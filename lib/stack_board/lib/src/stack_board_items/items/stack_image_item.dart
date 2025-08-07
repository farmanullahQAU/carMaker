import 'package:cardmaker/stack_board/lib/helpers.dart';
import 'package:cardmaker/stack_board/lib/src/widget_style_extension/ex_size.dart';
import 'package:cardmaker/stack_board/lib/stack_board_item.dart';
import 'package:cardmaker/stack_board/lib/stack_case.dart'
    show ImageFilter, ImageMaskShape, ImagePattern;
import 'package:cardmaker/stack_board/lib/widget_style_extension.dart';
import 'package:flutter/material.dart';

// Enhanced ImageItemContent with advanced customization features
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
    // New advanced customization properties
    this.brightness = 0.0,
    this.contrast = 1.0,
    this.saturation = 1.0,
    this.hue = 0.0,
    this.opacity = 1.0,
    this.borderRadius = 0.0,
    this.borderWidth = 0.0,
    this.borderColor,
    this.shadowBlur = 0.0,
    this.shadowOffset = const Offset(0, 0),
    this.shadowColor,
    this.rotationAngle = 0.0,
    this.flipHorizontal = false,
    this.flipVertical = false,
    this.grayscale = false,
    this.sepia = false,
    this.vintage = false,
    this.vignette = 0.0,
    this.vignetteColor,
    this.overlayColor,
    this.overlayBlendMode,
    this.cropRect,
    this.maskShape = ImageMaskShape.none,
    this.gradientOverlay,
    this.patternOverlay,
    this.noiseIntensity = 0.0,
    this.sharpen = 0.0,
    this.emboss = false,
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
      // Advanced properties
      brightness: asNullT<double>(json['brightness']) ?? 0.0,
      contrast: asNullT<double>(json['contrast']) ?? 1.0,
      saturation: asNullT<double>(json['saturation']) ?? 1.0,
      hue: asNullT<double>(json['hue']) ?? 0.0,
      opacity: asNullT<double>(json['opacity']) ?? 1.0,
      borderRadius: asNullT<double>(json['borderRadius']) ?? 0.0,
      borderWidth: asNullT<double>(json['borderWidth']) ?? 0.0,
      borderColor: json['borderColor'] != null
          ? Color(asT<int>(json['borderColor']))
          : null,
      shadowBlur: asNullT<double>(json['shadowBlur']) ?? 0.0,
      shadowOffset: json['shadowOffset'] != null
          ? Offset(
              asT<double>(json['shadowOffset']['dx']),
              asT<double>(json['shadowOffset']['dy']),
            )
          : const Offset(0, 0),
      shadowColor: json['shadowColor'] != null
          ? Color(asT<int>(json['shadowColor']))
          : null,
      rotationAngle: asNullT<double>(json['rotationAngle']) ?? 0.0,
      flipHorizontal: asNullT<bool>(json['flipHorizontal']) ?? false,
      flipVertical: asNullT<bool>(json['flipVertical']) ?? false,
      grayscale: asNullT<bool>(json['grayscale']) ?? false,
      sepia: asNullT<bool>(json['sepia']) ?? false,
      vintage: asNullT<bool>(json['vintage']) ?? false,
      vignette: asNullT<double>(json['vignette']) ?? 0.0,
      vignetteColor: json['vignetteColor'] != null
          ? Color(asT<int>(json['vignetteColor']))
          : null,
      overlayColor: json['overlayColor'] != null
          ? Color(asT<int>(json['overlayColor']))
          : null,
      overlayBlendMode: json['overlayBlendMode'] != null
          ? BlendMode.values[asT<int>(json['overlayBlendMode'])]
          : null,
      maskShape: json['maskShape'] != null
          ? ImageMaskShape.values[asT<int>(json['maskShape'])]
          : ImageMaskShape.none,
      noiseIntensity: asNullT<double>(json['noiseIntensity']) ?? 0.0,
      sharpen: asNullT<double>(json['sharpen']) ?? 0.0,
      emboss: asNullT<bool>(json['emboss']) ?? false,
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

  // Existing properties
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

  // Advanced customization properties
  double brightness; // -1.0 to 1.0
  double contrast; // 0.0 to 2.0
  double saturation; // 0.0 to 2.0
  double hue; // 0.0 to 360.0 degrees
  double opacity; // 0.0 to 1.0
  double borderRadius;
  double borderWidth;
  Color? borderColor;
  double shadowBlur;
  Offset shadowOffset;
  Color? shadowColor;
  double rotationAngle; // in degrees
  bool flipHorizontal;
  bool flipVertical;
  bool grayscale;
  bool sepia;
  bool vintage;
  double vignette; // 0.0 to 1.0
  Color? vignetteColor;
  Color? overlayColor;
  BlendMode? overlayBlendMode;
  Rect? cropRect;
  ImageMaskShape maskShape;
  Gradient? gradientOverlay;
  ImagePattern? patternOverlay;
  double noiseIntensity; // 0.0 to 1.0
  double sharpen; // 0.0 to 1.0
  bool emboss;

  ImageProvider get image => _image;

  void setRes({String? url, String? assetName}) {
    if (url != null) this.url = url;
    if (assetName != null) this.assetName = assetName;
    _init();
  }

  // Advanced customization methods
  void adjustBrightness(double value) => brightness = value.clamp(-1.0, 1.0);
  void adjustContrast(double value) => contrast = value.clamp(0.0, 2.0);
  void adjustSaturation(double value) => saturation = value.clamp(0.0, 2.0);
  void adjustHue(double value) => hue = value % 360.0;
  void adjustOpacity(double value) => opacity = value.clamp(0.0, 1.0);

  void setBorder({double? radius, double? width, Color? color}) {
    if (radius != null) borderRadius = radius;
    if (width != null) borderWidth = width;
    if (color != null) borderColor = color;
  }

  void setShadow({double? blur, Offset? offset, Color? color}) {
    if (blur != null) shadowBlur = blur;
    if (offset != null) shadowOffset = offset;
    if (color != null) shadowColor = color;
  }

  void setTransform({double? rotation, bool? flipH, bool? flipV}) {
    if (rotation != null) rotationAngle = rotation;
    if (flipH != null) flipHorizontal = flipH;
    if (flipV != null) flipVertical = flipV;
  }

  void applyFilter(ImageFilter filter) {
    switch (filter) {
      case ImageFilter.grayscale:
        grayscale = !grayscale;
        break;
      case ImageFilter.sepia:
        sepia = !sepia;
        break;
      case ImageFilter.vintage:
        vintage = !vintage;
        break;
      case ImageFilter.emboss:
        emboss = !emboss;
        break;
    }
  }

  void resetFilters() {
    brightness = 0.0;
    contrast = 1.0;
    saturation = 1.0;
    hue = 0.0;
    opacity = 1.0;
    grayscale = false;
    sepia = false;
    vintage = false;
    vignette = 0.0;
    noiseIntensity = 0.0;
    sharpen = 0.0;
    emboss = false;
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      // Existing properties
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
      // Advanced properties
      'brightness': brightness,
      'contrast': contrast,
      'saturation': saturation,
      'hue': hue,
      'opacity': opacity,
      'borderRadius': borderRadius,
      'borderWidth': borderWidth,
      if (borderColor != null) 'borderColor': borderColor?.value,
      'shadowBlur': shadowBlur,
      'shadowOffset': {'dx': shadowOffset.dx, 'dy': shadowOffset.dy},
      if (shadowColor != null) 'shadowColor': shadowColor?.value,
      'rotationAngle': rotationAngle,
      'flipHorizontal': flipHorizontal,
      'flipVertical': flipVertical,
      'grayscale': grayscale,
      'sepia': sepia,
      'vintage': vintage,
      'vignette': vignette,
      if (vignetteColor != null) 'vignetteColor': vignetteColor?.value,
      if (overlayColor != null) 'overlayColor': overlayColor?.value,
      if (overlayBlendMode != null) 'overlayBlendMode': overlayBlendMode?.index,
      'maskShape': maskShape.index,
      'noiseIntensity': noiseIntensity,
      'sharpen': sharpen,
      'emboss': emboss,
    };
  }
}

// Enhanced StackImageItem with all existing functionality preserved
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

  // Existing methods preserved
  void setUrl(String url) {
    content?.setRes(url: url);
  }

  void setAssetName(String assetName) {
    content?.setRes(assetName: assetName);
  }

  // New advanced customization methods
  void applyColorAdjustments({
    double? brightness,
    double? contrast,
    double? saturation,
    double? hue,
    double? opacity,
  }) {
    if (brightness != null) content?.adjustBrightness(brightness);
    if (contrast != null) content?.adjustContrast(contrast);
    if (saturation != null) content?.adjustSaturation(saturation);
    if (hue != null) content?.adjustHue(hue);
    if (opacity != null) content?.adjustOpacity(opacity);
  }

  void applyBorderAndShadow({
    double? borderRadius,
    double? borderWidth,
    Color? borderColor,
    double? shadowBlur,
    Offset? shadowOffset,
    Color? shadowColor,
  }) {
    content?.setBorder(
      radius: borderRadius,
      width: borderWidth,
      color: borderColor,
    );
    content?.setShadow(
      blur: shadowBlur,
      offset: shadowOffset,
      color: shadowColor,
    );
  }

  void applyTransformations({
    double? rotation,
    bool? flipHorizontal,
    bool? flipVertical,
  }) {
    content?.setTransform(
      rotation: rotation,
      flipH: flipHorizontal,
      flipV: flipVertical,
    );
  }

  void applyFilter(ImageFilter filter) {
    content?.applyFilter(filter);
  }

  void resetAllFilters() {
    content?.resetFilters();
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
    );
  }
}

// import 'package:cardmaker/stack_board/lib/helpers.dart';
// import 'package:cardmaker/stack_board/lib/src/widget_style_extension/ex_size.dart';
// import 'package:cardmaker/stack_board/lib/stack_board_item.dart';
// import 'package:cardmaker/stack_board/lib/widget_style_extension.dart';
// import 'package:flutter/material.dart';

// class ImageItemContent extends StackItemContent {
//   ImageItemContent({
//     this.url,
//     this.assetName,
//     this.semanticLabel,
//     this.excludeFromSemantics = false,
//     this.width,
//     this.height,
//     this.color,
//     this.colorBlendMode,
//     this.fit = BoxFit.cover,
//     this.repeat = ImageRepeat.noRepeat,
//     this.matchTextDirection = false,
//     this.gaplessPlayback = false,
//     this.isAntiAlias = false,
//     this.filterQuality = FilterQuality.low,
//   }) {
//     _init();
//   }

//   factory ImageItemContent.fromJson(Map<String, dynamic> json) {
//     return ImageItemContent(
//       url: json['url'] != null ? asT<String>(json['url']) : null,
//       assetName: json['assetName'] != null
//           ? asT<String>(json['assetName'])
//           : null,
//       semanticLabel: json['semanticLabel'] != null
//           ? asT<String>(json['semanticLabel'])
//           : null,
//       excludeFromSemantics:
//           asNullT<bool>(json['excludeFromSemantics']) ?? false,
//       width: json['width'] != null ? asT<double>(json['width']) : null,
//       height: json['height'] != null ? asT<double>(json['height']) : null,
//       color: json['color'] != null ? Color(asT<int>(json['color'])) : null,
//       colorBlendMode: json['colorBlendMode'] != null
//           ? BlendMode.values[asT<int>(json['colorBlendMode'])]
//           : BlendMode.srcIn,
//       fit: json['fit'] != null
//           ? BoxFit.values[asT<int>(json['fit'])]
//           : BoxFit.cover,
//       repeat: json['repeat'] != null
//           ? ImageRepeat.values[asT<int>(json['repeat'])]
//           : ImageRepeat.noRepeat,
//       matchTextDirection: asNullT<bool>(json['matchTextDirection']) ?? false,
//       gaplessPlayback: asNullT<bool>(json['gaplessPlayback']) ?? false,
//       isAntiAlias: asNullT<bool>(json['isAntiAlias']) ?? true,
//       filterQuality: json['filterQuality'] != null
//           ? FilterQuality.values[asT<int>(json['filterQuality'])]
//           : FilterQuality.high,
//     );
//   }

//   void _init() {
//     if (url != null && assetName != null) {
//       throw Exception('url and assetName can not be set at the same time');
//     }

//     if (url == null && assetName == null) {
//       throw Exception('url and assetName can not be null at the same time');
//     }

//     if (url != null) {
//       _image = NetworkImage(url!);
//     } else if (assetName != null) {
//       _image = AssetImage(assetName!);
//     }
//   }

//   late ImageProvider _image;
//   String? url;
//   String? assetName;
//   String? semanticLabel;
//   bool excludeFromSemantics;
//   double? width;
//   double? height;
//   Color? color;
//   BlendMode? colorBlendMode;
//   BoxFit fit;
//   ImageRepeat repeat;
//   bool matchTextDirection;
//   bool gaplessPlayback;
//   bool isAntiAlias;
//   FilterQuality filterQuality;

//   ImageProvider get image => _image;

//   void setRes({String? url, String? assetName}) {
//     if (url != null) this.url = url;
//     if (assetName != null) this.assetName = assetName;
//     _init();
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return <String, dynamic>{
//       if (url != null) 'url': url,
//       if (assetName != null) 'assetName': assetName,
//       if (semanticLabel != null) 'semanticLabel': semanticLabel,
//       'excludeFromSemantics': excludeFromSemantics,
//       if (width != null) 'width': width,
//       if (height != null) 'height': height,
//       if (color != null) 'color': color?.value,
//       if (colorBlendMode != null) 'colorBlendMode': colorBlendMode?.index,
//       'fit': fit.index,
//       'repeat': repeat.index,
//       'matchTextDirection': matchTextDirection,
//       'gaplessPlayback': gaplessPlayback,
//       'isAntiAlias': isAntiAlias,
//       'filterQuality': filterQuality.index,
//     };
//   }
// }

// class StackImageItem extends StackItem<ImageItemContent> {
//   StackImageItem({
//     required super.content,
//     super.id,
//     super.angle = null,
//     required super.size,
//     super.offset,
//     super.status = null,
//     super.lockZOrder = null,
//     super.isProfileImage = false,
//   });

//   factory StackImageItem.fromJson(Map<String, dynamic> data) {
//     return StackImageItem(
//       id: data['id'] == null ? null : asT<String>(data['id']),
//       angle: data['angle'] == null ? null : asT<double>(data['angle']),
//       size: jsonToSize(asMap(data['size'])),
//       offset: data['offset'] == null
//           ? null
//           : jsonToOffset(asMap(data['offset'])),
//       status: StackItemStatus.values[data['status'] as int],
//       lockZOrder: asNullT<bool>(data['lockZOrder']) ?? false,
//       isProfileImage: asNullT<bool>(data['isProfileImage']) ?? false,
//       content: ImageItemContent.fromJson(asMap(data['content'])),
//     );
//   }

//   void setUrl(String url) {
//     content?.setRes(url: url);
//   }

//   void setAssetName(String assetName) {
//     content?.setRes(assetName: assetName);
//   }

//   @override
//   StackImageItem copyWith({
//     Size? size,
//     Offset? offset,
//     double? angle,
//     StackItemStatus? status,
//     bool? lockZOrder,
//     ImageItemContent? content,
//     bool? isProfileImage,
//     bool? isCentered,
//   }) {
//     return StackImageItem(
//       id: id,
//       size: size ?? this.size,
//       offset: offset ?? this.offset,
//       angle: angle ?? this.angle,
//       status: status ?? this.status,
//       lockZOrder: lockZOrder ?? this.lockZOrder,
//       content: content ?? this.content,
//       isProfileImage: isProfileImage ?? this.isProfileImage,

//       // isCentered is ignored here unless you want to use it
//     );
//   }
// }
