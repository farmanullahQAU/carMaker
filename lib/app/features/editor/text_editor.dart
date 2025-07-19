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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
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
  }

  // void _updateTextItem() {
  //   final updatedContent = widget.textItem.content?.copyWith(
  //     googleFont: _selectedFont.value,
  //     style: TextStyle(
  //       fontFamily: GoogleFonts.getFont(_selectedFont.value).fontFamily,
  //       fontSize: _fontSize.value,
  //       letterSpacing: _letterSpacing.value,
  //       height: _lineHeight.value,
  //       color: _textColor.value,
  //       backgroundColor: _backgroundColor.value,
  //       fontWeight: _fontWeight.value,
  //       fontStyle: _isItalic.value ? FontStyle.italic : FontStyle.normal,
  //       decoration: _isUnderlined.value
  //           ? TextDecoration.underline
  //           : TextDecoration.none,
  //     ),
  //     textAlign: _textAlign.value,
  //   );

  //   if (updatedContent == null) {
  //     print('Error: updatedContent is null');
  //     return;
  //   }

  //   final updatedItem = widget.textItem.copyWith(content: updatedContent);
  //   print(
  //     'TextStylingEditor: Updating item ID: ${updatedItem.id}, '
  //     'backgroundColor: ${updatedContent.style?.backgroundColor}, '
  //     'color: ${updatedContent.style?.color}, '
  //     'font: ${updatedContent.googleFont}',
  //   );

  //   // Update item and ensure reactivity
  //   controller.boardController.updateItem(updatedItem);
  //   // controller.boardController.refresh();
  //   // Workaround: Remove and re-add item to force update
  //   // controller.boardController.removeById(updatedItem.id);
  //   // controller.boardController.addItem(updatedItem);
  //   controller.boardController.updateBasic(
  //     updatedItem.id,
  //     status: StackItemStatus.selected,
  //     size: Size(
  //       updatedItem.size.width + (2 * updatedItem.content!.style!.fontSize!),
  //       (2 * updatedItem.content!.style!.fontSize!),
  //     ),
  //   );

  //   print('TextStylingEditor: Item re-added to force update');
  // }

  void _updateTextItem() {
    final updatedContent = widget.textItem.content?.copyWith(
      googleFont: _selectedFont.value,
      style: TextStyle(
        fontFamily: GoogleFonts.getFont(_selectedFont.value).fontFamily,
        fontSize: _fontSize.value,
        letterSpacing: _letterSpacing.value,
        height: _lineHeight.value,
        color: _textColor.value,
        backgroundColor: _backgroundColor.value,
        fontWeight: _fontWeight.value,
        fontStyle: _isItalic.value ? FontStyle.italic : FontStyle.normal,
        decoration: _isUnderlined.value
            ? TextDecoration.underline
            : TextDecoration.none,
      ),
      textAlign: _textAlign.value,
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
      textAlign: updatedContent.textAlign ?? TextAlign.center,
      maxLines: 2, // allow wrapping
    );

    // Provide a max width (you can customize this as needed)
    const double maxWidth = 300.0;
    painter.layout(maxWidth: maxWidth);

    final width = painter.size.width.clamp(100.0, maxWidth); // min 200, max 300
    final height = painter.size.height;

    controller.boardController.updateItem(updatedItem);

    controller.boardController.updateBasic(
      updatedItem.id,
      status: StackItemStatus.selected,
      size: Size(width, height),
    );

    print(
      'Updated ID: ${updatedItem.id}, '
      'Size: ${width.toStringAsFixed(1)} x ${height.toStringAsFixed(1)}, '
      'Font: ${updatedContent.googleFont}',
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          //   decoration: BoxDecoration(
          //     gradient: LinearGradient(
          //       colors: [Colors.blueAccent.withOpacity(0.1), Colors.white],
          //       begin: Alignment.topCenter,
          //       end: Alignment.bottomCenter,
          //     ),
          //     borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          //   ),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       Text(
          //         'Text Styling',
          //         style: TextStyle(
          //           fontSize: 14,
          //           fontWeight: FontWeight.w600,
          //           color: Colors.grey[900],
          //         ),
          //       ),
          //       IconButton(
          //         onPressed: widget.onClose,
          //         icon: Icon(Icons.close, color: Colors.grey[700], size: 18),
          //         padding: EdgeInsets.zero,
          //         constraints: BoxConstraints(),
          //       ),
          //     ],
          //   ),
          // ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4),
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
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
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
                    ],
                  ),
                ),
                // Container(
                //   padding: EdgeInsets.all(8),
                //   color: Colors.grey[100],
                //   child: AnimatedBuilder(
                //     animation: Listenable.merge([
                //       _selectedFont,
                //       _fontSize,
                //       _letterSpacing,
                //       _lineHeight,
                //       _textAlign,
                //       _textColor,
                //       _backgroundColor,
                //       _fontWeight,
                //       _isItalic,
                //       _isUnderlined,
                //     ]),
                //     builder: (context, _) {
                //       final previewContent = widget.textItem.content?.copyWith(
                //         googleFont: _selectedFont.value,
                //         style: TextStyle(
                //           fontFamily: GoogleFonts.getFont(
                //             _selectedFont.value,
                //           ).fontFamily,
                //           fontSize: _fontSize.value,
                //           letterSpacing: _letterSpacing.value,
                //           height: _lineHeight.value,
                //           color: _textColor.value,
                //           backgroundColor: _backgroundColor.value,
                //           fontWeight: _fontWeight.value,
                //           fontStyle: _isItalic.value
                //               ? FontStyle.italic
                //               : FontStyle.normal,
                //           decoration: _isUnderlined.value
                //               ? TextDecoration.underline
                //               : TextDecoration.none,
                //         ),
                //         textAlign: _textAlign.value,
                //       );
                //       return StackTextCase(
                //         item: widget.textItem.copyWith(content: previewContent),
                //         readOnly: true,
                //         enabled: false,
                //       );
                //     },
                //   ),
                // ),
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
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularFonts.map((font) {
              final isSelected = font == selectedFont;
              return GestureDetector(
                onTap: () {
                  _selectedFont.value = font;
                  _updateTextItem();
                },
                child: Container(
                  width: 120,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.blueAccent.withOpacity(0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.blueAccent : Colors.grey[200]!,
                    ),
                  ),
                  child: Text(
                    font,
                    style: GoogleFonts.getFont(font, fontSize: 12),
                  ),
                ),
              );
            }).toList(),
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
                      padding: EdgeInsets.zero,
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
                      padding: EdgeInsets.zero,

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

  String weightToString(FontWeight weight) {
    switch (weight) {
      case FontWeight.w300:
        return 'Light';
      case FontWeight.normal:
        return 'Normal';
      case FontWeight.w500:
        return 'Medium';
      case FontWeight.bold:
        return 'Bold';
      default:
        return 'Normal';
    }
  }
}
