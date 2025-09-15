// // Quick Color Picker Modal
// import 'package:flutter/material.dart';

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

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 200,
//       padding: const EdgeInsets.all(20),
//       decoration: const BoxDecoration(
//         // color: Color(0xFF1C1C1E),
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Text(
//                 title,
//                 style: const TextStyle(
//                   // color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const Spacer(),
//               GestureDetector(
//                 onTap: () => Navigator.pop(context),
//                 child: Container(
//                   width: 28,
//                   height: 28,
//                   decoration: BoxDecoration(
//                     // color: Colors.white.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                   child: const Icon(Icons.close, size: 16),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),

//           // Color Grid
//           Expanded(
//             child: GridView.builder(
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 8,
//                 crossAxisSpacing: 8,
//                 mainAxisSpacing: 8,
//               ),
//               itemCount: _getColorPalette().length,
//               itemBuilder: (context, index) {
//                 final color = _getColorPalette()[index];
//                 final isSelected = color?.value == currentColor?.value;

//                 return GestureDetector(
//                   onTap: () {
//                     onChanged(color);
//                     Navigator.pop(context);
//                   },
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 200),
//                     decoration: BoxDecoration(
//                       color: color ?? Colors.transparent,
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(
//                         color: isSelected
//                             ? Colors.blue
//                             : Colors.white.withOpacity(0.2),
//                         width: isSelected ? 2 : 1,
//                       ),
//                     ),
//                     child: color == null
//                         ? Icon(
//                             Icons.not_interested,
//                             color: Colors.white.withOpacity(0.6),
//                             size: 16,
//                           )
//                         : isSelected
//                         ? const Icon(Icons.check, color: Colors.white, size: 16)
//                         : null,
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   List<Color?> _getColorPalette() {
//     return Colors.primaries.toList();

//   }
// }
import 'package:cardmaker/core/values/app_colors.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.close, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Color Grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _getColorPalette().length,
              itemBuilder: (context, index) {
                final color = _getColorPalette()[index];
                final isSelected = color == currentColor;

                return GestureDetector(
                  onTap: () {
                    onChanged(color);
                    Navigator.pop(context);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.branding
                            : Colors.white.withOpacity(0.2),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: color == null || color == Colors.transparent
                        ? const Center(child: Icon(Icons.close))
                        : isSelected
                        ? const Icon(Icons.check, size: 16)
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Color?> _getColorPalette() {
    return [
      Colors.transparent, // Transparent/No color option
      Colors.white,
      Colors.black,
      Colors.grey,
      Colors.grey.shade300,
      Colors.grey.shade700,
      ...Colors.primaries.expand(
        (color) => [color, color.shade300, color.shade700],
      ),
    ];
  }
}

void showColorPicker({
  required BuildContext context,
  required Color? currentColor,
  required Function(Color?) onChanged,
  required String title,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
    ),
    builder: (context) => QuickColorPicker(
      title: title,
      currentColor: currentColor,
      onChanged: onChanged,
    ),
  );
}
