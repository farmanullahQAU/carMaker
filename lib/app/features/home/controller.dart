// import 'dart:convert';

// import 'package:cardmaker/app/routes/app_routes.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../../../models/card_template.dart';

// class HomeController extends GetxController {
//   // --- STATE ---
//   final selectedIndex = 0.obs;
//   final pageController = PageController();
//   final templates = <CardTemplate>[].obs;
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
//   final RxList<CardTemplate> featuredTemplates = RxList<CardTemplate>([
//     CardTemplate(
//       id: 'wedding_invite_20250712',
//       name: 'Wedding Invitation',
//       thumbnailPath: null,
//       backgroundImage: 'assets/card1.png',
//       items: [
//         {
//           'type': 'StackTextItem',
//           'id': 'center',
//           'status': 0,
//           'size': {'width': 200.0, 'height': 100.0},
//           'content': {
//             'data': 'Invitation to the Wedding of John and Jane',
//             'googleFont': 'Great Vibes',
//             'style': {'fontSize': 30.0},
//           },
//           'isCentered': false,
//           'originalRelativeOffset': {'dx': 0.5, 'dy': 0.5},
//         },
//         {
//           'type': 'StackTextItem',
//           'id': 'text2_topRight',
//           'status': 0,
//           'size': {'width': 200.0, 'height': 100.0},
//           'content': {
//             'data': 'John & Jane',
//             'googleFont': 'Great Vibes',
//             'style': {'fontSize': 11.0},
//           },
//           'isCentered': false,
//           'originalRelativeOffset': {'dx': 0.5, 'dy': 0.55},
//         },
//         {
//           'type': 'StackTextItem',
//           'id': 'text3_bottomLeft',
//           'status': 0,
//           'size': {'width': 200.0, 'height': 33.0},
//           'content': {
//             'data': 'Saturday, July 12',
//             'googleFont': 'Great Vibes',
//             'style': {'fontSize': 11.0},
//           },
//           'isCentered': false,
//           'originalRelativeOffset': {'dx': 0.5, 'dy': 0.6},
//         },
//         {
//           'type': 'StackTextItem',
//           'id': 'text4_bottomRight',
//           'status': 0,
//           'size': {'width': 200.0, 'height': 40.0},
//           'content': {
//             'data': 'Save the Date',
//             'googleFont': 'Great Vibes',
//             'style': {'fontSize': 11.0},
//           },
//           'isCentered': false,
//           'originalRelativeOffset': {'dx': 0.879, 'dy': 0.977},
//         },
//         {
//           'type': 'StackImageItem',
//           'id': 'image_topLeft',
//           'status': 0,
//           'size': {'width': 200.0, 'height': 200.0},
//           'content': {'assetName': 'assets/Farman.png'},
//           'isCentered': false,
//           'originalRelativeOffset': {'dx': 0.1, 'dy': 0.1},
//         },
//       ],
//       createdAt: DateTime.parse('2025-07-12T06:32:00Z'),
//       updatedAt: null,
//       category: 'wedding',
//       categoryId: 'wedding',
//       compatibleDesigns: [],
//       width: 1240,
//       height: 1748,
//       isPremium: false,
//       tags: ['wedding', 'invitation', 'elegant'],
//       imagePath: 'assets/card1.png',
//     ),
//     CardTemplate(
//       id: 'birthday_invite_20250716',
//       name: 'Birthday Celebration',
//       thumbnailPath: null,
//       backgroundImage: 'assets/birthday_2.png',
//       items: [
//         {
//           'type': 'StackTextItem',
//           'id': 'title_center',
//           'status': 0,
//           'size': {'width': 240.0, 'height': 32.0},
//           'content': {
//             'data': 'You\'re Invited!',
//             'googleFont': 'Pacifico',
//             'style': {
//               'fontSize': 20.0,
//               'color': '#FF4081',
//               'fontWeight': 'FontWeight.w700',
//             },
//           },
//           'isCentered': false,
//           'originalRelativeOffset': {'dx': 0.5, 'dy': 0.18},
//         },
//         {
//           'type': 'StackTextItem',
//           'id': 'subtitle',
//           'status': 0,
//           'size': {'width': 240.0, 'height': 28.0},
//           'content': {
//             'data': 'To Celebrate Alex\'s 5th Birthday',
//             'googleFont': 'Roboto',
//             'style': {
//               'fontSize': 14.0,
//               'color': '#3F51B5',
//               'fontWeight': 'FontWeight.w600',
//             },
//           },
//           'isCentered': false,
//           'originalRelativeOffset': {'dx': 0.5, 'dy': 0.28},
//         },
//         {
//           'type': 'StackTextItem',
//           'id': 'details_date_time',
//           'status': 0,
//           'size': {'width': 220.0, 'height': 24.0},
//           'content': {
//             'data': 'Saturday, July 20 | 3 PM',
//             'googleFont': 'Lato',
//             'style': {
//               'fontSize': 12.0,
//               'color': '#000000',
//               'fontWeight': 'FontWeight.w500',
//             },
//           },
//           'isCentered': false,
//           'originalRelativeOffset': {'dx': 0.5, 'dy': 0.5},
//         },
//         {
//           'type': 'StackTextItem',
//           'id': 'details_location',
//           'status': 0,
//           'size': {'width': 240.0, 'height': 24.0},
//           'content': {
//             'data': 'Happy Hall, Main Street, Cityville',
//             'googleFont': 'Lato',
//             'style': {
//               'fontSize': 12.0,
//               'color': '#000000',
//               'fontWeight': 'FontWeight.w400',
//             },
//           },
//           'isCentered': false,
//           'originalRelativeOffset': {'dx': 0.5, 'dy': 0.56},
//         },
//         {
//           'type': 'StackTextItem',
//           'id': 'footer_rsvp',
//           'status': 0,
//           'size': {'width': 160.0, 'height': 22.0},
//           'content': {
//             'data': 'RSVP: mom@party.com',
//             'googleFont': 'Lato',
//             'style': {
//               'fontSize': 11.0,
//               'color': '#FF6F00',
//               'fontWeight': 'FontWeight.w500',
//             },
//           },
//           'isCentered': false,
//           'originalRelativeOffset': {'dx': 0.5, 'dy': 0.65},
//         },
//       ],
//       createdAt: DateTime.parse('2025-07-16T12:00:00Z'),
//       updatedAt: null,
//       category: 'birthday',
//       categoryId: 'birthday',
//       compatibleDesigns: [],
//       width: 1240,
//       height: 1748,
//       isPremium: false,
//       tags: ['birthday', 'kids', 'fun', 'party'],
//       imagePath: 'assets/birthday_2.png',
//     ),
//   ]);

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
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final String? templatesJson = prefs.getString('templates');

//       if (templatesJson != null && templatesJson.isNotEmpty) {
//         final List<dynamic> templatesList = jsonDecode(templatesJson);
//         final loadedTemplates = templatesList
//             .map((json) => CardTemplate.fromJson(json))
//             .toList();
//         templates.assignAll(loadedTemplates);
//       } else {
//         templates.assignAll(featuredTemplates);
//       }
//     } catch (e) {
//       print('Error loading templates: $e');
//       templates.assignAll(featuredTemplates);
//     }
//   }

//   // Future<void> saveTemplates() async {
//   //   try {
//   //     final prefs = await SharedPreferences.getInstance();
//   //     final templatesJson = jsonEncode(
//   //       templates.map((template) => template.toJson()).toList(),
//   //     );
//   //     await prefs.setString('templates', templatesJson);
//   //   } catch (e) {
//   //     print('Error saving templates: $e');
//   //   }
//   // }

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
//     Get.toNamed('/editor/new');
//   }

//   void _handleTemplatesAction() {
//     onBottomNavTap(1);
//   }

//   // --- SEARCH FUNCTIONALITY ---
//   void onSearchChanged(String query) {
//     if (query.isEmpty) {
//       templates.assignAll(featuredTemplates);
//       return;
//     }

//     final filteredTemplates = featuredTemplates.where((template) {
//       return template.name.toLowerCase().contains(query.toLowerCase()) ||
//           template.category.toLowerCase().contains(query.toLowerCase()) ||
//           template.tags.any(
//             (tag) => tag.toLowerCase().contains(query.toLowerCase()),
//           );
//     }).toList();

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
// }

// // --- ENHANCED DATA MODELS ---
// class CategoryModel {
//   final String id;
//   final String name;
//   final Color color;
//   final IconData icon;
//   final String? imagePath;

//   CategoryModel({
//     required this.id,
//     required this.name,
//     required this.color,
//     required this.icon,
//     this.imagePath,
//   });

//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'name': name,
//     'color': color.value,
//     'icon': icon.codePoint,
//     'imagePath': imagePath,
//   };

//   factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
//     id: json['id'],
//     name: json['name'],
//     color: Color(json['color']),
//     icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
//     imagePath: json['imagePath'],
//   );
// }

// class QuickAction {
//   final String title;
//   final IconData icon;
//   final Color color;

//   QuickAction({required this.title, required this.icon, required this.color});

//   Map<String, dynamic> toJson() => {
//     'title': title,
//     'icon': icon.codePoint,
//     'color': color.value,
//   };

//   factory QuickAction.fromJson(Map<String, dynamic> json) => QuickAction(
//     title: json['title'],
//     icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
//     color: Color(json['color']),
//   );
// }

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
    //   id: 'wedding_invite_20250712',
    //   name: 'Wedding Invitation',
    //   thumbnailPath: null,
    //   backgroundImage: 'assets/card1.png',
    //   items: [
    //     {
    //       'type': 'StackTextItem',
    //       'originalX': 420,
    //       'originalY': 824,
    //       'originalWidth': 400,
    //       'originalHeight': 100,
    //       'content': {
    //         'data': 'Invitation',
    //         'googleFont': 'Poppins',
    //         'style': {'fontSize': 30.0, 'minFontSize': 8, 'maxFontSize': 40},
    //       },
    //       'textAlign': 'center',
    //     },
    //     {
    //       'type': 'StackTextItem',
    //       'originalX': 420,
    //       'originalY': 924,
    //       'originalWidth': 400,
    //       'originalHeight': 100,
    //       'content': {
    //         'data': 'John & Jane',
    //         'googleFont': 'Great Vibes',
    //         'style': {'fontSize': 22.0, 'minFontSize': 8, 'maxFontSize': 40},
    //       },
    //       'textAlign': 'center',
    //     },
    //     {
    //       'type': 'StackTextItem',
    //       'originalX': 420,
    //       'originalY': 1024,
    //       'originalWidth': 400,
    //       'originalHeight': 100,
    //       'content': {
    //         'data': 'Saturday, July 12',
    //         'googleFont': 'Great Vibes',
    //         'style': {'fontSize': 22.0, 'minFontSize': 8, 'maxFontSize': 40},
    //       },
    //       'textAlign': 'center',
    //     },
    //     {
    //       'type': 'StackTextItem',
    //       'originalX': 940,
    //       'originalY': 1608,
    //       'originalWidth': 200,
    //       'originalHeight': 100,
    //       'content': {
    //         'data': 'Save the Date',
    //         'googleFont': 'Great Vibes',
    //         'style': {'fontSize': 22.0, 'minFontSize': 8, 'maxFontSize': 40},
    //       },
    //       'textAlign': 'center',
    //     },
    //     {
    //       'type': 'StackImageItem',
    //       'originalX': 20,
    //       'originalY': 20,
    //       'originalWidth': 200,
    //       'originalHeight': 200,
    //       'content': {'assetName': 'assets/Farman.png'},
    //       'fit': 'cover',
    //     },
    //   ],
    //   createdAt: DateTime.parse('2025-07-12T06:32:00Z'),
    //   updatedAt: null,
    //   category: 'wedding',
    //   categoryId: 'wedding',
    //   compatibleDesigns: [],
    //   width: 1240,
    //   height: 1748,
    //   isPremium: false,
    //   tags: ['wedding', 'invitation', 'elegant'],
    //   imagePath: 'assets/card1.png',
    // ),
    CardTemplate(
      id: 'wedding_invite_20250718',
      name: 'Ali & Zara Wedding',
      thumbnailPath: null,
      backgroundImage: 'assets/card1.png',
      items: [
        {
          'type': 'StackTextItem',
          'status': 0,
          'originalX': 620,
          'originalY': 160.0,
          'size': {'width': 1000.0, 'height': 120.0},
          'originalRelativeOffset': {'dx': 0.1, 'dy': 0.2},
          'isCentered': false,
          'content': {
            'data': 'ZARA & \n KIERAN',
            'googleFont': 'Poppins',
            'style': {'fontSize': 32.0, 'color': '#B71C1C'},
          },
          'textAlign': 'left',
        },
        {
          'type': 'StackTextItem',
          'status': 0,
          'originalX': 620,
          'originalY': 300.0,
          'size': {'width': 1000.0, 'height': 100.0},
          'originalRelativeOffset': {'dx': 0.5, 'dy': 0.3},
          'isCentered': true,
          'content': {
            'data': 'joyfully invite you to their ',
            'googleFont': 'Dancing Script',
            'style': {'fontSize': 11.0, 'color': '#880E4F'},
          },
          'textAlign': 'center',
        },
        {
          'type': 'StackTextItem',
          'status': 0,
          'originalX': 620,
          'originalY': 440.0,
          'size': {'width': 1000.0, 'height': 60.0},
          'originalRelativeOffset': {'dx': 0.5, 'dy': 0.3},
          'isCentered': true,
          'content': {
            'data': 'Together With Their Families',
            'googleFont': 'Montserrat',
            'style': {'fontSize': 20.0, 'color': '#4A148C'},
          },
          'textAlign': 'center',
        },
        {
          'type': 'StackTextItem',
          'status': 0,
          'originalX': 620,
          'originalY': 570.0,
          'size': {'width': 1000.0, 'height': 80.0},
          'originalRelativeOffset': {'dx': 0.5, 'dy': 0.4},
          'isCentered': true,
          'content': {
            'data': 'Invite You To Celebrate Their Wedding',
            'googleFont': 'Montserrat',
            'style': {'fontSize': 18.0, 'color': '#6A1B9A'},
          },
          'textAlign': 'center',
        },
        {
          'type': 'StackTextItem',
          'status': 0,
          'originalX': 620,
          'originalY': 700.0,
          'size': {'width': 1000.0, 'height': 60.0},
          'originalRelativeOffset': {'dx': 0.5, 'dy': 0.5},
          'isCentered': true,
          'content': {
            'data': 'Sunday • 25 August 2025 • 6:00 PM',
            'googleFont': 'Open Sans',
            'style': {'fontSize': 18.0, 'color': '#1A237E'},
          },
          'textAlign': 'center',
        },
        {
          'type': 'StackTextItem',
          'status': 0,
          'originalX': 620,
          'originalY': 800.0,
          'size': {'width': 1000.0, 'height': 60.0},
          'originalRelativeOffset': {'dx': 0.5, 'dy': 0.58},
          'isCentered': true,
          'content': {
            'data': 'Royal Gardens Hall, Lahore',
            'googleFont': 'Open Sans',
            'style': {'fontSize': 18.0, 'color': '#283593'},
          },
          'textAlign': 'center',
        },
        {
          'type': 'StackTextItem',
          'status': 0,
          'originalX': 620,
          'originalY': 1000.0,
          'size': {'width': 1000.0, 'height': 50.0},
          'originalRelativeOffset': {'dx': 0.5, 'dy': 0.7},
          'isCentered': true,
          'content': {
            'data': 'Kindly RSVP by August 15',
            'googleFont': 'Roboto',
            'style': {'fontSize': 16.0, 'color': '#37474F'},
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
      tags: ['wedding', 'romantic', 'invitation', 'ceremony', 'celebration'],
      imagePath: 'assets/card1.png',
    ),

    CardTemplate(
      id: 'wedding_invite_20250718',
      name: 'Elegant Wedding Invite',
      thumbnailPath: null,
      backgroundImage: 'assets/card1.png',
      items: [
        {
          'type': 'StackTextItem',
          'status': 0,
          'originalX': 620,
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
          'originalX': 620,
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
          'originalX': 620,
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
          'originalX': 620,
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
          'originalX': 620,
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
          'originalX': 620,
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
