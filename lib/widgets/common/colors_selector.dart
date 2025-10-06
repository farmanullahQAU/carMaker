// import 'package:cardmaker/core/values/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_colorpicker/flutter_colorpicker.dart';

// class ColorSelector extends StatelessWidget {
//   final String title;
//   final List<Color> colors;
//   final Color currentColor;
//   final ValueChanged<Color> onColorSelected;
//   final double itemSize;
//   final double spacing;
//   final double borderWidth;
//   final Color? selectedBorderColor;
//   final double iconSize;
//   final bool showTitle;
//   final double? paddingx;
//   final bool
//   showColorPicker; // New parameter to control color picker visibility

//   const ColorSelector({
//     super.key,
//     required this.title,
//     required this.colors,
//     required this.currentColor,
//     required this.onColorSelected,
//     this.itemSize = 36,
//     this.spacing = 8,
//     this.borderWidth = 2,
//     this.selectedBorderColor,
//     this.iconSize = 14,
//     this.showTitle = true,
//     this.paddingx = 0,
//     this.showColorPicker = true, // Default to true
//   });

//   void _showColorPickerDialog(BuildContext context) {
//     Color pickerColor = currentColor;

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(
//           'Choose Custom Color',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: Colors.grey[800],
//           ),
//         ),
//         content: SingleChildScrollView(
//           child: ColorPicker(
//             pickerColor: pickerColor,
//             onColorChanged: (color) => pickerColor = color,
//             colorPickerWidth: 300,
//             pickerAreaHeightPercent: 0.7,
//             enableAlpha: false,
//             displayThumbColor: true,
//             labelTypes: const [],
//             portraitOnly: true,
//             hexInputBar: false,
//             pickerAreaBorderRadius: BorderRadius.circular(8),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               onColorSelected(pickerColor);
//               Navigator.pop(context);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.branding,
//               foregroundColor: Colors.white,
//             ),
//             child: const Text('Select'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final Color borderColor =
//         selectedBorderColor ?? Theme.of(context).primaryColor;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         if (showTitle)
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Text(
//               title,
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.grey.shade700,
//               ),
//             ),
//           ),
//         SizedBox(
//           height: itemSize,
//           child: ListView.separated(
//             padding: EdgeInsets.symmetric(horizontal: paddingx!),
//             scrollDirection: Axis.horizontal,
//             itemCount:
//                 colors.length +
//                 (showColorPicker ? 1 : 0), // Add 1 for color picker
//             separatorBuilder: (_, __) => SizedBox(width: spacing),
//             itemBuilder: (context, index) {
//               // Color picker button (last item)
//               if (showColorPicker && index == colors.length) {
//                 return GestureDetector(
//                   onTap: () => _showColorPickerDialog(context),
//                   child: Container(
//                     width: itemSize,
//                     height: itemSize,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[50],
//                       shape: BoxShape.circle,
//                       border: Border.all(color: Colors.grey.shade300, width: 1),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.1),
//                           blurRadius: 2,
//                           offset: const Offset(0, 1),
//                         ),
//                       ],
//                     ),
//                     child: Icon(
//                       Icons.colorize,
//                       size: iconSize,
//                       color: Colors.grey.shade700,
//                     ),
//                   ),
//                 );
//               }

//               // Regular color items
//               final color = colors[index];
//               final isSelected = color == currentColor;

//               if (index == 0) {
//                 return GestureDetector(
//                   onTap: () => onColorSelected(color),
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 150),
//                     width: itemSize,
//                     height: itemSize,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                         color: isSelected
//                             ? AppColors.branding
//                             : AppColors.highlight.withOpacity(0.3),
//                         width: isSelected ? 1 : 0.5,
//                       ),
//                     ),
//                     child: Icon(
//                       Icons.clear,
//                       color: isSelected
//                           ? AppColors.accent
//                           : AppColors.highlight.withOpacity(0.6),
//                       size: 14,
//                     ),
//                   ),
//                 );
//               }

//               return GestureDetector(
//                 onTap: () => onColorSelected(color),
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 150),
//                   width: itemSize,
//                   height: itemSize,
//                   decoration: BoxDecoration(
//                     color: color,
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: isSelected ? borderColor : Colors.transparent,
//                       width: isSelected ? borderWidth : 0,
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 2,
//                         offset: const Offset(0, 1),
//                       ),
//                     ],
//                   ),
//                   child: isSelected
//                       ? Center(
//                           child: Icon(
//                             Icons.check,
//                             size: iconSize,
//                             color: color.computeLuminance() > 0.5
//                                 ? Colors.black
//                                 : Colors.white,
//                           ),
//                         )
//                       : null,
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:cardmaker/core/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorSelector extends StatefulWidget {
  final String title;
  final List<Color> colors;
  final Color currentColor;
  final ValueChanged<Color> onColorSelected;
  final double itemSize;
  final double spacing;
  final double borderWidth;
  final Color? selectedBorderColor;
  final double iconSize;
  final bool showTitle;
  final double? paddingx;
  final bool showColorPicker;
  final int maxCustomColors; // Maximum number of custom colors to store

  const ColorSelector({
    super.key,
    required this.title,
    required this.colors,
    required this.currentColor,
    required this.onColorSelected,
    this.itemSize = 36,
    this.spacing = 8,
    this.borderWidth = 2,
    this.selectedBorderColor,
    this.iconSize = 14,
    this.showTitle = true,
    this.paddingx = 0,
    this.showColorPicker = true,
    this.maxCustomColors = 5, // Limit custom colors to avoid clutter
  });

  @override
  State<ColorSelector> createState() => _ColorSelectorState();
}

class _ColorSelectorState extends State<ColorSelector> {
  final List<Color> _customColors = []; // Store custom selected colors

  void _showColorPickerDialog(BuildContext context) {
    Color pickerColor = widget.currentColor;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Choose Custom Color',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (color) => pickerColor = color,
            colorPickerWidth: 300,
            pickerAreaHeightPercent: 0.7,
            enableAlpha: false,
            displayThumbColor: true,
            labelTypes: const [],
            portraitOnly: true,
            hexInputBar: false,
            pickerAreaBorderRadius: BorderRadius.circular(8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _handleColorSelection(pickerColor);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.branding,
              foregroundColor: Colors.white,
            ),
            child: const Text('Select'),
          ),
        ],
      ),
    );
  }

  void _handleColorSelection(Color color) {
    // Check if color is not in the predefined list
    final bool isCustomColor = !widget.colors.contains(color);

    if (isCustomColor) {
      // Add to custom colors if not already present
      if (!_customColors.contains(color)) {
        setState(() {
          _customColors.insert(0, color); // Add at beginning

          // Limit the number of custom colors
          if (_customColors.length > widget.maxCustomColors) {
            _customColors.removeLast();
          }
        });
      }
    }

    // Call the parent callback
    widget.onColorSelected(color);
  }

  bool _isColorInList(Color color, List<Color> list) {
    return list.any((c) => c.value == color.value);
  }

  @override
  Widget build(BuildContext context) {
    final Color borderColor =
        widget.selectedBorderColor ?? Theme.of(context).primaryColor;

    // Combine predefined colors and custom colors
    final allColors = [...widget.colors, ..._customColors];
    final uniqueColors = allColors.toSet().toList(); // Remove duplicates

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.showTitle)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),

        SizedBox(
          height: widget.itemSize,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: widget.paddingx!),
            scrollDirection: Axis.horizontal,
            itemCount: uniqueColors.length + (widget.showColorPicker ? 1 : 0),
            separatorBuilder: (_, __) => SizedBox(width: widget.spacing),
            itemBuilder: (context, index) {
              // Color picker button (last item)
              if (widget.showColorPicker && index == uniqueColors.length) {
                return GestureDetector(
                  onTap: () => _showColorPickerDialog(context),
                  child: Container(
                    width: widget.itemSize,
                    height: widget.itemSize,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.colorize,
                      size: widget.iconSize,
                      color: Colors.grey.shade700,
                    ),
                  ),
                );
              }

              // Color items
              final color = uniqueColors[index];
              final isSelected = color == widget.currentColor;
              final isCustomColor = _customColors.contains(color);

              // First item (clear/transparent button)
              if (index == 0 && color == Colors.transparent) {
                return GestureDetector(
                  onTap: () => _handleColorSelection(color),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: widget.itemSize,
                    height: widget.itemSize,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.branding
                            : AppColors.highlight.withOpacity(0.3),
                        width: isSelected ? 1 : 0.5,
                      ),
                    ),
                    child: Icon(
                      Icons.clear,
                      color: isSelected
                          ? AppColors.accent
                          : AppColors.highlight.withOpacity(0.6),
                      size: 14,
                    ),
                  ),
                );
              }

              return Stack(
                children: [
                  GestureDetector(
                    onTap: () => _handleColorSelection(color),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: widget.itemSize,
                      height: widget.itemSize,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? borderColor : Colors.transparent,
                          width: isSelected ? widget.borderWidth : 0,
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
                          ? Center(
                              child: Icon(
                                Icons.check,
                                size: widget.iconSize,
                                color: color.computeLuminance() > 0.5
                                    ? Colors.black
                                    : Colors.white,
                              ),
                            )
                          : null,
                    ),
                  ),

                  // Custom color indicator (small dot)
                  if (isCustomColor)
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.shade400,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),

        // Show hint for custom colors
        // if (_customColors.isNotEmpty)
        //   Padding(
        //     padding: const EdgeInsets.only(left: 8.0, top: 4.0),
        //     child: Text(
        //       '• Custom colors are saved automatically',
        //       style: TextStyle(
        //         fontSize: 10,
        //         color: Colors.grey.shade600,
        //         fontStyle: FontStyle.italic,
        //       ),
        //     ),
        //   ),
      ],
    );
  }
}
