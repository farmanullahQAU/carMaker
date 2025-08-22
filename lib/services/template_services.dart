import 'dart:io';

import 'package:cardmaker/models/card_template.dart';
import 'package:cardmaker/services/firebase_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'firestore_service.dart';

/// TemplateService coordinates Firestore and Storage operations for templates.
class TemplateService extends GetxService {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseStorageService _storageService = FirebaseStorageService();

  /// Adds a template with optional image files.
  Future<void> addTemplate(
    CardTemplate template, {
    File? thumbnailFile,
    File? backgroundFile,
  }) async {
    try {
      final templateData = template.toJson();

      // Upload thumbnail if provided
      if (thumbnailFile != null) {
        final thumbnailUrl = await _storageService.uploadImage(
          thumbnailFile,
          template.id,
          'thumbnails',
          fileName: 'thumbnail.jpg', //TODO
        );
        templateData['thumbnailUrl'] = thumbnailUrl;
      }

      // Upload background if provided
      if (backgroundFile != null) {
        final backgroundUrl = await _storageService.uploadImage(
          backgroundFile,
          template.id,
          'backgrounds',
          fileName: 'background.jpg', //TODO
        );
        templateData['backgroundImageUrl'] = backgroundUrl;
      }

      await _firestoreService.addTemplate(template, templateData);

      Get.snackbar(
        'bbbbbbbbbbbbbb',
        'Template uploaded successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to upload template: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      rethrow;
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
}
