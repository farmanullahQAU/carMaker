import 'dart:io';

import 'package:cardmaker/core/errors/failure.dart';
import 'package:cardmaker/core/errors/firebase_error_handler.dart';
import 'package:cardmaker/core/helper/image_helper.dart';
import 'package:cardmaker/models/card_template.dart';
import 'package:cardmaker/services/auth_service.dart';
import 'package:cardmaker/services/firebase_storage_service.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/stack_items.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FirestoreService {
  // 🔹 Private constructor
  FirestoreService._internal();

  // 🔹 The single instance
  static final FirestoreService _instance = FirestoreService._internal();

  // 🔹 Public accessor
  factory FirestoreService() => _instance;

  // 🔹 Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorageService _storageService = FirebaseStorageService();

  // 🔹 Rx variable for upload state
  final RxBool _isUploading = false.obs;

  // 🔹 Always fetch latest Facet latest userId (don’t cache it at init, otherwise null before login)
  String? get userId => Get.find<AuthService>().user?.uid;

  bool get isUploading => _isUploading.value;

  // Add a template to Firestore
  Future<void> addTemplate(
    CardTemplate template, {
    File? thumbnailFile,
    File? backgroundFile,
    Map<String, bool> newImageFlags = const {},
  }) async {
    if (_isUploading.value) {
      throw const Failure(
        'upload-in-progress',
        'Another upload is in progress',
      );
    }

    _isUploading.value = true;

    try {
      // Create a deep copy of template.items to avoid mutating the original
      final List<Map<String, dynamic>> modifiedItems = List.from(
        template.items,
      );

      for (int i = 0; i < modifiedItems.length; i++) {
        final itemJson = modifiedItems[i];
        final item = deserializeItem(itemJson);
        if (item is StackImageItem && item.content != null) {
          final isNewImage = newImageFlags[item.id] ?? false;
          final isPlaceholder = item.content!.isPlaceholder ?? false;
          print(
            'Item ${item.id}: filePath=${item.content?.filePath}, url=${item.content?.url}, isNewImage=$isNewImage, isPlaceholder=$isPlaceholder',
          );

          Map<String, dynamic> processedItemJson;

          if (isPlaceholder) {
            debugPrint('Processing placeholder item ${item.id}');
            final updatedContent = item.content!.copyWith(
              filePath: null,
              assetName: item.content!.assetName ?? 'assets/icon.png',
              isPlaceholder: true,
            );
            final updatedItem = item.copyWith(content: updatedContent);
            processedItemJson = updatedItem.toJson();
            print('After placeholder: filePath=${updatedContent.filePath}');
          } else if (isNewImage && item.content?.filePath != null) {
            debugPrint('Uploading new image for item ${item.id}');
            final imageUrl = await _storageService.uploadImage(
              File(item.content!.filePath!),
              template.id,
              'template_images',
              fileName: '${item.id}.webp',
              isDraft: template.isDraft,
            );
            final updatedContent = item.content!.copyWith(
              filePath: null,
              url: imageUrl,
              isPlaceholder: false,
            );
            final updatedItem = item.copyWith(content: updatedContent);
            processedItemJson = updatedItem.toJson();
            print(
              'After upload: filePath=${updatedContent.filePath}, url=${updatedContent.url}',
            );
          } else if (item.content?.url != null) {
            debugPrint('Reusing existing URL for item ${item.id}');
            final updatedContent = item.content!.copyWith(
              filePath: null,
              isPlaceholder: false,
            );
            final updatedItem = item.copyWith(content: updatedContent);
            processedItemJson = updatedItem.toJson();
            print('After reuse: filePath=${updatedContent.filePath}');
          } else {
            debugPrint('No filePath or URL for item ${item.id}');
            final updatedContent = item.content!.copyWith(
              filePath: null,
              isPlaceholder: item.content!.isPlaceholder ?? false,
            );
            final updatedItem = item.copyWith(content: updatedContent);
            processedItemJson = updatedItem.toJson();
            print('After no filePath/URL: filePath=${updatedContent.filePath}');
          }

          // Replace the item in the modifiedItems list
          modifiedItems[i] = processedItemJson;
        } else {
          debugPrint('Non-image item or null content for item ${item.id}');
          // Keep non-image items unchanged
          modifiedItems[i] = itemJson;
        }
      }

      final templateData = template.toJson();
      templateData['items'] = modifiedItems;

      if (thumbnailFile != null) {
        final thumbnailUrl = await _storageService.uploadImage(
          thumbnailFile,
          template.id,
          'thumbnails',
          fileName: 'thumbnail.webp',
          isDraft: template.isDraft,
        );
        templateData['thumbnailUrl'] = thumbnailUrl;
      }

      if (backgroundFile != null) {
        final backgroundUrl = await _storageService.uploadImage(
          backgroundFile,
          template.id,
          'backgrounds',
          fileName: 'background.webp',
          isDraft: template.isDraft,
        );
        templateData['backgroundImageUrl'] = backgroundUrl;
      }

      if (template.isDraft) {
        await saveDraft(template.id, templateData);
      } else {
        await _firestore
            .collection('templates')
            .doc(template.id)
            .set(templateData);
      }
    } catch (e) {
      print('Error in addTemplate: $e');
      throw FirebaseErrorHandler.handle(e).message;
    } finally {
      _isUploading.value = false;
    }
  }

  // Batch upload templates with progress tracking
  Future<void> uploadTemplatesInBatch(
    List<CardTemplate> templates, {
    ValueChanged<double>? onProgress,
  }) async {
    final total = templates.length;
    var completed = 0;

    try {
      for (final template in templates) {
        await addTemplate(template);
        completed++;
        if (onProgress != null) {
          onProgress(completed / total);
        }
        // Small delay to prevent overwhelming the server
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } catch (e) {
      throw FirebaseErrorHandler.handle(e);
    }
  }

  // Get templates with pagination
  Future<QuerySnapshot<Map<String, dynamic>>> getTemplatesPaginated({
    String? category,
    List<String>? tags,
    int limit = 20,
    DocumentSnapshot? startAfterDocument,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('templates')
          .limit(limit);

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }
      if (tags != null && tags.isNotEmpty) {
        query = query.where('tags', arrayContainsAny: tags);
      }
      if (startAfterDocument != null) {
        query = query.startAfterDocument(startAfterDocument);
      }

      return await query.get();
    } catch (e) {
      throw FirebaseErrorHandler.handle(e);
    }
  }

  // Get free and featured templates with pagination
  Future<QuerySnapshot<Map<String, dynamic>>> getFreeTodayTemplatesPaginated({
    int limit = 20,
    DocumentSnapshot? startAfterDocument,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('templates')
          .where('isPremium', isEqualTo: false)
          // .where('isFeatured', isEqualTo: true)
          .limit(limit);

      if (startAfterDocument != null) {
        query = query.startAfterDocument(startAfterDocument);
      }

      return await query.get();
    } catch (e) {
      throw FirebaseErrorHandler.handle(e);
    }
  }

  // Get premium and featured templates (Trending) with pagination
  Future<QuerySnapshot<Map<String, dynamic>>> getTrendingTemplatesPaginated({
    int limit = 20,
    DocumentSnapshot? startAfterDocument,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('templates')
          .where('isPremium', isEqualTo: true)
          .where('isFeatured', isEqualTo: true)
          .limit(limit);

      if (startAfterDocument != null) {
        query = query.startAfterDocument(startAfterDocument);
      }

      return await query.get();
    } catch (e) {
      throw FirebaseErrorHandler.handle(e);
    }
  }

  // Get templates count
  Future<int> getTemplatesCount({String? category}) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('templates');
      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }
      final snapshot = await query.get();
      return snapshot.docs.length;
    } catch (e) {
      throw FirebaseErrorHandler.handle(e);
    }
  }

  // Search templates with pagination
  Future<QuerySnapshot<Map<String, dynamic>>> searchTemplatesPaginated({
    required String searchTerm,
    String? category,
    int limit = 20,
    DocumentSnapshot? startAfterDocument,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('templates')
          .where('name', isGreaterThanOrEqualTo: searchTerm)
          .where('name', isLessThanOrEqualTo: '$searchTerm\uf8ff')
          .limit(limit);

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }
      if (startAfterDocument != null) {
        query = query.startAfterDocument(startAfterDocument);
      }

      return await query.get();
    } catch (e) {
      throw FirebaseErrorHandler.handle(e);
    }
  }

  // Get templates by category with proper typing
  Future<List<CardTemplate>> getTemplatesByCategory({
    required String category,
    int limit = 20,
    DocumentSnapshot? startAfterDocument,
  }) async {
    try {
      final snapshot = await getTemplatesPaginated(
        category: category,
        limit: limit,
        startAfterDocument: startAfterDocument,
      );

      return snapshot.docs
          .map((doc) => CardTemplate.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw FirebaseErrorHandler.handle(e);
    }
  }

  // Add a template to favorites
  Future<void> addToFavorites(String templateId) async {
    if (userId == null) {
      throw const Failure('unauthenticated', 'User not authenticated');
    }

    try {
      final favoriteRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(templateId);

      await favoriteRef.set({
        'addedAt': FieldValue.serverTimestamp(),
        'templateRef': _firestore.collection('templates').doc(templateId),
      });

      await _firestore.collection('templates').doc(templateId).update({
        'favoriteCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw FirebaseErrorHandler.handle(e);
    }
  }

  // Remove a template from favorites
  Future<void> removeFromFavorites(String templateId) async {
    if (userId == null) {
      throw const Failure('unauthenticated', 'User not authenticated');
    }

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(templateId)
          .delete();

      await _firestore.collection('templates').doc(templateId).update({
        'favoriteCount': FieldValue.increment(-1),
      });
    } catch (e) {
      throw FirebaseErrorHandler.handle(e);
    }
  }

  // Get favorite template IDs
  Future<List<String>> getFavoriteTemplateIds() async {
    if (userId == null) {
      return [];
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      throw FirebaseErrorHandler.handle(e);
    }
  }

  // Get favorite template IDs with pagination
  Future<QuerySnapshot<Map<String, dynamic>>> getFavoriteTemplateIdsPaginated({
    int limit = 20,
    DocumentSnapshot? startAfterDocument,
  }) async {
    if (userId == null) {
      throw const Failure('unauthenticated', 'User not authenticated');
    }

    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .orderBy('addedAt', descending: true)
          .limit(limit);

      if (startAfterDocument != null) {
        query = query.startAfterDocument(startAfterDocument);
      }

      return await query.get();
    } catch (e) {
      throw FirebaseErrorHandler.handle(e);
    }
  }

  // Get favorite templates with pagination
  Future<List<CardTemplate>> getFavoriteTemplates({
    int limit = 20,
    DocumentSnapshot? startAfterDocument,
  }) async {
    if (userId == null) {
      return [];
    }

    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .orderBy('addedAt', descending: true)
          .limit(limit);

      if (startAfterDocument != null) {
        query = query.startAfterDocument(startAfterDocument);
      }

      final favoriteSnapshot = await query.get();
      final templateIds = favoriteSnapshot.docs.map((doc) => doc.id).toList();

      if (templateIds.isEmpty) return [];

      const int batchSize = 10;
      final List<CardTemplate> templates = [];
      for (int i = 0; i < templateIds.length; i += batchSize) {
        final batchIds = templateIds.sublist(
          i,
          i + batchSize > templateIds.length
              ? templateIds.length
              : i + batchSize,
        );
        final templateSnapshot = await _firestore
            .collection('templates')
            .where(FieldPath.documentId, whereIn: batchIds)
            .get();
        templates.addAll(
          templateSnapshot.docs.map((doc) => CardTemplate.fromJson(doc.data())),
        );
      }

      return templates;
    } catch (e) {
      throw FirebaseErrorHandler.handle(e);
    }
  }

  // Save a draft
  Future<void> saveDraft(String id, Map<String, dynamic> templateData) async {
    if (userId == null) {
      throw const Failure('unauthenticated', 'User not authenticated');
    }

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('drafts')
          .doc(id)
          .set(templateData);
    } catch (e) {
      throw FirebaseErrorHandler.handle(e);
    }
  }

  // Get user's drafts with pagination
  Future<QuerySnapshot<Map<String, dynamic>>> getUserDraftsPaginated({
    int limit = 20,
    DocumentSnapshot? startAfterDocument,
  }) async {
    if (userId == null) {
      throw const Failure('unauthenticated', 'User not authenticated');
    }

    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('users')
          .doc(userId)
          .collection('drafts')
          .orderBy('createdAt', descending: false)
          .limit(limit);

      if (startAfterDocument != null) {
        query = query.startAfterDocument(startAfterDocument);
      }

      return await query.get();
    } catch (e) {
      throw FirebaseErrorHandler.handle(e);
    }
  }

  // Get user's drafts as CardTemplate list
  Future<List<CardTemplate>> getUserDrafts({
    int limit = 20,
    DocumentSnapshot? startAfterDocument,
  }) async {
    try {
      final snapshot = await getUserDraftsPaginated(
        limit: limit,
        startAfterDocument: startAfterDocument,
      );

      return snapshot.docs
          .map((doc) => CardTemplate.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw FirebaseErrorHandler.handle(e);
    }
  }

  // Delete a draft
  Future<void> deleteDraft(String draftId) async {
    if (userId == null) {
      throw const Failure('unauthenticated', 'User not authenticated');
    }

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('drafts')
          .doc(draftId)
          .delete();
    } catch (e) {
      throw FirebaseErrorHandler.handle(e);
    }
  }

  // Get drafts count
  Future<int> getDraftsCount() async {
    if (userId == null) {
      return 0;
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('drafts')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      throw FirebaseErrorHandler.handle(e);
    }
  }
}
