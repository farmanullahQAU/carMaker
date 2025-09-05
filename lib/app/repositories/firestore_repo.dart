// import 'package:cardmaker/app/repositories/auth_repo.dart';
// import 'package:cardmaker/models/card_template.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// abstract class FirestoreRepository {
//   String? get userId;

//   Future<void> addTemplate(String id, Map<String, dynamic> templateData);

//   Future<QuerySnapshot<Map<String, dynamic>>> getTemplatesPaginated({
//     String? category,
//     List<String>? tags,
//     int limit = 20,
//     DocumentSnapshot? startAfterDocument,
//   });

//   Future<int> getTemplatesCount({String? category});

//   Future<QuerySnapshot<Map<String, dynamic>>> searchTemplatesPaginated({
//     required String searchTerm,
//     String? category,
//     int limit = 20,
//     DocumentSnapshot? startAfterDocument,
//   });

//   Future<void> addToFavorites(String templateId);
//   Future<void> removeFromFavorites(String templateId);
//   Future<List<String>> getFavoriteTemplateIds();

//   Future<QuerySnapshot<Map<String, dynamic>>> getFavoriteTemplateIdsPaginated({
//     int limit = 20,
//     DocumentSnapshot? startAfterDocument,
//   });

//   Future<List<CardTemplate>> getFavoriteTemplates({
//     int limit = 20,
//     DocumentSnapshot? startAfterDocument,
//   });

//   Future<void> saveDraft(String id, Map<String, dynamic> templateData);

//   Future<QuerySnapshot<Map<String, dynamic>>> getUserDraftsPaginated({
//     int limit = 20,
//     DocumentSnapshot? startAfterDocument,
//   });

//   Future<void> deleteDraft(String draftId);
//   Future<int> getDraftsCount();

//   // Additional methods that might be useful
//   Future<DocumentSnapshot<Map<String, dynamic>>> getTemplate(String templateId);
//   Future<void> updateTemplate(String templateId, Map<String, dynamic> updates);
//   Future<void> deleteTemplate(String templateId);
//   Future<List<CardTemplate>> getTemplatesByIds(List<String> templateIds);
//   Future<int> getUserFavoritesCount();
//   Future<bool> isTemplateInFavorites(String templateId);
// }

// class FirestoreRepositoryImpl implements FirestoreRepository {
//   final FirebaseFirestore _firestore;
//   final AuthRepository _authRepository;

//   FirestoreRepositoryImpl({
//     FirebaseFirestore? firestore,
//     required AuthRepository authRepository,
//   }) : _firestore = firestore ?? FirebaseFirestore.instance,
//        _authRepository = authRepository;

//   @override
//   String? get userId => _authRepository.currentUser?.uid;

//   @override
//   Future<void> addTemplate(String id, Map<String, dynamic> templateData) async {
//     if (userId == null) throw Exception('User not authenticated');
//     await _firestore.collection('templates').doc(id).set(templateData);
//   }

//   @override
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

//   @override
//   Future<int> getTemplatesCount({String? category}) async {
//     Query<Map<String, dynamic>> query = _firestore.collection('templates');
//     if (category != null) {
//       query = query.where('category', isEqualTo: category);
//     }
//     final snapshot = await query.get();
//     return snapshot.docs.length;
//   }

//   @override
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

//   @override
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

//   @override
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

//   @override
//   Future<List<String>> getFavoriteTemplateIds() async {
//     if (userId == null) return [];

//     final snapshot = await _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('favorites')
//         .get();

//     return snapshot.docs.map((doc) => doc.id).toList();
//   }

//   @override
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

//   @override
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

//   @override
//   Future<void> saveDraft(String id, Map<String, dynamic> templateData) async {
//     if (userId == null) throw Exception('User not authenticated');

//     await _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('drafts')
//         .doc(id)
//         .set(templateData);
//   }

//   @override
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

//   @override
//   Future<void> deleteDraft(String draftId) async {
//     if (userId == null) throw Exception('User not authenticated');

//     await _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('drafts')
//         .doc(draftId)
//         .delete();
//   }

//   @override
//   Future<int> getDraftsCount() async {
//     if (userId == null) return 0;

//     final snapshot = await _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('drafts')
//         .get();
//     return snapshot.docs.length;
//   }

//   // Additional methods

//   @override
//   Future<DocumentSnapshot<Map<String, dynamic>>> getTemplate(
//     String templateId,
//   ) async {
//     return await _firestore.collection('templates').doc(templateId).get();
//   }

//   @override
//   Future<void> updateTemplate(
//     String templateId,
//     Map<String, dynamic> updates,
//   ) async {
//     await _firestore.collection('templates').doc(templateId).update(updates);
//   }

//   @override
//   Future<void> deleteTemplate(String templateId) async {
//     await _firestore.collection('templates').doc(templateId).delete();
//   }

//   @override
//   Future<List<CardTemplate>> getTemplatesByIds(List<String> templateIds) async {
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

//   @override
//   Future<int> getUserFavoritesCount() async {
//     if (userId == null) return 0;

//     final snapshot = await _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('favorites')
//         .get();

//     return snapshot.docs.length;
//   }

//   @override
//   Future<bool> isTemplateInFavorites(String templateId) async {
//     if (userId == null) return false;

//     final doc = await _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('favorites')
//         .doc(templateId)
//         .get();

//     return doc.exists;
//   }

//   // Utility method to get templates with specific ordering
//   Future<QuerySnapshot<Map<String, dynamic>>> getTemplatesOrdered({
//     String? category,
//     String orderBy = 'createdAt',
//     bool descending = true,
//     int limit = 20,
//     DocumentSnapshot? startAfterDocument,
//   }) async {
//     Query<Map<String, dynamic>> query = _firestore
//         .collection('templates')
//         .orderBy(orderBy, descending: descending)
//         .limit(limit);

//     if (category != null) {
//       query = query.where('category', isEqualTo: category);
//     }
//     if (startAfterDocument != null) {
//       query = query.startAfterDocument(startAfterDocument);
//     }

//     return await query.get();
//   }

//   // Get popular templates (most favorited)
//   Future<QuerySnapshot<Map<String, dynamic>>> getPopularTemplates({
//     String? category,
//     int limit = 20,
//     DocumentSnapshot? startAfterDocument,
//   }) async {
//     Query<Map<String, dynamic>> query = _firestore
//         .collection('templates')
//         .orderBy('favoriteCount', descending: true)
//         .limit(limit);

//     if (category != null) {
//       query = query.where('category', isEqualTo: category);
//     }
//     if (startAfterDocument != null) {
//       query = query.startAfterDocument(startAfterDocument);
//     }

//     return await query.get();
//   }

//   // Get user's templates (if they have created any)
//   Future<QuerySnapshot<Map<String, dynamic>>> getUserTemplatesPaginated({
//     int limit = 20,
//     DocumentSnapshot? startAfterDocument,
//   }) async {
//     if (userId == null) throw Exception('User not authenticated');

//     Query<Map<String, dynamic>> query = _firestore
//         .collection('templates')
//         .where('creatorId', isEqualTo: userId)
//         .orderBy('createdAt', descending: true)
//         .limit(limit);

//     if (startAfterDocument != null) {
//       query = query.startAfterDocument(startAfterDocument);
//     }

//     return await query.get();
//   }

//   // Get templates created by a specific user
//   Future<QuerySnapshot<Map<String, dynamic>>> getTemplatesByUserPaginated({
//     required String creatorId,
//     int limit = 20,
//     DocumentSnapshot? startAfterDocument,
//   }) async {
//     Query<Map<String, dynamic>> query = _firestore
//         .collection('templates')
//         .where('creatorId', isEqualTo: creatorId)
//         .orderBy('createdAt', descending: true)
//         .limit(limit);

//     if (startAfterDocument != null) {
//       query = query.startAfterDocument(startAfterDocument);
//     }

//     return await query.get();
//   }

//   // Get templates with multiple categories
//   Future<QuerySnapshot<Map<String, dynamic>>>
//   getTemplatesByCategoriesPaginated({
//     required List<String> categories,
//     int limit = 20,
//     DocumentSnapshot? startAfterDocument,
//   }) async {
//     Query<Map<String, dynamic>> query = _firestore
//         .collection('templates')
//         .where('category', whereIn: categories)
//         .limit(limit);

//     if (startAfterDocument != null) {
//       query = query.startAfterDocument(startAfterDocument);
//     }

//     return await query.get();
//   }

//   // Get templates with exact tag matching
//   Future<QuerySnapshot<Map<String, dynamic>>> getTemplatesByExactTagsPaginated({
//     required List<String> tags,
//     int limit = 20,
//     DocumentSnapshot? startAfterDocument,
//   }) async {
//     Query<Map<String, dynamic>> query = _firestore
//         .collection('templates')
//         .where('tags', arrayContainsAny: tags)
//         .limit(limit);

//     if (startAfterDocument != null) {
//       query = query.startAfterDocument(startAfterDocument);
//     }

//     return await query.get();
//   }

//   // Get recently viewed templates (if you implement view tracking)
//   Future<QuerySnapshot<Map<String, dynamic>>>
//   getRecentlyViewedTemplatesPaginated({
//     int limit = 20,
//     DocumentSnapshot? startAfterDocument,
//   }) async {
//     if (userId == null) throw Exception('User not authenticated');

//     Query<Map<String, dynamic>> query = _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('recentlyViewed')
//         .orderBy('viewedAt', descending: true)
//         .limit(limit);

//     if (startAfterDocument != null) {
//       query = query.startAfterDocument(startAfterDocument);
//     }

//     return await query.get();
//   }

//   // Increment template view count
//   Future<void> incrementTemplateViews(String templateId) async {
//     await _firestore.collection('templates').doc(templateId).update({
//       'viewCount': FieldValue.increment(1),
//     });
//   }

//   // Add template to recently viewed
//   Future<void> addToRecentlyViewed(String templateId) async {
//     if (userId == null) return;

//     await _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('recentlyViewed')
//         .doc(templateId)
//         .set({
//           'viewedAt': FieldValue.serverTimestamp(),
//           'templateRef': _firestore.collection('templates').doc(templateId),
//         });
//   }

//   // Clear recently viewed
//   Future<void> clearRecentlyViewed() async {
//     if (userId == null) return;

//     final snapshot = await _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('recentlyViewed')
//         .get();

//     final batch = _firestore.batch();
//     for (final doc in snapshot.docs) {
//       batch.delete(doc.reference);
//     }
//     await batch.commit();
//   }
// }
