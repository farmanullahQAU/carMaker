import 'package:cardmaker/app/features/editor/circular_text/model.dart';
import 'package:cardmaker/app/features/editor/text_editor.dart';
import 'package:cardmaker/stack_board/lib/helpers.dart';
import 'package:cardmaker/stack_board/lib/src/widget_style_extension/ex_size.dart';
import 'package:cardmaker/stack_board/lib/stack_board_item.dart';
import 'package:flutter/material.dart';

import '../../../widget_style_extension.dart';

class StackTextItem extends StackItem<TextItemContent> {
  StackTextItem({
    super.content,
    super.id,
    super.angle = 0,
    required super.size,
    required super.offset,
    super.lockZOrder = false,
    super.status = StackItemStatus.selected,
  });

  @override
  factory StackTextItem.fromJson(Map<String, dynamic> data) {
    return StackTextItem(
      id: data['id'] == null ? null : asT<String>(data['id']),
      angle: data['angle'] == null ? 0 : asT<double>(data['angle']),
      size: jsonToSize(asMap(data['size'])),
      offset: jsonToOffset(asMap(data['offset'])),
      status: data['status'] != null
          ? StackItemStatus.values[data['status'] as int]
          : StackItemStatus.idle,
      lockZOrder: asNullT<bool>(data['lockZOrder']) ?? false,
      content: TextItemContent.fromJson(asMap(data['content'])),
    );
  }

  void setData(String str) {
    content!.data = str;
  }

  @override
  @override
  StackTextItem copyWith({
    double? angle,
    Size? size,
    Offset? offset,
    StackItemStatus? status,
    bool? lockZOrder,
    TextItemContent? content,
    bool? isCentered,
    bool? isProfileImage, // Added to match base class signature
  }) {
    return StackTextItem(
      id: id,
      angle: angle ?? this.angle,
      size: size ?? this.size,
      offset: offset ?? this.offset,
      status: status ?? this.status,
      lockZOrder: lockZOrder ?? this.lockZOrder,
      content: content ?? this.content,

      // isProfileImage is ignored as StackTextItem does not use it
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
      'isCentered': isCentered,
      'type': 'StackTextItem',
    };
  }
}

class TextItemContent implements StackItemContent {
  TextItemContent({
    this.data,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.googleFont,
    this.maskImage,
    // Stroke properties (NEW)
    this.hasStroke = false,
    this.strokeWidth = 2.0,
    this.strokeColor = Colors.black,
    // Circular text properties
    this.isCircular = false,
    this.radius,
    this.space,
    this.startAngle,
    this.startAngleAlignment,
    this.position,
    this.direction,
    this.showBackground,
    this.showStroke,
    this.backgroundPaintColor,
    // Dual Tone properties (ADD THESE)
    this.hasDualTone = false,
    this.dualToneColor1 = Colors.red,
    this.dualToneColor2 = Colors.blue,
    this.dualToneDirection = DualToneDirection.horizontal,
    this.dualTonePosition = 0.5,
  });

  factory TextItemContent.fromJson(Map<String, dynamic> data) {
    return TextItemContent(
      data: data['data'],
      style: data['style'] == null
          ? null
          : jsonToTextStyle(asMap(data['style'])),
      strutStyle: data['strutStyle'] == null
          ? null
          : StackTextStrutStyle.fromJson(asMap(data['strutStyle'])),
      textAlign: data['textAlign'] == null
          ? null
          : ExEnum.tryParse<TextAlign>(
              TextAlign.values,
              asT<String>(data['textAlign']),
            ),
      textDirection: data['textDirection'] == null
          ? null
          : ExEnum.tryParse<TextDirection>(
              TextDirection.values,
              asT<String>(data['textDirection']),
            ),
      locale: data['locale'] == null
          ? null
          : jsonToLocale(asMap(data['locale'])),
      softWrap: data['softWrap'] == null ? null : asT<bool>(data['softWrap']),
      overflow: data['overflow'] == null
          ? null
          : ExEnum.tryParse<TextOverflow>(
              TextOverflow.values,
              asT<String>(data['overflow']),
            ),
      textScaleFactor: data['textScaleFactor'] == null
          ? null
          : asT<double>(data['textScaleFactor']),
      maxLines: data['maxLines'] == null ? null : asT<int>(data['maxLines']),
      semanticsLabel: data['semanticsLabel'] == null
          ? null
          : asT<String>(data['semanticsLabel']),
      textWidthBasis: data['textWidthBasis'] == null
          ? null
          : ExEnum.tryParse<TextWidthBasis>(
              TextWidthBasis.values,
              asT<String>(data['textWidthBasis']),
            ),
      textHeightBehavior: data['textHeightBehavior'] == null
          ? null
          : jsonToTextHeightBehavior(asMap(data['textHeightBehavior'])),
      selectionColor: data['selectionColor'] == null
          ? null
          : Color(asT<int>(data['selectionColor'])),
      googleFont: data['googleFont'],
      maskImage: data['maskImage'],

      // Stroke properties (NEW)
      hasStroke: asT<bool>(data['hasStroke'], false),
      strokeWidth: asT<double>(data['strokeWidth'], 2.0),
      strokeColor: data['strokeColor'] == null
          ? Colors.black
          : Color(asT<int>(data['strokeColor'])),

      // Circular text properties
      isCircular: asT<bool>(data['isCircular'], false),
      radius: asT<double>(data['radius']),
      space: asT<double>(data['space']),
      startAngle: asT<double>(data['startAngle']),
      startAngleAlignment: data['startAngleAlignment'] == null
          ? null
          : ExEnum.tryParse<StartAngleAlignment>(
              StartAngleAlignment.values,
              asT<String>(data['startAngleAlignment']),
            ),
      position: data['position'] == null
          ? null
          : ExEnum.tryParse<CircularTextPosition>(
              CircularTextPosition.values,
              asT<String>(data['position']),
            ),
      direction: data['direction'] == null
          ? null
          : ExEnum.tryParse<CircularTextDirection>(
              CircularTextDirection.values,
              asT<String>(data['direction']),
            ),
      showBackground: asT<bool>(data['showBackground']),
      showStroke: asT<bool>(data['showStroke']),
      backgroundPaintColor: data['backgroundPaintColor'] == null
          ? null
          : Color(asT<int>(data['backgroundPaintColor'])),

      // Add dual tone properties
      hasDualTone: asT<bool>(data['hasDualTone'], false),
      dualToneColor1: data['dualToneColor1'] == null
          ? Colors.red
          : Color(asT<int>(data['dualToneColor1'])),
      dualToneColor2: data['dualToneColor2'] == null
          ? Colors.blue
          : Color(asT<int>(data['dualToneColor2'])),
      dualToneDirection: data['dualToneDirection'] == null
          ? DualToneDirection.horizontal
          : ExEnum.tryParse<DualToneDirection>(
                  DualToneDirection.values,
                  asT<String>(data['dualToneDirection']),
                ) ??
                DualToneDirection.horizontal,
      dualTonePosition: asT<double>(data['dualTonePosition'], 0.5),
    );
  }

  String? data;
  TextStyle? style;
  StackTextStrutStyle? strutStyle;
  TextAlign? textAlign;
  TextDirection? textDirection;
  Locale? locale;
  bool? softWrap;
  TextOverflow? overflow;
  double? textScaleFactor;
  int? maxLines;
  String? semanticsLabel;
  TextWidthBasis? textWidthBasis;
  TextHeightBehavior? textHeightBehavior;
  Color? selectionColor;
  String? googleFont;
  String? maskImage;
  Color? maskColor;

  // Stroke properties (NEW)
  bool hasStroke;
  double strokeWidth;
  Color strokeColor;

  // Circular text properties
  bool isCircular;
  double? radius;
  double? space;
  double? startAngle;
  StartAngleAlignment? startAngleAlignment;
  CircularTextPosition? position;
  CircularTextDirection? direction;
  bool? showBackground;
  bool? showStroke;
  Color? backgroundPaintColor;
  bool hasDualTone;
  Color dualToneColor1;
  Color dualToneColor2;
  DualToneDirection dualToneDirection;
  double dualTonePosition;

  TextItemContent copyWith({
    String? data,
    TextStyle? style,
    StackTextStrutStyle? strutStyle,
    TextAlign? textAlign,
    TextDirection? textDirection,
    Locale? locale,
    bool? softWrap,
    TextOverflow? overflow,
    double? textScaleFactor,
    int? maxLines,
    String? semanticsLabel,
    TextWidthBasis? textWidthBasis,
    TextHeightBehavior? textHeightBehavior,
    Color? selectionColor,
    String? googleFont,
    String? maskImage,
    Color? maskColor,
    // Stroke properties (NEW)
    bool? hasStroke,
    double? strokeWidth,
    Color? strokeColor,
    // Circular text properties
    bool? isCircular,
    double? radius,
    double? space,
    double? startAngle,
    StartAngleAlignment? startAngleAlignment,
    CircularTextPosition? position,
    CircularTextDirection? direction,
    bool? showBackground,
    bool? showStroke,
    Color? backgroundPaintColor,

    // Dual Tone properties (ADD THESE)
    // Dual Tone properties (ADD THESE)
    bool? hasDualTone,
    Color? dualToneColor1,
    Color? dualToneColor2,
    DualToneDirection? dualToneDirection,
    double? dualTonePosition,
  }) {
    return TextItemContent(
      data: data ?? this.data,
      style: style ?? this.style,
      strutStyle: strutStyle ?? this.strutStyle,
      textAlign: textAlign ?? this.textAlign,
      textDirection: textDirection ?? this.textDirection,
      locale: locale ?? this.locale,
      softWrap: softWrap ?? this.softWrap,
      overflow: overflow ?? this.overflow,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      maxLines: maxLines ?? this.maxLines,
      semanticsLabel: semanticsLabel ?? this.semanticsLabel,
      textWidthBasis: textWidthBasis ?? this.textWidthBasis,
      textHeightBehavior: textHeightBehavior ?? this.textHeightBehavior,
      selectionColor: selectionColor ?? this.selectionColor,
      googleFont: googleFont ?? this.googleFont,
      maskImage: maskImage ?? this.maskImage,
      // Stroke properties (NEW)
      hasStroke: hasStroke ?? this.hasStroke,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      strokeColor: strokeColor ?? this.strokeColor,
      // Circular text properties
      isCircular: isCircular ?? this.isCircular,
      radius: radius ?? this.radius,
      space: space ?? this.space,
      startAngle: startAngle ?? this.startAngle,
      startAngleAlignment: startAngleAlignment ?? this.startAngleAlignment,
      position: position ?? this.position,
      direction: direction ?? this.direction,
      showBackground: showBackground ?? this.showBackground,
      showStroke: showStroke ?? this.showStroke,
      backgroundPaintColor: backgroundPaintColor ?? this.backgroundPaintColor,
      // Add dual tone properties
      hasDualTone: hasDualTone ?? this.hasDualTone,
      dualToneColor1: dualToneColor1 ?? this.dualToneColor1,
      dualToneColor2: dualToneColor2 ?? this.dualToneColor2,
      dualToneDirection: dualToneDirection ?? this.dualToneDirection,
      dualTonePosition: dualTonePosition ?? this.dualTonePosition,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (data != null) 'data': data,
      if (style != null) 'style': style?.toJson(),
      if (strutStyle != null) 'strutStyle': strutStyle?.toJson(),
      if (textAlign != null) 'textAlign': textAlign?.toString(),
      if (textDirection != null) 'textDirection': textDirection?.toString(),
      if (locale != null) 'locale': locale?.toJson(),
      if (softWrap != null) 'softWrap': softWrap,
      if (overflow != null) 'overflow': overflow?.toString(),
      if (textScaleFactor != null) 'textScaleFactor': textScaleFactor,
      if (maxLines != null) 'maxLines': maxLines,
      if (semanticsLabel != null) 'semanticsLabel': semanticsLabel,
      if (textWidthBasis != null) 'textWidthBasis': textWidthBasis?.toString(),
      if (textHeightBehavior != null)
        'textHeightBehavior': textHeightBehavior?.toJson(),
      if (selectionColor != null) 'selectionColor': selectionColor?.toARGB32(),
      if (googleFont != null) 'googleFont': googleFont,
      if (maskImage != null) 'maskImage': maskImage,
      if (maskColor != null) 'maskColor': maskColor?.toARGB32(),

      // Stroke properties (NEW)
      'hasStroke': hasStroke,
      'strokeWidth': strokeWidth,
      'strokeColor': strokeColor.toARGB32(),

      // Circular text properties
      'isCircular': isCircular,
      if (radius != null) 'radius': radius,
      if (space != null) 'space': space,
      if (startAngle != null) 'startAngle': startAngle,
      if (startAngleAlignment != null)
        'startAngleAlignment': startAngleAlignment?.toString(),
      if (position != null) 'position': position?.toString(),
      if (direction != null) 'direction': direction?.toString(),
      if (showBackground != null) 'showBackground': showBackground,
      if (showStroke != null) 'showStroke': showStroke,
      if (backgroundPaintColor != null)
        'backgroundPaintColor': backgroundPaintColor?.toARGB32(),

      // Add dual tone properties
      'hasDualTone': hasDualTone,
      'dualToneColor1': dualToneColor1.toARGB32(),
      'dualToneColor2': dualToneColor2.toARGB32(),
      'dualToneDirection': dualToneDirection.toString(),
      'dualTonePosition': dualTonePosition,
    };
  }
}
