// chart_editor_controller.dart
import 'package:cardmaker/app/features/editor/controller.dart';
import 'package:cardmaker/core/values/app_colors.dart';
import 'package:cardmaker/core/values/enums.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/src/stack_board_items/items/stack_chart_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChartEditorController extends GetxController {
  final CanvasController canvasController = Get.find();

  // Chart properties
  var chartType = ChartType.linearProgress.obs;
  var value = 75.0.obs;
  var maxValue = 100.0.obs;
  var backgroundColor = AppColors.branding;
  var progressColor = AppColors.accent;
  var showValueText = true.obs;
  var textColor = Colors.black.obs;
  var thickness = 10.0.obs;
  var cornerRadius = 0.0.obs;
  var glowEffect = false.obs;

  StackChartItem? currentChartItem;

  void updateChartType(ChartType type) {
    chartType.value = type;
    _updateCurrentChart();
  }

  void updateValue(double newValue) {
    value.value = newValue;
    _updateCurrentChart();
  }

  void updateMaxValue(double newValue) {
    maxValue.value = newValue;
    _updateCurrentChart();
  }

  void updateBackgroundColor(Color color) {
    backgroundColor = color;
    _updateCurrentChart();
  }

  void updateProgressColor(Color color) {
    progressColor = color;
    _updateCurrentChart();
  }

  void updateTextColor(Color color) {
    textColor.value = color;
    _updateCurrentChart();
  }

  void updateShowValueText(bool show) {
    showValueText.value = show;
    _updateCurrentChart();
  }

  void updateThickness(double newThickness) {
    thickness.value = newThickness;
    _updateCurrentChart();
  }

  void updateCornerRadius(double radius) {
    cornerRadius.value = radius;
    _updateCurrentChart();
  }

  void updateGlowEffect(bool glow) {
    glowEffect.value = glow;
    _updateCurrentChart();
  }

  void _updateCurrentChart() {
    if (currentChartItem != null) {
      final newContent = ChartItemContent(
        chartType: chartType.value,
        value: value.value,
        maxValue: maxValue.value,
        backgroundColor: backgroundColor,
        progressColor: progressColor,
        showValueText: showValueText.value,
        textColor: textColor.value,
        thickness: thickness.value,
        cornerRadius: cornerRadius.value,
        glowEffect: glowEffect.value,
      );

      final newItem = currentChartItem!.copyWith(content: newContent);
      canvasController.updateItem(newItem);
      update(['chart_editor']);
    }
  }

  void addChartToCanvas() {
    final content = ChartItemContent(
      chartType: chartType.value,
      value: value.value,
      maxValue: maxValue.value,
      backgroundColor: backgroundColor,
      progressColor: progressColor,
      showValueText: showValueText.value,
      textColor: textColor.value,
      thickness: thickness.value,
      cornerRadius: cornerRadius.value,
      glowEffect: glowEffect.value,
    );

    final chartItem = StackChartItem(
      id: UniqueKey().toString(),
      size: const Size(200, 80),
      offset: canvasController.getCenteredOffset(const Size(200, 80)),
      content: content,
    );

    canvasController.boardController.addItem(chartItem);
    canvasController.activeItem.value = chartItem;
    currentChartItem = chartItem;
  }

  void initWithItem(StackChartItem item) {
    currentChartItem = item;
    final content = item.content!;

    chartType.value = content.chartType;
    value.value = content.value;
    maxValue.value = content.maxValue;
    backgroundColor = content.backgroundColor;
    progressColor = content.progressColor;
    showValueText.value = content.showValueText;
    textColor.value = content.textColor;
    thickness.value = content.thickness;
    cornerRadius.value = content.cornerRadius;
    glowEffect.value = content.glowEffect;

    update(['chart_editor']);
  }
}
