// Add this new route/page in your app
import 'package:cardmaker/app/features/editor/controller.dart';
import 'package:cardmaker/core/utils/language_detector.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/stack_board_item.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/stack_items.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TextUpdateController extends GetxController {
  final StackTextItem? existingItem;

  late TextEditingController textController;
  RxBool isSaving = false.obs;
  RxInt characterCount = 0.obs;
  Rx<LanguageType> selectedLanguage = LanguageType.auto.obs;
  Rx<TextDirection> textDirection = TextDirection.ltr.obs;
  RxBool isUrduFont = false.obs;
  RxString selectedFont = 'Roboto'.obs;

  TextUpdateController({this.existingItem});

  @override
  void onInit() {
    super.onInit();
    final initialText = existingItem?.content?.data ?? '';
    textController = TextEditingController(text: initialText);

    // Initialize language and direction from existing item or detect from text
    if (existingItem != null) {
      final content = existingItem!.content!;
      isUrduFont.value = content.isArabicFont;
      selectedFont.value = content.googleFont ?? 'Roboto';
      textDirection.value =
          content.textDirection ??
          (content.isArabicFont ? TextDirection.rtl : TextDirection.ltr);

      // Determine language mode
      if (content.isArabicFont ||
          (content.textDirection == TextDirection.rtl)) {
        selectedLanguage.value = LanguageType.urdu;
      } else if (LanguageDetector.isUrduOrArabic(initialText)) {
        selectedLanguage.value = LanguageType.auto;
      } else {
        selectedLanguage.value = LanguageType.english;
      }
    } else {
      // For new items, detect from initial text
      detectAndUpdateLanguage(initialText);
    }

    textController.addListener(() {
      characterCount.value = textController.text.length;
      if (selectedLanguage.value == LanguageType.auto) {
        detectAndUpdateLanguage(textController.text);
      }
    });
  }

  void detectAndUpdateLanguage(String text) {
    if (selectedLanguage.value == LanguageType.auto) {
      final detected = LanguageDetector.detectLanguage(text);
      final detectedDirection = LanguageDetector.detectTextDirection(text);
      textDirection.value = detectedDirection;
      final isUrdu = detected == LanguageType.urdu;
      isUrduFont.value = isUrdu;

      // If Urdu detected, set a default Urdu font if not already set
      if (isUrdu && selectedFont.value == 'Roboto') {
        selectedFont.value = 'AadilAadil'; // Default Urdu font
      }
    }
  }

  void updateTextDirection() {
    switch (selectedLanguage.value) {
      case LanguageType.english:
        textDirection.value = TextDirection.ltr;
        isUrduFont.value = false;
        break;
      case LanguageType.urdu:
        textDirection.value = TextDirection.rtl;
        isUrduFont.value = true;
        if (selectedFont.value == 'Roboto' || !isUrduFont.value) {
          selectedFont.value = 'AadilAadil'; // Default Urdu font
        }
        break;
      case LanguageType.auto:
        detectAndUpdateLanguage(textController.text);
        break;
    }
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

    // Ensure language detection is up to date
    if (selectedLanguage.value == LanguageType.auto) {
      detectAndUpdateLanguage(currentText);
    }

    // Determine final text direction and font settings
    final finalDirection = textDirection.value;
    final finalIsUrdu = isUrduFont.value;
    final finalFont = selectedFont.value;

    // Preserve all existing properties if this is an update
    if (existingItem != null) {
      final existingContent = existingItem!.content!;
      final existingStyle =
          existingContent.style ??
          const TextStyle(fontSize: 24, fontFamily: "Roboto");

      // Update style with proper font family
      final updatedStyle = existingStyle.copyWith(
        fontFamily: finalIsUrdu ? finalFont : existingStyle.fontFamily,
      );

      // Calculate text size with width constraint to get correct height when text wraps
      final maxWidth = canvasController.scaledCanvasWidth.value * 0.9;
      final textPainter = TextPainter(
        text: TextSpan(text: currentText, style: updatedStyle),
        textDirection: finalDirection,
        maxLines: null,
      );
      textPainter.layout(maxWidth: maxWidth);
      final clampedSize = Size(
        textPainter.width.clamp(0.0, maxWidth),
        textPainter.height,
      );

      final updatedItem = existingItem!.copyWith(
        content: existingContent.copyWith(
          data: currentText,
          style: updatedStyle,
          googleFont: finalFont,
          textDirection: finalDirection,
          isArabicFont: finalIsUrdu,
          textAlign:
              existingContent.textAlign ??
              (finalDirection == TextDirection.rtl
                  ? TextAlign.right
                  : TextAlign.left),
        ),
        size: clampedSize,
      );

      canvasController.boardController.updateItem(updatedItem);
      canvasController.boardController.updateBasic(
        existingItem!.id,
        size: clampedSize,
        status: StackItemStatus.selected,
      );

      // Update active item to reflect changes
      if (canvasController.activeItem.value?.id == existingItem!.id) {
        canvasController.activeItem.value = updatedItem;
        canvasController.activeItem.refresh();
      }
    }
    // Handle new item creation
    else {
      final defaultStyle = TextStyle(
        fontSize: 24,
        fontFamily: finalIsUrdu ? finalFont : null,
        color: Colors.black,
      );

      // Calculate text size with width constraint to get correct height when text wraps
      final maxWidth = canvasController.scaledCanvasWidth.value * 0.9;
      final textPainter = TextPainter(
        text: TextSpan(text: currentText, style: defaultStyle),
        textDirection: finalDirection,
        maxLines: null,
      );
      textPainter.layout(maxWidth: maxWidth);
      final clampedSize = Size(
        textPainter.width.clamp(0.0, maxWidth),
        textPainter.height,
      );

      final newItem = StackTextItem(
        id: UniqueKey().toString(),
        content: TextItemContent(
          data: currentText,
          style: defaultStyle,
          googleFont: finalFont,
          textDirection: finalDirection,
          isArabicFont: finalIsUrdu,
          textAlign: finalDirection == TextDirection.rtl
              ? TextAlign.right
              : TextAlign.left,
        ),
        size: clampedSize,
        offset: Offset(
          canvasController.scaledCanvasWidth.value / 2 - 100,
          canvasController.scaledCanvasHeight.value / 2 - 25,
        ),
      );
      canvasController.boardController.addItem(newItem, selectIt: true);
      canvasController.activeItem.value = newItem;
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
