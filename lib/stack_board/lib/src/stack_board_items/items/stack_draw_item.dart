// import 'dart:ui';

// import 'package:cardmaker/stack_board/lib/stack_board_item.dart';

// import '../../../helpers.dart';

// class DrawItemContent implements StackItemContent {
//   DrawItemContent({
//     required this.size,
//     required this.paintContents,
//   });

//   factory DrawItemContent.fromJson(
//     Map<String, dynamic> data, {
//     PaintContent Function(String type, Map<String, dynamic> jsonStepMap)?
//         contentFactory,
//   }) {
//     return DrawItemContent(
//       size: data['size'] as double,
//       paintContents: (data['paintContents'] as List<dynamic>).map((dynamic e) {
//         final String type = e['type'] as String;

//         final Map<String, dynamic> contentJson = e as Map<String, dynamic>;

//         switch (type) {
//           case 'Circle':
//             return Circle.fromJson(contentJson);
//           case 'Eraser':
//             return Eraser.fromJson(contentJson);
//           case 'Rectangle':
//             return Rectangle.fromJson(contentJson);
//           case 'SimpleLine':
//             return SimpleLine.fromJson(contentJson);
//           case 'SmoothLine':
//             return SmoothLine.fromJson(contentJson);
//           case 'StraightLine':
//             return StraightLine.fromJson(contentJson);
//         }

//         return contentFactory?.call(type, contentJson) ??
//             EmptyContent.fromJson(contentJson);
//       }).toList(),
//     );
//   }

//   double size;
//   List<PaintContent> paintContents;

//   @override
//   Map<String, dynamic> toJson() {
//     return <String, dynamic>{
//       'size': size,
//       'paintContents':
//           paintContents.map((PaintContent e) => e.toJson()).toList(),
//     };
//   }
// }

// /// StackDrawItem
// class StackDrawItem extends StackItem<DrawItemContent> {
//   StackDrawItem({
//     DrawItemContent? content,
//     String? id,
//     double? angle,
//     Size size = const Size(300, 300),
//     Offset? offset,
//     bool? lockZOrder,
//     StackItemStatus? status,
//   }) : super(
//             id: id,
//             size: size,
//             offset: offset,
//             angle: angle,
//             status: status,
//             lockZOrder: lockZOrder,
//             content: content ??
//                 DrawItemContent(
//                     size: size.shortestSide, paintContents: <PaintContent>[]));

//   factory StackDrawItem.fromJson(Map<String, dynamic> data) {
//     return StackDrawItem(
//       id: data['id'] as String?,
//       angle: data['angle'] as double?,
//       size: jsonToSize(data['size'] as Map<String, dynamic>),
//       offset: jsonToOffset(data['offset'] as Map<String, dynamic>),
//       status: StackItemStatus.values[data['status'] as int],
//       lockZOrder: asNullT<bool>(data['lockZOrder']) ?? false,
//       content:
//           DrawItemContent.fromJson(data['content'] as Map<String, dynamic>),
//     );
//   }

//   /// * 覆盖绘制内容
//   /// * Override the drawing content
//   void setContents(List<PaintContent> contents) {
//     content!.paintContents = contents;
//   }

//   @override
//   StackDrawItem copyWith({
//     Size? size,
//     Offset? offset,
//     double? angle,
//     StackItemStatus? status,
//     bool? lockZOrder,
//     DrawItemContent? content,
//   }) {
//     return StackDrawItem(
//       id: id,
//       size: size ?? this.size,
//       offset: offset ?? this.offset,
//       angle: angle ?? this.angle,
//       status: status ?? this.status,
//       lockZOrder: lockZOrder ?? this.lockZOrder,
//       content: content ?? this.content,
//     );
//   }
// }
