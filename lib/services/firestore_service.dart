import 'package:cardmaker/models/card_template.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// FirestoreService handles template metadata operations in Firestore.
class FirestoreService {
  static const String _templatesCollection = 'templates';

  // Singleton instance
  static final FirestoreService _instance = FirestoreService._internal();

  // Private constructor
  FirestoreService._internal() {
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  // Factory constructor → always returns same instance
  factory FirestoreService() => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  /// Get templates with pagination support
  Future<QuerySnapshot<Map<String, dynamic>>> getTemplatesPaginated({
    String? category,
    List<String>? tags,
    int limit = 20,
    DocumentSnapshot? startAfterDocument,
  }) async {
    try {
      print("Fetching templates...of category $category");
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

      if (startAfterDocument != null) {
        query = query.startAfterDocument(startAfterDocument);
      }

      return await query.get();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch templates: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      rethrow;
    }
  }

  /// Search templates with pagination
  Future<QuerySnapshot<Map<String, dynamic>>> searchTemplatesPaginated({
    required String searchTerm,
    String? category,
    int limit = 20,
    DocumentSnapshot? startAfterDocument,
  }) async {
    try {
      // Note: This is a basic implementation. For better search,
      // consider using Algolia or implementing full-text search
      Query<Map<String, dynamic>> query = _firestore
          .collection(_templatesCollection)
          .orderBy('name')
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
      print('Error searching templates: $e');
      rethrow;
    }
  }

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

  /// Get templates count for a category
  Future<int> getTemplatesCount({String? category}) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(
        _templatesCollection,
      );

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting templates count: $e');
      return 0;
    }
  }
}
