import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../stack_items.dart';

enum ImageMaskShape { none, circle, roundedRectangle, star, heart, hexagon }

class ImagePattern {
  final String assetPath;
  final BlendMode blendMode;
  final double opacity;

  ImagePattern({
    required this.assetPath,
    this.blendMode = BlendMode.overlay,
    this.opacity = 0.5,
  });
}

class StackImageCase extends StatelessWidget {
  const StackImageCase({super.key, required this.item});

  final StackImageItem item;

  ImageItemContent get content => item.content!;

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = Image(
      image: content.image,
      width: content.width,
      height: content.height,
      fit: content.fit,
      color: content.color,
      colorBlendMode: content.colorBlendMode,
      repeat: content.repeat,
      filterQuality: content.filterQuality,
      gaplessPlayback: content.gaplessPlayback,
      isAntiAlias: content.isAntiAlias,
      matchTextDirection: content.matchTextDirection,
      excludeFromSemantics: content.excludeFromSemantics,
      semanticLabel: content.semanticLabel,
    );

    // Apply advanced transformations and effects
    imageWidget = _applyAdvancedEffects(imageWidget);

    return imageWidget;
  }

  Widget _applyAdvancedEffects(Widget imageWidget) {
    Widget result = imageWidget;

    // Apply flip transformations
    if (content.flipHorizontal || content.flipVertical) {
      result = Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..scale(
            content.flipHorizontal ? -1.0 : 1.0,
            content.flipVertical ? -1.0 : 1.0,
          ),
        child: result,
      );
    }

    // Apply rotation
    if (content.rotationAngle != 0.0) {
      result = Transform.rotate(
        angle: content.rotationAngle * (3.14159 / 180.0),
        child: result,
      );
    }

    // Apply color filters and adjustments using unified system
    result = _applyColorFilters(result);

    // Apply border radius
    if (content.borderRadius > 0.0) {
      result = ClipRRect(
        borderRadius: BorderRadius.circular(content.borderRadius),
        child: result,
      );
    }

    // Apply mask shape
    result = _applyMaskShape(result);

    // Apply border
    if (content.borderWidth > 0.0 && content.borderColor != null) {
      result = Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: content.borderColor!,
            width: content.borderWidth,
          ),
          borderRadius: content.borderRadius > 0.0
              ? BorderRadius.circular(content.borderRadius)
              : null,
        ),
        child: result,
      );
    }

    // Apply shadow
    if (content.shadowBlur > 0.0) {
      result = Container(
        decoration: BoxDecoration(
          borderRadius: content.borderRadius > 0.0
              ? BorderRadius.circular(content.borderRadius)
              : null,
          boxShadow: [
            BoxShadow(
              color: content.shadowColor ?? Colors.black.withOpacity(0.3),
              blurRadius: content.shadowBlur,
              offset: content.shadowOffset,
            ),
          ],
        ),
        child: result,
      );
    }

    // Apply opacity
    if (content.opacity < 1.0) {
      result = Opacity(opacity: content.opacity, child: result);
    }

    // Apply overlay effects
    result = _applyOverlayEffects(result);

    return result;
  }

  Widget _applyColorFilters(Widget widget) {
    // Use the unified color filter system
    List<double> matrix = ColorFilterMatrixes.combineMatrices(
      content.activeFilter,
      content.brightness,
      content.contrast,
      content.saturation,
    );

    // Apply hue adjustment if needed
    // if (content.hue != 0.0) {
    //   matrix = ColorFilterMatrixes._multiplyMatrices(
    //     matrix,
    //     _createHueMatrix(content.hue),
    //   );
    // }

    // Check if any filter is applied
    bool hasFilter =
        content.activeFilter != 'none' ||
        content.brightness != 0.0 ||
        content.contrast != 1.0 ||
        content.saturation != 1.0 ||
        content.hue != 0.0;

    if (!hasFilter) {
      return widget;
    }

    return ColorFiltered(
      colorFilter: ColorFilter.matrix(matrix),
      child: widget,
    );
  }

  // Create hue adjustment matrix
  List<double> _createHueMatrix(double hue) {
    double hueRadians = hue * (3.14159 / 180.0);
    double cosHue = math.cos(hueRadians);
    double sinHue = math.sin(hueRadians);

    // Standard hue rotation matrix
    return [
      0.213 + cosHue * 0.787 - sinHue * 0.213,
      0.715 - cosHue * 0.715 - sinHue * 0.715,
      0.072 - cosHue * 0.072 + sinHue * 0.928,
      0,
      0,
      0.213 - cosHue * 0.213 + sinHue * 0.143,
      0.715 + cosHue * 0.285 + sinHue * 0.140,
      0.072 - cosHue * 0.072 - sinHue * 0.283,
      0,
      0,
      0.213 - cosHue * 0.213 - sinHue * 0.787,
      0.715 - cosHue * 0.715 + sinHue * 0.715,
      0.072 + cosHue * 0.928 + sinHue * 0.072,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];
  }

  Widget _applyMaskShape(Widget widget) {
    switch (content.maskShape) {
      case ImageMaskShape.circle:
        return ClipOval(child: widget);
      case ImageMaskShape.roundedRectangle:
        return ClipRRect(
          borderRadius: BorderRadius.circular(content.borderRadius),
          child: widget,
        );
      case ImageMaskShape.star:
        return ClipPath(clipper: StarClipper(), child: widget);
      case ImageMaskShape.heart:
        return ClipPath(clipper: HeartClipper(), child: widget);
      case ImageMaskShape.hexagon:
        return ClipPath(clipper: HexagonClipper(), child: widget);
      case ImageMaskShape.none:
      default:
        return widget;
    }
  }

  Widget _applyOverlayEffects(Widget widget) {
    List<Widget> children = [widget];

    // Apply gradient overlay
    if (content.gradientOverlay != null) {
      children.add(
        Positioned.fill(
          child: Container(
            width: content.width,
            height: content.height,
            decoration: BoxDecoration(gradient: content.gradientOverlay),
          ),
        ),
      );
    }

    // Apply color overlay
    if (content.overlayColor != null) {
      children.add(
        Positioned.fill(
          child: Container(
            width: content.width,
            height: content.height,
            color: content.overlayColor,
            child: content.overlayBlendMode != null
                ? ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      content.overlayColor!,
                      content.overlayBlendMode!,
                    ),
                    child: Container(),
                  )
                : null,
          ),
        ),
      );
    }

    // Apply vignette effect
    if (content.vignette > 0.0) {
      children.add(
        Positioned.fill(
          child: Container(
            width: content.width,
            height: content.height,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.transparent,
                  (content.vignetteColor ?? Colors.black).withOpacity(
                    content.vignette,
                  ),
                ],
                stops: const [0.3, 1.0],
              ),
            ),
          ),
        ),
      );
    }

    // Apply noise effect
    if (content.noiseIntensity > 0.0) {
      children.add(
        Positioned.fill(
          child: SizedBox(
            width: content.width,
            height: content.height,
            child: Opacity(
              opacity: content.noiseIntensity,
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/noise_texture.png'),
                    fit: BoxFit.cover,
                    opacity: 0.1,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Wrap the Stack with a SizedBox to enforce image dimensions
    return children.length == 1
        ? widget
        : SizedBox(
            width: content.width,
            height: content.height,
            child: Stack(
              fit: StackFit.passthrough,
              alignment: Alignment.center,
              children: children,
            ),
          );
  }
}

// Updated enums and helper classes
enum ImageFilters {
  none,
  grayscale,
  sepia,
  vintage,
  mood,
  crisp,
  cool,
  blush,
  sunkissed,
  fresh,
  classic,
  lomo,
  nashville,
  valencia,
  clarendon,
  moon,
  willow,
  kodak,
  frost,
  nightvision,
  sunset,
  noir,
  dreamy,
  radium,
  aqua,
  purplehaze,
  lemonade,
  caramel,
  peachy,
  coolblue,
  contrast,
  neon,
  coldmorning,
  lush,
  urbanneon,
  moodymonochrome,
  emboss,
}

extension ImageFilterExtension on ImageFilters {
  String get name {
    return toString().split('.').last;
  }
}

// Required imports (add these to your file)
// import 'dart:math' as math;

// Custom clippers (implement these if not already available)
class StarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double centerX = size.width / 2;
    double centerY = size.height / 2;
    double radius = math.min(centerX, centerY);

    for (int i = 0; i < 10; i++) {
      double angle = (i * math.pi) / 5;
      double r = i % 2 == 0 ? radius : radius * 0.5;
      double x = centerX + r * math.cos(angle - math.pi / 2);
      double y = centerY + r * math.sin(angle - math.pi / 2);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class HeartClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double width = size.width;
    double height = size.height;

    path.moveTo(width / 2, height * 0.3);
    path.cubicTo(
      width / 2,
      height * 0.1,
      width * 0.1,
      height * 0.1,
      width * 0.1,
      height * 0.3,
    );
    path.cubicTo(
      width * 0.1,
      height * 0.5,
      width / 2,
      height * 0.7,
      width / 2,
      height * 0.9,
    );
    path.cubicTo(
      width / 2,
      height * 0.7,
      width * 0.9,
      height * 0.5,
      width * 0.9,
      height * 0.3,
    );
    path.cubicTo(
      width * 0.9,
      height * 0.1,
      width / 2,
      height * 0.1,
      width / 2,
      height * 0.3,
    );
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double centerX = size.width / 2;
    double centerY = size.height / 2;
    double radius = math.min(centerX, centerY);

    for (int i = 0; i < 6; i++) {
      double angle = (i * math.pi) / 3;
      double x = centerX + radius * math.cos(angle);
      double y = centerY + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
