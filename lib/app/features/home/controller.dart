import 'package:cardmaker/app/features/home/home.dart';
import 'package:cardmaker/app/routes/app_routes.dart';
import 'package:cardmaker/models/card_template.dart';
import 'package:cardmaker/services/auth_service.dart';
import 'package:cardmaker/services/storage_service.dart';
import 'package:cardmaker/services/template_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final selectedIndex = 0.obs;
  final pageController = PageController();
  final RxList<CardTemplate> templates = <CardTemplate>[].obs;
  final RxList<CardTemplate> featuredTemplates = <CardTemplate>[].obs;
  final RxList<String> favoriteTemplateIds = <String>[].obs;
  final isLoading = false.obs;

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

  // New Canvas Sizes
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

  late final TemplateService _templateService;
  late final AuthService _authService;

  @override
  void onInit() {
    super.onInit();
    _templateService = Get.find<TemplateService>();
    _authService = Get.find<AuthService>();
    _initializeData();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  Future<void> _initializeData() async {
    isLoading.value = true;
    try {
      await _loadTemplates();
      if (_authService.isUserAuthenticated()) {
        await _loadFavorites();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to initialize data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadTemplates() async {
    final storedTemplates = StorageService.loadTemplates();
    if (storedTemplates.isNotEmpty) {
      templates.assignAll(storedTemplates);
      featuredTemplates.assignAll(storedTemplates.take(10).toList());
    } else {
      final snapshot = await _templateService.getTemplatesPaginated(limit: 10);
      final fetchedTemplates = snapshot.docs
          .map((doc) => CardTemplate.fromJson(doc.data()))
          .toList();
      templates.assignAll(fetchedTemplates);
      featuredTemplates.assignAll(fetchedTemplates);
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final favoriteIds = await _templateService.getFavoriteTemplateIds();
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

  Future<void> toggleFavorite(CardTemplate template) async {
    if (!_authService.isUserAuthenticated()) {
      _authService.promptLogin();
      return;
    }

    try {
      if (favoriteTemplateIds.contains(template.id)) {
        await _templateService.removeFromFavorites(template.id);
        favoriteTemplateIds.remove(template.id);
        Get.snackbar(
          'Removed',
          'Template removed from favorites',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
        );
      } else {
        await _templateService.addToFavorites(template.id);
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

  void onPageChanged(int index) {
    selectedIndex.value = index;
  }

  void onBottomNavTap(int index) {
    if (selectedIndex.value == index) return;

    selectedIndex.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
  }

  void onCategoryTap(CategoryModel category) {
    Get.toNamed(
      Routes.categoryTemplates,
      preventDuplicates: true,
      arguments: category,
    );
  }

  void onViewAllTemplates() {
    Get.toNamed(Routes.categoryTemplates, arguments: null);
  }

  void onTemplateTap(CardTemplate template) {
    Get.toNamed(Routes.editor, arguments: template);
  }

  void onCanvasSizeTap(CanvasSize canvas) {
    final template = CardTemplate(
      id: 'blank_${canvas.title.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}',
      name: '${canvas.title} Canvas',
      thumbnailUrl: canvas.thumbnailUrl,
      backgroundImageUrl: '',
      items: [],
      createdAt: DateTime.now(),
      updatedAt: null,
      category: 'general',
      categoryId: 'general',
      compatibleDesigns: [],
      width: canvas.width,
      height: canvas.height,
      isPremium: false,
      tags: [canvas.title.toLowerCase(), 'blank'],
      imagePath: '',
    );
    Get.toNamed(Routes.editor, arguments: template);
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
      templates.assignAll(
        StorageService.loadTemplates().isNotEmpty
            ? StorageService.loadTemplates()
            : featuredTemplates,
      );
      return;
    }

    final filteredTemplates =
        (StorageService.loadTemplates().isNotEmpty
                ? StorageService.loadTemplates()
                : featuredTemplates)
            .where((template) {
      return template.name.toLowerCase().contains(
            query.toLowerCase(),
          ) ||
          template.category.toLowerCase().contains(
            query.toLowerCase(),
          ) ||
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
  }

  Future<void> addTemplate(CardTemplate template) async {
    await StorageService.addTemplate(template);
    await _loadTemplates();
  }

  Future<void> updateTemplate(CardTemplate template) async {
    await StorageService.updateTemplate(template);
    await _loadTemplates();
  }

  Future<void> deleteTemplate(String templateId) async {
    await StorageService.deleteTemplate(templateId);
    await _loadTemplates();
  }
}

extension MmToPx on num {
  double get mm => (this / 25.4) * 96;
}


/*
class HomeController extends GetxController {
  final selectedIndex = 0.obs;
  final pageController = PageController();
  final RxList<CardTemplate> templates = <CardTemplate>[].obs;
  final isLoading = false.obs;

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

  // New Canvas Sizes
  final List<CanvasSize> canvasSizes = [
    CanvasSize(
      title: 'Portrait',
      width: 1080,
      height: 1920,
      icon: Icons.portrait,
      color: const Color(0xFF3B82F6),
      thumbnailUrl: 'assets/portrait_thumbnail.png', // Optional: add asset
    ),
    CanvasSize(
      title: 'Landscape',
      width: 1920,
      height: 1080,
      icon: Icons.landscape,
      color: const Color(0xFF10B981),
      thumbnailUrl: 'assets/landscape_thumbnail.png', // Optional: add asset
    ),
    CanvasSize(
      title: 'Square',
      width: 1080,
      height: 1080,
      icon: Icons.square,
      color: const Color(0xFFF59E0B),
      thumbnailUrl: 'assets/square_thumbnail.png', // Optional: add asset
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void onPageChanged(int index) {
    selectedIndex.value = index;
  }

  void onBottomNavTap(int index) {
    if (selectedIndex.value == index) return;

    selectedIndex.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _initializeData() async {
    isLoading.value = true;
    try {
      await _loadTemplates();
    } catch (e) {
      print('Error initializing data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadTemplates() async {
    final storedTemplates = StorageService.loadTemplates();
    if (storedTemplates.isNotEmpty) {
      templates.assignAll(storedTemplates);
    } else {
      templates.assignAll(featuredTemplates);
    }
  }

  // void onCategoryTap(CategoryModel category) {
  //   Get.toNamed('/category/${category.id}');
  // }
  // For category navigation (from home page)
  void onCategoryTap(CategoryModel category) {
    Get.toNamed(
      Routes.categoryTemplates,
      preventDuplicates: true,
      arguments: category,
    );
  }

  // For "View All" navigation (show all templates)
  void onViewAllTemplates() {
    Get.toNamed(Routes.categoryTemplates, arguments: null);
  }

  void onTemplateTap(CardTemplate template) {
    Get.toNamed(Routes.editor, arguments: template);
  }

  // New Handler for Canvas Size Selection
  void onCanvasSizeTap(CanvasSize canvas) {
    final template = CardTemplate(
      id: 'blank_${canvas.title.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}',
      name: '${canvas.title} Canvas',
      thumbnailUrl: canvas.thumbnailUrl,
      backgroundImageUrl: '',
      items: [],
      createdAt: DateTime.now(),
      updatedAt: null,
      category: 'general',
      categoryId: 'general',
      compatibleDesigns: [],
      width: canvas.width,
      height: canvas.height,
      isPremium: false,
      tags: [canvas.title.toLowerCase(), 'blank'],
      imagePath: '',
    );
    Get.toNamed(Routes.editor, arguments: template);
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
      templates.assignAll(
        StorageService.loadTemplates().isNotEmpty
            ? StorageService.loadTemplates()
            : featuredTemplates,
      );
      return;
    }

    final filteredTemplates =
        (StorageService.loadTemplates().isNotEmpty
                ? StorageService.loadTemplates()
                : featuredTemplates)
            .where((template) {
              return template.name.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  template.category.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  template.tags.any(
                    (tag) => tag.toLowerCase().contains(query.toLowerCase()),
                  );
            })
            .toList();

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
  }

  Future<void> addTemplate(CardTemplate template) async {
    await StorageService.addTemplate(template);
    await _loadTemplates();
  }

  Future<void> updateTemplate(CardTemplate template) async {
    await StorageService.updateTemplate(template);
    await _loadTemplates();
  }

  Future<void> deleteTemplate(String templateId) async {
    await StorageService.deleteTemplate(templateId);
    await _loadTemplates();
  }
}
*/
