import 'package:flutter/material.dart';

import '../../../stack_items.dart';

class StackImageCase extends StatelessWidget {
  const StackImageCase({super.key, required this.item});

  final StackImageItem item;

  ImageItemContent get content => item.content!;

  @override
  Widget build(BuildContext context) {
    // return item.status == StackItemStatus.editing
    //     ? Center(
    //         child: TextFormField(
    //           initialValue: item.content?.url,
    //           onChanged: (String url) {
    //             item.setUrl(url);
    //           },
    //         ),
    //       )
    //

    return Image(
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
  }
}
