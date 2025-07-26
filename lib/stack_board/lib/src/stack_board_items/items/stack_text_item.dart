import 'package:cardmaker/stack_board/lib/helpers.dart';
import 'package:cardmaker/stack_board/lib/src/widget_style_extension/ex_size.dart';
import 'package:cardmaker/stack_board/lib/stack_board_item.dart';
import 'package:flutter/painting.dart';

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
    this.isCentered = false,
  });

  @override
  final bool isCentered;

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
      isCentered: asT<bool>(data['isCentered'], false),
    );
  }

  void setData(String str) {
    content!.data = str;
  }

  @override
  StackTextItem copyWith({
    double? angle,
    Size? size,
    Offset? offset,
    StackItemStatus? status,
    bool? lockZOrder,
    TextItemContent? content,
    bool? isCentered,
  }) {
    return StackTextItem(
      id: id,
      angle: angle ?? this.angle,
      size: size ?? this.size,
      offset: offset ?? this.offset,
      status: status ?? this.status,
      lockZOrder: lockZOrder ?? this.lockZOrder,
      content: content ?? this.content,
      isCentered: isCentered ?? this.isCentered,
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
    this.maskColor,
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
      maskColor: data['maskColor'] == null
          ? null
          : Color(asT<int>(data['maskColor'])),
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
      maskColor: maskColor ?? this.maskColor,
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
    };
  }
}
