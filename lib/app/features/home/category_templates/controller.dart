// import 'dart:async';

// import 'package:cardmaker/app/features/home/controller.dart';
// import 'package:cardmaker/app/routes/app_routes.dart';
// import 'package:cardmaker/core/values/app_colors.dart';
// import 'package:cardmaker/models/card_template.dart';
// import 'package:cardmaker/services/template_services.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

import 'dart:async';

import 'package:cardmaker/app/features/home/controller.dart';
import 'package:cardmaker/app/routes/app_routes.dart';
import 'package:cardmaker/core/values/app_colors.dart';
import 'package:cardmaker/models/card_template.dart';
import 'package:cardmaker/services/auth_service.dart';
import 'package:cardmaker/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryTemplatesController extends GetxController {
  final _firestoreService = FirestoreService();

  final CategoryModel? category;
  final AuthService authService = Get.find<AuthService>();

  final RxList<CardTemplate> templates = <CardTemplate>[].obs;
  final RxList<CardTemplate> _allTemplates = <CardTemplate>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMoreData = true.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = ''.obs;
  final RxString selectedType = ''.obs; // Free, Premium, or empty for all
  final RxList<String> availableCategories = <String>[].obs;
  final RxList<String> favoriteTemplateIds = <String>[].obs;

  late final ScrollController scrollController;
  static const int _pageSize = 10;
  DocumentSnapshot? _lastDocument;
  Timer? _searchDebounce;

  CategoryTemplatesController([this.category]);

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    _setupScrollListener();

    // Initialize selected category
    selectedCategory.value = category?.id ?? '';
    _initializeAvailableCategories();
    _loadFavorites();
    loadTemplates();
  }

  @override
  void onClose() {
    scrollController.dispose();
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

  Future<void> loadTemplates({bool refresh = false}) async {
    if (isLoading.value && !refresh) return;

    isLoading.value = true;

    try {
      if (refresh) {
        templates.clear();
        _allTemplates.clear();
        _lastDocument = null;
        hasMoreData.value = true;
        await _loadFavorites(); // Refresh favorites on pull-to-refresh
      }

      final snapshot = await _firestoreService.getTemplatesPaginated(
        category: category?.id,
        limit: _pageSize,
        startAfterDocument: _lastDocument,
      );

      if (snapshot.docs.isNotEmpty) {
        final newTemplates = snapshot.docs
            .map((doc) => CardTemplate.fromJson(doc.data()))
            .toList();

        templates.addAll(newTemplates);
        _allTemplates.addAll(newTemplates);
        _lastDocument = snapshot.docs.last;
        hasMoreData.value = snapshot.docs.length == _pageSize;

        _applyFilters();
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

  Future<void> loadMoreTemplates() async {
    await loadTemplates();
  }

  void onCategoryFilterChanged(String categoryId) {
    selectedCategory.value = categoryId;
    _applyFilters();
  }

  void onTypeFilterChanged(String type) {
    selectedType.value = type;
    _applyFilters();
  }

  void clearFilters() {
    selectedCategory.value = '';
    selectedType.value = '';
    searchQuery.value = '';
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = _allTemplates.toList();

    // Apply category filter
    if (selectedCategory.value.isNotEmpty) {
      filtered = filtered.where((template) {
        return template.categoryId == selectedCategory.value;
      }).toList();
    }

    // Apply type filter
    if (selectedType.value.isNotEmpty) {
      filtered = filtered.where((template) {
        return selectedType.value == 'free'
            ? !template.isPremium
            : template.isPremium;
      }).toList();
    }

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      final searchLower = searchQuery.value.toLowerCase();
      filtered = filtered.where((template) {
        return template.name.toLowerCase().contains(searchLower) ||
            template.tags.any((tag) => tag.toLowerCase().contains(searchLower));
      }).toList();
    }

    templates.assignAll(filtered);
  }

  void onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      searchQuery.value = query;
      _applyFilters();
    });
  }

  Future<void> toggleFavorite(CardTemplate template) async {
    try {
      if (authService.user == null) {
        Get.toNamed(Routes.auth);
        return;
      }
      if (favoriteTemplateIds.contains(template.id)) {
        await _firestoreService.removeFromFavorites(template.id);
      } else {
        await _firestoreService.addToFavorites(template.id);
        favoriteTemplateIds.add(template.id);
        Get.snackbar(
          'Added',
          'Template added to favorites',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
        );
      }
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

  void onTemplateSelected(CardTemplate template) {
    Get.toNamed(Routes.editor, arguments: {'template': template});
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
    return category?.name ?? 'All Templates';
  }

  Color getPageColor() {
    return category?.color ?? AppColors.branding;
  }
}

// class CategoryTemplatesController extends GetxController {
//   final CategoryModel? category;
//   late final TemplateService _firestoreService;

//   final RxList<CardTemplate> templates = <CardTemplate>[].obs;
//   final RxList<CardTemplate> _allTemplates = <CardTemplate>[].obs;
//   final RxBool isLoading = false.obs;
//   final RxBool hasMoreData = true.obs;
//   final RxString searchQuery = ''.obs;
//   final RxString selectedCategory = ''.obs;
//   final RxString selectedType = ''.obs; // Free, Premium, or empty for all
//   final RxList<String> availableCategories = <String>[].obs;

//   late final ScrollController scrollController;
//   static const int _pageSize = 10;
//   DocumentSnapshot? _lastDocument;
//   Timer? _searchDebounce;

//   CategoryTemplatesController([this.category]);

//   @override
//   void onInit() {
//     super.onInit();
//     _firestoreService = Get.find<TemplateService>();
//     scrollController = ScrollController();
//     _setupScrollListener();

//     // Initialize selected category
//     selectedCategory.value = category?.id ?? '';
//     _initializeAvailableCategories();
//     loadTemplates();
//   }

//   @override
//   void onClose() {
//     scrollController.dispose();
//     _searchDebounce?.cancel();
//     templates.clear();
//     _allTemplates.clear();
//     super.onClose();
//   }

//   void _setupScrollListener() {
//     scrollController.addListener(() {
//       if (scrollController.position.pixels >=
//           scrollController.position.maxScrollExtent * 0.8) {
//         if (!isLoading.value && hasMoreData.value) {
//           loadMoreTemplates();
//         }
//       }
//     });
//   }

//   void _initializeAvailableCategories() {
//     final homeController = Get.find<HomeController>();
//     final uniqueCategories = homeController.categories.map((c) => c.id).toSet();
//     availableCategories.addAll(uniqueCategories);
//   }

//   Future<void> loadTemplates({bool refresh = false}) async {
//     if (isLoading.value && !refresh) return;

//     isLoading.value = true;

//     try {
//       if (refresh) {
//         templates.clear();
//         _allTemplates.clear();
//         _lastDocument = null;
//         hasMoreData.value = true;
//       }

//       final snapshot = await _firestoreService.getTemplatesPaginated(
//         category: category?.id,
//         limit: _pageSize,
//         startAfterDocument: _lastDocument,
//       );

//       if (snapshot.docs.isNotEmpty) {
//         final newTemplates = snapshot.docs
//             .map((doc) => CardTemplate.fromJson(doc.data()))
//             .toList();

//         templates.addAll(newTemplates);
//         _allTemplates.addAll(newTemplates);
//         _lastDocument = snapshot.docs.last;
//         hasMoreData.value = snapshot.docs.length == _pageSize;

//         _applyFilters();
//       } else {
//         hasMoreData.value = false;
//       }
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Failed to load templates: $e',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red.shade100,
//         colorText: Colors.red.shade900,
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<void> loadMoreTemplates() async {
//     await loadTemplates();
//   }

//   void onCategoryFilterChanged(String categoryId) {
//     selectedCategory.value = categoryId;
//     _applyFilters();
//   }

//   void onTypeFilterChanged(String type) {
//     selectedType.value = type;
//     _applyFilters();
//   }

//   void clearFilters() {
//     selectedCategory.value = '';
//     selectedType.value = '';
//     searchQuery.value = '';
//     _applyFilters();
//   }

//   void _applyFilters() {
//     var filtered = _allTemplates.toList();

//     // Apply category filter
//     if (selectedCategory.value.isNotEmpty) {
//       filtered = filtered.where((template) {
//         return template.categoryId == selectedCategory.value;
//       }).toList();
//     }

//     // Apply type filter
//     if (selectedType.value.isNotEmpty) {
//       filtered = filtered.where((template) {
//         return selectedType.value == 'free'
//             ? !template.isPremium
//             : template.isPremium;
//       }).toList();
//     }

//     // Apply search filter
//     if (searchQuery.value.isNotEmpty) {
//       final searchLower = searchQuery.value.toLowerCase();
//       filtered = filtered.where((template) {
//         return template.name.toLowerCase().contains(searchLower) ||
//             template.tags.any((tag) => tag.toLowerCase().contains(searchLower));
//       }).toList();
//     }

//     templates.assignAll(filtered);
//   }

//   void onSearchChanged(String query) {
//     _searchDebounce?.cancel();
//     _searchDebounce = Timer(const Duration(milliseconds: 300), () {
//       searchQuery.value = query;
//       _applyFilters();
//     });
//   }

//   void onTemplateSelected(CardTemplate template) {
//     Get.toNamed(Routes.editor, arguments: {'template': template});
//   }

//   Future<void> onRefresh() async {
//     await loadTemplates(refresh: true);
//   }

//   String getCategoryName(String categoryId) {
//     if (categoryId.isEmpty) return 'All Categories';

//     final homeController = Get.find<HomeController>();
//     final category = homeController.categories.firstWhere(
//       (c) => c.id == categoryId,
//       orElse: () => CategoryModel(
//         id: categoryId,
//         name: categoryId.capitalizeFirst!,
//         color: AppColors.branding,
//         icon: Icons.category_outlined,
//         imagePath: '',
//       ),
//     );

//     return category.name;
//   }

//   Color getCategoryColor(String categoryId) {
//     if (categoryId.isEmpty) return AppColors.branding;

//     final homeController = Get.find<HomeController>();
//     final category = homeController.categories.firstWhere(
//       (c) => c.id == categoryId,
//       orElse: () => CategoryModel(
//         id: categoryId,
//         name: categoryId.capitalizeFirst!,
//         color: AppColors.branding,
//         icon: Icons.category_outlined,
//         imagePath: '',
//       ),
//     );

//     return category.color;
//   }

//   String getPageTitle() {
//     return category?.name ?? 'All Templates';
//   }

//   Color getPageColor() {
//     return category?.color ?? AppColors.branding;
//   }
// }
