// import 'package:cardmaker/core/values/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_colorpicker/flutter_colorpicker.dart';

// // Predefined color palette for quick selection
// const List<Color> _quickPickColors = [
//   Colors.transparent,
//   Colors.white,
//   Colors.black,
//   Color(0xFF9E9E9E), // Grey 500
//   Color(0xFF607D8B), // Blue Grey 500
//   Color(0xFF795548), // Brown 500
//   Color(0xFFF44336), // Red 500
//   Color(0xFFFF9800), // Orange 500
//   Color(0xFFFFC107), // Amber 500
//   Color(0xFF4CAF50), // Green 500
//   Color(0xFF2196F3), // Blue 500
//   Color(0xFF3F51B5), // Indigo 500
//   Color(0xFF9C27B0), // Purple 500
//   Color(0xFFE91E63), // Pink 500
//   Color(0xFFFFD700), // Gold
//   Color(0xFF00CED1), // Dark Turquoise
//   Color(0xFF8A2BE2), // Blue Violet
//   Color(0xFFFFB6C1), // Light Pink
//   Color(0xFF98FB98), // Pale Green
//   Color(0xFFADD8E6), // Light Blue
// ];

// class QuickColorPicker extends StatelessWidget {
//   final String title;
//   final Color? currentColor;
//   final Function(Color?) onChanged;

//   const QuickColorPicker({
//     super.key,
//     required this.title,
//     required this.currentColor,
//     required this.onChanged,
//   });

//   void _showFullColorPicker(BuildContext context) {
//     Color pickerColor = currentColor ?? Colors.blue;

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(
//           'Custom Color Picker',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//             color: Colors.grey[800],
//           ),
//         ),
//         content: SingleChildScrollView(
//           child: ColorPicker(
//             pickerColor: pickerColor,
//             onColorChanged: (color) => pickerColor = color,
//             colorPickerWidth: 280,
//             pickerAreaHeightPercent: 1.0,
//             enableAlpha: false, // Disable opacity
//             displayThumbColor: true,
//             labelTypes: const [], // Remove labels
//             portraitOnly: true,
//             hexInputBar: false, // Remove hex input
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
//               onChanged(pickerColor);
//               Navigator.pop(context);
//               Navigator.pop(context); // Close the bottom sheet too
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.branding,
//               foregroundColor: Colors.white,
//             ),
//             child: const Text('Select Color'),
//           ),
//         ],
//       ),
//     );
//   }

//   Color? _getEffectiveColor(Color? color) {
//     if (color == null || color == Colors.transparent) return null;
//     return color;
//   }

//   Widget _buildColorIndicator(
//     Color? color,
//     bool isSelected,
//     BuildContext context,
//   ) {
//     final effectiveColor = _getEffectiveColor(color);

//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 200),
//       decoration: BoxDecoration(
//         color: effectiveColor ?? Colors.transparent,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: isSelected ? AppColors.branding : Colors.grey[300]!,
//           width: isSelected ? 3 : 2,
//         ),
//         boxShadow: [
//           if (isSelected)
//             BoxShadow(
//               color: AppColors.branding.withOpacity(0.3),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//         ],
//       ),
//       child: effectiveColor == null
//           ? Center(child: Icon(Icons.block, size: 20, color: Colors.grey[600]))
//           : isSelected
//           ? Center(
//               child: Icon(
//                 Icons.check,
//                 size: 20,
//                 color: _getContrastColor(effectiveColor),
//               ),
//             )
//           : null,
//     );
//   }

//   Color _getContrastColor(Color color) {
//     // Calculate the perceived brightness of the color
//     final brightness = color.computeLuminance();
//     return brightness > 0.5 ? Colors.black : Colors.white;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 380,
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 20,
//             offset: const Offset(0, -5),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header
//           Row(
//             children: [
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black87,
//                 ),
//               ),
//               const Spacer(),
//               IconButton(
//                 onPressed: () => Navigator.pop(context),
//                 icon: Container(
//                   width: 32,
//                   height: 32,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[100],
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Icon(Icons.close, size: 18, color: Colors.grey[600]),
//                 ),
//                 padding: EdgeInsets.zero,
//                 constraints: const BoxConstraints(),
//               ),
//             ],
//           ),

//           // Quick-pick color grid
//           Column(
//             mainAxisSize: MainAxisSize.min,

//             children: [
//               Expanded(
//                 child: GridView.builder(
//                   physics: const BouncingScrollPhysics(),
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 8,
//                     crossAxisSpacing: 12,
//                     mainAxisSpacing: 12,
//                     childAspectRatio: 1,
//                   ),
//                   itemCount: _quickPickColors.length + 1,
//                   itemBuilder: (context, index) {
//                     if (index == _quickPickColors.length) {
//                       // Custom color picker button
//                       return GestureDetector(
//                         onTap: () => _showFullColorPicker(context),
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.grey[50],
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(
//                               color: Colors.grey[300]!,
//                               width: 2,
//                             ),
//                           ),
//                           child: Center(
//                             child: Icon(
//                               Icons.colorize,
//                               size: 20,
//                               color: Colors.grey[700],
//                             ),
//                           ),
//                         ),
//                       );
//                     }

//                     final color = _quickPickColors[index];
//                     final isSelected = color == currentColor;

//                     return GestureDetector(
//                       onTap: () {
//                         onChanged(color);
//                         Navigator.pop(context);
//                       },
//                       child: _buildColorIndicator(color, isSelected, context),
//                     );
//                   },
//                 ),
//               ),

//               const SizedBox(height: 16),

//               // Current selection display
//               if (currentColor != null && currentColor != Colors.transparent)
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 12,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[50],
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Container(
//                         width: 20,
//                         height: 20,
//                         decoration: BoxDecoration(
//                           color: currentColor,
//                           borderRadius: BorderRadius.circular(6),
//                           border: Border.all(color: Colors.grey[300]!),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Text(
//                         'Selected: ${_colorToHex(currentColor!)}',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.grey[700],
//                           fontFamily: 'monospace',
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   String _colorToHex(Color color) {
//     return '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
//   }
// }
import 'package:cardmaker/core/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

// Predefined color palette for quick selection
const List<Color> _quickPickColors = [
  Colors.transparent,
  Colors.white,
  Colors.black,
  Color(0xFF9E9E9E), // Grey 500
  Color(0xFF607D8B), // Blue Grey 500
  Color(0xFF795548), // Brown 500
  Color(0xFFF44336), // Red 500
  Color(0xFFFF9800), // Orange 500
  Color(0xFFFFC107), // Amber 500
  Color(0xFF4CAF50), // Green 500
  Color(0xFF2196F3), // Blue 500
  Color(0xFF3F51B5), // Indigo 500
  Color(0xFF9C27B0), // Purple 500
  Color(0xFFE91E63), // Pink 500
  Color(0xFFFFD700), // Gold
  Color(0xFF00CED1), // Dark Turquoise
  Color(0xFF8A2BE2), // Blue Violet
  Color(0xFFFFB6C1), // Light Pink
  Color(0xFF98FB98), // Pale Green
  Color(0xFFADD8E6), // Light Blue
];

class QuickColorPicker extends StatelessWidget {
  final String title;
  final Color? currentColor;
  final Function(Color?) onChanged;

  const QuickColorPicker({
    super.key,
    required this.title,
    required this.currentColor,
    required this.onChanged,
  });

  void _showFullColorPicker(BuildContext context) {
    Color pickerColor = currentColor ?? Colors.blue;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Custom Color Picker',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (color) => pickerColor = color,
            colorPickerWidth: 280,
            pickerAreaHeightPercent: 1.0,
            enableAlpha: false, // Disable opacity
            displayThumbColor: true,
            labelTypes: const [], // Remove labels
            portraitOnly: true,
            hexInputBar: false, // Remove hex input
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
              onChanged(pickerColor);
              Navigator.pop(context);
              Navigator.pop(context); // Close the bottom sheet too
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.branding,
              foregroundColor: Colors.white,
            ),
            child: const Text('Select Color'),
          ),
        ],
      ),
    );
  }

  Color? _getEffectiveColor(Color? color) {
    if (color == null || color == Colors.transparent) return null;
    return color;
  }

  Widget _buildColorIndicator(
    Color? color,
    bool isSelected,
    BuildContext context,
  ) {
    final effectiveColor = _getEffectiveColor(color);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: effectiveColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.branding : Colors.grey[300]!,
          width: isSelected ? 3 : 2,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: AppColors.branding.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: effectiveColor == null
          ? Center(child: Icon(Icons.block, size: 20, color: Colors.grey[600]))
          : isSelected
          ? Center(
              child: Icon(
                Icons.check,
                size: 20,
                color: _getContrastColor(effectiveColor),
              ),
            )
          : null,
    );
  }

  Color _getContrastColor(Color color) {
    // Calculate the perceived brightness of the color
    final brightness = color.computeLuminance();
    return brightness > 0.5 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize:
            MainAxisSize.min, // Important: Make column size to content
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.close, size: 18, color: Colors.grey[600]),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Quick-pick color grid
          GridView.builder(
            shrinkWrap: true, // Important: Allow grid to shrink-wrap content
            physics:
                const NeverScrollableScrollPhysics(), // Disable grid scrolling
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: _quickPickColors.length + 1,
            itemBuilder: (context, index) {
              if (index == _quickPickColors.length) {
                // Custom color picker button
                return GestureDetector(
                  onTap: () => _showFullColorPicker(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!, width: 2),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.colorize,
                        size: 20,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                );
              }

              final color = _quickPickColors[index];
              final isSelected = color == currentColor;

              return GestureDetector(
                onTap: () {
                  onChanged(color);
                  Navigator.pop(context);
                },
                child: _buildColorIndicator(color, isSelected, context),
              );
            },
          ),

          const SizedBox(height: 16),

          // Current selection display
          if (currentColor != null && currentColor != Colors.transparent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: currentColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Selected: ${_colorToHex(currentColor!)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }
}
