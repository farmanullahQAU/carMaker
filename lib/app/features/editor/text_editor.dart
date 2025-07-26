import 'package:cardmaker/app/features/editor/controller.dart';
import 'package:cardmaker/stack_board/lib/stack_board_item.dart';
import 'package:cardmaker/stack_board/lib/stack_items.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this);

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
    );

    if (updatedContent == null) {
      print('Error: updatedContent is null');
      return;
    }

    final updatedItem = widget.textItem.copyWith(content: updatedContent);

    // Measure text dimensions using TextPainter
    final span = TextSpan(
      text: updatedContent.data,
      style: updatedContent.style,
    );

    final painter = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
      textAlign: updatedContent.textAlign ?? TextAlign.left,
      maxLines: null, // Allow unlimited lines for wrapping
    );

    // Provide a max width
    const double maxWidth = 500.0;
    painter.layout(maxWidth: maxWidth);

    final width = painter.width.clamp(50.0, maxWidth); // Min 100
    final height = painter.height.clamp(50.0, double.infinity); // Min 50

    controller.boardController.updateItem(updatedItem);
    controller.boardController.updateBasic(
      updatedItem.id,
      status: StackItemStatus.selected,
      size: Size(width, width / 2),
    );

    print(
      'Updated ID: ${updatedItem.id}, '
      'Size: ${width.toStringAsFixed(1)} x ${height.toStringAsFixed(1)}, '
      'Text: ${updatedContent.data}, '
      'Font: ${updatedContent.googleFont}, ',
      // 'Mask: ${_maskImage.value ?? _maskColor.value?.toStringAsFixed(0)}',
    );
    _selectedFont.value =
        (Get.find<EditorController>().activeItem.value as StackTextItem)
            .content
            ?.googleFont ??
        'Roboto';
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
    _shadowColor;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Ensures Column takes minimum height
        children: [
          // Tab Bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: TabBar(
              controller: _tabController,
              tabAlignment: TabAlignment.start,
              isScrollable: true,
              indicator: BoxDecoration(),
              dividerHeight: 0,
              dividerColor: Colors.transparent,
              // indicatorColor: Colors.blueAccent,
              // labelColor: Colors.blueAccent,
              // unselectedLabelColor: Colors.grey[600],
              padding: EdgeInsets.zero,
              indicatorPadding: EdgeInsetsGeometry.zero,
              // labelPadding: EdgeInsets.only(right: 25),
              indicatorWeight: 2,
              labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              tabs: const [
                Tab(icon: Icon(Icons.font_download, size: 16), text: 'Font'),
                Tab(icon: Icon(Icons.format_size, size: 16), text: 'Size'),
                Tab(
                  icon: Icon(Icons.format_align_left, size: 16),
                  text: 'Align',
                ),
                Tab(icon: Icon(Icons.palette, size: 16), text: 'Color'),
                Tab(icon: Icon(Icons.format_color_fill, size: 16), text: 'BG'),
                Tab(icon: Icon(Icons.format_bold, size: 16), text: 'Style'),
                Tab(icon: Icon(Icons.tune, size: 16), text: 'Spacing'),
                Tab(icon: Icon(Icons.image, size: 16), text: 'Mask'),
                Tab(icon: Icon(Icons.blur_on, size: 16), text: 'Effects'),
              ],
            ),
          ),
          // Tab Content
          LayoutBuilder(
            builder: (context, constraints) {
              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight:
                      100, // Optional: Set a reasonable max height to prevent overflow
                  minHeight: 0, // Allow shrinking to content size
                ),
                child: TabBarView(
                  controller: _tabController,
                  physics:
                      NeverScrollableScrollPhysics(), // Prevent unwanted scrolling
                  children: [
                    _buildTabContent(_buildFontTab()),
                    _buildTabContent(_buildSizeTab()),
                    _buildTabContent(_buildAlignmentTab()),
                    _buildTabContent(_buildColorTab()),
                    _buildTabContent(_buildBackgroundTab()),
                    _buildTabContent(_buildStyleTab()),
                    _buildTabContent(_buildSpacingTab()),
                    _buildTabContent(_buildMaskTab()),
                    _buildTabContent(_buildEffectsTab()),
                  ],
                ),
              );
            },
          ),
        ],
      ),
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
                  showCheckmark: false,
                  visualDensity: VisualDensity.comfortable,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 0,
                  ),
                  label: Text(
                    font,
                    style: GoogleFonts.getFont(font, fontSize: 12),
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
                return Slider(
                  value: fontSize,
                  min: 8,
                  max: 72,
                  divisions: 64,
                  label: '${fontSize.round()}px',
                  activeColor: Colors.blueAccent,
                  onChanged: (value) {
                    _fontSize.value = value;
                    _updateTextItem();
                  },
                );
              },
            ),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [12, 16, 20, 24, 32, 48].map((size) {
                return ValueListenableBuilder<double>(
                  valueListenable: _fontSize,
                  builder: (context, fontSize, child) {
                    final isSelected = fontSize.round() == size;
                    return GestureDetector(
                      onTap: () {
                        _fontSize.value = size.toDouble();
                        _updateTextItem();
                      },
                      child: Chip(
                        label: Text(
                          '${size}px',
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[800],
                            fontSize: 10,
                          ),
                        ),
                        backgroundColor: isSelected
                            ? Colors.blueAccent
                            : Colors.grey[100],
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
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
          color: isSelected ? Colors.blueAccent : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[800],
              size: 16,
            ),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[800],
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
                          child: Chip(
                            label: Text(
                              label,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[800],
                                fontWeight: weight,
                                fontSize: 10,
                              ),
                            ),
                            backgroundColor: isSelected
                                ? Colors.blueAccent
                                : Colors.grey[100],
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                          ),
                        );
                      }).toList(),
                );
              },
            ),
            const SizedBox(height: 8),
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
                            color: isItalic
                                ? Colors.blueAccent
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.format_italic,
                                color: isItalic
                                    ? Colors.white
                                    : Colors.grey[800],
                                size: 16,
                              ),
                              Text(
                                'Italic',
                                style: TextStyle(
                                  color: isItalic
                                      ? Colors.white
                                      : Colors.grey[800],
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
                                ? Colors.blueAccent
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.format_underline,
                                color: isUnderlined
                                    ? Colors.white
                                    : Colors.grey[800],
                                size: 16,
                              ),
                              Text(
                                'Underline',
                                style: TextStyle(
                                  color: isUnderlined
                                      ? Colors.white
                                      : Colors.grey[800],
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
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder<double>(
              valueListenable: _letterSpacing,
              builder: (context, letterSpacing, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Letter Spacing',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    Slider(
                      value: letterSpacing,
                      min: -2.0,
                      max: 8.0,
                      divisions: 100,
                      label: '${letterSpacing.toStringAsFixed(1)}px',
                      activeColor: Colors.blueAccent,
                      onChanged: (value) {
                        _letterSpacing.value = value;
                        _updateTextItem();
                      },
                    ),
                  ],
                );
              },
            ),
            ValueListenableBuilder<double>(
              valueListenable: _lineHeight,
              builder: (context, lineHeight, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Line Height',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    Slider(
                      value: lineHeight,
                      min: 0.8,
                      max: 3.0,
                      divisions: 44,
                      label: '${lineHeight.toStringAsFixed(1)}x',
                      activeColor: Colors.blueAccent,
                      onChanged: (value) {
                        _lineHeight.value = value;
                        _updateTextItem();
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaskTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Image Mask',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
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
                              ? Colors.blueAccent
                              : Colors.grey[300]!,
                          width: maskImage == null && _maskColor.value == null
                              ? 2
                              : 1,
                        ),
                      ),
                      child: Icon(
                        Icons.clear,
                        color: maskImage == null && _maskColor.value == null
                            ? Colors.blueAccent
                            : Colors.grey,
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
                                ? Colors.blueAccent
                                : Colors.grey[300]!,
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
          SizedBox(height: 16),
          Text(
            'Color Mask',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
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
        ],
      ),
    );
  }

  Widget _buildEffectsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: _hasShadow,
            builder: (context, hasShadow, child) {
              return SwitchListTile(
                title: Text(
                  'Text Shadow',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                value: hasShadow,
                activeColor: Colors.blueAccent,
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
                      color: Colors.grey[700],
                    ),
                  ),
                  ValueListenableBuilder<Offset>(
                    valueListenable: _shadowOffset,
                    builder: (context, shadowOffset, child) {
                      return Slider(
                        value: shadowOffset.dx,
                        min: -10.0,
                        max: 10.0,
                        divisions: 40,
                        label: '${shadowOffset.dx.toStringAsFixed(1)}px',
                        activeColor: Colors.blueAccent,
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
                      color: Colors.grey[700],
                    ),
                  ),
                  ValueListenableBuilder<Offset>(
                    valueListenable: _shadowOffset,
                    builder: (context, shadowOffset, child) {
                      return Slider(
                        value: shadowOffset.dy,
                        min: -10.0,
                        max: 10.0,
                        divisions: 40,
                        label: '${shadowOffset.dy.toStringAsFixed(1)}px',
                        activeColor: Colors.blueAccent,
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
                      color: Colors.grey[700],
                    ),
                  ),
                  ValueListenableBuilder<double>(
                    valueListenable: _shadowBlurRadius,
                    builder: (context, blurRadius, child) {
                      return Slider(
                        value: blurRadius,
                        min: 0.0,
                        max: 20.0,
                        divisions: 40,
                        label: '${blurRadius.toStringAsFixed(1)}px',
                        activeColor: Colors.blueAccent,
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
                      color: Colors.grey[700],
                    ),
                  ),
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
                                      ? Colors.blueAccent
                                      : Colors.grey[300]!,
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


/*import 'package:cardmaker/app/features/editor/controller.dart';
import 'package:cardmaker/stack_board/lib/stack_items.dart';
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
  late TextEditingController _textController;
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
    'assets/Farman.png',
    'assets/Farman.png',
    'assets/Farman.png',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this);
    _textController = TextEditingController(
      text: widget.textItem.content?.data ?? '',
    );
    _initializeTextProperties();
    _textController.addListener(_updateTextItem);
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
  }

  void _updateTextItem() {
    final updatedContent = widget.textItem.content?.copyWith(
      data: _textController.text.isEmpty ? 'Text' : _textController.text,
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
    );

    if (updatedContent == null) {
      print('Error: updatedContent is null');
      return;
    }

    // Measure text dimensions using TextPainter
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

    const double maxWidth = 300.0;
    painter.layout(maxWidth: maxWidth);

    final width = painter.width.clamp(100.0, maxWidth);
    final height = painter.height.clamp(50.0, double.infinity);

    // Preserve offset explicitly
    final updatedItem = widget.textItem.copyWith(
      content: updatedContent,
      size: Size(width, height),
      offset: widget.textItem.offset, // Explicitly preserve offset
    );

    // Update StackBoard and sync activeItem
    print(
      'Before update: item=${updatedItem.id}, offset=${updatedItem.offset}, font=${updatedContent.googleFont}',
    );
    controller.boardController.updateItem(updatedItem);
    if (controller.activeItem.value?.id == updatedItem.id) {
      controller.activeItem.value = updatedItem;
    }

    print(
      'Updated ID: ${updatedItem.id}, '
      'Size: ${width.toStringAsFixed(1)} x ${height.toStringAsFixed(1)}, '
      'Text: ${updatedContent.data}, '
      'Font: ${updatedContent.googleFont}, '
      'Offset: dx: ${updatedItem.offset.dx}, dy: ${updatedItem.offset.dy}',
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Text Input Field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Enter text here',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
              ),
              maxLines: 1,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          // Tab Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: TabBar(
              controller: _tabController,
              tabAlignment: TabAlignment.start,
              isScrollable: true,
              indicatorColor: Colors.blueAccent,
              labelColor: Colors.blueAccent,
              unselectedLabelColor: Colors.grey[600],
              indicatorWeight: 2,
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(icon: Icon(Icons.font_download, size: 16), text: 'Font'),
                Tab(icon: Icon(Icons.format_size, size: 16), text: 'Size'),
                Tab(
                  icon: Icon(Icons.format_align_left, size: 16),
                  text: 'Align',
                ),
                Tab(icon: Icon(Icons.palette, size: 16), text: 'Color'),
                Tab(icon: Icon(Icons.format_color_fill, size: 16), text: 'BG'),
                Tab(icon: Icon(Icons.format_bold, size: 16), text: 'Style'),
                Tab(icon: Icon(Icons.tune, size: 16), text: 'Spacing'),
                Tab(icon: Icon(Icons.image, size: 16), text: 'Mask'),
                Tab(icon: Icon(Icons.blur_on, size: 16), text: 'Effects'),
              ],
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFontTab(),
                _buildSizeTab(),
                _buildAlignmentTab(),
                _buildColorTab(),
                _buildBackgroundTab(),
                _buildStyleTab(),
                _buildSpacingTab(),
                _buildMaskTab(),
                _buildEffectsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
                  showCheckmark: false,
                  visualDensity: VisualDensity.comfortable,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 0,
                  ),
                  label: Text(
                    font,
                    style: GoogleFonts.getFont(font, fontSize: 12),
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
                return Slider(
                  value: fontSize,
                  min: 8,
                  max: 72,
                  divisions: 64,
                  label: '${fontSize.round()}px',
                  activeColor: Colors.blueAccent,
                  onChanged: (value) {
                    _fontSize.value = value;
                    _updateTextItem();
                  },
                );
              },
            ),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [12, 16, 20, 24, 32, 48].map((size) {
                return ValueListenableBuilder<double>(
                  valueListenable: _fontSize,
                  builder: (context, fontSize, child) {
                    final isSelected = fontSize.round() == size;
                    return GestureDetector(
                      onTap: () {
                        _fontSize.value = size.toDouble();
                        _updateTextItem();
                      },
                      child: Chip(
                        label: Text(
                          '${size}px',
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[800],
                            fontSize: 10,
                          ),
                        ),
                        backgroundColor: isSelected
                            ? Colors.blueAccent
                            : Colors.grey[100],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
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
          color: isSelected ? Colors.blueAccent : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[800],
              size: 16,
            ),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[800],
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
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildStyleTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                          child: Chip(
                            label: Text(
                              label,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[800],
                                fontWeight: weight,
                                fontSize: 10,
                              ),
                            ),
                            backgroundColor: isSelected
                                ? Colors.blueAccent
                                : Colors.grey[100],
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                          ),
                        );
                      }).toList(),
                );
              },
            ),
            const SizedBox(height: 8),
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
                            color: isItalic
                                ? Colors.blueAccent
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.format_italic,
                                color: isItalic
                                    ? Colors.white
                                    : Colors.grey[800],
                                size: 16,
                              ),
                              Text(
                                'Italic',
                                style: TextStyle(
                                  color: isItalic
                                      ? Colors.white
                                      : Colors.grey[800],
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
                                ? Colors.blueAccent
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.format_underline,
                                color: isUnderlined
                                    ? Colors.white
                                    : Colors.grey[800],
                                size: 16,
                              ),
                              Text(
                                'Underline',
                                style: TextStyle(
                                  color: isUnderlined
                                      ? Colors.white
                                      : Colors.grey[800],
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
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder<double>(
              valueListenable: _letterSpacing,
              builder: (context, letterSpacing, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Letter Spacing',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    Slider(
                      value: letterSpacing,
                      min: -2.0,
                      max: 8.0,
                      divisions: 100,
                      label: '${letterSpacing.toStringAsFixed(1)}px',
                      activeColor: Colors.blueAccent,
                      onChanged: (value) {
                        _letterSpacing.value = value;
                        _updateTextItem();
                      },
                    ),
                  ],
                );
              },
            ),
            ValueListenableBuilder<double>(
              valueListenable: _lineHeight,
              builder: (context, lineHeight, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Line Height',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    Slider(
                      value: lineHeight,
                      min: 0.8,
                      max: 3.0,
                      divisions: 44,
                      label: '${lineHeight.toStringAsFixed(1)}x',
                      activeColor: Colors.blueAccent,
                      onChanged: (value) {
                        _lineHeight.value = value;
                        _updateTextItem();
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaskTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Image Mask',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
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
                              ? Colors.blueAccent
                              : Colors.grey[300]!,
                          width: maskImage == null && _maskColor.value == null
                              ? 2
                              : 1,
                        ),
                      ),
                      child: Icon(
                        Icons.clear,
                        color: maskImage == null && _maskColor.value == null
                            ? Colors.blueAccent
                            : Colors.grey,
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
                                ? Colors.blueAccent
                                : Colors.grey[300]!,
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
          const SizedBox(height: 16),
          Text(
            'Color Mask',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
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
                      // _maskColor.value abode: text_styling_editor.dart
                      // _maskImage.value = null;
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

  Widget _buildEffectsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: _hasShadow,
            builder: (context, hasShadow, child) {
              return SwitchListTile(
                title: Text(
                  'Text Shadow',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                value: hasShadow,
                activeColor: Colors.blueAccent,
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
              if (!hasShadow) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shadow Offset X',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  ValueListenableBuilder<Offset>(
                    valueListenable: _shadowOffset,
                    builder: (context, shadowOffset, child) {
                      return Slider(
                        value: shadowOffset.dx,
                        min: -10.0,
                        max: 10.0,
                        divisions: 40,
                        label: '${shadowOffset.dx.toStringAsFixed(1)}px',
                        activeColor: Colors.blueAccent,
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
                      color: Colors.grey[700],
                    ),
                  ),
                  ValueListenableBuilder<Offset>(
                    valueListenable: _shadowOffset,
                    builder: (context, shadowOffset, child) {
                      return Slider(
                        value: shadowOffset.dy,
                        min: -10.0,
                        max: 10.0,
                        divisions: 40,
                        label: '${shadowOffset.dy.toStringAsFixed(1)}px',
                        activeColor: Colors.blueAccent,
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
                      color: Colors.grey[700],
                    ),
                  ),
                  ValueListenableBuilder<double>(
                    valueListenable: _shadowBlurRadius,
                    builder: (context, blurRadius, child) {
                      return Slider(
                        value: blurRadius,
                        min: 0.0,
                        max: 20.0,
                        divisions: 40,
                        label: '${blurRadius.toStringAsFixed(1)}px',
                        activeColor: Colors.blueAccent,
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
                      color: Colors.grey[700],
                    ),
                  ),
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
 */