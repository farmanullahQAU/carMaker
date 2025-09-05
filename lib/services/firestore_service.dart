// import 'package:cardmaker/models/card_template.dart';
// import 'package:cardmaker/services/auth_service.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:get/get.dart';

// class FirestoreService {
//   // 🔹 Private constructor
//   FirestoreService._internal();

//   // 🔹 The single instance
//   static final FirestoreService _instance = FirestoreService._internal();

//   // 🔹 Public accessor
//   factory FirestoreService() => _instance;

//   // 🔹 Firebase instance
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // 🔹 Always fetch latest userId (don’t cache it at init, otherwise null before login)
//   String? get userId => Get.find<AuthService>().user?.uid;

//   // Add a template to Firestore
//   Future<void> addTemplate(String id, Map<String, dynamic> templateData) async {
//     if (userId == null) throw Exception('User not authenticated');
//     await _firestore.collection('templates').doc(id).set(templateData);
//   }

//   // Get templates with pagination
//   Future<QuerySnapshot<Map<String, dynamic>>> getTemplatesPaginated({
//     String? category,
//     List<String>? tags,
//     int limit = 20,
//     DocumentSnapshot? startAfterDocument,
//   }) async {
//     Query<Map<String, dynamic>> query = _firestore
//         .collection('templates')
//         .limit(limit);

//     if (category != null) {
//       query = query.where('category', isEqualTo: category);
//     }
//     if (tags != null && tags.isNotEmpty) {
//       query = query.where('tags', arrayContainsAny: tags);
//     }
//     if (startAfterDocument != null) {
//       query = query.startAfterDocument(startAfterDocument);
//     }

//     return await query.get();
//   }

//   // Get templates count
//   Future<int> getTemplatesCount({String? category}) async {
//     Query<Map<String, dynamic>> query = _firestore.collection('templates');
//     if (category != null) {
//       query = query.where('category', isEqualTo: category);
//     }
//     final snapshot = await query.get();
//     return snapshot.docs.length;
//   }

//   // Search templates with pagination
//   Future<QuerySnapshot<Map<String, dynamic>>> searchTemplatesPaginated({
//     required String searchTerm,
//     String? category,
//     int limit = 20,
//     DocumentSnapshot? startAfterDocument,
//   }) async {
//     Query<Map<String, dynamic>> query = _firestore
//         .collection('templates')
//         .where('name', isGreaterThanOrEqualTo: searchTerm)
//         .where('name', isLessThanOrEqualTo: '$searchTerm\uf8ff')
//         .limit(limit);

//     if (category != null) {
//       query = query.where('category', isEqualTo: category);
//     }
//     if (startAfterDocument != null) {
//       query = query.startAfterDocument(startAfterDocument);
//     }

//     return await query.get();
//   }

//   // Add a template to favorites
//   Future<void> addToFavorites(String templateId) async {
//     if (userId == null) throw Exception('User not authenticated');

//     final favoriteRef = _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('favorites')
//         .doc(templateId);

//     await favoriteRef.set({
//       'addedAt': FieldValue.serverTimestamp(),
//       'templateRef': _firestore.collection('templates').doc(templateId),
//     });

//     await _firestore.collection('templates').doc(templateId).update({
//       'favoriteCount': FieldValue.increment(1),
//     });
//   }

//   // Remove a template from favorites
//   Future<void> removeFromFavorites(String templateId) async {
//     if (userId == null) throw Exception('User not authenticated');

//     await _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('favorites')
//         .doc(templateId)
//         .delete();

//     await _firestore.collection('templates').doc(templateId).update({
//       'favoriteCount': FieldValue.increment(-1),
//     });
//   }

//   // Get favorite template IDs
//   Future<List<String>> getFavoriteTemplateIds() async {
//     if (userId == null) return [];

//     final snapshot = await _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('favorites')
//         .get();

//     return snapshot.docs.map((doc) => doc.id).toList();
//   }

//   // Get favorite template IDs with pagination
//   Future<QuerySnapshot<Map<String, dynamic>>> getFavoriteTemplateIdsPaginated({
//     int limit = 20,
//     DocumentSnapshot? startAfterDocument,
//   }) async {
//     if (userId == null) throw Exception('User not authenticated');

//     Query<Map<String, dynamic>> query = _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('favorites')
//         .orderBy('addedAt', descending: true)
//         .limit(limit);

//     if (startAfterDocument != null) {
//       query = query.startAfterDocument(startAfterDocument);
//     }

//     return await query.get();
//   }

//   // Get favorite templates with pagination
//   Future<List<CardTemplate>> getFavoriteTemplates({
//     int limit = 20,
//     DocumentSnapshot? startAfterDocument,
//   }) async {
//     if (userId == null) return [];

//     Query<Map<String, dynamic>> query = _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('favorites')
//         .orderBy('addedAt', descending: true)
//         .limit(limit);

//     if (startAfterDocument != null) {
//       query = query.startAfterDocument(startAfterDocument);
//     }

//     final favoriteSnapshot = await query.get();
//     final templateIds = favoriteSnapshot.docs.map((doc) => doc.id).toList();

//     if (templateIds.isEmpty) return [];

//     const int batchSize = 10;
//     final List<CardTemplate> templates = [];
//     for (int i = 0; i < templateIds.length; i += batchSize) {
//       final batchIds = templateIds.sublist(
//         i,
//         i + batchSize > templateIds.length ? templateIds.length : i + batchSize,
//       );
//       final templateSnapshot = await _firestore
//           .collection('templates')
//           .where(FieldPath.documentId, whereIn: batchIds)
//           .get();
//       templates.addAll(
//         templateSnapshot.docs.map((doc) => CardTemplate.fromJson(doc.data())),
//       );
//     }

//     return templates;
//   }

//   // Save a draft
//   Future<void> saveDraft(String id, Map<String, dynamic> templateData) async {
//     if (userId == null) throw Exception('User not authenticated');

//     await _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('drafts')
//         .doc(id)
//         .set(templateData);
//   }

//   // Get user's drafts with pagination
//   Future<QuerySnapshot<Map<String, dynamic>>> getUserDraftsPaginated({
//     int limit = 20,
//     DocumentSnapshot? startAfterDocument,
//   }) async {
//     if (userId == null) throw Exception('User not authenticated');

//     Query<Map<String, dynamic>> query = _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('drafts')
//         .orderBy('createdAt', descending: false)
//         .limit(limit);

//     if (startAfterDocument != null) {
//       query = query.startAfterDocument(startAfterDocument);
//     }

//     return await query.get();
//   }

//   // Delete a draft
//   Future<void> deleteDraft(String draftId) async {
//     if (userId == null) throw Exception('User not authenticated');

//     await _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('drafts')
//         .doc(draftId)
//         .delete();
//   }

//   // Get drafts count
//   Future<int> getDraftsCount() async {
//     if (userId == null) return 0;

//     final snapshot = await _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('drafts')
//         .get();
//     return snapshot.docs.length;
//   }
// }
import 'dart:io';

import 'package:cardmaker/core/errors/failure.dart';
import 'package:cardmaker/core/errors/firebase_error_handler.dart';
import 'package:cardmaker/models/card_template.dart';
import 'package:cardmaker/services/auth_service.dart';
import 'package:cardmaker/services/firebase_storage_service.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/stack_board_item.dart';
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
  Future<String?> addTemplate(
    CardTemplate template, {
    File? thumbnailFile,
    File? backgroundFile,
  }) async {
    if (_isUploading.value) {
      throw const Failure(
        'upload-in-progress',
        'Another upload is in progress',
      );
    }

    _isUploading.value = true;

    try {
      // Create a copy of the template's items to modify
      final updatedItems = <Map<String, dynamic>>[];
      for (final itemJson in template.items) {
        final item = _deserializeItem(itemJson);
        if (item is StackImageItem && item.content?.filePath != null) {
          // Always save as .webp
          final imageUrl = await _storageService.uploadImage(
            File(item.content!.filePath!),
            template.id,
            'template_images',
            fileName: '${item.id}.webp',
            isDraft: template.isDraft,
          );

          // Update ImageItemContent with the URL
          final updatedContent = item.content!.copyWith(
            filePath: null, // Clear local file path
            url: imageUrl, // Set cloud URL
          );

          // Update the item with the new content
          final updatedItem = item.copyWith(content: updatedContent);
          updatedItems.add(updatedItem.toJson());
        } else {
          // Non-image item or image with URL/asset, keep as is
          updatedItems.add(itemJson);
        }
      }

      // Prepare template data with updated items
      final templateData = template.toJson();
      templateData['items'] = updatedItems;

      // Upload thumbnail if provided
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

      // Upload background if provided
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

      // Save template to Firestore
      if (template.isDraft) {
        await saveDraft(template.id, templateData);
      } else {
        await _firestore
            .collection('templates')
            .doc(template.id)
            .set(templateData);
      }
    } catch (e) {
      final errorMessage = FirebaseErrorHandler.handle(e).message;
      Get.snackbar("Error", errorMessage);
    } finally {
      _isUploading.value = false;
    }
    // Return an empty string or a success message if no error occurred
    return null;
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

  // Helper method to deserialize StackItem from JSON
  StackItem _deserializeItem(Map<String, dynamic> itemJson) {
    final type = itemJson['type'];
    if (type == 'StackTextItem') {
      return StackTextItem.fromJson(itemJson);
    } else if (type == 'StackImageItem') {
      return StackImageItem.fromJson(itemJson);
    } else {
      throw Exception('Unsupported item type: $type');
    }
  }
}
