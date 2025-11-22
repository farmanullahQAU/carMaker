import 'package:cardmaker/app/features/editor/controller.dart';
import 'package:cardmaker/core/values/app_colors.dart';
import 'package:cardmaker/core/values/enums.dart';
import 'package:cardmaker/widgets/common/colors_selector.dart';
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
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
                  Icons.format_color_fill_rounded,
                  size: 18,
                  color: AppColors.branding,
                ),
                const SizedBox(width: 8),
                Text(
                  'Background',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const Spacer(),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      controller.activePanel.value = PanelType.none;
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (!hasBackgroundImage) ...[
              // Mode toggle: Gradient or Solid Color
              Obx(
                () => Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildModeButton(
                          context,
                          'Gradient',
                          Icons.gradient,
                          controller.isBackgroundGradient.value,
                          () => controller.setBackgroundMode(true),
                        ),
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: _buildModeButton(
                          context,
                          'Solid',
                          Icons.circle,
                          !controller.isBackgroundGradient.value,
                          () => controller.setBackgroundMode(false),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            Obx(() {
              if (!hasBackgroundImage &&
                  !controller.isBackgroundGradient.value) {
                // Solid Color Mode
                return ColorSelector(
                  title: "Background Color",
                  showTitle: false,
                  paddingx: 0,
                  colors: AppColors.predefinedColors,
                  currentColor: controller.backgroundColor.value,
                  onColorSelected: (color) {
                    controller.updateBackgroundColor(color);
                  },
                  selectedBorderColor: AppColors.branding,
                  itemSize: 30,
                  spacing: 5,
                );
              } else {
                // Gradient Mode (or has background image)
                return Column(
                  children: [
                    // Compact Hue/Gradient Slider
                    CompactSlider(
                      icon: hasBackgroundImage
                          ? Icons.colorize
                          : Icons.gradient,
                      label: hasBackgroundImage ? 'Hue' : 'Color Theme',
                      value: controller.backgroundHue.value,
                      min: 0.0,
                      max: 360.0,
                      onChanged: (value) {
                        controller.updateBackgroundHue(value);
                      },
                    ),
                    const SizedBox(height: 6),
                    // Preview with gradient
                    Container(
                      height: 28,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: _getPreviewGradient(
                          controller.backgroundHue.value,
                          hasBackgroundImage,
                        ),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.1),
                          width: 0.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          hasBackgroundImage
                              ? '${controller.backgroundHue.value.round()}°'
                              : 'Theme ${(controller.backgroundHue.value / 36).round() + 1}',
                          style: TextStyle(
                            color: _getTextColor(
                              controller.backgroundHue.value,
                            ),
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            letterSpacing: 0.3,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            }),
            const SizedBox(height: 10),
            // Background Image Options
            Obx(() {
              final hasBackgroundImage =
                  controller.selectedBackground.value != null;
              return Row(
                children: [
                  Expanded(
                    child: _buildImageActionButton(
                      context,
                      icon: hasBackgroundImage
                          ? Icons.image_outlined
                          : Icons.add_photo_alternate_outlined,
                      label: hasBackgroundImage ? 'Change' : 'Add Image',
                      onTap: () => controller.pickAndUpdateBackground(),
                    ),
                  ),
                  if (hasBackgroundImage) ...[
                    const SizedBox(width: 6),
                    _buildImageActionButton(
                      context,
                      icon: Icons.delete_outline_rounded,
                      label: 'Remove',
                      onTap: () => controller.removeBackgroundImage(),
                      isDestructive: true,
                    ),
                  ],
                ],
              );
            }),
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

  Color _getTextColor(double hueValue) {
    // Determine if text should be white or black based on background brightness
    final color = HSLColor.fromAHSL(1, hueValue, 1, 0.5).toColor();
    final brightness = ThemeData.estimateBrightnessForColor(color);
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }

  Widget _buildModeButton(
    BuildContext context,
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.branding : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 13,
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.withOpacity(0.08)
                : Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDestructive
                  ? Colors.red.withOpacity(0.25)
                  : Theme.of(context).colorScheme.outline.withOpacity(0.12),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isDestructive
                    ? Colors.red
                    : Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDestructive
                      ? Colors.red
                      : Theme.of(context).colorScheme.onSurface,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
