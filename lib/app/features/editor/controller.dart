import 'dart:convert';
import 'dart:math' as math;

import 'package:cardmaker/app/features/editor/editor_canvas.dart';
import 'package:cardmaker/models/card_template.dart';
import 'package:cardmaker/services/storage_service.dart';
import 'package:cardmaker/stack_board/lib/flutter_stack_board.dart';
import 'package:cardmaker/stack_board/lib/stack_board_item.dart';
import 'package:cardmaker/stack_board/lib/stack_items.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

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
  final RxList<AlignmentPoint> alignmentPoints = <AlignmentPoint>[].obs;
  final RxBool showGrid = true.obs;
  final RxDouble gridSize = 20.0.obs;
  final Rx<Color> guideColor = Colors.black.obs;
  final Rx<OverlayEntry?> activeTextEditorOverlay = Rx<OverlayEntry?>(null);

  final RxList<_ItemState> _undoStack = <_ItemState>[].obs;
  final RxList<_ItemState> _redoStack = <_ItemState>[].obs;
  Rx<Offset> midYOffset = Rx<Offset>(Offset(0, 0));
  Rx<Size> midSize = Rx<Size>(Size(0, 0));

  Offset? _dragStart;
  Offset? _lastOffset;
  static const double _dragThreshold = 5.0;
  final RxBool showHueSlider = false.obs;
  final RxBool showStickerPanel = false.obs;
  final RxInt selectedToolIndex = 0.obs;

  // bool get showVerticalLine =>

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is Map<String, dynamic>) {
      // Initialize blank template
      initialTemplate = Get.arguments['template'];
    } else {
      initialTemplate = Get.arguments as CardTemplate;
    }

    // Initialize properties from initialTemplate
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
    boardController.clear(); // Ensure the canvas starts fresh
    print(initialTemplate?.toJson());
  }

  void updateStackBoardRenderSize(Size size) {
    if (actualStackBoardRenderSize.value != size) {
      actualStackBoardRenderSize.value = size;

      _updateGridSize();
    }
  }

  // New method to export design as CardTemplate with pixel-perfect accuracy
  Future<void> exportDesign() async {
    final double originalWidth = initialTemplate!.width.toDouble();
    final double originalHeight = initialTemplate!.height.toDouble();

    final List<Map<String, dynamic>> exportedItems = [];
    final currentItems = boardController.getAllData();

    debugPrint('Current Items: $currentItems', wrapWidth: 1000);

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
      };

      if (type == 'StackTextItem') {
        // Use TextItemContent.toJson to include all properties, including circular text
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
            };
            if (subItemType == 'StackTextItem') {
              // Use TextItemContent.toJson for sub-item content
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

    // Add to featuredTemplates
    await addTemplate(temp);
  }
  // Future<void> exportDesign() async {
  //   final double originalWidth = initialTemplate!.width.toDouble();
  //   final double originalHeight = initialTemplate!.height.toDouble();

  //   final List<Map<String, dynamic>> exportedItems = [];
  //   final currentItems = boardController.getAllData();

  //   debugPrint('Current Items: $currentItems', wrapWidth: 1000);

  //   for (final itemJson in currentItems) {
  //     final type = itemJson['type'];
  //     final Map<String, dynamic> exportedItem = {
  //       'type': type,
  //       'id': itemJson['id'],
  //       'status': itemJson['status'] ?? 0,
  //       'isCentered': itemJson['isCentered'] ?? false,
  //       'size': {
  //         'width': itemJson['size']['width'],
  //         'height': itemJson['size']['height'],
  //       },
  //       'offset': {
  //         'dx': itemJson['offset']['dx'],
  //         'dy': itemJson['offset']['dy'],
  //       },
  //     };

  //     if (type == 'StackTextItem') {
  //       exportedItem['content'] = {
  //         'data': itemJson['content']['data'],
  //         'googleFont': itemJson['content']['googleFont'],
  //         'style': {
  //           'fontSize': itemJson['content']['style']['fontSize'],
  //           'color': itemJson['content']['style']['color'],
  //         },
  //         'textAlign': itemJson['content']['textAlign'],
  //       };
  //     } else if (type == 'StackImageItem') {
  //       exportedItem['content'] = {
  //         'assetName': itemJson['content']['assetName'],
  //       };
  //     } else if (type == 'RowStackItem') {
  //       exportedItem['content'] = {
  //         'items': (itemJson['content']['items'] as List)
  //             .map(
  //               (subItemJson) => {
  //                 'type': subItemJson['type'],
  //                 'id': subItemJson['id'],
  //                 'status': subItemJson['status'] ?? 0,
  //                 'size': {
  //                   'width': subItemJson['size']['width'],
  //                   'height': subItemJson['size']['height'],
  //                 },
  //                 'offset': {
  //                   'dx': subItemJson['offset']['dx'],
  //                   'dy': subItemJson['offset']['dy'],
  //                 },
  //                 'content': {
  //                   'data': subItemJson['content']['data'],
  //                   'googleFont': subItemJson['content']['googleFont'],
  //                   'style': {
  //                     'fontSize': subItemJson['content']['style']['fontSize'],
  //                     'color': subItemJson['content']['style']['color'],
  //                   },
  //                   'textAlign': subItemJson['content']['textAlign'],
  //                 },
  //                 'isCentered': subItemJson['isCentered'] ?? false,
  //               },
  //             )
  //             .toList(),
  //       };
  //     }

  //     exportedItems.add(exportedItem);
  //   }

  //   final temp = CardTemplate(
  //     id: 'exported_${initialTemplate!.id}_modified_${DateTime.now().millisecondsSinceEpoch}',
  //     name: templateName.value.isNotEmpty
  //         ? templateName.value
  //         : initialTemplate!.name,
  //     thumbnailPath: initialTemplate!.thumbnailPath,
  //     backgroundImage: initialTemplate?.backgroundImage ?? "",
  //     items: exportedItems,
  //     createdAt: DateTime.now(),
  //     updatedAt: null,
  //     category: category.value,
  //     categoryId: categoryId.value,
  //     compatibleDesigns: initialTemplate!.compatibleDesigns,
  //     width: originalWidth,
  //     height: originalHeight,
  //     isPremium: isPremium.value,
  //     tags: tags.value,
  //     imagePath: selectedBackground.value,
  //   );

  //   // Add to featuredTemplates
  //   addTemplate(temp);
  // }

  void removeTextEditorOverlay() {
    final entry = activeTextEditorOverlay.value;
    if (entry != null && entry.mounted) {
      entry.remove();
      activeTextEditorOverlay.value = null;
    }
  }

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

  // Deserialize item based on type
  StackItem _deserializeItem(Map<String, dynamic> itemJson) {
    final type = itemJson['type'];
    if (type == 'StackTextItem') {
      return StackTextItem.fromJson(itemJson);
    } else if (type == 'StackImageItem') {
      return StackImageItem.fromJson(itemJson);
    } else if (type == 'RowStackItem') {
      return RowStackItem.fromJson(itemJson);
    } else {
      throw Exception('Unsupported item type: $type');
    }
  }

  Future<void> loadFromStorage(
    String templateId,
    BuildContext context,
    BoxConstraints constraints,
  ) async {
    final storage = GetStorage();
    final jsonString = storage.read(templateId);
    if (jsonString == null) {
      throw Exception('No template found with id: $templateId');
    }

    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
    final template = CardTemplate.fromJson(jsonMap);

    // Calculate scaled canvas size
    final double availableWidth = constraints.maxWidth * 0.9;
    final double availableHeight = constraints.maxHeight * 0.95;
    final double aspectRatio = template.width / template.height;

    double scaledCanvasWidth, scaledCanvasHeight;
    if (availableWidth / aspectRatio <= availableHeight) {
      scaledCanvasWidth = availableWidth;
      scaledCanvasHeight = availableWidth / aspectRatio;
    } else {
      scaledCanvasHeight = availableHeight;
      scaledCanvasWidth = availableHeight * aspectRatio;
    }

    final controller = Get.find<EditorController>();
    controller.canvasWidth.value = scaledCanvasWidth;
    controller.canvasHeight.value = scaledCanvasHeight;
    controller.updateStackBoardRenderSize(
      Size(controller.canvasWidth.value, controller.canvasHeight.value),
    );

    debugPrint(
      'Loaded from storage - Updated StackBoard size for template ${template.id}: ${controller.canvasWidth.value} x ${controller.canvasHeight.value}',
    );

    loadExportedTemplate(
      template,
      context,
      scaledCanvasWidth,
      scaledCanvasHeight,
    );
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
    controller.templateOriginalWidth.value = template.width.toDouble(); // 1748
    controller.templateOriginalHeight.value = template.height
        .toDouble(); // 1240
    controller.canvasWidth.value = scaledCanvasWidth; // Use scaled width
    controller.canvasHeight.value = scaledCanvasHeight; // Use scaled height
    controller.boardController.clear();
    // double cumulativeYOffset = 0.0;

    for (final itemJson in template.items) {
      try {
        final bool isCentered = itemJson['isCentered'] ?? false;

        print(
          "ccccccccccccccccccccccccccccccvvvvvvvvvvvvvvvvvvvvvvvvvwwwwwwwwwwwwwwwwwwwwwwwww",
        );
        print(itemJson);
        if (itemJson['type'] == 'RowStackItem') {
          RowStackItem rowStackItem = RowStackItem.fromJson(itemJson);
          double totalWidth = 0.0;
          double maxHeight = 0.0;
          final List<StackItem> scaledSubItems = [];
          double rowScaledX = rowStackItem.offset.dx; // No scaling
          double rowScaledY = rowStackItem.offset.dy; // No scaling

          for (final subItem in rowStackItem.content!.items) {
            StackItem updatedSubItem;

            if (subItem is StackTextItem) {
              final updatedStyle = subItem.content!.style!.copyWith(
                fontSize: subItem.content!.style!.fontSize, // No scaling
              );

              // Use exact size from exported data
              final subItemWidth = itemJson['size']['width'];
              final subItemHeight = itemJson['size']['height'];

              final scaledY = (subItem.offset.dy > 0
                  ? subItem
                        .offset
                        .dy // No scaling
                  : rowScaledY);

              updatedSubItem = subItem.copyWith(
                offset: Offset(rowScaledX, scaledY),
                size: Size(subItemWidth, subItemHeight),
                content: subItem.content!.copyWith(
                  style: updatedStyle,
                  data: subItem.content!.data,
                ),
                status: StackItemStatus.idle,
                isCentered: subItem.isCentered,
              );

              totalWidth += subItemWidth;
              maxHeight = subItemHeight;
              debugPrint(
                'Loaded sub-item: ${subItem.id}, isCentered: ${subItem.isCentered}, size: ${updatedSubItem.size}, offset: ${updatedSubItem.offset}',
              );
              controller.boardController.addItem(updatedSubItem);
              scaledSubItems.add(updatedSubItem);
              rowScaledX += subItemWidth; // No scaling in increment
              controller._undoStack.add(
                _ItemState(item: updatedSubItem, action: _ItemAction.add),
              );
            } else {
              throw Exception(
                'Unsupported sub-item type in RowStackItem: ${subItem.runtimeType}',
              );
            }
          }

          if (isCentered) {
            double startX = ((controller.canvasWidth - totalWidth) / 2);
            for (var subItem in scaledSubItems) {
              controller.boardController.updateBasic(
                subItem.id,
                offset: Offset(
                  startX + subItem.size.width / 2,
                  subItem.offset.dy,
                ),
              );
              startX += subItem.size.width;
            }
          }

          // cumulativeYOffset += maxHeight;
        } else {
          final item = _deserializeItem(itemJson);
          Size itemSize;
          StackItem updatedItem;

          if (item is StackTextItem) {
            double scaledX = item.offset.dx; // No scaling
            double scaledY = item.offset.dy; // No scaling
            // scaledY += cumulativeYOffset;

            final updatedStyle = item.content!.style!.copyWith(
              fontSize: item.content!.style!.fontSize!, // No scaling
            );

            // Use exact size from exported data
            itemSize = Size(
              itemJson['size']['width'],
              itemJson['size']['height'],
            );

            final double buttonSize = 18; // No scaling
            // if (isCentered) {
            //   scaledY +=
            //       (itemSize.height / 2) + buttonSize; // Use unscaled buttonSize
            // }

            updatedItem = item.copyWith(
              offset: Offset(scaledX, scaledY),
              size: itemSize,
              status: StackItemStatus.idle,
              content: item.content!.copyWith(style: updatedStyle),
              isCentered: isCentered,
            );
            // cumulativeYOffset += itemSize.height;
          } else if (item is StackImageItem) {
            double scaledX = item.offset.dx; // No scaling
            double scaledY = item.offset.dy; // No scaling
            final double originalWidth = itemJson['size']['width'];
            final double originalHeight = itemJson['size']['height'];

            itemSize = Size(originalWidth, originalHeight);

            final double buttonSize = 36; // No scaling
            // scaledY += buttonSize + cumulativeYOffset;

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
        }
      } catch (err) {}
    }
  }

  // --- Template Management ---
  Future<void> addTemplate(CardTemplate template) async {
    print(template.backgroundImage.toString());

    await StorageService.addTemplate(template);
  }

  Future<void> deleteItem(StackItem<StackItemContent> item) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      _undoStack.add(_ItemState(item: item, action: _ItemAction.delete));
      _redoStack.clear();
      boardController.removeById(item.id);
      if (activeItem.value?.id == item.id) activeItem.value = null;
      _updateSpatialIndex();
    }
  }

  void addSticker(String imagePath) {
    final sticker = StackImageItem(
      id: UniqueKey().toString(),
      size: const Size(100, 100),
      offset: getCenteredOffset(const Size(100, 100)),
      content: ImageItemContent(assetName: imagePath),
    );
    boardController.addItem(sticker);
    _undoStack.add(_ItemState(item: sticker, action: _ItemAction.add));
    _redoStack.clear();
    _updateSpatialIndex();
  }

  void addText(String data, {Size? size}) {
    final textItem = StackTextItem(
      id: UniqueKey().toString(),
      size: size ?? const Size(200, 50),
      offset: getCenteredOffset(size ?? const Size(200, 50)),
      content: TextItemContent(
        data: data,
        googleFont: 'Roboto',
        style: const TextStyle(fontSize: 24, color: Colors.black),
        textAlign: TextAlign.center,
      ),
    );
    boardController.addItem(textItem);
    _undoStack.add(_ItemState(item: textItem, action: _ItemAction.add));
    _redoStack.clear();
    _updateSpatialIndex();
    activeItem.value = textItem;
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
  }

  void toggleGrid() => showGrid.value = !showGrid.value;

  void undo() {
    if (_undoStack.isEmpty) return;
    final state = _undoStack.removeLast();
    switch (state.action) {
      case _ItemAction.add:
        boardController.removeById(state.item.id);
        _redoStack.add(state);
        if (activeItem.value?.id == state.item.id) activeItem.value = null;
        break;
      case _ItemAction.update:
        final currentItemJson = boardController.getAllData().firstWhere(
          (json) => json['id'] == state.item.id,
          orElse: () => <String, dynamic>{},
        );
        if (currentItemJson.isNotEmpty) {
          final currentItem = _deserializeItem(currentItemJson);
          _redoStack.add(
            _ItemState(item: currentItem, action: _ItemAction.update),
          );
          boardController.updateItem(state.item);
          activeItem.value = state.item;
        }
        break;
      case _ItemAction.delete:
        boardController.addItem(state.item);
        _redoStack.add(state);
        activeItem.value = state.item;
        break;
      case _ItemAction.hue:
        final previousHue = state.previousHue ?? 0.0;
        _redoStack.add(
          _ItemState(
            item: state.item,
            action: _ItemAction.hue,
            previousHue: backgroundHue.value,
          ),
        );
        backgroundHue.value = previousHue;
        break;
    }
    _updateSpatialIndex();
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    final state = _redoStack.removeLast();
    switch (state.action) {
      case _ItemAction.add:
        boardController.addItem(state.item);
        _undoStack.add(state);
        activeItem.value = state.item;
        break;
      case _ItemAction.update:
        final currentItemJson = boardController.getAllData().firstWhere(
          (json) => json['id'] == state.item.id,
          orElse: () => <String, dynamic>{},
        );
        if (currentItemJson.isNotEmpty) {
          final currentItem = _deserializeItem(currentItemJson);
          _undoStack.add(
            _ItemState(item: currentItem, action: _ItemAction.update),
          );
          boardController.updateItem(state.item);
          activeItem.value = state.item;
        }
        break;
      case _ItemAction.delete:
        boardController.removeById(state.item.id);
        _undoStack.add(state);
        if (activeItem.value?.id == state.item.id) activeItem.value = null;
        break;
      case _ItemAction.hue:
        final previousHue = state.previousHue ?? 0.0;
        _undoStack.add(
          _ItemState(
            item: state.item,
            action: _ItemAction.hue,
            previousHue: backgroundHue.value,
          ),
        );
        backgroundHue.value = previousHue;
        break;
    }
    _updateSpatialIndex();
  }

  void onItemOffsetChanged(StackItem item, Offset offset) {
    if (draggedItem.value?.id != item.id) return;
    if (_dragStart == null) {
      _dragStart = offset;
      _lastOffset = offset;
      draggedItem.value = item.copyWith(offset: offset);
      return;
    }
    final double distance = (offset - _dragStart!).distance;
    if (distance < _dragThreshold && _lastOffset != null) {
      draggedItem.value = item.copyWith(offset: _lastOffset!);
      return;
    }
    _lastOffset = offset;
    draggedItem.value = item.copyWith(offset: offset);
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
    _updateSpatialIndex();
  }

  // void onItemStatusChanged(StackItem item, StackItemStatus status) {
  //   print(item.toJson());
  //   if (status == StackItemStatus.moving) {
  //     draggedItem.value = item;

  //     activeItem.value = null;

  //     _dragStart = null;
  //     _lastOffset = null;
  //   } else if (status == StackItemStatus.selected) {
  //     activeItem.value = null;
  //     draggedItem.value = null;
  //     _dragStart = null;
  //     _lastOffset = null;
  //     alignmentPoints.value = [];
  //   } else if (status == StackItemStatus.idle) {
  //     if (draggedItem.value?.id == item.id) {
  //     } else if (activeItem.value?.id == item.id) {
  //       activeItem.value = null;
  //       alignmentPoints.value = [];
  //     }
  //   }
  // }

  void onItemStatusChanged(StackItem item, StackItemStatus status) {
    if (status == StackItemStatus.moving) {
      draggedItem.value = item;

      activeItem.value = null;

      _dragStart = null;
      _lastOffset = null;
    } else if (status == StackItemStatus.selected) {
      draggedItem.value = null;
      _dragStart = null;
      _lastOffset = null;
      alignmentPoints.value = [];
    } else if (status == StackItemStatus.idle) {
      if (draggedItem.value?.id == item.id) {
        draggedItem.value = null;
      }
      if (activeItem.value?.id == item.id) {
        activeItem.value = null;
        alignmentPoints.value = [];
      }
    }
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
      _updateSpatialIndex();
    }
  }

  _SpatialIndex _spatialIndex = _SpatialIndex();

  void _updateSpatialIndex() {
    _spatialIndex = _SpatialIndex();
    final allItems = boardController.getAllData();
    for (final itemJson in allItems) {
      if (itemJson['id'] != draggedItem.value?.id) {
        try {
          final item = _deserializeItem(itemJson);
          _spatialIndex.addItem(item);
        } catch (e) {
          debugPrint('Error adding item to spatial index: $e');
        }
      }
    }
  }

  @override
  void onClose() {
    boardController.dispose();
    super.onClose();
  }
}

class _SnapResult {
  final List<AlignmentPoint> points;
  final Offset snappedOffset;

  _SnapResult({required this.points, required this.snappedOffset});
}

class _SpatialIndex {
  final Map<int, List<StackItem>> _buckets = {};
  static const double bucketSize = 30.0;

  void addItem(StackItem item) {
    final double centerX = item.offset.dx + item.size.width / 2;
    final double centerY = item.offset.dy + item.size.height / 2;
    final int bucketX = (centerX / bucketSize).floor();
    final int bucketY = (centerY / bucketSize).floor();
    final int key = bucketX * 10000 + bucketY;
    _buckets.putIfAbsent(key, () => []).add(item);
  }

  List<StackItem> getNearbyItems(Offset center) {
    const double maxDistance = 150.0;
    final int centerBucketX = (center.dx / bucketSize).floor();
    final int centerBucketY = (center.dy / bucketSize).floor();
    final List<StackItem> nearbyItems = [];
    for (int dx = -2; dx <= 2; dx++) {
      for (int dy = -2; dy <= 2; dy++) {
        final int bucketX = centerBucketX + dx;
        final int bucketY = centerBucketY + dy;
        final int key = bucketX * 10000 + bucketY;
        final items = _buckets[key] ?? [];
        for (final item in items) {
          final itemCenter = Offset(
            item.offset.dx + item.size.width / 2,
            item.offset.dy + item.size.height / 2,
          );
          if ((center - itemCenter).distance < maxDistance)
            nearbyItems.add(item);
        }
      }
    }
    return nearbyItems;
  }
}

class _ItemState {
  final StackItem item;
  final _ItemAction action;
  final double? previousHue;

  _ItemState({required this.item, required this.action, this.previousHue});
}

enum _ItemAction { add, update, delete, hue }

enum AlignmentOption { center, left, right, top, bottom }

enum SnapType { inactive, edge, center, edgeCritical, centerCritical }

class AlignmentPoint {
  final double value;
  final bool isVertical;
  final SnapType snapType;

  AlignmentPoint({
    required this.value,
    required this.isVertical,
    required this.snapType,
  });

  bool get isSnapped => snapType != SnapType.inactive;
  bool get isCriticalSnap =>
      snapType == SnapType.edgeCritical || snapType == SnapType.centerCritical;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlignmentPoint &&
          value == other.value &&
          isVertical == other.isVertical &&
          snapType == other.snapType;

  @override
  int get hashCode => Object.hash(value, isVertical, snapType);
}

extension IterableExtension<T> on Iterable<T> {
  List<T> sorted(int Function(T, T) compare) {
    final list = toList();
    list.sort(compare);
    return list;
  }
}
