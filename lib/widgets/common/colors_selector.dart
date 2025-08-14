import 'package:cardmaker/core/values/app_colors.dart';
import 'package:flutter/material.dart';

class ColorSelector extends StatelessWidget {
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
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor =
        selectedBorderColor ?? Theme.of(context).primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (showTitle)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        // if (showTitle) const SizedBox(height: 8),
        SizedBox(
          height: itemSize,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: paddingx!),
            scrollDirection: Axis.horizontal,
            itemCount: colors.length,
            separatorBuilder: (_, __) => SizedBox(width: spacing),
            itemBuilder: (context, index) {
              final color = colors[index];
              final isSelected = color == currentColor;
              if (index == 0) {
                return GestureDetector(
                  onTap: () => onColorSelected(color),

                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: itemSize,
                    height: itemSize,
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
              return GestureDetector(
                onTap: () => onColorSelected(color),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: itemSize,
                  height: itemSize,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? borderColor : Colors.transparent,
                      width: isSelected ? borderWidth : 0,
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
                            size: iconSize,
                            color: color.computeLuminance() > 0.5
                                ? Colors.black
                                : Colors.white,
                          ),
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
