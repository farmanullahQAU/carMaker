import 'dart:convert';

import 'package:cardmaker/app/features/home/home.dart';
import 'package:cardmaker/app/routes/app_routes.dart';
import 'package:cardmaker/models/card_template.dart';
import 'package:cardmaker/services/auth_service.dart';
import 'package:cardmaker/services/firestore_service.dart';
import 'package:cardmaker/services/remote_config.dart';
import 'package:cardmaker/services/update_service.dart';
import 'package:cardmaker/widgets/common/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class HomeController extends GetxController {
  final selectedIndex = 0.obs;
  final RxList<CardTemplate> templates = <CardTemplate>[].obs;
  final RxList<CardTemplate> freeTodayTemplates = <CardTemplate>[].obs;
  final RxList<CardTemplate> trendingTemplates = <CardTemplate>[].obs;
  final RxList<String> favoriteTemplateIds = <String>[].obs;
  final isLoading = false.obs;
  final _storage = GetStorage();
  final authService = Get.put(AuthService());
  final _firestoreService = FirestoreServices();
  final RemoteConfigService remoteConfig = RemoteConfigService(); // Add this
  final UpdateManager updateManager = UpdateManager(); // Add this
  static const String _favoriteIdsKey = 'favorite_template_ids';
  // Add config values you want to use

  final List<QuickAction> quickActions = [
    QuickAction(
      title: 'From Photo',
      icon: Icons.add_photo_alternate_outlined,
      color: const Color(0xFF06B6D4),
    ),
    QuickAction(
      title: 'AI Generate',
      icon: Icons.auto_awesome_outlined,
      color: const Color(0xFF8B5CF6),
    ),
    QuickAction(
      title: 'Blank Canvas',
      icon: Icons.edit_outlined,
      color: const Color(0xFF3B82F6),
    ),
    QuickAction(
      title: 'Templates',
      icon: Icons.grid_view_outlined,
      color: const Color(0xFF10B981),
    ),
  ];

  final List<CategoryModel> categories = [
    CategoryModel(
      id: 'birthday',
      name: 'Birthday',
      color: const Color(0xFFF59E0B),
      icon: Icons.cake_outlined,
      imagePath: '',
    ),
    CategoryModel(
      id: 'wedding',
      name: 'Wedding',
      color: const Color(0xFFEC4899),
      icon: Icons.favorite_outline,
      imagePath: '',
    ),
    CategoryModel(
      id: 'business',
      name: 'Business',
      color: const Color(0xFF6366F1),
      icon: Icons.business_outlined,
      imagePath: '',
    ),
    CategoryModel(
      id: 'anniversary',
      name: 'Anniversary',
      color: const Color(0xFF8B5CF6),
      icon: Icons.celebration_outlined,
      imagePath: '',
    ),
    CategoryModel(
      id: 'invitation',
      name: 'Invitation',
      color: const Color(0xFF06B6D4),
      icon: Icons.mail_outline,
      imagePath: '',
    ),
    CategoryModel(
      id: 'holiday',
      name: 'Holiday',
      color: const Color(0xFF10B981),
      icon: Icons.card_giftcard_outlined,
      imagePath: '',
    ),
  ];

  final List<CategoryModel> trendingNow = [
    CategoryModel(
      id: 'birthday',
      name: 'Birthday',
      color: const Color(0xFFF59E0B),
      icon: Icons.cake_outlined,
      imagePath: 'assets/birthday_2.png',
    ),
    CategoryModel(
      id: 'wedding',
      name: 'Wedding',
      color: const Color(0xFFEC4899),
      icon: Icons.favorite_outline,
      imagePath: 'assets/card1.png',
    ),
    CategoryModel(
      id: 'business',
      name: 'Business',
      color: const Color(0xFF6366F1),
      icon: Icons.business_outlined,
      imagePath: 'assets/card1.png',
    ),
    CategoryModel(
      id: 'anniversary',
      name: 'Anniversary',
      color: const Color(0xFF8B5CF6),
      icon: Icons.celebration_outlined,
      imagePath: 'assets/card1.png',
    ),
    CategoryModel(
      id: 'invitation',
      name: 'Invitation',
      color: const Color(0xFF06B6D4),
      icon: Icons.mail_outline,
      imagePath: 'assets/card1.png',
    ),
    CategoryModel(
      id: 'holiday',
      name: 'Holiday',
      color: const Color(0xFF10B981),
      icon: Icons.card_giftcard_outlined,
      imagePath: 'assets/card1.png',
    ),
  ];

  final RxList<CardTemplate> featuredTemplates = RxList<CardTemplate>([]);

  final List<CanvasSize> canvasSizes = [
    CanvasSize(
      title: 'Portrait',
      width: 1080,
      height: 1920,
      icon: Icons.portrait,
      color: const Color(0xFF3B82F6),
      thumbnailUrl: 'assets/portrait_thumbnail.png',
    ),
    CanvasSize(
      title: 'Landscape',
      width: 1920,
      height: 1080,
      icon: Icons.landscape,
      color: const Color(0xFF10B981),
      thumbnailUrl: 'assets/landscape_thumbnail.png',
    ),
    CanvasSize(
      title: 'Square',
      width: 1080,
      height: 1080,
      icon: Icons.square,
      color: const Color(0xFFF59E0B),
      thumbnailUrl: 'assets/square_thumbnail.png',
    ),
  ];
  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  // Modify your HomeController's _initializeData method

  // Future<void> _initializeData() async {
  //   isLoading.value = true;
  //   try {
  //     await Future.wait([
  //       _loadTemplates(),
  //       _loadFreeTodayTemplates(),
  //       _loadTrendingTemplates(),
  //       _loadFavoriteTemplateIds(),
  //     ]);
  //     _checkForUpdates(); // Simple update check on init
  //   } catch (e) {
  //     print('Error initializing data: $e');
  //   } finally {
  //     isLoading.value = false;
  //     update(['freeTodayTemplates', 'trendingTemplates']);
  //   }
  // }
  Future<void> _initializeData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        _loadTemplates(),
        _loadFreeTodayTemplates(),
        _loadTrendingTemplates(),
        _loadFavoriteTemplateIds(),
      ]);
      // Sync local favorites with Firebase if user is logged in
      await syncLocalFavoritesWithFirebase();
      _checkForUpdates();
    } catch (e) {
      print('Error initializing data: $e');
    } finally {
      isLoading.value = false;
      update([
        'freeTodayTemplates',
        'trendingTemplates',
        'favoriteTemplateIds',
      ]);
    }
  }

  Future<void> _toggleLocalFavorite(String templateId) async {
    try {
      List<String> localFavorites = await _loadLocalFavoriteIds();
      if (localFavorites.contains(templateId)) {
        localFavorites.remove(templateId);
        favoriteTemplateIds.remove(templateId);
      } else {
        localFavorites.add(templateId);
        favoriteTemplateIds.add(templateId);
      }
      await _saveLocalFavoriteIds(localFavorites);
    } catch (e) {
      debugPrint('Error toggling local favorite: $e');
      rethrow;
    }
  }

  // Load favorite template IDs from local storage
  Future<List<String>> _loadLocalFavoriteIds() async {
    try {
      final jsonString = _storage.read(_favoriteIdsKey);
      if (jsonString == null || jsonString.isEmpty) return [];
      return List<String>.from(jsonDecode(jsonString));
    } catch (e) {
      debugPrint('Error loading local favorite IDs: $e');
      return [];
    }
  }

  // Save favorite template IDs to local storage
  Future<void> _saveLocalFavoriteIds(List<String> favoriteIds) async {
    try {
      await _storage.write(_favoriteIdsKey, jsonEncode(favoriteIds));
    } catch (e) {
      debugPrint('Error saving local favorite IDs: $e');
      rethrow;
    }
  }

  // Modified _loadFavoriteTemplateIds to include local storage
  Future<void> _loadFavoriteTemplateIds() async {
    try {
      if (authService.user != null) {
        // Load from Firebase if user is logged in
        final favorites = await _firestoreService.getFavoriteTemplateIds();
        favoriteTemplateIds.assignAll(favorites);
      } else {
        // Load from local storage if user is logged out
        final localFavorites = await _loadLocalFavoriteIds();
        favoriteTemplateIds.assignAll(localFavorites);
      }
    } catch (e) {
      debugPrint('Error loading favorite template IDs: $e');
    }
  }

  // Optional: Sync local favorites with Firebase when user logs in
  Future<void> syncLocalFavoritesWithFirebase() async {
    if (authService.user == null) return;
    try {
      final localFavorites = await _loadLocalFavoriteIds();
      if (localFavorites.isNotEmpty) {
        for (var templateId in localFavorites) {
          if (!favoriteTemplateIds.contains(templateId)) {
            await _firestoreService.addToFavorites(templateId);
            favoriteTemplateIds.add(templateId);
          }
        }
        // Clear local favorites after syncing
        await _saveLocalFavoriteIds([]);
      }
    } catch (e) {
      debugPrint('Error syncing local favorites with Firebase: $e');
    }
  }

  Future<void> _checkForUpdates() async {
    try {
      if (remoteConfig.config.update.isUpdateAvailable) {
        await updateManager.checkForUpdates(Get.context!);
      }
    } catch (e) {
      print('Update check failed: $e');
    }
  }

  Future<void> _loadTemplates() async {
    final templatesList = await _firestoreService.getTemplatesPaginated(
      limit: 10,
    );
    templates.assignAll(
      templatesList.docs
          .map((doc) => CardTemplate.fromJson(doc.data()))
          .toList(),
    );
    update(['templates']);
  }

  Future<void> _loadFreeTodayTemplates() async {
    try {
      final snapshot = await _firestoreService.getFreeTodayTemplatesPaginated(
        limit: 10,
      );
      freeTodayTemplates.assignAll(
        snapshot.docs.map((doc) => CardTemplate.fromJson(doc.data())).toList(),
      );
      update(['freeTodayTemplates']);
    } catch (e) {
      AppToast.error(message: e.toString());
    }
  }

  Future<void> _loadTrendingTemplates() async {
    try {
      final snapshot = await _firestoreService.getTrendingTemplatesPaginated(
        limit: 10,
      );
      trendingTemplates.assignAll(
        snapshot.docs.map((doc) => CardTemplate.fromJson(doc.data())).toList(),
      );
      update(['trendingTemplates']);
    } catch (e) {
      print('Error loading trending templates: $e');
      Get.snackbar(
        'Error',
        'Failed to load trending templates: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
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
        await _toggleLocalFavorite(templateId);
      }
      update(['favoriteTemplateIds']);
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
  // Future<void> toggleFavorite(String templateId) async {
  //   try {
  //     if (authService.user == null) {
  //       Get.toNamed(Routes.auth);
  //       return;
  //     }

  //     if (favoriteTemplateIds.contains(templateId)) {
  //       await _firestoreService.removeFromFavorites(templateId);
  //       favoriteTemplateIds.remove(templateId);
  //     } else {
  //       await _firestoreService.addToFavorites(templateId);
  //       favoriteTemplateIds.add(templateId);
  //     }
  //   } catch (e) {
  //     Get.snackbar(
  //       'Error',
  //       'Failed to update favorites: $e',
  //       snackPosition: SnackPosition.BOTTOM,
  //       backgroundColor: Colors.red.shade100,
  //       colorText: Colors.red.shade900,
  //     );
  //   }
  // }

  void onPageChanged(int index) {
    selectedIndex.value = index;
  }

  void onBottomNavTap(int index) {
    if (selectedIndex.value == index) return;

    selectedIndex.value = index;
  }

  void onCategoryTap(CategoryModel category) {
    Get.toNamed(
      Routes.categoryTemplates,
      preventDuplicates: true,
      arguments: category,
    );
  }

  void onTapViewAll(bool isFree) {
    Get.toNamed(Routes.categoryTemplates, arguments: isFree);
  }

  void onViewAllTemplates() {
    Get.toNamed(Routes.categoryTemplates, arguments: null);
  }

  void onTemplateTap(CardTemplate template) {
    Get.toNamed(
      Routes.editor,
      arguments: {"template": template, "showSaveCopyBtn": false},
    );
  }

  void _handlePhotoAction() {
    Get.toNamed('/photo-import');
  }

  void _handleAIAction() {
    Get.toNamed('/ai-generator');
  }

  void _handleTemplatesAction() {
    onBottomNavTap(1);
  }

  void onSearchChanged(String query) {
    if (query.isEmpty) {
      _loadTemplates();
      return;
    }

    final filteredTemplates = templates.where((template) {
      return template.name.toLowerCase().contains(query.toLowerCase()) ||
          template.category.toLowerCase().contains(query.toLowerCase()) ||
          template.tags.any(
            (tag) => tag.toLowerCase().contains(query.toLowerCase()),
          );
    }).toList();

    templates.assignAll(filteredTemplates);
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void refreshData() async {
    await _initializeData();
    await remoteConfig.refreshConfig();
  }
}
