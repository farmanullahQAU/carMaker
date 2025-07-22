// // import 'dart:math' as math;

// // import 'package:cardmaker/app/features/editor/editor_canvas.dart';
// // import 'package:cardmaker/models/card_template.dart';
// // import 'package:cardmaker/stack_board/lib/flutter_stack_board.dart';
// // import 'package:cardmaker/stack_board/lib/stack_board_item.dart';
// // import 'package:cardmaker/stack_board/lib/stack_items.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/scheduler.dart';
// // import 'package:flutter/services.dart';
// // import 'package:get/get.dart';

// // class EditorController extends GetxController {
// //   final StackBoardController boardController = StackBoardController();
// //   final RxString selectedFont = 'Poppins'.obs;
// //   final RxDouble fontSize = 24.0.obs;
// //   final Rx<Color> fontColor = Colors.black.obs;
// //   final RxString selectedBackground = ''.obs;
// //   final RxString templateName = ''.obs;

// //   final RxDouble templateOriginalWidth = 0.0.obs;
// //   final RxDouble templateOriginalHeight = 0.0.obs;
// //   final Rx<Size> actualStackBoardRenderSize = Size.zero.obs;

// //   final RxString category = 'general'.obs;
// //   final RxString categoryId = 'general'.obs;
// //   final RxList<String> tags = <String>[].obs;
// //   final RxBool isPremium = false.obs;
// //   CardTemplate? initialTemplate;

// //   final RxDouble canvasWidth = 0.0.obs;
// //   final RxDouble canvasHeight = 0.0.obs;

// //   final Rx<StackItem?> draggedItem = Rx<StackItem?>(null);
// //   Rx<StackItem?> activeItem = Rx<StackItem?>(null);
// //   final RxList<AlignmentPoint> alignmentPoints = <AlignmentPoint>[].obs;
// //   final RxBool showGrid = true.obs;
// //   final RxDouble gridSize = 20.0.obs;
// //   final Rx<Color> guideColor = Colors.black.obs;
// //   final Rx<OverlayEntry?> activeTextEditorOverlay = Rx<OverlayEntry?>(null);

// //   // Undo/Redo stacks
// //   final RxList<_ItemState> _undoStack = <_ItemState>[].obs;
// //   final RxList<_ItemState> _redoStack = <_ItemState>[].obs;

// //   // Drag threshold tracking
// //   Offset? _dragStart;
// //   Offset? _lastOffset;
// //   static const double _dragThreshold = 5.0;

// //   @override
// //   void onInit() {
// //     super.onInit();
// //     initialTemplate = Get.arguments as CardTemplate?;
// //     if (initialTemplate != null) {
// //       templateOriginalWidth.value = initialTemplate!.width;
// //       templateOriginalHeight.value = initialTemplate!.height;
// //       canvasWidth.value = initialTemplate!.width;
// //       canvasHeight.value = initialTemplate!.height;
// //     }
// //   }

// //   @override
// //   void onReady() {
// //     super.onReady();
// //     if (initialTemplate != null) {
// //       loadTemplate(initialTemplate!);
// //     }
// //   }

// //   void updateStackBoardRenderSize(Size size) {
// //     if (actualStackBoardRenderSize.value != size) {
// //       actualStackBoardRenderSize.value = size;
// //       _updateGridSize();
// //       // _updateSpatialIndex();
// //     }
// //   }

// //   void removeTextEditorOverlay() {
// //     final entry = activeTextEditorOverlay.value;
// //     if (entry != null && entry.mounted) {
// //       entry.remove();
// //       activeTextEditorOverlay.value = null;
// //     }
// //   }

// //   void _updateGridSize() {
// //     if (actualStackBoardRenderSize.value == Size.zero) return;

// //     final double width = actualStackBoardRenderSize.value.width;
// //     final double height = actualStackBoardRenderSize.value.height;
// //     final int divisions =
// //         20; // Target number of divisions (adjustable for smaller squares)
// //     double newGridSize = math.min(width, height) / divisions;

// //     // Ensure grid size is at least 10.0 and divides evenly
// //     newGridSize = math.max(15.0, newGridSize);
// //     while (width % newGridSize != 0 || height % newGridSize != 0) {
// //       newGridSize = (newGridSize / 2).floorToDouble();
// //       if (newGridSize < 15.0) {
// //         newGridSize = 15.0;
// //         break;
// //       }
// //     }

// //     gridSize.value = newGridSize;
// //   }

// //   Offset _getAbsoluteOffsetFromRelative(Offset relativeOffset, Size itemSize) {
// //     if (actualStackBoardRenderSize.value == Size.zero) {
// //       debugPrint("Warning: actualStackBoardRenderSize is zero.");
// //       return Offset.zero;
// //     }
// //     return Offset(
// //       relativeOffset.dx * actualStackBoardRenderSize.value.width,
// //       relativeOffset.dy * actualStackBoardRenderSize.value.height,
// //     );
// //   }

// //   Offset getRelativeOffsetFromAbsolute(Offset absoluteOffset) {
// //     if (templateOriginalWidth.value == 0 || templateOriginalHeight.value == 0) {
// //       debugPrint("Warning: templateOriginalSize is zero.");
// //       return Offset.zero;
// //     }
// //     return Offset(
// //       absoluteOffset.dx / templateOriginalWidth.value,
// //       absoluteOffset.dy / templateOriginalHeight.value,
// //     );
// //   }

// //   Offset getCenteredOffset(Size itemSize, {double? existingDy}) {
// //     if (actualStackBoardRenderSize.value == Size.zero) {
// //       debugPrint("Warning: actualStackBoardRenderSize is zero for centering.");
// //       return Offset(0, existingDy ?? 0);
// //     }
// //     final double centerX =
// //         (actualStackBoardRenderSize.value.width - itemSize.width) / 2;
// //     return Offset(
// //       centerX.clamp(
// //         0.0,
// //         actualStackBoardRenderSize.value.width - itemSize.width,
// //       ),
// //       existingDy ?? 0.0,
// //     );
// //   }

// //   StackItem<StackItemContent> _deserializeItem(Map<String, dynamic> json) {
// //     try {
// //       if (json['type'] == 'StackTextItem') {
// //         return StackTextItem.fromJson(json);
// //       } else if (json['type'] == 'StackImageItem') {
// //         return StackImageItem.fromJson(json);
// //       } else if (json['type'] == 'ColorStackItem1') {
// //         return ColorStackItem1.fromJson(json);
// //       } else {
// //         throw Exception('Unknown item type: ${json['type']}');
// //       }
// //     } catch (e) {
// //       debugPrint('Error deserializing item: $e');
// //       rethrow;
// //     }
// //   }

// //   void loadTemplate(CardTemplate template) async {
// //     selectedBackground.value = template.backgroundImage;
// //     templateName.value = template.name;
// //     category.value = template.category;
// //     categoryId.value = template.categoryId;
// //     tags.value = template.tags;
// //     isPremium.value = template.isPremium;
// //     boardController.clear();

// //     final List<StackItem<StackItemContent>> itemsToLoad = [];

// //     for (final itemJson in template.items) {
// //       try {
// //         final item = _deserializeItem(itemJson);
// //         itemsToLoad.add(item);
// //       } catch (e) {
// //         debugPrint("Error loading item: $e");
// //         Get.snackbar(
// //           'Error',
// //           'Failed to load item: $e',
// //           snackPosition: SnackPosition.BOTTOM,
// //         );
// //       }
// //     }

// //     SchedulerBinding.instance.addPostFrameCallback((_) async {
// //       for (final item in itemsToLoad) {
// //         Offset calculatedOffset;
// //         if (item is StackTextItem) {
// //           if (item.isCentered == true) {
// //             calculatedOffset = getCenteredOffset(
// //               item.size,
// //               existingDy: item.offset.dy,
// //             );
// //           } else if (item.originalRelativeOffset != null) {
// //             calculatedOffset = _getAbsoluteOffsetFromRelative(
// //               item.originalRelativeOffset!,
// //               item.size,
// //             );
// //           } else {
// //             calculatedOffset = item.offset;
// //           }
// //         } else {
// //           calculatedOffset = item.offset;
// //         }
// //         boardController.addItem(item.copyWith(offset: calculatedOffset));
// //       }
// //       _updateSpatialIndex();

// //       //to make the items dased border visible for a second
// //       draggedItem.value = itemsToLoad.last;

// //       await Future.delayed(Duration(milliseconds: 1000));
// //       draggedItem.value = null;

// //       boardController.setAllItemStatuses(StackItemStatus.idle);
// //     });
// //   }

// //   Future<void> deleteItem(StackItem<StackItemContent> item) async {
// //     final confirm = await Get.dialog<bool>(
// //       AlertDialog(
// //         title: const Text('Confirm Delete'),
// //         content: const Text('Are you sure you want to delete this item?'),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Get.back(result: false),
// //             child: const Text('No'),
// //           ),
// //           TextButton(
// //             onPressed: () => Get.back(result: true),
// //             child: const Text('Yes'),
// //           ),
// //         ],
// //       ),
// //     );
// //     if (confirm == true) {
// //       _undoStack.add(_ItemState(item: item, action: _ItemAction.delete));
// //       _redoStack.clear();
// //       boardController.removeById(item.id);
// //       if (activeItem.value?.id == item.id) {
// //         activeItem.value = null;
// //       }
// //       _updateSpatialIndex();
// //     }
// //   }

// //   void toggleGrid() {
// //     showGrid.value = !showGrid.value;
// //   }

// //   void undo() {
// //     if (_undoStack.isEmpty) return;
// //     final state = _undoStack.removeLast();
// //     switch (state.action) {
// //       case _ItemAction.add:
// //         boardController.removeById(state.item.id);
// //         _redoStack.add(state);
// //         if (activeItem.value?.id == state.item.id) {
// //           activeItem.value = null;
// //         }
// //         break;
// //       case _ItemAction.update:
// //         final List<Map<String, dynamic>> allItems = boardController
// //             .getAllData();
// //         final currentItemJson = allItems.firstWhere(
// //           (json) => json['id'] == state.item.id,
// //           orElse: () => throw Exception('Item ${state.item.id} not found'),
// //         );
// //         final currentItem = _deserializeItem(currentItemJson);
// //         _redoStack.add(
// //           _ItemState(item: currentItem, action: _ItemAction.update),
// //         );
// //         boardController.updateItem(state.item);
// //         activeItem.value = state.item;
// //         break;
// //       case _ItemAction.delete:
// //         boardController.addItem(state.item);
// //         _redoStack.add(state);
// //         activeItem.value = state.item;
// //         break;
// //     }
// //     _updateSpatialIndex();
// //   }

// //   void redo() {
// //     if (_redoStack.isEmpty) return;
// //     final state = _redoStack.removeLast();
// //     switch (state.action) {
// //       case _ItemAction.add:
// //         boardController.addItem(state.item);
// //         _undoStack.add(state);
// //         activeItem.value = state.item;
// //         break;
// //       case _ItemAction.update:
// //         final List<Map<String, dynamic>> allItems = boardController
// //             .getAllData();
// //         final currentItemJson = allItems.firstWhere(
// //           (json) => json['id'] == state.item.id,
// //           orElse: () => throw Exception('Item ${state.item.id} not found'),
// //         );
// //         final currentItem = _deserializeItem(currentItemJson);
// //         _undoStack.add(
// //           _ItemState(item: currentItem, action: _ItemAction.update),
// //         );
// //         boardController.updateItem(state.item);
// //         activeItem.value = state.item;
// //         break;
// //       case _ItemAction.delete:
// //         boardController.removeById(state.item.id);
// //         _undoStack.add(state);
// //         if (activeItem.value?.id == state.item.id) {
// //           activeItem.value = null;
// //         }
// //         break;
// //     }
// //     _updateSpatialIndex();
// //   }

// //   void onItemOffsetChanged(StackItem item, Offset offset) {
// //     if (draggedItem.value?.id != item.id) return;

// //     if (_dragStart == null) {
// //       _dragStart = offset;
// //       _lastOffset = offset;
// //       draggedItem.value = item.copyWith(offset: offset);
// //       _debounceCalculateAlignmentPoints(item, offset);
// //       return;
// //     }

// //     final double distance = (offset - _dragStart!).distance;
// //     if (distance < _dragThreshold && _lastOffset != null) {
// //       draggedItem.value = item.copyWith(offset: _lastOffset!);
// //       return;
// //     }

// //     _lastOffset = offset;
// //     draggedItem.value = item.copyWith(offset: offset);
// //     _debounceCalculateAlignmentPoints(item, offset);
// //   }

// //   void onItemStatusChanged(StackItem item, StackItemStatus status) {
// //     if (status == StackItemStatus.moving) {
// //       draggedItem.value = item;
// //       activeItem.value = item;
// //       _dragStart = null;
// //       _lastOffset = null;
// //       _debounceCalculateAlignmentPoints(item, item.offset);
// //     } else if (status == StackItemStatus.selected) {
// //       activeItem.value = item;
// //       draggedItem.value = null;
// //       _dragStart = null;
// //       _lastOffset = null;
// //       alignmentPoints.value = [];
// //     } else if (status == StackItemStatus.idle) {
// //       if (draggedItem.value?.id == item.id) {
// //         final snapResult = _findClosestSnapPoints(item, item.offset);
// //         if (snapResult.snappedOffset != item.offset) {
// //           _undoStack.add(_ItemState(item: item, action: _ItemAction.update));
// //           _redoStack.clear();
// //           boardController.updateItem(
// //             item.copyWith(offset: snapResult.snappedOffset),
// //           );
// //           final isCriticalSnap = snapResult.points.any((p) => p.isCriticalSnap);
// //           if (isCriticalSnap) {
// //             HapticFeedback.heavyImpact();
// //           } else if (snapResult.points.any((p) => p.isSnapped)) {
// //             HapticFeedback.lightImpact();
// //           }
// //           activeItem.value = item.copyWith(offset: snapResult.snappedOffset);
// //         }
// //         draggedItem.value = null;
// //         _dragStart = null;
// //         _lastOffset = null;
// //         alignmentPoints.value = [];
// //       } else if (activeItem.value?.id == item.id) {
// //         activeItem.value = null;
// //         alignmentPoints.value = [];
// //       }
// //     }
// //   }

// //   void _debounceCalculateAlignmentPoints(StackItem item, Offset offset) {
// //     Future.delayed(const Duration(milliseconds: 16), () {
// //       if (draggedItem.value?.id == item.id) {
// //         final snapResult = _findClosestSnapPoints(item, offset);
// //         alignmentPoints.value = snapResult.points;
// //       } else {
// //         alignmentPoints.value = [];
// //       }
// //     });
// //   }

// //   _SnapResult _findClosestSnapPoints(StackItem item, Offset offset) {
// //     const double snapThreshold = 5.0;
// //     const double criticalSnapThreshold = 2.0;
// //     final List<AlignmentPoint> points = [];
// //     double? closestX, closestY;
// //     double minXDistance = double.infinity;
// //     double minYDistance = double.infinity;
// //     bool isCriticalXSnap = false;
// //     bool isCriticalYSnap = false;

// //     final draggedRect = Rect.fromLTWH(
// //       offset.dx,
// //       offset.dy,
// //       item.size.width,
// //       item.size.height,
// //     );

// //     final double itemMidX = draggedRect.center.dx;
// //     final double itemMidY = draggedRect.center.dy;
// //     final Map<double, SnapType> verticalPoints = {};
// //     final Map<double, SnapType> horizontalPoints = {};

// //     // Canvas critical points (centerlines and edges)
// //     final double centerX = actualStackBoardRenderSize.value.width / 2;
// //     final double centerY = actualStackBoardRenderSize.value.height / 2;
// //     final List<double> canvasVerticals = [
// //       0,
// //       centerX,
// //       actualStackBoardRenderSize.value.width,
// //     ];
// //     final List<double> canvasHorizontals = [
// //       0,
// //       centerY,
// //       actualStackBoardRenderSize.value.height,
// //     ];

// //     // Check canvas critical points
// //     for (final x in canvasVerticals) {
// //       final leftDistance = (draggedRect.left - x).abs();
// //       final rightDistance = (draggedRect.right - x).abs();
// //       final centerDistance = (itemMidX - x).abs();

// //       if (centerDistance < criticalSnapThreshold &&
// //           centerDistance < minXDistance) {
// //         verticalPoints[x] = SnapType.centerCritical;
// //         closestX = x - item.size.width / 2;
// //         minXDistance = centerDistance;
// //         isCriticalXSnap = true;
// //       } else if (leftDistance < criticalSnapThreshold &&
// //           leftDistance < minXDistance) {
// //         verticalPoints[x] = SnapType.edgeCritical;
// //         closestX = x;
// //         minXDistance = leftDistance;
// //         isCriticalXSnap = true;
// //       } else if (rightDistance < criticalSnapThreshold &&
// //           rightDistance < minXDistance) {
// //         verticalPoints[x] = SnapType.edgeCritical;
// //         closestX = x - item.size.width;
// //         minXDistance = rightDistance;
// //         isCriticalXSnap = true;
// //       } else {
// //         verticalPoints[x] = SnapType.inactive;
// //       }
// //     }

// //     for (final y in canvasHorizontals) {
// //       final topDistance = (draggedRect.top - y).abs();
// //       final bottomDistance = (draggedRect.bottom - y).abs();
// //       final centerDistance = (itemMidY - y).abs();

// //       if (centerDistance < criticalSnapThreshold &&
// //           centerDistance < minYDistance) {
// //         horizontalPoints[y] = SnapType.centerCritical;
// //         closestY = y - item.size.height / 2;
// //         minYDistance = centerDistance;
// //         isCriticalYSnap = true;
// //       } else if (topDistance < criticalSnapThreshold &&
// //           topDistance < minYDistance) {
// //         horizontalPoints[y] = SnapType.edgeCritical;
// //         closestY = y;
// //         minYDistance = topDistance;
// //         isCriticalYSnap = true;
// //       } else if (bottomDistance < criticalSnapThreshold &&
// //           bottomDistance < minYDistance) {
// //         horizontalPoints[y] = SnapType.edgeCritical;
// //         closestY = y - item.size.height;
// //         minYDistance = bottomDistance;
// //         isCriticalYSnap = true;
// //       } else {
// //         horizontalPoints[y] = SnapType.inactive;
// //       }
// //     }

// //     // Nearby items snapping
// //     final spatialIndex = _spatialIndex;
// //     final nearbyItems = spatialIndex.getNearbyItems(draggedRect.center);

// //     for (final otherItem in nearbyItems) {
// //       final itemRect = Rect.fromLTWH(
// //         otherItem.offset.dx,
// //         otherItem.offset.dy,
// //         otherItem.size.width,
// //         otherItem.size.height,
// //       );

// //       final verticalEdges = [itemRect.left, itemRect.center.dx, itemRect.right];
// //       final horizontalEdges = [
// //         itemRect.top,
// //         itemRect.center.dy,
// //         itemRect.bottom,
// //       ];

// //       for (final x in verticalEdges) {
// //         final leftDistance = (draggedRect.left - x).abs();
// //         final rightDistance = (draggedRect.right - x).abs();
// //         final centerDistance = (itemMidX - x).abs();

// //         if (centerDistance < snapThreshold &&
// //             centerDistance < minXDistance &&
// //             !isCriticalXSnap) {
// //           verticalPoints[x] = SnapType.center;
// //           closestX = x - item.size.width / 2;
// //           minXDistance = centerDistance;
// //         } else if (leftDistance < snapThreshold &&
// //             leftDistance < minXDistance &&
// //             !isCriticalXSnap) {
// //           verticalPoints[x] = SnapType.edge;
// //           closestX = x;
// //           minXDistance = leftDistance;
// //         } else if (rightDistance < snapThreshold &&
// //             rightDistance < minXDistance &&
// //             !isCriticalXSnap) {
// //           verticalPoints[x] = SnapType.edge;
// //           closestX = x - item.size.width;
// //           minXDistance = rightDistance;
// //         } else {
// //           verticalPoints.putIfAbsent(x, () => SnapType.inactive);
// //         }
// //       }

// //       for (final y in horizontalEdges) {
// //         final topDistance = (draggedRect.top - y).abs();
// //         final bottomDistance = (draggedRect.bottom - y).abs();
// //         final centerDistance = (itemMidY - y).abs();

// //         if (centerDistance < snapThreshold &&
// //             centerDistance < minYDistance &&
// //             !isCriticalYSnap) {
// //           horizontalPoints[y] = SnapType.center;
// //           closestY = y - item.size.height / 2;
// //           minYDistance = centerDistance;
// //         } else if (topDistance < snapThreshold &&
// //             topDistance < minYDistance &&
// //             !isCriticalYSnap) {
// //           horizontalPoints[y] = SnapType.edge;
// //           closestY = y;
// //           minYDistance = topDistance;
// //         } else if (bottomDistance < snapThreshold &&
// //             bottomDistance < minYDistance &&
// //             !isCriticalYSnap) {
// //           horizontalPoints[y] = SnapType.edge;
// //           closestY = y - item.size.height;
// //           minYDistance = bottomDistance;
// //         } else {
// //           horizontalPoints.putIfAbsent(y, () => SnapType.inactive);
// //         }
// //       }
// //     }

// //     // Select up to 3 points per axis, prioritizing snapped and critical points
// //     final sortedVertical = verticalPoints.entries
// //         .toList()
// //         .sorted((a, b) => a.key.compareTo(b.key))
// //         .where((e) => e.value != SnapType.inactive)
// //         .take(3)
// //         .map(
// //           (e) => AlignmentPoint(
// //             value: (e.key * 100).roundToDouble() / 100,
// //             isVertical: true,
// //             snapType: e.value,
// //           ),
// //         )
// //         .toList();

// //     final sortedHorizontal = horizontalPoints.entries
// //         .toList()
// //         .sorted((a, b) => a.key.compareTo(b.key))
// //         .where((e) => e.value != SnapType.inactive)
// //         .take(3)
// //         .map(
// //           (e) => AlignmentPoint(
// //             value: (e.key * 100).roundToDouble() / 100,
// //             isVertical: false,
// //             snapType: e.value,
// //           ),
// //         )
// //         .toList();

// //     points.addAll(sortedVertical);
// //     points.addAll(sortedHorizontal);

// //     final snappedOffset = Offset(closestX ?? offset.dx, closestY ?? offset.dy);

// //     return _SnapResult(points: points, snappedOffset: snappedOffset);
// //   }

// //   // Spatial index
// //   _SpatialIndex _spatialIndex = _SpatialIndex();

// //   void _updateSpatialIndex() {
// //     _spatialIndex = _SpatialIndex();
// //     final allItems = boardController.getAllData();
// //     for (final itemJson in allItems) {
// //       if (itemJson['id'] != draggedItem.value?.id) {
// //         try {
// //           final item = _deserializeItem(itemJson);
// //           _spatialIndex.addItem(item);
// //         } catch (e) {
// //           debugPrint('Error adding item to spatial index: $e');
// //         }
// //       }
// //     }
// //   }

// //   @override
// //   void onClose() {
// //     boardController.dispose();
// //     super.onClose();
// //   }
// // }

// // class _SnapResult {
// //   final List<AlignmentPoint> points;
// //   final Offset snappedOffset;

// //   _SnapResult({required this.points, required this.snappedOffset});
// // }

// // class _SpatialIndex {
// //   final Map<int, List<StackItem>> _buckets = {};
// //   static const double bucketSize = 30.0;

// //   void addItem(StackItem item) {
// //     final double centerX = item.offset.dx + item.size.width / 2;
// //     final double centerY = item.offset.dy + item.size.height / 2;
// //     final int bucketX = (centerX / bucketSize).floor();
// //     final int bucketY = (centerY / bucketSize).floor();
// //     final int key = bucketX * 10000 + bucketY;
// //     _buckets.putIfAbsent(key, () => []).add(item);
// //   }

// //   List<StackItem> getNearbyItems(Offset center) {
// //     const double maxDistance = 150.0;
// //     final int centerBucketX = (center.dx / bucketSize).floor();
// //     final int centerBucketY = (center.dy / bucketSize).floor();
// //     final List<StackItem> nearbyItems = [];

// //     for (int dx = -2; dx <= 2; dx++) {
// //       for (int dy = -2; dy <= 2; dy++) {
// //         final int bucketX = centerBucketX + dx;
// //         final int bucketY = centerBucketY + dy;
// //         final int key = bucketX * 10000 + bucketY;
// //         final items = _buckets[key] ?? [];
// //         for (final item in items) {
// //           final itemCenter = Offset(
// //             item.offset.dx + item.size.width / 2,
// //             item.offset.dy + item.size.height / 2,
// //           );
// //           if ((center - itemCenter).distance < maxDistance) {
// //             nearbyItems.add(item);
// //           }
// //         }
// //       }
// //     }
// //     return nearbyItems;
// //   }
// // }

// // class _ItemState {
// //   final StackItem item;
// //   final _ItemAction action;

// //   _ItemState({required this.item, required this.action});
// // }

// // enum _ItemAction { add, update, delete }

// // enum AlignmentOption { center, left, right, top, bottom }

// // enum SnapType { inactive, edge, center, edgeCritical, centerCritical }

// // class AlignmentPoint {
// //   final double value;
// //   final bool isVertical;
// //   final SnapType snapType;

// //   AlignmentPoint({
// //     required this.value,
// //     required this.isVertical,
// //     required this.snapType,
// //   });

// //   bool get isSnapped => snapType != SnapType.inactive;
// //   bool get isCriticalSnap =>
// //       snapType == SnapType.edgeCritical || snapType == SnapType.centerCritical;

// //   @override
// //   bool operator ==(Object other) =>
// //       identical(this, other) ||
// //       other is AlignmentPoint &&
// //           value == other.value &&
// //           isVertical == other.isVertical &&
// //           snapType == other.snapType;

// //   @override
// //   int get hashCode => Object.hash(value, isVertical, snapType);
// // }

// // extension IterableExtension<T> on Iterable<T> {
// //   List<T> sorted(int Function(T, T) compare) {
// //     final list = toList();
// //     list.sort(compare);
// //     return list;
// //   }
// // }
// import 'dart:math' as math;

// import 'package:cardmaker/app/features/editor/editor_canvas.dart';
// import 'package:cardmaker/models/card_template.dart';
// import 'package:cardmaker/stack_board/lib/flutter_stack_board.dart';
// import 'package:cardmaker/stack_board/lib/stack_board_item.dart';
// import 'package:cardmaker/stack_board/lib/stack_items.dart'
//     hide ColorStackItem1;
// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';

// class EditorController extends GetxController {
//   final StackBoardController boardController = StackBoardController();
//   final RxString selectedFont = 'Poppins'.obs;
//   final RxDouble fontSize = 24.0.obs;
//   final Rx<Color> fontColor = Colors.black.obs;
//   final RxString selectedBackground = ''.obs;
//   final RxDouble backgroundHue = 0.0.obs; // New: Hue for background
//   final RxString templateName = ''.obs;

//   final RxDouble templateOriginalWidth = 0.0.obs;
//   final RxDouble templateOriginalHeight = 0.0.obs;
//   final Rx<Size> actualStackBoardRenderSize = Size.zero.obs;

//   final RxString category = 'general'.obs;
//   final RxString categoryId = 'general'.obs;
//   final RxList<String> tags = <String>[].obs;
//   final RxBool isPremium = false.obs;
//   CardTemplate? initialTemplate;

//   final RxDouble canvasWidth = 0.0.obs;
//   final RxDouble canvasHeight = 0.0.obs;

//   final Rx<StackItem?> draggedItem = Rx<StackItem?>(null);
//   Rx<StackItem?> activeItem = Rx<StackItem?>(null);
//   final RxList<AlignmentPoint> alignmentPoints = <AlignmentPoint>[].obs;
//   final RxBool showGrid = true.obs;
//   final RxDouble gridSize = 20.0.obs;
//   final Rx<Color> guideColor = Colors.black.obs;
//   final Rx<OverlayEntry?> activeTextEditorOverlay = Rx<OverlayEntry?>(null);

//   // Undo/Redo stacks
//   final RxList<_ItemState> _undoStack = <_ItemState>[].obs;
//   final RxList<_ItemState> _redoStack = <_ItemState>[].obs;

//   // Drag threshold tracking
//   Offset? _dragStart;
//   Offset? _lastOffset;
//   static const double _dragThreshold = 5.0;
//   final RxBool showHueSlider = false.obs;
//   final RxBool showStickerPanel = false.obs;
//   final RxInt selectedToolIndex =
//       0.obs; // 0: none, 1: sticker, 2: color, 3: text

//   @override
//   void onInit() {
//     super.onInit();
//     initialTemplate = Get.arguments as CardTemplate?;
//     if (initialTemplate != null) {
//       templateOriginalWidth.value = initialTemplate!.width;
//       templateOriginalHeight.value = initialTemplate!.height;
//       canvasWidth.value = initialTemplate!.width;
//       canvasHeight.value = initialTemplate!.height;
//     }
//   }

//   @override
//   void onReady() {
//     super.onReady();
//     if (initialTemplate != null) {
//       loadTemplate(initialTemplate!);
//     }
//   }

//   void updateStackBoardRenderSize(Size size) {
//     if (actualStackBoardRenderSize.value != size) {
//       actualStackBoardRenderSize.value = size;
//       _updateGridSize();
//     }
//   }

//   void removeTextEditorOverlay() {
//     final entry = activeTextEditorOverlay.value;
//     if (entry != null && entry.mounted) {
//       entry.remove();
//       activeTextEditorOverlay.value = null;
//     }
//   }

//   void _updateGridSize() {
//     if (actualStackBoardRenderSize.value == Size.zero) return;

//     final double width = actualStackBoardRenderSize.value.width;
//     final double height = actualStackBoardRenderSize.value.height;
//     const int divisions = 20;
//     double newGridSize = math.min(width, height) / divisions;

//     newGridSize = math.max(15.0, newGridSize);
//     while (width % newGridSize != 0 || height % newGridSize != 0) {
//       newGridSize = (newGridSize / 2).floorToDouble();
//       if (newGridSize < 15.0) {
//         newGridSize = 15.0;
//         break;
//       }
//     }

//     gridSize.value = newGridSize;
//   }

//   Offset _getAbsoluteOffsetFromRelative(Offset relativeOffset, Size itemSize) {
//     if (actualStackBoardRenderSize.value == Size.zero) {
//       debugPrint("Warning: actualStackBoardRenderSize is zero.");
//       return Offset.zero;
//     }
//     return Offset(
//       relativeOffset.dx * actualStackBoardRenderSize.value.width,
//       relativeOffset.dy * actualStackBoardRenderSize.value.height,
//     );
//   }

//   Offset getRelativeOffsetFromAbsolute(Offset absoluteOffset) {
//     if (templateOriginalWidth.value == 0 || templateOriginalHeight.value == 0) {
//       debugPrint("Warning: templateOriginalSize is zero.");
//       return Offset.zero;
//     }
//     return Offset(
//       absoluteOffset.dx / templateOriginalWidth.value,
//       absoluteOffset.dy / templateOriginalHeight.value,
//     );
//   }

//   Offset getCenteredOffset(Size itemSize, {double? existingDy}) {
//     if (actualStackBoardRenderSize.value == Size.zero) {
//       debugPrint("Warning: actualStackBoardRenderSize is zero for centering.");
//       return Offset(0, existingDy ?? 0);
//     }
//     final double centerX =
//         (actualStackBoardRenderSize.value.width - itemSize.width) / 2;
//     return Offset(
//       centerX.clamp(
//         0.0,
//         actualStackBoardRenderSize.value.width - itemSize.width,
//       ),
//       existingDy ?? 0.0,
//     );
//   }

//   StackItem<StackItemContent> _deserializeItem(Map<String, dynamic> json) {
//     try {
//       if (json['type'] == 'StackTextItem') {
//         return StackTextItem.fromJson(json);
//       } else if (json['type'] == 'StackImageItem') {
//         return StackImageItem.fromJson(json);
//       } else if (json['type'] == 'ColorStackItem1') {
//         return ColorStackItem1.fromJson(json);
//       } else {
//         throw Exception('Unknown item type: ${json['type']}');
//       }
//     } catch (e) {
//       debugPrint('Error deserializing item: $e');
//       rethrow;
//     }
//   }

//   void loadTemplate(CardTemplate template) async {
//     print("Loading template: ${template.toJson()}");
//     selectedBackground.value = template.backgroundImage;
//     templateName.value = template.name;
//     category.value = template.category;
//     categoryId.value = template.categoryId;
//     tags.value = template.tags;
//     isPremium.value = template.isPremium;
//     backgroundHue.value = 0.0; // Reset hue
//     boardController.clear();

//     final List<StackItem<StackItemContent>> itemsToLoad = [];

//     for (final itemJson in template.items) {
//       try {
//         final item = _deserializeItem(itemJson);
//         itemsToLoad.add(item);
//       } catch (e) {
//         debugPrint("Error loading item: $e");
//         Get.snackbar(
//           'Error',
//           'Failed to load item: $e',
//           snackPosition: SnackPosition.BOTTOM,
//         );
//       }
//     }

//     SchedulerBinding.instance.addPostFrameCallback((_) async {
//       for (final item in itemsToLoad) {
//         Offset calculatedOffset;
//         if (item is StackTextItem) {
//           if (item.isCentered == true) {
//             calculatedOffset = getCenteredOffset(
//               item.size,
//               existingDy: item.offset.dy,
//             );
//           } else if (item.originalRelativeOffset != null) {
//             calculatedOffset = _getAbsoluteOffsetFromRelative(
//               item.originalRelativeOffset!,
//               item.size,
//             );
//           } else {
//             calculatedOffset = item.offset;
//           }
//         } else {
//           calculatedOffset = item.offset;
//         }
//         final newItem = item.copyWith(offset: calculatedOffset);
//         boardController.addItem(newItem);
//         _undoStack.add(_ItemState(item: newItem, action: _ItemAction.add));
//       }
//       _updateSpatialIndex();

//       draggedItem.value = itemsToLoad.isNotEmpty ? itemsToLoad.last : null;
//       await Future.delayed(Duration(milliseconds: 1000));
//       draggedItem.value = null;

//       boardController.setAllItemStatuses(StackItemStatus.idle);
//     });
//   }

//   Future<void> deleteItem(StackItem<StackItemContent> item) async {
//     final confirm = await Get.dialog<bool>(
//       AlertDialog(
//         title: const Text('Confirm Delete'),
//         content: const Text('Are you sure you want to delete this item?'),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(result: false),
//             child: const Text('No'),
//           ),
//           TextButton(
//             onPressed: () => Get.back(result: true),
//             child: const Text('Yes'),
//           ),
//         ],
//       ),
//     );
//     if (confirm == true) {
//       _undoStack.add(_ItemState(item: item, action: _ItemAction.delete));
//       _redoStack.clear();
//       boardController.removeById(item.id);
//       if (activeItem.value?.id == item.id) {
//         activeItem.value = null;
//       }
//       _updateSpatialIndex();
//     }
//   }

//   void addSticker(String imagePath) {
//     final sticker = StackImageItem(
//       id: UniqueKey().toString(),
//       size: const Size(100, 100),
//       offset: getCenteredOffset(const Size(100, 100)),
//       content: ImageItemContent(assetName: imagePath),
//     );
//     boardController.addItem(sticker);
//     _undoStack.add(_ItemState(item: sticker, action: _ItemAction.add));
//     _redoStack.clear();
//     _updateSpatialIndex();
//   }

//   void addText(String data, {Size? size}) {
//     final textItem = StackTextItem(
//       id: UniqueKey().toString(),
//       size: size ?? const Size(200, 50),
//       offset: _getAbsoluteOffsetFromRelative(
//         Offset(0.5, 0.5),
//         size ?? const Size(200, 50),
//       ),
//       content: TextItemContent(
//         data: data,
//         googleFont: 'Roboto',
//         style: const TextStyle(fontSize: 24, color: Colors.black),
//         textAlign: TextAlign.center,
//       ),
//     );
//     boardController.addItem(textItem);
//     _undoStack.add(_ItemState(item: textItem, action: _ItemAction.add));
//     _redoStack.clear();
//     _updateSpatialIndex();
//     activeItem.value = textItem;
//   }

//   void updateBackgroundHue(double hue) {
//     final previousHue = backgroundHue.value;
//     _undoStack.add(
//       _ItemState(
//         item: ColorStackItem1(
//           id: 'background_hue',
//           size: Size.zero,
//           content: ColorContent(
//             color: Colors.transparent,
//           ), // Dummy item for hue
//         ),
//         action: _ItemAction.hue,
//         previousHue: previousHue,
//       ),
//     );
//     _redoStack.clear();
//     backgroundHue.value = hue;
//   }

//   void toggleGrid() {
//     showGrid.value = !showGrid.value;
//   }

//   void undo() {
//     if (_undoStack.isEmpty) return;
//     final state = _undoStack.removeLast();
//     switch (state.action) {
//       case _ItemAction.add:
//         boardController.removeById(state.item.id);
//         _redoStack.add(state);
//         if (activeItem.value?.id == state.item.id) {
//           activeItem.value = null;
//         }
//         break;
//       case _ItemAction.update:
//         final currentItemJson = boardController.getAllData().firstWhere(
//           (json) => json['id'] == state.item.id,
//           orElse: () => <String, dynamic>{},
//         );
//         if (currentItemJson.isNotEmpty) {
//           final currentItem = _deserializeItem(currentItemJson);
//           _redoStack.add(
//             _ItemState(item: currentItem, action: _ItemAction.update),
//           );
//           boardController.updateItem(state.item);
//           activeItem.value = state.item;
//         }
//         break;
//       case _ItemAction.delete:
//         boardController.addItem(state.item);
//         _redoStack.add(state);
//         activeItem.value = state.item;
//         break;
//       case _ItemAction.hue:
//         final previousHue = state.previousHue ?? 0.0;
//         _redoStack.add(
//           _ItemState(
//             item: state.item,
//             action: _ItemAction.hue,
//             previousHue: backgroundHue.value,
//           ),
//         );
//         backgroundHue.value = previousHue;
//         break;
//     }
//     _updateSpatialIndex();
//   }

//   void redo() {
//     if (_redoStack.isEmpty) return;
//     final state = _redoStack.removeLast();
//     switch (state.action) {
//       case _ItemAction.add:
//         boardController.addItem(state.item);
//         _undoStack.add(state);
//         activeItem.value = state.item;
//         break;
//       case _ItemAction.update:
//         final currentItemJson = boardController.getAllData().firstWhere(
//           (json) => json['id'] == state.item.id,
//           orElse: () => <String, dynamic>{},
//         );
//         if (currentItemJson.isNotEmpty) {
//           final currentItem = _deserializeItem(currentItemJson);
//           _undoStack.add(
//             _ItemState(item: currentItem, action: _ItemAction.update),
//           );
//           boardController.updateItem(state.item);
//           activeItem.value = state.item;
//         }
//         break;
//       case _ItemAction.delete:
//         boardController.removeById(state.item.id);
//         _undoStack.add(state);
//         if (activeItem.value?.id == state.item.id) {
//           activeItem.value = null;
//         }
//         break;
//       case _ItemAction.hue:
//         final previousHue = state.previousHue ?? 0.0;
//         _undoStack.add(
//           _ItemState(
//             item: state.item,
//             action: _ItemAction.hue,
//             previousHue: backgroundHue.value,
//           ),
//         );
//         backgroundHue.value = previousHue;
//         break;
//     }
//     _updateSpatialIndex();
//   }

//   void onItemOffsetChanged(StackItem item, Offset offset) {
//     if (draggedItem.value?.id != item.id) return;

//     if (_dragStart == null) {
//       _dragStart = offset;
//       _lastOffset = offset;
//       draggedItem.value = item.copyWith(offset: offset);
//       _debounceCalculateAlignmentPoints(item, offset);
//       return;
//     }

//     final double distance = (offset - _dragStart!).distance;
//     if (distance < _dragThreshold && _lastOffset != null) {
//       draggedItem.value = item.copyWith(offset: _lastOffset!);
//       return;
//     }

//     _lastOffset = offset;
//     draggedItem.value = item.copyWith(offset: offset);
//     _debounceCalculateAlignmentPoints(item, offset);
//   }

//   void onItemSizeChanged(StackItem item, Size newSize) {
//     final currentItemJson = boardController.getAllData().firstWhere(
//       (json) => json['id'] == item.id,
//       orElse: () => <String, dynamic>{},
//     );
//     if (currentItemJson.isEmpty) return;

//     final previousItem = _deserializeItem(currentItemJson);
//     _undoStack.add(_ItemState(item: previousItem, action: _ItemAction.update));
//     _redoStack.clear();

//     if (item is StackTextItem && item.content != null) {
//       final currentFontSize = item.content!.style?.fontSize ?? 24.0;
//       final scaleFactor = math.min(
//         newSize.width / item.size.width,
//         newSize.height / item.size.height,
//       );
//       final newFontSize = (currentFontSize * scaleFactor).clamp(8.0, 72.0);

//       final updatedContent = item.content!.copyWith(
//         style: item.content!.style?.copyWith(fontSize: newFontSize),
//       );

//       final updatedItem = item.copyWith(size: newSize, content: updatedContent);
//       boardController.updateItem(updatedItem);
//       activeItem.value = updatedItem;
//     } else {
//       final updatedItem = item.copyWith(size: newSize);
//       boardController.updateItem(updatedItem);
//       activeItem.value = updatedItem;
//     }
//     _updateSpatialIndex();
//   }

//   void onItemStatusChanged(StackItem item, StackItemStatus status) {
//     if (status == StackItemStatus.moving) {
//       draggedItem.value = item;
//       activeItem.value = item;
//       _dragStart = null;
//       _lastOffset = null;
//       _debounceCalculateAlignmentPoints(item, item.offset);
//     } else if (status == StackItemStatus.selected) {
//       activeItem.value = item;
//       draggedItem.value = null;
//       _dragStart = null;
//       _lastOffset = null;
//       alignmentPoints.value = [];
//     } else if (status == StackItemStatus.idle) {
//       if (draggedItem.value?.id == item.id) {
//         final snapResult = _findClosestSnapPoints(item, item.offset);
//         if (snapResult.snappedOffset != item.offset) {
//           _undoStack.add(_ItemState(item: item, action: _ItemAction.update));
//           _redoStack.clear();
//           boardController.updateItem(
//             item.copyWith(offset: snapResult.snappedOffset),
//           );
//           final isCriticalSnap = snapResult.points.any((p) => p.isCriticalSnap);
//           if (isCriticalSnap) {
//             HapticFeedback.heavyImpact();
//           } else if (snapResult.points.any((p) => p.isSnapped)) {
//             HapticFeedback.lightImpact();
//           }
//           activeItem.value = item.copyWith(offset: snapResult.snappedOffset);
//         }
//         draggedItem.value = null;
//         _dragStart = null;
//         _lastOffset = null;
//         alignmentPoints.value = [];
//       } else if (activeItem.value?.id == item.id) {
//         activeItem.value = null;
//         alignmentPoints.value = [];
//       }
//     }
//   }

//   void updateTextItem(
//     StackTextItem item,
//     StackItemContent content, {
//     Size? newSize,
//   }) {
//     final currentItemJson = boardController.getAllData().firstWhere(
//       (json) => json['id'] == item.id,
//       orElse: () => <String, dynamic>{},
//     );
//     if (currentItemJson.isNotEmpty) {
//       final previousItem = _deserializeItem(currentItemJson);
//       _undoStack.add(
//         _ItemState(item: previousItem, action: _ItemAction.update),
//       );
//       _redoStack.clear();
//       final updatedItem = item.copyWith(
//         content: content as TextItemContent,
//         size: newSize ?? item.size,
//       );
//       boardController.updateItem(updatedItem);
//       activeItem.value = updatedItem;
//       _updateSpatialIndex();
//     }
//   }

//   void _debounceCalculateAlignmentPoints(StackItem item, Offset offset) {
//     Future.delayed(const Duration(milliseconds: 16), () {
//       if (draggedItem.value?.id == item.id) {
//         final snapResult = _findClosestSnapPoints(item, offset);
//         alignmentPoints.value = snapResult.points;
//       } else {
//         alignmentPoints.value = [];
//       }
//     });
//   }

//   _SnapResult _findClosestSnapPoints(StackItem item, Offset offset) {
//     const double snapThreshold = 5.0;
//     const double criticalSnapThreshold = 2.0;
//     final List<AlignmentPoint> points = [];
//     double? closestX, closestY;
//     double minXDistance = double.infinity;
//     double minYDistance = double.infinity;
//     bool isCriticalXSnap = false;
//     bool isCriticalYSnap = false;

//     final draggedRect = Rect.fromLTWH(
//       offset.dx,
//       offset.dy,
//       item.size.width,
//       item.size.height,
//     );

//     final double itemMidX = draggedRect.center.dx;
//     final double itemMidY = draggedRect.center.dy;
//     final Map<double, SnapType> verticalPoints = {};
//     final Map<double, SnapType> horizontalPoints = {};

//     final double centerX = actualStackBoardRenderSize.value.width / 2;
//     final double centerY = actualStackBoardRenderSize.value.height / 2;
//     final List<double> canvasVerticals = [
//       0,
//       centerX,
//       actualStackBoardRenderSize.value.width,
//     ];
//     final List<double> canvasHorizontals = [
//       0,
//       centerY,
//       actualStackBoardRenderSize.value.height,
//     ];

//     for (final x in canvasVerticals) {
//       final leftDistance = (draggedRect.left - x).abs();
//       final rightDistance = (draggedRect.right - x).abs();
//       final centerDistance = (itemMidX - x).abs();

//       if (centerDistance < criticalSnapThreshold &&
//           centerDistance < minXDistance) {
//         verticalPoints[x] = SnapType.centerCritical;
//         closestX = x - item.size.width / 2;
//         minXDistance = centerDistance;
//         isCriticalXSnap = true;
//       } else if (leftDistance < criticalSnapThreshold &&
//           leftDistance < minXDistance) {
//         verticalPoints[x] = SnapType.edgeCritical;
//         closestX = x;
//         minXDistance = leftDistance;
//         isCriticalXSnap = true;
//       } else if (rightDistance < criticalSnapThreshold &&
//           rightDistance < minXDistance) {
//         verticalPoints[x] = SnapType.edgeCritical;
//         closestX = x - item.size.width;
//         minXDistance = rightDistance;
//         isCriticalXSnap = true;
//       } else {
//         verticalPoints[x] = SnapType.inactive;
//       }
//     }

//     for (final y in canvasHorizontals) {
//       final topDistance = (draggedRect.top - y).abs();
//       final bottomDistance = (draggedRect.bottom - y).abs();
//       final centerDistance = (itemMidY - y).abs();

//       if (centerDistance < criticalSnapThreshold &&
//           centerDistance < minYDistance) {
//         horizontalPoints[y] = SnapType.centerCritical;
//         closestY = y - item.size.height / 2;
//         minYDistance = centerDistance;
//         isCriticalYSnap = true;
//       } else if (topDistance < criticalSnapThreshold &&
//           topDistance < minYDistance) {
//         horizontalPoints[y] = SnapType.edgeCritical;
//         closestY = y;
//         minYDistance = topDistance;
//         isCriticalYSnap = true;
//       } else if (bottomDistance < criticalSnapThreshold &&
//           bottomDistance < minYDistance) {
//         horizontalPoints[y] = SnapType.edgeCritical;
//         closestY = y - item.size.height;
//         minYDistance = bottomDistance;
//         isCriticalYSnap = true;
//       } else {
//         horizontalPoints[y] = SnapType.inactive;
//       }
//     }

//     final spatialIndex = _spatialIndex;
//     final nearbyItems = spatialIndex.getNearbyItems(draggedRect.center);

//     for (final otherItem in nearbyItems) {
//       final itemRect = Rect.fromLTWH(
//         otherItem.offset.dx,
//         otherItem.offset.dy,
//         otherItem.size.width,
//         otherItem.size.height,
//       );

//       final verticalEdges = [itemRect.left, itemRect.center.dx, itemRect.right];
//       final horizontalEdges = [
//         itemRect.top,
//         itemRect.center.dy,
//         itemRect.bottom,
//       ];

//       for (final x in verticalEdges) {
//         final leftDistance = (draggedRect.left - x).abs();
//         final rightDistance = (draggedRect.right - x).abs();
//         final centerDistance = (itemMidX - x).abs();

//         if (centerDistance < snapThreshold &&
//             centerDistance < minXDistance &&
//             !isCriticalXSnap) {
//           verticalPoints[x] = SnapType.center;
//           closestX = x - item.size.width / 2;
//           minXDistance = centerDistance;
//         } else if (leftDistance < snapThreshold &&
//             leftDistance < minXDistance &&
//             !isCriticalXSnap) {
//           verticalPoints[x] = SnapType.edge;
//           closestX = x;
//           minXDistance = leftDistance;
//         } else if (rightDistance < snapThreshold &&
//             rightDistance < minXDistance &&
//             !isCriticalXSnap) {
//           verticalPoints[x] = SnapType.edge;
//           closestX = x - item.size.width;
//           minXDistance = rightDistance;
//         } else {
//           verticalPoints.putIfAbsent(x, () => SnapType.inactive);
//         }
//       }

//       for (final y in horizontalEdges) {
//         final topDistance = (draggedRect.top - y).abs();
//         final bottomDistance = (draggedRect.bottom - y).abs();
//         final centerDistance = (itemMidY - y).abs();

//         if (centerDistance < snapThreshold &&
//             centerDistance < minYDistance &&
//             !isCriticalYSnap) {
//           horizontalPoints[y] = SnapType.center;
//           closestY = y - item.size.height / 2;
//           minYDistance = centerDistance;
//         } else if (topDistance < snapThreshold &&
//             topDistance < minYDistance &&
//             !isCriticalYSnap) {
//           horizontalPoints[y] = SnapType.edge;
//           closestY = y;
//           minYDistance = topDistance;
//         } else if (bottomDistance < snapThreshold &&
//             bottomDistance < minYDistance &&
//             !isCriticalYSnap) {
//           horizontalPoints[y] = SnapType.edge;
//           closestY = y - item.size.height;
//           minYDistance = bottomDistance;
//         } else {
//           horizontalPoints.putIfAbsent(y, () => SnapType.inactive);
//         }
//       }
//     }

//     final sortedVertical = verticalPoints.entries
//         .toList()
//         .sorted((a, b) => a.key.compareTo(b.key))
//         .where((e) => e.value != SnapType.inactive)
//         .take(3)
//         .map(
//           (e) => AlignmentPoint(
//             value: (e.key * 100).roundToDouble() / 100,
//             isVertical: true,
//             snapType: e.value,
//           ),
//         )
//         .toList();

//     final sortedHorizontal = horizontalPoints.entries
//         .toList()
//         .sorted((a, b) => a.key.compareTo(b.key))
//         .where((e) => e.value != SnapType.inactive)
//         .take(3)
//         .map(
//           (e) => AlignmentPoint(
//             value: (e.key * 100).roundToDouble() / 100,
//             isVertical: false,
//             snapType: e.value,
//           ),
//         )
//         .toList();

//     points.addAll(sortedVertical);
//     points.addAll(sortedHorizontal);

//     final snappedOffset = Offset(closestX ?? offset.dx, closestY ?? offset.dy);

//     return _SnapResult(points: points, snappedOffset: snappedOffset);
//   }

//   _SpatialIndex _spatialIndex = _SpatialIndex();

//   void _updateSpatialIndex() {
//     _spatialIndex = _SpatialIndex();
//     final allItems = boardController.getAllData();
//     for (final itemJson in allItems) {
//       if (itemJson['id'] != draggedItem.value?.id) {
//         try {
//           final item = _deserializeItem(itemJson);
//           _spatialIndex.addItem(item);
//         } catch (e) {
//           debugPrint('Error adding item to spatial index: $e');
//         }
//       }
//     }
//   }

//   @override
//   void onClose() {
//     boardController.dispose();
//     super.onClose();
//   }
// }

// class _SnapResult {
//   final List<AlignmentPoint> points;
//   final Offset snappedOffset;

//   _SnapResult({required this.points, required this.snappedOffset});
// }

// class _SpatialIndex {
//   final Map<int, List<StackItem>> _buckets = {};
//   static const double bucketSize = 30.0;

//   void addItem(StackItem item) {
//     final double centerX = item.offset.dx + item.size.width / 2;
//     final double centerY = item.offset.dy + item.size.height / 2;
//     final int bucketX = (centerX / bucketSize).floor();
//     final int bucketY = (centerY / bucketSize).floor();
//     final int key = bucketX * 10000 + bucketY;
//     _buckets.putIfAbsent(key, () => []).add(item);
//   }

//   List<StackItem> getNearbyItems(Offset center) {
//     const double maxDistance = 150.0;
//     final int centerBucketX = (center.dx / bucketSize).floor();
//     final int centerBucketY = (center.dy / bucketSize).floor();
//     final List<StackItem> nearbyItems = [];

//     for (int dx = -2; dx <= 2; dx++) {
//       for (int dy = -2; dy <= 2; dy++) {
//         final int bucketX = centerBucketX + dx;
//         final int bucketY = centerBucketY + dy;
//         final int key = bucketX * 10000 + bucketY;
//         final items = _buckets[key] ?? [];
//         for (final item in items) {
//           final itemCenter = Offset(
//             item.offset.dx + item.size.width / 2,
//             item.offset.dy + item.size.height / 2,
//           );
//           if ((center - itemCenter).distance < maxDistance) {
//             nearbyItems.add(item);
//           }
//         }
//       }
//     }
//     return nearbyItems;
//   }
// }

// class _ItemState {
//   final StackItem item;
//   final _ItemAction action;
//   final double? previousHue; // For hue changes

//   _ItemState({required this.item, required this.action, this.previousHue});
// }

// enum _ItemAction { add, update, delete, hue }

// enum AlignmentOption { center, left, right, top, bottom }

// enum SnapType { inactive, edge, center, edgeCritical, centerCritical }

// class AlignmentPoint {
//   final double value;
//   final bool isVertical;
//   final SnapType snapType;

//   AlignmentPoint({
//     required this.value,
//     required this.isVertical,
//     required this.snapType,
//   });

//   bool get isSnapped => snapType != SnapType.inactive;
//   bool get isCriticalSnap =>
//       snapType == SnapType.edgeCritical || snapType == SnapType.centerCritical;

//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is AlignmentPoint &&
//           value == other.value &&
//           isVertical == other.isVertical &&
//           snapType == other.snapType;

//   @override
//   int get hashCode => Object.hash(value, isVertical, snapType);
// }

// extension IterableExtension<T> on Iterable<T> {
//   List<T> sorted(int Function(T, T) compare) {
//     final list = toList();
//     list.sort(compare);
//     return list;
//   }
// }

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

  StackItem<StackItemContent> _deserializeItem(Map<String, dynamic> json) {
    try {
      if (json['type'] == 'StackTextItem') {
        return StackTextItem.fromJson(json);
      } else if (json['type'] == 'StackImageItem') {
        return StackImageItem.fromJson(json);
      } else if (json['type'] == 'ColorStackItem1') {
        return ColorStackItem1.fromJson(json);
      } else {
        throw Exception('Unknown item type: ${json['type']}');
      }
    } catch (e) {
      debugPrint('Error deserializing item: $e');
      rethrow;
    }
  }

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
        final item = _deserializeItem(itemJson);

        final double originalX = (itemJson['originalX'] ?? 0.0) as double;
        final double originalY = (itemJson['originalY'] ?? 0.0) as double;
        final bool isCentered = itemJson['isCentered'] ?? false;

        // Scale the item's position based on the provided canvas scale
        double scaledX = originalX * canvasScale;
        double scaledY = originalY * canvasScale;
        Size itemSize;
        StackItem updatedItem;
        scaledY += cumulativeYOffset;

        if (item is StackTextItem) {
          // Scale the font size, clamping it to ensure readability
          // final double scaledFontSize = MediaQuery.textScalerOf(context)
          //     .scale(item.content!.style!.fontSize! * canvasScale)
          //     .clamp(8.0, 200.0);

          // Update the item's style with the scaled font size
          final updatedStyle = item.content!.style!.copyWith(
            fontSize: item.content!.style!.fontSize,
          );

          // Calculate the item's size based on the scaled text
          itemSize = Size(
            getTextWidth(text: item.content!.data!, style: updatedStyle).width +
                20,
            getTextWidth(text: item.content!.data!, style: updatedStyle).height,
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
          // Add spacing after text
          cumulativeYOffset += itemSize.height;
        } else if (item is StackImageItem) {
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
