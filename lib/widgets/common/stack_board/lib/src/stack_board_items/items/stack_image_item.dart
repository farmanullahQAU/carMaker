import 'dart:io';

import 'package:cardmaker/core/extensions/extensions.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/helpers.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/src/widget_style_extension/ex_size.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/stack_board_item.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/stack_case.dart'
    show ImageFilters, ImageMaskShape, ImagePattern;
import 'package:cardmaker/widgets/common/stack_board/lib/widget_style_extension.dart';
import 'package:flutter/material.dart';

// Enhanced ImageItemContent with unified color matrix approach
class ImageItemContent extends StackItemContent {
  ImageItemContent({
    this.url,
    this.assetName,
    this.filePath,
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
    // Advanced customization properties
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
    // Unified filter system
    this.activeFilter = 'none',
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
    // Shape-specific border properties
    this.shapeBorderWidth = 0.0,
    this.shapeBorderColor,
    this.shapeBorderRadius = 0.0,
  }) {
    _init();
  }
  ImageItemContent copyWith({
    String? url,
    String? assetName,
    String? filePath,
    String? semanticLabel,
    bool? excludeFromSemantics,
    double? width,
    double? height,
    Color? color,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    ImageRepeat? repeat,
    bool? matchTextDirection,
    bool? gaplessPlayback,
    bool? isAntiAlias,
    FilterQuality? filterQuality,
    // Advanced properties
    double? brightness,
    double? contrast,
    double? saturation,
    double? hue,
    double? opacity,
    double? borderRadius,
    double? borderWidth,
    Color? borderColor,
    double? shadowBlur,
    Offset? shadowOffset,
    Color? shadowColor,
    double? rotationAngle,
    bool? flipHorizontal,
    bool? flipVertical,
    // Filter system
    String? activeFilter,
    double? vignette,
    Color? vignetteColor,
    Color? overlayColor,
    BlendMode? overlayBlendMode,
    Rect? cropRect,
    ImageMaskShape? maskShape,
    Gradient? gradientOverlay,
    ImagePattern? patternOverlay,
    double? noiseIntensity,
    double? sharpen,
    bool? emboss,
    // Shape border properties
    double? shapeBorderWidth,
    Color? shapeBorderColor,
    double? shapeBorderRadius,
  }) {
    return ImageItemContent(
      url: url ?? this.url,
      assetName: assetName ?? this.assetName,
      filePath: filePath ?? this.filePath,
      semanticLabel: semanticLabel ?? this.semanticLabel,
      excludeFromSemantics: excludeFromSemantics ?? this.excludeFromSemantics,
      width: width ?? this.width,
      height: height ?? this.height,
      color: color ?? this.color,
      colorBlendMode: colorBlendMode ?? this.colorBlendMode,
      fit: fit ?? this.fit,
      repeat: repeat ?? this.repeat,
      matchTextDirection: matchTextDirection ?? this.matchTextDirection,
      gaplessPlayback: gaplessPlayback ?? this.gaplessPlayback,
      isAntiAlias: isAntiAlias ?? this.isAntiAlias,
      filterQuality: filterQuality ?? this.filterQuality,
      // Advanced properties
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      saturation: saturation ?? this.saturation,
      hue: hue ?? this.hue,
      opacity: opacity ?? this.opacity,
      borderRadius: borderRadius ?? this.borderRadius,
      borderWidth: borderWidth ?? this.borderWidth,
      borderColor: borderColor ?? this.borderColor,
      shadowBlur: shadowBlur ?? this.shadowBlur,
      shadowOffset: shadowOffset ?? this.shadowOffset,
      shadowColor: shadowColor ?? this.shadowColor,
      rotationAngle: rotationAngle ?? this.rotationAngle,
      flipHorizontal: flipHorizontal ?? this.flipHorizontal,
      flipVertical: flipVertical ?? this.flipVertical,
      // Filter system
      activeFilter: activeFilter ?? this.activeFilter,
      vignette: vignette ?? this.vignette,
      vignetteColor: vignetteColor ?? this.vignetteColor,
      overlayColor: overlayColor ?? this.overlayColor,
      overlayBlendMode: overlayBlendMode ?? this.overlayBlendMode,
      cropRect: cropRect ?? this.cropRect,
      maskShape: maskShape ?? this.maskShape,
      gradientOverlay: gradientOverlay ?? this.gradientOverlay,
      patternOverlay: patternOverlay ?? this.patternOverlay,
      noiseIntensity: noiseIntensity ?? this.noiseIntensity,
      sharpen: sharpen ?? this.sharpen,
      emboss: emboss ?? this.emboss,
      // Shape border properties
      shapeBorderWidth: shapeBorderWidth ?? this.shapeBorderWidth,
      shapeBorderColor: shapeBorderColor ?? this.shapeBorderColor,
      shapeBorderRadius: shapeBorderRadius ?? this.shapeBorderRadius,
    );
  }

  void _init() {
    if (url != null && assetName != null && filePath != null) {
      throw Exception('url and assetName can not be set at the same time');
    }

    if (url == null && assetName == null && filePath == null) {
      throw Exception('url and assetName can not be null at the same time');
    }

    if (url != null) {
      _image = NetworkImage(url!);
    } else if (assetName != null) {
      _image = AssetImage(assetName!);
    } else if (filePath != null) {
      _image = FileImage(File(filePath!));
    }
  }

  // Existing properties
  late ImageProvider _image;
  String? url;
  String? assetName;
  String? filePath; //when iamge is picked using iamgepicker
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

  // Unified filter system - only one filter can be active
  String activeFilter; // 'none', 'vintage', 'grayscale', etc.

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

  double shapeBorderWidth = 0.0;
  Color? shapeBorderColor;
  double shapeBorderRadius = 0.0; // Only for rounded rectangle

  void setRes({String? url, String? assetName, String? filePath}) {
    if (url != null) this.url = url;
    if (assetName != null) this.assetName = assetName;
    if (filePath != null) this.filePath = filePath;

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

  // Unified filter application
  void applyFilter(String filterName) {
    activeFilter = filterName;
  }

  void resetFilters() {
    brightness = 0.0;
    contrast = 1.0;
    saturation = 1.0;
    hue = 0.0;
    opacity = 1.0;
    activeFilter = 'none';
    vignette = 0.0;
    noiseIntensity = 0.0;
    sharpen = 0.0;
    emboss = false;
  }

  factory ImageItemContent.fromJson(Map<String, dynamic> json) {
    return ImageItemContent(
      url: json['url'] != null ? asT<String>(json['url']) : null,
      assetName: json['assetName'] != null
          ? asT<String>(json['assetName'])
          : null,
      filePath: json['filePath'] != null ? asT<String>(json['filePath']) : null,
      semanticLabel: json['semanticLabel'] != null
          ? asT<String>(json['semanticLabel'])
          : null,
      excludeFromSemantics:
          asNullT<bool>(json['excludeFromSemantics']) ?? false,
      width: json['width'] != null ? asT<double>(json['width']) : null,
      height: json['height'] != null ? asT<double>(json['height']) : null,
      color: ColorExtension.fromARGB32(json['color'] as String?),
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
      borderColor: ColorExtension.fromARGB32(json['borderColor'] as String?),
      shadowBlur: asNullT<double>(json['shadowBlur']) ?? 0.0,
      shadowOffset: json['shadowOffset'] != null
          ? Offset(
              asT<double>(json['shadowOffset']['dx']),
              asT<double>(json['shadowOffset']['dy']),
            )
          : const Offset(0, 0),
      shadowColor: ColorExtension.fromARGB32(json['shadowColor'] as String?),
      rotationAngle: asNullT<double>(json['rotationAngle']) ?? 0.0,
      flipHorizontal: asNullT<bool>(json['flipHorizontal']) ?? false,
      flipVertical: asNullT<bool>(json['flipVertical']) ?? false,
      activeFilter: asNullT<String>(json['activeFilter']) ?? 'none',
      vignette: asNullT<double>(json['vignette']) ?? 0.0,
      vignetteColor: ColorExtension.fromARGB32(
        json['vignetteColor'] as String?,
      ),
      overlayColor: ColorExtension.fromARGB32(json['overlayColor'] as String?),
      overlayBlendMode: json['overlayBlendMode'] != null
          ? BlendMode.values[asT<int>(json['overlayBlendMode'])]
          : null,
      maskShape: json['maskShape'] != null
          ? ImageMaskShape.values[asT<int>(json['maskShape'])]
          : ImageMaskShape.none,
      noiseIntensity: asNullT<double>(json['noiseIntensity']) ?? 0.0,
      sharpen: asNullT<double>(json['sharpen']) ?? 0.0,
      emboss: asNullT<bool>(json['emboss']) ?? false,
      // Shape border properties
      shapeBorderWidth: asNullT<double>(json['shapeBorderWidth']) ?? 0.0,
      shapeBorderColor: ColorExtension.fromARGB32(
        json['shapeBorderColor'] as String?,
      ),
      shapeBorderRadius: asNullT<double>(json['shapeBorderRadius']) ?? 0.0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (url != null) 'url': url,
      if (assetName != null) 'assetName': assetName,
      if (filePath != null) 'filePath': filePath,
      if (semanticLabel != null) 'semanticLabel': semanticLabel,
      'excludeFromSemantics': excludeFromSemantics,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (color != null) 'color': color?.toARGB32(),
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
      if (borderColor != null) 'borderColor': borderColor?.toARGB32(),
      'shadowBlur': shadowBlur,
      'shadowOffset': {'dx': shadowOffset.dx, 'dy': shadowOffset.dy},
      if (shadowColor != null) 'shadowColor': shadowColor?.toARGB32(),
      'rotationAngle': rotationAngle,
      'flipHorizontal': flipHorizontal,
      'flipVertical': flipVertical,
      'activeFilter': activeFilter,
      'vignette': vignette,
      if (vignetteColor != null) 'vignetteColor': vignetteColor?.toARGB32(),
      if (overlayColor != null) 'overlayColor': overlayColor?.toARGB32(),
      if (overlayBlendMode != null) 'overlayBlendMode': overlayBlendMode?.index,
      'maskShape': maskShape.index,
      'noiseIntensity': noiseIntensity,
      'sharpen': sharpen,
      'emboss': emboss,
      // Shape border properties
      'shapeBorderWidth': shapeBorderWidth,
      if (shapeBorderColor != null)
        'shapeBorderColor': shapeBorderColor?.toARGB32(),
      'shapeBorderRadius': shapeBorderRadius,
    };
  }

  /*
factory ImageItemContent.fromJson(Map<String, dynamic> json) {
    return ImageItemContent(
      url: json['url'] != null ? asT<String>(json['url']) : null,
      assetName: json['assetName'] != null
          ? asT<String>(json['assetName'])
          : null,
      filePath: json['filePath'] != null ? asT<String>(json['filePath']) : null,
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
      activeFilter: asNullT<String>(json['activeFilter']) ?? 'none',
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
      // Shape border properties
      shapeBorderWidth: asNullT<double>(json['shapeBorderWidth']) ?? 0.0,
      shapeBorderColor: json['shapeBorderColor'] != null
          ? Color(asT<int>(json['shapeBorderColor']))
          : null,
      shapeBorderRadius: asNullT<double>(json['shapeBorderRadius']) ?? 0.0,
    );
  }
  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      // Existing properties
      if (url != null) 'url': url,
      if (assetName != null) 'assetName': assetName,
      if (filePath != null) 'filePath': filePath,
      if (semanticLabel != null) 'semanticLabel': semanticLabel,
      'excludeFromSemantics': excludeFromSemantics,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (color != null) 'color': color,
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
      if (borderColor != null) 'borderColor': borderColor?.toARGB32,

      'shadowBlur': shadowBlur,
      'shadowOffset': {'dx': shadowOffset.dx, 'dy': shadowOffset.dy},
      if (shadowColor != null) 'shadowColor': shadowColor?.toARGB32,
      'rotationAngle': rotationAngle,
      'flipHorizontal': flipHorizontal,
      'flipVertical': flipVertical,
      'activeFilter': activeFilter,
      'vignette': vignette,
      if (vignetteColor != null) 'vignetteColor': vignetteColor?.toARGB32(),
      if (overlayColor != null) 'overlayColor': overlayColor?.toARGB32(),
      if (overlayBlendMode != null) 'overlayBlendMode': overlayBlendMode?.index,
      'maskShape': maskShape.index,
      'noiseIntensity': noiseIntensity,
      'sharpen': sharpen,
      'emboss': emboss,

      // Shape border properties
      'shapeBorderWidth': shapeBorderWidth,
      if (shapeBorderColor != null)
        'shapeBorderColor': shapeBorderColor?.toARGB32(),
      'shapeBorderRadius': shapeBorderRadius,
    };
  }
*/
}

// Unified Color Filter System - Single source of truth for all filters
class ColorFilterMatrixes {
  // Identity matrix (no filter)
  static const List<double> identity = [
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  // Basic adjustment matrices
  static List<double> brightness(double value) {
    double b = value * 255;
    return [1, 0, 0, 0, b, 0, 1, 0, 0, b, 0, 0, 1, 0, b, 0, 0, 0, 1, 0];
  }

  static List<double> contrast(double value) {
    double c = value;
    double o = (1 - c) * 127.5;
    return [c, 0, 0, 0, o, 0, c, 0, 0, o, 0, 0, c, 0, o, 0, 0, 0, 1, 0];
  }

  static List<double> saturation(double value) {
    double s = value;
    double sr = (1 - s) * 0.3086;
    double sg = (1 - s) * 0.6094;
    double sb = (1 - s) * 0.0820;
    return [
      sr + s,
      sg,
      sb,
      0,
      0,
      sr,
      sg + s,
      sb,
      0,
      0,
      sr,
      sg,
      sb + s,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];
  }

  // Preset filter matrices
  static const List<double> grayscale = [
    0.299,
    0.587,
    0.114,
    0,
    0,
    0.299,
    0.587,
    0.114,
    0,
    0,
    0.299,
    0.587,
    0.114,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  static const List<double> sepia = [
    0.393,
    0.769,
    0.189,
    0,
    0,
    0.349,
    0.686,
    0.168,
    0,
    0,
    0.272,
    0.534,
    0.131,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  static const List<double> vintage = [
    0.8,
    0.1,
    0.1,
    0,
    20,
    0.1,
    0.8,
    0.1,
    0,
    20,
    0.1,
    0.1,
    0.8,
    0,
    20,
    0,
    0,
    0,
    1,
    0,
  ];

  static const List<double> mood = [
    1.2,
    0.1,
    0.1,
    0,
    10,
    0.1,
    1,
    0.1,
    0,
    10,
    0.1,
    0.1,
    1,
    0,
    10,
    0,
    0,
    0,
    1,
    0,
  ];

  static const List<double> crisp = [
    1.2,
    0,
    0,
    0,
    0,
    0,
    1.2,
    0,
    0,
    0,
    0,
    0,
    1.2,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  static const List<double> cool = [
    0.9,
    0,
    0.2,
    0,
    0,
    0,
    1,
    0.1,
    0,
    0,
    0.1,
    0,
    1.2,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  static const List<double> blush = [
    1.1,
    0.1,
    0.1,
    0,
    10,
    0.1,
    1,
    0.1,
    0,
    10,
    0.1,
    0.1,
    1,
    0,
    5,
    0,
    0,
    0,
    1,
    0,
  ];

  static const List<double> sunkissed = [
    1.3,
    0,
    0.1,
    0,
    15,
    0,
    1.1,
    0.1,
    0,
    10,
    0,
    0,
    0.9,
    0,
    5,
    0,
    0,
    0,
    1,
    0,
  ];

  static const List<double> fresh = [
    1.2,
    0,
    0,
    0,
    20,
    0,
    1.2,
    0,
    0,
    20,
    0,
    0,
    1.1,
    0,
    20,
    0,
    0,
    0,
    1,
    0,
  ];

  static const List<double> classic = [
    1.1,
    0,
    -0.1,
    0,
    10,
    -0.1,
    1.1,
    0.1,
    0,
    5,
    0,
    -0.1,
    1.1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  static const List<double> lomo = [
    1.5,
    0,
    0.1,
    0,
    0,
    0,
    1.45,
    0,
    0,
    0,
    0.1,
    0,
    1.3,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  static const List<double> nashville = [
    1.2,
    0.15,
    -0.15,
    0,
    15,
    0.1,
    1.1,
    0.1,
    0,
    10,
    -0.05,
    0.2,
    1.25,
    0,
    5,
    0,
    0,
    0,
    1,
    0,
  ];

  static const List<double> valencia = [
    1.15,
    0.1,
    0.1,
    0,
    20,
    0.1,
    1.1,
    0,
    0,
    10,
    0.1,
    0.1,
    1.2,
    0,
    5,
    0,
    0,
    0,
    1,
    0,
  ];

  static const List<double> clarendon = [
    1.2,
    0,
    0,
    0,
    10,
    0,
    1.25,
    0,
    0,
    10,
    0,
    0,
    1.3,
    0,
    10,
    0,
    0,
    0,
    1,
    0,
  ];

  static const List<double> moon = [
    0.33,
    0.33,
    0.33,
    0,
    0,
    0.33,
    0.33,
    0.33,
    0,
    0,
    0.33,
    0.33,
    0.33,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  static const List<double> willow = [
    0.5,
    0.5,
    0.5,
    0,
    20,
    0.5,
    0.5,
    0.5,
    0,
    20,
    0.5,
    0.5,
    0.5,
    0,
    20,
    0,
    0,
    0,
    1,
    0,
  ];

  static const List<double> kodak = [
    1.3,
    0.1,
    -0.1,
    0,
    10,
    0,
    1.25,
    0.1,
    0,
    10,
    0,
    -0.1,
    1.1,
    0,
    5,
    0,
    0,
    0,
    1,
    0,
  ];

  static const List<double> frost = [
    0.8,
    0.2,
    0.1,
    0,
    0,
    0.2,
    1.1,
    0.1,
    0,
    0,
    0.1,
    0.1,
    1.2,
    0,
    10,
    0,
    0,
    0,
    1,
    0,
  ];

  static const List<double> nightVision = [
    0.1,
    0.95,
    0.2,
    0,
    0,
    0.1,
    1.5,
    0.1,
    0,
    0,
    0.2,
    0.7,
    0,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  static const List<double> sunset = [
    1.5,
    0.2,
    0,
    0,
    0,
    0.1,
    0.9,
    0.1,
    0,
    0,
    -0.1,
    -0.2,
    1.3,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  static const List<double> noir = [
    1.3,
    -0.3,
    0.1,
    0,
    0,
    -0.1,
    1.2,
    -0.1,
    0,
    0,
    0.1,
    -0.2,
    1.3,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  static const List<double> dreamy = [
    1.1,
    0.1,
    0.1,
    0,
    0,
    0.1,
    1.1,
    0.1,
    0,
    0,
    0.1,
    0.1,
    1.1,
    0,
    15,
    0,
    0,
    0,
    1,
    0,
  ];

  static const List<double> radium = [
    1.438,
    -0.062,
    -0.062,
    0,
    0,
    -0.122,
    1.378,
    -0.122,
    0,
    0,
    -0.016,
    -0.016,
    1.483,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  static const List<double> aqua = [
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.7873,
    0.2848,
    0.9278,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  static const List<double> purpleHaze = [
    1.3,
    0,
    1.2,
    0,
    0,
    0,
    1.1,
    0,
    0,
    0,
    0.2,
    0,
    1.3,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  static const List<double> lemonade = [
    1.2,
    0.1,
    0,
    0,
    0,
    0,
    1.1,
    0.2,
    0,
    0,
    0.1,
    0,
    0.7,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  static const List<double> caramel = [
    1.6,
    0.2,
    0,
    0,
    0,
    0.1,
    1.3,
    0.1,
    0,
    0,
    0,
    0.1,
    0.9,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  static const List<double> peachy = [
    1.3,
    0.5,
    0,
    0,
    0,
    0.2,
    1.1,
    0.3,
    0,
    0,
    0.1,
    0.1,
    1.2,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  static const List<double> coolBlue = [
    0.8,
    0.2,
    0.5,
    0,
    0,
    0.1,
    1.2,
    0.1,
    0,
    0,
    0.3,
    0.1,
    1.7,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  static const List<double> contrastFilter = [
    0.5,
    0,
    0,
    0,
    0,
    0,
    0.5,
    0,
    0,
    0,
    0,
    0,
    0.5,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  static const List<double> neon = [
    1,
    0,
    1,
    0,
    0,
    0,
    2,
    0,
    0,
    0,
    0,
    0,
    3,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  static const List<double> coldMorning = [
    0.9,
    0.1,
    0.2,
    0,
    0,
    0,
    1,
    0.1,
    0,
    0,
    0.1,
    0,
    1.2,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  static const List<double> lush = [
    0.9,
    0.2,
    0,
    0,
    0,
    0,
    1.2,
    0,
    0,
    0,
    0,
    0,
    1.1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  static const List<double> urbanNeon = [
    1.1,
    0,
    0.3,
    0,
    0,
    0,
    0.9,
    0.3,
    0,
    0,
    0.3,
    0.1,
    1.2,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  static const List<double> moodyMonochrome = [
    0.6,
    0.2,
    0.2,
    0,
    0,
    0.2,
    0.6,
    0.2,
    0,
    0,
    0.2,
    0.2,
    0.7,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  // Method to get matrix by filter name
  static List<double> getMatrix(String filterName) {
    switch (filterName) {
      case 'grayscale':
        return grayscale;
      case 'sepia':
        return sepia;
      case 'vintage':
        return vintage;
      case 'mood':
        return mood;
      case 'crisp':
        return crisp;
      case 'cool':
        return cool;
      case 'blush':
        return blush;
      case 'sunkissed':
        return sunkissed;
      case 'fresh':
        return fresh;
      case 'classic':
        return classic;
      case 'lomo':
        return lomo;
      case 'nashville':
        return nashville;
      case 'valencia':
        return valencia;
      case 'clarendon':
        return clarendon;
      case 'moon':
        return moon;
      case 'willow':
        return willow;
      case 'kodak':
        return kodak;
      case 'frost':
        return frost;
      case 'nightvision':
        return nightVision;
      case 'sunset':
        return sunset;
      case 'noir':
        return noir;
      case 'dreamy':
        return dreamy;
      case 'radium':
        return radium;
      case 'aqua':
        return aqua;
      case 'purplehaze':
        return purpleHaze;
      case 'lemonade':
        return lemonade;
      case 'caramel':
        return caramel;
      case 'peachy':
        return peachy;
      case 'coolblue':
        return coolBlue;
      case 'contrast':
        return contrastFilter;
      case 'neon':
        return neon;
      case 'coldmorning':
        return coldMorning;
      case 'lush':
        return lush;
      case 'urbanneon':
        return urbanNeon;
      case 'moodymonochrome':
        return moodyMonochrome;
      case 'none':
      default:
        return identity;
    }
  }

  // Combine multiple matrices (for adjustments + filters)
  static List<double> combineMatrices(
    String filterName,
    double brightness,
    double contrast,
    double saturation,
  ) {
    // Start with filter matrix
    List<double> result = getMatrix(filterName);

    // Apply adjustments if they're not default values
    if (brightness != 0.0) {
      result = _multiplyMatrices(
        result,
        ColorFilterMatrixes.brightness(brightness),
      );
    }

    if (contrast != 1.0) {
      result = _multiplyMatrices(
        result,
        ColorFilterMatrixes.contrast(contrast),
      );
    }

    if (saturation != 1.0) {
      result = _multiplyMatrices(
        result,
        ColorFilterMatrixes.saturation(saturation),
      );
    }

    return result;
  }

  // Matrix multiplication utility
  static List<double> _multiplyMatrices(List<double> a, List<double> b) {
    List<double> result = List.filled(20, 0.0);
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 5; j++) {
        for (int k = 0; k < 4; k++) {
          result[i * 5 + j] += a[i * 5 + k] * b[k * 5 + j];
        }
        if (j == 4) result[i * 5 + j] += a[i * 5 + j];
      }
    }
    return result;
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

  void applyFilter(ImageFilters filter) {
    content?.applyFilter(filter.name);
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
