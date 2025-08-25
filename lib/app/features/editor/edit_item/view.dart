// Add this new route/page in your app
import 'package:cardmaker/app/features/editor/edit_item/controller.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/stack_items.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdateTextView extends GetView<TextUpdateController> {
  final StackTextItem? item;

  const UpdateTextView({super.key, this.item});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TextUpdateController(existingItem: item));

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
