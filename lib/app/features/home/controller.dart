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

  final RxList<CardTemplate> templates = <CardTemplate>[].obs;
  final RxList<String> favoriteTemplateIds =
      <String>[].obs; // Cached favorite IDs
  final isLoading = false.obs;
  final AuthService authService = Get.find<AuthService>();
  final TemplateService templateService = Get.find<TemplateService>();

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

  Future<void> _initializeData() async {
    isLoading.value = true;
    try {
      await Future.wait([_loadTemplates(), _loadFavoriteTemplateIds()]);
    } catch (e) {
      print('Error initializing data: $e');
      Get.snackbar(
        'Error',
        'Failed to load data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadTemplates() async {
    final templatesList = await templateService.getTemplatesPaginated(
      limit: 10,
    );
    templates.assignAll(
      templatesList.docs
          .map((doc) => CardTemplate.fromJson(doc.data()))
          .toList(),
    );
  }

  Future<void> _loadFavoriteTemplateIds() async {
    final favorites = await templateService.getFavoriteTemplateIds();
    favoriteTemplateIds.assignAll(favorites);
  }

  Future<void> toggleFavorite(String templateId) async {
    try {
      if (authService.user == null) {
        Get.toNamed(Routes.auth);
        return;
      }

      if (favoriteTemplateIds.contains(templateId)) {
        await templateService.removeFromFavorites(templateId);
        favoriteTemplateIds.remove(templateId);
      } else {
        await templateService.addToFavorites(templateId);
        favoriteTemplateIds.add(templateId);
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
