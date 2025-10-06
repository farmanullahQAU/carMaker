// stack_icon_item.dart
import 'package:cardmaker/widgets/common/stack_board/lib/helpers.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/src/widget_style_extension/ex_size.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/stack_board_item.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/widget_style_extension.dart';
import 'package:flutter/material.dart';

class StackIconItem extends StackItem<IconItemContent> {
  StackIconItem({
    super.content,
    super.id,
    super.angle = 0,
    required super.size,
    required super.offset,
    super.lockZOrder = false,
    super.status = StackItemStatus.selected,
  });

  @override
  factory StackIconItem.fromJson(Map<String, dynamic> data) {
    return StackIconItem(
      id: data['id'] == null ? null : asT<String>(data['id']),
      angle: data['angle'] == null ? 0 : asT<double>(data['angle']),
      size: jsonToSize(asMap(data['size'])),
      offset: jsonToOffset(asMap(data['offset'])),
      status: data['status'] != null
          ? StackItemStatus.values[data['status'] as int]
          : StackItemStatus.idle,
      lockZOrder: asNullT<bool>(data['lockZOrder']) ?? false,
      content: IconItemContent.fromJson(asMap(data['content'])),
    );
  }

  @override
  @override
  StackIconItem copyWith({
    double? angle,
    Size? size,
    Offset? offset,
    StackItemStatus? status,
    bool? lockZOrder,
    IconItemContent? content,
    bool? isNewImage,
    bool? isProfileImage,
  }) {
    return StackIconItem(
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
      'type': 'StackIconItem',
    };
  }
}

class IconItemContent implements StackItemContent {
  IconItemContent({
    required this.icon,
    this.color = Colors.black,
    this.size = 24.0,
  });

  factory IconItemContent.fromJson(Map<String, dynamic> data) {
    return IconItemContent(
      icon: IconData(data['icon'] as int, fontFamily: 'MaterialIcons'),
      color: Color(data['color'] as int),
      size: (data['size'] ?? 24.0).toDouble(),
    );
  }

  final IconData icon;
  Color color;
  double size;

  IconItemContent copyWith({IconData? icon, Color? color, double? size}) {
    return IconItemContent(
      icon: icon ?? this.icon,
      color: color ?? this.color,
      size: size ?? this.size,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'icon': icon.codePoint, 'color': color, 'size': size};
  }
}
