// import 'dart:io';

// import 'package:cardmaker/core/errors/failure.dart';
// import 'package:cardmaker/core/errors/firebase_error_handler.dart';
// import 'package:cardmaker/core/helper/image_helper.dart';
// import 'package:cardmaker/models/card_template.dart';
// import 'package:cardmaker/services/auth_service.dart';
// import 'package:cardmaker/services/firebase_storage_service.dart';
// import 'package:cardmaker/widgets/common/stack_board/lib/stack_items.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class FirestoreServices {
//   // 🔹 Private constructor
//   FirestoreServices._internal();

//   // 🔹 The single instance
//   static final FirestoreServices _instance = FirestoreServices._internal();

//   // 🔹 Public accessor
//   factory FirestoreServices() => _instance;

//   // 🔹 Firebase instances
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseStorageService _storageService = FirebaseStorageService();

//   // 🔹 Rx variable for upload state
//   final RxBool _isUploading = false.obs;

//   // 🔹 Always fetch latest Facet latest userId (don’t cache it at init, otherwise null before login)
//   String? get userId => Get.find<AuthService>().user?.uid;

//   bool get isUploading => _isUploading.value;

//   // Add a template to Firestore
//   Future<void> addTemplate(
//     CardTemplate template, {
//     File? thumbnailFile,
//     File? backgroundFile,
//   }) async {
//     if (_isUploading.value) {
//       throw const Failure(
//         'upload-in-progress',
//         'Another upload is in progress',
//       );
//     }

//     _isUploading.value = true;

//     try {
//       // Create a deep copy of template.items to avoid mutating the original
//       final List<Map<String, dynamic>> modifiedItems = List.from(
//         template.items,
//       );

//       for (int i = 0; i < modifiedItems.length; i++) {
//         final itemJson = modifiedItems[i];
//         final item = deserializeItem(itemJson);
//         if (item is StackImageItem && item.content != null) {
//           final isPlaceholder = item.content!.isPlaceholder ?? false;

//           Map<String, dynamic> processedItemJson;

//           if (isPlaceholder) {
//             debugPrint('Processing placeholder item ${item.id}');
//             final updatedContent = item.content!.copyWith(
//               filePath: null,
//               assetName: item.content!.assetName ?? 'assets/icon.png',
//               isPlaceholder: true,
//             );
//             final updatedItem = item.copyWith(content: updatedContent);
//             processedItemJson = updatedItem.toJson();
//             print('After placeholder: filePath=${updatedContent.filePath}');
//           } else if (item.content?.filePath != null) {
//             debugPrint('Uploading new image for item ${item.id}');
//             final imageUrl = await _storageService.uploadImage(
//               File(item.content!.filePath!),
//               template.id,
//               'template_images',
//               fileName: '${item.id}.webp',
//               isDraft: template.isDraft,
//             );
//             final updatedContent = item.content!.copyWith(
//               filePath: null,
//               url: imageUrl,
//               isPlaceholder: false,
//             );
//             final updatedItem = item.copyWith(content: updatedContent);
//             processedItemJson = updatedItem.toJson();
//             print(
//               'After upload: filePath=${updatedContent.filePath}, url=${updatedContent.url}',
//             );
//           } else if (item.content?.url != null) {
//             debugPrint('Reusing existing URL for item ${item.id}');
//             final updatedContent = item.content!.copyWith(
//               filePath: null,
//               isPlaceholder: false,
//             );
//             final updatedItem = item.copyWith(content: updatedContent);
//             processedItemJson = updatedItem.toJson();
//             print('After reuse: filePath=${updatedContent.filePath}');
//           } else {
//             debugPrint('No filePath or URL for item ${item.id}');
//             final updatedContent = item.content!.copyWith(
//               filePath: null,
//               isPlaceholder: item.content!.isPlaceholder ?? false,
//             );
//             final updatedItem = item.copyWith(content: updatedContent);
//             processedItemJson = updatedItem.toJson();
//             print('After no filePath/URL: filePath=${updatedContent.filePath}');
//           }

//           // Replace the item in the modifiedItems list
//           modifiedItems[i] = processedItemJson;
//         } else {
//           debugPrint('Non-image item or null content for item ${item.id}');
//           // Keep non-image items unchanged
//           modifiedItems[i] = itemJson;
//         }
//       }

//       final templateData = template.toJson();
//       templateData['items'] = modifiedItems;

//       if (thumbnailFile != null) {
//         final thumbnailUrl = await _storageService.uploadImage(
//           thumbnailFile,
//           template.id,
//           'thumbnails',
//           fileName: 'thumbnail.webp',
//           isDraft: template.isDraft,
//         );
//         templateData['thumbnailUrl'] = thumbnailUrl;
//       }

//       if (backgroundFile != null) {
//         final backgroundUrl = await _storageService.uploadImage(
//           backgroundFile,
//           template.id,
//           'backgrounds',
//           fileName: 'background.webp',
//           isDraft: template.isDraft,
//         );
//         templateData['backgroundImageUrl'] = backgroundUrl;
//       }

//       if (template.isDraft) {
//         // await saveDraft(template.id, templateData);
//         await _firestore
//             .collection('users')
//             .doc(userId)
//             .collection('drafts')
//             .doc(template.id)
//             .set(templateData);
//       } else {
//         await _firestore
//             .collection('templates')
//             .doc(template.id)
//             .set(templateData);
//       }
//     } catch (e) {
//       print('Error in addTemplate: $e');
//       throw FirebaseErrorHandler.handle(e).message;
//     } finally {
//       _isUploading.value = false;
//     }
//   }

//   // Batch upload templates with progress tracking
//   Future<void> uploadTemplatesInBatch(
//     List<CardTemplate> templates, {
//     ValueChanged<double>? onProgress,
//   }) async {
//     final total = templates.length;
//     var completed = 0;

//     try {
//       for (final template in templates) {
//         await addTemplate(template);
//         completed++;
//         if (onProgress != null) {
//           onProgress(completed / total);
//         }
//         // Small delay to prevent overwhelming the server
//         await Future.delayed(const Duration(milliseconds: 100));
//       }
//     } catch (e) {
//       throw FirebaseErrorHandler.handle(e);
//     }
//   }

//   // Get templates with pagination
//   Future<QuerySnapshot<Map<String, dynamic>>> getTemplatesPaginated({
//     String? category,
//     List<String>? tags,
//     int limit = 20,
//     DocumentSnapshot? startAfterDocument,
//   }) async {
//     try {
//       Query<Map<String, dynamic>> query = _firestore
//           .collection('templates')
//           .limit(limit);

//       if (category != null) {
//         query = query.where('category', isEqualTo: category);
//       }
//       if (tags != null && tags.isNotEmpty) {
//         query = query.where('tags', arrayContainsAny: tags);
//       }
//       if (startAfterDocument != null) {
//         query = query.startAfterDocument(startAfterDocument);
//       }

//       return await query.get();
//     } catch (e) {
//       throw FirebaseErrorHandler.handle(e);
//     }
//   }

//   // Get free and featured templates with pagination
//   Future<QuerySnapshot<Map<String, dynamic>>> getFreeTodayTemplatesPaginated({
//     int limit = 20,
//     DocumentSnapshot? startAfterDocument,
//   }) async {
//     try {
//       Query<Map<String, dynamic>> query = _firestore
//           .collection('templates')
//           .where('isPremium', isEqualTo: false)
//           // .where('isFeatured', isEqualTo: true)
//           .limit(limit);

//       if (startAfterDocument != null) {
//         query = query.startAfterDocument(startAfterDocument);
//       }

//       return await query.get();
//     } catch (e) {
//       throw FirebaseErrorHandler.handle(e);
//     }
//   }

//   // Get premium and featured templates (Trending) with pagination
//   Future<QuerySnapshot<Map<String, dynamic>>> getTrendingTemplatesPaginated({
//     int limit = 20,
//     DocumentSnapshot? startAfterDocument,
//   }) async {
//     try {
//       Query<Map<String, dynamic>> query = _firestore
//           .collection('templates')
//           .where('isPremium', isEqualTo: true)
//           .where('isFeatured', isEqualTo: true)
//           .limit(limit);

//       if (startAfterDocument != null) {
//         query = query.startAfterDocument(startAfterDocument);
//       }

//       return await query.get();
//     } catch (e) {
//       throw FirebaseErrorHandler.handle(e);
//     }
//   }

//   // Get templates count
//   Future<int> getTemplatesCount({String? category}) async {
//     try {
//       Query<Map<String, dynamic>> query = _firestore.collection('templates');
//       if (category != null) {
//         query = query.where('category', isEqualTo: category);
//       }
//       final snapshot = await query.get();
//       return snapshot.docs.length;
//     } catch (e) {
//       throw FirebaseErrorHandler.handle(e);
//     }
//   }

//   // Search templates with pagination
//   Future<QuerySnapshot<Map<String, dynamic>>> searchTemplatesPaginated({
//     required String searchTerm,
//     String? category,
//     int limit = 20,
//     DocumentSnapshot? startAfterDocument,
//   }) async {
//     try {
//       Query<Map<String, dynamic>> query = _firestore
//           .collection('templates')
//           .where('name', isGreaterThanOrEqualTo: searchTerm)
//           .where('name', isLessThanOrEqualTo: '$searchTerm\uf8ff')
//           .limit(limit);

//       if (category != null) {
//         query = query.where('category', isEqualTo: category);
//       }
//       if (startAfterDocument != null) {
//         query = query.startAfterDocument(startAfterDocument);
//       }

//       return await query.get();
//     } catch (e) {
//       throw FirebaseErrorHandler.handle(e);
//     }
//   }

//   // Get templates by category with proper typing
//   Future<List<CardTemplate>> getTemplatesByCategory({
//     required String category,
//     int limit = 20,
//     DocumentSnapshot? startAfterDocument,
//   }) async {
//     try {
//       final snapshot = await getTemplatesPaginated(
//         category: category,
//         limit: limit,
//         startAfterDocument: startAfterDocument,
//       );

//       return snapshot.docs
//           .map((doc) => CardTemplate.fromJson(doc.data()))
//           .toList();
//     } catch (e) {
//       throw FirebaseErrorHandler.handle(e);
//     }
//   }

//   // Add a template to favorites
//   Future<void> addToFavorites(String templateId) async {
//     if (userId == null) {
//       throw const Failure('unauthenticated', 'User not authenticated');
//     }

//     try {
//       final favoriteRef = _firestore
//           .collection('users')
//           .doc(userId)
//           .collection('favorites')
//           .doc(templateId);

//       await favoriteRef.set({
//         'addedAt': FieldValue.serverTimestamp(),
//         'templateRef': _firestore.collection('templates').doc(templateId),
//       });

//       await _firestore.collection('templates').doc(templateId).update({
//         'favoriteCount': FieldValue.increment(1),
//       });
//     } catch (e) {
//       throw FirebaseErrorHandler.handle(e);
//     }
//   }

//   // Remove a template from favorites
//   Future<void> removeFromFavorites(String templateId) async {
//     if (userId == null) {
//       // throw const Failure('unauthenticated', 'User not authenticated');
//       throw "Login to remove from favorite";
//     }

//     try {
//       await _firestore
//           .collection('users')
//           .doc(userId)
//           .collection('favorites')
//           .doc(templateId)
//           .delete();

//       await _firestore.collection('templates').doc(templateId).update({
//         'favoriteCount': FieldValue.increment(-1),
//       });
//     } catch (e) {
//       throw FirebaseErrorHandler.handle(e).message;
//     }
//   }

//   // Get favorite template IDs
//   Future<List<String>> getFavoriteTemplateIds() async {
//     if (userId == null) {
//       return [];
//     }

//     try {
//       final snapshot = await _firestore
//           .collection('users')
//           .doc(userId)
//           .collection('favorites')
//           .get();

//       return snapshot.docs.map((doc) => doc.id).toList();
//     } catch (e) {
//       throw FirebaseErrorHandler.handle(e);
//     }
//   }

//   // Get favorite template IDs with pagination
//   Future<QuerySnapshot<Map<String, dynamic>>> getFavoriteTemplateIdsPaginated({
//     int limit = 20,
//     DocumentSnapshot? startAfterDocument,
//   }) async {
//     if (userId == null) {
//       throw const Failure('unauthenticated', 'User not authenticated');
//     }

//     try {
//       Query<Map<String, dynamic>> query = _firestore
//           .collection('users')
//           .doc(userId)
//           .collection('favorites')
//           .orderBy('addedAt', descending: true)
//           .limit(limit);

//       if (startAfterDocument != null) {
//         query = query.startAfterDocument(startAfterDocument);
//       }

//       return await query.get();
//     } catch (e) {
//       throw FirebaseErrorHandler.handle(e);
//     }
//   }

//   // Get favorite templates with pagination
//   Future<List<CardTemplate>> getFavoriteTemplates({
//     int limit = 20,
//     DocumentSnapshot? startAfterDocument,
//   }) async {
//     if (userId == null) {
//       return [];
//     }

//     try {
//       Query<Map<String, dynamic>> query = _firestore
//           .collection('users')
//           .doc(userId)
//           .collection('favorites')
//           .orderBy('addedAt', descending: true)
//           .limit(limit);

//       if (startAfterDocument != null) {
//         query = query.startAfterDocument(startAfterDocument);
//       }

//       final favoriteSnapshot = await query.get();
//       final templateIds = favoriteSnapshot.docs.map((doc) => doc.id).toList();

//       if (templateIds.isEmpty) return [];

//       const int batchSize = 10;
//       final List<CardTemplate> templates = [];
//       for (int i = 0; i < templateIds.length; i += batchSize) {
//         final batchIds = templateIds.sublist(
//           i,
//           i + batchSize > templateIds.length
//               ? templateIds.length
//               : i + batchSize,
//         );
//         final templateSnapshot = await _firestore
//             .collection('templates')
//             .where(FieldPath.documentId, whereIn: batchIds)
//             .get();
//         templates.addAll(
//           templateSnapshot.docs.map((doc) => CardTemplate.fromJson(doc.data())),
//         );
//       }

//       return templates;
//     } catch (e) {
//       throw FirebaseErrorHandler.handle(e);
//     }
//   }

//   // Save a draft
//   // Future<void> saveDraft(String id, Map<String, dynamic> templateData) async {
//   //   if (userId == null) {
//   //     throw const Failure('unauthenticated', 'User not authenticated');
//   //   }

//   //   try {
//   //     await _firestore
//   //         .collection('users')
//   //         .doc(userId)
//   //         .collection('drafts')
//   //         .doc(id)
//   //         .set(templateData);
//   //   } catch (e) {
//   //     throw FirebaseErrorHandler.handle(e);
//   //   }
//   // }

//   // Get user's drafts with pagination
//   Future<QuerySnapshot<Map<String, dynamic>>> getUserDraftsPaginated({
//     int limit = 20,
//     DocumentSnapshot? startAfterDocument,
//   }) async {
//     if (userId == null) {
//       throw const Failure('unauthenticated', 'User not authenticated');
//     }

//     try {
//       Query<Map<String, dynamic>> query = _firestore
//           .collection('users')
//           .doc(userId)
//           .collection('drafts')
//           .orderBy('createdAt', descending: false)
//           .limit(limit);

//       if (startAfterDocument != null) {
//         query = query.startAfterDocument(startAfterDocument);
//       }

//       return await query.get();
//     } catch (e) {
//       throw FirebaseErrorHandler.handle(e);
//     }
//   }

//   // Get user's drafts as CardTemplate list
//   Future<List<CardTemplate>> getUserDrafts({
//     int limit = 20,
//     DocumentSnapshot? startAfterDocument,
//   }) async {
//     try {
//       final snapshot = await getUserDraftsPaginated(
//         limit: limit,
//         startAfterDocument: startAfterDocument,
//       );

//       return snapshot.docs
//           .map((doc) => CardTemplate.fromJson(doc.data()))
//           .toList();
//     } catch (e) {
//       throw FirebaseErrorHandler.handle(e);
//     }
//   }

//   // Delete a draft
//   Future<void> deleteDraft(String draftId) async {
//     if (userId == null) {
//       throw const Failure('unauthenticated', 'User not authenticated');
//     }

//     try {
//       // First, get the draft data to find associated files
//       final draftDoc = await _firestore
//           .collection('users')
//           .doc(userId)
//           .collection('drafts')
//           .doc(draftId)
//           .get();

//       if (draftDoc.exists) {
//         final template = CardTemplate.fromJson(draftDoc.data()!);

//         // Delete from Firestore
//         await _firestore
//             .collection('users')
//             .doc(userId)
//             .collection('drafts')
//             .doc(draftId)
//             .delete();

//         // Delete associated files from Firebase Storage
//         await _deleteDraftFiles(draftId, template);
//       }
//     } catch (e) {
//       throw FirebaseErrorHandler.handle(e);
//     }
//   }

//   // Delete all files associated with a draft
//   Future<void> _deleteDraftFiles(String draftId, CardTemplate template) async {
//     final FirebaseStorage storage = FirebaseStorage.instance;

//     try {
//       final basePath = 'user_drafts/$userId/$draftId';
//       final storageRef = storage.ref().child(basePath);

//       // Delete entire folder recursively (includes thumbnails, backgrounds, template_images)
//       await storageRef.listAll().then((result) {
//         // Delete all items in the folder
//         final deleteFutures = <Future>[];

//         // Delete all files in subfolders
//         for (final prefix in result.prefixes) {
//           deleteFutures.add(
//             prefix.listAll().then((subResult) {
//               return Future.wait(subResult.items.map((item) => item.delete()));
//             }),
//           );
//         }

//         // Delete all files in root
//         deleteFutures.addAll(result.items.map((item) => item.delete()));

//         return Future.wait(deleteFutures);
//       });
//     } catch (e) {
//       debugPrint('Error deleting draft files: $e');
//       // Don't throw here - we want to complete the draft deletion even if file deletion fails
//     }
//   }

//   // Get drafts count
//   Future<int> getDraftsCount() async {
//     if (userId == null) {
//       return 0;
//     }

//     try {
//       final snapshot = await _firestore
//           .collection('users')
//           .doc(userId)
//           .collection('drafts')
//           .get();
//       return snapshot.docs.length;
//     } catch (e) {
//       throw FirebaseErrorHandler.handle(e);
//     }
//   }
// }
import 'dart:io';

import 'package:cardmaker/core/errors/failure.dart';
import 'package:cardmaker/core/errors/firebase_error_handler.dart';
import 'package:cardmaker/core/helper/image_helper.dart';
import 'package:cardmaker/models/card_template.dart';
import 'package:cardmaker/models/user_model.dart';
import 'package:cardmaker/services/auth_service.dart';
import 'package:cardmaker/services/firebase_storage_service.dart';
import 'package:cardmaker/services/remote_config.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/stack_items.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FirestoreServices {
  // 🔹 Private constructor
  FirestoreServices._internal();

  // 🔹 The single instance
  static final FirestoreServices _instance = FirestoreServices._internal();

  // 🔹 Public accessor
  factory FirestoreServices() => _instance;

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
          final isPlaceholder = item.content!.isPlaceholder ?? false;

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
          } else if (item.content?.filePath != null) {
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
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('drafts')
            .doc(template.id)
            .set(templateData);
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
    bool useCache = false,
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

      // useCache=true: Only use cache (fast, but might be stale)
      // useCache=false: Use serverAndCache (shows cache immediately, then updates with fresh data)
      return await query.get(
        GetOptions(source: useCache ? Source.cache : Source.serverAndCache),
      );
    } catch (e) {
      throw FirebaseErrorHandler.handle(e);
    }
  }

  // Get free and featured templates with pagination
  Future<QuerySnapshot<Map<String, dynamic>>> getFreeTodayTemplatesPaginated({
    int limit = 20,
    DocumentSnapshot? startAfterDocument,
    bool useCache = false,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('templates')
          .where('isPremium', isEqualTo: false)
          .limit(limit);

      if (startAfterDocument != null) {
        query = query.startAfterDocument(startAfterDocument);
      }

      // useCache=true: Only use cache (fast, but might be stale)
      // useCache=false: Use serverAndCache (shows cache immediately, then updates with fresh data)
      return await query.get(
        GetOptions(source: useCache ? Source.cache : Source.serverAndCache),
      );
    } catch (e) {
      throw FirebaseErrorHandler.handle(e);
    }
  }

  // Get premium and featured templates (Trending) with pagination
  Future<QuerySnapshot<Map<String, dynamic>>> getTrendingTemplatesPaginated({
    int limit = 20,
    DocumentSnapshot? startAfterDocument,
    bool useCache = false,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('templates')
          .where('isPremium', isEqualTo: true)
          // .where('isFeatured', isEqualTo: true)
          .limit(limit);

      if (startAfterDocument != null) {
        query = query.startAfterDocument(startAfterDocument);
      }

      // useCache=true: Only use cache (fast, but might be stale)
      // useCache=false: Use serverAndCache (shows cache immediately, then updates with fresh data)
      return await query.get(
        GetOptions(source: useCache ? Source.cache : Source.serverAndCache),
      );
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

  // Get a single template by ID
  Future<CardTemplate?> getTemplateById(String templateId) async {
    try {
      final doc = await _firestore
          .collection('templates')
          .doc(templateId)
          .get();
      return doc.exists ? CardTemplate.fromJson(doc.data()!) : null;
    } catch (e) {
      throw FirebaseErrorHandler.handle(e);
    }
  }

  // Get templates by IDs
  Future<List<CardTemplate>> getTemplatesByIds(List<String> templateIds) async {
    try {
      if (templateIds.isEmpty) return [];
      const int batchSize = 10; // Firestore whereIn limit
      final List<CardTemplate> templates = [];
      for (int i = 0; i < templateIds.length; i += batchSize) {
        final batchIds = templateIds.sublist(
          i,
          i + batchSize > templateIds.length
              ? templateIds.length
              : i + batchSize,
        );
        final snapshot = await _firestore
            .collection('templates')
            .where(FieldPath.documentId, whereIn: batchIds)
            .get();
        templates.addAll(
          snapshot.docs.map((doc) => CardTemplate.fromJson(doc.data())),
        );
      }
      return templates;
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
      throw "Login to remove from favorite";
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
      throw FirebaseErrorHandler.handle(e).message;
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
      // First, get the draft data to find associated files
      final draftDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('drafts')
          .doc(draftId)
          .get();

      if (draftDoc.exists) {
        final template = CardTemplate.fromJson(draftDoc.data()!);

        // Delete from Firestore
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('drafts')
            .doc(draftId)
            .delete();

        // Delete associated files from Firebase Storage
        await _deleteDraftFiles(draftId, template);
      }
    } catch (e) {
      throw FirebaseErrorHandler.handle(e);
    }
  }

  // Delete all files associated with a draft
  Future<void> _deleteDraftFiles(String draftId, CardTemplate template) async {
    final FirebaseStorage storage = FirebaseStorage.instance;

    try {
      final basePath = 'user_drafts/$userId/$draftId';
      final storageRef = storage.ref().child(basePath);

      // Delete entire folder recursively (includes thumbnails, backgrounds, template_images)
      await storageRef.listAll().then((result) {
        // Delete all items in the folder
        final deleteFutures = <Future>[];

        // Delete all files in subfolders
        for (final prefix in result.prefixes) {
          deleteFutures.add(
            prefix.listAll().then((subResult) {
              return Future.wait(subResult.items.map((item) => item.delete()));
            }),
          );
        }

        // Delete all files in root
        deleteFutures.addAll(result.items.map((item) => item.delete()));

        return Future.wait(deleteFutures);
      });
    } catch (e) {
      debugPrint('Error deleting draft files: $e');
      // Don't throw here - we want to complete the draft deletion even if file deletion fails
    }
  }

  // Save or update user in Firestore
  Future<void> saveUser(UserModel user) async {
    try {
      final docRef = _firestore.collection('users').doc(user.id);
      final existingDoc = await docRef.get();

      UserModel userToSave = user;

      if (existingDoc.exists) {
        final existingData = existingDoc.data();
        final existingRoleValue = existingData?['role'];

        if (existingRoleValue is String) {
          final existingRole = UserRole.values.firstWhere(
            (role) => role.toString().split('.').last == existingRoleValue,
            orElse: () => user.role,
          );

          // Preserve existing elevated roles unless the new payload explicitly changes it
          if (user.role == UserRole.user && existingRole != UserRole.user) {
            userToSave = user.copyWith(role: existingRole);
          }
        }
      }

      await docRef.set(userToSave.toJson(), SetOptions(merge: true));
    } catch (e) {
      throw FirebaseErrorHandler.handle(e);
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw FirebaseErrorHandler.handle(e);
    }
  }

  // Get all templates (for admin)
  Future<List<CardTemplate>> getAllTemplates({
    int limit = 100,
    DocumentSnapshot? startAfterDocument,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('templates')
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (startAfterDocument != null) {
        query = query.startAfterDocument(startAfterDocument);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => CardTemplate.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw FirebaseErrorHandler.handle(e);
    }
  }

  // Delete template (admin only) - includes storage cleanup
  Future<void> deleteTemplate(String templateId) async {
    try {
      // First, get the template data to find associated files
      final templateDoc = await _firestore
          .collection('templates')
          .doc(templateId)
          .get();

      // Delete from Firestore
      if (templateDoc.exists) {
        await _firestore.collection('templates').doc(templateId).delete();
      }

      // Delete associated files from Firebase Storage
      // This will attempt to delete even if the document doesn't exist (cleanup orphaned files)
      await _deleteTemplateFiles(templateId);
    } catch (e) {
      throw FirebaseErrorHandler.handle(e);
    }
  }

  // Delete all files associated with a public template
  Future<void> _deleteTemplateFiles(String templateId) async {
    final FirebaseStorage storage = FirebaseStorage.instance;

    try {
      final basePath = 'public_templates/$templateId';
      final storageRef = storage.ref().child(basePath);

      // Delete entire folder recursively (includes thumbnails, backgrounds, template_images)
      final listResult = await storageRef.listAll();
      final deleteFutures = <Future>[];

      // Delete all files in subfolders (thumbnails, backgrounds, template_images)
      for (final prefix in listResult.prefixes) {
        deleteFutures.add(
          prefix.listAll().then((subResult) {
            return Future.wait(subResult.items.map((item) => item.delete()));
          }),
        );
      }

      // Delete all files in root
      deleteFutures.addAll(listResult.items.map((item) => item.delete()));

      await Future.wait(deleteFutures);
    } catch (e) {
      debugPrint('Error deleting template files: $e');
      // Don't throw here - we want to complete the template deletion even if file deletion fails
      // This ensures the Firestore document is deleted even if some storage files are missing
    }
  }

  // Update template (admin only)
  Future<void> updateTemplate(
    String templateId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _firestore.collection('templates').doc(templateId).update({
        ...updates,
        'updatedAt': DateTime.now().toIso8601String(),
      });
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

  // Get feedback count for a user (by userId or deviceId)
  // Uses a separate count document to avoid permission issues
  Future<int> getFeedbackCount({String? userId, String? deviceId}) async {
    try {
      String? countKey;
      if (userId != null) {
        countKey = 'user_$userId';
      } else if (deviceId != null) {
        countKey = 'device_$deviceId';
      } else {
        return 0;
      }

      // Try to get the count document
      final countDoc = await _firestore
          .collection('feedback_count')
          .doc(countKey)
          .get();

      if (countDoc.exists && countDoc.data() != null) {
        return countDoc.data()!['count'] as int? ?? 0;
      }
      return 0;
    } catch (e) {
      // If there's an error, return 0 to allow submission
      // This prevents blocking users if there's a permission issue
      debugPrint('Error getting feedback count: $e');
      return 0;
    }
  }

  // Save user feedback to Firestore
  // For anonymous users, deviceId is used as document ID
  Future<void> saveFeedback({
    required String feedback,
    String? userId,
    String? userEmail,
    String? deviceId,
  }) async {
    try {
      // Check feedback count (max 10)
      final feedbackCount = await getFeedbackCount(
        userId: userId,
        deviceId: deviceId,
      );

      if (feedbackCount >= 10) {
        throw Exception(
          'Maximum feedback limit reached. You can submit up to 10 feedbacks.',
        );
      }

      final feedbackData = {
        'feedback': feedback,
        'userId': userId,
        'userEmail': userEmail ?? 'anonymous',
        'deviceId': deviceId,
        'timestamp': FieldValue.serverTimestamp(),
        'appVersion': RemoteConfigService().config.update.currentVersion,
      };

      // Save feedback document
      String docId;
      if (deviceId != null && userId == null) {
        // For anonymous users, use deviceId_timestamp as document ID
        docId = '${deviceId}_${DateTime.now().millisecondsSinceEpoch}';
        await _firestore.collection('feedback').doc(docId).set(feedbackData);
      } else {
        // For authenticated users, use auto-generated ID
        final docRef = await _firestore
            .collection('feedback')
            .add(feedbackData);
        docId = docRef.id;
      }

      // Update feedback count
      String countKey;
      if (userId != null) {
        countKey = 'user_$userId';
      } else if (deviceId != null) {
        countKey = 'device_$deviceId';
      } else {
        return; // Should not happen, but safety check
      }

      // Increment count in feedback_count collection
      final countRef = _firestore.collection('feedback_count').doc(countKey);
      final countDoc = await countRef.get();

      if (countDoc.exists) {
        // Increment existing count
        await countRef.update({
          'count': FieldValue.increment(1),
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      } else {
        // Create new count document
        await countRef.set({
          'count': 1,
          'userId': userId,
          'deviceId': deviceId,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw FirebaseErrorHandler.handle(e);
    }
  }
}
