import 'package:cardmaker/app/features/editor/controller.dart';
import 'package:cardmaker/core/values/app_colors.dart';
import 'package:cardmaker/core/values/enums.dart';
import 'package:cardmaker/widgets/common/compact_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class HueAdjustmentPanel extends StatelessWidget {
  final CanvasController controller;

  const HueAdjustmentPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasBackgroundImage = controller.selectedBackground.value != null;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasBackgroundImage ? Icons.colorize : Icons.gradient,
                  size: 20,
                  color: AppColors.branding,
                ),
                const SizedBox(width: 8),
                Text(
                  hasBackgroundImage ? 'Hue Adjustment' : 'Gradient Background',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                Spacer(),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      controller.activePanel.value = PanelType.none;
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.close_rounded, size: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                // Compact Hue/Gradient Slider
                CompactSlider(
                  icon: hasBackgroundImage ? Icons.colorize : Icons.gradient,
                  label: hasBackgroundImage ? 'Hue' : 'Color Theme',
                  value: controller.backgroundHue.value,
                  min: 0.0,
                  max: 360.0,
                  onChanged: (value) {
                    controller.updateBackgroundHue(value);
                  },
                ),
                const SizedBox(height: 8),
                // Preview with gradient
                Container(
                  height: 24,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: _getPreviewGradient(
                      controller.backgroundHue.value,
                      hasBackgroundImage,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      hasBackgroundImage
                          ? '${controller.backgroundHue.value.round()}°'
                          : 'Theme ${(controller.backgroundHue.value / 36).round() + 1}',
                      style: TextStyle(
                        color: _getTextColor(controller.backgroundHue.value),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (!hasBackgroundImage) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Drag to change gradient colors',
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ],
        ),
      );
    });
  }

  LinearGradient _getPreviewGradient(double hueValue, bool hasBackgroundImage) {
    if (hasBackgroundImage) {
      // For images, show a simple hue preview
      return LinearGradient(
        colors: [
          HSLColor.fromAHSL(1, hueValue, 1, 0.5).toColor(),
          HSLColor.fromAHSL(1, hueValue, 0.8, 0.7).toColor(),
        ],
      );
    } else {
      // Default case: transparent gradient for hueValue == 0
      if (hueValue == 0.0) {
        return const LinearGradient(colors: [Colors.white, Colors.white]);
      }

      // Dynamic gradient generation for all hues
      final baseColor = HSLColor.fromAHSL(1, hueValue, 0.9, 0.5).toColor();
      final lighterColor = HSLColor.fromAHSL(
        1,
        (hueValue + 20) % 360,
        0.8,
        0.7,
      ).toColor();
      final darkerColor = HSLColor.fromAHSL(
        1,
        (hueValue - 20) % 360,
        0.8,
        0.3,
      ).toColor();

      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [lighterColor, baseColor, darkerColor],
        stops: const [0.0, 0.5, 1.0],
      );
    }
  }

  // LinearGradient _getPreviewGradient(double hueValue, bool hasBackgroundImage) {
  //   if (!hasBackgroundImage) {
  //     if (hueValue == 0.0) {
  //       return const LinearGradient(colors: [Colors.white, Colors.white]);
  //     }

  //     final baseColor = HSLColor.fromAHSL(1, hueValue, 1, 0.5).toColor();
  //     final lighterColor = HSLColor.fromAHSL(1, hueValue, 0.8, 0.7).toColor();
  //     final darkerColor = HSLColor.fromAHSL(1, hueValue, 0.8, 0.3).toColor();

  //     return LinearGradient(colors: [lighterColor, baseColor, darkerColor]);
  //   } else {
  //     // For images, show a simple hue preview
  //     return LinearGradient(
  //       colors: [
  //         HSLColor.fromAHSL(1, hueValue, 1, 0.5).toColor(),
  //         HSLColor.fromAHSL(1, hueValue, 0.8, 0.7).toColor(),
  //       ],
  //     );
  //   }
  // }

  Color _getTextColor(double hueValue) {
    // Determine if text should be white or black based on background brightness
    final color = HSLColor.fromAHSL(1, hueValue, 1, 0.5).toColor();
    final brightness = ThemeData.estimateBrightnessForColor(color);
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }
}
