import 'dart:math' as math;

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class FontSearchController extends GetxController {
  final displayedFonts = <String>[].obs;
  final isLoading = false.obs;
  final hasMoreFonts = true.obs;
  final searchQuery = ''.obs;
  String selectedFont = '';

  List<String> _allFonts = [];
  List<String> _filteredFonts = [];
  static const int _fontsPerPage = 30;
  int _currentPage = 0;

  void initialize(String currentFont) {
    selectedFont = currentFont;
    _initializeFonts();
    _loadInitialFonts();
  }

  void _initializeFonts() {
    final googleFontsMap = GoogleFonts.asMap();
    _allFonts = googleFontsMap.keys.toList();
    _allFonts.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  }

  void _loadInitialFonts() {
    final endIndex = math.min(_fontsPerPage, _allFonts.length);
    displayedFonts.value = _allFonts.sublist(0, endIndex);
    _currentPage = 1;
    hasMoreFonts.value = endIndex < _allFonts.length;
  }

  void searchFonts(String query) {
    searchQuery.value = query;

    if (query.isEmpty) {
      _loadInitialFonts();
    } else {
      _filteredFonts = _allFonts
          .where((font) => font.toLowerCase().contains(query.toLowerCase()))
          .toList();

      displayedFonts.value = _filteredFonts.take(_fontsPerPage).toList();
      hasMoreFonts.value = _filteredFonts.length > _fontsPerPage;
      _currentPage = 1;
    }

    update();
  }

  void clearSearch() {
    searchQuery.value = '';
    _loadInitialFonts();
    update();
  }

  void selectFont(String font) {
    selectedFont = font;
    update();
  }

  void loadMoreFonts() {
    if (isLoading.value || !hasMoreFonts.value) return;

    isLoading.value = true;

    Future.delayed(const Duration(milliseconds: 300), () {
      final fontsToUse = searchQuery.isNotEmpty ? _filteredFonts : _allFonts;
      final startIndex = displayedFonts.length;
      final endIndex = math.min(startIndex + _fontsPerPage, fontsToUse.length);

      if (startIndex < fontsToUse.length) {
        final newFonts = fontsToUse.sublist(startIndex, endIndex);
        displayedFonts.addAll(newFonts);
        hasMoreFonts.value = endIndex < fontsToUse.length;
      } else {
        hasMoreFonts.value = false;
      }

      isLoading.value = false;
      update();
    });
  }
}
