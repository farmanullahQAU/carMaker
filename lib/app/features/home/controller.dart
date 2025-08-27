import 'package:cardmaker/app/features/home/category_templates/view.dart';
import 'package:cardmaker/app/features/home/home.dart';
import 'package:cardmaker/app/routes/app_routes.dart';
import 'package:cardmaker/models/card_template.dart';
import 'package:cardmaker/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../editor/blank_canvas/view.dart';

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

  void onQuickActionTap(QuickAction action) {
    switch (action.title) {
      case 'From Photo':
        _handlePhotoAction();
        break;
      case 'AI Generate':
        _handleAIAction();
        break;
      case 'Blank Canvas':
        _handleBlankCanvasAction();
        break;
      case 'Templates':
        _handleTemplatesAction();
        break;
    }
  }

  // void onCategoryTap(CategoryModel category) {
  //   Get.toNamed('/category/${category.id}');
  // }
  void onCategoryTap(CategoryModel category) {
    // Navigate with proper arguments to avoid controller conflicts
    Get.to(
      () => CategoryTemplatesPage(category: category),
      preventDuplicates: true,
      arguments: category,
    );
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
      backgroundImage: '',
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

  void _handleBlankCanvasAction() {
    Get.to(() => CanvasSelectionPage());
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

extension MmToPx on num {
  double get mm => (this / 25.4) * 96;
}
// class HomeController extends GetxController {
//   // --- STATE ---
//   final selectedIndex = 0.obs;
//   final pageController = PageController();
//   final RxList<CardTemplate> templates =
//       <CardTemplate>[].obs; // Changed to RxList for reactivity
//   final isLoading = false.obs;

//   // --- MODERN QUICK ACTIONS ---
//   final List<QuickAction> quickActions = [
//     QuickAction(
//       title: 'From Photo',
//       icon: Icons.add_photo_alternate_outlined,
//       color: const Color(0xFF06B6D4),
//     ),
//     QuickAction(
//       title: 'AI Generate',
//       icon: Icons.auto_awesome_outlined,
//       color: const Color(0xFF8B5CF6),
//     ),
//     QuickAction(
//       title: 'Blank Canvas',
//       icon: Icons.edit_outlined,
//       color: const Color(0xFF3B82F6),
//     ),
//     QuickAction(
//       title: 'Templates',
//       icon: Icons.grid_view_outlined,
//       color: const Color(0xFF10B981),
//     ),
//   ];

//   // --- MODERN CATEGORIES ---
//   final List<CategoryModel> categories = [
//     CategoryModel(
//       id: 'birthday',
//       name: 'Birthday',
//       color: const Color(0xFFF59E0B),
//       icon: Icons.cake_outlined,
//       imagePath: 'assets/birthday_2.png',
//     ),
//     CategoryModel(
//       id: 'wedding',
//       name: 'Wedding',
//       color: const Color(0xFFEC4899),
//       icon: Icons.favorite_outline,
//       imagePath: 'assets/card1.png',
//     ),
//     CategoryModel(
//       id: 'business',
//       name: 'Business',
//       color: const Color(0xFF6366F1),
//       icon: Icons.business_outlined,
//       imagePath: 'assets/card1.png',
//     ),
//     CategoryModel(
//       id: 'anniversary',
//       name: 'Anniversary',
//       color: const Color(0xFF8B5CF6),
//       icon: Icons.celebration_outlined,
//       imagePath: 'assets/card1.png',
//     ),
//     CategoryModel(
//       id: 'invitation',
//       name: 'Invitation',
//       color: const Color(0xFF06B6D4),
//       icon: Icons.mail_outline,
//       imagePath: 'assets/card1.png',
//     ),
//     CategoryModel(
//       id: 'holiday',
//       name: 'Holiday',
//       color: const Color(0xFF10B981),
//       icon: Icons.card_giftcard_outlined,
//       imagePath: 'assets/card1.png',
//     ),
//   ];

//   // --- TRENDING TEMPLATES ---
//   final List<CategoryModel> trendingNow = [
//     CategoryModel(
//       id: 'birthday',
//       name: 'Birthday',
//       color: const Color(0xFFF59E0B),
//       icon: Icons.cake_outlined,
//       imagePath: 'assets/birthday_2.png',
//     ),
//     CategoryModel(
//       id: 'wedding',
//       name: 'Wedding',
//       color: const Color(0xFFEC4899),
//       icon: Icons.favorite_outline,
//       imagePath: 'assets/card1.png',
//     ),
//     CategoryModel(
//       id: 'business',
//       name: 'Business',
//       color: const Color(0xFF6366F1),
//       icon: Icons.business_outlined,
//       imagePath: 'assets/card1.png',
//     ),
//     CategoryModel(
//       id: 'anniversary',
//       name: 'Anniversary',
//       color: const Color(0xFF8B5CF6),
//       icon: Icons.celebration_outlined,
//       imagePath: 'assets/card1.png',
//     ),
//     CategoryModel(
//       id: 'invitation',
//       name: 'Invitation',
//       color: const Color(0xFF06B6D4),
//       icon: Icons.mail_outline,
//       imagePath: 'assets/card1.png',
//     ),
//     CategoryModel(
//       id: 'holiday',
//       name: 'Holiday',
//       color: const Color(0xFF10B981),
//       icon: Icons.card_giftcard_outlined,
//       imagePath: 'assets/card1.png',
//     ),
//   ];

//   // --- FEATURED TEMPLATES ---
//   final RxList<CardTemplate> featuredTemplates = RxList<CardTemplate>([]);

//   // --- LIFECYCLE ---
//   @override
//   void onInit() {
//     super.onInit();
//     _initializeData();
//   }

//   @override
//   void onClose() {
//     pageController.dispose();
//     super.onClose();
//   }

//   // --- NAVIGATION METHODS ---
//   void onPageChanged(int index) {
//     selectedIndex.value = index;
//   }

//   void onBottomNavTap(int index) {
//     if (selectedIndex.value == index) return;

//     selectedIndex.value = index;
//     pageController.animateToPage(
//       index,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOutCubic,
//     );
//   }

//   // --- DATA METHODS ---
//   Future<void> _initializeData() async {
//     isLoading.value = true;
//     try {
//       await _loadTemplates();
//     } catch (e) {
//       print('Error initializing data: $e');
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<void> _loadTemplates() async {
//     final storedTemplates = StorageService.loadTemplates();
//     if (storedTemplates.isNotEmpty) {
//       templates.assignAll(storedTemplates);
//     } else {
//       templates.assignAll(featuredTemplates);
//     }
//   }

//   // --- ACTION HANDLERS ---
//   void onQuickActionTap(QuickAction action) {
//     switch (action.title) {
//       case 'From Photo':
//         _handlePhotoAction();
//         break;
//       case 'AI Generate':
//         _handleAIAction();
//         break;
//       case 'Blank Canvas':
//         _handleBlankCanvasAction();
//         break;
//       case 'Templates':
//         _handleTemplatesAction();
//         break;
//     }
//   }

//   void onCategoryTap(CategoryModel category) {
//     Get.toNamed('/category/${category.id}');
//   }

//   void onTemplateTap(CardTemplate template) {
//     Get.toNamed(Routes.editor, arguments: template);
//   }

//   // --- PRIVATE ACTION HANDLERS ---
//   void _handlePhotoAction() {
//     Get.toNamed('/photo-import');
//   }

//   void _handleAIAction() {
//     Get.toNamed('/ai-generator');
//   }

//   void _handleBlankCanvasAction() {
//     //   Get.toNamed(Routes.editor, arguments: null);
//     Get.to(() => CanvasSelectionPage());
//   }

//   void _handleTemplatesAction() {
//     onBottomNavTap(1);
//   }

//   // --- SEARCH FUNCTIONALITY ---
//   void onSearchChanged(String query) {
//     if (query.isEmpty) {
//       templates.assignAll(
//         StorageService.loadTemplates().isNotEmpty
//             ? StorageService.loadTemplates()
//             : featuredTemplates,
//       );
//       return;
//     }

//     final filteredTemplates =
//         (StorageService.loadTemplates().isNotEmpty
//                 ? StorageService.loadTemplates()
//                 : featuredTemplates)
//             .where((template) {
//               return template.name.toLowerCase().contains(
//                     query.toLowerCase(),
//                   ) ||
//                   template.category.toLowerCase().contains(
//                     query.toLowerCase(),
//                   ) ||
//                   template.tags.any(
//                     (tag) => tag.toLowerCase().contains(query.toLowerCase()),
//                   );
//             })
//             .toList();

//     templates.assignAll(filteredTemplates);
//   }

//   // --- UTILITY METHODS ---
//   String getGreeting() {
//     final hour = DateTime.now().hour;
//     if (hour < 12) return 'Good morning';
//     if (hour < 17) return 'Good afternoon';
//     return 'Good evening';
//   }

//   void refreshData() async {
//     await _initializeData();
//   }

//   // --- Template Management ---
//   Future<void> addTemplate(CardTemplate template) async {
//     await StorageService.addTemplate(template);
//     await _loadTemplates();
//   }

//   Future<void> updateTemplate(CardTemplate template) async {
//     await StorageService.updateTemplate(template);
//     await _loadTemplates();
//   }

//   Future<void> deleteTemplate(String templateId) async {
//     await StorageService.deleteTemplate(templateId);
//     await _loadTemplates();
//   }
// }

// extension MmToPx on num {
//   /// Converts millimeters to Flutter logical pixels using standard 96 DPI (Figma default)
//   double get mm => (this / 25.4) * 96;
// }
