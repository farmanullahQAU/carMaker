// import 'dart:async';
// import 'dart:io';

// import 'package:cardmaker/models/card_template.dart';
// import 'package:cardmaker/services/firestore_service.dart';
// import 'package:cardmaker/services/storage_service.dart';
// import 'package:cardmaker/widgets/common/app_toast.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:screenshot/screenshot.dart';

// import '../../../services/auth_service.dart';
import 'dart:async';
import 'dart:io';

import 'package:cardmaker/models/card_template.dart';
import 'package:cardmaker/services/firestore_service.dart';
import 'package:cardmaker/services/storage_service.dart';
import 'package:cardmaker/widgets/common/app_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:screenshot/screenshot.dart';

import '../../../services/auth_service.dart';

class ProfileController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final authService = Get.find<AuthService>();
  late TabController tabController;
  final _firestoreService = FirestoreServices();
  final ScreenshotController screenshotController = ScreenshotController();

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
  final RxList<String> favoriteTemplateIds = <String>[].obs;

  // Draft count
  final RxInt draftsCount = 0.obs;
  final RxList<CardTemplate> localDrafts = <CardTemplate>[].obs;

  static const int _pageSize = 10;

  Timer? _favoritesDebounceTimer;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(_handleTabChange);

    // Initialize storage and load data
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await StorageService.init();
      await loadLocalDrafts();
      await loadDraftsCount();
      // Load initial tab data based on which tab is active
      if (tabController.index == 0) {
        await loadDrafts();
      } else {
        await loadFavorites();
      }
      // Sync local favorites with Firebase if user is logged in
      if (authService.user != null) {
        await syncLocalFavoritesWithFirebase();
      }
    } catch (e) {
      debugPrint('Error initializing data: $e');
    }
  }

  void _handleTabChange() {
    if (!tabController.indexIsChanging) return;

    if (tabController.index == 1 && favorites.isEmpty) {
      loadFavorites();
    } else if (tabController.index == 0 && drafts.isEmpty) {
      loadDrafts();
    }
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
    if (isDraftsLoading.value || authService.user == null) return;

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

  Future<void> addToFavorites(String templateId) async {
    try {
      if (authService.user != null) {
        // Add to Firebase if logged in
        await _firestoreService.addToFavorites(templateId);
        favoriteTemplateIds.add(templateId);
        // Fetch the template to add to favorites list
        final template = await _firestoreService.getTemplateById(templateId);
        if (template != null) {
          favorites.add(template);
        }
      } else {
        // Add to local storage if logged out
        await StorageService.addFavoriteId(templateId);
        favoriteTemplateIds.add(templateId);
        // Fetch the template to add to favorites list
        final template = await _firestoreService.getTemplateById(templateId);
        if (template != null) {
          favorites.add(template);
        }
      }
      update(['favoriteTemplateIds']);
    } catch (e) {
      AppToast.error(message: e.toString());
    }
  }

  Future<void> loadMoreFavorites() async {
    if (isFavoritesLoading.value || !hasMoreFavorites.value) return;

    isFavoritesLoading.value = true;

    try {
      if (authService.user != null) {
        // Load more from Firebase
        final favoriteTemplates = await _firestoreService.getFavoriteTemplates(
          limit: _pageSize,
          startAfterDocument: lastFavoriteDocument,
        );
        debugPrint(
          'Fetched ${favoriteTemplates.length} more favorite templates',
        );

        if (favoriteTemplates.isNotEmpty) {
          favorites.addAll(favoriteTemplates);
          final snapshot = await _firestoreService
              .getFavoriteTemplateIdsPaginated(
                limit: _pageSize,
                startAfterDocument: lastFavoriteDocument,
              );
          debugPrint('Fetched ${snapshot.docs.length} more favorite IDs');
          favoriteTemplateIds.addAll(
            snapshot.docs.map((doc) => doc.id).toList(),
          );
          lastFavoriteDocument = snapshot.docs.isNotEmpty
              ? snapshot.docs.last
              : null;
          hasMoreFavorites.value = snapshot.docs.length == _pageSize;
        } else {
          hasMoreFavorites.value = false;
          debugPrint('No more favorites to load');
        }
      } else {
        // No more favorites to load from local storage
        hasMoreFavorites.value = false;
        debugPrint('No more local favorites to load');
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

  Future<void> backupDraft(CardTemplate template) async {
    try {
      if (authService.user == null) {
        AppToast.error(message: 'You must be logged in to back up drafts.');
        return;
      }

      AppToast.loading(message: 'Backing up draft...', showLogo: true);
      isDraftsLoading.value = true;

      // Upload to Firebase
      await saveDraft(template);

      // Remove from local storage after successful backup
      await StorageService.deleteDraft(template.id);

      // Update local state immediately
      localDrafts.removeWhere((draft) => draft.id == template.id);

      // Refresh all related data in sequence
      await loadDraftsCount();
      // await refreshDrafts(); // This will handle the drafts list refresh

      AppToast.success(message: 'Draft backed up successfully');
    } catch (e) {
      AppToast.error(message: 'Failed to backup draft: ${e.toString()}');
      // Revert local state if backup failed
      await loadLocalDrafts();
    } finally {
      isDraftsLoading.value = false;
    }
  }

  /// Save current design as draft to Firebase
  Future<void> saveDraft(CardTemplate template) async {
    try {
      template = template.copyWith(isDraft: true);
      File? backgroundFile;
      File? thumbnailFile;

      if (template.thumbnailUrl?.isNotEmpty ?? false) {
        if (await File(template.thumbnailUrl!).exists()) {
          thumbnailFile = File(template.thumbnailUrl!);
        }
      }

      if (template.backgroundImageUrl?.isNotEmpty ?? false) {
        if (!template.backgroundImageUrl!.startsWith('http')) {
          backgroundFile = File(template.backgroundImageUrl!);
        }
      }

      await _firestoreService.addTemplate(
        template,
        thumbnailFile: thumbnailFile,
        backgroundFile: backgroundFile,
      );
    } catch (err) {
      AppToast.error(message: err.toString());
      rethrow; // Important: rethrow to handle in backupDraft
    }
  }

  bool isBackedUp(CardTemplate template) {
    return drafts.any((draft) => draft.id == template.id);
  }

  Future<void> deleteDraft(String draftId) async {
    try {
      // Check if it's a Firebase draft
      final isFirebaseDraft = drafts.any((draft) => draft.id == draftId);

      if (isFirebaseDraft) {
        await _firestoreService.deleteDraft(draftId);
      }

      // Always delete from local storage
      await StorageService.deleteDraft(draftId);

      // Update all states
      drafts.removeWhere((draft) => draft.id == draftId);
      localDrafts.removeWhere((draft) => draft.id == draftId);

      await loadDraftsCount();
      await refreshDrafts();
    } catch (e) {
      AppToast.error(message: e.toString());
    }
  }

  bool isLocalDraft(String draftId) {
    return localDrafts.any((draft) => draft.id == draftId) &&
        !drafts.any((draft) => draft.id == draftId);
  }

  bool isLocalOnly(CardTemplate template) {
    return localDrafts.any((draft) => draft.id == template.id) &&
        !drafts.any((draft) => draft.id == template.id);
  }

  Future<void> removeFromFavorites(String templateId) async {
    try {
      if (authService.user != null) {
        // Remove from Firebase if logged in
        _firestoreService.removeFromFavorites(templateId);
        favorites.removeWhere((template) => template.id == templateId);
        favoriteTemplateIds.remove(templateId);
      } else {
        // Remove from local storage if logged out
        StorageService.removeFavoriteId(templateId);
        favorites.removeWhere((template) => template.id == templateId);
        favoriteTemplateIds.remove(templateId);
      }

      // If we're on the favorites tab, refresh the list
      if (tabController.index == 1) {
        await refreshFavorites();
      }
      update(['favoriteTemplateIds']);
    } catch (e) {
      AppToast.error(message: e.toString());
    }
  }

  Future<void> refreshDrafts() async {
    if (isDraftsLoading.value) return;

    // Reset pagination state
    lastDraftDocument = null;
    hasMoreDrafts.value = true;

    // Reload local drafts first
    await loadLocalDrafts();

    // Then reload Firebase drafts
    await loadDrafts();

    // Finally update the count
    await loadDraftsCount();
  }

  Future<void> refreshFavorites() async {
    if (isFavoritesLoading.value) return;

    // Reset pagination state
    lastFavoriteDocument = null;
    hasMoreFavorites.value = true;

    await loadFavorites();
  }

  // Combine all drafts (Firebase + Local)
  List<CardTemplate> get allDrafts {
    return [...drafts, ...localDrafts];
  }

  Future<void> loadFavorites() async {
    if (isFavoritesLoading.value) return;

    isFavoritesLoading.value = true;
    hasFavoritesError.value = false;

    try {
      if (authService.user != null) {
        // Load from Firebase if user is logged in
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
          favoriteTemplateIds.assignAll(
            snapshot.docs.map((doc) => doc.id).toList(),
          );
          lastFavoriteDocument = snapshot.docs.isNotEmpty
              ? snapshot.docs.last
              : null;
          hasMoreFavorites.value = snapshot.docs.length == _pageSize;
        } else {
          favorites.clear();
          favoriteTemplateIds.clear();
          hasMoreFavorites.value = false;
        }
      } else {
        // Load from local storage if user is logged out
        final localFavoriteIds = StorageService.loadFavoriteIds();
        favoriteTemplateIds.assignAll(localFavoriteIds);
        // Fetch favorite templates based on local IDs
        if (localFavoriteIds.isNotEmpty) {
          final favoriteTemplates = await _firestoreService.getTemplatesByIds(
            localFavoriteIds,
          );
          favorites.value = favoriteTemplates;
          hasMoreFavorites.value = false; // No pagination for local favorites
        } else {
          favorites.clear();
          hasMoreFavorites.value = false;
        }
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

  Future<void> loadLocalDrafts() async {
    try {
      final localTemplates = StorageService.loadDrafts();
      localDrafts.assignAll(localTemplates);
    } catch (e) {
      debugPrint('Error loading local drafts: $e');
    }
  }

  // Sync local favorites with Firebase when user logs in
  Future<void> syncLocalFavoritesWithFirebase() async {
    if (authService.user == null) return;
    try {
      final localFavorites = StorageService.loadFavoriteIds();
      if (localFavorites.isNotEmpty) {
        for (var templateId in localFavorites) {
          if (!favoriteTemplateIds.contains(templateId)) {
            await _firestoreService.addToFavorites(templateId);
            favoriteTemplateIds.add(templateId);
            // Fetch the template to add to favorites list
            final template = await _firestoreService.getTemplateById(
              templateId,
            );
            if (template != null) {
              favorites.add(template);
            }
          }
        }
        // Clear local favorites after syncing
        await StorageService.saveFavoriteIds([]);
      }
    } catch (e) {
      debugPrint('Error syncing local favorites with Firebase: $e');
    }
  }

  @override
  void onClose() {
    tabController.removeListener(_handleTabChange);
    tabController.dispose();
    _favoritesDebounceTimer?.cancel();
    super.onClose();
  }
}

/*
class ProfileController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final authService = Get.find<AuthService>();
  late TabController tabController;
  final _firestoreService = FirestoreServices();
  final ScreenshotController screenshotController = ScreenshotController();

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
  final RxList<CardTemplate> localDrafts = <CardTemplate>[].obs;

  static const int _pageSize = 10;

  Timer? _favoritesDebounceTimer;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(_handleTabChange);

    // Initialize storage and load data
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await StorageService.init();
      await loadLocalDrafts();
      await loadDraftsCount();
      // Load initial tab data based on which tab is active
      if (tabController.index == 0) {
        await loadDrafts();
      } else {
        await loadFavorites();
      }
    } catch (e) {
      debugPrint('Error initializing data: $e');
    }
  }

  void _handleTabChange() {
    if (!tabController.indexIsChanging) return;

    if (tabController.index == 1 && favorites.isEmpty) {
      loadFavorites();
    } else if (tabController.index == 0 && drafts.isEmpty) {
      loadDrafts();
    }
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
    if (isDraftsLoading.value || authService.user == null) return;

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

  Future<void> backupDraft(CardTemplate template) async {
    try {
      if (authService.user == null) {
        AppToast.error(message: 'You must be logged in to back up drafts.');
        return;
      }

      AppToast.loading(message: 'Backing up draft...', showLogo: true);
      isDraftsLoading.value = true;

      // Upload to Firebase
      await saveDraft(template);

      // Remove from local storage after successful backup
      await StorageService.deleteDraft(template.id);

      // Update local state immediately
      localDrafts.removeWhere((draft) => draft.id == template.id);

      // Refresh all related data in sequence
      await loadDraftsCount();
      // await refreshDrafts(); // This will handle the drafts list refresh

      AppToast.success(message: 'Draft backed up successfully');
    } catch (e) {
      AppToast.error(message: 'Failed to backup draft: ${e.toString()}');
      // Revert local state if backup failed
      await loadLocalDrafts();
    } finally {
      isDraftsLoading.value = false;
    }
  }

  /// Save current design as draft to Firebase
  Future<void> saveDraft(CardTemplate template) async {
    try {
      template = template.copyWith(isDraft: true);
      File? backgroundFile;
      File? thumbnailFile;

      if (template.thumbnailUrl?.isNotEmpty ?? false) {
        if (await File(template.thumbnailUrl!).exists()) {
          thumbnailFile = File(template.thumbnailUrl!);
        }
      }

      if (template.backgroundImageUrl?.isNotEmpty ?? false) {
        if (!template.backgroundImageUrl!.startsWith('http')) {
          backgroundFile = File(template.backgroundImageUrl!);
        }
      }

      await _firestoreService.addTemplate(
        template,
        thumbnailFile: thumbnailFile,
        backgroundFile: backgroundFile,
      );
    } catch (err) {
      AppToast.error(message: err.toString());
      rethrow; // Important: rethrow to handle in backupDraft
    }
  }

  bool isBackedUp(CardTemplate template) {
    return drafts.any((draft) => draft.id == template.id);
  }

  Future<void> deleteDraft(String draftId) async {
    try {
      // Check if it's a Firebase draft
      final isFirebaseDraft = drafts.any((draft) => draft.id == draftId);

      if (isFirebaseDraft) {
        await _firestoreService.deleteDraft(draftId);
      }

      // Always delete from local storage
      await StorageService.deleteDraft(draftId);

      // Update all states
      drafts.removeWhere((draft) => draft.id == draftId);
      localDrafts.removeWhere((draft) => draft.id == draftId);

      await loadDraftsCount();

      await refreshDrafts();
    } catch (e) {
      AppToast.error(message: e.toString());
    }
  }

  bool isLocalDraft(String draftId) {
    return localDrafts.any((draft) => draft.id == draftId) &&
        !drafts.any((draft) => draft.id == draftId);
  }

  bool isLocalOnly(CardTemplate template) {
    return localDrafts.any((draft) => draft.id == template.id) &&
        !drafts.any((draft) => draft.id == template.id);
  }

  Future<void> removeFromFavorites(String templateId) async {
    try {
      await _firestoreService.removeFromFavorites(templateId);
      favorites.removeWhere((template) => template.id == templateId);

      // If we're on the favorites tab, refresh the list
      if (tabController.index == 1) {
        await refreshFavorites();
      }
    } catch (e) {
      AppToast.error(message: e.toString());
    }
  }

  Future<void> refreshDrafts() async {
    if (isDraftsLoading.value) return;

    // Reset pagination state
    lastDraftDocument = null;
    hasMoreDrafts.value = true;

    // Reload local drafts first
    await loadLocalDrafts();

    // Then reload Firebase drafts
    await loadDrafts();

    // Finally update the count
    await loadDraftsCount();
  }

  Future<void> refreshFavorites() async {
    if (isFavoritesLoading.value) return;

    // Reset pagination state
    lastFavoriteDocument = null;
    hasMoreFavorites.value = true;

    await loadFavorites();
  }

  // Combine all drafts (Firebase + Local)
  List<CardTemplate> get allDrafts {
    return [...drafts, ...localDrafts];
  }

  Future<void> loadLocalDrafts() async {
    try {
      final localTemplates = StorageService.loadDrafts();
      localDrafts.assignAll(localTemplates);
    } catch (e) {
      debugPrint('Error loading local drafts: $e');
    }
  }

  @override
  void onClose() {
    tabController.removeListener(_handleTabChange);
    tabController.dispose();
    _favoritesDebounceTimer?.cancel();
    super.onClose();
  }
}
*/
