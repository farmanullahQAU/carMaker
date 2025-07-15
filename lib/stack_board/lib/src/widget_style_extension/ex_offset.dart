import 'package:cardmaker/stack_board/lib/helpers.dart';
import 'package:flutter/painting.dart';

extension ExOffset on Offset {
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'dx': dx, 'dy': dy};
  }
}

Offset? jsonToOffset(Map<String, dynamic>? data) {
  if (data == null) {
    return null;
  }
  return Offset(asT<double>(data['dx']), asT<double>(data['dy']));
}
