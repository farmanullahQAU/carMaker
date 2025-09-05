import 'dart:async';

import 'package:cardmaker/core/errors/firebase_error_handler.dart';
import 'package:cardmaker/models/card_template.dart';
import 'package:cardmaker/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  final _firestoreService = FirestoreService();

  // Drafts
  final RxList<CardTemplate> drafts = <CardTemplate>[].obs;
  final RxBool isDraftsLoading = false.obs;
  final RxBool hasDraftsError = false.obs;
  DocumentSnapshot? lastDraftDocument;
  final RxBool hasMoreDrafts = true.obs;

  // Favorites
  final RxList<CardTemplate> favorites = <CardTemplate>[].obs;
  final RxBool isFavoritesLoading = false.obs;
  final RxBool hasFavoritesError = false.obs;
  DocumentSnapshot? lastFavoriteDocument;
  final RxBool hasMoreFavorites = true.obs;

  // Draft count
  final RxInt draftsCount = 0.obs;

  final ScrollController draftsScrollController = ScrollController();
  // Removed favoritesScrollController as NotificationListener handles pagination

  static const int _pageSize = 2; // Kept as 2 per your preference

  Timer? _favoritesDebounceTimer;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      if (tabController.index == 1 && favorites.isEmpty) {
        loadFavorites();
      }
    });
    // Setup scroll listener for drafts only
    draftsScrollController.addListener(() {
      if (draftsScrollController.position.pixels >=
          draftsScrollController.position.maxScrollExtent - 100) {
        if (!isDraftsLoading.value && hasMoreDrafts.value) {
          loadMoreDrafts();
        }
      }
    });

    // Load initial data
    loadDraftsCount();
    loadDrafts();
    loadFavorites();
  }

  Future<void> loadDraftsCount() async {
    try {
      final count = await _firestoreService.getDraftsCount();
      draftsCount.value = count;
    } catch (e) {
      debugPrint('Error loading drafts count: $e');
    }
  }

  Future<void> loadDrafts() async {
    if (isDraftsLoading.value) return;

    isDraftsLoading.value = true;
    hasDraftsError.value = false;

    try {
      final snapshot = await _firestoreService.getUserDraftsPaginated(
        limit: _pageSize,
      );

      if (snapshot.docs.isNotEmpty) {
        drafts.value = snapshot.docs
            .map((doc) => CardTemplate.fromJson(doc.data()))
            .toList();
        lastDraftDocument = snapshot.docs.last;
        hasMoreDrafts.value = snapshot.docs.length == _pageSize;
      } else {
        drafts.clear();
        hasMoreDrafts.value = false;
      }
    } catch (e) {
      hasDraftsError.value = true;
      debugPrint('Error loading drafts: $e');
    } finally {
      isDraftsLoading.value = false;
    }
  }

  Future<void> loadMoreDrafts() async {
    if (isDraftsLoading.value || !hasMoreDrafts.value) return;

    isDraftsLoading.value = true;

    try {
      final snapshot = await _firestoreService.getUserDraftsPaginated(
        limit: _pageSize,
        startAfterDocument: lastDraftDocument,
      );

      if (snapshot.docs.isNotEmpty) {
        final newDrafts = snapshot.docs
            .map((doc) => CardTemplate.fromJson(doc.data()))
            .toList();
        drafts.addAll(newDrafts);
        lastDraftDocument = snapshot.docs.last;
        hasMoreDrafts.value = snapshot.docs.length == _pageSize;
      } else {
        hasMoreDrafts.value = false;
      }
    } catch (e) {
      debugPrint('Error loading more drafts: $e');
    } finally {
      isDraftsLoading.value = false;
    }
  }

  Future<void> loadFavorites() async {
    if (isFavoritesLoading.value) return;

    isFavoritesLoading.value = true;
    hasFavoritesError.value = false;

    try {
      final favoriteTemplates = await _firestoreService.getFavoriteTemplates(
        limit: _pageSize,
      );
      debugPrint(
        'Initial fetch: ${favoriteTemplates.length} favorite templates',
      );

      if (favoriteTemplates.isNotEmpty) {
        favorites.value = favoriteTemplates;
        final snapshot = await _firestoreService
            .getFavoriteTemplateIdsPaginated(limit: _pageSize);
        debugPrint('Initial fetch: ${snapshot.docs.length} favorite IDs');
        lastFavoriteDocument = snapshot.docs.isNotEmpty
            ? snapshot.docs.last
            : null;
        hasMoreFavorites.value = snapshot.docs.length == _pageSize;
      } else {
        favorites.clear();
        hasMoreFavorites.value = false;
      }
    } catch (e) {
      hasFavoritesError.value = true;
      debugPrint('Error loading favorites: $e');
      Get.snackbar(
        'Error',
        'Failed to load favorites. Please try again.',
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isFavoritesLoading.value = false;
    }
  }

  Future<void> loadMoreFavorites() async {
    if (isFavoritesLoading.value || !hasMoreFavorites.value) return;

    isFavoritesLoading.value = true;

    try {
      final favoriteTemplates = await _firestoreService.getFavoriteTemplates(
        limit: _pageSize,
        startAfterDocument: lastFavoriteDocument,
      );
      debugPrint('Fetched ${favoriteTemplates.length} more favorite templates');

      if (favoriteTemplates.isNotEmpty) {
        favorites.addAll(favoriteTemplates);
        final snapshot = await _firestoreService
            .getFavoriteTemplateIdsPaginated(
              limit: _pageSize,
              startAfterDocument: lastFavoriteDocument,
            );
        debugPrint('Fetched ${snapshot.docs.length} more favorite IDs');
        lastFavoriteDocument = snapshot.docs.isNotEmpty
            ? snapshot.docs.last
            : null;
        debugPrint('Updated lastFavoriteDocument: ${lastFavoriteDocument?.id}');
        hasMoreFavorites.value = snapshot.docs.length == _pageSize;
      } else {
        hasMoreFavorites.value = false;
        debugPrint('No more favorites to load');
      }
    } catch (e) {
      debugPrint('Error loading more favorites: $e');
      Get.snackbar(
        'Error',
        'Failed to load more favorites. Please try again.',
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isFavoritesLoading.value = false;
    }
  }

  Future<void> deleteDraft(String draftId) async {
    try {
      await _firestoreService.deleteDraft(draftId);
      drafts.removeWhere((draft) => draft.id == draftId);
      loadDraftsCount();
    } catch (e) {
      final error = FirebaseErrorHandler.handle(e);
    }
  }

  Future<void> removeFromFavorites(String templateId) async {
    try {
      await _firestoreService.removeFromFavorites(templateId);
      favorites.removeWhere((template) => template.id == templateId);
    } catch (e) {
      debugPrint('Error removing from favorites: $e');
    }
  }

  Future<void> refreshDrafts() async {
    if (isDraftsLoading.value) return Future.value();
    lastDraftDocument = null;
    hasMoreDrafts.value = true;
    await loadDrafts();
    await loadDraftsCount();
    Get.snackbar(
      'Drafts Refreshed',
      'Your drafts have been updated.',
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 2),
      backgroundColor: Colors.blue.shade600,
      colorText: Colors.white,
    );
  }

  Future<void> refreshFavorites() async {
    if (isFavoritesLoading.value) return Future.value();
    lastFavoriteDocument = null;
    hasMoreFavorites.value = true;
    await loadFavorites();
    Get.snackbar(
      'Favorites Refreshed',
      'Your favorites have been updated.',
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 2),
      backgroundColor: Colors.blue.shade600,
      colorText: Colors.white,
    );
  }

  @override
  void onClose() {
    tabController.dispose();
    draftsScrollController.dispose();
    _favoritesDebounceTimer?.cancel();
    super.onClose();
  }
}
