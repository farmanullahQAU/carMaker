import 'dart:convert';
import 'dart:math';

import 'package:cardmaker/widgets/common/stack_board/lib/src/widget_style_extension/ex_size.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/widget_style_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'stack_item_content.dart';
import 'stack_item_status.dart';

/// * 生成 StackItem id
/// * Generate Id for StackItem
String _genId() {
  final DateTime now = DateTime.now();
  final int value = Random().nextInt(100000);
  return '$value-${now.millisecondsSinceEpoch}';
}

/// * 布局数据核心类
/// * 自定义需要继承此类
/// * Core class for layout data
/// * Custom needs to inherit this class
@immutable
abstract class StackItem<T extends StackItemContent> {
  StackItem({
    String? id,
    required this.size,

    bool isCentered = false,
    Offset? offset,
    double? angle = 0,
    StackItemStatus? status = StackItemStatus.selected,
    bool? lockZOrder = false,
    bool? isProfileImage = false,
    bool? isNewImage = false,

    this.content,
  }) : id = id ?? _genId(),
       offset = offset ?? Offset.zero,
       angle = angle ?? 0,
       lockZOrder = lockZOrder ?? false,

       isProfileImage = isProfileImage ?? false,
       isNewImage = isNewImage ?? false,

       status = status ?? StackItemStatus.selected;

  const StackItem.empty({
    required this.size,
    required this.offset,
    required this.angle,
    required this.status,
    required this.content,
    required this.lockZOrder,
    required this.isProfileImage,
    this.isNewImage,
  }) : id = '';

  /// id
  final String id;

  /// Size
  final Size size;

  /// Offset
  final Offset offset;

  /// Angle
  final double angle;

  /// Status
  final StackItemStatus status;

  final bool lockZOrder;
  final bool isProfileImage;
  final bool? isNewImage;

  /// Content
  final T? content;

  /// Update content and return new instance
  StackItem<T> copyWith({
    Size? size,
    Offset? offset,
    double? angle,
    StackItemStatus? status,
    bool? lockZOrder,
    bool? isProfileImage,
    bool? isNewImage,

    T? content,
  });

  /// to json
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'type': runtimeType.toString(),
      'angle': angle,
      'size': size.toJson(),
      'offset': offset
          .toJson(), // This is the absolute offset for runtime, will be ignored for persistence in StackTextItem, StackImageItem, ColorStackItem1
      'status': status.index,
      'lockZOrder': lockZOrder,
      'isProfileImage': isProfileImage,
      if (content != null) 'content': content?.toJson(),
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) => other is StackItem && id == other.id;
}
