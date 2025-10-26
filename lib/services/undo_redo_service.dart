import 'dart:collection';

import 'package:cardmaker/widgets/common/stack_board/lib/stack_board_item.dart';
import 'package:get/get.dart';

/// Command pattern for undo/redo operations
class CanvasCommand {
  final String description;
  final Future<void> Function() execute;
  final Future<void> Function() undo;

  CanvasCommand({
    required this.description,
    required this.execute,
    required this.undo,
  });
}

/// Efficient Undo/Redo service using command pattern
class UndoRedoService {
  // History stacks
  final Queue<List<StackItemData>> _undoStack = Queue<List<StackItemData>>();
  final Queue<List<StackItemData>> _redoStack = Queue<List<StackItemData>>();

  // Observable flags for reactive UI
  final RxBool canUndoFlag = false.obs;
  final RxBool canRedoFlag = false.obs;

  // Maximum history depth
  static const int _maxHistoryDepth = 50;

  /// Save current state to history
  void saveState(List<StackItem<StackItemContent>> items) {
    // Convert items to serializable data
    final state = items.map((item) => _itemToData(item)).toList();

    // Add to undo stack
    _undoStack.addLast(state);

    // Limit history depth
    if (_undoStack.length > _maxHistoryDepth) {
      _undoStack.removeFirst();
    }

    // Clear redo stack when new action is performed
    _redoStack.clear();

    // Update observable flags
    _updateFlags();
  }

  /// Undo last action
  List<StackItemData>? undo() {
    if (!canUndo()) return null;

    // Move current state to redo stack
    _redoStack.addLast(_undoStack.removeLast());

    // Update observable flags
    _updateFlags();

    // Return previous state
    return _undoStack.isNotEmpty ? _undoStack.last : null;
  }

  /// Redo last undone action
  List<StackItemData>? redo() {
    if (!canRedo()) return null;

    // Get state from redo stack
    final state = _redoStack.removeLast();

    // Move to undo stack
    _undoStack.addLast(state);

    // Update observable flags
    _updateFlags();

    return state;
  }

  /// Check if undo is possible
  bool canUndo() => _undoStack.isNotEmpty;

  /// Check if redo is possible
  bool canRedo() => _redoStack.isNotEmpty;

  /// Save current state to redo stack (called before undo)
  void saveStateToRedo(List<StackItemData> state) {
    _redoStack.addLast(state);
  }

  /// Clear history
  void clear() {
    _undoStack.clear();
    _redoStack.clear();
    _updateFlags();
  }

  /// Update observable flags
  void _updateFlags() {
    canUndoFlag.value = _undoStack.isNotEmpty;
    canRedoFlag.value = _redoStack.isNotEmpty;
  }

  /// Get current state size (for debugging)
  int get undoStackSize => _undoStack.length;
  int get redoStackSize => _redoStack.length;

  /// Convert StackItem to serializable data
  StackItemData _itemToData(StackItem<StackItemContent> item) {
    return StackItemData(
      id: item.id,
      type: item.runtimeType.toString(),
      json: item.toJson(),
    );
  }
}

/// Serializable data for StackItem
class StackItemData {
  final String id;
  final String type;
  final Map<String, dynamic> json;

  StackItemData({required this.id, required this.type, required this.json});

  Map<String, dynamic> toJson() => {'id': id, 'type': type, 'json': json};

  factory StackItemData.fromJson(Map<String, dynamic> json) {
    return StackItemData(
      id: json['id'],
      type: json['type'],
      json: json['json'],
    );
  }
}
