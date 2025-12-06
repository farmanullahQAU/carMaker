import 'dart:convert';

import 'package:cardmaker/app/features/home/home.dart';
import 'package:cardmaker/app/routes/app_routes.dart';
import 'package:cardmaker/core/values/app_colors.dart';
import 'package:cardmaker/models/card_template.dart';
import 'package:cardmaker/services/admob_service.dart';
import 'package:cardmaker/services/auth_service.dart';
import 'package:cardmaker/services/design_export_service.dart';
import 'package:cardmaker/services/firestore_service.dart';
import 'package:cardmaker/services/remote_config.dart';
import 'package:file_picker/file_picker.dart';
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
  final RxBool hasLoadedTemplates = false.obs;
  final RxBool hasLoadedFreeToday = false.obs;
  final RxBool hasLoadedTrending = false.obs;
  final _storage = GetStorage();
  final authService = Get.find<AuthService>();
  final _firestoreService = FirestoreServices();
  final RemoteConfigService remoteConfig = RemoteConfigService(); // Add this
  final designExportService = DesignExportService();
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
      id: 'business',
      name: 'Business',
      color: const Color(0xFF6366F1),
      icon: Icons.business_outlined,
      imagePath: '',
    ),
    CategoryModel(
      id: 'general',
      name: 'Common',
      color: AppColors.green400,
      icon: Icons.category_outlined,
      imagePath: '',
    ),
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
    CategoryModel(
      id: 'general',
      name: 'General',
      color: const Color(0xFF6B7280),
      icon: Icons.category_outlined,
      imagePath: 'assets/card1.png',
    ),
  ];

  final RxList<CardTemplate> featuredTemplates = RxList<CardTemplate>([]);

  // Cache flags to prevent unnecessary reloads
  bool _isDataInitialized = false;
  bool _isInitializing = false;

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
    // Only initialize if not already initialized
    if (!_isDataInitialized && !_isInitializing) {
      _initializeData();
    }
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
    // Prevent multiple simultaneous initializations
    if (_isInitializing || _isDataInitialized) return;

    _isInitializing = true;
    isLoading.value = false; // Don't show loading spinner initially

    try {
      // Load favorites first (fast, local)
      await _loadFavoriteTemplateIds();

      // Use serverAndCache: Returns cached data immediately, then fetches fresh data
      // This ensures users see cached data instantly AND get fresh templates
      await Future.wait([
        _loadTemplates(useCache: false),
        _loadFreeTodayTemplates(useCache: false),
        _loadTrendingTemplates(useCache: false),
      ]);

      // Sync local favorites with Firebase if user is logged in
      await syncLocalFavoritesWithFirebase();

      // Update UI with data (cached first, then fresh)
      update([
        'templates',
        'freeTodayTemplates',
        'trendingTemplates',
        'favoriteTemplateIds',
      ]);

      _isDataInitialized = true;
    } catch (e) {
      debugPrint('Error initializing data: $e');
      // If server fetch fails, try cache as fallback
      try {
        await Future.wait([
          _loadTemplates(useCache: true),
          _loadFreeTodayTemplates(useCache: true),
          _loadTrendingTemplates(useCache: true),
        ]);
        update(['templates', 'freeTodayTemplates', 'trendingTemplates']);
      } catch (cacheError) {
        debugPrint('Cache fallback also failed: $cacheError');
      }
    } finally {
      _isInitializing = false;
      isLoading.value = false;
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

  Future<void> _loadTemplates({bool useCache = false}) async {
    try {
      final templatesList = await _firestoreService.getTemplatesPaginated(
        limit: 10,
        useCache: useCache,
      );
      templates.assignAll(
        templatesList.docs
            .map((doc) => CardTemplate.fromJson(doc.data()))
            .toList(),
      );
      hasLoadedTemplates.value = true;
      update(['templates']);
    } catch (e) {
      debugPrint('Error loading templates: $e');
      // If cache fails, try server
      if (useCache) {
        await _loadTemplates(useCache: false);
      } else {
        await _loadTemplates(useCache: true);
      }
    }
  }

  Future<void> _loadFreeTodayTemplates({bool useCache = false}) async {
    try {
      final snapshot = await _firestoreService.getFreeTodayTemplatesPaginated(
        limit: 10,
        useCache: useCache,
      );
      freeTodayTemplates.assignAll(
        snapshot.docs.map((doc) => CardTemplate.fromJson(doc.data())).toList(),
      );
      hasLoadedFreeToday.value = true;
      update(['freeTodayTemplates']);
    } catch (e) {
      debugPrint('Error loading free today templates: $e');
      if (useCache) {
        hasLoadedFreeToday.value = true;
        update(['freeTodayTemplates']);
      } else {
        await _loadFreeTodayTemplates(useCache: true);
      }
    }
  }

  Future<void> _loadTrendingTemplates({bool useCache = false}) async {
    try {
      final snapshot = await _firestoreService.getTrendingTemplatesPaginated(
        limit: 20,
        useCache: useCache,
      );
      trendingTemplates.assignAll(
        snapshot.docs.map((doc) => CardTemplate.fromJson(doc.data())).toList(),
      );
      hasLoadedTrending.value = true;
      update(['trendingTemplates']);
    } catch (e) {
      debugPrint('Error loading trending templates: $e');
      if (useCache) {
        hasLoadedTrending.value = true;
        update(['trendingTemplates']);
      } else {
        await _loadTrendingTemplates(useCache: true);
      }
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
  //       Get.toNamed(AppRoutes.auth);
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
      AppRoutes.categoryTemplates,
      preventDuplicates: true,
      arguments: category,
    );
  }

  void onTapViewAll(bool isFree) {
    Get.toNamed(AppRoutes.categoryTemplates, arguments: isFree);
  }

  void onViewAllTemplates() {
    Get.toNamed(AppRoutes.categoryTemplates, arguments: null);
  }

  void onTemplateTap(CardTemplate template) {
    AdMobService().onTemplateViewed();

    Get.toNamed(
      AppRoutes.editor,
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
    // Force refresh by resetting the flag
    _isDataInitialized = false;
    await _initializeData();
    await remoteConfig.refreshConfig();
  }

  /// Import design from .artnie file
  Future<void> importDesign() async {
    try {
      // Use FileType.any since .artnie is not a standard extension
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;

        // Validate file extension
        final fileName = file.name.toLowerCase();
        if (!fileName.endsWith('.artnie')) {
          _showFriendlyError(
            'Invalid File Type',
            'Please select a .artnie file exported from Artnie. The selected file is not a valid design file.',
          );
          return;
        }

        // Try to get bytes first (preferred method)
        if (file.bytes != null) {
          final bytes = file.bytes!;
          try {
            final template = await designExportService.importDesignFromBytes(
              bytes,
            );

            if (template != null) {
              // Navigate to editor with imported template
              Get.toNamed(
                AppRoutes.editor,
                arguments: {'template': template, 'showSaveCopyBtn': false},
              );
            }
          } catch (e) {
            // Handle import exceptions with friendly messages
            _handleImportError(e);
          }
        } else if (file.path != null) {
          // Fallback: use file path (for platforms that don't support bytes)
          final filePath = file.path!;
          try {
            final template = await designExportService.importDesignFromArtnie(
              filePath,
            );

            if (template != null) {
              // Navigate to editor with imported template
              Get.toNamed(
                AppRoutes.editor,
                arguments: {'template': template, 'showSaveCopyBtn': false},
              );
            }
          } catch (e) {
            // Handle import exceptions with friendly messages
            _handleImportError(e);
          }
        } else {
          _showFriendlyError(
            'Unable to Read File',
            'We couldn\'t read the selected file. Please make sure the file is accessible and try again.',
          );
        }
      }
    } catch (e) {
      debugPrint('Import design error: $e');
      _handleImportError(e);
    }
  }

  void _handleImportError(dynamic error) {
    String title = 'Import Failed';
    String message =
        'An error occurred while importing the file. Please try again.';

    // Check if it's our custom import exception
    if (error.toString().contains('Invalid file type')) {
      title = 'Invalid File Type';
      message =
          'This file is not a valid .artnie design file. Please make sure you selected a file exported from Artnie.';
    } else if (error.toString().contains('Invalid file format') ||
        error.toString().contains('Corrupted file')) {
      title = 'Corrupted File';
      message =
          'The selected file appears to be corrupted or damaged. Please try exporting the design again or select a different file.';
    } else if (error.toString().contains('Unsupported file version')) {
      title = 'Unsupported Version';
      message =
          'This file was created with a different version of Artnie. Please update the app or use a file exported from the current version.';
    } else if (error.toString().contains('File not found')) {
      title = 'File Not Found';
      message =
          'The selected file could not be found. Please make sure the file exists and try again.';
    } else if (error.toString().contains('Invalid file content')) {
      title = 'Invalid File Content';
      message =
          'The file structure is invalid. This may not be a valid Artnie design file.';
    } else if (error is Exception) {
      // Use the exception message if it's already user-friendly
      final errorStr = error.toString();
      if (errorStr.isNotEmpty && !errorStr.contains('Exception:')) {
        message = errorStr;
      }
    }

    _showFriendlyError(title, message);
  }

  void _showFriendlyError(String title, String message) {
    final theme = Get.theme;
    Get.dialog(
      AlertDialog(
        backgroundColor:
            theme.dialogTheme.backgroundColor ?? theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: Colors.orange.shade700,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (Get.isDialogOpen == true) {
                Get.back();
              }
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'OK',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }
}
