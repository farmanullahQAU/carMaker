// Add this new route/page in your app
import 'package:cardmaker/app/features/editor/controller.dart';
import 'package:cardmaker/app/features/home/home.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/stack_board_item.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/stack_items.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdateTextView extends StatelessWidget {
  final StackTextItem? item;

  const UpdateTextView({super.key, this.item});

  @override
  Widget build(BuildContext context) {
    final editorController = Get.find<CanvasController>();
    final controller = Get.put(TextEditorController(existingItem: item));

    return Scaffold(
      appBar: AppBar(
        title: Text(item != null ? 'Edit Text' : 'Add Text'),
        centerTitle: true,
        actions: [
          Obx(
            () => controller.isSaving.value
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : TextButton(
                    onPressed: controller.saveChanges,
                    child: Text(
                      'SAVE',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Preview card

            // Text input field
            Expanded(
              child: TextField(
                controller: controller.textController,
                maxLines: null,
                expands: true,
                textInputAction: TextInputAction
                    .newline, // Shows "return" button on keyboard

                keyboardType: TextInputType.multiline,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Type your text here...',
                  hintStyle: TextStyle(color: Theme.of(context).hintColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  // contentPadding: const EdgeInsets.all(16),
                ),
                autofocus: true,
              ),
            ),

            // Character count
            // Expanded(
            //   child: Padding(
            //     padding: const EdgeInsets.only(top: 8.0),
            //     child: Obx(
            //       () => Text(
            //         '${controller.characterCount.value} characters',
            //         style: Theme.of(context).textTheme.bodySmall?.copyWith(
            //           color: Theme.of(context).hintColor,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            SizedBox(height: 16),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // cancel button
                    Flexible(
                      fit: FlexFit.tight,
                      child: SizedBox(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          child: Text('Cancel'),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),

                    Flexible(
                      fit: FlexFit.tight,

                      child: SizedBox(
                        child: FilledButton(
                          onPressed: controller.saveChanges,
                          child: Text('Save'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TextEditorController extends GetxController {
  final StackTextItem? existingItem;

  late TextEditingController textController;
  RxBool isSaving = false.obs;
  RxInt characterCount = 0.obs;

  TextEditorController({this.existingItem});

  @override
  void onInit() {
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
