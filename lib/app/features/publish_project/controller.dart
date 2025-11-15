import 'package:cardmaker/app/features/home/controller.dart';
import 'package:cardmaker/models/card_template.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PublishProjectController extends GetxController {
  HomeController get homeController => Get.find<HomeController>();

  final RxString projectName = ''.obs;
  final Rxn<CategoryModel> selectedCategory = Rxn<CategoryModel>();
  final RxBool isPublishing = false.obs;
  final TextEditingController nameController = TextEditingController();

  // Cache categories list to avoid repeated access
  List<CategoryModel> get categories {
    try {
      return homeController.categories;
    } catch (e) {
      // Fallback if HomeController is not available
      return [];
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Set default category to 'general' if available
    try {
      final generalCategory = categories.firstWhereOrNull(
        (cat) => cat.id == 'general',
      );
      if (generalCategory != null) {
        selectedCategory.value = generalCategory;
      }
    } catch (e) {
      debugPrint('Error initializing default category: $e');
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  void selectCategory(CategoryModel category) {
    selectedCategory.value = category;
  }

  bool get canPublish {
    return projectName.value.trim().isNotEmpty &&
        selectedCategory.value != null;
  }

  String? get selectedCategoryId => selectedCategory.value?.id;
  String? get selectedCategoryName => selectedCategory.value?.name;
}
