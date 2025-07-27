import 'dart:convert';

import 'package:cardmaker/app/features/home/home.dart';
import 'package:cardmaker/app/routes/app_routes.dart';
import 'package:cardmaker/models/card_template.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    // CardTemplate(
    //   id: 'birthday_card_20250721',
    //   name: 'Liam\'s Birthday Bash',
    //   thumbnailPath: null,
    //   backgroundImage: 'assets/card1.png',
    //   items: [
    //     {
    //       'type': 'StackImageItem',
    //       'id': 'birthday_image',
    //       'status': 0,
    //       'size': {'width': 400.0, 'height': 400.0},
    //       'content': {'assetName': 'assets/Farman.png'},
    //       'isCentered': true,
    //       'offset': {'dx': 620.0, 'dy': 180.0},
    //     },
    //     {
    //       'type':
    //           'RowStackItem', //if we need the RowStackItem any item aligned horizentally we keep dy for that zero so that the RowStackItem dy will be used .
    //       'status': 0,
    //       'id': 'row_item_1',
    //       'size': {'width': 0.0, 'height': 30.0},
    //       'isCentered': true,
    //       'offset': {'dx': 413.0, 'dy': 660.0},
    //       'content': {
    //         'items': [
    //           {
    //             'type': 'StackTextItem',

    //             'id': 'text_1',
    //             'size': {'width': 0.0, 'height': 30.0},
    //             'offset': {'dx': 0.0, 'dy': 0.0},
    //             'content': {
    //               'data': 'Party Time',
    //               'googleFont': 'Dancing Script',
    //               'style': {'fontSize': 18.0, 'color': '#F57C00'},
    //             },
    //             'textAlign': 'center',
    //           },
    //           {
    //             'type': 'StackTextItem',
    //             'id': 'text_2',
    //             'size': {'width': 0.0, 'height': 30.0},
    //             'offset': {'dx': 0.0, 'dy': 0.0},
    //             'content': {
    //               'data': '5:30 PM',
    //               'googleFont': 'Dancing Script',
    //               'style': {'fontSize': 18.0, 'color': '#F57C00'},
    //             },
    //             'textAlign': 'center',
    //           },
    //           {
    //             'type': 'StackTextItem',
    //             'id': 'text_3',
    //             'size': {'width': 0.0, 'height': 30.0},
    //             'offset': {'dx': 0.0, 'dy': 660.0},
    //             'content': {
    //               'data': 'Islamabad',
    //               'googleFont': 'Dancing Script',
    //               'style': {'fontSize': 18.0, 'color': '#F57C00'},
    //             },
    //             'textAlign': 'center',
    //           },
    //         ],
    //       },
    //     },
    //     {
    //       'type': 'StackTextItem',
    //       'status': 0,
    //       'size': {'width': 1040.0, 'height': 300.0},
    //       'offset': {'dx': 620.0, 'dy': 675.0},
    //       'isCentered': true,
    //       'content': {
    //         'data': 'You\'re Invited to',
    //         'googleFont': 'Dancing Script',
    //         'style': {'fontSize': 18.0, 'color': '#F57C00'},
    //       },
    //       'textAlign': 'center',
    //     },

    //     {
    //       'type': 'StackTextItem',
    //       'status': 0,
    //       'size': {'width': 1040.0, 'height': 300.0},
    //       'offset': {'dx': 620.0, 'dy': 675.0},
    //       'isCentered': true,
    //       'content': {
    //         'data': 'Masked Text',
    //         'googleFont': 'Dancing Script',
    //         'style': {
    //           'fontSize': 30.0,
    //           // 'color': '#00000000', // Transparent for mask
    //           'shadows': [
    //             {
    //               'offset': {'dx': 2.0, 'dy': 2.0},
    //               'blurRadius': 4.0,
    //               // 'color': '#80000000', // Black with 50% opacity
    //             },
    //           ],
    //         },
    //         'maskImage': 'assets/card1.png',
    //       },
    //       'textAlign': 'center',
    //     },

    //     {
    //       'type': 'StackTextItem',
    //       'status': 0,
    //       'size': {'width': 1040.0, 'height': 100.0},
    //       'offset': {'dx': 620.0, 'dy': 675.0},
    //       'isCentered': true,
    //       'content': {
    //         'data': 'Liam\'s 8th \n Birthday!',
    //         'googleFont': 'Dancing Script',
    //         'style': {
    //           'fontSize': 30.0,
    //           'color': '#D32F2F',
    //           'letterSpacing': 7.8,
    //           'height': 1.0,
    //         },
    //       },
    //       'textAlign': 'center',
    //     },

    //     {
    //       'type': 'StackTextItem',
    //       'status': 0,
    //       'size': {'width': 1000.0, 'height': 30.0},
    //       'offset': {
    //         'dx': 620.0,
    //         'dy': 700.0,
    //       }, //dy is sam becase we calculate we add as this dy pluse the previous item height
    //       'isCentered': true,
    //       'content': {
    //         'data': 'Join us for cake, games, \n and fun!',
    //         'googleFont': stylishGoogleFonts[7],
    //         'style': {'fontSize': 20.0, 'color': '#F57C00'},
    //       },
    //       'textAlign': 'center',
    //     },
    //     {
    //       'type': 'StackImageItem',
    //       'id': 'line_1',
    //       'status': 0,
    //       'size': {'width': 400.0, 'height': 200.0},
    //       'content': {'assetName': 'assets/line1.png'},
    //       'isCentered': true,
    //       'offset': {'dx': 620.0, 'dy': 780.0},
    //     },
    //     {
    //       'type': 'StackTextItem',
    //       'status': 0,
    //       'size': {'width': 1000.0, 'height': 60.0},
    //       'offset': {'dx': 620.0, 'dy': 1000.0},
    //       'isCentered': true,
    //       'content': {
    //         'data': 'Saturday • August 31 • 2:00 PM',
    //         'googleFont': stylishGoogleFonts[4],
    //         'style': {'fontSize': 18.0, 'color': '#1E88E5'},
    //       },
    //       'textAlign': 'center',
    //     },
    //   ],
    //   createdAt: DateTime.parse('2025-07-21T00:00:00Z'),
    //   updatedAt: null,
    //   category: 'birthday',
    //   categoryId: 'birthday',
    //   compatibleDesigns: [],
    //   width: 1240,
    //   height: 1748,
    //   isPremium: false,
    //   tags: ['birthday', 'kids', 'party', 'celebration', 'invite'],
    //   imagePath: 'assets/birthday_1.png',
    // ),
    CardTemplate(
      id: 'birthday_card_20250721',
      name: 'Liam\'s Birthday Bash',
      thumbnailPath: null,
      backgroundImage: 'assets/card1.png',
      items: [
        {
          'type': 'StackTextItem',
          'status': 0,
          'size': {'width': 1040.0, 'height': 300.0},
          'offset': {
            'dx': 620.0,
            'dy': 500.0,
          }, //zero means half hide from above so we are adding half its heght+button size to make it perfect top
          'isCentered': true,
          'content': {
            'data': 'You\'re Invited to',
            'googleFont': 'Dancing Script',
            'style': {'fontSize': 25.0, 'color': '#F57C00'},
          },
          'textAlign': 'center',
        },
        {
          'type': 'StackImageItem',
          'id': 'birthday_image',
          'status': 0,
          'size': {'width': 500.0, 'height': 200.0}, //
          'content': {'assetName': 'assets/line1.png'},
          'isCentered': true,
          'offset': {
            'dx': 620.0,
            'dy': 500.0,
          }, //dy zero means half hide from above dy //to make it excatly to top we do dy =imageHeight/2
        },

        {
          'type': 'StackTextItem',
          'status': 0,
          'size': {'width': 1040.0, 'height': 100.0},
          'offset': {'dx': 600.0, 'dy': 500.0},
          'isCentered': true,
          'content': {
            'data': 'Liam\'s 8th \n Birthday!',
            'googleFont': 'Dancing Script',
            'style': {
              'fontSize': 30.0,
              'color': '#D32F2F',
              'letterSpacing': 7.8,
              'height': 1.0,
            },
          },
          'textAlign': 'center',
        },

        // {
        //   'type': 'StackImageItem',
        //   'id': 'fr',
        //   'status': 0,
        //   'size': {'width': 400.0, 'height': 400.0},
        //   'content': {'assetName': 'assets/Farman.png'},
        //   'isCentered': true,
        //   'offset': {
        //     'dx': 620.0,
        //     'dy': 400.0,
        //   }, // Adjusted dx to center based on new width (1748 / 2)
        // },
        // {
        //   'type': 'StackTextItem',
        //   'status': 0,
        //   'size': {'width': 1000.0, 'height': 30.0},
        //   'offset': {'dx': 620.0, 'dy': 400.0},
        //   'isCentered': true,
        //   'content': {
        //     'data': 'Join us for cake, games, \n and fun!',
        //     'googleFont': stylishGoogleFonts[7],
        //     'style': {'fontSize': 20.0, 'color': '#F57C00'},
        //   },
        //   'textAlign': 'center',
        // },
        // {
        //   'type': 'StackTextItem',
        //   'status': 0,
        //   'size': {'width': 1000.0, 'height': 60.0},
        //   'offset': {'dx': 620.0, 'dy': 450.0},
        //   'isCentered': true,
        //   'content': {
        //     'data': 'Saturday August 31',
        //     'googleFont': stylishGoogleFonts[4],
        //     'style': {'fontSize': 18.0, 'color': '#1E88E5'},
        //   },
        //   'textAlign': 'center',
        // },
        // {
        //   'type': 'StackTextItem',
        //   'status': 0,
        //   'size': {'width': 1000.0, 'height': 60.0},
        //   'offset': {'dx': 620.0, 'dy': 640.0},
        //   'isCentered': true,
        //   'content': {
        //     'data': '┃',
        //     'googleFont': stylishGoogleFonts[4],
        //     'style': {'fontSize': 20.0, 'color': '#1E88E5'},
        //   },
        //   'textAlign': 'center',
        // },
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
      imagePath: 'assets/card1.png',
    ),

    CardTemplate(
      id: 'new_template_20250726',
      name: 'Summer Celebration Invite',
      thumbnailPath: null,
      backgroundImage: 'assets/card2.png',
      items: [
        {
          'type': 'StackImageItem',
          'id': 'summer_image',
          'status': 0,
          'size': {'width': 450.0, 'height': 450.0},
          'content': {'assetName': 'assets/Farman.png'},
          'isCentered': true,
          'offset': {
            'dx': 874.0,
            'dy': 100.0,
          }, // Adjusted dx to center based on new width (1748 / 2)
        },
        {
          'type': 'StackTextItem',
          'status': 0,
          'size': {'width': 1000.0, 'height': 120.0},
          'offset': {'dx': 874.0, 'dy': 100.0}, // Adjusted dx to center
          'isCentered': true,
          'content': {
            'data': 'Join the Summer Fun!',
            'googleFont': 'Dancing Script',
            'style': {'fontSize': 28.0, 'color': '#FFCA28'},
          },
          'textAlign': 'cenlter',
        },
        {
          'type': 'StackTextItem',
          'status': 0,
          'size': {'width': 1000.0, 'height': 80.0},
          'offset': {'dx': 874.0, 'dy': 120.0}, // Adjusted dx to center
          'isCentered': true,
          'content': {
            'data': 'Outdoor Party',
            'googleFont': 'Roboto',
            'style': {'fontSize': 24.0, 'color': '#388E3C'},
          },
          'textAlign': 'center',
        },
        {
          'type': 'StackTextItem',
          'status': 0,
          'size': {'width': 1000.0, 'height': 60.0},
          'offset': {'dx': 874.0, 'dy': 140.0}, // Adjusted dx to center
          'isCentered': true,
          'content': {
            'data': 'Saturday, August 15, 2025',
            'googleFont': 'Dancing Script',
            'style': {'fontSize': 20.0, 'color': '#1976D2'},
          },
          'textAlign': 'center',
        },
        {
          'type': 'StackTextItem',
          'status': 0,
          'size': {'width': 1000.0, 'height': 60.0},
          'offset': {'dx': 874.0, 'dy': 300.0}, // Adjusted dx to center
          'isCentered': true,
          'content': {
            'data': 'Karachi Beach Park',
            'googleFont': 'Dancing Script',
            'style': {'fontSize': 18.0, 'color': '#D81B60'},
          },
          'textAlign': 'center',
        },
      ],
      createdAt: DateTime.parse('2025-07-26T00:00:00Z'),
      updatedAt: null,
      category: 'summer',
      categoryId: 'summer',
      compatibleDesigns: [],
      width: 1748, // Updated to match your specification
      height: 1240, // Updated to match your specification
      isPremium: false,
      tags: ['summer', 'party', 'outdoor', 'celebration', 'invite'],
      imagePath: 'assets/card2.png',
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
