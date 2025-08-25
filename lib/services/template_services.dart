import 'dart:io';

import 'package:cardmaker/models/card_template.dart';
import 'package:cardmaker/services/firebase_storage_service.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/stack_board_item.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/stack_items.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'firestore_service.dart';

/// TemplateService coordinates Firestore and Storage operations for templates.
class TemplateService extends GetxService {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseStorageService _storageService = FirebaseStorageService();
  final RxBool _isUploading = false.obs;

  bool get isUploading => _isUploading.value;

  /// Adds a template with optional image files and uploads images from ImageItemContent.
  Future<void> addTemplate(
    CardTemplate template, {
    File? thumbnailFile,
    File? backgroundFile,
  }) async {
    if (_isUploading.value) {
      Get.snackbar('Info', 'Another upload is in progress');
      return;
    }

    _isUploading.value = true;

    try {
      // Create a copy of the template's items to modify
      final updatedItems = <Map<String, dynamic>>[];
      for (final itemJson in template.items) {
        final item = _deserializeItem(itemJson);
        if (item is StackImageItem && item.content?.filePath != null) {
          // Upload image to Firebase Storage
          final imageUrl = await _storageService.uploadImage(
            File(item.content!.filePath!),
            template.id,
            'template_images',
            fileName: '${item.id}.jpg', // Unique file name per item
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
      String? thumbnailUrl;
      if (thumbnailFile != null) {
        thumbnailUrl = await _storageService.uploadImage(
          thumbnailFile,
          template.id,
          'thumbnails',
          fileName: 'thumbnail.jpg',
        );
        templateData['thumbnailUrl'] = thumbnailUrl;
      }

      // Upload background if provided
      String? backgroundUrl;
      if (backgroundFile != null) {
        backgroundUrl = await _storageService.uploadImage(
          backgroundFile,
          template.id,
          'backgrounds',
          fileName: 'background.jpg',
        );
        templateData['backgroundImageUrl'] = backgroundUrl;
      }

      // Save template to Firestore
      await _firestoreService.addTemplate(template, templateData);

      Get.back(); // Close loading dialog
      Get.snackbar(
        'Success',
        'Template uploaded successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Error',
        'Failed to upload template: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red,
      );
      rethrow;
    } finally {
      _isUploading.value = false;
    }
  }

  /// Batch upload templates with progress tracking
  Future<void> uploadTemplatesInBatch(
    List<CardTemplate> templates, {
    ValueChanged<double>? onProgress,
  }) async {
    final total = templates.length;
    var completed = 0;

    for (final template in templates) {
      try {
        await addTemplate(template);
        completed++;
        if (onProgress != null) {
          onProgress(completed / total);
        }
        // Small delay to prevent overwhelming the server
        await Future.delayed(const Duration(milliseconds: 100));
      } catch (e) {
        // Log error but continue with next template
        debugPrint('Failed to upload template ${template.id}: $e');
      }
    }
  }

  /// Retrieves templates with optional filtering.
  Stream<List<CardTemplate>> getTemplates({
    String? category,
    List<String>? tags,
    int limit = 20,
  }) {
    return _firestoreService.getTemplates(
      category: category,
      tags: tags,
      limit: limit,
    );
  }

  /// Helper method to deserialize StackItem from JSON
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
