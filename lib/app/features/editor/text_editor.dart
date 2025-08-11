import 'package:cardmaker/app/features/editor/circular_text/model.dart';
import 'package:cardmaker/app/features/editor/controller.dart';
import 'package:cardmaker/core/values/app_colors.dart';
import 'package:cardmaker/stack_board/lib/stack_board_item.dart';
import 'package:cardmaker/stack_board/lib/stack_items.dart';
import 'package:cardmaker/widgets/ruler_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class TextStyleController extends GetxController {
  // Tab control
  final currentIndex = 0.obs;
  final circularSubTabIndex = 0.obs;

  // Text item reference
  final textItem = Rx<StackTextItem?>(null);

  // Text properties
  final selectedFont = 'Roboto'.obs;
  final fontSize = 16.0.obs;
  final letterSpacing = 0.0.obs;
  final lineHeight = 1.2.obs;
  final textAlign = TextAlign.left.obs;
  final textColor = Colors.black.obs;
  final backgroundColor = Colors.transparent.obs;
  final fontWeight = FontWeight.normal.obs;
  final isItalic = false.obs;
  final isUnderlined = false.obs;
  final maskImage = Rx<String?>(null);
  final maskColor = Rx<Color?>(null);

  // Effects
  final hasShadow = false.obs;
  final shadowOffset = const Offset(2, 2).obs;
  final shadowBlurRadius = 4.0.obs;
  final shadowColor = Colors.black54.obs;

  // Circular text
  final isCircular = false.obs;
  final radius = 50.0.obs;
  final space = 10.0.obs;
  final startAngle = 0.0.obs;
  final startAngleAlignment = StartAngleAlignment.start.obs;
  final position = CircularTextPosition.inside.obs;
  final direction = CircularTextDirection.clockwise.obs;
  final showBackground = true.obs;
  final showStroke = false.obs;
  final strokeWidth = 0.0.obs;
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
    Colors.black,
    Colors.white,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.amber,
    Colors.cyan,
    Colors.grey,
    Colors.brown,
    Colors.indigo,
    Colors.lime,
    Colors.deepOrange,
  ];

  static const maskImages = [
    'assets/card1.png',
    'assets/birthday_1.png',
    'assets/Farman.png',
    'assets/Farman.png',
  ];

  @override
  void onInit() {
    super.onInit();
    initializeProperties(textItem.value);
  }

  void initializeProperties(StackTextItem? item) {
    if (item == null) return;
    textItem.value = item;

    final textContent = item.content;
    selectedFont.value = textContent?.googleFont ?? 'Roboto';
    fontSize.value = textContent?.style?.fontSize ?? 16.0;
    letterSpacing.value = textContent?.style?.letterSpacing ?? 0.0;
    lineHeight.value = textContent?.style?.height ?? 1.2;
    textAlign.value = textContent?.textAlign ?? TextAlign.left;
    textColor.value = textContent?.style?.color ?? Colors.black;
    backgroundColor.value =
        textContent?.style?.backgroundColor ?? Colors.transparent;
    fontWeight.value = textContent?.style?.fontWeight ?? FontWeight.normal;
    isItalic.value = textContent?.style?.fontStyle == FontStyle.italic;
    isUnderlined.value =
        textContent?.style?.decoration == TextDecoration.underline;
    maskImage.value = textContent?.maskImage;
    maskColor.value = textContent?.maskColor;
    hasShadow.value = textContent?.style?.shadows?.isNotEmpty ?? false;

    if (hasShadow.value && textContent?.style?.shadows?.isNotEmpty == true) {
      shadowOffset.value = textContent!.style!.shadows![0].offset;
      shadowBlurRadius.value = textContent.style!.shadows![0].blurRadius;
      shadowColor.value = textContent.style!.shadows![0].color;
    }

    isCircular.value = textContent?.isCircular ?? false;
    radius.value = (textContent?.radius ?? 0) >= 50
        ? textContent!.radius!
        : 50.0;
    space.value = textContent?.space ?? 10.0;
    startAngle.value = textContent?.startAngle ?? 0.0;
    startAngleAlignment.value =
        textContent?.startAngleAlignment ?? StartAngleAlignment.start;
    position.value = textContent?.position ?? CircularTextPosition.inside;
    direction.value = textContent?.direction ?? CircularTextDirection.clockwise;
    showBackground.value = textContent?.showBackground ?? true;
    showStroke.value = textContent?.showStroke ?? false;
    strokeWidth.value = textContent?.strokeWidth ?? 0.0;
    backgroundPaintColor.value =
        textContent?.backgroundPaintColor ?? Colors.grey.shade200;
  }

  void updateTextItem() {
    final item = textItem.value;
    if (item == null) return;

    final updatedContent = item.content?.copyWith(
      data: item.content?.data,
      googleFont: selectedFont.value,
      style: TextStyle(
        fontFamily: GoogleFonts.getFont(selectedFont.value).fontFamily,
        fontSize: fontSize.value,
        letterSpacing: letterSpacing.value,
        height: lineHeight.value,
        color: maskImage.value != null || maskColor.value != null
            ? Colors.transparent
            : textColor.value,
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
      maskColor: maskColor.value,
      isCircular: isCircular.value,
      radius: radius.value,
      space: space.value,
      startAngle: startAngle.value,
      startAngleAlignment: startAngleAlignment.value,
      position: position.value,
      direction: direction.value,
      showBackground: showBackground.value,
      showStroke: showStroke.value,
      strokeWidth: strokeWidth.value,
      backgroundPaintColor: backgroundPaintColor.value,
    );

    if (updatedContent == null) return;

    final editorController = Get.find<EditorController>();
    // Get the latest item from boardController to preserve current position
    final currentItem =
        editorController.boardController.getById(item.id) ?? item;
    final updatedItem = item.copyWith(
      content: updatedContent,
      offset: currentItem.offset, // Preserve the latest position
    );

    editorController.boardController.updateItem(updatedItem);
    // Force a status update to trigger StackBoard rebuild, preserving position
    editorController.boardController.updateBasic(
      updatedItem.id,
      status: StackItemStatus.idle,
      size: updatedItem.size,
      offset: updatedItem.offset, // Explicitly set current offset
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

      // const double maxWidth = 200.0; //for not using fittedbox

      const double maxWidth = 800.0;

      painter.layout(maxWidth: maxWidth);

      final width = painter.width.clamp(50.0, maxWidth);
      final height = painter.height.clamp(30.0, double.infinity);

      editorController.boardController.updateBasic(
        updatedItem.id,
        status: StackItemStatus.selected,
        size: Size(width, height),
        offset: updatedItem.offset, // Explicitly set current offset
      );
    } else {
      final diameter = updatedContent.radius! * 2;
      editorController.boardController.updateBasic(
        updatedItem.id,
        status: StackItemStatus.selected,
        size: Size(diameter, diameter),
        offset: updatedItem.offset, // Explicitly set current offset
      );
    }
  }

  // void updateTextItem() {
  //   final item = textItem.value;
  //   if (item == null) return;

  //   final updatedContent = item.content?.copyWith(
  //     data: item.content?.data,
  //     googleFont: selectedFont.value,
  //     style: TextStyle(
  //       fontFamily: GoogleFonts.getFont(selectedFont.value).fontFamily,
  //       fontSize: fontSize.value,
  //       letterSpacing: letterSpacing.value,
  //       height: lineHeight.value,
  //       color: maskImage.value != null || maskColor.value != null
  //           ? Colors.transparent
  //           : textColor.value,
  //       backgroundColor: backgroundColor.value,
  //       fontWeight: fontWeight.value,
  //       fontStyle: isItalic.value ? FontStyle.italic : FontStyle.normal,
  //       decoration: isUnderlined.value
  //           ? TextDecoration.underline
  //           : TextDecoration.none,
  //       shadows: hasShadow.value
  //           ? [
  //               Shadow(
  //                 offset: shadowOffset.value,
  //                 blurRadius: shadowBlurRadius.value,
  //                 color: shadowColor.value,
  //               ),
  //             ]
  //           : null,
  //     ),
  //     textAlign: textAlign.value,
  //     maskImage: maskImage.value,
  //     maskColor: maskColor.value,
  //     isCircular: isCircular.value,
  //     radius: radius.value,
  //     space: space.value,
  //     startAngle: startAngle.value,
  //     startAngleAlignment: startAngleAlignment.value,
  //     position: position.value,
  //     direction: direction.value,
  //     showBackground: showBackground.value,
  //     showStroke: showStroke.value,
  //     strokeWidth: strokeWidth.value,
  //     backgroundPaintColor: backgroundPaintColor.value,
  //   );

  //   if (updatedContent == null) return;

  //   final updatedItem = item.copyWith(content: updatedContent);
  //   final editorController = Get.find<EditorController>();

  //   editorController.boardController.updateItem(updatedItem);
  //   // Force a status update to trigger StackBoard rebuild
  //   editorController.boardController.updateBasic(
  //     updatedItem.id,
  //     status: StackItemStatus.idle,
  //     size: updatedItem.size, // Preserve current size
  //   );

  //   if (!updatedContent.isCircular) {
  //     final span = TextSpan(
  //       text: updatedContent.data,
  //       style: updatedContent.style,
  //     );

  //     final painter = TextPainter(
  //       text: span,
  //       textDirection: TextDirection.ltr,
  //       textAlign: updatedContent.textAlign ?? TextAlign.left,
  //       maxLines: null,
  //     );

  //     const double maxWidth = 500.0;
  //     painter.layout(maxWidth: maxWidth);

  //     final width = painter.width.clamp(50.0, maxWidth);
  //     final height = painter.height.clamp(50.0, double.infinity);

  //     editorController.boardController.updateBasic(
  //       updatedItem.id,
  //       status: StackItemStatus.selected,
  //       size: Size(width, height),
  //     );
  //   } else {
  //     final diameter = updatedContent.radius! * 2;
  //     editorController.boardController.updateBasic(
  //       updatedItem.id,
  //       status: StackItemStatus.selected,
  //       size: Size(diameter, diameter),
  //     );
  //   }
  // }

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
  void initState() {
    super.initState();
    _controller.initializeProperties(widget.textItem);

    _circularSubTabController = TabController(length: 8, vsync: this);
    _circularSubTabController.addListener(() {
      _controller.circularSubTabIndex.value = _circularSubTabController.index;
    });

    _tabController = TabController(
      length: 10,
      vsync: this,
      initialIndex: _controller.currentIndex.value,
    );
    _tabController.addListener(() {
      _controller.currentIndex.value = _tabController.index;

      _controller.update(['tab_view']);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _circularSubTabController.dispose();
    // Get.delete<TextStyleController>();
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

  Widget _buildTabBar() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.branding, width: 0.1),
        ),
      ),
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
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        tabs: const [
          // Tab(icon: Icon(Icons.format_size, size: 16)),
          // Tab(icon: Icon(Icons.format_align_left, size: 16)),
          // Tab(icon: Icon(Icons.palette, size: 16)),
          // Tab(icon: Icon(Icons.format_color_fill, size: 16)),
          // Tab(icon: Icon(Icons.format_bold, size: 16)),
          // Tab(icon: Icon(Icons.tune, size: 16)),
          // Tab(icon: Icon(Icons.font_download, size: 16)),
          // Tab(icon: Icon(Icons.image, size: 16)),
          // Tab(icon: Icon(Icons.blur_on, size: 16)),
          // Tab(icon: Icon(Icons.circle, size: 16)),
          Tab(icon: Icon(Icons.format_size, size: 16), text: 'Size'),
          Tab(icon: Icon(Icons.format_align_left, size: 16), text: 'Align'),
          Tab(icon: Icon(Icons.palette, size: 16), text: 'Color'),
          Tab(icon: Icon(Icons.format_color_fill, size: 16), text: 'BG'),
          Tab(icon: Icon(Icons.format_bold, size: 16), text: 'Style'),
          Tab(icon: Icon(Icons.tune, size: 16), text: 'Spacing'),
          Tab(icon: Icon(Icons.font_download, size: 16), text: 'Font'),
          Tab(icon: Icon(Icons.image, size: 16), text: 'Mask'),
          Tab(icon: Icon(Icons.blur_on, size: 16), text: 'Effects'),
          Tab(icon: Icon(Icons.circle, size: 16), text: 'Circular'),
        ],
      ),
    );
  }

  Widget _buildTabView() {
    return LayoutBuilder(
      builder: (_, constraints) {
        return GetBuilder<TextStyleController>(
          id: 'tab_view',
          builder: (controller) {
            print(controller.currentIndex.value);
            return AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: SizedBox(
                height: controller.currentIndex.value < 6
                    ? 120
                    : controller.currentIndex.value == 8
                    ? 250
                    : 250,
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
                    _CircularTab(
                      controller: controller,
                      tabController: _circularSubTabController,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// Individual tab implementations with GetBuilder for precise updates
class _ColorTab extends StatelessWidget {
  final TextStyleController controller;
  const _ColorTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GetBuilder<TextStyleController>(
        id: 'text_color',
        builder: (controller) {
          return SingleChildScrollView(
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ...TextStyleController.predefinedColors.map((color) {
                  final isSelected = color == controller.textColor.value;
                  return GestureDetector(
                    onTap: () {
                      controller.textColor.value = color;
                      controller.maskImage.value = null;
                      controller.maskColor.value = null;
                      controller.updateTextItem();
                      controller.update(['text_color', 'mask']);
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Colors.blueAccent
                              : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ====================== BACKGROUND TAB ======================
class _BackgroundTab extends StatelessWidget {
  final TextStyleController controller;
  const _BackgroundTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GetBuilder<TextStyleController>(
        id: 'background_color',
        builder: (controller) {
          return SingleChildScrollView(
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                GestureDetector(
                  onTap: () {
                    controller.backgroundColor.value = Colors.transparent;
                    controller.updateTextItem();
                    controller.update(['background_color']);
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            controller.backgroundColor.value ==
                                Colors.transparent
                            ? Colors.blueAccent
                            : Colors.grey[300]!,
                        width:
                            controller.backgroundColor.value ==
                                Colors.transparent
                            ? 2
                            : 1,
                      ),
                    ),
                    child: Icon(
                      Icons.clear,
                      color:
                          controller.backgroundColor.value == Colors.transparent
                          ? Colors.blueAccent
                          : Colors.grey,
                      size: 16,
                    ),
                  ),
                ),
                ...TextStyleController.predefinedColors.map((color) {
                  final isSelected = color == controller.backgroundColor.value;
                  return GestureDetector(
                    onTap: () {
                      controller.backgroundColor.value = color;
                      controller.updateTextItem();
                      controller.update(['background_color']);
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Colors.blueAccent
                              : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ====================== STYLE TAB ======================
class _StyleTab extends StatelessWidget {
  final TextStyleController controller;
  const _StyleTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8),

      child: GetBuilder<TextStyleController>(
        id: 'text_style',
        builder: (controller) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children:
                    [
                      FontWeight.w300,
                      FontWeight.normal,
                      FontWeight.w500,
                      FontWeight.bold,
                    ].map((weight) {
                      final isSelected = weight == controller.fontWeight.value;
                      return GestureDetector(
                        onTap: () {
                          controller.fontWeight.value = weight;
                          controller.updateTextItem();
                          controller.update(['text_style']);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Get.theme.colorScheme.primary
                                : null,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          margin: const EdgeInsets.only(top: 4),
                          child: Text(
                            controller.weightToString(weight),
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.highlight,
                              fontWeight: weight,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        controller.isItalic.value = !controller.isItalic.value;
                        controller.updateTextItem();
                        controller.update(['text_style']);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          color: controller.isItalic.value
                              ? AppColors.accent
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.format_italic,
                              color: controller.isItalic.value
                                  ? Colors.white
                                  : AppColors.highlight,
                              size: 16,
                            ),
                            Text(
                              'Italic',
                              style: TextStyle(
                                color: controller.isItalic.value
                                    ? Colors.white
                                    : AppColors.highlight,
                                fontStyle: FontStyle.italic,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        controller.isUnderlined.value =
                            !controller.isUnderlined.value;
                        controller.updateTextItem();
                        controller.update(['text_style']);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          color: controller.isUnderlined.value
                              ? AppColors.accent
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.format_underline,
                              color: controller.isUnderlined.value
                                  ? Colors.white
                                  : AppColors.highlight,
                              size: 16,
                            ),
                            Text(
                              'Underline',
                              style: TextStyle(
                                color: controller.isUnderlined.value
                                    ? Colors.white
                                    : AppColors.highlight,
                                decoration: TextDecoration.underline,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
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

// ====================== SPACING TAB ======================
class _SpacingTab extends StatelessWidget {
  final TextStyleController controller;
  const _SpacingTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Letter Spacing',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.highlight,
              ),
            ),
            GetBuilder<TextStyleController>(
              id: 'letter_spacing',
              builder: (controller) {
                return SliderTheme(
                  data: SliderTheme.of(Get.context!).copyWith(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    // activeTrackColor: AppColors.branding,
                    // inactiveTrackColor: AppColors.highlight.withOpacity(0.15),
                    // thumbColor: AppColors.branding,
                    // overlayColor: AppColors.branding.withOpacity(0.2),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8,
                    ),
                    trackHeight: 8,
                  ),
                  child: Slider(
                    value: controller.letterSpacing.value,
                    label:
                        "${controller.letterSpacing.value.toStringAsFixed(1)}px",
                    min: 0.0,
                    max: 32,
                    divisions: 32,
                    onChanged: (value) {
                      controller.letterSpacing.value = value;
                      controller.updateTextItem();
                      controller.update(['letter_spacing']);
                    },
                  ),
                );
              },
            ),
            const Text(
              'Line Height',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.highlight,
              ),
            ),
            GetBuilder<TextStyleController>(
              id: 'line_height',
              builder: (controller) {
                return SliderTheme(
                  data: SliderTheme.of(Get.context!).copyWith(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    activeTrackColor: AppColors.accent,
                    inactiveTrackColor: AppColors.highlight.withOpacity(0.15),
                    thumbColor: AppColors.accent,
                    overlayColor: AppColors.accent.withOpacity(0.2),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8,
                    ),
                    trackHeight: 8,
                  ),
                  child: Slider(
                    value: controller.lineHeight.value,
                    min: 0.8,
                    max: 3.0,
                    label: '${controller.lineHeight.value.toStringAsFixed(1)}x',
                    onChanged: (value) {
                      controller.lineHeight.value = value;
                      controller.updateTextItem();
                      controller.update(['line_height']);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ====================== FONT TAB ======================
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

// ====================== MASK TAB ======================
class _MaskTab extends StatelessWidget {
  final TextStyleController controller;
  const _MaskTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Image Mask',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.highlight,
            ),
          ),
          const SizedBox(height: 8),
          GetBuilder<TextStyleController>(
            id: 'mask_image',
            builder: (controller) {
              return Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  GestureDetector(
                    onTap: () {
                      controller.maskImage.value = null;
                      controller.maskColor.value = null;
                      controller.updateTextItem();
                      controller.update(['mask_image', 'mask_color']);
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              controller.maskImage.value == null &&
                                  controller.maskColor.value == null
                              ? AppColors.branding
                              : AppColors.highlight,
                          width:
                              controller.maskImage.value == null &&
                                  controller.maskColor.value == null
                              ? 2
                              : 1,
                        ),
                      ),
                      child: Icon(
                        Icons.clear,
                        color:
                            controller.maskImage.value == null &&
                                controller.maskColor.value == null
                            ? AppColors.branding
                            : AppColors.highlight,
                        size: 24,
                      ),
                    ),
                  ),
                  ...TextStyleController.maskImages.map((image) {
                    final isSelected = image == controller.maskImage.value;
                    return GestureDetector(
                      onTap: () {
                        controller.maskImage.value = image;
                        controller.maskColor.value = null;
                        controller.updateTextItem();
                        controller.update(['mask_image', 'mask_color']);
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(image),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.branding
                                : AppColors.highlight,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 24,
                              )
                            : null,
                      ),
                    );
                  }),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          const Text(
            'Color Mask',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.highlight,
            ),
          ),
          const SizedBox(height: 8),
          GetBuilder<TextStyleController>(
            id: 'mask_color',
            builder: (controller) {
              return Wrap(
                spacing: 6,
                runSpacing: 6,
                children: TextStyleController.predefinedColors.map((color) {
                  final isSelected =
                      color.value == controller.maskColor.value?.value;
                  return GestureDetector(
                    onTap: () {
                      controller.maskColor.value = color;
                      controller.maskImage.value = null;
                      controller.updateTextItem();
                      controller.update(['mask_color', 'mask_image']);
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.highlight,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ====================== EFFECTS TAB ======================
class _EffectsTab extends StatelessWidget {
  final TextStyleController controller;
  const _EffectsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GetBuilder<TextStyleController>(
            id: 'shadow_toggle',
            builder: (controller) {
              return SwitchListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: const Text(
                  'Text Shadow',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.highlight,
                  ),
                ),
                value: controller.hasShadow.value,
                onChanged: (value) {
                  controller.hasShadow.value = value;
                  controller.updateTextItem();
                  controller.update(['shadow_toggle', 'shadow_properties']);
                },
              );
            },
          ),
          GetBuilder<TextStyleController>(
            id: 'shadow_properties',
            builder: (controller) {
              if (!controller.hasShadow.value) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Shadow Offset X',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.highlight,
                    ),
                  ),
                  Slider(
                    value: controller.shadowOffset.value.dx,
                    min: -10.0,
                    max: 10.0,
                    divisions: 40,
                    label:
                        '${controller.shadowOffset.value.dx.toStringAsFixed(1)}px',
                    onChanged: (value) {
                      controller.shadowOffset.value = Offset(
                        value,
                        controller.shadowOffset.value.dy,
                      );
                      controller.updateTextItem();
                      controller.update(['shadow_properties']);
                    },
                  ),
                  const Text(
                    'Shadow Offset Y',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.highlight,
                    ),
                  ),
                  Slider(
                    value: controller.shadowOffset.value.dy,
                    min: -10.0,
                    max: 10.0,
                    divisions: 40,
                    label:
                        '${controller.shadowOffset.value.dy.toStringAsFixed(1)}px',
                    activeColor: AppColors.accent,
                    onChanged: (value) {
                      controller.shadowOffset.value = Offset(
                        controller.shadowOffset.value.dx,
                        value,
                      );
                      controller.updateTextItem();
                      controller.update(['shadow_properties']);
                    },
                  ),
                  const Text(
                    'Shadow Blur Radius',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.highlight,
                    ),
                  ),
                  Slider(
                    value: controller.shadowBlurRadius.value,
                    min: 0.0,
                    max: 20.0,
                    divisions: 40,
                    label:
                        '${controller.shadowBlurRadius.value.toStringAsFixed(1)}px',
                    activeColor: AppColors.branding,
                    onChanged: (value) {
                      controller.shadowBlurRadius.value = value;
                      controller.updateTextItem();
                      controller.update(['shadow_properties']);
                    },
                  ),
                  const Text(
                    'Shadow Color',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.highlight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: TextStyleController.predefinedColors.map((color) {
                      final isSelected =
                          color.value == controller.shadowColor.value.value;
                      return GestureDetector(
                        onTap: () {
                          controller.shadowColor.value = color;
                          controller.updateTextItem();
                          controller.update(['shadow_properties']);
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.accent
                                  : AppColors.highlight,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
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

// ====================== CIRCULAR SUB TABS ======================

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
              max: 10.0,
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
            child: _buildCompactColorPicker(
              selectedColor: controller.backgroundPaintColor.value,
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
      color: Get.theme.colorScheme.surfaceContainer.withOpacity(0.3),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: AppColors.highlight.withOpacity(0.08),
        width: 1,
      ),
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

Widget _buildCompactColorPicker({
  required Color selectedColor,
  required ValueChanged<Color> onColorSelected,
}) {
  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 6,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1,
    ),
    itemCount: TextStyleController.predefinedColors.length,
    itemBuilder: (context, index) {
      final color = TextStyleController.predefinedColors[index];
      final isSelected = color.value == selectedColor.value;

      return GestureDetector(
        onTap: () => onColorSelected(color),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.accent : Colors.transparent,
              width: isSelected ? 2.5 : 0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: isSelected
              ? Icon(
                  Icons.check,
                  color: color.computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white,
                  size: 14,
                )
              : null,
        ),
      );
    },
  );
}

class _SizeTab extends StatelessWidget {
  final TextStyleController controller;
  const _SizeTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: GetBuilder<TextStyleController>(
          id: 'font_size',
          builder: (controller) {
            // return RulerSlider(
            //   minValue: 8.0,
            //   maxValue: 72.0,
            //   initialValue: controller.fontSize.value,
            //   rulerHeight: 60.0,
            //   selectedBarColor: AppColors.branding,
            //   unselectedBarColor: AppColors.highlight,
            //   tickSpacing: 10.0,
            //   labelBuilder: (value) => '${value.round()}px',
            //   onChanged: (value) {
            //     controller.fontSize.value = value;
            //     controller.updateTextItem();
            //     controller.update(['font_size']);
            //   },
            //   majorTickInterval: 10,
            //   labelInterval: 10,
            //   labelVerticalOffset: 20.0,
            //   showBottomLabels: true,
            //   labelTextStyle: Get.theme.textTheme.labelSmall!,
            //   majorTickHeight: 15.0,
            //   minorTickHeight: 7.0,
            // );
            return RulerSlider(
              minValue: 8.0,
              maxValue: 72.0,
              initialValue: controller.fontSize.value,
              rulerHeight: 60.0, // Adjust height to fit layout
              selectedBarColor:
                  AppColors.branding, // Match Slider's activeColor
              unselectedBarColor: AppColors.highlight,
              tickSpacing: 10.0, // Smaller spacing for finer ticks
              // valueTextStyle: TextStyle(
              //   // color: Colors.blueAccent,
              //   fontSize: 12,
              // ),
              fixedBarColor: AppColors.branding,
              labelBuilder: (value) => '${value.round()}px',

              onChanged: (value) {
                controller.fontSize.value = value;
                controller.updateTextItem();
                controller.update(['font_size']);
              },
              showFixedBar: true, // Disable fixed bar for simplicity
              showFixedLabel: false, // Disable fixed label
              scrollSensitivity: 0.9,
              enableSnapping: false, // Snap to whole numbers for font sizes
              majorTickInterval: 10,
              labelInterval: 10,

              labelVerticalOffset: 20.0,
              showBottomLabels: true,
              labelTextStyle: Get.theme.textTheme.labelSmall!,
              majorTickHeight: 15.0,
              minorTickHeight: 7.0,
            );
          },
        ),
      ),
    );
  }
}

class _AlignmentTab extends StatelessWidget {
  final TextStyleController controller;
  const _AlignmentTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GetBuilder<TextStyleController>(
        id: 'text_align',
        builder: (controller) {
          return Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              _buildAlignmentButton(
                icon: Icons.format_align_left,
                alignment: TextAlign.left,
                label: 'Left',
                isSelected: controller.textAlign.value == TextAlign.left,
                controller: controller,
              ),
              _buildAlignmentButton(
                icon: Icons.format_align_center,
                alignment: TextAlign.center,
                label: 'Center',
                isSelected: controller.textAlign.value == TextAlign.center,
                controller: controller,
              ),
              _buildAlignmentButton(
                icon: Icons.format_align_right,
                alignment: TextAlign.right,
                label: 'Right',
                isSelected: controller.textAlign.value == TextAlign.right,
                controller: controller,
              ),
              _buildAlignmentButton(
                icon: Icons.format_align_justify,
                alignment: TextAlign.justify,
                label: 'Justify',
                isSelected: controller.textAlign.value == TextAlign.justify,
                controller: controller,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAlignmentButton({
    required IconData icon,
    required TextAlign alignment,
    required String label,
    required bool isSelected,
    required TextStyleController controller,
  }) {
    return GestureDetector(
      onTap: () {
        controller.textAlign.value = alignment;
        controller.updateTextItem();
        controller.update(['text_align']);
      },
      child: Container(
        width: 70,
        height: 50,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected ? Get.theme.colorScheme.primary : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.background : AppColors.highlight,
              size: 16,
            ),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.background : AppColors.highlight,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Implement other tabs similarly with GetBuilder and specific IDs

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
                  color: Get.theme.colorScheme.surfaceContainer,
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
                      color: AppColors.highlight.withOpacity(0.05),
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

// Implement circular sub-tabs similarly with GetBuilder
