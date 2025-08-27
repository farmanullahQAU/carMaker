// // Controller for managing theme and form state
// import 'package:cardmaker/app/routes/app_routes.dart';
// import 'package:cardmaker/models/card_template.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class CanvasSelectionController extends GetxController {
//   var isDarkMode = false.obs;
//   final widthController = TextEditingController();
//   final heightController = TextEditingController();

//   final List<CardTemplate> cardTemplates = [
//     CardTemplate(
//       id: '1',
//       name: 'Portrait - 5x7 in',
//       backgroundImageUrl: '',
//       items: [],
//       categoryId: 'standard',
//       width: 1500, // 5 inches * 300 dpi
//       height: 2100, // 7 inches * 300 dpi
//       imagePath: '',
//     ),
//     CardTemplate(
//       id: '2',
//       name: 'Landscape - 6x4 in',
//       backgroundImageUrl: '',
//       items: [],
//       categoryId: 'standard',
//       width: 1800,
//       height: 1200,
//       imagePath: '',
//     ),
//     CardTemplate(
//       id: '3',
//       name: 'Square - 6x6 in',
//       backgroundImageUrl: '',
//       items: [],
//       categoryId: 'standard',
//       width: 1800,
//       height: 1800,
//       imagePath: '',
//     ),
//     CardTemplate(
//       id: '4',
//       name: 'Printable - A4',
//       backgroundImageUrl: '',
//       items: [],
//       categoryId: 'standard',
//       width: 2480, // A4 width in pixels at 300 dpi
//       height: 3508, // A4 height in pixels at 300 dpi
//       imagePath: '',
//     ),
//     CardTemplate(
//       id: '5',
//       name: 'Mobile - 9:16',
//       backgroundImageUrl: '',
//       items: [],
//       categoryId: 'standard',
//       width: 1080,
//       height: 1920,
//       imagePath: '',
//     ),
//     CardTemplate(
//       id: '6',
//       name: 'Story - 1080x1920',
//       backgroundImageUrl: '',
//       items: [],
//       categoryId: 'standard',
//       width: 1080,
//       height: 1920,
//       imagePath: '',
//     ),

//     //greetings card
//     CardTemplate(
//       id: '7',
//       name: 'Oversized Portrait - 10x14 in',
//       backgroundImageUrl: '',
//       items: [],
//       categoryId: 'oversized',
//       width: 3000,
//       height: 4200,
//       imagePath: '',
//     ),
//     CardTemplate(
//       id: '8',
//       name: 'Oversized Landscape - 14x10 in',
//       backgroundImageUrl: '',
//       items: [],
//       categoryId: 'oversized',
//       width: 4200,
//       height: 3000,
//       imagePath: '',
//     ),

//     CardTemplate(
//       id: '9',
//       name: 'Greetog',
//       backgroundImageUrl: '',
//       items: [],
//       categoryId: 'Greetings',
//       width: 1240,
//       height: 1748,
//       imagePath: '',
//     ),

//     CardTemplate(
//       id: '22',
//       name: 'Greetog',
//       backgroundImageUrl: 'assets/card7.png',
//       thumbnailUrl: 'assets/hisham.png',
//       items: [
//         {
//           "type": "StackImageItem",
//           "id": "profile_image_1698765432100",
//           "offset": {"dx": 555.0, "dy": 1077.0},
//           "size": {"width": 791.0, "height": 778.0},
//           "content": {"assetName": "assets/hisham.jpeg"},
//           "status": 0,
//           "isCentered": false,
//           "lockZOrder": true,
//           "isProfileImage": true,
//         },
//         {
//           "type": "StackImageItem",
//           "id": "sssss",
//           "offset": {"dx": 50.0, "dy": 44.0},
//           "size": {"width": 100.0, "height": 100.0},
//           "content": {"assetName": "assets/hisham.jpeg"},
//           "status": 0,
//           "isCentered": false,
//           "lockZOrder": false,
//           "isProfileImage": false,
//         },
//         {
//           "type": "StackImageItem",
//           "id": "ll",
//           "offset": {"dx": 100.0, "dy": 200.0},
//           "size": {"width": 100.0, "height": 100.0},
//           "content": {"assetName": "assets/farame.png"},
//           "status": 0,
//           "isCentered": false,
//           "lockZOrder": false,
//           "isProfileImage": false,
//         },
//       ],
//       categoryId: 'Greetings',
//       width: 1414,
//       height: 2000,
//       imagePath: '',
//     ),
//   ];

//   void toggleTheme() {
//     isDarkMode.value = !isDarkMode.value;
//   }

//   void createCustomCanvas() {
//     final width = int.tryParse(widthController.text);
//     final height = int.tryParse(heightController.text);

//     if (width == null || height == null || width <= 0 || height <= 0) {
//       Get.snackbar(
//         'Invalid Dimensions',
//         'Please enter valid positive numbers for width and height',
//         backgroundColor: Colors.red.withOpacity(0.8),
//         colorText: Colors.white,
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return;
//     }

//     Get.back(result: {'width': width, 'height': height});
//   }

//   void selectPresetCanvas(CardTemplate template) {
//     Get.toNamed(
//       Routes.editor,
//       arguments: {"isblank": true, "template": template},
//     );
//   }

//   @override
//   void onClose() {
//     widthController.dispose();
//     heightController.dispose();
//     super.onClose();
//   }
// }
