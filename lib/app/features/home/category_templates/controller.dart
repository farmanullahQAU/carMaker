import 'dart:async';

import 'package:cardmaker/app/features/home/controller.dart';
import 'package:cardmaker/app/routes/app_routes.dart';
import 'package:cardmaker/core/values/app_colors.dart';
import 'package:cardmaker/models/card_template.dart';
import 'package:cardmaker/services/auth_service.dart';
import 'package:cardmaker/services/firestore_service.dart';
import 'package:cardmaker/services/storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryTemplatesController extends GetxController {
  final _firestoreService = FirestoreServices();
  final AuthService authService = Get.find<AuthService>();

  final RxList<CardTemplate> templates = <CardTemplate>[].obs;
  final RxList<CardTemplate> _allTemplates = <CardTemplate>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSearchLoading = false.obs;
  final RxBool hasMoreData = true.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = ''.obs;
  final RxString selectedType = ''.obs;
  final RxList<String> availableCategories = <String>[].obs;
  final RxSet<String> favoriteTemplateIds = <String>{}.obs;
  final TextEditingController searchController = TextEditingController();

  late final ScrollController scrollController;
  static const int _pageSize = 10;
  DocumentSnapshot? _lastDocument;
  Timer? _searchDebounce;

  final RxBool showFreeOnly = false.obs;

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;

    scrollController = ScrollController();
    _setupScrollListener();
    searchController.addListener(_onSearchTextChanged);

    // Initialize from Get.arguments
    if (arguments is Map<String, dynamic>) {
      final category = arguments['category'];
      selectedCategory.value = category?.id ?? '';
      showFreeOnly.value = arguments['isFreeOnly'] as bool? ?? false;
    } else if (arguments is CategoryModel) {
      selectedCategory.value = arguments.id ?? '';
    } else if (arguments is bool) {
      selectedCategory.value = '';
      showFreeOnly.value = arguments;
    } else {
      selectedCategory.value = '';
      showFreeOnly.value = false; // Default when no arguments
    }

    _initializeAvailableCategories();
    _loadFavorites();
    if (authService.user != null) {
      syncLocalFavoritesWithFirebase();
    }
    loadTemplates();
  }

  Future<void> _loadFavorites() async {
    try {
      if (authService.user != null) {
        // Load from Firebase if user is logged in
        final favoriteIds = await _firestoreService.getFavoriteTemplateIds();
        favoriteTemplateIds.assignAll(favoriteIds);
      } else {
        // Load from local storage if user is logged out
        final localFavoriteIds = StorageService.loadFavoriteIds();
        favoriteTemplateIds.assignAll(localFavoriteIds.toSet());
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load favorites: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  Future<void> syncLocalFavoritesWithFirebase() async {
    if (authService.user == null) return;
    try {
      final localFavorites = StorageService.loadFavoriteIds();
      if (localFavorites.isNotEmpty) {
        for (var templateId in localFavorites) {
          if (!favoriteTemplateIds.contains(templateId)) {
            await _firestoreService.addToFavorites(templateId);
            favoriteTemplateIds.add(templateId);
          }
        }
        // Clear local favorites after syncing
        await StorageService.saveFavoriteIds([]);
      }
    } catch (e) {
      debugPrint('Error syncing local favorites with Firebase: $e');
    }
  }

  Future<void> loadTemplates({bool refresh = false}) async {
    if (isLoading.value && !refresh) return;

    isLoading.value = true;

    try {
      if (refresh) {
        templates.clear();
        _allTemplates.clear();
        _lastDocument = null;
        hasMoreData.value = true;
        await _loadFavorites();
        if (authService.user != null) {
          await syncLocalFavoritesWithFirebase();
        }
      }

      Query query = FirebaseFirestore.instance
          .collection('templates')
          .orderBy('createdAt', descending: true)
          .limit(_pageSize);

      if (selectedCategory.value.isNotEmpty) {
        query = query.where('categoryId', isEqualTo: selectedCategory.value);
      }

      if (showFreeOnly.value) {
        query = query.where('isPremium', isEqualTo: false);
      }

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        final newTemplates = snapshot.docs
            .map(
              (doc) => CardTemplate.fromJson(
                doc.data() as Map<String, dynamic>? ?? {},
              ),
            )
            .toList();

        templates.addAll(newTemplates);
        _allTemplates.addAll(newTemplates);
        _lastDocument = snapshot.docs.last;
        hasMoreData.value = snapshot.docs.length == _pageSize;

        if (searchQuery.value.isNotEmpty) {
          _applySearchFilter();
        }
      } else {
        hasMoreData.value = false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load templates: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _applySearchFilter() {
    if (searchQuery.value.isEmpty) {
      templates.assignAll(_allTemplates);
      return;
    }

    final searchLower = searchQuery.value.toLowerCase();
    final filtered = _allTemplates.where((template) {
      return template.name.toLowerCase().contains(searchLower) ||
          template.tags.any((tag) => tag.toLowerCase().contains(searchLower)) ||
          template.categoryId.toLowerCase().contains(searchLower);
    }).toList();

    templates.assignAll(filtered);
  }

  void _onSearchTextChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      searchQuery.value = searchController.text.trim();
      _applySearchFilter();
    });
  }

  Future<void> onSearchSubmitted(String query) async {
    searchQuery.value = query.trim();
    if (templates.isEmpty && searchQuery.value.isNotEmpty) {
      isSearchLoading.value = true;
      await loadTemplates(refresh: true);
      isSearchLoading.value = false;
    }
  }

  void toggleFreeFilter(bool value) {
    showFreeOnly.value = value;
    loadTemplates(refresh: true);
  }

  void onCategoryFilterChanged(String categoryId) {
    Get.back();
    selectedCategory.value = categoryId;
    loadTemplates(refresh: true);
  }

  void clearFilters() {
    selectedCategory.value = '';
    showFreeOnly.value = false;
    searchQuery.value = '';
    searchController.clear();
    loadTemplates(refresh: true);
  }

  Future<void> toggleFavorite(String templateId) async {
    try {
      if (authService.user != null) {
        // User is logged in, handle favorites with Firebase
        if (favoriteTemplateIds.contains(templateId)) {
          _firestoreService.removeFromFavorites(templateId);
          favoriteTemplateIds.remove(templateId);
        } else {
          _firestoreService.addToFavorites(templateId);
          favoriteTemplateIds.add(templateId);
        }
      } else {
        // User is logged out, handle favorites in local storage
        if (StorageService.isFavorite(templateId)) {
          await StorageService.removeFavoriteId(templateId);
          favoriteTemplateIds.remove(templateId);
        } else {
          await StorageService.addFavoriteId(templateId);
          favoriteTemplateIds.add(templateId);
        }
      }
      update(['favorite_$templateId']);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update favorites: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  bool isTemplateFavorite(String templateId) {
    return favoriteTemplateIds.contains(templateId);
  }

  void onTemplateSelected(CardTemplate template) {
    Get.toNamed(AppRoutes.editor, arguments: {'template': template});
  }

  Future<void> loadMoreTemplates() async {
    await loadTemplates();
  }

  Future<void> onRefresh() async {
    await loadTemplates(refresh: true);
  }

  String getCategoryName(String categoryId) {
    if (categoryId.isEmpty) return 'All Categories';

    final homeController = Get.find<HomeController>();
    final category = homeController.categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => CategoryModel(
        id: categoryId,
        name: categoryId.capitalizeFirst!,
        color: AppColors.branding,
        icon: Icons.category_outlined,
        imagePath: '',
      ),
    );

    return category.name;
  }

  Color getCategoryColor(String categoryId) {
    if (categoryId.isEmpty) return AppColors.branding;

    final homeController = Get.find<HomeController>();
    final category = homeController.categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => CategoryModel(
        id: categoryId,
        name: categoryId.capitalizeFirst!,
        color: AppColors.branding,
        icon: Icons.category_outlined,
        imagePath: '',
      ),
    );

    return category.color;
  }

  String getPageTitle() {
    return (showFreeOnly.value)
        ? 'Free Templates'
        : (selectedCategory.value.isEmpty)
        ? "All Templates"
        : selectedCategory.value;
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchController.removeListener(_onSearchTextChanged);
    searchController.dispose();
    _searchDebounce?.cancel();
    templates.clear();
    _allTemplates.clear();
    favoriteTemplateIds.clear();
    super.onClose();
  }

  void _setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent * 0.8) {
        if (!isLoading.value && hasMoreData.value) {
          loadMoreTemplates();
        }
      }
    });
  }

  void _initializeAvailableCategories() {
    final homeController = Get.find<HomeController>();
    final uniqueCategories = homeController.categories.map((c) => c.id).toSet();
    availableCategories.addAll(uniqueCategories);
  }
}

/*
class CategoryTemplatesController extends GetxController {
  final _firestoreService = FirestoreServices();
  final AuthService authService = Get.find<AuthService>();

  final RxList<CardTemplate> templates = <CardTemplate>[].obs;
  final RxList<CardTemplate> _allTemplates = <CardTemplate>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSearchLoading = false.obs;
  final RxBool hasMoreData = true.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = ''.obs;
  final RxString selectedType = ''.obs;
  final RxList<String> availableCategories = <String>[].obs;
  final RxSet<String> favoriteTemplateIds = <String>{}.obs;
  final TextEditingController searchController = TextEditingController();

  late final ScrollController scrollController;
  static const int _pageSize = 10;
  DocumentSnapshot? _lastDocument;
  Timer? _searchDebounce;

  final RxBool showFreeOnly = false.obs;

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;

    scrollController = ScrollController();
    _setupScrollListener();
    searchController.addListener(_onSearchTextChanged);

    // Initialize from Get.arguments
    if (arguments is Map<String, dynamic>) {
      final category = arguments['category'];
      selectedCategory.value = category?.id ?? '';
      showFreeOnly.value = arguments['isFreeOnly'] as bool? ?? false;
    } else if (arguments is CategoryModel) {
      selectedCategory.value = arguments.id ?? '';
    } else if (arguments is bool) {
      selectedCategory.value = '';
      showFreeOnly.value = arguments;
    } else {
      selectedCategory.value = '';
      showFreeOnly.value = false; // Default when no arguments
    }

    _initializeAvailableCategories();
    _loadFavorites();
    loadTemplates();
  }

  Future<void> loadTemplates({bool refresh = false}) async {
    if (isLoading.value && !refresh) return;

    isLoading.value = true;

    try {
      if (refresh) {
        templates.clear();
        _allTemplates.clear();
        _lastDocument = null;
        hasMoreData.value = true;
        await _loadFavorites();
      }

      Query query = FirebaseFirestore.instance
          .collection('templates')
          .orderBy('createdAt', descending: true)
          .limit(_pageSize);

      if (selectedCategory.value.isNotEmpty) {
        query = query.where('categoryId', isEqualTo: selectedCategory.value);
      }

      if (showFreeOnly.value) {
        query = query.where('isPremium', isEqualTo: false);
      }

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        final newTemplates = snapshot.docs
            .map(
              (doc) => CardTemplate.fromJson(
                doc.data() as Map<String, dynamic>? ?? {},
              ),
            )
            .toList();

        templates.addAll(newTemplates);
        _allTemplates.addAll(newTemplates);
        _lastDocument = snapshot.docs.last;
        hasMoreData.value = snapshot.docs.length == _pageSize;

        if (searchQuery.value.isNotEmpty) {
          _applySearchFilter();
        }
      } else {
        hasMoreData.value = false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load templates: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _applySearchFilter() {
    if (searchQuery.value.isEmpty) {
      templates.assignAll(_allTemplates);
      return;
    }

    final searchLower = searchQuery.value.toLowerCase();
    final filtered = _allTemplates.where((template) {
      return template.name.toLowerCase().contains(searchLower) ||
          template.tags.any((tag) => tag.toLowerCase().contains(searchLower)) ||
          template.categoryId.toLowerCase().contains(searchLower);
    }).toList();

    templates.assignAll(filtered);
  }

  void _onSearchTextChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      searchQuery.value = searchController.text.trim();
      _applySearchFilter();
    });
  }

  Future<void> onSearchSubmitted(String query) async {
    searchQuery.value = query.trim();
    if (templates.isEmpty && searchQuery.value.isNotEmpty) {
      isSearchLoading.value = true;
      await loadTemplates(refresh: true);
      isSearchLoading.value = false;
    }
  }

  void toggleFreeFilter(bool value) {
    showFreeOnly.value = value;
    loadTemplates(refresh: true);
  }

  void onCategoryFilterChanged(String categoryId) {
    Get.back();
    selectedCategory.value = categoryId;
    loadTemplates(refresh: true);
  }

  void clearFilters() {
    selectedCategory.value = '';
    showFreeOnly.value = false;
    searchQuery.value = '';
    searchController.clear();
    loadTemplates(refresh: true);
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchController.removeListener(_onSearchTextChanged);
    searchController.dispose();
    _searchDebounce?.cancel();
    templates.clear();
    _allTemplates.clear();
    favoriteTemplateIds.clear();
    super.onClose();
  }

  void _setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent * 0.8) {
        if (!isLoading.value && hasMoreData.value) {
          loadMoreTemplates();
        }
      }
    });
  }

  void _initializeAvailableCategories() {
    final homeController = Get.find<HomeController>();
    final uniqueCategories = homeController.categories.map((c) => c.id).toSet();
    availableCategories.addAll(uniqueCategories);
  }

  Future<void> _loadFavorites() async {
    try {
      final favoriteIds = await _firestoreService.getFavoriteTemplateIds();
      favoriteTemplateIds.assignAll(favoriteIds);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load favorites: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  Future<void> loadMoreTemplates() async {
    await loadTemplates();
  }

  Future<void> toggleFavorite(String templateId) async {
    try {
      if (authService.user == null) {
        Get.toNamed(AppRoutes.auth);
        return;
      }

      final wasFavorite = favoriteTemplateIds.contains(templateId);

      if (wasFavorite) {
        await _firestoreService.removeFromFavorites(templateId);
        favoriteTemplateIds.remove(templateId);
      } else {
        await _firestoreService.addToFavorites(templateId);
        favoriteTemplateIds.add(templateId);
      }

      update(['favorite_$templateId']);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update favorites: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  bool isTemplateFavorite(String templateId) {
    return favoriteTemplateIds.contains(templateId);
  }

  void onTemplateSelected(CardTemplate template) {
    Get.toNamed(AppRoutes.editor, arguments: {'template': template});
  }

  Future<void> onRefresh() async {
    await loadTemplates(refresh: true);
  }

  String getCategoryName(String categoryId) {
    if (categoryId.isEmpty) return 'All Categories';

    final homeController = Get.find<HomeController>();
    final category = homeController.categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => CategoryModel(
        id: categoryId,
        name: categoryId.capitalizeFirst!,
        color: AppColors.branding,
        icon: Icons.category_outlined,
        imagePath: '',
      ),
    );

    return category.name;
  }

  Color getCategoryColor(String categoryId) {
    if (categoryId.isEmpty) return AppColors.branding;

    final homeController = Get.find<HomeController>();
    final category = homeController.categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => CategoryModel(
        id: categoryId,
        name: categoryId.capitalizeFirst!,
        color: AppColors.branding,
        icon: Icons.category_outlined,
        imagePath: '',
      ),
    );

    return category.color;
  }

  String getPageTitle() {
    return (showFreeOnly.value)
        ? 'Free Templates'
        : (selectedCategory.value.isEmpty)
        ? "All Templates"
        : selectedCategory.value;
  }
}
*/
