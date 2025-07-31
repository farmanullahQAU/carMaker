import 'package:cardmaker/app/features/editor/circular_text/model.dart';
import 'package:cardmaker/app/features/editor/controller.dart';
import 'package:cardmaker/core/values/app_colors.dart';
import 'package:cardmaker/stack_board/lib/stack_board_item.dart';
import 'package:cardmaker/stack_board/lib/stack_items.dart';
import 'package:cardmaker/widgets/ruler_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

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
  late TabController _tabController;
  final EditorController controller = Get.find<EditorController>();
  late ValueNotifier<String> _selectedFont;
  late ValueNotifier<double> _fontSize;
  late ValueNotifier<double> _letterSpacing;
  late ValueNotifier<double> _lineHeight;
  late ValueNotifier<TextAlign> _textAlign;
  late ValueNotifier<Color> _textColor;
  late ValueNotifier<Color> _backgroundColor;
  late ValueNotifier<FontWeight> _fontWeight;
  late ValueNotifier<bool> _isItalic;
  late ValueNotifier<bool> _isUnderlined;
  late ValueNotifier<String?> _maskImage;
  late ValueNotifier<Color?> _maskColor;
  late ValueNotifier<bool> _hasShadow;
  late ValueNotifier<Offset> _shadowOffset;
  late ValueNotifier<double> _shadowBlurRadius;
  late ValueNotifier<Color> _shadowColor;
  late ValueNotifier<bool> _isCircular;
  late ValueNotifier<double> _radius;
  late ValueNotifier<double> _space;
  late ValueNotifier<double> _startAngle;
  late ValueNotifier<StartAngleAlignment> _startAngleAlignment;
  late ValueNotifier<CircularTextPosition> _position;
  late ValueNotifier<CircularTextDirection> _direction;
  late ValueNotifier<bool> _showBackground;
  late ValueNotifier<bool> _showStroke;
  late ValueNotifier<double> _strokeWidth;
  late ValueNotifier<Color> _backgroundPaintColor;
  var currentIndex = 0.obs;

  final List<String> _popularFonts = [
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

  final List<Color> _predefinedColors = [
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

  final List<String> _maskImages = [
    'assets/card1.png',
    'assets/birthday_1.png',
    'assets/Farman.png',
    'assets/Farman.png',
  ];
  // Add these variables to your _TextStylingEditorState class
  late TabController _circularSubTabController;
  var circularSubTabIndex = 0.obs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 10,
      vsync: this,
    ); // Increased to 10 for Circular tab
    _tabController.addListener(() {
      currentIndex.value = _tabController.index;

      _circularSubTabController = TabController(length: 7, vsync: this);
      _circularSubTabController.addListener(() {
        circularSubTabIndex.value = _circularSubTabController.index;
      });
    });

    _initializeTextProperties();
  }

  void _initializeTextProperties() {
    final textContent = widget.textItem.content;
    _selectedFont = ValueNotifier(textContent?.googleFont ?? 'Roboto');
    _fontSize = ValueNotifier(textContent?.style?.fontSize ?? 16.0);
    _letterSpacing = ValueNotifier(textContent?.style?.letterSpacing ?? 0.0);
    _lineHeight = ValueNotifier(textContent?.style?.height ?? 1.2);
    _textAlign = ValueNotifier(textContent?.textAlign ?? TextAlign.left);
    _textColor = ValueNotifier(textContent?.style?.color ?? Colors.black);
    _backgroundColor = ValueNotifier(
      textContent?.style?.backgroundColor ?? Colors.transparent,
    );
    _fontWeight = ValueNotifier(
      textContent?.style?.fontWeight ?? FontWeight.normal,
    );
    _isItalic = ValueNotifier(
      textContent?.style?.fontStyle == FontStyle.italic,
    );
    _isUnderlined = ValueNotifier(
      textContent?.style?.decoration == TextDecoration.underline,
    );
    _maskImage = ValueNotifier(textContent?.maskImage);
    _maskColor = ValueNotifier(textContent?.maskColor);
    _hasShadow = ValueNotifier(
      textContent?.style?.shadows?.isNotEmpty ?? false,
    );
    _shadowOffset = ValueNotifier(
      textContent?.style?.shadows?.isNotEmpty ?? false
          ? textContent!.style!.shadows![0].offset
          : Offset(2, 2),
    );
    _shadowBlurRadius = ValueNotifier(
      textContent?.style?.shadows?.isNotEmpty ?? false
          ? textContent!.style!.shadows![0].blurRadius
          : 4.0,
    );
    _shadowColor = ValueNotifier(
      textContent?.style?.shadows?.isNotEmpty ?? false
          ? textContent!.style!.shadows![0].color
          : Colors.black54,
    );
    _isCircular = ValueNotifier(textContent?.isCircular ?? false);
    _radius = ValueNotifier(
      (textContent?.radius ?? 0) >= 50 ? textContent!.radius! : 50.0,
    );
    _space = ValueNotifier(textContent?.space ?? 10.0);
    _startAngle = ValueNotifier(textContent?.startAngle ?? 0.0);
    _startAngleAlignment = ValueNotifier(
      textContent?.startAngleAlignment ?? StartAngleAlignment.start,
    );
    _position = ValueNotifier(
      textContent?.position ?? CircularTextPosition.inside,
    );
    _direction = ValueNotifier(
      textContent?.direction ?? CircularTextDirection.clockwise,
    );
    _showBackground = ValueNotifier(textContent?.showBackground ?? true);
    _showStroke = ValueNotifier(textContent?.showStroke ?? false);
    _strokeWidth = ValueNotifier(textContent?.strokeWidth ?? 0.0);
    _backgroundPaintColor = ValueNotifier(
      textContent?.backgroundPaintColor ?? Colors.grey.shade200,
    );
  }

  void _updateTextItem() {
    final updatedContent = widget.textItem.content?.copyWith(
      data: (Get.find<EditorController>().activeItem.value as StackTextItem)
          .content
          ?.data,
      googleFont: _selectedFont.value,
      style: TextStyle(
        fontFamily: GoogleFonts.getFont(_selectedFont.value).fontFamily,
        fontSize: _fontSize.value,
        letterSpacing: _letterSpacing.value,
        height: _lineHeight.value,
        color: _maskImage.value != null || _maskColor.value != null
            ? Colors.transparent
            : _textColor.value,
        backgroundColor: _backgroundColor.value,
        fontWeight: _fontWeight.value,
        fontStyle: _isItalic.value ? FontStyle.italic : FontStyle.normal,
        decoration: _isUnderlined.value
            ? TextDecoration.underline
            : TextDecoration.none,
        shadows: _hasShadow.value
            ? [
                Shadow(
                  offset: _shadowOffset.value,
                  blurRadius: _shadowBlurRadius.value,
                  color: _shadowColor.value,
                ),
              ]
            : null,
      ),
      textAlign: _textAlign.value,
      maskImage: _maskImage.value,
      maskColor: _maskColor.value,
      isCircular: _isCircular.value,
      radius: _radius.value,
      space: _space.value,
      startAngle: _startAngle.value,
      startAngleAlignment: _startAngleAlignment.value,
      position: _position.value,
      direction: _direction.value,
      showBackground: _showBackground.value,
      showStroke: _showStroke.value,
      strokeWidth: _strokeWidth.value,
      backgroundPaintColor: _backgroundPaintColor.value,
    );

    if (updatedContent == null) {
      print('Error: updatedContent is null');
      return;
    }

    final updatedItem = widget.textItem.copyWith(content: updatedContent);

    // Measure text dimensions using TextPainter for non-circular text
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

      const double maxWidth = 500.0;
      painter.layout(maxWidth: maxWidth);

      final width = painter.width.clamp(50.0, maxWidth);
      final height = painter.height.clamp(50.0, double.infinity);

      controller.boardController.updateItem(updatedItem);
      controller.boardController.updateBasic(
        updatedItem.id,
        status: StackItemStatus.selected,
        size: Size(width, height),
      );
    } else {
      // For circular text, use radius to determine size
      final diameter = updatedContent.radius! * 2;
      controller.boardController.updateItem(updatedItem);
      controller.boardController.updateBasic(
        updatedItem.id,
        status: StackItemStatus.selected,
        size: Size(diameter, diameter),
      );
    }

    print(
      'Updated ID: ${updatedItem.id}, '
      'Size: ${updatedItem.size.width.toStringAsFixed(1)} x ${updatedItem.size.height.toStringAsFixed(1)}, '
      'Text: ${updatedContent.data}, '
      'Font: ${updatedContent.googleFont}, '
      'Circular: ${updatedContent.isCircular}, '
      'Radius: ${updatedContent.radius?.toStringAsFixed(1)}',
    );
  }

  @override
  void dispose() {
    _selectedFont.dispose();
    _fontSize.dispose();
    _letterSpacing.dispose();
    _lineHeight.dispose();
    _textAlign.dispose();
    _textColor.dispose();
    _backgroundColor.dispose();
    _fontWeight.dispose();
    _isItalic.dispose();
    _isUnderlined.dispose();
    _maskImage.dispose();
    _maskColor.dispose();
    _hasShadow.dispose();
    _shadowOffset.dispose();
    _shadowBlurRadius.dispose();
    _shadowColor.dispose();
    _isCircular.dispose();
    _radius.dispose();
    _space.dispose();
    _startAngle.dispose();
    _startAngleAlignment.dispose();
    _position.dispose();
    _direction.dispose();
    _showBackground.dispose();
    _showStroke.dispose();
    _strokeWidth.dispose();
    _backgroundPaintColor.dispose();
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
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.branding, width: 0.1),
              ),
            ),
            child: TabBar(
              onTap: (index) {
                currentIndex.value = _tabController.index;
              },
              controller: _tabController,
              tabAlignment: TabAlignment.start,
              isScrollable: true,
              indicator: BoxDecoration(),
              dividerHeight: 0,
              dividerColor: Colors.transparent,
              indicatorColor: Colors.transparent,
              padding: EdgeInsets.zero,
              indicatorPadding: EdgeInsetsGeometry.zero,
              labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              tabs: const [
                Tab(icon: Icon(Icons.format_size, size: 16), text: 'Size'),
                Tab(
                  icon: Icon(Icons.format_align_left, size: 16),
                  text: 'Align',
                ),
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
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              return Obx(
                () => AnimatedSize(
                  duration: Duration(milliseconds: 200),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: currentIndex.value < 6
                          ? 120
                          : currentIndex.value == 8
                          ? 250
                          : 250,
                      minHeight: 0,
                    ),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildTabContent(_buildSizeTab()),
                        _buildTabContent(_buildAlignmentTab()),
                        _buildTabContent(_buildColorTab()),
                        _buildTabContent(_buildBackgroundTab()),
                        _buildTabContent(_buildStyleTab()),
                        _buildTabContent(_buildSpacingTab()),
                        _buildTabContent(_buildFontTab()),
                        _buildTabContent(_buildMaskTab()),
                        _buildTabContent(_buildEffectsTab()),
                        _buildTabContent(_buildCircularTab()),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCircularTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enable Circular Text Toggle - Compact Design
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.highlight.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: ValueListenableBuilder<bool>(
              valueListenable: _isCircular,
              builder: (context, isCircular, child) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isCircular
                              ? AppColors.accent.withOpacity(0.15)
                              : AppColors.highlight.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.circle_outlined,
                          color: isCircular
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
                          value: isCircular,
                          onChanged: (value) {
                            _isCircular.value = value;
                            _updateTextItem();
                          },
                          activeColor: AppColors.accent,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Circular Text Controls
          ValueListenableBuilder<bool>(
            valueListenable: _isCircular,
            builder: (context, isCircular, child) {
              if (!isCircular) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      controller: _circularSubTabController,
                      indicator: BoxDecoration(
                        color: AppColors.branding,
                        borderRadius: BorderRadius.circular(50),
                      ),

                      indicatorPadding: const EdgeInsets.symmetric(vertical: 0),

                      padding: EdgeInsets.symmetric(horizontal: 0),
                      labelPadding: EdgeInsets.symmetric(horizontal: 16),
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
                        Tab(text: 'Radius'),
                        Tab(text: 'Spacing'),
                        Tab(text: 'Angle'),
                        Tab(text: 'Position'),
                        Tab(text: 'Direction'),
                        Tab(text: 'Style'),
                        Tab(text: 'Colors'),
                      ],
                    ),
                  ),

                  // Sub-tab content with fixed height
                  SizedBox(
                    height: _circularSubTabController.index == 6
                        ? 250
                        : 100, // Fixed height to constrain TabBarView
                    child: TabBarView(
                      controller: _circularSubTabController,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        _buildRadiusSubTab(),
                        _buildLetterSpacingSubTab(),
                        _buildStartAngleSubTab(),
                        _buildTextPositionSubTab(),
                        _buildTextDirectionSubTab(),
                        _buildStyleSubTab(),
                        _buildColorsSubTab(),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRadiusSubTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),

      child: Column(
        children: [
          // Radius Control
          _buildCompactSection(
            title: 'Radius',
            subtitle: 'Circular path size',
            icon: Icons.radio_button_unchecked,
            child: ValueListenableBuilder<double>(
              valueListenable: _radius,
              builder: (context, radius, child) {
                return _buildCompactSlider(
                  value: radius,
                  min: 50.0,
                  max: 200.0,
                  label: '${radius.toStringAsFixed(0)}px',
                  onChanged: (value) {
                    _radius.value = value;
                    _updateTextItem();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLetterSpacingSubTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),

      child: Column(
        children: [
          // Letter Spacing Control
          _buildCompactSection(
            title: 'Letter Spacing',
            subtitle: 'Space between characters',
            icon: Icons.space_bar,
            child: ValueListenableBuilder<double>(
              valueListenable: _space,
              builder: (context, space, child) {
                return _buildCompactSlider(
                  value: space,
                  min: 0.0,
                  max: 30.0,
                  label: space.toStringAsFixed(1),
                  onChanged: (value) {
                    _space.value = value;
                    _updateTextItem();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartAngleSubTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Start Angle Control
          _buildCompactSection(
            title: 'Start Angle',
            subtitle: 'Rotation of text path',
            icon: Icons.rotate_right,
            child: ValueListenableBuilder<double>(
              valueListenable: _startAngle,
              builder: (context, startAngle, child) {
                return _buildCompactSlider(
                  value: startAngle,
                  min: 0.0,
                  max: 360.0,
                  label: '${startAngle.toStringAsFixed(0)}°',
                  onChanged: (value) {
                    _startAngle.value = value;
                    _updateTextItem();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextPositionSubTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Text Position Control
          _buildCompactSection(
            title: 'Text Position',
            subtitle: 'Inside or outside the circle',
            icon: Icons.place,
            child: ValueListenableBuilder<CircularTextPosition>(
              valueListenable: _position,
              builder: (context, position, child) {
                return _buildCompactSegmented<CircularTextPosition>(
                  values: CircularTextPosition.values,
                  selected: position,
                  onChanged: (value) {
                    _position.value = value;
                    _updateTextItem();
                  },
                  labelBuilder: (value) =>
                      value.toString().split('.').last.capitalize!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextDirectionSubTab() {
    return Column(
      children: [
        // Text Direction Control
        _buildCompactSection(
          title: 'Text Direction',
          subtitle: 'Clockwise or counterclockwise',
          icon: Icons.trending_flat,
          child: ValueListenableBuilder<CircularTextDirection>(
            valueListenable: _direction,
            builder: (context, direction, child) {
              return _buildCompactSegmented<CircularTextDirection>(
                values: CircularTextDirection.values,
                selected: direction,
                onChanged: (value) {
                  _direction.value = value;
                  _updateTextItem();
                },
                labelBuilder: (value) =>
                    value.toString().split('.').last.capitalize!,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStyleSubTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Toggle Options
          Row(
            children: [
              Expanded(
                child: _buildCompactToggle(
                  title: 'Background',
                  icon: Icons.circle,
                  valueListenable: _showBackground,
                  onChanged: (value) {
                    _showBackground.value = value;
                    _updateTextItem();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCompactToggle(
                  title: 'Stroke',
                  icon: Icons.radio_button_unchecked,
                  valueListenable: _showStroke,
                  onChanged: (value) {
                    _showStroke.value = value;
                    _updateTextItem();
                  },
                ),
              ),
            ],
          ),

          // Stroke Width (conditional)
          ValueListenableBuilder<bool>(
            valueListenable: _showStroke,
            builder: (context, showStroke, child) {
              if (!showStroke) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.only(top: 20),
                child: _buildCompactSection(
                  title: 'Stroke Width',
                  subtitle: 'Thickness of the outline',
                  icon: Icons.line_weight,
                  child: ValueListenableBuilder<double>(
                    valueListenable: _strokeWidth,
                    builder: (context, strokeWidth, child) {
                      return _buildCompactSlider(
                        value: strokeWidth,
                        min: 0.0,
                        max: 10.0,
                        label: '${strokeWidth.toStringAsFixed(1)}px',
                        onChanged: (value) {
                          _strokeWidth.value = value;
                          _updateTextItem();
                        },
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildColorsSubTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCompactSection(
            title: 'Background Color',
            subtitle: 'Choose the background color',
            icon: Icons.color_lens_outlined,
            child: ValueListenableBuilder<Color>(
              valueListenable: _backgroundPaintColor,
              builder: (context, backgroundPaintColor, child) {
                return _buildCompactColorPicker(
                  selectedColor: backgroundPaintColor,
                  onColorSelected: (color) {
                    _backgroundPaintColor.value = color;
                    _updateTextItem();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /*

  Widget _buildCircularTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enable Circular Text Toggle - Compact Design
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.highlight.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: ValueListenableBuilder<bool>(
              valueListenable: _isCircular,
              builder: (context, isCircular, child) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isCircular
                              ? AppColors.accent.withOpacity(0.15)
                              : AppColors.highlight.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.circle_outlined,
                          color: isCircular
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
                          value: isCircular,
                          onChanged: (value) {
                            _isCircular.value = value;
                            _updateTextItem();
                          },
                          activeColor: AppColors.accent,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Circular Text Controls
          ValueListenableBuilder<bool>(
            valueListenable: _isCircular,
            builder: (context, isCircular, child) {
              if (!isCircular) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sub-tab bar
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.highlight.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TabBar(
                      controller: _circularSubTabController,
                      indicator: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      indicatorPadding: const EdgeInsets.all(2),
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
                        Tab(text: 'Layout'),
                        Tab(text: 'Position'),
                        Tab(text: 'Style'),
                        Tab(text: 'Colors'),
                      ],
                    ),
                  ),

                  // Sub-tab content with fixed height
                  SizedBox(
                    height: 200, // Fixed height to constrain TabBarView
                    child: TabBarView(
                      controller: _circularSubTabController,
                      children: [
                        _buildLayoutSubTab(),
                        _buildPositionSubTab(),
                        _buildStyleSubTab(),
                        _buildColorsSubTab(),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // Layout Sub-tab - Radius and Spacing
  Widget _buildLayoutSubTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Radius Control
          _buildCompactSection(
            title: 'Radius',
            subtitle: 'Circular path size',
            icon: Icons.radio_button_unchecked,
            child: ValueListenableBuilder<double>(
              valueListenable: _radius,
              builder: (context, radius, child) {
                return _buildCompactSlider(
                  value: radius,
                  min: 50.0,
                  max: 200.0,
                  label: '${radius.toStringAsFixed(0)}px',
                  onChanged: (value) {
                    _radius.value = value;
                    _updateTextItem();
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Letter Spacing Control
          _buildCompactSection(
            title: 'Letter Spacing',
            subtitle: 'Space between characters',
            icon: Icons.space_bar,
            child: ValueListenableBuilder<double>(
              valueListenable: _space,
              builder: (context, space, child) {
                return _buildCompactSlider(
                  value: space,
                  min: 0.0,
                  max: 30.0,
                  label: space.toStringAsFixed(1),
                  onChanged: (value) {
                    _space.value = value;
                    _updateTextItem();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Position Sub-tab - Angle and Direction
  Widget _buildPositionSubTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Start Angle Control
          _buildCompactSection(
            title: 'Start Angle',
            subtitle: 'Rotation of text path',
            icon: Icons.rotate_right,
            child: ValueListenableBuilder<double>(
              valueListenable: _startAngle,
              builder: (context, startAngle, child) {
                return _buildCompactSlider(
                  value: startAngle,
                  min: 0.0,
                  max: 360.0,
                  label: '${startAngle.toStringAsFixed(0)}°',
                  onChanged: (value) {
                    _startAngle.value = value;
                    _updateTextItem();
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Position Control
          _buildCompactSection(
            title: 'Text Position',
            subtitle: 'Inside or outside the circle',
            icon: Icons.place,
            child: ValueListenableBuilder<CircularTextPosition>(
              valueListenable: _position,
              builder: (context, position, child) {
                return _buildCompactSegmented<CircularTextPosition>(
                  values: CircularTextPosition.values,
                  selected: position,
                  onChanged: (value) {
                    _position.value = value;
                    _updateTextItem();
                  },
                  labelBuilder: (value) =>
                      value.toString().split('.').last.capitalize!,
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Direction Control
          _buildCompactSection(
            title: 'Text Direction',
            subtitle: 'Clockwise or counterclockwise',
            icon: Icons.trending_flat,
            child: ValueListenableBuilder<CircularTextDirection>(
              valueListenable: _direction,
              builder: (context, direction, child) {
                return _buildCompactSegmented<CircularTextDirection>(
                  values: CircularTextDirection.values,
                  selected: direction,
                  onChanged: (value) {
                    _direction.value = value;
                    _updateTextItem();
                  },
                  labelBuilder: (value) =>
                      value.toString().split('.').last.capitalize!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Style Sub-tab - Background and Stroke
  Widget _buildStyleSubTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Toggle Options
          Row(
            children: [
              Expanded(
                child: _buildCompactToggle(
                  title: 'Background',
                  icon: Icons.circle,
                  valueListenable: _showBackground,
                  onChanged: (value) {
                    _showBackground.value = value;
                    _updateTextItem();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCompactToggle(
                  title: 'Stroke',
                  icon: Icons.radio_button_unchecked,
                  valueListenable: _showStroke,
                  onChanged: (value) {
                    _showStroke.value = value;
                    _updateTextItem();
                  },
                ),
              ),
            ],
          ),

          // Stroke Width (conditional)
          ValueListenableBuilder<bool>(
            valueListenable: _showStroke,
            builder: (context, showStroke, child) {
              if (!showStroke) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.only(top: 20),
                child: _buildCompactSection(
                  title: 'Stroke Width',
                  subtitle: 'Thickness of the outline',
                  icon: Icons.line_weight,
                  child: ValueListenableBuilder<double>(
                    valueListenable: _strokeWidth,
                    builder: (context, strokeWidth, child) {
                      return _buildCompactSlider(
                        value: strokeWidth,
                        min: 0.0,
                        max: 10.0,
                        label: '${strokeWidth.toStringAsFixed(1)}px',
                        onChanged: (value) {
                          _strokeWidth.value = value;
                          _updateTextItem();
                        },
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Colors Sub-tab - Background Color
  Widget _buildColorsSubTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCompactSection(
            title: 'Background Color',
            subtitle: 'Choose the background color',
            icon: Icons.color_lens_outlined,
            child: ValueListenableBuilder<Color>(
              valueListenable: _backgroundPaintColor,
              builder: (context, backgroundPaintColor, child) {
                return _buildCompactColorPicker(
                  selectedColor: backgroundPaintColor,
                  onColorSelected: (color) {
                    _backgroundPaintColor.value = color;
                    _updateTextItem();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
*/
  // Compact section helper
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

  // Compact slider
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
        // const SizedBox(height: 8),
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

  // Compact segmented control
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

  // Compact toggle
  Widget _buildCompactToggle({
    required String title,
    required IconData icon,
    required ValueNotifier<bool> valueListenable,
    required ValueChanged<bool> onChanged,
  }) {
    return ValueListenableBuilder<bool>(
      valueListenable: valueListenable,
      builder: (context, value, child) {
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
      },
    );
  }

  // Compact color picker
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
      itemCount: _predefinedColors.length,
      itemBuilder: (context, index) {
        final color = _predefinedColors[index];
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

  // Helper method to wrap each tab's content
  Widget _buildTabContent(Widget child) {
    return SingleChildScrollView(child: child);
  }
  // Helper method to wrap each tab's content

  Widget _buildFontTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: ValueListenableBuilder<String>(
        valueListenable: _selectedFont,
        builder: (context, selectedFont, child) {
          return Center(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _popularFonts.map((font) {
                final isSelected = font == selectedFont;
                return ChoiceChip(
                  onSelected: (v) {
                    _selectedFont.value = font;
                    _updateTextItem();
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

  Widget _buildSizeTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder<double>(
              valueListenable: _fontSize,
              builder: (context, fontSize, child) {
                return RulerSlider(
                  minValue: 8.0,
                  maxValue: 72.0,
                  initialValue: fontSize,
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
                    _fontSize.value = value;
                    _updateTextItem();
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
          ],
        ),
      ),
    );
  }

  Widget _buildAlignmentTab() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ValueListenableBuilder<TextAlign>(
        valueListenable: _textAlign,
        builder: (context, textAlign, child) {
          return Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              _buildAlignmentButton(
                icon: Icons.format_align_left,
                alignment: TextAlign.left,
                label: 'Left',
                isSelected: textAlign == TextAlign.left,
              ),
              _buildAlignmentButton(
                icon: Icons.format_align_center,
                alignment: TextAlign.center,
                label: 'Center',
                isSelected: textAlign == TextAlign.center,
              ),
              _buildAlignmentButton(
                icon: Icons.format_align_right,
                alignment: TextAlign.right,
                label: 'Right',
                isSelected: textAlign == TextAlign.right,
              ),
              _buildAlignmentButton(
                icon: Icons.format_align_justify,
                alignment: TextAlign.justify,
                label: 'Justify',
                isSelected: textAlign == TextAlign.justify,
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
  }) {
    return GestureDetector(
      onTap: () {
        _textAlign.value = alignment;
        _updateTextItem();
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

  Widget _buildColorTab() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        child: ValueListenableBuilder<Color>(
          valueListenable: _textColor,
          builder: (context, textColor, child) {
            return Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _predefinedColors.map((color) {
                final isSelected = color.value == textColor.value;
                return GestureDetector(
                  onTap: () {
                    _textColor.value = color;
                    _maskImage.value = null;
                    _maskColor.value = null;
                    _updateTextItem();
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
                        ? Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBackgroundTab() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        child: ValueListenableBuilder<Color>(
          valueListenable: _backgroundColor,
          builder: (context, backgroundColor, child) {
            return Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                GestureDetector(
                  onTap: () {
                    _backgroundColor.value = Colors.transparent;
                    _updateTextItem();
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: backgroundColor == Colors.transparent
                            ? Colors.blueAccent
                            : Colors.grey[300]!,
                        width: backgroundColor == Colors.transparent ? 2 : 1,
                      ),
                    ),
                    child: Icon(
                      Icons.clear,
                      color: backgroundColor == Colors.transparent
                          ? Colors.blueAccent
                          : Colors.grey,
                      size: 16,
                    ),
                  ),
                ),
                ..._predefinedColors.map((color) {
                  final isSelected = color.value == backgroundColor.value;
                  return GestureDetector(
                    onTap: () {
                      _backgroundColor.value = color;
                      _updateTextItem();
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
                          ? Icon(Icons.check, color: Colors.white, size: 16)
                          : null,
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStyleTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ValueListenableBuilder<FontWeight>(
              valueListenable: _fontWeight,
              builder: (context, fontWeight, child) {
                return Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children:
                      [
                        FontWeight.w300,
                        FontWeight.normal,
                        FontWeight.w500,
                        FontWeight.bold,
                      ].map((weight) {
                        final isSelected = weight == fontWeight;
                        String label = weightToString(weight);
                        return GestureDetector(
                          onTap: () {
                            _fontWeight.value = weight;
                            _updateTextItem();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Get.theme.colorScheme.primary
                                  : null,
                              borderRadius: BorderRadius.circular(8),
                            ),

                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            margin: EdgeInsets.only(top: 4),

                            child: Text(
                              label,
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
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _isItalic,
                    builder: (context, isItalic, child) {
                      return GestureDetector(
                        onTap: () {
                          _isItalic.value = !isItalic;
                          _updateTextItem();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isItalic ? AppColors.branding : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.format_italic,
                                color: isItalic
                                    ? Colors.white
                                    : AppColors.highlight,
                                size: 16,
                              ),
                              Text(
                                'Italic',
                                style: TextStyle(
                                  color: isItalic
                                      ? Colors.white
                                      : AppColors.highlight,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _isUnderlined,
                    builder: (context, isUnderlined, child) {
                      return GestureDetector(
                        onTap: () {
                          _isUnderlined.value = !isUnderlined;
                          _updateTextItem();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isUnderlined
                                ? AppColors.branding
                                : Colors.white,

                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.format_underline,
                                color: isUnderlined
                                    ? Colors.white
                                    : AppColors.highlight,
                                size: 16,
                              ),
                              Text(
                                'Underline',
                                style: TextStyle(
                                  color: isUnderlined
                                      ? Colors.white
                                      : AppColors.highlight,
                                  decoration: TextDecoration.underline,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpacingTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Text(
              'Letter Spacing',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.highlight,
              ),
            ),
            ValueListenableBuilder<double>(
              valueListenable: _letterSpacing,
              builder: (context, letterSpacing, child) {
                return Slider(
                  padding: EdgeInsets.only(top: 4),

                  min: 0.0,
                  max: 32.0,
                  value: letterSpacing,
                  divisions: 32,
                  label: '${letterSpacing.toStringAsFixed(1)}px',
                  onChanged: (value) {
                    setState(() {
                      _letterSpacing.value = value;
                      _updateTextItem();
                    });
                  },
                );
              },
            ),
            // SizedBox(height: 8),
            Text(
              'Line Height',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.highlight,
              ),
            ),
            ValueListenableBuilder<double>(
              valueListenable: _lineHeight,
              builder: (context, lineHeight, child) {
                // return RulerSlider(
                //   minValue: 0.8,
                //   maxValue: 3.0,
                //   initialValue: lineHeight,
                //   onChanged: (value) {
                //     _lineHeight.value = value;
                //     _updateTextItem();
                //   },
                //   labelBuilder: (value) => '${value.toStringAsFixed(1)}x',
                //   majorTickInterval: 1,
                //   labelInterval: 1,
                // );

                return Slider(
                  padding: EdgeInsets.only(top: 4),
                  min: 0.8,
                  max: 3.0,
                  value: lineHeight,
                  // divisions: 3,
                  label: '${lineHeight.toStringAsFixed(1)}x',
                  onChanged: (value) {
                    setState(() {
                      _lineHeight.value = value;
                      _updateTextItem();
                    });
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildSpacingTab() {
  //   return SingleChildScrollView(
  //     child: Padding(
  //       padding: const EdgeInsets.all(8),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           ValueListenableBuilder<double>(
  //             valueListenable: _letterSpacing,
  //             builder: (context, letterSpacing, child) {
  //               return Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     'Letter Spacing',
  //                     style: TextStyle(
  //                       fontSize: 10,
  //                       fontWeight: FontWeight.w500,
  //                       color: AppColors.highlight,
  //                     ),
  //                   ),
  //                   Slider(
  //                     value: letterSpacing,
  //                     min: -2.0,
  //                     max: 8.0,
  //                     divisions: 100,
  //                     label: '${letterSpacing.toStringAsFixed(1)}px',
  //                     activeColor: Colors.blueAccent,
  //                     onChanged: (value) {
  //                       _letterSpacing.value = value;
  //                       _updateTextItem();
  //                     },
  //                   ),
  //                 ],
  //               );
  //             },
  //           ),
  //           ValueListenableBuilder<double>(
  //             valueListenable: _lineHeight,
  //             builder: (context, lineHeight, child) {
  //               return Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     'Line Height',
  //                     style: TextStyle(
  //                       fontSize: 10,
  //                       fontWeight: FontWeight.w500,
  //                       color: AppColors.highlight,
  //                     ),
  //                   ),
  //                   Slider(
  //                     value: lineHeight,
  //                     min: 0.8,
  //                     max: 3.0,
  //                     divisions: 44,
  //                     label: '${lineHeight.toStringAsFixed(1)}x',
  //                     activeColor: Colors.blueAccent,
  //                     onChanged: (value) {
  //                       _lineHeight.value = value;
  //                       _updateTextItem();
  //                     },
  //                   ),
  //                 ],
  //               );
  //             },
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildMaskTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Image Mask',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.highlight,
            ),
          ),
          SizedBox(height: 8),

          ValueListenableBuilder<String?>(
            valueListenable: _maskImage,
            builder: (context, maskImage, child) {
              return Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  GestureDetector(
                    onTap: () {
                      _maskImage.value = null;
                      _maskColor.value = null;
                      _updateTextItem();
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: maskImage == null && _maskColor.value == null
                              ? AppColors.branding
                              : AppColors.highlight,
                          width: maskImage == null && _maskColor.value == null
                              ? 2
                              : 1,
                        ),
                      ),
                      child: Icon(
                        Icons.clear,
                        color: maskImage == null && _maskColor.value == null
                            ? AppColors.branding
                            : AppColors.highlight,
                        size: 24,
                      ),
                    ),
                  ),
                  ..._maskImages.map((image) {
                    final isSelected = image == maskImage;
                    return GestureDetector(
                      onTap: () {
                        _maskImage.value = image;
                        _maskColor.value = null;
                        _updateTextItem();
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
                            ? Icon(Icons.check, color: Colors.white, size: 24)
                            : null,
                      ),
                    );
                  }),
                ],
              );
            },
          ),
          SizedBox(height: 8),
          Text(
            'Color Mask',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.highlight,
            ),
          ),
          SizedBox(height: 8),

          ValueListenableBuilder<Color?>(
            valueListenable: _maskColor,
            builder: (context, maskColor, child) {
              return Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _predefinedColors.map((color) {
                  final isSelected = color.value == maskColor?.value;
                  return GestureDetector(
                    onTap: () {
                      _maskColor.value = color;
                      _maskImage.value = null;
                      _updateTextItem();
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
                          ? Icon(Icons.check, color: Colors.white, size: 16)
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

  Widget _buildEffectsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: _hasShadow,
            builder: (context, hasShadow, child) {
              return SwitchListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(
                  'Text Shadow',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.highlight,
                  ),
                ),
                value: hasShadow,
                onChanged: (value) {
                  _hasShadow.value = value;
                  _updateTextItem();
                },
              );
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _hasShadow,
            builder: (context, hasShadow, child) {
              if (!hasShadow) return SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shadow Offset X',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.highlight,
                    ),
                  ),
                  ValueListenableBuilder<Offset>(
                    valueListenable: _shadowOffset,
                    builder: (context, shadowOffset, child) {
                      return Slider(
                        padding: EdgeInsets.only(top: 4, bottom: 8),
                        value: shadowOffset.dx,
                        min: -10.0,
                        max: 10.0,
                        divisions: 40,
                        label: '${shadowOffset.dx.toStringAsFixed(1)}px',
                        onChanged: (value) {
                          _shadowOffset.value = Offset(value, shadowOffset.dy);
                          _updateTextItem();
                        },
                      );
                    },
                  ),
                  Text(
                    'Shadow Offset Y',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.highlight,
                    ),
                  ),
                  ValueListenableBuilder<Offset>(
                    valueListenable: _shadowOffset,
                    builder: (context, shadowOffset, child) {
                      return Slider(
                        padding: EdgeInsets.only(top: 4, bottom: 8),

                        value: shadowOffset.dy,
                        min: -10.0,
                        max: 10.0,
                        divisions: 40,
                        label: '${shadowOffset.dy.toStringAsFixed(1)}px',
                        activeColor: AppColors.accent,
                        onChanged: (value) {
                          _shadowOffset.value = Offset(shadowOffset.dx, value);
                          _updateTextItem();
                        },
                      );
                    },
                  ),
                  Text(
                    'Shadow Blur Radius',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.highlight,
                    ),
                  ),
                  ValueListenableBuilder<double>(
                    valueListenable: _shadowBlurRadius,
                    builder: (context, blurRadius, child) {
                      return Slider(
                        padding: EdgeInsets.only(top: 4, bottom: 8),
                        value: blurRadius,
                        min: 0.0,
                        max: 20.0,
                        divisions: 40,
                        label: '${blurRadius.toStringAsFixed(1)}px',
                        activeColor: AppColors.branding,
                        onChanged: (value) {
                          _shadowBlurRadius.value = value;
                          _updateTextItem();
                        },
                      );
                    },
                  ),
                  Text(
                    'Shadow Color',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.highlight,
                    ),
                  ),
                  SizedBox(height: 4),
                  ValueListenableBuilder<Color>(
                    valueListenable: _shadowColor,
                    builder: (context, shadowColor, child) {
                      return Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _predefinedColors.map((color) {
                          final isSelected = color.value == shadowColor.value;
                          return GestureDetector(
                            onTap: () {
                              _shadowColor.value = color;
                              _updateTextItem();
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
                                  ? Icon(
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
              );
            },
          ),
        ],
      ),
    );
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
