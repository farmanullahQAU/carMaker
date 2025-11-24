import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cardmaker/app/features/editor/text_editor/view.dart';
import 'package:cardmaker/core/values/enums.dart' show DualToneDirection;
import 'package:cardmaker/widgets/common/stack_board/lib/stack_items.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class StackTextCase extends StatelessWidget {
  const StackTextCase({
    super.key,
    required this.item,
    this.decoration,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.textAlignVertical,
    this.controller,
    this.maxLength,
    this.onChanged,
    this.onEditingComplete,
    this.onTap,
    this.readOnly = false,
    this.autofocus = true,
    this.obscureText = false,
    this.maxLines,
    this.inputFormatters,
    this.focusNode,
    this.enabled = true,
    this.isFitted = true,
  });

  final StackTextItem item;
  final InputDecoration? decoration;
  final TextEditingController? controller;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final TextAlignVertical? textAlignVertical;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final Function()? onEditingComplete;
  final Function()? onTap;
  final bool readOnly;
  final bool autofocus;
  final bool obscureText;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final bool enabled;
  final TextCapitalization textCapitalization;

  TextItemContent? get content => item.content;
  final bool isFitted;

  @override
  Widget build(BuildContext context) {
    return _buildNormal(context);
  }

  Widget _buildNormal(BuildContext context) {
    final textStyle = content?.style?.copyWith(
      fontFamily: content?.isArabicFont == true
          ? content?.googleFont
          : GoogleFonts.getFont(content?.googleFont ?? 'Roboto').fontFamily,
      // fontFamily: GoogleFonts.getFont(content?.googleFont ?? "").fontFamily,
      height: content?.style?.height,
      color: content?.style?.color ?? Colors.black,
    );

    Widget textWidget;

    if (content?.hasDualTone == true) {
      textWidget = ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 10,
          minHeight: 10,
          maxWidth: 800,
          maxHeight: 600,
        ),
        child: DualToneText(
          text: content?.data ?? "",
          color1: content?.dualToneColor1 ?? Colors.red,
          color2: content?.dualToneColor2 ?? Colors.blue,
          direction: content?.dualToneDirection ?? DualToneDirection.horizontal,
          position: content?.dualTonePosition ?? 0.5,
          textStyle: textStyle,
          textAlign: content?.textAlign ?? TextAlign.center,
          textDirection: content?.textDirection,
          textScaler: content?.textScaleFactor != null
              ? TextScaler.linear(content!.textScaleFactor!)
              : TextScaler.noScaling,
          maxLines: content?.maxLines ?? 5,
          overflow: TextOverflow.clip,
        ),
      );
    } else if (content?.hasStroke == true) {
      // Use StrokeText for stroke effect
      textWidget = ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 10,
          minHeight: 10,
          maxWidth: 800,
          maxHeight: 600,
        ),
        child: StrokeText(
          text: content?.data ?? "",

          strokeColor: content?.strokeColor ?? Colors.black,
          strokeWidth: content?.strokeWidth ?? 2.0,
          textStyle: textStyle,
          textAlign: content?.textAlign ?? TextAlign.center,
          textDirection: content?.textDirection,
          textScaler: content?.textScaleFactor != null
              ? TextScaler.linear(content!.textScaleFactor!)
              : TextScaler.noScaling,
          maxLines: content?.maxLines,
          overflow: TextOverflow.clip,
        ),
      );
    } else {
      // Use regular Text widget
      textWidget = Text(
        content?.data ?? "",
        style: textStyle,
        strutStyle: content?.strutStyle?.style,
        textAlign: content?.textAlign ?? TextAlign.center,
        textDirection: content?.textDirection,
        locale: content?.locale,

        softWrap: true,
        overflow: TextOverflow.clip,
        textScaler: content?.textScaleFactor != null
            ? TextScaler.linear(content!.textScaleFactor!)
            : TextScaler.noScaling,
        maxLines: content?.maxLines,
        semanticsLabel: content?.semanticsLabel,
        textWidthBasis: content?.textWidthBasis,
        textHeightBehavior: content?.textHeightBehavior,
        selectionColor: content?.selectionColor,
      );
    }

    Widget wrappedWidget;

    if (content?.hasMask == true &&
        content?.maskImage != null &&
        content?.hasDualTone != true) {
      wrappedWidget = FutureBuilder<ui.Image>(
        key: ValueKey(content?.maskImage ?? 'no_mask'),
        future: _loadImage(content!.maskImage!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return textWidget;
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return textWidget;
          }

          // Create transformation matrix with new properties
          final matrix = Matrix4.identity();

          Widget maskedWidget = ClipRect(
            child: ShaderMask(
              shaderCallback: (rect) {
                return ImageShader(
                  snapshot.data!,
                  TileMode.clamp,
                  TileMode.clamp,

                  matrix.storage,
                  filterQuality: FilterQuality.high,
                );
              },
              blendMode: content!.maskBlendMode!,
              child: Text(
                content!.data!,
                style: textStyle,
                strutStyle: content!.strutStyle?.style,
                textAlign: content!.textAlign ?? TextAlign.center,
                textDirection: content!.textDirection,
                locale: content!.locale,
                softWrap: true,
                overflow: TextOverflow.clip,
                textScaler: content!.textScaleFactor != null
                    ? TextScaler.linear(content!.textScaleFactor!)
                    : TextScaler.noScaling,
                maxLines: content?.maxLines,
                semanticsLabel: content!.semanticsLabel,
                textWidthBasis: content!.textWidthBasis,
                textHeightBehavior: content!.textHeightBehavior,
                selectionColor: content!.selectionColor,
              ),
            ),
          );

          return maskedWidget;
        },
      );
    } else {
      wrappedWidget = textWidget;
    }

    final bool shouldFit = content?.autoFit ?? isFitted;
    return shouldFit ? FittedBox(child: wrappedWidget) : wrappedWidget;
  }

  /// * 构建编辑框
  /// * TextFormField
  Widget _buildEditing(BuildContext context) {
    return Center(
      child: TextFormField(
        initialValue: content?.data,
        style: content?.style,
        strutStyle: content?.strutStyle?.style,
        textAlign: content?.textAlign ?? TextAlign.start,
        textDirection: content?.textDirection,
        maxLines: content?.maxLines,
        decoration: decoration,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        textInputAction: textInputAction,
        textAlignVertical: textAlignVertical,
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        readOnly: readOnly,
        obscureText: obscureText,
        maxLength: maxLength,
        onChanged: (String str) {
          item.setData(str);
          onChanged?.call(str);
        },
        onTap: onTap,
        onEditingComplete: onEditingComplete,
        inputFormatters: inputFormatters,
        enabled: enabled,
      ),
    );
  }

  Future<ui.Image> _loadImage(String imagePath) async {
    final completer = Completer<ui.Image>();

    // Check if it's a file path or asset path
    // Asset paths start with 'assets/', file paths are absolute paths
    final isAsset = imagePath.startsWith('assets/');

    ImageProvider imageProvider;
    if (isAsset) {
      // It's an asset path
      imageProvider = AssetImage(imagePath);
    } else {
      // It's a file path from gallery
      imageProvider = FileImage(File(imagePath));
    }

    final imageStream = imageProvider.resolve(const ImageConfiguration());
    ImageStreamListener? listener;
    listener = ImageStreamListener(
      (ImageInfo info, bool synchronousCall) {
        completer.complete(info.image);
        imageStream.removeListener(listener!);
      },
      onError: (exception, stackTrace) {
        completer.completeError(exception, stackTrace);
        imageStream.removeListener(listener!);
      },
    );
    imageStream.addListener(listener);
    return completer.future;
  }
}
