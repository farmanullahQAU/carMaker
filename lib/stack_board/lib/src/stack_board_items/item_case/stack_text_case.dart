import 'dart:async';
import 'dart:ui' as ui;

import 'package:cardmaker/stack_board/lib/stack_items.dart';
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

  /// * 构建文本
  /// * Text
  Widget _buildNormal(BuildContext context) {
    final textStyle = content?.style?.copyWith(
      fontFamily: GoogleFonts.getFont(content?.googleFont ?? "").fontFamily,
      height: content?.style?.height,
    );

    final textWidget = Text(
      content?.data ?? "",

      style: textStyle,
      strutStyle: content?.strutStyle?.style,
      textAlign: content?.textAlign ?? TextAlign.center,
      textDirection: content?.textDirection,
      locale: content?.locale,
      softWrap: true,
      overflow: TextOverflow.visible,
      textScaler: content?.textScaleFactor != null
          ? TextScaler.linear(content!.textScaleFactor!)
          : TextScaler.noScaling,
      maxLines: content?.maxLines ?? 5,
      semanticsLabel: content?.semanticsLabel,
      textWidthBasis: content?.textWidthBasis,
      textHeightBehavior: content?.textHeightBehavior,
      selectionColor: content?.selectionColor,
    );

    Widget wrappedWidget;

    if (content?.maskImage != null) {
      wrappedWidget = FutureBuilder<ui.Image>(
        future: _loadImage(content!.maskImage!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return textWidget; // Fallback to text during loading
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return textWidget; // Fallback to text without mask
          }

          return ClipRect(
            child: ShaderMask(
              shaderCallback: (rect) {
                return ImageShader(
                  snapshot.data!,
                  TileMode.clamp,
                  TileMode.clamp,
                  Matrix4.identity().storage,
                );
              },
              blendMode: BlendMode.srcATop,
              child: Text(
                content!.data!,
                style: textStyle?.copyWith(color: Colors.black),
                strutStyle: content!.strutStyle?.style,
                textAlign: content!.textAlign ?? TextAlign.center,
                textDirection: content!.textDirection,
                locale: content!.locale,
                softWrap: true,
                overflow: TextOverflow.visible,
                textScaler: content!.textScaleFactor != null
                    ? TextScaler.linear(content!.textScaleFactor!)
                    : TextScaler.noScaling,
                maxLines: content!.maxLines ?? 5,
                semanticsLabel: content!.semanticsLabel,
                textWidthBasis: content!.textWidthBasis,
                textHeightBehavior: content!.textHeightBehavior,
                selectionColor: content!.selectionColor,
              ),
            ),
          );
        },
      );
    } else if (content?.maskColor != null) {
      wrappedWidget = ClipRect(
        child: ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              colors: [content!.maskColor!, content!.maskColor!],
            ).createShader(rect);
          },
          blendMode: BlendMode.srcIn,
          child: Text(
            content!.data!,
            style: textStyle,
            strutStyle: content!.strutStyle?.style,
            textAlign: content!.textAlign ?? TextAlign.center,
            textDirection: content!.textDirection,
            locale: content!.locale,
            softWrap: true,
            overflow: TextOverflow.visible,
            textScaler: content!.textScaleFactor != null
                ? TextScaler.linear(content!.textScaleFactor!)
                : TextScaler.noScaling,
            maxLines: content!.maxLines ?? 5,
            semanticsLabel: content!.semanticsLabel,
            textWidthBasis: content!.textWidthBasis,
            textHeightBehavior: content!.textHeightBehavior,
            selectionColor: content!.selectionColor,
          ),
        ),
      );
    } else {
      wrappedWidget = textWidget;
    }

    // Dynamically wrap with FittedBox if useFittedBox is true
    return isFitted == true ? FittedBox(child: wrappedWidget) : wrappedWidget;
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

  Future<ui.Image> _loadImage(String assetPath) async {
    final imageProvider = AssetImage(assetPath);
    final completer = Completer<ui.Image>();
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
