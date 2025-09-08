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
      fillColor: data['fillColor'] == null
          ? Colors.blue
          : Color(asT<int>(data['fillColor'])),
      border: data['border'] == null
          ? DynamicBorderSide.none
          : DynamicBorderSide.fromJson(asMap(data['border'])),
      shadows: data['shadows'] == null
          ? []
          : List<ShapeShadow>.from(
              (data['shadows'] as List).map(
                (e) => ShapeShadow.fromBoxShadow(e),
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
      'fillColor': fillColor.value,
      'border': border.toJson(),
      'shadows': shadows.map((e) => e.toJson()).toList(),
    };
  }
}

// Helper function to parse MorphableShapeBorder from JSON
MorphableShapeBorder? parseMorphableShapeBorder(Map<String, dynamic>? data) {
  if (data == null) return null;

  final type = data['type'] as String?;

  switch (type) {
    case 'RectangleShapeBorder':
      return RectangleShapeBorder.fromJson(data);
    case 'CircleShapeBorder':
      return CircleShapeBorder.fromJson(data);
    case 'PolygonShapeBorder':
      return PolygonShapeBorder.fromJson(data);
    case 'StarShapeBorder':
      return StarShapeBorder.fromJson(data);
    case 'ArrowShapeBorder':
      return ArrowShapeBorder.fromJson(data);
    case 'BubbleShapeBorder':
      return BubbleShapeBorder.fromJson(data);
    default:
      return RectangleShapeBorder();
  }
}

// Extension to convert ShapeShadow to BoxShadow for rendering
extension ShapeShadowExtension on ShapeShadow {
  static ShapeShadow fromBoxShadow(Map<String, dynamic> data) {
    return ShapeShadow(
      color: Color(data['color'] as int),
      blurRadius: (data['blurRadius'] as num).toDouble(),
      offset: Offset(
        (data['offset']['dx'] as num).toDouble(),
        (data['offset']['dy'] as num).toDouble(),
      ),
      spreadRadius: (data['spreadRadius'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'color': color.value,
      'blurRadius': blurRadius,
      'offset': {'dx': offset.dx, 'dy': offset.dy},
      'spreadRadius': spreadRadius,
    };
  }
}
