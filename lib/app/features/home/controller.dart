import 'dart:convert';

import 'package:cardmaker/app/features/home/home.dart';
import 'package:cardmaker/app/routes/app_routes.dart';
import 'package:cardmaker/core/values/app_constants.dart';
import 'package:cardmaker/models/card_template.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeController extends GetxController {
  static CardTemplate get stunningBirthdayTemplate => CardTemplate(
    id: 'birthday_card_20250721',
    name: 'Liam\'s Birthday Bash',
    thumbnailPath: null,
    backgroundImage: 'assets/card1.png', // Updated to a gradient background
    items: [
      // Main Image (Centered with slight offset)
      {
        'type': 'StackImageItem',
        'originalX': 620.0,
        'originalY': 524.0,
        'id': 'balloons_left',
        'status': 0,
        'size': {'width': 620.0, 'height': 620.0},
        'content': {'assetName': 'assets/Farman.png'},
        'isCentered': true,
        'originalRelativeOffset': {'dx': 0.08, 'dy': 0.11},
      },

      // Decorative Confetti (Right)
      {
        'type': 'StackTextItem',
        'status': 0,
        'originalX': 620.0,
        'originalY': 400.0,
        'size': {'width': 500.0, 'height': 100.0},
        'originalRelativeOffset': {'dx': 0.5, 'dy': 0.03},
        'isCentered': true,
        'content': {
          'data': 'YOU\'RE INVITED TO',
          'googleFont': 'Poppins', // Playful, handwritten font
          'style': {
            'fontSize': 18.0,
            'color': '#FF6F00', // Vibrant orange
            'fontWeight': FontWeight.bold,
            'shadows': [
              {
                'blurRadius': 4.0,
                'color': '#00000033', // Subtle shadow
                'offset': {'dx': 2.0, 'dy': 2.0},
              },
            ],
          },
        },
        'textAlign': 'center',
      },
      // Main Heading: "LIAM'S 8TH BIRTHDAY!"
      {
        'type': 'StackTextItem',
        'status': 0,
        'originalX': 620.0,
        'originalY': 600.0,
        'size': {'width': 1000.0, 'height': 120.0},
        'originalRelativeOffset': {'dx': 0.5, 'dy': 0.09},
        'isCentered': true,
        'content': {
          'data': 'Liam\'s 8th \n Birthday!',
          'googleFont':
              'Dancing Script', // Bold, modern sans-serif 'Dancing Script'
          'style': {
            'fontSize': 32.0,
            'color': '#D81B60', // Vibrant magenta
            'fontWeight': FontWeight.w800,

            'shadows': [
              {
                'blurRadius': 6.0,
                'color': '#0000004D', // Stronger shadow
                'offset': {'dx': 3.0, 'dy': 3.0},
              },
            ],
          },
        },
        'textAlign': 'center',
      },
      // Description: "Join us for cake, games, and fun!"
      {
        'type': 'StackTextItem',
        'status': 0,
        'originalX': 620.0,
        'originalY': 600.0,
        'size': {'width': 1000.0, 'height': 80.0},
        'originalRelativeOffset': {'dx': 0.5, 'dy': 0.34},
        'isCentered': true,
        'content': {
          'data': 'Join us for cake, games, and fun!',
          'googleFont': 'Montserrat', // Elegant sans-serif
          'style': {
            'fontSize': 22.0,
            'color': '#00897B', // Teal for contrast
            'fontWeight': FontWeight.w400,
          },
        },
        'textAlign': 'center',
      },
      // Date and Time
      {
        'type': 'StackTextItem',
        'status': 0,
        'originalX': 620.0,
        'originalY': 700.0,
        'size': {'width': 1000.0, 'height': 60.0},
        'originalRelativeOffset': {'dx': 0.5, 'dy': 0.40},
        'isCentered': true,
        'content': {
          'data': 'Saturday • August 31 • 2:00 PM',
          'googleFont': 'Poppins', // Clean and modern
          'style': {
            'fontSize': 20.0,
            'color': '#FBC02D', // Bright yellow
          },
        },
        'textAlign': 'center',
      },
      // Location
      {
        'type': 'StackTextItem',
        'status': 0,
        'originalX': 620.0,
        'originalY': 780.0,
        'size': {'width': 1000.0, 'height': 60.0},
        'originalRelativeOffset': {'dx': 0.5, 'dy': 0.45},
        'isCentered': true,
        'content': {
          'data': '123 Party Lane, Funville',
          'googleFont': 'Poppins',
          'style': {
            'fontSize': 18.0,
            'color': '#37474F', // Neutral dark gray
            'fontWeight': FontWeight.bold,
          },
        },
        'textAlign': 'center',
      },
      // RSVP
      {
        'type': 'StackTextItem',
        'status': 0,
        'originalX': 620.0,
        'originalY': 860.0,
        'size': {'width': 1000.0, 'height': 50.0},
        'originalRelativeOffset': {'dx': 0.5, 'dy': 0.49},
        'isCentered': true,
        'content': {
          'data': 'RSVP to Sarah by Aug 25',
          'googleFont': 'Raleway',
          'style': {
            'fontSize': 16.0,
            'color': '#455A64', // Soft slate
            'fontStyle': FontStyle.italic,
          },
        },
        'textAlign': 'center',
      },
    ],
    createdAt: DateTime.parse('2025-07-21T00:00:00Z'),
    updatedAt: null,
    category: 'birthday',
    categoryId: 'birthday',
    compatibleDesigns: [],
    width: 1240,
    height: 1748,
    isPremium: false,
    tags: ['birthday', 'kids', 'party', 'celebration', 'invite', 'festive'],
    imagePath: 'assets/card1.png',
  );

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

  // --- MODERN CATEGORIES ---
  final List<CategoryModel> categories = [
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

  // --- TRENDING TEMPLATES ---
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

  // --- FEATURED TEMPLATES ---
  final RxList<CardTemplate> featuredTemplates = RxList<CardTemplate>([
    CardTemplate(
      id: 'birthday_card_20250721',
      name: 'Liam\'s Birthday Bash',
      thumbnailPath: null,
      backgroundImage: 'assets/birthday_1.png',
      items: [
        {
          'type': 'StackImageItem',
          'originalX': 620.0,
          'originalY': 180.0,
          'id': 'birthday_image',
          'status': 0,
          'size': {'width': 400.0, 'height': 400.0},
          'content': {'assetName': 'assets/Farman.png'},
          'isCentered': true,
          'originalRelativeOffset': {'dx': 0.5, 'dy': 0.25},
        },
        {
          'type': 'StackTextItem',
          'status': 0,
          'originalX': 620.0,
          'originalY': 580.0,
          'size': {'width': 1040.0, 'height': 300.0},
          'originalRelativeOffset': {'dx': 0.5, 'dy': 0.05},
          'isCentered': true,
          'content': {
            'data': 'You\'re Invited to',
            'googleFont': 'Dancing Script',

            'style': {'fontSize': 18.0, 'color': '#F57C00'},
          },
          'textAlign': 'center',
        },
        {
          'type': 'StackTextItem',
          'status': 0,
          'originalX': 620.0,
          'originalY': 585.0,
          'size': {'width': 1040.0, 'height': 100.0},
          'originalRelativeOffset': {'dx': 0.5, 'dy': 0.12},
          'isCentered': true,
          'content': {
            'data': 'Liam\'s 8th \n Birthday!',
            'googleFont':
                'Dancing Script', // Bold, modern sans-serif 'Dancing Script'
            'style': {
              'fontSize': 30.0,
              'color': '#D32F2F',

              'letterSpacing': 7.8,
              'height': 1.0,
            },
          },
          'textAlign': TextAlign.center.name,
        },
        {
          'type': 'StackTextItem',
          'status': 0,
          'originalX': 620.0,
          'originalY': 590.0,
          'size': {'width': 1000.0, 'height': 30.0},
          'originalRelativeOffset': {'dx': 0.5, 'dy': 0.4},
          'isCentered': true,
          'content': {
            'data': 'Join us for cake, games, and fun!',
            'googleFont': 'Poppins',
            'style': {'fontSize': 20.0, 'color': '#F57C00'},
          },
          'textAlign': 'center',
        },
        {
          'type': 'StackTextItem',
          'status': 0,
          'originalX': 120.0,
          'originalY': 595.0,
          'size': {'width': 1000.0, 'height': 60.0},
          'originalRelativeOffset': {'dx': 0.5, 'dy': 0.45},
          'isCentered': true,
          'content': {
            'data': 'Saturday • August 31 • 2:00 PM',
            'googleFont': stylishGoogleFonts[4],
            'style': {'fontSize': 18.0, 'color': '#1E88E5'},
          },
          'textAlign': 'center',
        },
        {
          'type': 'StackTextItem',
          'status': 0,
          'originalX': 120.0,
          'originalY': 850.0,
          'size': {'width': 1000.0, 'height': 60.0},
          'originalRelativeOffset': {'dx': 0.5, 'dy': 0.52},
          'isCentered': true,
          'content': {
            'data': '123 Party Lane, Funville',
            'googleFont': 'Open Sans',
            'style': {'fontSize': 16.0, 'color': '#37474F'},
          },
          'textAlign': 'center',
        },
        {
          'type': 'StackTextItem',
          'status': 0,
          'originalX': 120.0,
          'originalY': 950.0,
          'size': {'width': 1000.0, 'height': 50.0},
          'originalRelativeOffset': {'dx': 0.5, 'dy': 0.6},
          'isCentered': true,
          'content': {
            'data': 'RSVP to Sarah by Aug 25',
            'googleFont': 'Roboto',
            'style': {'fontSize': 14.0, 'color': '#455A64'},
          },
          'textAlign': 'center',
        },
      ],
      createdAt: DateTime.parse('2025-07-21T00:00:00Z'),
      updatedAt: null,
      category: 'birthday',
      categoryId: 'birthday',
      compatibleDesigns: [],
      width: 1240,
      height: 1748,
      isPremium: false,
      tags: ['birthday', 'kids', 'party', 'celebration', 'invite'],
      imagePath: 'assets/birthday_1.png',
    ),
    stunningBirthdayTemplate,

    CardTemplate(
      id: 'wedding_invite_20250718',
      name: 'Elegant Wedding Invite',
      thumbnailPath: null,
      backgroundImage: 'assets/card1.png',
      items: [
        {
          'type': 'StackTextItem',
          'status': 0,
          'originalX': 620.0,
          'originalY': 150.0,
          'size': {'width': 1000.0, 'height': 120.0},
          'originalRelativeOffset': {'dx': 0.5, 'dy': 0.1},
          'isCentered': true,
          'content': {
            'data': 'Wedding Invitation',
            'googleFont': 'Great Vibes',
            'style': {'fontSize': 32.0, 'color': '#C2185B'},
          },
          'textAlign': 'center',
        },
        {
          'type': 'StackTextItem',
          'status': 0,
          'originalX': 620.0,
          'originalY': 300.0,
          'size': {'width': 1000.0, 'height': 100.0},
          'originalRelativeOffset': {'dx': 0.5, 'dy': 0.2},
          'isCentered': true,
          'content': {
            'data': 'Ali & Zara',
            'googleFont': 'Dancing Script',
            'style': {'fontSize': 40.0, 'color': '#880E4F'},
          },
          'textAlign': 'center',
        },
        {
          'type': 'StackTextItem',
          'status': 0,
          'originalX': 620.0,
          'originalY': 430.0,
          'size': {'width': 1000.0, 'height': 60.0},
          'originalRelativeOffset': {'dx': 0.5, 'dy': 0.3},
          'isCentered': true,
          'content': {
            'data': 'are getting married',
            'googleFont': 'Open Sans',
            'style': {'fontSize': 20.0, 'color': '#6A1B9A'},
          },
          'textAlign': 'center',
        },
        {
          'type': 'StackTextItem',
          'status': 0,
          'originalX': 620.0,
          'originalY': 550.0,
          'size': {'width': 1000.0, 'height': 80.0},
          'originalRelativeOffset': {'dx': 0.5, 'dy': 0.4},
          'isCentered': true,
          'content': {
            'data': 'Saturday, August 24, 2025',
            'googleFont': 'Montserrat',
            'style': {'fontSize': 22.0, 'color': '#4A148C'},
          },
          'textAlign': 'center',
        },
        {
          'type': 'StackTextItem',
          'status': 0,
          'originalX': 620.0,
          'originalY': 650.0,
          'size': {'width': 1000.0, 'height': 60.0},
          'originalRelativeOffset': {'dx': 0.5, 'dy': 0.5},
          'isCentered': true,
          'content': {
            'data': 'Lahore Royal Gardens, Phase 5',
            'googleFont': 'Roboto',
            'style': {'fontSize': 18.0, 'color': '#311B92'},
          },
          'textAlign': 'center',
        },
        {
          'type': 'StackTextItem',
          'status': 0,
          'originalX': 620.0,
          'originalY': 850.0,
          'size': {'width': 1000.0, 'height': 60.0},
          'originalRelativeOffset': {'dx': 0.5, 'dy': 0.65},
          'isCentered': true,
          'content': {
            'data': 'RSVP by August 10',
            'googleFont': 'Roboto',
            'style': {'fontSize': 18.0, 'color': '#1A237E'},
          },
          'textAlign': 'center',
        },
      ],
      createdAt: DateTime.parse('2025-07-18T00:00:00Z'),
      updatedAt: null,
      category: 'wedding',
      categoryId: 'wedding',
      compatibleDesigns: [],
      width: 1240,
      height: 1748,
      isPremium: true,
      tags: ['wedding', 'love', 'romance', 'marriage'],
      imagePath: 'assets/card1.png',
    ),
  ]);

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

      if (templatesJson != null && templatesJson.isNotEmpty) {
        final List<dynamic> templatesList = jsonDecode(templatesJson);
        final loadedTemplates = templatesList
            .map((json) => CardTemplate.fromJson(json))
            .toList();
        templates.assignAll(loadedTemplates);
      } else {
        templates.assignAll(featuredTemplates);
      }
    } catch (e) {
      print('Error loading templates: $e');
      templates.assignAll(featuredTemplates);
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
    Get.toNamed('/category/${category.id}');
  }

  void onTemplateTap(CardTemplate template) {
    Get.toNamed(Routes.editor, arguments: template);
  }

  // --- PRIVATE ACTION HANDLERS ---
  void _handlePhotoAction() {
    Get.toNamed('/photo-import');
  }

  void _handleAIAction() {
    Get.toNamed('/ai-generator');
  }

  void _handleBlankCanvasAction() {
    Get.toNamed('/editor/new');
  }

  void _handleTemplatesAction() {
    onBottomNavTap(1);
  }

  // --- SEARCH FUNCTIONALITY ---
  void onSearchChanged(String query) {
    if (query.isEmpty) {
      templates.assignAll(featuredTemplates);
      return;
    }

    final filteredTemplates = featuredTemplates.where((template) {
      return template.name.toLowerCase().contains(query.toLowerCase()) ||
          template.category.toLowerCase().contains(query.toLowerCase()) ||
          template.tags.any(
            (tag) => tag.toLowerCase().contains(query.toLowerCase()),
          );
    }).toList();

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

extension MmToPx on num {
  /// Converts millimeters to Flutter logical pixels using standard 96 DPI (Figma default)
  double get mm => (this / 25.4) * 96;
}
