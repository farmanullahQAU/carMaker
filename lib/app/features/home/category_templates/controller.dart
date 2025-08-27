import 'dart:async';

import 'package:cardmaker/app/routes/app_routes.dart';
import 'package:cardmaker/models/card_template.dart';
import 'package:cardmaker/services/template_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryTemplatesController extends GetxController {
  final CategoryModel category;
  late final TemplateService _templateService;

  final RxList<CardTemplate> templates = <CardTemplate>[].obs;
  final RxList<CardTemplate> _allTemplates =
      <CardTemplate>[].obs; // Store all templates for search
  final RxBool isLoading = false.obs;
  final RxBool hasMoreData = true.obs;
  final RxString searchQuery = ''.obs;

  late final ScrollController scrollController;
  static const int _pageSize = 3;
  DocumentSnapshot? _lastDocument;
  Timer? _searchDebounce;

  CategoryTemplatesController(this.category);

  @override
  void onInit() {
    super.onInit();
    _templateService = Get.find<TemplateService>();
    scrollController = ScrollController();
    _setupScrollListener();
    loadTemplates();
  }

  @override
  void onClose() {
    scrollController.dispose();
    _searchDebounce?.cancel();
    templates.clear();
    _allTemplates.clear();
    super.onClose();
  }

  void _setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent * 0.8) {
        if (!isLoading.value && hasMoreData.value) {
          loadMoreTemplates();
        }
      }
    });
  }

  Future<void> loadTemplates({bool refresh = false}) async {
    if (isLoading.value && !refresh) return;

    isLoading.value = true;

    try {
      if (refresh) {
        templates.clear();
        _allTemplates.clear();
        _lastDocument = null;
        hasMoreData.value = true;
      }

      // Use the TemplateService method instead of direct Firestore calls
      final snapshot = await _templateService.getTemplatesPaginated(
        category: category.id,
        limit: _pageSize,
        startAfterDocument: _lastDocument,
      );

      if (snapshot.docs.isNotEmpty) {
        final newTemplates = snapshot.docs
            .map((doc) => CardTemplate.fromJson(doc.data()))
            .toList();

        templates.addAll(newTemplates);
        _allTemplates.addAll(newTemplates); // Store all templates
        _lastDocument = snapshot.docs.last;
        hasMoreData.value = snapshot.docs.length == _pageSize;
      } else {
        hasMoreData.value = false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load templates: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreTemplates() async {
    await loadTemplates();
  }

  void onSearchChanged(String query) {
    // Cancel previous debounce timer
    _searchDebounce?.cancel();

    // Set new debounce timer
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      searchQuery.value = query;
      _performSearch();
    });
  }

  void _performSearch() {
    if (searchQuery.value.isEmpty) {
      // Show all templates when search is empty
      templates.assignAll(_allTemplates);
      return;
    }

    final filtered = _allTemplates.where((template) {
      final searchLower = searchQuery.value.toLowerCase();
      return template.name.toLowerCase().contains(searchLower) ||
          template.tags.any((tag) => tag.toLowerCase().contains(searchLower));
    }).toList();

    templates.assignAll(filtered);
  }

  void onTemplateSelected(CardTemplate template) {
    Get.toNamed(Routes.editor, arguments: {'template': template});
  }

  Future<void> onRefresh() async {
    await loadTemplates(refresh: true);
  }
}

// import 'package:cardmaker/app/routes/app_routes.dart';
// import 'package:cardmaker/models/card_template.dart';
// import 'package:cardmaker/services/template_services.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class CategoryTemplatesController extends GetxController {
//   final CategoryModel category;
//   late final TemplateService _templateService;

//   final RxList<CardTemplate> templates = <CardTemplate>[].obs;
//   final RxBool isLoading = false.obs;
//   final RxBool hasMoreData = true.obs;
//   final RxString searchQuery = ''.obs;

//   late final ScrollController scrollController;
//   static const int _pageSize = 20;
//   DocumentSnapshot? _lastDocument;

//   CategoryTemplatesController(this.category);

//   @override
//   void onInit() {
//     super.onInit();
//     _templateService = Get.find<TemplateService>();
//     scrollController = ScrollController();
//     _setupScrollListener();
//     loadTemplates();
//   }

//   @override
//   void onClose() {
//     scrollController.dispose();
//     templates.clear();
//     super.onClose();
//   }

//   void _setupScrollListener() {
//     scrollController.addListener(() {
//       if (scrollController.position.pixels >=
//           scrollController.position.maxScrollExtent * 0.8) {
//         if (!isLoading.value && hasMoreData.value) {
//           loadMoreTemplates();
//         }
//       }
//     });
//   }

//   Future<void> loadTemplates({bool refresh = false}) async {
//     if (isLoading.value && !refresh) return;

//     isLoading.value = true;

//     try {
//       if (refresh) {
//         templates.clear();
//         _lastDocument = null;
//         hasMoreData.value = true;
//       }

//       // Use the TemplateService method instead of direct Firestore calls
//       final snapshot = await _templateService.getTemplatesPaginated(
//         category: category.id,
//         limit: _pageSize,
//         startAfterDocument: _lastDocument,
//       );

//       if (snapshot.docs.isNotEmpty) {
//         final newTemplates = snapshot.docs
//             .map((doc) => CardTemplate.fromJson(doc.data()))
//             .toList();

//         templates.addAll(newTemplates);
//         _lastDocument = snapshot.docs.last;
//         hasMoreData.value = snapshot.docs.length == _pageSize;
//       } else {
//         hasMoreData.value = false;
//       }
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Failed to load templates: $e',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red.shade100,
//         colorText: Colors.red.shade900,
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<void> loadMoreTemplates() async {
//     await loadTemplates();
//   }

//   void onSearchChanged(String query) {
//     searchQuery.value = query;
//     _performSearch();
//   }

//   void _performSearch() {
//     if (searchQuery.value.isEmpty) {
//       loadTemplates(refresh: true);
//       return;
//     }

//     final filtered = templates.where((template) {
//       final searchLower = searchQuery.value.toLowerCase();
//       return template.name.toLowerCase().contains(searchLower) ||
//           template.tags.any((tag) => tag.toLowerCase().contains(searchLower));
//     }).toList();

//     templates.assignAll(filtered);
//   }

//   void onTemplateSelected(CardTemplate template) {
//     Get.toNamed(Routes.editor, arguments: {'template': template});
//   }

//   Future<void> onRefresh() async {
//     await loadTemplates(refresh: true);
//   }
// }
