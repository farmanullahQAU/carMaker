import 'package:cardmaker/stack_board/lib/helpers.dart';
import 'package:cardmaker/stack_board/lib/src/widget_style_extension/ex_size.dart';
import 'package:cardmaker/stack_board/lib/stack_board_item.dart';
import 'package:cardmaker/stack_board/lib/widget_style_extension.dart';
import 'package:flutter/material.dart';

class ImageItemContent extends StackItemContent {
  ImageItemContent({
    this.url,
    this.assetName,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.width,
    this.height,
    this.color,
    this.colorBlendMode,
    this.fit = BoxFit.cover,
    this.repeat = ImageRepeat.noRepeat,
    this.matchTextDirection = false,
    this.gaplessPlayback = false,
    this.isAntiAlias = false,
    this.filterQuality = FilterQuality.low,
  }) {
    _init();
  }

  factory ImageItemContent.fromJson(Map<String, dynamic> json) {
    return ImageItemContent(
      url: json['url'] != null ? asT<String>(json['url']) : null,
      assetName: json['assetName'] != null
          ? asT<String>(json['assetName'])
          : null,
      semanticLabel: json['semanticLabel'] != null
          ? asT<String>(json['semanticLabel'])
          : null,
      excludeFromSemantics:
          asNullT<bool>(json['excludeFromSemantics']) ?? false,
      width: json['width'] != null ? asT<double>(json['width']) : null,
      height: json['height'] != null ? asT<double>(json['height']) : null,
      color: json['color'] != null ? Color(asT<int>(json['color'])) : null,
      colorBlendMode: json['colorBlendMode'] != null
          ? BlendMode.values[asT<int>(json['colorBlendMode'])]
          : BlendMode.srcIn,
      fit: json['fit'] != null
          ? BoxFit.values[asT<int>(json['fit'])]
          : BoxFit.cover,
      repeat: json['repeat'] != null
          ? ImageRepeat.values[asT<int>(json['repeat'])]
          : ImageRepeat.noRepeat,
      matchTextDirection: asNullT<bool>(json['matchTextDirection']) ?? false,
      gaplessPlayback: asNullT<bool>(json['gaplessPlayback']) ?? false,
      isAntiAlias: asNullT<bool>(json['isAntiAlias']) ?? true,
      filterQuality: json['filterQuality'] != null
          ? FilterQuality.values[asT<int>(json['filterQuality'])]
          : FilterQuality.high,
    );
  }

  void _init() {
    if (url != null && assetName != null) {
      throw Exception('url and assetName can not be set at the same time');
    }

    if (url == null && assetName == null) {
      throw Exception('url and assetName can not be null at the same time');
    }

    if (url != null) {
      _image = NetworkImage(url!);
    } else if (assetName != null) {
      _image = AssetImage(assetName!);
    }
  }

  late ImageProvider _image;
  String? url;
  String? assetName;
  String? semanticLabel;
  bool excludeFromSemantics;
  double? width;
  double? height;
  Color? color;
  BlendMode? colorBlendMode;
  BoxFit fit;
  ImageRepeat repeat;
  bool matchTextDirection;
  bool gaplessPlayback;
  bool isAntiAlias;
  FilterQuality filterQuality;

  ImageProvider get image => _image;

  void setRes({String? url, String? assetName}) {
    if (url != null) this.url = url;
    if (assetName != null) this.assetName = assetName;
    _init();
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (url != null) 'url': url,
      if (assetName != null) 'assetName': assetName,
      if (semanticLabel != null) 'semanticLabel': semanticLabel,
      'excludeFromSemantics': excludeFromSemantics,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (color != null) 'color': color?.value,
      if (colorBlendMode != null) 'colorBlendMode': colorBlendMode?.index,
      'fit': fit.index,
      'repeat': repeat.index,
      'matchTextDirection': matchTextDirection,
      'gaplessPlayback': gaplessPlayback,
      'isAntiAlias': isAntiAlias,
      'filterQuality': filterQuality.index,
    };
  }
}

class StackImageItem extends StackItem<ImageItemContent> {
  StackImageItem({
    required super.content,
    super.id,
    super.angle = null,
    required super.size,
    super.offset,
    super.status = null,
    super.lockZOrder = null,
    super.isProfileImage = false,
  });

  factory StackImageItem.fromJson(Map<String, dynamic> data) {
    return StackImageItem(
      id: data['id'] == null ? null : asT<String>(data['id']),
      angle: data['angle'] == null ? null : asT<double>(data['angle']),
      size: jsonToSize(asMap(data['size'])),
      offset: data['offset'] == null
          ? null
          : jsonToOffset(asMap(data['offset'])),
      status: StackItemStatus.values[data['status'] as int],
      lockZOrder: asNullT<bool>(data['lockZOrder']) ?? false,
      isProfileImage: asNullT<bool>(data['isProfileImage']) ?? false,
      content: ImageItemContent.fromJson(asMap(data['content'])),
    );
  }

  void setUrl(String url) {
    content?.setRes(url: url);
  }

  void setAssetName(String assetName) {
    content?.setRes(assetName: assetName);
  }

  @override
  StackImageItem copyWith({
    Size? size,
    Offset? offset,
    double? angle,
    StackItemStatus? status,
    bool? lockZOrder,
    ImageItemContent? content,
    bool? isProfileImage,
    bool? isCentered,
  }) {
    return StackImageItem(
      id: id,
      size: size ?? this.size,
      offset: offset ?? this.offset,
      angle: angle ?? this.angle,
      status: status ?? this.status,
      lockZOrder: lockZOrder ?? this.lockZOrder,
      content: content ?? this.content,
      isProfileImage: isProfileImage ?? this.isProfileImage,

      // isCentered is ignored here unless you want to use it
    );
  }
}
