import 'package:cardmaker/models/card_template.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// FirestoreService handles template metadata operations in Firestore.
class FirestoreService {
  static const String _templatesCollection = 'templates';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initializes FirestoreService with offline persistence.
  FirestoreService() {
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  /// Adds a template to Firestore with provided metadata.
  Future<void> addTemplate(
    CardTemplate template,
    Map<String, dynamic> templateData,
  ) async {
    try {
      templateData['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore
          .collection(_templatesCollection)
          .doc(template.id)
          .set(templateData, SetOptions(merge: true));

      Get.snackbar(
        'Success',
        'Template metadata uploaded successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to upload template metadata: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      rethrow;
    }
  }

  /// Retrieves a stream of templates with optional filtering and pagination.
  Stream<List<CardTemplate>> getTemplates({
    String? category,
    List<String>? tags,
    int limit = 20,
  }) {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(_templatesCollection)
          .orderBy('updatedAt', descending: true)
          .limit(limit);

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }
      if (tags != null && tags.isNotEmpty) {
        query = query.where('tags', arrayContainsAny: tags);
      }

      return query.snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => CardTemplate.fromJson(doc.data()))
            .toList(),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch templates: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return Stream.value([]);
    }
  }
}
