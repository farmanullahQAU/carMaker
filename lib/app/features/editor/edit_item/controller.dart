// Add this new route/page in your app
import 'package:cardmaker/app/features/editor/controller.dart';
import 'package:cardmaker/app/features/home/home.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/stack_board_item.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/stack_items.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TextUpdateController extends GetxController {
  final StackTextItem? existingItem;

  late TextEditingController textController;
  RxBool isSaving = false.obs;
  RxInt characterCount = 0.obs;

  TextUpdateController({this.existingItem});

  @override
  void onInit() {
    print("xxxxxxxxxxxxxxxxxxxxxxxxx");
    super.onInit();
    textController = TextEditingController(
      text: existingItem?.content?.data ?? '',
    );
    textController.addListener(() {
      characterCount.value = textController.text.length;
    });
  }

  Future<void> saveChanges() async {
    final canvasController = Get.find<CanvasController>();
    isSaving.value = true;

    // Get the current text from the controller
    final currentText = textController.text;
    if (currentText.trim().isEmpty) {
      isSaving.value = false;
      Get.back();
      return; // Do not save empty text
    }

    // Preserve all existing properties if this is an update
    if (existingItem != null) {
      final updatedItem = existingItem!.copyWith(
        content: existingItem!.content!.copyWith(
          data: currentText, // Keep the edited text
          // Preserve all other content properties
          style: existingItem!.content!.style,
          googleFont: existingItem!.content!.googleFont,
          textAlign: existingItem!.content!.textAlign,
        ),
        size: getTextWidth(
          text: currentText,
          style:
              existingItem!.content!.style ??
              const TextStyle(fontSize: 24, fontFamily: "Roboto"),
        ),
      );

      canvasController.boardController.updateItem(updatedItem);
      canvasController.boardController.updateBasic(
        existingItem!.id,
        size: getTextWidth(
          text: currentText,
          style:
              existingItem!.content!.style ??
              const TextStyle(fontSize: 20, fontFamily: "Roboto"),
        ),
        status: StackItemStatus.selected,
      );
    }
    // Handle new item creation
    else {
      final newItem = StackTextItem(
        id: UniqueKey().toString(),
        content: TextItemContent(
          data: currentText,
          style: const TextStyle(fontSize: 24, fontFamily: "Roboto"),
          googleFont: "Roboto",
        ),
        size: getTextWidth(
          text: currentText,
          style: const TextStyle(fontSize: 24, fontFamily: "Roboto"),
        ),
        offset: Offset(
          canvasController.scaledCanvasWidth.value / 2 - 100,
          canvasController.scaledCanvasHeight.value / 2 - 25,
        ),
      );
      canvasController.boardController.addItem(newItem, selectIt: true);
    }

    isSaving.value = false;
    Get.back();
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}
