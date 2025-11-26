import 'package:cardmaker/app/features/editor/chart_editor/chart_editor_controller.dart';
import 'package:cardmaker/app/features/editor/controller.dart';
import 'package:cardmaker/app/features/editor/widgets/panel_action_button.dart';
import 'package:cardmaker/core/values/enums.dart';
import 'package:cardmaker/widgets/common/compact_slider.dart';
import 'package:cardmaker/widgets/common/quick_color_picker.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/src/stack_board_items/items/stack_chart_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChartEditorPanel extends StatelessWidget {
  final StackChartItem? chartItem;
  final VoidCallback onClose;

  final ChartEditorController controller = Get.put(ChartEditorController());
  final CanvasController canvasController = Get.find();

  ChartEditorPanel({super.key, this.chartItem, required this.onClose});

  @override
  Widget build(BuildContext context) {
    // Initialize controller based on whether we're adding or editing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (chartItem != null) {
        controller.initWithItem(chartItem!);
      } else {
        controller.resetForNewChart();
      }
    });

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onClose,
      child: Material(
        child: Container(
          constraints: const BoxConstraints(maxHeight: 280),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              Expanded(
                child: GetBuilder<ChartEditorController>(
                  id: 'chart_editor',
                  builder: (controller) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Column(
                        children: [
                          _buildChartTypeSection(controller),
                          const SizedBox(height: 8),
                          _buildProgressSection(controller),
                          const SizedBox(height: 8),
                          _buildAppearanceSection(controller),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(
          bottom: BorderSide(
            color: Get.theme.colorScheme.outline.withOpacity(0.1),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.bar_chart_rounded,
            size: 16,
            color: Get.theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            chartItem == null ? 'Add Chart' : 'Edit Chart',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Get.theme.colorScheme.onSurface,
              letterSpacing: 0.2,
            ),
          ),
          const Spacer(),
          PanelActionButton(
            icon: Icons.delete_outline,
            label: 'Delete',
            isDestructive: true,
            onPressed: canvasController.deleteActiveItem,
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded, size: 16),
            style: IconButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(32, 32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartTypeSection(ChartEditorController controller) {
    return _buildSection(
      'Type',
      Icons.analytics_outlined,
      child: Row(
        children: ChartType.values.map((type) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Obx(() {
                final isSelected = controller.chartType.value == type;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => controller.updateChartType(type),
                    borderRadius: BorderRadius.circular(8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Get.theme.colorScheme.primary
                            : Get.theme.colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? Get.theme.colorScheme.primary
                              : Get.theme.colorScheme.outline.withOpacity(0.15),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getChartTypeIcon(type),
                            size: 15,
                            color: isSelected
                                ? Get.theme.colorScheme.onPrimary
                                : Get.theme.colorScheme.onSurface.withOpacity(
                                    0.8,
                                  ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getChartTypeName(type),
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Get.theme.colorScheme.onPrimary
                                  : Get.theme.colorScheme.onSurface.withOpacity(
                                      0.8,
                                    ),
                              letterSpacing: 0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProgressSection(ChartEditorController controller) {
    return _buildSection(
      'Settings',
      Icons.tune_rounded,
      child: Column(
        children: [
          Obx(
            () => CompactSlider(
              icon: Icons.percent_rounded,
              value: controller.value.value,
              min: 0,
              max: 100,
              onChanged: controller.updateValue,
            ),
          ),
          const SizedBox(height: 5),
          Obx(
            () => CompactSlider(
              icon: Icons.line_weight_rounded,
              value: controller.thickness.value,
              min: 1,
              max: 50,
              onChanged: controller.updateThickness,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection(ChartEditorController controller) {
    return _buildSection(
      'Colors',
      Icons.palette_outlined,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => _buildColorPicker(
                    'BG',
                    controller.backgroundColor.value,
                    controller.updateBackgroundColor,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Obx(
                  () => _buildColorPicker(
                    'Progress',
                    controller.progressColor.value,
                    controller.updateProgressColor,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Obx(
                  () => _buildColorPicker(
                    'Text',
                    controller.textColor.value,
                    controller.updateTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => _buildCompactSwitch(
                    'Text',
                    Icons.text_fields_rounded,
                    controller.showValueText.value,
                    controller.updateShowValueText,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Obx(
                  () => _buildCompactSwitch(
                    'Glow',
                    Icons.auto_awesome_rounded,
                    controller.glowEffect.value,
                    controller.updateGlowEffect,
                  ),
                ),
              ),
            ],
          ),
          Obx(() {
            if (controller.chartType.value == ChartType.linearProgress) {
              return Padding(
                padding: const EdgeInsets.only(top: 5),
                child: CompactSlider(
                  icon: Icons.rounded_corner,
                  value: controller.cornerRadius.value,
                  min: 0,
                  max: 50,
                  onChanged: controller.updateCornerRadius,
                ),
              );
            }
            return const SizedBox();
          }),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, {required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5, left: 2),
          child: Row(
            children: [
              Icon(
                icon,
                size: 13,
                color: Get.theme.colorScheme.primary.withOpacity(0.8),
              ),
              const SizedBox(width: 5),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Get.theme.colorScheme.onSurface.withOpacity(0.85),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            // color: Get.theme.colorScheme.surfaceContainerHigh.withOpacity(0.4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Get.theme.colorScheme.outline.withOpacity(0.1),
              width: 0.5,
            ),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildColorPicker(
    String label,
    Color color,
    Function(Color) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 4),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showColorPicker(label, color, onChanged),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: double.infinity,
              height: 26,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Get.theme.colorScheme.outline.withOpacity(0.25),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
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

  Widget _buildCompactSwitch(
    String label,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: Get.theme.colorScheme.outline.withOpacity(0.12),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 13,
            color: Get.theme.colorScheme.onSurface.withOpacity(0.75),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Get.theme.colorScheme.onSurface.withOpacity(0.85),
                letterSpacing: 0.1,
              ),
            ),
          ),
          Transform.scale(
            scale: 0.75,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: Get.theme.colorScheme.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  void _showColorPicker(
    String title,
    Color currentColor,
    Function(Color) onChanged,
  ) {
    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickColorPicker(
        title: title,
        currentColor: currentColor,
        onChanged: (color) => onChanged(color!),
      ),
    );
  }

  IconData _getChartTypeIcon(ChartType type) {
    switch (type) {
      case ChartType.linearProgress:
        return Icons.linear_scale_rounded;
      case ChartType.circularProgress:
        return Icons.donut_large_rounded;
      case ChartType.radialProgress:
        return Icons.radio_button_unchecked_rounded;
    }
  }

  String _getChartTypeName(ChartType type) {
    switch (type) {
      case ChartType.linearProgress:
        return 'Linear';
      case ChartType.circularProgress:
        return 'Circular';
      case ChartType.radialProgress:
        return 'Radial';
    }
  }
}
