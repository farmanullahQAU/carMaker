import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/card_template.dart';

class HomeController extends GetxController {
  // --- STATE ---
  final selectedIndex = 0.obs;
  final pageController = PageController();
  final templates = <CardTemplate>[].obs;
  final isLoading = false.obs;

  // --- MODERN QUICK ACTIONS ---
  final List<QuickAction> quickActions = [
    QuickAction(
      title: 'From Photo',
      icon: Icons.add_photo_alternate_outlined,
      color: const Color(0xFF06B6D4), // Modern cyan
    ),
    QuickAction(
      title: 'AI Generate',
      icon: Icons.auto_awesome_outlined,
      color: const Color(0xFF8B5CF6), // Modern purple
    ),
    QuickAction(
      title: 'Blank Canvas',
      icon: Icons.edit_outlined,
      color: const Color(0xFF3B82F6), // Modern blue
    ),
    QuickAction(
      title: 'Templates',
      icon: Icons.grid_view_outlined,
      color: const Color(0xFF10B981), // Modern green
    ),
  ];

  // --- MODERN CATEGORIES ---
  final List<CategoryModel> categories = [
    CategoryModel(
      imagePath: "assets/card1.png",

      id: 'birthday',
      name: 'Birthday',
      color: const Color(0xFFF59E0B), // Amber
      icon: Icons.cake_outlined,
    ),
    CategoryModel(
      imagePath: "assets/card1.png",

      id: 'wedding',
      name: 'Wedding',
      color: const Color(0xFFEC4899), // Pink
      icon: Icons.favorite_outline,
    ),
    CategoryModel(
      imagePath: "assets/card1.png",

      id: 'business',
      name: 'Business',
      color: const Color(0xFF6366F1), // Indigo
      icon: Icons.business_outlined,
    ),
    CategoryModel(
      imagePath: "assets/card1.png",

      id: 'anniversary',
      name: 'Anniversary',
      color: const Color(0xFF8B5CF6), // Purple
      icon: Icons.celebration_outlined,
    ),
    CategoryModel(
      imagePath: "assets/card1.png",
      id: 'invitation',
      name: 'Invitation',
      color: const Color(0xFF06B6D4), // Cyan
      icon: Icons.mail_outline,
    ),
    CategoryModel(
      imagePath: "assets/card1.png",

      id: 'holiday',
      name: 'Holiday',
      color: const Color(0xFF10B981), // Emerald
      icon: Icons.card_giftcard_outlined,
    ),
  ];

  // --- TRENDING TEMPLATES ---
  final List<CategoryModel> trendingNow = [
    CategoryModel(
      imagePath: "assets/card1.png",

      id: 'birthday',
      name: 'Birthday',
      color: const Color(0xFFF59E0B), // Amber
      icon: Icons.cake_outlined,
    ),
    CategoryModel(
      imagePath: "assets/card1.png",

      id: 'wedding',
      name: 'Wedding',
      color: const Color(0xFFEC4899), // Pink
      icon: Icons.favorite_outline,
    ),
    CategoryModel(
      imagePath: "assets/card1.png",

      id: 'business',
      name: 'Business',
      color: const Color(0xFF6366F1), // Indigo
      icon: Icons.business_outlined,
    ),
    CategoryModel(
      imagePath: "assets/card1.png",

      id: 'anniversary',
      name: 'Anniversary',
      color: const Color(0xFF8B5CF6), // Purple
      icon: Icons.celebration_outlined,
    ),
    CategoryModel(
      imagePath: "assets/card1.png",

      id: 'invitation',
      name: 'Invitation',
      color: const Color(0xFF06B6D4), // Cyan
      icon: Icons.mail_outline,
    ),
    CategoryModel(
      imagePath: "assets/card1.png",

      id: 'holiday',
      name: 'Holiday',
      color: const Color(0xFF10B981), // Emerald
      icon: Icons.card_giftcard_outlined,
    ),
  ];

  // --- MINIMALIST COLLECTION ---
  final List<CardTemplate> minimalistCollection = [
    CardTemplate(
      id: 'minimal_1',
      name: 'Clean Lines',
      backgroundImage: 'assets/card1.png',
      imagePath: 'assets/Farman.png',
      categoryId: 'minimalist',
      items: [],
    ),
    CardTemplate(
      id: 'minimal_2',
      name: 'Geometric Patterns',
      backgroundImage: 'assets/card1.png',
      imagePath: 'assets/Farman.png',
      categoryId: 'minimalist',
      items: [],
    ),
    CardTemplate(
      id: 'minimal_3',
      name: 'Monochrome Style',
      backgroundImage: 'assets/card1.png',
      imagePath: 'assets/Farman.png',
      categoryId: 'minimalist',
      items: [],
    ),
    CardTemplate(
      id: 'minimal_4',
      name: 'Typography Focus',
      backgroundImage: 'assets/card1.png',
      imagePath: 'assets/Farman.png',
      categoryId: 'minimalist',
      items: [],
    ),
  ];

  // --- LIFECYCLE ---
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

  // --- NAVIGATION METHODS ---
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

  // --- DATA METHODS ---
  Future<void> _initializeData() async {
    isLoading.value = true;
    try {
      await _loadTemplates();
      // Add any other initialization logic here
    } catch (e) {
      print('Error initializing data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? templatesJson = prefs.getString('templates');

      if (templatesJson != null) {
        final List<dynamic> templatesList = jsonDecode(templatesJson);
        final loadedTemplates = templatesList
            .map((json) => CardTemplate.fromJson(json))
            .toList();
        templates.assignAll(loadedTemplates);
      }
    } catch (e) {
      print('Error loading templates: $e');
    }
  }

  Future<void> saveTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final templatesJson = jsonEncode(
        templates.map((template) => template.toJson()).toList(),
      );
      await prefs.setString('templates', templatesJson);
    } catch (e) {
      print('Error saving templates: $e');
    }
  }

  // --- ACTION HANDLERS ---
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

  void onCategoryTap(CategoryModel category) {
    // Navigate to category-specific templates
    Get.toNamed('/category/${category.id}');
  }

  void onTemplateTap(CardTemplate template) {
    // Navigate to template editor
    Get.toNamed('/editor/${template.id}');
  }

  // --- PRIVATE ACTION HANDLERS ---
  void _handlePhotoAction() {
    // Handle photo import logic
    Get.toNamed('/photo-import');
  }

  void _handleAIAction() {
    // Handle AI generation logic
    Get.toNamed('/ai-generator');
  }

  void _handleBlankCanvasAction() {
    // Handle blank canvas creation
    Get.toNamed('/editor/new');
  }

  void _handleTemplatesAction() {
    // Switch to templates tab
    onBottomNavTap(1);
  }

  // --- SEARCH FUNCTIONALITY ---
  void onSearchChanged(String query) {
    // Implement search logic
    if (query.isEmpty) {
      // Reset to all templates
      return;
    }

    // Filter templates based on search query
    final filteredTemplates = templates.where((template) {
      return template.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    // Update UI with filtered results
    templates.assignAll(filteredTemplates);
  }

  // --- UTILITY METHODS ---
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void refreshData() async {
    await _initializeData();
  }
}

// --- ENHANCED DATA MODELS ---
class CategoryModel {
  final String id;
  final String name;
  final Color color;
  final IconData icon;
  String? imagePath;

  CategoryModel({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    required this.imagePath,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'color': color.value,
    'icon': icon.codePoint,
    'imagePath': imagePath,
  };

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    id: json['id'],
    name: json['name'],
    color: Color(json['color']),
    icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
    imagePath: json['imagePath'],
  );
}

class QuickAction {
  final String title;
  final IconData icon;
  final Color color;

  QuickAction({required this.title, required this.icon, required this.color});

  Map<String, dynamic> toJson() => {
    'title': title,
    'icon': icon.codePoint,
    'color': color.value,
  };

  factory QuickAction.fromJson(Map<String, dynamic> json) => QuickAction(
    title: json['title'],
    icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
    color: Color(json['color']),
  );
}
