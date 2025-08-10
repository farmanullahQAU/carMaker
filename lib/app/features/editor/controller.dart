import 'dart:math' as math;

import 'package:cardmaker/app/features/editor/editor_canvas.dart';
import 'package:cardmaker/app/features/home/home.dart' show getTextWidth;
import 'package:cardmaker/app/features/home/home.dart';
import 'package:cardmaker/models/card_template.dart';
import 'package:cardmaker/services/storage_service.dart';
import 'package:cardmaker/stack_board/lib/flutter_stack_board.dart';
import 'package:cardmaker/stack_board/lib/stack_board_item.dart';
import 'package:cardmaker/stack_board/lib/stack_items.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditorController extends GetxController {
  final StackBoardController boardController = StackBoardController();
  final RxString selectedFont = 'Poppins'.obs;
  final RxDouble fontSize = 24.0.obs;
  final Rx<Color> fontColor = Colors.black.obs;
  final RxString selectedBackground = ''.obs;
  final RxDouble backgroundHue = 0.0.obs;
  final RxString templateName = ''.obs;

  final RxDouble templateOriginalWidth = 0.0.obs;
  final RxDouble templateOriginalHeight = 0.0.obs;
  final Rx<Size> actualStackBoardRenderSize = Size(100, 100).obs;

  final RxString category = 'general'.obs;
  final RxString categoryId = 'general'.obs;
  final RxList<String> tags = <String>[].obs;
  final RxBool isPremium = false.obs;
  CardTemplate? initialTemplate;

  final RxDouble canvasWidth = 0.0.obs;
  final RxDouble canvasHeight = 0.0.obs;
  final List<StackItem<StackItemContent>> itemsToLoad = [];

  final Rx<StackItem?> draggedItem = Rx<StackItem?>(null);
  Rx<StackItem?> activeItem = Rx<StackItem?>(null);
  final RxBool showGrid = true.obs;
  final RxDouble gridSize = 20.0.obs;
  final Rx<Color> guideColor = Colors.black.obs;
  final Rx<OverlayEntry?> activeTextEditorOverlay = Rx<OverlayEntry?>(null);

  final RxList<_ItemState> _undoStack = <_ItemState>[].obs;
  final RxList<_ItemState> _redoStack = <_ItemState>[].obs;
  Rx<Offset> midYOffset = Rx<Offset>(Offset(0, 0));
  Rx<Size> midSize = Rx<Size>(Size(0, 0));
  bool isDragging = false;
  // CHANGED: Use RxList for multiple profile images
  final RxList<StackImageItem> profileImageItems = <StackImageItem>[].obs;

  final RxBool showHueSlider = false.obs;
  final RxBool showStickerPanel = false.obs;
  final RxInt selectedToolIndex = 0.obs;
  String _selectedAdjustment = 'brightness';

  String get selectedAdjustment => _selectedAdjustment;

  void setSelectedAdjustment(String adjustment) {
    _selectedAdjustment = adjustment;
    update(); // This will trigger GetBuilder rebuild
  }

  ///
  ///
  ///    final GlobalKey stackBoardKey = GlobalKey();
  final RxBool isTemplateLoaded = false.obs;
  final RxDouble canvasScale = 1.0.obs;
  final RxDouble scaledCanvasWidth = 0.0.obs;
  final RxDouble scaledCanvasHeight = 0.0.obs;
  final GlobalKey stackBoardKey = GlobalKey();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is Map<String, dynamic>) {
      initialTemplate = Get.arguments['template'];
    } else {
      initialTemplate = Get.arguments as CardTemplate;
    }

    templateName.value = initialTemplate!.name;
    category.value = initialTemplate!.category;
    categoryId.value = initialTemplate!.categoryId;
    tags.value = initialTemplate!.tags;
    isPremium.value = initialTemplate!.isPremium;
    selectedBackground.value = initialTemplate!.backgroundImage;
    templateOriginalWidth.value = initialTemplate!.width.toDouble();
    templateOriginalHeight.value = initialTemplate!.height.toDouble();
    canvasWidth.value = initialTemplate!.width.toDouble();
    canvasHeight.value = initialTemplate!.height.toDouble();
    boardController.clear();

    // CHANGED: Collect all profile images from initialTemplate
    profileImageItems.clear();
    for (var itemJson in initialTemplate!.items) {
      if (itemJson['isProfileImage'] == true) {
        final item = _deserializeItem(itemJson);
        if (item is StackImageItem) {
          profileImageItems.add(item);
        }
      }
    }
  }

  void updateCanvasAndLoadTemplate(
    BoxConstraints constraints,
    BuildContext context,
  ) {
    if (isTemplateLoaded.value) return;

    final double availableWidth = constraints.maxWidth * 0.9;
    final double availableHeight = constraints.maxHeight;
    final double aspectRatio = initialTemplate!.width / initialTemplate!.height;

    if (availableWidth / aspectRatio <= availableHeight) {
      scaledCanvasWidth.value = availableWidth;
      scaledCanvasHeight.value = availableWidth / aspectRatio;
    } else {
      scaledCanvasHeight.value = availableHeight;
      scaledCanvasWidth.value = availableHeight * aspectRatio;
    }

    canvasScale.value = scaledCanvasWidth.value / initialTemplate!.width;

    updateStackBoardRenderSize(
      Size(scaledCanvasWidth.value, scaledCanvasHeight.value),
    );
    debugPrint(
      'Updated StackBoard size: ${scaledCanvasWidth.value} x ${scaledCanvasHeight.value}, Canvas Scale: $canvasScale',
    );

    loadExportedTemplate(
      initialTemplate!,
      context,
      scaledCanvasWidth.value,
      scaledCanvasHeight.value,
    );

    isTemplateLoaded.value = true;
    update(['canvas_stack']); // Trigger rebuild of canvas stack
  }

  void loadExportedTemplate(
    CardTemplate template,
    BuildContext context,
    double scaledCanvasWidth,
    double scaledCanvasHeight,
  ) async {
    print("this one .........................");
    final controller = Get.find<EditorController>();
    controller.selectedBackground.value = template.backgroundImage;
    controller.templateName.value = template.name;
    controller.category.value = template.category;
    controller.categoryId.value = template.categoryId;
    controller.tags.value = template.tags;
    controller.isPremium.value = template.isPremium;
    controller.backgroundHue.value = 0.0;
    controller.templateOriginalWidth.value = template.width.toDouble();
    controller.templateOriginalHeight.value = template.height.toDouble();
    controller.canvasWidth.value = scaledCanvasWidth;
    controller.canvasHeight.value = scaledCanvasHeight;
    controller.boardController.clear();
    controller.profileImageItems.clear();

    for (final itemJson in template.items) {
      try {
        final bool isCentered = itemJson['isCentered'] ?? false;
        final bool isProfileImage = itemJson['isProfileImage'] ?? false;

        final item = _deserializeItem(itemJson);
        if (isProfileImage) {
          if (item is StackImageItem) {
            controller.profileImageItems.add(item);
          }
          continue;
        }

        Size itemSize;
        StackItem updatedItem;

        if (item is StackTextItem) {
          double scaledX = item.offset.dx;
          double scaledY = item.offset.dy;

          final updatedStyle = item.content!.style!.copyWith(
            fontSize: item.content!.style!.fontSize!,
          );

          itemSize = Size(
            itemJson['size']['width'],
            itemJson['size']['height'],
          );

          updatedItem = item.copyWith(
            offset: Offset(scaledX, scaledY),
            size: itemSize,
            status: StackItemStatus.idle,
            content: item.content!.copyWith(style: updatedStyle),
            isCentered: isCentered,
          );
        } else if (item is StackImageItem) {
          double scaledX = item.offset.dx;
          double scaledY = item.offset.dy;
          final double originalWidth = itemJson['size']['width'];
          final double originalHeight = itemJson['size']['height'];

          itemSize = Size(originalWidth, originalHeight);

          updatedItem = item.copyWith(
            offset: Offset(scaledX, scaledY),
            size: itemSize,
            status: StackItemStatus.idle,
          );
        } else {
          throw Exception('Unsupported item type: ${item.runtimeType}');
        }

        debugPrint(
          'Loaded item: ${item.id}, isCentered: $isCentered, size: $itemSize, offset: ${updatedItem.offset}',
        );

        controller.boardController.addItem(updatedItem);
        controller._undoStack.add(
          _ItemState(item: updatedItem, action: _ItemAction.add),
        );
      } catch (err) {}
    }
    update([
      'canvas_stack',
      'bottom_sheet',
    ]); // Trigger rebuild of canvas and bottom sheet
  }

  void addProfileImage(String assetPath, {Offset? offset, Size? size}) {
    final profileImage = StackImageItem(
      id: 'profile_image_${DateTime.now().millisecondsSinceEpoch}',
      offset: offset ?? const Offset(690.0, 115.0),
      size: size ?? const Size(436.0, 574.0),
      content: ImageItemContent(assetName: assetPath),
      isProfileImage: true,
      lockZOrder: true,
      status: StackItemStatus.idle,
    );
    profileImageItems.add(profileImage);
    update(['canvas_stack']); // Trigger rebuild of canvas stack
  }

  void addSticker(String imagePath) {
    final sticker = StackImageItem(
      id: UniqueKey().toString(),
      size: const Size(100, 100),
      offset: getCenteredOffset(const Size(100, 100)),
      content: ImageItemContent(assetName: imagePath),
      isProfileImage: false,
    );
    boardController.addItem(sticker);
    _undoStack.add(_ItemState(item: sticker, action: _ItemAction.add));
    _redoStack.clear();
    update(['canvas_stack']); // Trigger rebuild of canvas stack
  }

  void addText(String data) {
    Offset offset;
    Size size;
    if (activeItem.value != null && activeItem.value is StackTextItem) {
      offset = Offset(
        activeItem.value!.offset.dx + 20,
        activeItem.value!.offset.dy + 40,
      );
      size = activeItem.value!.size;
    } else {
      offset = Offset(100, 100);
      size = const Size(200, 50);
    }

    final content = TextItemContent(
      data: data,
      googleFont: 'Roboto',
      style: const TextStyle(fontSize: 24, color: Colors.black),
      textAlign: TextAlign.center,
    );
    final textItem = StackTextItem(
      id: UniqueKey().toString(),
      size: getTextWidth(text: data, style: content.style!),
      offset: offset,
      content: content,
    );
    boardController.addItem(textItem);
    _undoStack.add(_ItemState(item: textItem, action: _ItemAction.add));
    _redoStack.clear();
    activeItem.value = textItem;
    update([
      'canvas_stack',
      'bottom_sheet',
    ]); // Trigger rebuild of canvas and bottom sheet
  }

  void updateBackgroundHue(double hue) {
    final previousHue = backgroundHue.value;
    _undoStack.add(
      _ItemState(
        item: ColorStackItem1(
          id: 'background_hue',
          size: Size.zero,
          content: ColorContent(color: Colors.transparent),
        ),
        action: _ItemAction.hue,
        previousHue: previousHue,
      ),
    );
    _redoStack.clear();
    backgroundHue.value = hue;
    update(['canvas_stack']); // Trigger rebuild of canvas stack
  }

  void toggleGrid() {
    showGrid.value = !showGrid.value;
    update(['canvas_stack']); // Trigger rebuild of canvas stack
  }

  void onItemStatusChanged(StackItem item, StackItemStatus status) {
    if (status == StackItemStatus.moving) {
      draggedItem.value = item;
      activeItem.value = null;
    } else if (status == StackItemStatus.selected) {
      draggedItem.value = null;
    } else if (status == StackItemStatus.idle) {
      if (draggedItem.value?.id == item.id) {
        draggedItem.value = null;
      }
      if (activeItem.value?.id == item.id) {
        activeItem.value = null;
      }
    }
    update([
      'canvas_stack',
      'bottom_sheet',
    ]); // Trigger rebuild of canvas and bottom sheet
  }

  void updateTextItem(
    StackTextItem item,
    StackItemContent content, {
    Size? newSize,
  }) {
    final currentItemJson = boardController.getAllData().firstWhere(
      (json) => json['id'] == item.id,
      orElse: () => <String, dynamic>{},
    );
    if (currentItemJson.isNotEmpty) {
      final previousItem = _deserializeItem(currentItemJson);
      _undoStack.add(
        _ItemState(item: previousItem, action: _ItemAction.update),
      );
      _redoStack.clear();
      final updatedItem = item.copyWith(
        content: content as TextItemContent,
        size: newSize ?? item.size,
      );
      boardController.updateItem(updatedItem);
      activeItem.value = updatedItem;
      update([
        'canvas_stack',
        'bottom_sheet',
      ]); // Trigger rebuild of canvas and bottom sheet
    }
  }
  /////////////////////////////

  void updateStackBoardRenderSize(Size size) {
    if (actualStackBoardRenderSize.value != size) {
      actualStackBoardRenderSize.value = size;
      _updateGridSize();
    }
  }

  Future<void> exportDesign() async {
    final double originalWidth = initialTemplate!.width.toDouble();
    final double originalHeight = initialTemplate!.height.toDouble();

    final List<Map<String, dynamic>> exportedItems = [];
    final currentItems = boardController.getAllData();

    debugPrint('Current Items: $currentItems', wrapWidth: 1000);

    // CHANGED: Include all profile images from profileImageItems

    if (profileImageItems.isNotEmpty) {
      for (final profileItem in profileImageItems) {
        exportedItems.add(profileItem.toJson());
      }
    } else {}

    for (final itemJson in currentItems) {
      final type = itemJson['type'];
      final Map<String, dynamic> exportedItem = {
        'type': type,
        'id': itemJson['id'],
        'status': itemJson['status'] ?? 0,
        'isCentered': itemJson['isCentered'] ?? false,
        'size': {
          'width': itemJson['size']['width'],
          'height': itemJson['size']['height'],
        },
        'offset': {
          'dx': itemJson['offset']['dx'],
          'dy': itemJson['offset']['dy'],
        },
        'isProfileImage': false,
      };

      if (type == 'StackTextItem') {
        exportedItem['content'] = itemJson['content'];
      } else if (type == 'StackImageItem') {
        exportedItem['content'] = {
          'assetName': itemJson['content']['assetName'],
        };
      } else if (type == 'RowStackItem') {
        exportedItem['content'] = {
          'items': (itemJson['content']['items'] as List).map((subItemJson) {
            final subItemType = subItemJson['type'];
            final Map<String, dynamic> subItem = {
              'type': subItemType,
              'id': subItemJson['id'],
              'status': subItemJson['status'] ?? 0,
              'size': {
                'width': subItemJson['size']['width'],
                'height': subItemJson['size']['height'],
              },
              'offset': {
                'dx': subItemJson['offset']['dx'],
                'dy': subItemJson['offset']['dy'],
              },
              'isCentered': subItemJson['isCentered'] ?? false,
              'isProfileImage': false,
            };
            if (subItemType == 'StackTextItem') {
              subItem['content'] = subItemJson['content'];
            } else {
              throw Exception('Unsupported sub-item type: $subItemType');
            }
            return subItem;
          }).toList(),
        };
      }

      exportedItems.add(exportedItem);
    }

    final temp = CardTemplate(
      id: 'exported_${initialTemplate!.id}_modified_${DateTime.now().millisecondsSinceEpoch}',
      name: templateName.value.isNotEmpty
          ? templateName.value
          : initialTemplate!.name,
      thumbnailPath: initialTemplate!.thumbnailPath,
      backgroundImage: initialTemplate?.backgroundImage ?? "",
      items: exportedItems,
      createdAt: DateTime.now(),
      updatedAt: null,
      category: category.value,
      categoryId: categoryId.value,
      compatibleDesigns: initialTemplate!.compatibleDesigns,
      width: originalWidth,
      height: originalHeight,
      isPremium: isPremium.value,
      tags: tags.value,
      imagePath: selectedBackground.value,
    );

    await addTemplate(temp);
  }

  // NEW: Method to add profile images dynamically

  void _updateGridSize() {
    if (actualStackBoardRenderSize.value == Size.zero) return;
    final double width = actualStackBoardRenderSize.value.width;
    final double height = actualStackBoardRenderSize.value.height;
    const int divisions = 20;
    double newGridSize = math.min(width, height) / divisions;
    newGridSize = math.max(15.0, newGridSize);
    while (width % newGridSize != 0 || height % newGridSize != 0) {
      newGridSize = (newGridSize / 2).floorToDouble();
      if (newGridSize < 15.0) {
        newGridSize = 15.0;
        break;
      }
    }
    gridSize.value = newGridSize;
  }

  Offset getCenteredOffset(Size itemSize, {double? existingDy}) {
    if (actualStackBoardRenderSize.value == Size.zero) {
      debugPrint("Warning: actualStackBoardRenderSize is zero for centering.");
      return Offset(0, existingDy ?? 0);
    }
    final double centerX =
        (actualStackBoardRenderSize.value.width - itemSize.width) / 2;
    final double clampedX = centerX.clamp(
      0.0,
      actualStackBoardRenderSize.value.width - itemSize.width,
    );
    final double clampedY = (existingDy ?? 0.0).clamp(
      0.0,
      actualStackBoardRenderSize.value.height - itemSize.height,
    );
    return Offset(clampedX, clampedY);
  }

  StackItem _deserializeItem(Map<String, dynamic> itemJson) {
    final type = itemJson['type'];
    if (type == 'StackTextItem') {
      return StackTextItem.fromJson(itemJson);
    } else if (type == 'StackImageItem') {
      return StackImageItem.fromJson(itemJson);
    } else {
      throw Exception('Unsupported item type: $type');
    }
  }

  void onItemSizeChanged(StackItem item, Size newSize) {
    final currentItemJson = boardController.getAllData().firstWhere(
      (json) => json['id'] == item.id,
      orElse: () => <String, dynamic>{},
    );
    if (currentItemJson.isEmpty) return;
    final previousItem = _deserializeItem(currentItemJson);
    _undoStack.add(_ItemState(item: previousItem, action: _ItemAction.update));
    _redoStack.clear();
    if (item is StackTextItem && item.content != null) {
      final currentFontSize = item.content!.style?.fontSize ?? 24.0;
      final scaleFactor = math.min(
        newSize.width / item.size.width,
        newSize.height / item.size.height,
      );
      final newFontSize = (currentFontSize * scaleFactor).clamp(8.0, 72.0);
      final updatedContent = item.content!.copyWith(
        style: item.content!.style?.copyWith(fontSize: newFontSize),
      );
      final updatedItem = item.copyWith(size: newSize, content: updatedContent);
      boardController.updateItem(updatedItem);
      activeItem.value = updatedItem;
    } else {
      final updatedItem = item.copyWith(size: newSize);
      boardController.updateItem(updatedItem);
      activeItem.value = updatedItem;
    }
  }

  Future<void> addTemplate(CardTemplate template) async {
    print(template.backgroundImage.toString());

    await StorageService.addTemplate(template);
  }

  @override
  void onClose() {
    boardController.dispose();
    super.onClose();
  }
}

class _ItemState {
  final StackItem item;
  final _ItemAction action;
  final double? previousHue;

  _ItemState({required this.item, required this.action, this.previousHue});
}

enum _ItemAction { add, update, hue }
