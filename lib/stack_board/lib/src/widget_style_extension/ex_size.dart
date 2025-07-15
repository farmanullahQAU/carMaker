import 'dart:ui';

import 'package:cardmaker/stack_board/lib/helpers.dart';

extension ExSize on Size {
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'width': width, 'height': height};
  }
}

Size jsonToSize(Map<String, dynamic>? data) {
  if (data == null) return Size.zero;
  return Size(
    asT<double>(data['width'], 0.0),
    asT<double>(data['height'], 0.0),
  );
}

// Offset? jsonToOffset(Map<String, dynamic>? data) {
//   if (data == null) return null;
//   return Offset(asT<double>(data['dx'], 0.0), asT<double>(data['dy'], 0.0));
// }
