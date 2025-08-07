import 'package:flutter/material.dart';

import '../../../stack_items.dart';

// class StackImageCase extends StatelessWidget {
//   const StackImageCase({super.key, required this.item});

//   final StackImageItem item;

//   ImageItemContent get content => item.content!;

//   @override
//   Widget build(BuildContext context) {
//     // return item.status == StackItemStatus.editing
//     //     ? Center(
//     //         child: TextFormField(
//     //           initialValue: item.content?.url,
//     //           onChanged: (String url) {
//     //             item.setUrl(url);
//     //           },
//     //         ),
//     //       )
//     //

//     return Image(
//       image: content.image,
//       width: content.width,
//       height: content.height,
//       fit: content.fit,

//       color: content.color,
//       colorBlendMode: content.colorBlendMode,
//       repeat: content.repeat,
//       filterQuality: content.filterQuality,
//       gaplessPlayback: content.gaplessPlayback,
//       isAntiAlias: content.isAntiAlias,
//       matchTextDirection: content.matchTextDirection,
//       excludeFromSemantics: content.excludeFromSemantics,
//       semanticLabel: content.semanticLabel,
//     );
//   }
// }
// Enhanced StackImageCase with advanced rendering
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

    // Apply color filters and adjustments
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
    if (content.brightness == 0.0 &&
        content.contrast == 1.0 &&
        content.saturation == 1.0 &&
        content.hue == 0.0 &&
        !content.grayscale &&
        !content.sepia &&
        !content.vintage) {
      return widget;
    }

    // Create color matrix for adjustments
    List<double> matrix = _createColorMatrix();

    return ColorFiltered(
      colorFilter: ColorFilter.matrix(matrix),
      child: widget,
    );
  }

  List<double> _createColorMatrix() {
    // Base identity matrix
    List<double> matrix = [
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

    // Apply brightness
    if (content.brightness != 0.0) {
      double b = content.brightness * 255;
      matrix = _multiplyMatrices(matrix, [
        1,
        0,
        0,
        0,
        b,
        0,
        1,
        0,
        0,
        b,
        0,
        0,
        1,
        0,
        b,
        0,
        0,
        0,
        1,
        0,
      ]);
    }

    // Apply contrast
    if (content.contrast != 1.0) {
      double c = content.contrast;
      double o = (1 - c) * 127.5;
      matrix = _multiplyMatrices(matrix, [
        c,
        0,
        0,
        0,
        o,
        0,
        c,
        0,
        0,
        o,
        0,
        0,
        c,
        0,
        o,
        0,
        0,
        0,
        1,
        0,
      ]);
    }

    // Apply saturation
    if (content.saturation != 1.0) {
      double s = content.saturation;
      double sr = (1 - s) * 0.3086;
      double sg = (1 - s) * 0.6094;
      double sb = (1 - s) * 0.0820;
      matrix = _multiplyMatrices(matrix, [
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
      ]);
    }

    // Apply special filters
    if (content.grayscale) {
      matrix = _multiplyMatrices(matrix, [
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
      ]);
    }

    if (content.sepia) {
      matrix = _multiplyMatrices(matrix, [
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
      ]);
    }

    return matrix;
  }

  List<double> _multiplyMatrices(List<double> a, List<double> b) {
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
            decoration: BoxDecoration(gradient: content.gradientOverlay),
          ),
        ),
      );
    }

    // Apply color overlay
    if (content.overlayColor != null) {
      children.add(
        Positioned.fill(child: Container(color: content.overlayColor)),
      );
    }

    // Apply vignette effect
    if (content.vignette > 0.0) {
      children.add(
        Positioned.fill(
          child: Container(
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

    return children.length == 1 ? widget : Stack(children: children);
  }
}

// Enums and helper classes
enum ImageFilter { grayscale, sepia, vintage, emboss }

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

// Custom clippers for different shapes
class StarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final double w = size.width;
    final double h = size.height;

    path.moveTo(w * 0.5, 0);
    path.lineTo(w * 0.618, h * 0.382);
    path.lineTo(w, h * 0.382);
    path.lineTo(w * 0.691, h * 0.618);
    path.lineTo(w * 0.809, h);
    path.lineTo(w * 0.5, h * 0.764);
    path.lineTo(w * 0.191, h);
    path.lineTo(w * 0.309, h * 0.618);
    path.lineTo(0, h * 0.382);
    path.lineTo(w * 0.382, h * 0.382);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class HeartClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final double w = size.width;
    final double h = size.height;

    path.moveTo(w * 0.5, h * 0.25);
    path.cubicTo(w * 0.2, 0, 0, h * 0.2, w * 0.25, h * 0.5);
    path.lineTo(w * 0.5, h * 0.75);
    path.lineTo(w * 0.75, h * 0.5);
    path.cubicTo(w, h * 0.2, w * 0.8, 0, w * 0.5, h * 0.25);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final double w = size.width;
    final double h = size.height;

    path.moveTo(w * 0.25, 0);
    path.lineTo(w * 0.75, 0);
    path.lineTo(w, h * 0.5);
    path.lineTo(w * 0.75, h);
    path.lineTo(w * 0.25, h);
    path.lineTo(0, h * 0.5);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
