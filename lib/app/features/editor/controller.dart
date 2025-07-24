import 'dart:math' as math;

import 'package:cardmaker/app/features/editor/editor_canvas.dart';
import 'package:cardmaker/app/features/home/home.dart';
import 'package:cardmaker/models/card_template.dart';
import 'package:cardmaker/stack_board/lib/flutter_stack_board.dart';
import 'package:cardmaker/stack_board/lib/stack_board_item.dart';
import 'package:cardmaker/stack_board/lib/stack_items.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final RxList<AlignmentPoint> alignmentPoints = <AlignmentPoint>[].obs;
  final RxBool showGrid = true.obs;
  final RxDouble gridSize = 20.0.obs;
  final Rx<Color> guideColor = Colors.black.obs;
  final Rx<OverlayEntry?> activeTextEditorOverlay = Rx<OverlayEntry?>(null);

  final RxList<_ItemState> _undoStack = <_ItemState>[].obs;
  final RxList<_ItemState> _redoStack = <_ItemState>[].obs;

  Offset? _dragStart;
  Offset? _lastOffset;
  static const double _dragThreshold = 5.0;
  final RxBool showHueSlider = false.obs;
  final RxBool showStickerPanel = false.obs;
  final RxInt selectedToolIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    initialTemplate = Get.arguments as CardTemplate?;
    if (initialTemplate != null) {
      templateOriginalWidth.value = initialTemplate!.width.toDouble();
      templateOriginalHeight.value = initialTemplate!.height.toDouble();
      canvasWidth.value = initialTemplate!.width.toDouble();
      canvasHeight.value = initialTemplate!.height.toDouble();
    }
  }

  void updateStackBoardRenderSize(Size size) {
    print(
      "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx ${size.width}",
    );
    if (actualStackBoardRenderSize.value != size) {
      actualStackBoardRenderSize.value = size;

      _updateGridSize();
    }
  }

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

  Offset _getAbsoluteOffsetFromRelative(Offset relativeOffset, Size itemSize) {
    if (actualStackBoardRenderSize.value == Size.zero ||
        templateOriginalWidth.value == 0 ||
        templateOriginalHeight.value == 0) {
      debugPrint("Warning: Invalid dimensions for offset calculation.");
      return Offset.zero;
    }
    final double scaleX =
        actualStackBoardRenderSize.value.width / templateOriginalWidth.value;
    final double scaleY =
        actualStackBoardRenderSize.value.height / templateOriginalHeight.value;
    final double x = relativeOffset.dx * scaleX;
    final double y = relativeOffset.dy * scaleY;
    return Offset(
      x.clamp(0.0, actualStackBoardRenderSize.value.width - itemSize.width),
      y.clamp(0.0, actualStackBoardRenderSize.value.height - itemSize.height),
    );
  }

  Offset getRelativeOffsetFromAbsolute(Offset absoluteOffset) {
    if (templateOriginalWidth.value == 0 || templateOriginalHeight.value == 0) {
      debugPrint("Warning: templateOriginalSize is zero.");
      return Offset.zero;
    }
    return Offset(
      (absoluteOffset.dx / actualStackBoardRenderSize.value.width) *
          templateOriginalWidth.value,
      (absoluteOffset.dy / actualStackBoardRenderSize.value.height) *
          templateOriginalHeight.value,
    );
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
    } else if (type == 'ShapeStackItem') {
      return ShapeStackItem.fromJson(itemJson);
    } else if (type == 'RowStackItem') {
      return RowStackItem.fromJson(itemJson);
    } else {
      throw Exception('Unsupported item type: $type');
    }
  }

  // Updated loadTemplate to handle row items as separate StackItems
  void loadTemplate(
    CardTemplate template,
    double canvasScale,
    double scaledCanvasWidth,
    double scaledCanvasHeight,
    BuildContext context,
  ) async {
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
    const double previewFactor = 0.1; // Adjust for home screen preview
    double cumulativeYOffset = 0.0;

    for (final itemJson in template.items) {
      try {
        // final double originalX = (itemJson['originalX'] ?? 0.0) as double;
        // final double originalY = (itemJson['originalY'] ?? 0.0) as double;
        final bool isCentered = itemJson['isCentered'] ?? false;

        // Scale the item's position based on the provided canvas scale

        if (itemJson['type'] == 'RowStackItem') {
          RowStackItem rowStackItem = RowStackItem.fromJson(itemJson);

          // Handle row items as separate StackItems
          // final subItems = (itemJson['content']['items'] as List)
          //     .map((subItemJson) => _deserializeItem(subItemJson))
          //     .toList();

          double totalWidth = 0.0; //sum of widths of each row item
          double maxHeight = 0.0;
          final List<StackItem> scaledSubItems = [];
          double subItemWidth = 0.0;
          double subItemHeight = 0.0;
          double rowScaledX =
              (rowStackItem.offset.dx * canvasScale); //offset of the row
          double rowScaledY = (rowStackItem.offset.dy * canvasScale);
          // Process each sub-item
          for (final subItem in rowStackItem.content!.items) {
            // rowScaledY += cumulativeYOffset;
            StackItem updatedSubItem;

            if (subItem is StackTextItem) {
              // Reuse the same scaling logic as standalone StackTextItem
              final updatedStyle = subItem.content!.style!.copyWith(
                fontSize: subItem.content!.style!.fontSize,
              );

              // Calculate the sub-item's size based on the scaled text
              subItemWidth = getTextWidth(
                text: subItem.content!.data!,
                style: updatedStyle,
              ).width;
              subItemHeight = getTextWidth(
                text: subItem.content!.data!,
                style: updatedStyle,
              ).height;

              // Adjust y-position for button size if centered
              final double buttonSize = 18 * canvasScale;
              // if (subItem.isCentered) {
              //   subItemY += (subItemHeight / 2) + buttonSize;
              // }

              final scaledY =
                  (subItem.offset.dy >
                      0 //if item.dy is zero it means it is aligned with the Main rowScaledY
                  ? subItem.offset.dy * canvasScale
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
            }
            // else if (subItem is ShapeStackItem) {
            //   subItemWidth = subItem.size.width * canvasScale;
            //   subItemHeight = subItem.size.height * canvasScale;
            //   updatedSubItem = subItem.copyWith(
            //     offset: Offset(scaledX + totalWidth, scaledY),
            //     size: Size(subItemWidth, subItemHeight),
            //     status: StackItemStatus.idle,
            //     isCentered: subItem.isCentered,
            //   );
            //   totalWidth += subItemWidth;
            //   maxHeight = math.max(maxHeight, subItemHeight);
            // }
            else {
              throw Exception(
                'Unsupported sub-item type in RowStackItem: ${subItem.runtimeType}',
              );
            }

            debugPrint(
              'Loaded sub-item: ${subItem.id}, isCentered: ${subItem.isCentered}, size: ${updatedSubItem.size}, offset: ${updatedSubItem.offset}',
            );
            controller.boardController.addItem(updatedSubItem);
            scaledSubItems.add(updatedSubItem);
            rowScaledX += (subItemWidth);
            controller._undoStack.add(
              _ItemState(item: updatedSubItem, action: _ItemAction.add),
            );
          }

          // Adjust for centering the entire row
          if (isCentered) {
            // Proper centering: remaining space divided by 2
            double startX = (((canvasWidth - totalWidth) / 2));

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

          cumulativeYOffset += maxHeight * canvasScale;
        } else {
          final item = _deserializeItem(itemJson);
          Size itemSize;
          StackItem updatedItem;

          if (item is StackTextItem) {
            double scaledX = item.offset.dx * canvasScale;
            double scaledY = item.offset.dy * canvasScale;
            scaledY += cumulativeYOffset;

            // Update the item's style with the scaled font size
            final updatedStyle = item.content!.style!.copyWith(
              fontSize: item.content!.style!.fontSize,
            );

            // Calculate the item's size based on the scaled text
            itemSize = Size(
              getTextWidth(
                    text: item.content!.data!,
                    style: updatedStyle,
                  ).width +
                  20,
              getTextWidth(
                text: item.content!.data!,
                style: updatedStyle,
              ).height,
            );

            // Adjust y-position for button size if centered
            final double buttonSize = 18 * canvasScale;
            if (isCentered) {
              scaledY += (itemSize.height / 2) + buttonSize;
            }

            updatedItem = item.copyWith(
              offset: Offset(scaledX, scaledY),
              size: itemSize,
              status: StackItemStatus.idle, // Ensure item is movable
              content: item.content!.copyWith(style: updatedStyle),
              isCentered: isCentered,
            );
            cumulativeYOffset += itemSize.height;
          } else if (item is StackImageItem) {
            double scaledX = item.offset.dx * canvasScale;
            double scaledY = item.offset.dy * canvasScale;
            // Assume itemJson contains width and height for the image
            final double originalWidth =
                (itemJson['size']?['width'] ?? 100.0) as double;
            final double originalHeight =
                (itemJson['size']?['height'] ?? 100.0) as double;

            // Scale the image size
            itemSize = Size(
              originalWidth * canvasScale,
              originalHeight * canvasScale,
            );

            // Adjust y-position for button size if centered
            final double buttonSize = 36 * canvasScale;
            if (isCentered) {
              scaledY += (itemSize.height / 2);
            }

            updatedItem = item.copyWith(
              offset: Offset(scaledX, scaledY),
              size: itemSize,
              status: StackItemStatus.idle, // Ensure item is movable
              // isCentered: isCentered,
            );
            // cumulativeYOffset += itemSize.height / 2;
          } else if (item is ShapeStackItem) {
            final double originalWidth =
                (itemJson['size']?['width'] ?? 100.0) as double;
            final double originalHeight =
                (itemJson['size']?['height'] ?? 100.0) as double;
            double scaledX = item.offset.dx * canvasScale;
            double scaledY = item.offset.dy * canvasScale;
            // Scale the shape size
            itemSize = Size(
              originalWidth * canvasScale,
              originalHeight * canvasScale,
            );

            // Adjust x-position for centering if needed
            if (isCentered) {
              scaledX = (scaledCanvasWidth - itemSize.width) / 2;
            }

            updatedItem = item.copyWith(
              offset: Offset(scaledX, scaledY),
              size: itemSize,
              status: StackItemStatus.idle,
              isCentered: isCentered,
            );
            cumulativeYOffset += itemSize.height;
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
      } catch (e) {
        debugPrint("Error loading item: $e");
        Get.snackbar(
          'Error',
          'Failed to load item: $e',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
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
      _debounceCalculateAlignmentPoints(item, offset);
      return;
    }
    final double distance = (offset - _dragStart!).distance;
    if (distance < _dragThreshold && _lastOffset != null) {
      draggedItem.value = item.copyWith(offset: _lastOffset!);
      return;
    }
    _lastOffset = offset;
    draggedItem.value = item.copyWith(offset: offset);
    _debounceCalculateAlignmentPoints(item, offset);
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

  void onItemStatusChanged(StackItem item, StackItemStatus status) {
    if (status == StackItemStatus.moving) {
      draggedItem.value = item;
      activeItem.value = item;
      _dragStart = null;
      _lastOffset = null;
      _debounceCalculateAlignmentPoints(item, item.offset);
    } else if (status == StackItemStatus.selected) {
      activeItem.value = item;
      draggedItem.value = null;
      _dragStart = null;
      _lastOffset = null;
      alignmentPoints.value = [];
    } else if (status == StackItemStatus.idle) {
      if (draggedItem.value?.id == item.id) {
        final snapResult = _findClosestSnapPoints(item, item.offset);
        if (snapResult.snappedOffset != item.offset) {
          _undoStack.add(_ItemState(item: item, action: _ItemAction.update));
          _redoStack.clear();
          boardController.updateItem(
            item.copyWith(offset: snapResult.snappedOffset),
          );
          final isCriticalSnap = snapResult.points.any((p) => p.isCriticalSnap);
          if (isCriticalSnap) {
            HapticFeedback.heavyImpact();
          } else if (snapResult.points.any((p) => p.isSnapped)) {
            HapticFeedback.lightImpact();
          }
          activeItem.value = item.copyWith(offset: snapResult.snappedOffset);
        }
        draggedItem.value = null;
        _dragStart = null;
        _lastOffset = null;
        alignmentPoints.value = [];
      } else if (activeItem.value?.id == item.id) {
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

  void _debounceCalculateAlignmentPoints(StackItem item, Offset offset) {
    Future.delayed(const Duration(milliseconds: 16), () {
      if (draggedItem.value?.id == item.id) {
        final snapResult = _findClosestSnapPoints(item, offset);
        alignmentPoints.value = snapResult.points;
      } else {
        alignmentPoints.value = [];
      }
    });
  }

  _SnapResult _findClosestSnapPoints(StackItem item, Offset offset) {
    const double snapThreshold = 5.0;
    const double criticalSnapThreshold = 2.0;
    final List<AlignmentPoint> points = [];
    double? closestX, closestY;
    double minXDistance = double.infinity;
    double minYDistance = double.infinity;
    bool isCriticalXSnap = false;
    bool isCriticalYSnap = false;

    final draggedRect = Rect.fromLTWH(
      offset.dx,
      offset.dy,
      item.size.width,
      item.size.height,
    );
    final double itemMidX = draggedRect.center.dx;
    final double itemMidY = draggedRect.center.dy;
    final Map<double, SnapType> verticalPoints = {};
    final Map<double, SnapType> horizontalPoints = {};

    final double centerX = actualStackBoardRenderSize.value.width / 2;
    final double centerY = actualStackBoardRenderSize.value.height / 2;
    final List<double> canvasVerticals = [
      0,
      centerX,
      actualStackBoardRenderSize.value.width,
    ];
    final List<double> canvasHorizontals = [
      0,
      centerY,
      actualStackBoardRenderSize.value.height,
    ];

    for (final x in canvasVerticals) {
      final leftDistance = (draggedRect.left - x).abs();
      final rightDistance = (draggedRect.right - x).abs();
      final centerDistance = (itemMidX - x).abs();
      if (centerDistance < criticalSnapThreshold &&
          centerDistance < minXDistance) {
        verticalPoints[x] = SnapType.centerCritical;
        closestX = x - item.size.width / 2;
        minXDistance = centerDistance;
        isCriticalXSnap = true;
      } else if (leftDistance < criticalSnapThreshold &&
          leftDistance < minXDistance) {
        verticalPoints[x] = SnapType.edgeCritical;
        closestX = x;
        minXDistance = leftDistance;
        isCriticalXSnap = true;
      } else if (rightDistance < criticalSnapThreshold &&
          rightDistance < minXDistance) {
        verticalPoints[x] = SnapType.edgeCritical;
        closestX = x - item.size.width;
        minXDistance = rightDistance;
        isCriticalXSnap = true;
      } else {
        verticalPoints[x] = SnapType.inactive;
      }
    }

    for (final y in canvasHorizontals) {
      final topDistance = (draggedRect.top - y).abs();
      final bottomDistance = (draggedRect.bottom - y).abs();
      final centerDistance = (itemMidY - y).abs();
      if (centerDistance < criticalSnapThreshold &&
          centerDistance < minYDistance) {
        horizontalPoints[y] = SnapType.centerCritical;
        closestY = y - item.size.height / 2;
        minYDistance = centerDistance;
        isCriticalYSnap = true;
      } else if (topDistance < criticalSnapThreshold &&
          topDistance < minYDistance) {
        horizontalPoints[y] = SnapType.edgeCritical;
        closestY = y;
        minYDistance = topDistance;
        isCriticalYSnap = true;
      } else if (bottomDistance < criticalSnapThreshold &&
          bottomDistance < minYDistance) {
        horizontalPoints[y] = SnapType.edgeCritical;
        closestY = y - item.size.height;
        minYDistance = bottomDistance;
        isCriticalYSnap = true;
      } else {
        horizontalPoints[y] = SnapType.inactive;
      }
    }

    final spatialIndex = _spatialIndex;
    final nearbyItems = spatialIndex.getNearbyItems(draggedRect.center);
    for (final otherItem in nearbyItems) {
      final itemRect = Rect.fromLTWH(
        otherItem.offset.dx,
        otherItem.offset.dy,
        otherItem.size.width,
        otherItem.size.height,
      );
      final verticalEdges = [itemRect.left, itemRect.center.dx, itemRect.right];
      final horizontalEdges = [
        itemRect.top,
        itemRect.center.dy,
        itemRect.bottom,
      ];
      for (final x in verticalEdges) {
        final leftDistance = (draggedRect.left - x).abs();
        final rightDistance = (draggedRect.right - x).abs();
        final centerDistance = (itemMidX - x).abs();
        if (centerDistance < snapThreshold &&
            centerDistance < minXDistance &&
            !isCriticalXSnap) {
          verticalPoints[x] = SnapType.center;
          closestX = x - item.size.width / 2;
          minXDistance = centerDistance;
        } else if (leftDistance < snapThreshold &&
            leftDistance < minXDistance &&
            !isCriticalXSnap) {
          verticalPoints[x] = SnapType.edge;
          closestX = x;
          minXDistance = leftDistance;
        } else if (rightDistance < snapThreshold &&
            rightDistance < minXDistance &&
            !isCriticalXSnap) {
          verticalPoints[x] = SnapType.edge;
          closestX = x - item.size.width;
          minXDistance = rightDistance;
        } else {
          verticalPoints.putIfAbsent(x, () => SnapType.inactive);
        }
      }
      for (final y in horizontalEdges) {
        final topDistance = (draggedRect.top - y).abs();
        final bottomDistance = (draggedRect.bottom - y).abs();
        final centerDistance = (itemMidY - y).abs();
        if (centerDistance < snapThreshold &&
            centerDistance < minYDistance &&
            !isCriticalYSnap) {
          horizontalPoints[y] = SnapType.center;
          closestY = y - item.size.height / 2;
          minYDistance = centerDistance;
        } else if (topDistance < snapThreshold &&
            topDistance < minYDistance &&
            !isCriticalYSnap) {
          horizontalPoints[y] = SnapType.edge;
          closestY = y;
          minYDistance = topDistance;
        } else if (bottomDistance < snapThreshold &&
            bottomDistance < minYDistance &&
            !isCriticalYSnap) {
          horizontalPoints[y] = SnapType.edge;
          closestY = y - item.size.height;
          minYDistance = bottomDistance;
        } else {
          horizontalPoints.putIfAbsent(y, () => SnapType.inactive);
        }
      }
    }

    final sortedVertical = verticalPoints.entries
        .toList()
        .sorted((a, b) => a.key.compareTo(b.key))
        .where((e) => e.value != SnapType.inactive)
        .take(3)
        .map(
          (e) => AlignmentPoint(
            value: (e.key * 100).roundToDouble() / 100,
            isVertical: true,
            snapType: e.value,
          ),
        )
        .toList();
    final sortedHorizontal = horizontalPoints.entries
        .toList()
        .sorted((a, b) => a.key.compareTo(b.key))
        .where((e) => e.value != SnapType.inactive)
        .take(3)
        .map(
          (e) => AlignmentPoint(
            value: (e.key * 100).roundToDouble() / 100,
            isVertical: false,
            snapType: e.value,
          ),
        )
        .toList();
    points.addAll(sortedVertical);
    points.addAll(sortedHorizontal);

    final snappedOffset = Offset(
      (closestX ?? offset.dx).clamp(
        0.0,
        actualStackBoardRenderSize.value.width - item.size.width,
      ),
      (closestY ?? offset.dy).clamp(
        0.0,
        actualStackBoardRenderSize.value.height - item.size.height,
      ),
    );

    return _SnapResult(points: points, snappedOffset: snappedOffset);
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
