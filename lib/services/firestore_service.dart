import 'package:cardmaker/models/card_template.dart';
import 'package:cardmaker/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class FirestoreService {
  // 🔹 Private constructor
  FirestoreService._internal();

  // 🔹 The single instance
  static final FirestoreService _instance = FirestoreService._internal();

  // 🔹 Public accessor
  factory FirestoreService() => _instance;

  // 🔹 Firebase instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔹 Always fetch latest userId (don’t cache it at init, otherwise null before login)
  String? get userId => Get.find<AuthService>().user?.uid;

  // Add a template to Firestore
  Future<void> addTemplate(String id, Map<String, dynamic> templateData) async {
    if (userId == null) throw Exception('User not authenticated');
    await _firestore.collection('templates').doc(id).set(templateData);
  }

  // Get templates with pagination
  Future<QuerySnapshot<Map<String, dynamic>>> getTemplatesPaginated({
    String? category,
    List<String>? tags,
    int limit = 20,
    DocumentSnapshot? startAfterDocument,
  }) async {
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
  }

  // Get templates count
  Future<int> getTemplatesCount({String? category}) async {
    Query<Map<String, dynamic>> query = _firestore.collection('templates');
    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }
    final snapshot = await query.get();
    return snapshot.docs.length;
  }

  // Search templates with pagination
  Future<QuerySnapshot<Map<String, dynamic>>> searchTemplatesPaginated({
    required String searchTerm,
    String? category,
    int limit = 20,
    DocumentSnapshot? startAfterDocument,
  }) async {
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
  }

  // Add a template to favorites
  Future<void> addToFavorites(String templateId) async {
    if (userId == null) throw Exception('User not authenticated');

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
  }

  // Remove a template from favorites
  Future<void> removeFromFavorites(String templateId) async {
    if (userId == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(templateId)
        .delete();

    await _firestore.collection('templates').doc(templateId).update({
      'favoriteCount': FieldValue.increment(-1),
    });
  }

  // Get favorite template IDs
  Future<List<String>> getFavoriteTemplateIds() async {
    if (userId == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }

  // Get favorite template IDs with pagination
  Future<QuerySnapshot<Map<String, dynamic>>> getFavoriteTemplateIdsPaginated({
    int limit = 20,
    DocumentSnapshot? startAfterDocument,
  }) async {
    if (userId == null) throw Exception('User not authenticated');

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
  }

  // Get favorite templates with pagination
  Future<List<CardTemplate>> getFavoriteTemplates({
    int limit = 20,
    DocumentSnapshot? startAfterDocument,
  }) async {
    if (userId == null) return [];

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
        i + batchSize > templateIds.length ? templateIds.length : i + batchSize,
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
  }

  // Save a draft
  Future<void> saveDraft(String id, Map<String, dynamic> templateData) async {
    if (userId == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('drafts')
        .doc(id)
        .set(templateData);
  }

  // Get user's drafts with pagination
  Future<QuerySnapshot<Map<String, dynamic>>> getUserDraftsPaginated({
    int limit = 20,
    DocumentSnapshot? startAfterDocument,
  }) async {
    if (userId == null) throw Exception('User not authenticated');

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
  }

  // Delete a draft
  Future<void> deleteDraft(String draftId) async {
    if (userId == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('drafts')
        .doc(draftId)
        .delete();
  }

  // Get drafts count
  Future<int> getDraftsCount() async {
    if (userId == null) return 0;

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('drafts')
        .get();
    return snapshot.docs.length;
  }
}
