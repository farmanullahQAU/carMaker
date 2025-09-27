// chart_editor_panel.dart
import 'package:cardmaker/app/features/editor/chart_editor/chart_editor_controller.dart';
import 'package:cardmaker/app/features/editor/controller.dart';
import 'package:cardmaker/core/values/enums.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/src/stack_board_items/item_case/stack_chart_case.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/src/stack_board_items/items/stack_chart_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChartEditorPanel extends StatelessWidget {
  final StackChartItem? chartItem;
  final VoidCallback onClose;

  const ChartEditorPanel({super.key, this.chartItem, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final ChartEditorController controller = Get.put(ChartEditorController());

    // Initialize if item provided
    if (chartItem != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.initWithItem(chartItem!);
      });
    }

    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(controller),
          Expanded(
            child: GetBuilder<ChartEditorController>(
              id: 'chart_editor',
              builder: (controller) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildChartTypeSelector(controller),
                    const SizedBox(height: 20),
                    _buildProgressSettings(controller),
                    const SizedBox(height: 20),
                    _buildColorSettings(controller),
                    const SizedBox(height: 20),
                    _buildAppearanceSettings(controller),
                    const SizedBox(height: 20),
                    _buildPreview(controller),
                    const SizedBox(height: 10),
                    _buildActionButtons(controller),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ChartEditorController controller) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.primaryContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          const Icon(Icons.bar_chart, color: Colors.blue),
          const SizedBox(width: 12),
          Text(
            chartItem == null ? 'Add Chart' : 'Edit Chart',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(icon: const Icon(Icons.close), onPressed: onClose),
        ],
      ),
    );
  }

  Widget _buildChartTypeSelector(ChartEditorController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Chart Type', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: ChartType.values.map((type) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Obx(() {
                  final isSelected = controller.chartType.value == type;
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected
                          ? Get.theme.colorScheme.primary
                          : Get.theme.colorScheme.surface,
                      foregroundColor: isSelected
                          ? Colors.white
                          : Get.theme.colorScheme.onSurface,
                    ),
                    onPressed: () => controller.updateChartType(type),
                    child: Text(_getChartTypeName(type)),
                  );
                }),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProgressSettings(ChartEditorController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Progress Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildSlider(
          'Value: ${controller.value.value.toInt()}%',
          controller.value.value,
          0,
          controller.maxValue.value,
          controller.updateValue,
        ),
        _buildSlider(
          'Max Value: ${controller.maxValue.value.toInt()}',
          controller.maxValue.value,
          1,
          200,
          controller.updateMaxValue,
        ),
        _buildSlider(
          'Thickness: ${controller.thickness.value.toInt()}',
          controller.thickness.value,
          1,
          50,
          controller.updateThickness,
        ),
      ],
    );
  }

  Widget _buildColorSettings(ChartEditorController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Colors', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildColorRow(
          'Background',
          controller.backgroundColor,
          controller.updateBackgroundColor,
        ),
        _buildColorRow(
          'Progress',
          controller.progressColor,
          controller.updateProgressColor,
        ),
        _buildColorRow(
          'Text',
          controller.textColor.value,
          controller.updateTextColor,
        ),
      ],
    );
  }

  Widget _buildAppearanceSettings(ChartEditorController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Appearance', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text('Show Value Text'),
          value: controller.showValueText.value,
          onChanged: controller.updateShowValueText,
        ),
        SwitchListTile(
          title: const Text('Glow Effect'),
          value: controller.glowEffect.value,
          onChanged: controller.updateGlowEffect,
        ),
        Obx(() {
          if (controller.chartType.value == ChartType.linearProgress) {
            return _buildSlider(
              'Corner Radius: ${controller.cornerRadius.value.toInt()}',
              controller.cornerRadius.value,
              0,
              50,
              controller.updateCornerRadius,
            );
          }
          return const SizedBox();
        }),
      ],
    );
  }

  Widget _buildPreview(ChartEditorController controller) {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: StackChartCase(
        item: StackChartItem(
          size: const Size(200, 50),
          offset: Offset.zero,
          content: ChartItemContent(
            chartType: controller.chartType.value,
            value: controller.value.value,
            maxValue: controller.maxValue.value,
            backgroundColor: controller.backgroundColor,
            progressColor: controller.progressColor,
            showValueText: controller.showValueText.value,
            textColor: controller.textColor.value,
            thickness: controller.thickness.value,
            cornerRadius: controller.cornerRadius.value,
            glowEffect: controller.glowEffect.value,
          ),
        ),
      ),
    );
  }

  // In ChartEditorPanel, add this method
  Widget _buildActionButtons(ChartEditorController controller) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              final canvasController = Get.find<CanvasController>();
              if (chartItem == null) {
                // Add new chart
                canvasController.addChart(controller.chartType.value);
              } else {
                // Chart is already added, just close
                onClose();
              }
            },
            child: Text(chartItem == null ? 'Add Chart' : 'Apply Changes'),
          ),
        ),
      ],
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
      ],
    );
  }

  Widget _buildColorRow(String label, Color color, Function(Color) onChanged) {
    return ListTile(
      dense: true,
      leading: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey),
        ),
      ),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _showColorPicker(color, onChanged),
    );
  }

  void _showColorPicker(Color initialColor, Function(Color) onChanged) {
    showDialog(
      context: Get.context!,
      builder: (context) => SimpleDialog(
        title: const Text('Pick a color'),
        children: [_buildColorGrid(initialColor, onChanged)],
      ),
    );
  }

  Widget _buildColorGrid(Color currentColor, Function(Color) onChanged) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.cyan,
      Colors.indigo,
      Colors.brown,
      Colors.grey,
      Colors.black,
      Colors.white,
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: colors.map((color) {
          return GestureDetector(
            onTap: () {
              onChanged(color);
              Get.back();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: color == currentColor ? Colors.black : Colors.grey,
                  width: color == currentColor ? 3 : 1,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
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
