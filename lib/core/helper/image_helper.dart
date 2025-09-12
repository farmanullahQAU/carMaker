import 'package:cardmaker/widgets/common/stack_board/lib/src/stack_board_items/items/shack_shape_item.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/stack_board_item.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/stack_items.dart';

// Update your deserializeItem method in EditorPage
StackItem deserializeItem(Map<String, dynamic> itemJson) {
  final type = itemJson['type'];
  if (type == 'StackTextItem') {
    return StackTextItem.fromJson(itemJson);
  } else if (type == 'StackImageItem') {
    return StackImageItem.fromJson(itemJson);
  } else if (type == 'StackShapeItem') {
    return StackShapeItem.fromJson(itemJson);
  } else {
    throw Exception('Unsupported item type: $type');
  }
}
