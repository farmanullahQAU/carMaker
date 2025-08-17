// Image Editor Controller
import 'dart:io';

import 'package:cardmaker/app/features/editor/controller.dart';
import 'package:cardmaker/stack_board/lib/stack_items.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ImgEditController extends GetxController {
  final EditorController editorController;
  final StackImageItem? existingItem;

  RxString imagePath = ''.obs;
  RxBool isSaving = false.obs;
  RxBool isLoading = false.obs;

  ImgEditController(this.editorController, {this.existingItem});

  @override
  void onInit() {
    super.onInit();
    if (existingItem != null) {
      imagePath.value = existingItem!.content?.assetName ?? '';
    }
  }

  Future<void> pickImage() async {
    isLoading.value = true;
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      imagePath.value = image.path;
    }
    isLoading.value = false;
  }

  Future<void> saveChanges() async {
    if (imagePath.isEmpty) return;

    isSaving.value = true;

    final content = ImageItemContent(assetName: imagePath.value);

    final imageItem = existingItem != null
        ? existingItem!.copyWith(content: content)
        : StackImageItem(
            id: UniqueKey().toString(),
            content: content,
            size: const Size(200, 200),
            offset: Offset(
              editorController.scaledCanvasWidth.value / 2 - 100,
              editorController.scaledCanvasHeight.value / 2 - 100,
            ),
          );

    if (existingItem != null) {
      editorController.boardController.updateItem(imageItem);
    } else {
      editorController.boardController.addItem(imageItem);
      // editorController._undoStack.add(_ItemState(item: imageItem, action: _ItemAction.add));
    }

    isSaving.value = false;
    Get.back();
  }
}

// Image Editor Page
class ImageEditorPage extends StatelessWidget {
  final StackImageItem? item;

  const ImageEditorPage({super.key, this.item});

  @override
  Widget build(BuildContext context) {
    final editorController = Get.find<EditorController>();
    final controller = Get.put(
      ImgEditController(editorController, existingItem: item),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(item != null ? 'Edit Image' : 'Add Image'),
        actions: [
          Obx(
            () => controller.isSaving.value
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: controller.saveChanges,
                    tooltip: 'Save',
                  ),
          ),
        ],
      ),
      body: Center(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const CircularProgressIndicator();
          }

          if (controller.imagePath.isNotEmpty) {
            return InteractiveViewer(
              child: Image.file(
                File(controller.imagePath.value),
                fit: BoxFit.contain,
              ),
            );
          } else {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.image, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.pickImage,
                  child: const Text('Select Image'),
                ),
              ],
            );
          }
        }),
      ),
    );
  }
}
