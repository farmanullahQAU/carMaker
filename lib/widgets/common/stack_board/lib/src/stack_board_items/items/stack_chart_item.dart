// stack_chart_item.dart
import 'package:cardmaker/core/values/enums.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/helpers.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/src/widget_style_extension/ex_size.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/stack_board_item.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/widget_style_extension.dart';
import 'package:flutter/material.dart';

class StackChartItem extends StackItem<ChartItemContent> {
  StackChartItem({
    super.content,
    super.id,
    super.angle = 0,
    required super.size,
    required super.offset,
    super.lockZOrder = false,
    super.status = StackItemStatus.selected,
  });

  @override
  factory StackChartItem.fromJson(Map<String, dynamic> data) {
    return StackChartItem(
      id: data['id'] == null ? null : asT<String>(data['id']),
      angle: data['angle'] == null ? 0 : asT<double>(data['angle']),
      size: jsonToSize(asMap(data['size'])),
      offset: jsonToOffset(asMap(data['offset'])),
      status: data['status'] != null
          ? StackItemStatus.values[data['status'] as int]
          : StackItemStatus.idle,
      lockZOrder: asNullT<bool>(data['lockZOrder']) ?? false,
      content: ChartItemContent.fromJson(asMap(data['content'])),
    );
  }

  @override
  @override
  StackChartItem copyWith({
    double? angle,
    Size? size,
    Offset? offset,
    StackItemStatus? status,
    bool? lockZOrder,
    ChartItemContent? content,
    bool? isNewImage,
    bool? isProfileImage,
  }) {
    return StackChartItem(
      id: id,
      angle: angle ?? this.angle,
      size: size ?? this.size,
      offset: offset ?? this.offset,
      status: status ?? this.status,
      lockZOrder: lockZOrder ?? this.lockZOrder,
      content: content ?? this.content,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'angle': angle,
      'size': {'width': size.width, 'height': size.height},
      'offset': {'dx': offset.dx, 'dy': offset.dy},
      'status': status.index,
      'lockZOrder': lockZOrder,
      'content': content?.toJson(),
      'type': 'StackChartItem',
    };
  }
}

class ChartItemContent implements StackItemContent {
  ChartItemContent({
    required this.chartType,
    this.value = 0.5,
    this.maxValue = 1.0,
    this.backgroundColor = Colors.grey,
    this.progressColor = Colors.blue,
    this.borderColor = Colors.transparent,
    this.borderWidth = 0.0,
    this.showValueText = true,
    this.textColor = Colors.black,
    this.textSize = 14.0,
    this.thickness = 10.0,
    this.startAngle = -90.0, // For radial charts (degrees)
    this.sweepAngle = 360.0, // For radial charts (degrees)
    this.cornerRadius = 0.0, // For linear progress bar
    this.glowEffect = false,
    this.glowColor,
    this.glowBlur = 5.0,
  });

  factory ChartItemContent.fromJson(Map<String, dynamic> data) {
    return ChartItemContent(
      chartType: ChartType.values[data['chartType'] as int],
      value: (data['value'] ?? 0.5).toDouble(),
      maxValue: (data['maxValue'] ?? 1.0).toDouble(),
      backgroundColor: Color(data['backgroundColor'] as int),
      progressColor: Color(data['progressColor'] as int),
      borderColor: Color(data['borderColor'] as int),
      borderWidth: (data['borderWidth'] ?? 0.0).toDouble(),
      showValueText: data['showValueText'] ?? true,
      textColor: Color(data['textColor'] as int),
      textSize: (data['textSize'] ?? 14.0).toDouble(),
      thickness: (data['thickness'] ?? 10.0).toDouble(),
      startAngle: (data['startAngle'] ?? -90.0).toDouble(),
      sweepAngle: (data['sweepAngle'] ?? 360.0).toDouble(),
      cornerRadius: (data['cornerRadius'] ?? 0.0).toDouble(),
      glowEffect: data['glowEffect'] ?? false,
      glowColor: data['glowColor'] != null
          ? Color(data['glowColor'] as int)
          : null,
      glowBlur: (data['glowBlur'] ?? 5.0).toDouble(),
    );
  }

  final ChartType chartType;
  double value;
  double maxValue;
  Color backgroundColor;
  Color progressColor;
  Color borderColor;
  double borderWidth;
  bool showValueText;
  Color textColor;
  double textSize;
  double thickness;
  double startAngle;
  double sweepAngle;
  double cornerRadius;
  bool glowEffect;
  Color? glowColor;
  double glowBlur;

  double get percentage => (value / maxValue).clamp(0.0, 1.0);

  ChartItemContent copyWith({
    ChartType? chartType,
    double? value,
    double? maxValue,
    Color? backgroundColor,
    Color? progressColor,
    Color? borderColor,
    double? borderWidth,
    bool? showValueText,
    Color? textColor,
    double? textSize,
    double? thickness,
    double? startAngle,
    double? sweepAngle,
    double? cornerRadius,
    bool? glowEffect,
    Color? glowColor,
    double? glowBlur,
  }) {
    return ChartItemContent(
      chartType: chartType ?? this.chartType,
      value: value ?? this.value,
      maxValue: maxValue ?? this.maxValue,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      progressColor: progressColor ?? this.progressColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      showValueText: showValueText ?? this.showValueText,
      textColor: textColor ?? this.textColor,
      textSize: textSize ?? this.textSize,
      thickness: thickness ?? this.thickness,
      startAngle: startAngle ?? this.startAngle,
      sweepAngle: sweepAngle ?? this.sweepAngle,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      glowEffect: glowEffect ?? this.glowEffect,
      glowColor: glowColor ?? this.glowColor,
      glowBlur: glowBlur ?? this.glowBlur,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'chartType': chartType.index,
      'value': value,
      'maxValue': maxValue,
      'backgroundColor': backgroundColor.value,
      'progressColor': progressColor.value,
      'borderColor': borderColor.value,
      'borderWidth': borderWidth,
      'showValueText': showValueText,
      'textColor': textColor.value,
      'textSize': textSize,
      'thickness': thickness,
      'startAngle': startAngle,
      'sweepAngle': sweepAngle,
      'cornerRadius': cornerRadius,
      'glowEffect': glowEffect,
      'glowColor': glowColor?.value,
      'glowBlur': glowBlur,
    };
  }
}
