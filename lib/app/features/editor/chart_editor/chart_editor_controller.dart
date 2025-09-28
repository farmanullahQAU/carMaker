import 'package:cardmaker/app/features/editor/controller.dart';
import 'package:cardmaker/core/values/app_colors.dart';
import 'package:cardmaker/core/values/enums.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/src/stack_board_items/items/stack_chart_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChartEditorController extends GetxController {
  final CanvasController canvasController = Get.find();

  // Chart properties - ALL as Rx variables
  var chartType = ChartType.linearProgress.obs;
  var value = 75.0.obs;
  final double maxValue = 100.0; // Fixed maximum value
  var backgroundColor = Colors.grey.shade300.obs;
  var progressColor = AppColors.branding.obs;
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

  void updateBackgroundColor(Color color) {
    backgroundColor.value = color;
    _updateCurrentChart();
  }

  void updateProgressColor(Color color) {
    progressColor.value = color;
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
      // Update existing chart
      final newContent = ChartItemContent(
        chartType: chartType.value,
        value: value.value,
        maxValue: maxValue,
        backgroundColor: backgroundColor.value,
        progressColor: progressColor.value,
        showValueText: showValueText.value,
        textColor: textColor.value,
        thickness: thickness.value,
        cornerRadius: cornerRadius.value,
        glowEffect: glowEffect.value,
      );

      final newItem = currentChartItem!.copyWith(content: newContent);
      canvasController.updateItem(newItem);
    } else {
      // Add new chart
      _addNewChart();
    }
  }

  void _addNewChart() {
    final content = ChartItemContent(
      chartType: chartType.value,
      value: value.value,
      maxValue: maxValue,
      backgroundColor: backgroundColor.value,
      progressColor: progressColor.value,
      showValueText: showValueText.value,
      textColor: textColor.value,
      thickness: thickness.value,
      cornerRadius: cornerRadius.value,
      glowEffect: glowEffect.value,
    );

    final chartItem = StackChartItem(
      id: UniqueKey().toString(),
      size: const Size(200, 80),
      offset: const Offset(200, 80),
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
    // maxValue is now fixed at 100, so we don't update it
    backgroundColor.value = content.backgroundColor;
    progressColor.value = content.progressColor;
    showValueText.value = content.showValueText;
    textColor.value = content.textColor;
    thickness.value = content.thickness;
    cornerRadius.value = content.cornerRadius;
    glowEffect.value = content.glowEffect;

    update(['chart_editor']);
  }

  void resetForNewChart() {
    currentChartItem = null;
    // Reset to default values
    chartType.value = ChartType.linearProgress;
    value.value = 75.0;
    backgroundColor.value = Colors.grey.shade300;
    progressColor.value = AppColors.branding;
    showValueText.value = true;
    textColor.value = Colors.black;
    thickness.value = 10.0;
    cornerRadius.value = 0.0;
    glowEffect.value = false;

    update(['chart_editor']);
  }

  double get percentage => (value.value / maxValue).clamp(0.0, 1.0);
}
// chart_editor_controller.dart
// import 'package:cardmaker/app/features/editor/controller.dart';
// import 'package:cardmaker/core/values/app_colors.dart';
// import 'package:cardmaker/core/values/enums.dart';
// import 'package:cardmaker/widgets/common/stack_board/lib/src/stack_board_items/items/stack_chart_item.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class ChartEditorController extends GetxController {
//   final CanvasController canvasController = Get.find();

//   // Chart properties
//   var chartType = ChartType.linearProgress.obs;
//   var value = 75.0.obs;
//   var backgroundColor = Colors.grey.shade300.obs;
//   var progressColor = AppColors.branding.obs;
//   var showValueText = true.obs;
//   var textColor = Colors.black.obs;
//   var thickness = 10.0.obs;
//   var cornerRadius = 0.0.obs;
//   var glowEffect = false.obs;

//   StackChartItem? currentChartItem;

//   void updateChartType(ChartType type) {
//     chartType.value = type;
//     _updateCurrentChart();
//   }

//   void updateValue(double newValue) {
//     value.value = newValue.clamp(0.0, 100.0);
//     _updateCurrentChart();
//   }

//   void updateBackgroundColor(Color color) {
//     backgroundColor.value = color;
//     _updateCurrentChart();
//   }

//   void updateProgressColor(Color color) {
//     progressColor.value = color;
//     _updateCurrentChart();
//   }

//   void updateTextColor(Color color) {
//     textColor.value = color;
//     _updateCurrentChart();
//   }

//   void updateShowValueText(bool show) {
//     showValueText.value = show;
//     _updateCurrentChart();
//   }

//   void updateThickness(double newThickness) {
//     thickness.value = newThickness.clamp(1.0, 30.0);
//     _updateCurrentChart();
//   }

//   void updateCornerRadius(double radius) {
//     cornerRadius.value = radius.clamp(0.0, 25.0);
//     _updateCurrentChart();
//   }

//   void updateGlowEffect(bool glow) {
//     glowEffect.value = glow;
//     _updateCurrentChart();
//   }

//   void _updateCurrentChart() {
//     if (currentChartItem != null) {
//       // Update existing chart
//       final newContent = ChartItemContent(
//         chartType: chartType.value,
//         value: value.value,
//         maxValue: 100.0, // Fixed max value
//         backgroundColor: backgroundColor.value,
//         progressColor: progressColor.value,
//         showValueText: showValueText.value,
//         textColor: textColor.value,
//         thickness: thickness.value,
//         cornerRadius: cornerRadius.value,
//         glowEffect: glowEffect.value,
//       );

//       final newItem = currentChartItem!.copyWith(content: newContent);
//       canvasController.updateItem(newItem);
//     } else {
//       // Add new chart
//       _addNewChart();
//     }
//   }

//   void _addNewChart() {
//     final content = ChartItemContent(
//       chartType: chartType.value,
//       value: value.value,
//       maxValue: 100.0, // Fixed max value
//       backgroundColor: backgroundColor.value,
//       progressColor: progressColor.value,
//       showValueText: showValueText.value,
//       textColor: textColor.value,
//       thickness: thickness.value,
//       cornerRadius: cornerRadius.value,
//       glowEffect: glowEffect.value,
//     );

//     final chartItem = StackChartItem(
//       id: UniqueKey().toString(),
//       size: const Size(200, 80),
//       offset: const Offset(200, 80),
//       content: content,
//     );

//     canvasController.boardController.addItem(chartItem);
//     canvasController.activeItem.value = chartItem;
//     currentChartItem = chartItem;
//     canvasController.activePanel.value = PanelType.chartEditor;
//   }

//   void initWithItem(StackChartItem item) {
//     currentChartItem = item;
//     final content = item.content!;

//     chartType.value = content.chartType;
//     value.value = content.value;
//     backgroundColor.value = content.backgroundColor;
//     progressColor.value = content.progressColor;
//     showValueText.value = content.showValueText;
//     textColor.value = content.textColor;
//     thickness.value = content.thickness;
//     cornerRadius.value = content.cornerRadius;
//     glowEffect.value = content.glowEffect;

//     update(['chart_editor']);
//   }

//   void resetForNewChart() {
//     currentChartItem = null;
//     update(['chart_editor']);
//   }
// }
