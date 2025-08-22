import 'package:cardmaker/app/features/editor/circular_text/model.dart';
import 'package:cardmaker/app/features/editor/controller.dart';
import 'package:cardmaker/app/features/editor/edit_item/view.dart';
import 'package:cardmaker/core/values/app_colors.dart';
import 'package:cardmaker/widgets/common/colors_selector.dart';
import 'package:cardmaker/widgets/common/compact_slider.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/stack_board_item.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/stack_items.dart';
import 'package:cardmaker/widgets/ruler_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

enum DualToneDirection { horizontal, vertical, diagonal, radial }

class StrokeText extends StatelessWidget {
  final String text;
  final Color strokeColor;
  final double strokeWidth;
  final TextStyle? textStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final TextScaler? textScaler;
  final TextOverflow? overflow;
  final int? maxLines;

  const StrokeText({
    super.key,
    required this.text,
    this.strokeColor = Colors.amber, // Default stroke color
    this.strokeWidth = 3, // Default stroke width
    this.textStyle,
    this.textAlign,
    this.textDirection,
    this.textScaler,
    this.overflow,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate proper size constraints for the text
    final defaultTextStyle = TextStyle(
      fontSize: textStyle?.fontSize ?? 24,
      color: textStyle?.color ?? Colors.black,
      fontFamily: textStyle?.fontFamily,
      fontWeight: textStyle?.fontWeight,
      fontStyle: textStyle?.fontStyle,
      letterSpacing: textStyle?.letterSpacing,
      wordSpacing: textStyle?.wordSpacing,
      height: textStyle?.height,
    );

    // Create a TextPainter to measure the text
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: defaultTextStyle),
      textAlign: textAlign ?? TextAlign.start,
      textDirection: textDirection ?? TextDirection.ltr,
      textScaler: textScaler ?? TextScaler.noScaling,
      maxLines: maxLines,
      ellipsis: overflow == TextOverflow.ellipsis ? '...' : null,
    );

    // Layout the text with constraints to get proper size
    textPainter.layout(minWidth: 0, maxWidth: double.infinity);

    // Add stroke width padding to prevent clipping
    final additionalWidth = strokeWidth * 2;
    final additionalHeight = strokeWidth * 2;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the actual size needed
        double width = textPainter.width + additionalWidth;
        double height = textPainter.height + additionalHeight;

        // Respect parent constraints
        if (constraints.maxWidth != double.infinity) {
          width = width.clamp(0.0, constraints.maxWidth);
        }
        if (constraints.maxHeight != double.infinity) {
          height = height.clamp(0.0, constraints.maxHeight);
        }

        return SizedBox(
          width: width,
          height: height,
          child: CustomPaint(
            size: Size(width, height),
            painter: _TextPainterWithStroke(
              text: text,
              strokeColor: strokeColor,
              strokeWidth: strokeWidth,
              textStyle: textStyle,
              textAlign: textAlign,
              textDirection: textDirection,
              textScaler: textScaler,
              overflow: overflow,
              maxLines: maxLines,
            ),
          ),
        );
      },
    );
  }
}

class _TextPainterWithStroke extends CustomPainter {
  final String text;
  final Color strokeColor;
  final double strokeWidth;
  final TextStyle? textStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final TextScaler? textScaler;
  final TextOverflow? overflow;
  final int? maxLines;

  _TextPainterWithStroke({
    required this.text,
    required this.strokeColor,
    required this.strokeWidth,
    this.textStyle,
    this.textAlign,
    this.textDirection,
    this.textScaler,
    this.overflow,
    this.maxLines,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (text.isEmpty || size.width <= 0 || size.height <= 0) return;

    const defaultTextStyle = TextStyle(fontSize: 24, color: Colors.black);

    final mergedTextStyle = defaultTextStyle.merge(textStyle);

    // Create stroke text style
    final strokeTextStyle = mergedTextStyle.copyWith(
      foreground: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = strokeColor,
    );

    // Create main text style
    final mainTextStyle = mergedTextStyle.copyWith(
      color: mergedTextStyle.color ?? Colors.black,
    );

    // Create stroke text painter
    final strokePainter = TextPainter(
      text: TextSpan(text: text, style: strokeTextStyle),
      textAlign: textAlign ?? TextAlign.start,
      textDirection: textDirection ?? TextDirection.ltr,
      textScaler: textScaler ?? TextScaler.noScaling,
      maxLines: maxLines,
      ellipsis: overflow == TextOverflow.ellipsis ? '...' : null,
    );

    // Create main text painter
    final mainTextPainter = TextPainter(
      text: TextSpan(text: text, style: mainTextStyle),
      textAlign: textAlign ?? TextAlign.start,
      textDirection: textDirection ?? TextDirection.ltr,
      textScaler: textScaler ?? TextScaler.noScaling,
      maxLines: maxLines,
      ellipsis: overflow == TextOverflow.ellipsis ? '...' : null,
    );

    // Layout with available width minus stroke padding
    final maxWidth = (size.width - strokeWidth * 2).clamp(0.0, double.infinity);

    strokePainter.layout(minWidth: 0, maxWidth: maxWidth);
    mainTextPainter.layout(minWidth: 0, maxWidth: maxWidth);

    // Calculate offset based on alignment and available space
    final offset = _calculateOffset(strokePainter, size);

    // Draw the stroke first
    strokePainter.paint(canvas, offset);

    // Then draw the main text
    mainTextPainter.paint(canvas, offset);
  }

  // Helper method to calculate the offset based on text alignment
  Offset _calculateOffset(TextPainter painter, Size size) {
    // Add stroke width as padding
    final paddingX = strokeWidth;
    final paddingY = strokeWidth;

    switch (textAlign ?? TextAlign.start) {
      case TextAlign.center:
        return Offset(
          ((size.width - painter.width) / 2).clamp(
            paddingX,
            size.width - paddingX,
          ),
          ((size.height - painter.height) / 2).clamp(
            paddingY,
            size.height - paddingY,
          ),
        );
      case TextAlign.end:
      case TextAlign.right:
        return Offset(
          (size.width - painter.width - paddingX).clamp(
            paddingX,
            size.width - paddingX,
          ),
          ((size.height - painter.height) / 2).clamp(
            paddingY,
            size.height - paddingY,
          ),
        );
      case TextAlign.left:
      case TextAlign.start:
      case TextAlign.justify:
      default:
        return Offset(
          paddingX,
          ((size.height - painter.height) / 2).clamp(
            paddingY,
            size.height - paddingY,
          ),
        );
    }
  }

  @override
  bool shouldRepaint(covariant _TextPainterWithStroke oldDelegate) {
    return text != oldDelegate.text ||
        strokeColor != oldDelegate.strokeColor ||
        strokeWidth != oldDelegate.strokeWidth ||
        textStyle != oldDelegate.textStyle ||
        textAlign != oldDelegate.textAlign ||
        textDirection != oldDelegate.textDirection ||
        textScaler != oldDelegate.textScaler ||
        overflow != oldDelegate.overflow ||
        maxLines != oldDelegate.maxLines;
  }
}

class TextStyleController extends GetxController {
  final editorController = Get.find<CanvasController>();

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
  final maskImage = Rx<String?>(null);

  var maskOpacity = (1.0).obs;

  // New mask properties for advanced settings
  final maskScale = 1.0.obs;
  final maskRotation = 0.0.obs;
  final maskPositionX = 0.0.obs;
  final maskPositionY = 0.0.obs;
  final maskBlendMode = BlendMode.dstATop.obs;
  final maskTileMode = TileMode.clamp.obs;

  // Add this method to reset mask settings
  void resetMaskSettings() {
    maskOpacity.value = 1.0;
    maskScale.value = 1.0;
    maskRotation.value = 0.0;
    maskPositionX.value = 0.0;
    maskPositionY.value = 0.0;
    maskBlendMode.value = BlendMode.dstATop;
    maskTileMode.value = TileMode.clamp;
    updateTextItem();
  }

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

  static const popularFonts = [
    'Roboto',
    'Poppins',
    'Inter',
    'Montserrat',
    'Lato',
    'Open Sans',
    'Nunito',
    'Raleway',
    'Playfair Display',
    'Merriweather',
  ];

  static const predefinedColors = [
    Colors.transparent,
    Colors.black,
    Colors.white,
    Color(0xFF333333), // Dark grey
    Color(0xFF666666), // Medium grey
    Color(0xFF999999), // Light grey
    Color(0xFFCCCCCC), // Very light grey
    Colors.red,
    Color(0xFFFF6B6B), // Light red
    Color(0xFF8B0000), // Dark red
    Colors.pink,
    Color(0xFFFF69B4), // Hot pink
    Colors.orange,
    Color(0xFFFF8C00), // Dark orange
    Colors.amber,
    Colors.yellow,
    Color(0xFFFFD700), // Gold
    Colors.lime,
    Colors.green,
    Color(0xFF00FF7F), // Spring green
    Color(0xFF228B22), // Forest green
    Colors.teal,
    Color(0xFF00CED1), // Dark turquoise
    Colors.cyan,
    Color(0xFF87CEEB), // Sky blue
    Colors.blue,
    Color(0xFF4169E1), // Royal blue
    Color(0xFF191970), // Midnight blue
    Colors.indigo,
    Colors.purple,
    Color(0xFF9370DB), // Medium purple
    Color(0xFF8A2BE2), // Blue violet
    Colors.brown,
    Color(0xFFD2691E), // Chocolate
  ];

  static const maskImages = [
    'assets/gliter1.jpeg',
    'assets/gliter2.jpeg',
    'assets/gliter3.jpeg',
    'assets/gliter4.jpeg',
  ];

  void initializeProperties(StackTextItem? item) {
    textItem = item;

    final textContent = item?.content;
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

    // Only initialize image mask, ignore color mask
    maskImage.value = textContent?.maskImage;

    // Initialize shadow properties
    hasShadow.value = textContent?.style?.shadows?.isNotEmpty ?? false;
    if (hasShadow.value && textContent?.style?.shadows?.isNotEmpty == true) {
      shadowOffset.value = textContent!.style!.shadows![0].offset;
      shadowBlurRadius.value = textContent.style!.shadows![0].blurRadius;
      shadowColor.value = textContent.style!.shadows![0].color;
    }

    // Initialize stroke properties
    hasStroke.value = textContent?.hasStroke ?? false;
    strokeWidth.value = textContent?.strokeWidth ?? 2.0;
    strokeColor.value = textContent?.strokeColor ?? Colors.black;

    // Initialize circular text properties
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

    // Initialize dual tone properties (ADD THESE)
    hasDualTone.value = textContent.hasDualTone ?? false;
    dualToneColor1 = textContent.dualToneColor1 ?? Colors.red;
    dualToneColor2 = textContent.dualToneColor2 ?? Colors.blue;
    dualToneDirection.value =
        textContent.dualToneDirection ?? DualToneDirection.horizontal;
    dualTonePosition.value = textContent.dualTonePosition ?? 0.5;
  }

  void updateTextItem() {
    // final item = textItem.value;
    // if (item == null) return;

    final updatedContent = textItem?.content?.copyWith(
      // Add dual tone properties
      hasDualTone: hasDualTone.value,
      dualToneColor1: dualToneColor1,
      dualToneColor2: dualToneColor2,
      dualToneDirection: dualToneDirection.value,
      dualTonePosition: dualTonePosition.value,

      data: textItem?.content?.data,
      googleFont: selectedFont.value,
      style: TextStyle(
        fontFamily: GoogleFonts.getFont(selectedFont.value).fontFamily,
        fontSize: fontSize.value,
        letterSpacing: letterSpacing.value,
        height: lineHeight.value,
        // Only make text transparent if image mask is applied
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
      maskImage: maskImage.value,
      maskBlendMode: maskBlendMode.value,
      // Stroke properties
      hasStroke: hasStroke.value,
      strokeWidth: strokeWidth.value,
      strokeColor: strokeColor.value,

      // Circular text properties
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

    if (!updatedContent.isCircular) {
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

      const double maxWidth = 800.0;
      painter.layout(maxWidth: maxWidth);

      final width = painter.width.clamp(50.0, maxWidth);
      final height = painter.height.clamp(25.0, double.infinity);

      editorController.boardController.updateBasic(
        updatedItem.id,
        status: StackItemStatus.selected,
        size: Size(width, height),
        offset: updatedItem.offset,
      );
    } else {
      final diameter = updatedContent.radius! * 2;
      editorController.boardController.updateBasic(
        updatedItem.id,
        status: StackItemStatus.selected,
        size: Size(diameter, diameter),
        offset: updatedItem.offset,
      );
    }
  }

  resetStrok() {
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
      case FontWeight.bold:
        return 'Bold';
      default:
        return 'Regular';
    }
  }
}

class TextStylingEditor extends StatefulWidget {
  final StackTextItem textItem;
  final VoidCallback onClose;

  const TextStylingEditor({
    super.key,
    required this.textItem,
    required this.onClose,
  });

  @override
  State<TextStylingEditor> createState() => _TextStylingEditorState();
}

class _TextStylingEditorState extends State<TextStylingEditor>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late final TabController _circularSubTabController;
  final TextStyleController _controller = Get.put(TextStyleController());

  @override
  void dispose() {
    _tabController.dispose();
    _circularSubTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surfaceContainerHigh,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [_buildTabBar(), _buildTabView()],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller.initializeProperties(widget.textItem);

    _circularSubTabController = TabController(length: 8, vsync: this);
    _circularSubTabController.addListener(() {
      _controller.circularSubTabIndex.value = _circularSubTabController.index;
    });

    _tabController = TabController(
      length: 12,
      vsync: this,
      initialIndex: _controller.currentIndex.value,
    );
    _tabController.addListener(() {
      _controller.currentIndex.value = _tabController.index;
      _controller.update(['tab_view']);
    });
  }

  Widget _buildTabBar() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.branding, width: 0.1),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Get.to(() => UpdateTextView(item: _controller.textItem));
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 12),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.branding.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.branding.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.keyboard_alt,
                color: AppColors.branding.withOpacity(0.7),
                size: 20,
              ),
            ),
          ),
          Expanded(
            child: TabBar(
              controller: _tabController,
              tabAlignment: TabAlignment.start,
              isScrollable: true,
              indicator: const BoxDecoration(),
              dividerHeight: 0,
              dividerColor: Colors.transparent,
              indicatorColor: Colors.transparent,
              padding: EdgeInsets.zero,
              indicatorPadding: EdgeInsets.zero,
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),

              tabs: [
                const Tab(
                  icon: Icon(Icons.format_size, size: 16),
                  text: 'Size',
                ),
                const Tab(
                  icon: Icon(Icons.format_align_left, size: 16),
                  text: 'Align',
                ),
                const Tab(icon: Icon(Icons.palette, size: 16), text: 'Color'),
                const Tab(
                  icon: Icon(Icons.format_color_fill, size: 16),
                  text: 'BG',
                ),
                const Tab(
                  icon: Icon(Icons.format_bold, size: 16),
                  text: 'Style',
                ),
                const Tab(icon: Icon(Icons.tune, size: 16), text: 'Spacing'),
                const Tab(
                  icon: Icon(Icons.font_download, size: 16),
                  text: 'Font',
                ),
                const Tab(icon: Icon(Icons.image, size: 16), text: 'Mask'),
                const Tab(icon: Icon(Icons.blur_on, size: 16), text: 'Effects'),
                const Tab(
                  icon: Icon(Icons.gradient, size: 16),
                  text: 'Dual',
                ), // ADD THIS
                const Tab(icon: Icon(Icons.circle, size: 16), text: 'Circular'),
                FloatingActionButton.small(
                  onPressed: () {
                    _controller.editorController.duplicateItem();
                  },

                  child: Icon(Icons.control_point_duplicate, size: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabView() {
    return GetBuilder<TextStyleController>(
      id: 'tab_view',
      builder: (controller) {
        return AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: SizedBox(
            height: _getTabHeight(controller.currentIndex.value),
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _tabController,

              children: [
                _SizeTab(controller: controller),
                _AlignmentTab(controller: controller),
                _ColorTab(controller: controller),
                _BackgroundTab(controller: controller),
                _StyleTab(controller: controller),
                _SpacingTab(controller: controller),
                _FontTab(controller: controller),
                _MaskTab(controller: controller),
                _EffectsTab(controller: controller),
                _DualToneTuneTab(controller: controller), // ADD THIS
                _CircularTab(
                  controller: controller,
                  tabController: _circularSubTabController,
                ),
                SizedBox(),
              ],
            ),
          ),
        );
      },
    );
  }

  double _getTabHeight(int index) {
    switch (index) {
      case 0: // Size
        return 80;
      case 1: // Align
        return 80;
      case 2: // Color
        return 80;
      case 3: // Background
        return 100;
      case 4: // Style
        return 100;
      case 5: // Spacing
        return 120;
      case 6: // Font
        return 160;
      case 7: // Mask
        return 120;
      case 8: // Effects
        return 120;
      case 9: // Dual Tone - ADD THIS CASE
        return 120;
      case 10: // Circular - CHANGE: was case 9, now case 10
        return 250;
      case 11:
        return 1;
      default:
        return 120;
    }
  }
}

// SIZE TAB - Modern with compact design
class _SizeTab extends StatelessWidget {
  final TextStyleController controller;
  const _SizeTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: GetBuilder<TextStyleController>(
        id: 'font_size',
        builder: (controller) {
          return SizedBox(
            child: RulerSlider(
              rulerHeight: 80.0,
              minValue: 8.0,
              maxValue: 72.0,
              initialValue: controller.fontSize.value,

              selectedBarColor: AppColors.brandingLight,
              unselectedBarColor: AppColors.highlight.withOpacity(0.3),
              // tickSpacing: 8.0,
              fixedBarColor: AppColors.accent,
              fixedLabelColor: AppColors.brandingLight,
              labelBuilder: (value) => '${value.round()}px',
              onChanged: (value) {
                controller.fontSize.value = value;
                controller.updateTextItem();
                controller.update(['font_size']);
              },
              // showFixedBar: true,
              // showFixedLabel: false,
              // scrollSensitivity: 0.9,
              // enableSnapping: false,
              // majorTickInterval: 10,
              // labelInterval: 10,
              // labelVerticalOffset: 16.0,
              // showBottomLabels: true,
              // labelTextStyle: Get.theme.textTheme.labelSmall!.copyWith(
              //   fontSize: 10,
              //   color: AppColors.highlight,
              // ),
              majorTickHeight: 12.0,
              // minorTickHeight: 6.0,
            ),
          );
        },
      ),
    );
  }
}

// ALIGNMENT TAB - Compact grid layout
class _AlignmentTab extends StatelessWidget {
  final TextStyleController controller;
  const _AlignmentTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TextStyleController>(
      id: 'text_align',
      builder: (controller) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAlignmentButton(
                icon: Icons.format_align_left_rounded,
                alignment: TextAlign.left,
                isSelected: controller.textAlign.value == TextAlign.left,
                controller: controller,
              ),
              _buildAlignmentButton(
                icon: Icons.format_align_center_rounded,
                alignment: TextAlign.center,
                isSelected: controller.textAlign.value == TextAlign.center,
                controller: controller,
              ),
              _buildAlignmentButton(
                icon: Icons.format_align_right_rounded,
                alignment: TextAlign.right,
                isSelected: controller.textAlign.value == TextAlign.right,
                controller: controller,
              ),
              _buildAlignmentButton(
                icon: Icons.format_align_justify_rounded,
                alignment: TextAlign.justify,
                isSelected: controller.textAlign.value == TextAlign.justify,
                controller: controller,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAlignmentButton({
    required IconData icon,
    required TextAlign alignment,
    required bool isSelected,
    required TextStyleController controller,
  }) {
    return GestureDetector(
      onTap: () {
        controller.textAlign.value = alignment;
        controller.updateTextItem();
        controller.update(['text_align']);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40.0,
        height: 40.0,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.branding : Colors.transparent,
          borderRadius: BorderRadius.circular(6.0),
          border: Border.all(
            color: isSelected
                ? AppColors.branding
                : AppColors.highlight.withOpacity(0.2),
            width: 1.0,
          ),
        ),
        child: Icon(
          icon,
          size: 20.0,
          color: isSelected ? Colors.white : AppColors.highlight,
        ),
      ),
    );
  }
}

// COLOR TAB - Optimized spacing
class _ColorTab extends StatelessWidget {
  final TextStyleController controller;
  const _ColorTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GetBuilder<TextStyleController>(
        id: 'text_color',
        builder: (controller) {
          return ColorSelector(
            title: "Text Color",
            showTitle: false,
            paddingx: 16,
            colors: TextStyleController.predefinedColors,
            currentColor: controller.textColor.value,
            onColorSelected: (color) {
              controller.textColor.value = color;
              controller.textColorOld = color;
              controller.maskImage.value = null;
              controller.updateTextItem();
              controller.update(['text_color', 'mask']);
            },
          );
        },
      ),
    );
  }
}

// BACKGROUND TAB - Optimized with clear option
class _BackgroundTab extends StatelessWidget {
  final TextStyleController controller;
  const _BackgroundTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: GetBuilder<TextStyleController>(
        id: 'background_color',
        builder: (controller) {
          return ColorSelector(
            title: "Bg Color",
            showTitle: true,

            colors: TextStyleController.predefinedColors,
            currentColor: controller.backgroundColor.value,
            onColorSelected: (color) {
              controller.backgroundColor.value = color;
              controller.updateTextItem();
              controller.update(['background_color']);
            },
            selectedBorderColor: AppColors.background,
            itemSize: 35,
          );
          // return GridView.builder(
          //   shrinkWrap: true,
          //   physics: const NeverScrollableScrollPhysics(),
          //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          //     crossAxisCount: 8,
          //     crossAxisSpacing: 6,
          //     mainAxisSpacing: 6,
          //     childAspectRatio: 1,
          //   ),
          //   itemCount:
          //       TextStyleController.predefinedColors.length +
          //       1, // +1 for clear option
          //   itemBuilder: (context, index) {
          //     if (index == 0) {
          //       // Clear/Transparent option
          //       final isSelected =
          //           controller.backgroundColor.value == Colors.transparent;
          //       return GestureDetector(
          //         onTap: () {
          //           controller.backgroundColor.value = Colors.transparent;
          //           controller.updateTextItem();
          //           controller.update(['background_color']);
          //         },
          //         child: Container(
          //           decoration: BoxDecoration(
          //             color: Colors.white,
          //             shape: BoxShape.circle,
          //             border: Border.all(
          //               color: isSelected
          //                   ? AppColors.accent
          //                   : AppColors.highlight.withOpacity(0.3),
          //               width: isSelected ? 3 : 1,
          //             ),
          //           ),
          //           child: Icon(
          //             Icons.clear,
          //             color: isSelected
          //                 ? AppColors.accent
          //                 : AppColors.highlight.withOpacity(0.6),
          //             size: 14,
          //           ),
          //         ),
          //       );
          //     }

          //     final color = TextStyleController.predefinedColors[index - 1];
          //     final isSelected = color == controller.backgroundColor.value;

          //     return GestureDetector(
          //       onTap: () {
          //         controller.backgroundColor.value = color;
          //         controller.updateTextItem();
          //         controller.update(['background_color']);
          //       },
          //       child: Container(
          //         decoration: BoxDecoration(
          //           color: color,
          //           shape: BoxShape.circle,
          //           border: Border.all(
          //             color: isSelected
          //                 ? AppColors.accent
          //                 : AppColors.highlight.withOpacity(0.3),
          //             width: isSelected ? 3 : 1,
          //           ),
          //         ),
          //         child: isSelected
          //             ? Icon(
          //                 Icons.check,
          //                 color: color.computeLuminance() > 0.5
          //                     ? Colors.black
          //                     : Colors.white,
          //                 size: 14,
          //               )
          //             : null,
          //       ),
          //     );
          //   },
          // );
        },
      ),
    );
  }
}

// STYLE TAB - Compact button layout
class _StyleTab extends StatelessWidget {
  final TextStyleController controller;
  const _StyleTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: GetBuilder<TextStyleController>(
        id: 'text_style',
        builder: (controller) {
          return Column(
            children: [
              // Font weights - radio buttons
              Row(
                spacing: 12,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _fontWeights.map((weight) {
                  final isSelected = weight == controller.fontWeight.value;
                  return GestureDetector(
                    onTap: () {
                      controller.fontWeight.value = weight;
                      controller.updateTextItem();
                      controller.update(['text_style']);
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.branding
                                  : AppColors.highlight.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? AppColors.branding
                                    : Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getWeightLabel(weight),
                          style: TextStyle(
                            color: AppColors.highlight,
                            fontWeight: weight,
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8.0),
              // Style buttons (italic/underline)
              Row(
                children: [
                  _buildStyleButton(
                    icon: Icons.format_italic_rounded,
                    label: 'Italic',
                    isActive: controller.isItalic.value,
                    onTap: () {
                      controller.isItalic.value = !controller.isItalic.value;
                      controller.updateTextItem();
                      controller.update(['text_style']);
                    },
                  ),
                  const SizedBox(width: 8.0),
                  _buildStyleButton(
                    icon: Icons.format_underline_rounded,
                    label: 'Underline',
                    isActive: controller.isUnderlined.value,
                    onTap: () {
                      controller.isUnderlined.value =
                          !controller.isUnderlined.value;
                      controller.updateTextItem();
                      controller.update(['text_style']);
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStyleButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 36.0,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.accent
                : AppColors.highlight.withOpacity(0.05),
            borderRadius: BorderRadius.circular(6.0),
            border: Border.all(
              color: isActive
                  ? AppColors.accent
                  : AppColors.highlight.withOpacity(0.1),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16.0,
                color: isActive ? Colors.white : AppColors.highlight,
              ),
              const SizedBox(width: 4.0),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : AppColors.highlight,
                  fontSize: 12.0,
                  fontStyle: label == 'Italic' && isActive
                      ? FontStyle.italic
                      : FontStyle.normal,
                  decoration: label == 'Underline' && isActive
                      ? TextDecoration.underline
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const List<FontWeight> _fontWeights = [
    FontWeight.w300,
    FontWeight.normal,
    FontWeight.w500,
    FontWeight.bold,
  ];

  String _getWeightLabel(FontWeight weight) {
    switch (weight) {
      case FontWeight.w300:
        return 'Light';
      case FontWeight.normal:
        return 'Regular';
      case FontWeight.w500:
        return 'Medium';
      case FontWeight.bold:
        return 'Bold';
      default:
        return '';
    }
  }
}
// SPACING TAB - Compact sliders

class _SpacingTab extends StatelessWidget {
  // Spacing constants
  static const double _sectionSpacing = 16.0;
  static const double _cardPaddingH = 16.0;
  static const double _cardPaddingV = 12.0;
  static const double _cardBorderRadius = 12.0;

  final TextStyleController controller;

  const _SpacingTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GetBuilder<TextStyleController>(
            id: 'letter_spacing',

            builder: (context) {
              return CompactSlider(
                icon: Icons.space_bar_rounded,
                label: 'Letter Spacing',
                value: controller.letterSpacing.value,
                min: -3,
                max: 32.0,

                onChanged: (value) {
                  controller.letterSpacing.value = value;
                  controller.updateTextItem();
                  controller.update(['letter_spacing']);
                },
              );
            },
          ),

          const SizedBox(height: _sectionSpacing),
          GetBuilder<TextStyleController>(
            id: 'line_height',

            builder: (context) {
              return CompactSlider(
                icon: Icons.height_rounded,
                label: 'Line Height',
                value: controller.lineHeight.value,
                min: 0.8,
                max: 3.0,

                onChanged: (value) {
                  controller.lineHeight.value = value;
                  controller.updateTextItem();
                  controller.update(['line_height']);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSliderCard({
    required BuildContext context,
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _cardPaddingH,
        vertical: _cardPaddingV,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 6.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// FONT TAB - Compact chip layout
class _FontTab extends StatelessWidget {
  final TextStyleController controller;
  const _FontTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: GetBuilder<TextStyleController>(
        id: 'font_family',
        builder: (controller) {
          return Center(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TextStyleController.popularFonts.map((font) {
                final isSelected = font == controller.selectedFont.value;
                return ChoiceChip(
                  onSelected: (v) {
                    controller.selectedFont.value = font;
                    controller.updateTextItem();
                    controller.update(['font_family']);
                  },
                  selected: isSelected,
                  selectedColor: AppColors.branding,
                  backgroundColor: Get.theme.colorScheme.surfaceContainerHigh,
                  shape: RoundedRectangleBorder(
                    side: BorderSide.none,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  showCheckmark: false,
                  visualDensity: VisualDensity.comfortable,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  label: Text(
                    font,
                    style: GoogleFonts.getFont(font, fontSize: 14),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}

// MASK TAB - Fixed implementation with proper organization
class _MaskTab extends StatelessWidget {
  final TextStyleController controller;
  const _MaskTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Mask presets in a horizontal list (including "None" option)
        _buildMaskPresets(),
      ],
    );
  }

  Widget _buildMaskPresets() {
    return SizedBox(
      height: 100,
      child: GetBuilder<TextStyleController>(
        id: 'mask_presets',
        builder: (controller) {
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount:
                TextStyleController.maskImages.length + 1, // +1 for "None"
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildNoMaskOption();
              }
              final image = TextStyleController.maskImages[index - 1];
              return _buildMaskOption(image);
            },
          );
        },
      ),
    );
  }

  Widget _buildNoMaskOption() {
    final isSelected = controller.maskImage.value == null;
    return GestureDetector(
      onTap: () => _clearMask(controller),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 88,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.branding.withOpacity(0.08)
              : Get.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppColors.branding, width: 0.4)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.layers_clear,
                size: 28,
                color: isSelected
                    ? AppColors.branding
                    : Get.theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'None',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.branding : Colors.grey.shade800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaskOption(String image) {
    final isSelected = image == controller.maskImage.value;
    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: () => _selectImageMask(controller, image),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 88,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.branding.withOpacity(0.08)
                  : Get.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: AppColors.branding, width: 0.4)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        color: Get.theme.colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image_not_supported,
                              color: Colors.grey.shade600,
                            );
                          },
                        ),
                      ),
                    ),

                    if (isSelected)
                      Container(
                        child: GestureDetector(
                          onTap: () {
                            _showMaskTuneBottomSheet(Get.context!);
                          },
                          child: Container(
                            height: 56,
                            width: 56,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.tune, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Mask ${TextStyleController.maskImages.indexOf(image) + 1}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? AppColors.branding
                        : Colors.grey.shade800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showMaskTuneBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: null,
      elevation: 0,
      builder: (context) => MaskTuneBottomSheet(controller: controller),
    );
  }

  void _clearMask(TextStyleController controller) {
    controller.maskImage.value = null;
    controller.updateTextItem();
    controller.update(['mask_presets', 'mask_settings']);
  }

  void _selectImageMask(TextStyleController controller, String image) {
    controller.maskImage.value = image;
    controller.updateTextItem();
    controller.update(['mask_presets', 'mask_settings']);
  }
}

class MaskTuneBottomSheet extends StatelessWidget {
  final TextStyleController controller;

  const MaskTuneBottomSheet({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: Get.width,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandleBar(),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_buildMaskProperties()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandleBar() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      height: 5,
      width: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildMaskProperties() {
    return GetBuilder<TextStyleController>(
      id: "mask_properties",
      builder: (controller) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Get.theme.shadowColor.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Blend Mode Radio Buttons
              _buildBlendModeSelector(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBlendModeSelector() {
    final blendModes = [
      {'mode': BlendMode.srcATop, 'name': 'Src A Top'},
      {'mode': BlendMode.dstATop, 'name': 'Dst A Top'},
    ];

    return GetBuilder<TextStyleController>(
      id: 'mask_blend_mode',
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.layers,
                  color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Blend Mode',
                  style: TextStyle(
                    fontSize: 14,
                    color: Get.theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: blendModes.map((blendModeData) {
                final mode = blendModeData['mode'] as BlendMode;
                final name = blendModeData['name'] as String;
                final isSelected = controller.maskBlendMode.value == mode;

                return GestureDetector(
                  onTap: () {
                    controller.maskBlendMode.value = mode;
                    controller.updateTextItem();
                    controller.update(['mask_properties', 'mask_blend_mode']);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.branding.withOpacity(0.1)
                          : Get.theme.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.branding
                            : Get.theme.colorScheme.outline.withOpacity(0.3),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.branding
                                  : Get.theme.colorScheme.outline.withOpacity(
                                      0.5,
                                    ),
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? Center(
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.branding,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? AppColors.branding
                                : Get.theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

class _EffectsTab extends StatelessWidget {
  static const List<EffectTemplate> effectTemplates = [
    EffectTemplate(
      id: 'none',
      name: 'None',
      icon: Icons.format_clear,
      hasShadow: false,
      hasStroke: false,
      fontSize: 16.0,
    ),
    EffectTemplate(
      id: 'basic_stroke',
      name: 'Basic Stroke',
      icon: Icons.border_color,
      hasShadow: true,
      hasStroke: true,
      strokeWidth: 2.0,
      strokeColor: Colors.black,
      textColor: Colors.white,
      fontSize: 22.0,
    ),
    EffectTemplate(
      id: 'thick_stroke',
      name: 'Thick Stroke',
      icon: Icons.format_paint,
      hasShadow: false,
      hasStroke: true,
      strokeWidth: 4.0,
      strokeColor: Colors.blue,
      textColor: Colors.white,

      fontSize: 16.0,
    ),
    EffectTemplate(
      id: 'colored_stroke',
      name: 'Color Stroke',
      icon: Icons.palette,
      hasShadow: false,
      hasStroke: true,
      strokeWidth: 3.0,
      strokeColor: Color(0xFFFF5722),
      textColor: Colors.white,
      fontSize: 16.0,
    ),
    EffectTemplate(
      id: 'neon_stroke',
      name: 'Neon Stroke',
      icon: Icons.flash_on,
      hasShadow: false,
      shadowOffset: Offset(0, 0),
      shadowBlur: 10.0,
      shadowColor: Color(0xFF00E676),
      hasStroke: true,
      strokeWidth: 1.0,
      strokeColor: Color(0xFF00E676),
      textColor: Colors.blue,
      fontSize: 33.0,
    ),
  ];
  final TextStyleController controller;
  const _EffectsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPresetCards(),

          /* stunning tabbar
          Container(
            height: 33,
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(25),
            ),
            margin: EdgeInsets.symmetric(horizontal: Get.width * 0.2),
            child: TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              dividerHeight: 0,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: AppColors.branding,
              ),
              labelColor: Colors.white,
              // unselectedLabelColor: Colors.grey.shade700,
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: 'Stroke'),
                Tab(text: 'Shadow'),
              ],
            ),
          ),*/
        ],
      ),
    );
  }

  Widget _buildPresetCards() {
    return SizedBox(
      height: 100,
      child: GetBuilder<TextStyleController>(
        id: 'effect_templates',
        builder: (controller) {
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: effectTemplates.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final template = effectTemplates[index];
              final isSelected = _isTemplateSelected(controller, template);

              return _buildTemplateCard(
                template: template,
                isSelected: isSelected,
                onTap: () => _applyTemplate(template),
              );
            },
          );
        },
      ),
    );
  }

  void _showTuneBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: null,
      elevation: 0,
      builder: (context) => TuneBottomSheet(controller: controller),
    );
  }

  Widget _buildTemplateCard({
    required EffectTemplate template,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isNoneTemplate = template.id == 'none';

    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 88,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.branding.withOpacity(0.08)
                  : Get.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: AppColors.branding, width: 0.4)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,

                  children: [
                    Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        color: Get.theme.colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: isNoneTemplate
                            ? Text(
                                "Aa",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: controller.textColorOld,
                                ),
                              )
                            : StrokeText(
                                text: "Aa",
                                strokeColor: template.strokeColor,
                                strokeWidth: template.strokeWidth,
                                textStyle: TextStyle(
                                  fontSize: 24,
                                  color: template.textColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    if (isSelected && !isNoneTemplate)
                      Container(
                        child: GestureDetector(
                          onTap: () {
                            _showTuneBottomSheet(Get.context!);
                          },
                          child: Container(
                            height: 56,
                            width: 56,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              // boxShadow: [
                              //   BoxShadow(
                              //     color: AppColors.branding.withOpacity(0.3),
                              //     blurRadius: 8,
                              //     offset: const Offset(0, 2),
                              //   ),
                              // ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 0),
                              child: const Icon(
                                Icons.tune,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  template.name,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? AppColors.branding
                        : Colors.grey.shade800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Keep all other existing methods exactly as they were
  void _applyTemplate(EffectTemplate template) {
    if (template.id == "none") {
      controller.resetStrok();
    } else {
      if (template.textColor != null) {
        controller.textColor(template.textColor);
      }
    }

    controller.fontSize.value = template.fontSize;

    controller.hasShadow.value = template.hasShadow;
    if (template.hasShadow) {
      controller.shadowOffset.value = template.shadowOffset;
      controller.shadowBlurRadius.value = template.shadowBlur;
      controller.shadowColor.value = template.shadowColor;
    }

    controller.hasStroke.value = template.hasStroke;
    if (template.hasStroke) {
      controller.strokeWidth.value = template.strokeWidth;
      controller.strokeColor.value = template.strokeColor;
    }

    controller.updateTextItem();
    controller.selectedTemplateId = template.id;
    controller.update(['effect_templates', 'template_properties']);
  }

  bool _isTemplateSelected(
    TextStyleController controller,
    EffectTemplate template,
  ) {
    // Use stored template ID for better tracking
    if (controller.selectedTemplateId != null) {
      return controller.selectedTemplateId == template.id;
    }

    // Fallback: Check basic structure match (not exact values)
    if (template.id == 'none') {
      return !controller.hasShadow.value && !controller.hasStroke.value;
    }

    return false;
  }
}

class TuneBottomSheet extends StatelessWidget {
  final TextStyleController controller;

  const TuneBottomSheet({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      // height: MediaQuery.of(context).size.height * 0.55,
      width: Get.width,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandleBar(),

          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (controller.hasStroke.value) ...[
                  // const SizedBox(height: 12),
                  _buildStrokeProperties(),
                ],
                if (controller.hasShadow.value) ...[
                  const SizedBox(height: 12),
                  _buildShadowProperties(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandleBar() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      height: 5,
      width: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildStrokeProperties() {
    return GetBuilder<TextStyleController>(
      id: "stroke_properties",
      builder: (controller) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Get.theme.shadowColor.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              CompactSlider(
                icon: Icons.line_weight,
                label: 'Stroke Width',
                value: controller.strokeWidth.value,
                min: 0.0,
                max: 10.0,
                onChanged: (value) {
                  controller.strokeWidth.value = value;

                  controller.updateTextItem();
                  controller.update(['stroke_properties']);
                },
              ),

              ColorSelector(
                title: "Stroke Color",

                colors: TextStyleController.predefinedColors,
                currentColor: controller.strokeColor.value,
                onColorSelected: (color) {
                  controller.strokeColor.value = color;
                  controller.updateTextItem();
                  controller.update(['stroke_properties']);
                },
                selectedBorderColor: AppColors.background,
                itemSize: 25,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShadowProperties() {
    return GetBuilder<TextStyleController>(
      id: 'shadow_properties',
      builder: (controller) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,

            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Get.theme.colorScheme.surfaceContainer.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              CompactSlider(
                icon: Icons.blur_on,
                label: 'Blur Radius',
                value: controller.shadowBlurRadius.value,
                min: 0.0,
                max: 20.0,
                onChanged: (value) {
                  controller.shadowBlurRadius.value = value;
                  controller.updateTextItem();
                  controller.update(['shadow_properties']);
                },
              ),

              ColorSelector(
                title: "Shadow Color",
                colors: TextStyleController.predefinedColors,
                currentColor: controller.shadowColor.value,
                onColorSelected: (color) {
                  controller.shadowColor.value = color;
                  controller.updateTextItem();
                  controller.update(['shadow_properties']);
                },
                selectedBorderColor: AppColors.background,

                itemSize: 25,
              ),
            ],
          ),
        );
      },
    );
  }
}

class EffectTemplate {
  final String id;
  final String name;
  final IconData icon;
  final bool hasShadow;
  final Offset shadowOffset;
  final double shadowBlur;
  final Color shadowColor;
  final bool hasStroke;
  final double strokeWidth;
  final Color strokeColor;
  final Color? textColor;
  final double fontSize; // Added fontSize property

  const EffectTemplate({
    required this.id,
    required this.name,
    required this.icon,
    this.hasShadow = false,
    this.shadowOffset = const Offset(0, 0),
    this.shadowBlur = 0.0,
    this.shadowColor = Colors.black,
    this.hasStroke = false,
    this.strokeWidth = 1.0,
    this.strokeColor = Colors.black,
    this.textColor,
    this.fontSize = 16.0, // Default font size
  });
}

// Create a new DualToneText widget
class DualToneText extends StatelessWidget {
  final String text;
  final Color color1;
  final Color color2;
  final DualToneDirection direction;
  final double position;
  final TextStyle? textStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final TextScaler? textScaler;
  final TextOverflow? overflow;
  final int? maxLines;

  const DualToneText({
    super.key,
    required this.text,
    required this.color1,
    required this.color2,
    this.direction = DualToneDirection.horizontal,
    this.position = 0.5,
    this.textStyle,
    this.textAlign,
    this.textDirection,
    this.textScaler,
    this.overflow,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return _createGradient().createShader(bounds);
      },
      blendMode: BlendMode.srcIn,
      child: Text(
        text,
        style: textStyle?.copyWith(color: Colors.white),
        textAlign: textAlign,
        textDirection: textDirection,
        textScaler: textScaler,
        overflow: overflow,
        maxLines: maxLines,
      ),
    );
  }

  Gradient _createGradient() {
    switch (direction) {
      case DualToneDirection.horizontal:
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [color1, color2],
          stops: [position, position],
        );
      case DualToneDirection.vertical:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color1, color2],
          stops: [position, position],
        );
      case DualToneDirection.diagonal:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color1, color2],
          stops: [position, position],
        );
      case DualToneDirection.radial:
        return RadialGradient(
          center: Alignment.center,
          colors: [color1, color2],
          stops: [position, position],
        );
    }
  }
}

// Add a new tab for Dual Tone in your TextStylingEditor

class _DualToneTuneTab extends StatelessWidget {
  final TextStyleController controller;
  const _DualToneTuneTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 100,
            child: GetBuilder<TextStyleController>(
              id: 'dual_tone_templates',
              builder: (controller) {
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: dualToneTemplates.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final template = dualToneTemplates[index];
                    final isSelected = _isDualToneTemplateSelected(
                      controller,
                      template,
                    );

                    return _buildDualToneTemplateCard(
                      template: template,
                      isSelected: isSelected,
                      onTap: () => _applyDualToneTemplate(controller, template),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDualToneTuneBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: null,
      barrierColor: Colors.transparent,
      elevation: 0,
      builder: (context) => DualToneTuneBottomSheet(controller: controller),
    );
  }

  Widget _buildDualToneTemplateCard({
    required DualToneTemplate template,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isNoneTemplate = template.id == 'none';

    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 88,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.branding.withOpacity(0.08)
                  : Get.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: AppColors.branding, width: 0.4)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        color: Get.theme.colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: isNoneTemplate
                            ? Text(
                                "Aa",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: controller.textColor.value,
                                ),
                              )
                            : DualToneText(
                                text: "Aa",
                                color1: template.color1,
                                color2: template.color2,
                                direction: template.direction,
                                position: template.position,
                                textStyle: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    if (isSelected && !isNoneTemplate)
                      Container(
                        child: GestureDetector(
                          onTap: () {
                            _showDualToneTuneBottomSheet(Get.context!);
                          },
                          child: Container(
                            height: 56,
                            width: 56,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 0),
                              child: const Icon(
                                Icons.tune,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  template.name,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? AppColors.branding
                        : Colors.grey.shade800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _applyDualToneTemplate(
    TextStyleController controller,
    DualToneTemplate template,
  ) {
    if (template.id == 'none') {
      controller.hasDualTone.value = false;
    } else {
      controller.hasDualTone.value = true;
      controller.dualToneColor1 = template.color1;
      controller.dualToneColor2 = template.color2;
      controller.dualToneDirection.value = template.direction;
      controller.dualTonePosition.value = template.position;
    }

    controller.updateTextItem();
    controller.selectedDualToneTemplateId = template.id;
    controller.update(['dual_tone_templates', 'dual_tone_properties']);
  }

  bool _isDualToneTemplateSelected(
    TextStyleController controller,
    DualToneTemplate template,
  ) {
    if (controller.selectedDualToneTemplateId != null) {
      return controller.selectedDualToneTemplateId == template.id;
    }

    // If no template is selected yet, "None" is selected when hasDualTone is false
    if (template.id == 'none') {
      return !controller.hasDualTone.value;
    }

    return false;
  }
}

class DualToneTuneBottomSheet extends StatelessWidget {
  final TextStyleController controller;

  const DualToneTuneBottomSheet({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      decoration: BoxDecoration(
        // color: Get.theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandleBar(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildColorSection(),
                const SizedBox(height: 8),
                _buildDirectionSection(),
                const SizedBox(height: 8),
                _buildPositionSlider(),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandleBar() {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      height: 4,
      width: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildColorSection() {
    return GetBuilder<TextStyleController>(
      id: 'dual_tone_colors',
      builder: (controller) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Get.theme.shadowColor.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.color_lens, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Colors',
                    style: Get.theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ColorSelector(
                          title: "Color 1",
                          colors: TextStyleController.predefinedColors,
                          currentColor: controller.dualToneColor1 ?? Colors.red,
                          onColorSelected: (color) {
                            controller.dualToneColor1 = color;
                            controller.updateTextItem();
                            controller.update(['dual_tone_colors']);
                          },
                          selectedBorderColor: AppColors.branding,
                          itemSize: 28,
                          spacing: 6,
                          paddingx: 0,
                          showTitle: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ColorSelector(
                          title: "Color 2",

                          colors: TextStyleController.predefinedColors,
                          currentColor:
                              controller.dualToneColor2 ?? Colors.blue,
                          onColorSelected: (color) {
                            controller.dualToneColor2 = color;
                            controller.updateTextItem();
                            controller.update(['dual_tone_colors']);
                          },
                          selectedBorderColor: AppColors.branding,
                          itemSize: 28,
                          spacing: 6,
                          paddingx: 0,
                          showTitle: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDirectionSection() {
    return GetBuilder<TextStyleController>(
      id: 'dual_tone_direction',
      builder: (controller) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Get.theme.shadowColor.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.directions, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Direction',
                    style: Get.theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: DualToneDirection.values.map((direction) {
                  final isSelected =
                      controller.dualToneDirection.value == direction;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Material(
                        color: isSelected
                            ? AppColors.branding.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            controller.dualToneDirection.value = direction;
                            controller.updateTextItem();
                            controller.update(['dual_tone_direction']);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Column(
                              children: [
                                Icon(
                                  _getDirectionIcon(direction),
                                  size: 20,
                                  color: isSelected
                                      ? AppColors.branding
                                      : Get.theme.colorScheme.onSurface
                                            .withOpacity(0.7),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPositionSlider() {
    return GetBuilder<TextStyleController>(
      id: 'dual_tone_position',
      builder: (controller) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Get.theme.shadowColor.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.tune, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Position',
                    style: Get.theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(controller.dualTonePosition.value * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.branding,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CompactSlider(
                icon: Icons.horizontal_rule,
                value: controller.dualTonePosition.value,
                min: 0.0,
                max: 1.0,
                onChanged: (value) {
                  controller.dualTonePosition.value = value;
                  controller.updateTextItem();
                  controller.update(['dual_tone_position']);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _getDirectionName(DualToneDirection direction) {
    switch (direction) {
      case DualToneDirection.horizontal:
        return 'Horizontal';
      case DualToneDirection.vertical:
        return 'Vertical';
      case DualToneDirection.diagonal:
        return 'Diagonal';
      case DualToneDirection.radial:
        return 'Radial';
    }
  }

  IconData _getDirectionIcon(DualToneDirection direction) {
    switch (direction) {
      case DualToneDirection.horizontal:
        return Icons.swap_horiz;
      case DualToneDirection.vertical:
        return Icons.swap_vert;
      case DualToneDirection.diagonal:
        return Icons.trending_up;
      case DualToneDirection.radial:
        return Icons.radio_button_unchecked;
    }
  }
}

class DualToneTemplate {
  final String id;
  final String name;
  final Color color1;
  final Color color2;
  final DualToneDirection direction;
  final double position;

  const DualToneTemplate({
    required this.id,
    required this.name,
    required this.color1,
    required this.color2,
    this.direction = DualToneDirection.horizontal,
    this.position = 0.5,
  });
}

const List<DualToneTemplate> dualToneTemplates = [
  DualToneTemplate(
    id: 'none',
    name: 'None',
    color1: Colors.transparent,
    color2: Colors.transparent,
    direction: DualToneDirection.horizontal,
  ),
  DualToneTemplate(
    id: 'red_blue',
    name: 'Red/Blue',
    color1: Colors.red,
    color2: Colors.blue,
    direction: DualToneDirection.horizontal,
  ),
  DualToneTemplate(
    id: 'purple_pink',
    name: 'Purple/Pink',
    color1: Colors.purple,
    color2: Colors.pink,
    direction: DualToneDirection.vertical,
  ),
  DualToneTemplate(
    id: 'green_yellow',
    name: 'Green/Yellow',
    color1: Colors.green,
    color2: Colors.yellow,
    direction: DualToneDirection.diagonal,
  ),
  DualToneTemplate(
    id: 'orange_teal',
    name: 'Orange/Teal',
    color1: Colors.orange,
    color2: Colors.teal,
    direction: DualToneDirection.radial,
    position: 0.7,
  ),
  DualToneTemplate(
    id: 'black_white',
    name: 'Black/White',
    color1: Colors.black,
    color2: Colors.white,
    direction: DualToneDirection.horizontal,
    position: 0.3,
  ),
];

class _CircularTab extends StatelessWidget {
  final TextStyleController controller;
  final TabController tabController;

  const _CircularTab({required this.controller, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Column(
        children: [
          // Circular text toggle
          GetBuilder<TextStyleController>(
            id: 'circular_toggle',
            builder: (controller) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.highlight.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: controller.isCircular.value
                              ? AppColors.accent.withOpacity(0.15)
                              : AppColors.highlight.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.circle_outlined,
                          color: controller.isCircular.value
                              ? AppColors.accent
                              : AppColors.highlight,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Circular Text',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Get.theme.colorScheme.onSurface,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              'Transform text into circular layout',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.highlight.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Transform.scale(
                        scale: 0.85,
                        child: Switch(
                          value: controller.isCircular.value,
                          onChanged: (value) {
                            controller.isCircular.value = value;
                            controller.space.value = 15;
                            controller.updateTextItem();
                            controller.update(['circular_toggle']);
                          },
                          activeColor: AppColors.accent,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Circular text controls
          GetBuilder<TextStyleController>(
            id: 'circular_toggle',
            builder: (controller) {
              if (!controller.isCircular.value) return const SizedBox.shrink();

              return Column(
                children: [
                  // Sub-tab bar
                  Container(
                    height: 30,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Get.theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      controller: tabController,
                      indicator: BoxDecoration(
                        color: AppColors.branding,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      indicatorPadding: const EdgeInsets.symmetric(vertical: 0),
                      padding: EdgeInsets.zero,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: Colors.white,
                      unselectedLabelColor: AppColors.highlight,
                      labelStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      tabs: const [
                        Tab(text: 'Spacing'),
                        Tab(text: 'Radius'),
                        Tab(text: 'Angle'),
                        Tab(text: 'Position'),
                        Tab(text: 'Direction'),
                        Tab(text: 'Style'),
                        Tab(text: 'Stroke'),
                        Tab(text: 'Colors'),
                      ],
                    ),
                  ),

                  // Sub-tab content
                  GetBuilder<TextStyleController>(
                    id: 'circular_tabbar',
                    builder: (context) {
                      return SizedBox(
                        height: tabController.index == 7 ? 250 : 100,
                        child: TabBarView(
                          controller: tabController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _LetterSpacingSubTab(controller: controller),
                            _RadiusSubTab(controller: controller),
                            _StartAngleSubTab(controller: controller),
                            _TextPositionSubTab(controller: controller),
                            _TextDirectionSubTab(controller: controller),
                            _StyleSubTab(controller: controller),
                            _StrokeWidthSubTab(controller: controller),
                            _ColorsSubTab(controller: controller),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// Keep all the existing circular sub-tab implementations
class _RadiusSubTab extends StatelessWidget {
  final TextStyleController controller;
  const _RadiusSubTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GetBuilder<TextStyleController>(
        id: 'circular_radius',
        builder: (controller) {
          return _buildCompactSection(
            title: 'Radius',
            subtitle: 'Circular path size',
            icon: Icons.radio_button_unchecked,
            child: _buildCompactSlider(
              value: controller.radius.value,
              min: 50.0,
              max: 200.0,
              label: '${controller.radius.value.toStringAsFixed(0)}px',
              onChanged: (value) {
                controller.radius.value = value;
                controller.updateTextItem();
                controller.update(['circular_radius']);
              },
            ),
          );
        },
      ),
    );
  }
}

class _LetterSpacingSubTab extends StatelessWidget {
  final TextStyleController controller;
  const _LetterSpacingSubTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GetBuilder<TextStyleController>(
        id: 'circular_spacing',
        builder: (controller) {
          return _buildCompactSection(
            title: 'Letter Spacing',
            subtitle: 'Space between characters',
            icon: Icons.space_bar,
            child: _buildCompactSlider(
              value: controller.space.value,
              min: 0.0,
              max: 30.0,
              label: controller.space.value.toStringAsFixed(1),
              onChanged: (value) {
                controller.space.value = value;
                controller.updateTextItem();
                controller.update(['circular_spacing']);
              },
            ),
          );
        },
      ),
    );
  }
}

class _StartAngleSubTab extends StatelessWidget {
  final TextStyleController controller;
  const _StartAngleSubTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GetBuilder<TextStyleController>(
        id: 'circular_angle',
        builder: (controller) {
          return _buildCompactSection(
            title: 'Start Angle',
            subtitle: 'Rotation of text path',
            icon: Icons.rotate_right,
            child: _buildCompactSlider(
              value: controller.startAngle.value,
              min: 0.0,
              max: 360.0,
              label: '${controller.startAngle.value.toStringAsFixed(0)}°',
              onChanged: (value) {
                controller.startAngle.value = value;
                controller.updateTextItem();
                controller.update(['circular_angle']);
              },
            ),
          );
        },
      ),
    );
  }
}

class _TextPositionSubTab extends StatelessWidget {
  final TextStyleController controller;
  const _TextPositionSubTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GetBuilder<TextStyleController>(
        id: 'circular_position',
        builder: (controller) {
          return _buildCompactSection(
            title: 'Text Position',
            subtitle: 'Inside or outside the circle',
            icon: Icons.place,
            child: _buildCompactSegmented<CircularTextPosition>(
              values: CircularTextPosition.values,
              selected: controller.position.value,
              onChanged: (value) {
                controller.position.value = value;
                controller.updateTextItem();
                controller.update(['circular_position']);
              },
              labelBuilder: (value) =>
                  value.toString().split('.').last.capitalize!,
            ),
          );
        },
      ),
    );
  }
}

class _TextDirectionSubTab extends StatelessWidget {
  final TextStyleController controller;
  const _TextDirectionSubTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GetBuilder<TextStyleController>(
        id: 'circular_direction',
        builder: (controller) {
          return _buildCompactSection(
            title: 'Text Direction',
            subtitle: 'Clockwise or counterclockwise',
            icon: Icons.trending_flat,
            child: _buildCompactSegmented<CircularTextDirection>(
              values: CircularTextDirection.values,
              selected: controller.direction.value,
              onChanged: (value) {
                controller.direction.value = value;
                controller.updateTextItem();
                controller.update(['circular_direction']);
              },
              labelBuilder: (value) =>
                  value.toString().split('.').last.capitalize!,
            ),
          );
        },
      ),
    );
  }
}

///.........................................

class _StyleSubTab extends StatelessWidget {
  final TextStyleController controller;
  const _StyleSubTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GetBuilder<TextStyleController>(
        id: 'circular_style',
        builder: (controller) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildCompactToggle(
                      title: 'Background',
                      icon: Icons.circle,
                      value: controller.showBackground.value,
                      onChanged: (value) {
                        controller.showBackground.value = value;
                        controller.updateTextItem();
                        controller.update(['circular_style']);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCompactToggle(
                      title: 'Stroke',
                      icon: Icons.radio_button_unchecked,
                      value: controller.showStroke.value,
                      onChanged: (value) {
                        controller.showStroke.value = value;
                        controller.updateTextItem();
                        controller.update(['circular_style']);
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StrokeWidthSubTab extends StatelessWidget {
  final TextStyleController controller;
  const _StrokeWidthSubTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GetBuilder<TextStyleController>(
        id: 'circular_stroke',
        builder: (controller) {
          if (!controller.showStroke.value) {
            return const Center(
              child: Text(
                'Enable Stroke in Style tab to adjust width',
                style: TextStyle(fontSize: 12, color: AppColors.highlight),
                textAlign: TextAlign.center,
              ),
            );
          }
          return _buildCompactSection(
            title: 'Stroke Width',
            subtitle: 'Thickness of the outline',
            icon: Icons.line_weight,
            child: _buildCompactSlider(
              value: controller.strokeWidth.value,
              min: 0.0,
              max: 100.0,
              label: '${controller.strokeWidth.value.toStringAsFixed(1)}px',
              onChanged: (value) {
                controller.strokeWidth.value = value;
                controller.updateTextItem();
                controller.update(['circular_stroke']);
              },
            ),
          );
        },
      ),
    );
  }
}

class _ColorsSubTab extends StatelessWidget {
  final TextStyleController controller;
  const _ColorsSubTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GetBuilder<TextStyleController>(
        id: 'circular_colors',
        builder: (controller) {
          return _buildCompactSection(
            title: 'Background Color',
            subtitle: 'Choose the background color',
            icon: Icons.color_lens_outlined,
            child: ColorSelector(
              colors: TextStyleController.predefinedColors,
              title: "colors",
              showTitle: false,
              currentColor: controller.backgroundPaintColor.value,
              onColorSelected: (color) {
                controller.backgroundPaintColor.value = color;
                controller.updateTextItem();
                controller.update(['circular_colors']);
              },
            ),
          );
        },
      ),
    );
  }
}

// ====================== SHARED HELPER METHODS ======================

Widget _buildCompactSection({
  required String title,
  required String subtitle,
  required IconData icon,
  required Widget child,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Get.theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),

      boxShadow: [
        BoxShadow(
          color: Get.theme.shadowColor.withValues(alpha: 0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 14, color: AppColors.accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Get.theme.colorScheme.onSurface,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.highlight.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    ),
  );
}

Widget _buildCompactSlider({
  required double value,
  required double min,
  required double max,
  required String label,
  required ValueChanged<double> onChanged,
}) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            min.toStringAsFixed(0),
            style: TextStyle(
              fontSize: 10,
              color: AppColors.highlight.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
          ),
          Text(
            max.toStringAsFixed(0),
            style: TextStyle(
              fontSize: 10,
              color: AppColors.highlight.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      SliderTheme(
        data: SliderTheme.of(Get.context!).copyWith(
          padding: EdgeInsets.zero,
          activeTrackColor: AppColors.accent,
          inactiveTrackColor: AppColors.highlight.withOpacity(0.15),
          thumbColor: AppColors.accent,
          overlayColor: AppColors.accent.withOpacity(0.2),
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          trackHeight: 3,
        ),
        child: Slider(value: value, min: min, max: max, onChanged: onChanged),
      ),
    ],
  );
}

Widget _buildCompactSegmented<T>({
  required List<T> values,
  required T selected,
  required ValueChanged<T> onChanged,
  required String Function(T) labelBuilder,
}) {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.highlight.withOpacity(0.06),
      borderRadius: BorderRadius.circular(8),
    ),
    padding: const EdgeInsets.all(3),
    child: Row(
      children: values.map((value) {
        final isSelected = value == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                labelBuilder(value),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.highlight,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    ),
  );
}

Widget _buildCompactToggle({
  required String title,
  required IconData icon,
  required bool value,
  required ValueChanged<bool> onChanged,
}) {
  return GestureDetector(
    onTap: () => onChanged(!value),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: value
            ? AppColors.accent.withOpacity(0.1)
            : Get.theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: value
              ? AppColors.accent.withOpacity(0.3)
              : AppColors.highlight.withOpacity(0.15),
          width: value ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: value ? AppColors.accent : AppColors.highlight,
            size: 18,
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: value ? AppColors.accent : AppColors.highlight,
            ),
          ),
        ],
      ),
    ),
  );
}
