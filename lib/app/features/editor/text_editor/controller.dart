import 'dart:math' as math;

import 'package:cardmaker/app/features/editor/controller.dart';
import 'package:cardmaker/core/values/enums.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/stack_board_item.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/stack_items.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class TextStyleController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final editorController = Get.find<CanvasController>();
  late final TabController tabController;

  // Tab control
  final currentIndex = 0.obs;
  final circularSubTabIndex = 0.obs;

  // Text item reference
  StackTextItem? textItem;

  // Text properties
  final selectedFont = 'Roboto'.obs;
  final fontSize = 16.0.obs;
  final letterSpacing = 0.0.obs;
  final lineHeight = 1.2.obs;
  final textAlign = TextAlign.left.obs;
  final textColor = Colors.black.obs;
  Color? textColorOld; //to keep track of textcolor when reset stroke effects
  final backgroundColor = Colors.transparent.obs;
  final fontWeight = FontWeight.normal.obs;
  final isItalic = false.obs;
  final isUnderlined = false.obs;
  String? maskImage;
  bool hasMask = false; // Make this reactive
  BlendMode maskBlendMode = BlendMode.srcATop;

  // Effects - Shadow
  final hasShadow = false.obs;
  final shadowOffset = const Offset(2, 2).obs;
  final shadowBlurRadius = 4.0.obs;
  final shadowColor = Colors.black54.obs;
  // Dual Tone properties (ADD THESE)
  final hasDualTone = false.obs;
  Color? dualToneColor1;
  Color? dualToneColor2;
  final dualToneDirection = DualToneDirection.horizontal.obs;
  final dualTonePosition = 0.5.obs; // 0.0 to 1.0 for gradient position
  // Effects - Stroke (NEW)
  final hasStroke = false.obs;
  final strokeWidth = 2.0.obs;

  final strokeColor = Colors.black.obs;
  String? selectedTemplateId;
  String? selectedDualToneTemplateId;

  // Circular text
  final isCircular = false.obs;
  final radius = 0.0.obs;
  final space = 10.0.obs;
  final startAngle = 0.0.obs;
  final startAngleAlignment = StartAngleAlignment.start.obs;
  final position = CircularTextPosition.inside.obs;
  final direction = CircularTextDirection.clockwise.obs;
  final showBackground = true.obs;
  final showStroke = false.obs;
  final backgroundPaintColor = Colors.grey.shade200.obs;
  // Arc text properties (NEW)

  //
  final isArabicFont = false.obs; // Add this
  final textDirection = TextDirection.ltr.obs; // Add this
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  List<String> _filteredFonts = [];
  bool _isSearching = false;
  final displayedFonts = <String>[].obs;
  final isLoadingMoreFonts = false.obs;
  final hasMoreFonts = true.obs;
  late List<String> _allGoogleFonts;
  static const int _fontsPerPage = 20;
  int _currentPage = 0;

  @override
  void onInit() {
    super.onInit();

    tabController = TabController(
      length: 10, // Increased to include Arabic font tab
      vsync: this,
      initialIndex: currentIndex.value,
    );
    tabController.addListener(() {
      currentIndex.value = tabController.index;
      update(['tab_view']);
    });
    _initializeGoogleFonts();
    _loadInitialFonts();
  }

  void _initializeGoogleFonts() {
    // Get all Google Fonts using asMap method
    final googleFontsMap = GoogleFonts.asMap();
    _allGoogleFonts = googleFontsMap.keys.toList();

    // Sort alphabetically for better UX
    _allGoogleFonts.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    print('Loaded ${_allGoogleFonts.length} Google Fonts');
  }

  void _loadInitialFonts() {
    if (_allGoogleFonts.isEmpty) return;

    final endIndex = math.min(_fontsPerPage, _allGoogleFonts.length);
    displayedFonts.value = _allGoogleFonts.sublist(0, endIndex);
    _currentPage = 1;

    hasMoreFonts.value = endIndex < _allGoogleFonts.length;
  }

  void searchFonts(String query) {
    searchQuery.value = query;

    if (query.isEmpty) {
      _isSearching = false;
      _loadInitialFonts(); // Reset to initial fonts
    } else {
      _isSearching = true;
      _filteredFonts = _allGoogleFonts
          .where((font) => font.toLowerCase().contains(query.toLowerCase()))
          .toList();

      // Show first 50 results to avoid performance issues
      displayedFonts.value = _filteredFonts.take(50).toList();
      hasMoreFonts.value = _filteredFonts.length > 50;
      _currentPage = 1;
    }

    update(['font_search', 'font_list']);
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    _isSearching = false;
    _loadInitialFonts(); // Reset to initial fonts
    update(['font_search', 'font_list']);
  }

  // Update the loadMoreFonts method to handle search results
  void loadMoreFonts() {
    if (isLoadingMoreFonts.value || !hasMoreFonts.value) return;

    isLoadingMoreFonts.value = true;

    // Simulate network delay for smooth UX
    Future.delayed(const Duration(milliseconds: 10), () {
      if (_isSearching) {
        // Load more filtered results
        final startIndex = displayedFonts.length;
        final endIndex = math.min(startIndex + 50, _filteredFonts.length);

        if (startIndex < _filteredFonts.length) {
          final newFonts = _filteredFonts.sublist(startIndex, endIndex);
          displayedFonts.addAll(newFonts);
          hasMoreFonts.value = endIndex < _filteredFonts.length;
        } else {
          hasMoreFonts.value = false;
        }
      } else {
        // Load more from all fonts (existing logic)
        final startIndex = _currentPage * _fontsPerPage;
        final endIndex = math.min(
          startIndex + _fontsPerPage,
          _allGoogleFonts.length,
        );

        if (startIndex < _allGoogleFonts.length) {
          final newFonts = _allGoogleFonts.sublist(startIndex, endIndex);
          displayedFonts.addAll(newFonts);
          _currentPage++;
          hasMoreFonts.value = endIndex < _allGoogleFonts.length;
        } else {
          hasMoreFonts.value = false;
        }
      }

      isLoadingMoreFonts.value = false;
      update(['font_list']);
    });
  }

  // static const predefinedColors = [
  //   Colors.transparent,
  //   Colors.black,
  //   Colors.white,
  //   Color(0xFF333333), // Dark grey
  //   Color(0xFF666666), // Medium grey
  //   Color(0xFF999999), // Light grey
  //   Color(0xFFCCCCCC), // Very light grey
  //   Colors.red,
  //   Color(0xFFFF6B6B), // Light red
  //   Color(0xFF8B0000), // Dark red
  //   Colors.pink,
  //   Color(0xFFFF69B4), // Hot pink
  //   Colors.orange,
  //   Color(0xFFFF8C00), // Dark orange
  //   Colors.amber,
  //   Colors.yellow,
  //   Color(0xFFFFD700), // Gold
  //   Colors.lime,
  //   Colors.green,
  //   Color(0xFF00FF7F), // Spring green
  //   Color(0xFF228B22), // Forest green
  //   Colors.teal,
  //   Color(0xFF00CED1), // Dark turquoise
  //   Colors.cyan,
  //   Color(0xFF87CEEB), // Sky blue
  //   Colors.blue,
  //   Color(0xFF4169E1), // Royal blue
  //   Color(0xFF191970), // Midnight blue
  //   Colors.indigo,
  //   Colors.purple,
  //   Color(0xFF9370DB), // Medium purple
  //   Color(0xFF8A2BE2), // Blue violet
  //   Colors.brown,
  //   Color(0xFFD2691E), // Chocolate
  // ];

  static const maskImages = [
    null, // "None" option - always first
    // Glitter masks
    'assets/gliter1.jpeg',
    'assets/gliter2.jpeg',
    'assets/gliter3.jpeg',
    'assets/gliter4.jpeg',
    // TODO: Add more stunning mask templates here
    // Recommended mask types:
    // - Gradient masks (rainbow, sunset, ocean)
    // - Texture masks (marble, wood, fabric)
    // - Pattern masks (geometric, floral, abstract)
    // - Effect masks (sparkle, glow, neon)
    // - Color masks (solid colors with patterns)
    // Example format: 'assets/masks/gradient_rainbow.png',
    // Example format: 'assets/masks/texture_marble.jpg',
  ];

  // Image picker for gallery selection
  final ImagePicker _imagePicker = ImagePicker();

  // Method to pick image from gallery
  Future<void> pickMaskImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) {
        hasMask = true;
        hasDualTone.value = false;
        maskImage = image.path; // Store file path for custom images
        if (backgroundColor.value != Colors.transparent) {
          backgroundColor(Colors.transparent);
        }
        updateTextItem();
        update(['mask_presets', 'mask_settings']);
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  final isArc = false.obs;
  final arcCurvature = 0.0.obs; // Changed to RxDouble for reactive updates

  void initializeProperties(StackTextItem? item) {
    textItem = item;
    final textContent = item?.content;
    selectedFont.value = textContent?.googleFont ?? 'Roboto';
    isArabicFont.value = textContent?.isArabicFont ?? false; // Initialize
    textDirection.value =
        textContent?.textDirection ??
        (textContent?.isArabicFont == true
            ? TextDirection.rtl
            : TextDirection.ltr);
    // ... initialize other properties ...
    textItem = item;
    selectedFont.value = textContent?.googleFont ?? 'Roboto';
    fontSize.value = textContent?.style?.fontSize ?? 16.0;
    letterSpacing.value = textContent?.style?.letterSpacing ?? 0.0;
    lineHeight.value = textContent?.style?.height ?? 1.2;
    textAlign.value = textContent?.textAlign ?? TextAlign.left;
    textColor.value = textContent?.style?.color ?? Colors.black;
    textColorOld = textContent?.style?.color;
    backgroundColor.value =
        textContent?.style?.backgroundColor ?? Colors.transparent;
    fontWeight.value = textContent?.style?.fontWeight ?? FontWeight.normal;
    isItalic.value = textContent?.style?.fontStyle == FontStyle.italic;
    isUnderlined.value =
        textContent?.style?.decoration == TextDecoration.underline;
    maskImage = textContent?.maskImage;
    hasMask = textContent?.hasMask ?? false;
    hasShadow.value = textContent?.style?.shadows?.isNotEmpty ?? false;
    if (hasShadow.value && textContent?.style?.shadows?.isNotEmpty == true) {
      shadowOffset.value = textContent!.style!.shadows![0].offset;
      shadowBlurRadius.value = textContent.style!.shadows![0].blurRadius;
      shadowColor.value = textContent.style!.shadows![0].color;
    }
    hasStroke.value = textContent?.hasStroke ?? false;
    strokeWidth.value = textContent?.strokeWidth ?? 2.0;
    strokeColor.value = textContent?.strokeColor ?? Colors.black;
    isCircular.value = textContent?.isCircular ?? false;
    radius.value = (textContent?.radius ?? 0) >= 50
        ? textContent!.radius!
        : 100.0;
    space.value = textContent?.space ?? 10.0;
    startAngle.value = textContent?.startAngle ?? 0.0;
    startAngleAlignment.value =
        textContent?.startAngleAlignment ?? StartAngleAlignment.start;
    position.value = textContent?.position ?? CircularTextPosition.inside;
    direction.value = textContent?.direction ?? CircularTextDirection.clockwise;
    showBackground.value = textContent?.showBackground ?? true;
    showStroke.value = textContent?.showStroke ?? false;
    strokeWidth.value = textContent!.strokeWidth;
    backgroundPaintColor.value =
        textContent.backgroundPaintColor ?? Colors.grey.shade200;
    isArc.value = textContent.isArc; // Add this line
    arcCurvature.value = textContent.arcCurvature ?? 0.0; // Add this line
  }

  void updateFont(String fontFamily, {bool isRTL = false}) {
    selectedFont.value = fontFamily;
    isArabicFont.value = isRTL;
    textDirection.value = isRTL ? TextDirection.rtl : TextDirection.ltr;
    updateTextItem();
    update(['font_family', 'urdu_font']);
  }

  // Update the updateTextItem method to include arc properties
  void updateTextItem() {
    final updatedContent = textItem?.content?.copyWith(
      hasDualTone: hasDualTone.value,
      dualToneColor1: dualToneColor1,
      dualToneColor2: dualToneColor2,
      dualToneDirection: dualToneDirection.value,
      dualTonePosition: dualTonePosition.value,
      data: textItem?.content?.data,
      googleFont: selectedFont.value,

      isArabicFont: isArabicFont.value, // Set isArabicFont
      textDirection: textDirection.value, // Set textDirection
      style: TextStyle(
        fontFamily: isArabicFont.value
            ? selectedFont.value
            : GoogleFonts.getFont(selectedFont.value).fontFamily,

        fontSize: fontSize.value,
        letterSpacing: letterSpacing.value,
        height: lineHeight.value,
        color: textColor.value,
        backgroundColor: backgroundColor.value,
        fontWeight: fontWeight.value,
        fontStyle: isItalic.value ? FontStyle.italic : FontStyle.normal,
        decoration: isUnderlined.value
            ? TextDecoration.underline
            : TextDecoration.none,
        shadows: hasShadow.value
            ? [
                Shadow(
                  offset: shadowOffset.value,
                  blurRadius: shadowBlurRadius.value,
                  color: shadowColor.value,
                ),
              ]
            : null,
      ),
      textAlign: textAlign.value,
      maskImage: maskImage,
      hasMask: hasMask,
      maskBlendMode: maskBlendMode,
      hasStroke: hasStroke.value,
      strokeWidth: strokeWidth.value,
      strokeColor: strokeColor.value,
      isCircular: isCircular.value,
      radius: radius.value,
      space: space.value,
      startAngle: startAngle.value,
      startAngleAlignment: startAngleAlignment.value,
      position: position.value,
      direction: direction.value,
      showBackground: showBackground.value,
      showStroke: showStroke.value,
      backgroundPaintColor: backgroundPaintColor.value,
      isArc: isArc.value, // Add this line
      arcCurvature: arcCurvature.value, // Add this line
    );

    if (updatedContent == null) return;

    final currentItem = editorController.boardController.getById(textItem!.id);
    final updatedItem = textItem?.copyWith(
      content: updatedContent,
      offset: currentItem?.offset,
    );

    editorController.boardController.updateItem(updatedItem!);
    editorController.boardController.updateBasic(
      updatedItem.id,
      status: StackItemStatus.idle,
      size: updatedItem.size,
      offset: updatedItem.offset,
    );

    if (updatedContent.isCircular) {
      final diameter = updatedContent.radius! * 2;
      editorController.boardController.updateBasic(
        updatedItem.id,
        status: StackItemStatus.selected,
        size: Size(diameter, diameter),
        offset: updatedItem.offset,
      );
    } else {
      final span = TextSpan(
        text: updatedContent.data,
        style: updatedContent.style,
      );
      final painter = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
        textAlign: updatedContent.textAlign ?? TextAlign.left,
        maxLines: null,
      );
      double maxWidth = editorController.scaledCanvasWidth.value * 0.9;
      painter.layout(
        maxWidth: maxWidth,
      ); //when there is not break line to the long text then size issues so we have to controll it inside the canvas
      // final width = painter.width.clamp(50.0, maxWidth);

      final width = painter.width + 10;
      final height = painter.height + 10;
      final size = Size(width, height);
      editorController.boardController.updateBasic(
        updatedItem.id,
        status: StackItemStatus.selected,
        size: updatedItem.content!.data!.length < 20 ? size : null,
        offset: updatedItem.offset,
      );
    }
  }

  void resetStrok() {
    textColor(textColorOld);
  }

  String weightToString(FontWeight weight) {
    switch (weight) {
      case FontWeight.w300:
        return 'Light';
      case FontWeight.normal:
        return 'Regular';
      case FontWeight.w500:
        return 'Medium';
      case FontWeight.w600:
        return 'SemiBold';
      case FontWeight.bold:
        return 'Bold';
      case FontWeight.w800:
        return 'ExtraBold';
      case FontWeight.w900:
        return 'Black';
      default:
        return 'Regular';
    }
  }

  @override
  void onClose() {
    super.onClose();
    tabController.dispose();
  }
}
