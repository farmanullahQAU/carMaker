import 'package:cardmaker/core/extensions/extensions.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/helpers.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/src/widget_style_extension/ex_size.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/stack_board_item.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/widget_style_extension.dart';
import 'package:flutter/material.dart';
import 'package:morphable_shape/morphable_shape.dart';

class StackShapeItem extends StackItem<ShapeItemContent> {
  StackShapeItem({
    super.content,
    super.id,
    super.angle = 0,
    required super.size,
    required super.offset,
    super.lockZOrder = false,
    super.status = StackItemStatus.selected,
  });

  @override
  factory StackShapeItem.fromJson(Map<String, dynamic> data) {
    return StackShapeItem(
      id: data['id'] == null ? null : asT<String>(data['id']),
      angle: data['angle'] == null ? 0 : asT<double>(data['angle']),
      size: jsonToSize(asMap(data['size'])),
      offset: jsonToOffset(asMap(data['offset'])),
      status: data['status'] != null
          ? StackItemStatus.values[data['status'] as int]
          : StackItemStatus.idle,
      lockZOrder: asNullT<bool>(data['lockZOrder']) ?? false,
      content: ShapeItemContent.fromJson(asMap(data['content'])),
    );
  }

  @override
  StackShapeItem copyWith({
    double? angle,
    Size? size,
    Offset? offset,
    StackItemStatus? status,
    bool? lockZOrder,
    ShapeItemContent? content,
    bool? isCentered,
    bool? isProfileImage,
    bool? isNewImage,
  }) {
    return StackShapeItem(
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
      'type': 'StackShapeItem',
    };
  }
}

class ShapeItemContent implements StackItemContent {
  ShapeItemContent({
    this.shapeBorder,
    this.fillColor = Colors.blue,
    this.border = DynamicBorderSide.none,
    this.shadows = const [],
  });

  factory ShapeItemContent.fromJson(Map<String, dynamic> data) {
    return ShapeItemContent(
      shapeBorder: parseMorphableShapeBorder(asMap(data['shapeBorder'])),
      fillColor: Color(asT<int>(data['fillColor'])),
      border: data['border'] == null
          ? DynamicBorderSide.none
          : DynamicBorderSide.fromJson(asMap(data['border'])),
      shadows: data['shadows'] == null
          ? <ShapeShadow>[]
          : List<ShapeShadow>.from(
              (data['shadows'] as List<dynamic>).map(
                (e) => ShapeShadowJson.fromJson(e as Map<String, dynamic>),
              ),
            ),
    );
  }

  MorphableShapeBorder? shapeBorder;
  Color fillColor;
  DynamicBorderSide border;
  List<ShapeShadow> shadows;

  ShapeItemContent copyWith({
    MorphableShapeBorder? shapeBorder,
    Color? fillColor,
    DynamicBorderSide? border,
    List<ShapeShadow>? shadows,
  }) {
    return ShapeItemContent(
      shapeBorder: shapeBorder ?? this.shapeBorder,
      fillColor: fillColor ?? this.fillColor,
      border: border ?? this.border,
      shadows: shadows ?? this.shadows,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      if (shapeBorder != null) 'shapeBorder': shapeBorder!.toJson(),
      'fillColor': fillColor,
      'border': border.toJson(),
      'shadows': shadows.map((e) => e.toJson()).toList(),
    };
  }
}
