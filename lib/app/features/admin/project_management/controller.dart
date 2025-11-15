import 'package:cardmaker/core/utils/admin_utils.dart';
import 'package:cardmaker/core/utils/toast_helper.dart';
import 'package:cardmaker/models/card_template.dart';
import 'package:cardmaker/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProjectManagementController extends GetxController {
  final FirestoreServices _firestoreService = FirestoreServices();

  final RxList<CardTemplate> templates = <CardTemplate>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isAdmin = false.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _checkAdminAccess();
  }

  Future<void> _checkAdminAccess() async {
    try {
      final admin = await AdminUtils.isAdmin();
      isAdmin.value = admin;
      if (admin) {
        loadProjects();
      } else {
        ToastHelper.error('Access denied. Admin only.');
        Get.back();
      }
    } catch (e) {
      ToastHelper.error('Error checking admin access: $e');
      Get.back();
    }
  }

  Future<void> loadProjects() async {
    if (!isAdmin.value) return;

    try {
      isLoading.value = true;
      final projects = await _firestoreService.getAllTemplates(limit: 100);
      templates.assignAll(projects);
    } catch (e) {
      ToastHelper.error('Failed to load projects: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProject(String templateId) async {
    if (!isAdmin.value) return;

    try {
      // Show confirmation dialog
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete Project'),
          content: const Text(
            'Are you sure you want to delete this project? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        ToastHelper.loading('Deleting project...');
        await _firestoreService.deleteTemplate(templateId);
        templates.removeWhere((t) => t.id == templateId);
        ToastHelper.dismissAll();
        ToastHelper.success('Project deleted successfully');
      }
    } catch (e) {
      ToastHelper.dismissAll();
      ToastHelper.error('Failed to delete project: $e');
    }
  }

  Future<void> updateProject(
    String templateId,
    Map<String, dynamic> updates,
  ) async {
    if (!isAdmin.value) return;

    try {
      ToastHelper.loading('Updating project...');
      await _firestoreService.updateTemplate(templateId, updates);

      // Update local list
      final index = templates.indexWhere((t) => t.id == templateId);
      if (index != -1) {
        final updatedTemplate = templates[index].copyWith(
          name: updates['name'] ?? templates[index].name,
          category: updates['category'] ?? templates[index].category,
          categoryId: updates['categoryId'] ?? templates[index].categoryId,
        );
        templates[index] = updatedTemplate;
      }

      ToastHelper.dismissAll();
      ToastHelper.success('Project updated successfully');
    } catch (e) {
      ToastHelper.dismissAll();
      ToastHelper.error('Failed to update project: $e');
    }
  }

  List<CardTemplate> get filteredTemplates {
    if (searchQuery.value.isEmpty) {
      return templates;
    }
    return templates.where((template) {
      return template.name.toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          ) ||
          template.category.toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          ) ||
          template.id.toLowerCase().contains(searchQuery.value.toLowerCase());
    }).toList();
  }
}
