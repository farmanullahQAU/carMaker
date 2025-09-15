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
      resizeToAvoidBottomInset: true, // ✅ avoids stretching with keyboard
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
                : IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: controller.saveChanges,
                    tooltip: 'Save',
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 📝 Text editor area
              TextField(
                controller: controller.textController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textAlign: TextAlign.start,

                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.5,
                ),
                decoration: InputDecoration(
                  hintMaxLines: 8,
                  hintText: 'Type your text here...',
                  filled: true,
                  fillColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                autofocus: true,
              ),

              const SizedBox(height: 16),

              // 🔘 Buttons directly under TextField
              Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: controller.isSaving.value
                            ? null
                            : () => Get.back(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: controller.isSaving.value
                            ? null
                            : controller.saveChanges,
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
