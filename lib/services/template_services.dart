// import 'dart:io';

// import 'package:cardmaker/core/errors/firebase_error_handler.dart';
// import 'package:cardmaker/models/card_template.dart';
// import 'package:cardmaker/services/firebase_storage_service.dart';
// import 'package:cardmaker/widgets/common/stack_board/lib/stack_board_item.dart';
// import 'package:cardmaker/widgets/common/stack_board/lib/stack_items.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import 'firestore_service.dart';

// /// TemplateService coordinates Firestore and Storage operations for templates.
// class TemplateService extends GetxService {
//   final FirestoreService _firestoreService = FirestoreService();
//   final FirebaseStorageService _storageService = FirebaseStorageService();

//   final RxBool _isUploading = false.obs;

//   bool get isUploading => _isUploading.value;

//   /// Adds a template with optional image files and uploads images from ImageItemContent.
//   Future<void> addTemplate(
//     CardTemplate template, {
//     File? thumbnailFile,
//     File? backgroundFile,
//   }) async {
//     print("is draft. ..................... ${template.isDraft}");
//     if (_isUploading.value) {
//       Get.snackbar('Info', 'Another upload is in progress');
//       return;
//     }

//     _isUploading.value = true;

//     try {
//       // Create a copy of the template's items to modify
//       final updatedItems = <Map<String, dynamic>>[];
//       for (final itemJson in template.items) {
//         final item = _deserializeItem(itemJson);
//         if (item is StackImageItem && item.content?.filePath != null) {
//           // Always save as .webp
//           final imageUrl = await _storageService.uploadImage(
//             File(item.content!.filePath!),
//             template.id,
//             'template_images',
//             fileName: '${item.id}.webp',
//             isDraft: template.isDraft,
//           );

//           // Update ImageItemContent with the URL
//           final updatedContent = item.content!.copyWith(
//             filePath: null, // Clear local file path
//             url: imageUrl, // Set cloud URL
//           );

//           // Update the item with the new content
//           final updatedItem = item.copyWith(content: updatedContent);
//           updatedItems.add(updatedItem.toJson());
//         } else {
//           // Non-image item or image with URL/asset, keep as is
//           updatedItems.add(itemJson);
//         }
//       }

//       // Prepare template data with updated items
//       final templateData = template.toJson();
//       templateData['items'] = updatedItems;

//       // Upload thumbnail if provided
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

//       // Upload background if provided
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

//       // Save template to Firestore
//       if (template.isDraft) {
//         await _firestoreService.saveDraft(template.id, templateData);
//       } else {
//         await _firestoreService.addTemplate(template.id, templateData);
//       }

//       Get.back(); // Close loading dialog
//     } catch (e) {
//       // ✅ Use unified error handler
//       final failure = FirebaseErrorHandler.handle(e);

//       Get.snackbar(
//         'Upload Failed',
//         failure.message, // show user-friendly message
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red.shade100,
//         colorText: Colors.red,
//       );
//     } finally {
//       _isUploading.value = false;
//     }
//   }

//   /// Batch upload templates with progress tracking
//   Future<void> uploadTemplatesInBatch(
//     List<CardTemplate> templates, {
//     ValueChanged<double>? onProgress,
//   }) async {
//     final total = templates.length;
//     var completed = 0;

//     for (final template in templates) {
//       try {
//         await addTemplate(template);
//         completed++;
//         if (onProgress != null) {
//           onProgress(completed / total);
//         }
//         // Small delay to prevent overwhelming the server
//         await Future.delayed(const Duration(milliseconds: 100));
//       } catch (e) {
//         // ✅ Still log error, but could also use ErrorHandler here if needed
//         debugPrint('Failed to upload template ${template.id}: $e');
//       }
//     }
//   }

//   /// Get templates with pagination support for category pages
//   Future<QuerySnapshot<Map<String, dynamic>>> getTemplatesPaginated({
//     String? category,
//     List<String>? tags,
//     int limit = 20,
//     DocumentSnapshot? startAfterDocument,
//   }) async {
//     return await _firestoreService.getTemplatesPaginated(
//       category: category,
//       tags: tags,
//       limit: limit,
//       startAfterDocument: startAfterDocument,
//     );
//   }

//   /// Get templates count for a specific category
//   Future<int> getTemplatesCount({String? category}) async {
//     return await _firestoreService.getTemplatesCount(category: category);
//   }

//   /// Search templates with pagination
//   Future<QuerySnapshot<Map<String, dynamic>>> searchTemplatesPaginated({
//     required String searchTerm,
//     String? category,
//     int limit = 20,
//     DocumentSnapshot? startAfterDocument,
//   }) async {
//     return await _firestoreService.searchTemplatesPaginated(
//       searchTerm: searchTerm,
//       category: category,
//       limit: limit,
//       startAfterDocument: startAfterDocument,
//     );
//   }

//   /// Get templates by category with proper typing
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
//       debugPrint('Error fetching templates by category: $e');
//       return [];
//     }
//   }

//   /// Add a template to the user's favorites
//   Future<void> addToFavorites(String templateId) async {
//     try {
//       await _firestoreService.addToFavorites(templateId);
//     } catch (e) {
//       debugPrint('Error adding to favorites: $e');
//       rethrow;
//     }
//   }

//   /// Remove a template from the user's favorites
//   Future<void> removeFromFavorites(String templateId) async {
//     try {
//       await _firestoreService.removeFromFavorites(templateId);
//     } catch (e) {
//       debugPrint('Error removing from favorites: $e');
//       rethrow;
//     }
//   }

//   /// Get the list of favorite template IDs for the user
//   Future<List<String>> getFavoriteTemplateIds() async {
//     try {
//       return await _firestoreService.getFavoriteTemplateIds();
//     } catch (e) {
//       debugPrint('Error fetching favorite template IDs: $e');
//       return [];
//     }
//   }

//   /// Get favorite template IDs with pagination
//   Future<QuerySnapshot<Map<String, dynamic>>> getFavoriteTemplateIdsPaginated({
//     int limit = 20,
//     DocumentSnapshot? startAfterDocument,
//   }) async {
//     try {
//       return await _firestoreService.getFavoriteTemplateIdsPaginated(
//         limit: limit,
//         startAfterDocument: startAfterDocument,
//       );
//     } catch (e) {
//       debugPrint('Error fetching paginated favorite template IDs: $e');
//       rethrow;
//     }
//   }

//   /// Get favorite templates with pagination
//   Future<List<CardTemplate>> getFavoriteTemplates({
//     int limit = 20,
//     DocumentSnapshot? startAfterDocument,
//   }) async {
//     try {
//       return await _firestoreService.getFavoriteTemplates(
//         limit: limit,
//         startAfterDocument: startAfterDocument,
//       );
//     } catch (e) {
//       debugPrint('Error fetching favorite templates: $e');
//       return [];
//     }
//   }

//   /// Get user's drafts with pagination
//   Future<QuerySnapshot<Map<String, dynamic>>> getUserDraftsPaginated({
//     int limit = 20,
//     DocumentSnapshot? startAfterDocument,
//   }) async {
//     return await _firestoreService.getUserDraftsPaginated(
//       limit: limit,
//       startAfterDocument: startAfterDocument,
//     );
//   }

//   /// Get user's drafts as CardTemplate list
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
//       debugPrint('Error fetching user drafts: $e');
//       return [];
//     }
//   }

//   /// Delete a draft
//   Future<void> deleteDraft(String draftId) async {
//     try {
//       await _firestoreService.deleteDraft(draftId);

//       Get.snackbar(
//         'Draft Deleted',
//         'Draft has been deleted successfully',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.orange.shade100,
//         colorText: Colors.orange.shade900,
//       );
//     } catch (e) {
//       debugPrint('Error deleting draft: $e');
//       rethrow;
//     }
//   }

//   /// Get drafts count for dashboard
//   Future<int> getDraftsCount() async {
//     try {
//       return await _firestoreService.getDraftsCount();
//     } catch (e) {
//       debugPrint('Error getting drafts count: $e');
//       return 0;
//     }
//   }

//   /// Helper method to deserialize StackItem from JSON
//   StackItem _deserializeItem(Map<String, dynamic> itemJson) {
//     final type = itemJson['type'];
//     if (type == 'StackTextItem') {
//       return StackTextItem.fromJson(itemJson);
//     } else if (type == 'StackImageItem') {
//       return StackImageItem.fromJson(itemJson);
//     } else {
//       throw Exception('Unsupported item type: $type');
//     }
//   }
// }
