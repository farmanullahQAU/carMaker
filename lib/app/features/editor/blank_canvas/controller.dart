// Controller for managing theme and form state
import 'package:cardmaker/app/routes/app_routes.dart';
import 'package:cardmaker/models/card_template.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CanvasSelectionController extends GetxController {
  var isDarkMode = false.obs;
  final widthController = TextEditingController();
  final heightController = TextEditingController();

  // List of card templates with different dimensions
  final List<CardTemplate> cardTemplates = [
    CardTemplate(
      id: '1',
      name: 'SVGA',
      backgroundImage: '',
      items: [],
      categoryId: 'standard',
      width: 800,
      height: 600,
      imagePath: '',
    ),
    CardTemplate(
      id: '2',
      name: 'Square',
      backgroundImage: '',
      items: [],
      categoryId: 'standard',
      width: 1000,
      height: 1000,
      imagePath: '',
    ),
    CardTemplate(
      id: '3',
      name: 'Full HD',
      backgroundImage: '',
      items: [],
      categoryId: 'standard',
      width: 1920,
      height: 1080,
      imagePath: '',
    ),
    CardTemplate(
      id: '4',
      name: '2K',
      backgroundImage: '',
      items: [],
      categoryId: 'standard',
      width: 2560,
      height: 1440,
      imagePath: '',
    ),
    CardTemplate(
      id: '5',
      name: 'Mobile',
      backgroundImage: '',
      items: [],
      categoryId: 'standard',
      width: 1080,
      height: 1920,
      imagePath: '',
    ),
    CardTemplate(
      id: '6',
      name: '4K',
      backgroundImage: '',
      items: [],
      categoryId: 'standard',
      width: 3840,
      height: 2160,
      imagePath: '',
    ),
  ];

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
  }

  void createCustomCanvas() {
    final width = int.tryParse(widthController.text);
    final height = int.tryParse(heightController.text);

    if (width == null || height == null || width <= 0 || height <= 0) {
      Get.snackbar(
        'Invalid Dimensions',
        'Please enter valid positive numbers for width and height',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.back(result: {'width': width, 'height': height});
  }

  void selectPresetCanvas(CardTemplate template) {
    Get.toNamed(
      Routes.editor,
      arguments: {"isblank": true, "template": template},
    );
  }

  @override
  void onClose() {
    widthController.dispose();
    heightController.dispose();
    super.onClose();
  }
}
