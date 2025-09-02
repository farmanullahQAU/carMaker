import 'package:cardmaker/app/features/editor/controller.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/stack_case.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/stack_items.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ImageEditorController extends GetxController {
  // Selected adjustment type (brightness, contrast, etc.)
  final RxString _selectedAdjustment = 'brightness'.obs;

  // Currently selected image item
  StackImageItem? _selectedImageItem;

  // Tab controller index for the image editor
  static final RxInt _selectedTabIndex = 0.obs;

  // Filter states
  final RxString _activeFilter = 'none'.obs;
  final RxDouble _filterIntensity = 1.0.obs;

  // Adjustment values cache for real-time updates
  final RxMap<String, double> _adjustmentValues = <String, double>{}.obs;

  // Mask and overlay states
  final Rx<ImageMaskShape> _selectedMaskShape = ImageMaskShape.none.obs;
  final Rx<Color?> _overlayColor = Rx<Color?>(null);
  final RxDouble _overlayOpacity = 0.4.obs; // Default opacity

  // Getter for overlay opacity
  double get overlayOpacity => _overlayOpacity.value;
  // Border properties
  final RxDouble _borderWidth = 0.0.obs;
  final RxDouble _borderRadius = 0.0.obs;
  final Rx<Color?> _borderColor = Rx<Color?>(null);
  final RxDouble _shadowBlur = 0.0.obs;
  final Rx<Color?> _shadowColor = Rx<Color?>(null);

  // Add shadow offset state
  final Rx<Offset> _shadowOffset = const Offset(0, 0).obs;

  // Getter for shadow offset
  Offset get shadowOffset => _shadowOffset.value;

  // Getter for noise intensity

  // Transform properties
  final RxDouble _rotationAngle = 0.0.obs;
  final RxBool _flipHorizontal = false.obs;
  final RxBool _flipVertical = false.obs;
  // Shape border properties
  final RxDouble _shapeBorderWidth = 0.0.obs;
  final RxDouble _shapeBorderRadius = 0.0.obs;
  final Rx<Color?> _shapeBorderColor = Rx<Color?>(null);

  // Getters
  double get shapeBorderWidth => _shapeBorderWidth.value;
  double get shapeBorderRadius => _shapeBorderRadius.value;
  Color? get shapeBorderColor => _shapeBorderColor.value;
  // Panel state
  final RxBool _isExpanded = true.obs;
  final RxBool _isPanelVisible = false.obs;

  // Getters
  String get selectedAdjustment => _selectedAdjustment.value;
  int get selectedTabIndex => _selectedTabIndex.value;
  String get activeFilter => _activeFilter.value;
  double get filterIntensity => _filterIntensity.value;
  ImageMaskShape get selectedMaskShape => _selectedMaskShape.value;
  Color? get overlayColor => _overlayColor.value;
  StackImageItem? get selectedImageItem => _selectedImageItem;
  double get borderWidth => _borderWidth.value;
  double get borderRadius => _borderRadius.value;
  Color? get borderColor => _borderColor.value;
  double get shadowBlur => _shadowBlur.value;
  Color? get shadowColor => _shadowColor.value;
  double get rotationAngle => _rotationAngle.value;
  bool get flipHorizontal => _flipHorizontal.value;
  bool get flipVertical => _flipVertical.value;
  bool get isExpanded => _isExpanded.value;
  bool get isPanelVisible => _isPanelVisible.value;

  // Methods to update states with specific IDs
  void setSelectedAdjustment(String adjustment) {
    _selectedAdjustment.value = adjustment;
    update(['adjustment_tools', 'adjustment_slider']);
  }

  void setSelectedImageItem(StackImageItem? item) {
    if (item != _selectedImageItem) {
      if (_selectedImageItem == null) {
        // No image is currently selected, set the new image as the active one
        _selectedImageItem = item;
      } else {}
      _selectedImageItem = item;
      _loadImageProperties(item);
      update(['panel_container']);
    }
  }

  void setSelectedTabIndex(int index) {
    _selectedTabIndex.value = index;
    update(['panel_container']);
  }

  void showImageEditor(StackImageItem imageItem) {
    setSelectedImageItem(imageItem);
    _isPanelVisible.value = true;
    update(['panel_container']);
  }

  void hideImageEditor() {
    _isPanelVisible.value = false;
    _selectedImageItem = null;
    update(['panel_container']);
  }

  void togglePanelExpansion() {
    _isExpanded.value = !_isExpanded.value;
    update(['filters_page', 'effects_page', 'border_page', 'transform_page']);
  }

  // Adjustment methods
  void updateAdjustment(String type, double value) {
    if (_selectedImageItem?.content == null) return;

    final content = _selectedImageItem!.content!;
    _adjustmentValues[type] = value;

    switch (type) {
      case 'brightness':
        content.adjustBrightness(value / 100);
        break;
      case 'contrast':
        content.adjustContrast((value / 100) + 1.0);
        break;
      case 'saturation':
        content.adjustSaturation((value / 100) + 1.0);
        break;
      case 'hue':
        content.adjustHue(value);
        break;
      case 'opacity':
        content.adjustOpacity(value / 100);
        break;
    }

    _notifyImageUpdate();
    update(['adjustment_slider']);
  }

  double getAdjustmentValue(String type) {
    if (_selectedImageItem?.content == null) return 0.0;

    final content = _selectedImageItem!.content!;
    switch (type) {
      case 'brightness':
        return content.brightness * 100;
      case 'contrast':
        return (content.contrast - 1.0) * 100;
      case 'saturation':
        return (content.saturation - 1.0) * 100;
      case 'hue':
        return content.hue;
      case 'opacity':
        return content.opacity * 100;
      default:
        return 0.0;
    }
  }

  // Filter methods
  void applyFilter(String filterKey) {
    if (_selectedImageItem?.content == null) return;

    _activeFilter.value = filterKey;
    _selectedImageItem!.content!.applyFilter(filterKey);
    _notifyImageUpdate();
    update(['filters_page']);
  }

  void setFilterIntensity(double intensity) {
    _filterIntensity.value = intensity;
    // Apply filter intensity logic here
    _notifyImageUpdate();
    update(['filters_page']);
  }

  // Effects methods
  void setMaskShape(ImageMaskShape shape) {
    if (_selectedImageItem?.content == null) return;

    _selectedMaskShape.value = shape;
    _selectedImageItem!.content!.maskShape = shape;
    _notifyImageUpdate();
    update(['shape_option']);
  }

  // Updated setOverlayColor method
  void setOverlayColor(Color? color) {
    if (_selectedImageItem?.content == null) return;

    _overlayColor.value = color;
    _selectedImageItem!.content!.overlayColor = color;
    if (color != null) {
      _selectedImageItem!.content!.overlayOpacity =
          _overlayOpacity.value; // Set opacity
    }
    _notifyImageUpdate();
    update(['color_overlay_page']);
  }

  void setPolygonSides(int sides) {
    if (_selectedImageItem?.content == null) return;

    _selectedImageItem!.content!.polygonSides = sides.clamp(3, 12);
    _notifyImageUpdate();
    update(['shape_specific_settings']);
  }

  void setStarPoints(int points) {
    if (_selectedImageItem?.content == null) return;

    _selectedImageItem!.content!.starPoints = points.clamp(3, 12);
    _notifyImageUpdate();
    update(['shape_specific_settings']);
  }

  void setStarInset(double inset) {
    if (_selectedImageItem?.content == null) return;

    _selectedImageItem!.content!.starInset = inset.clamp(0.1, 0.9);
    _notifyImageUpdate();
    update(['shape_specific_settings']);
  }

  // New method for setting overlay opacity
  void setOverlayOpacity(double opacity) {
    if (_selectedImageItem?.content == null) return;

    _overlayOpacity.value = opacity;
    _selectedImageItem!.content!.overlayOpacity = opacity;
    _notifyImageUpdate();
    update(['color_overlay_page', 'overlay_opacity']);
  }

  void setVignette(double value) {
    // if (_selectedImageItem?.content == null) return;

    _selectedImageItem!.content!.vignette = value;
    _notifyImageUpdate();
    update(['vignette_slider']);
  }

  // Border methods
  void setBorderWidth(double width) {
    if (_selectedImageItem?.content == null) return;

    _borderWidth.value = width;
    _selectedImageItem!.content!.borderWidth = width;
    if (width > 0 && _borderColor.value == null) {
      setBorderColor(Colors.white);
    }
    _notifyImageUpdate();
    update(['border_width']);
  }

  void setBorderRadius(double radius) {
    if (_selectedImageItem?.content == null) return;

    _borderRadius.value = radius;
    _selectedImageItem!.content!.borderRadius = radius;
    _notifyImageUpdate();
    update(['border_radius']);
  }

  void setBorderColor(Color? color) {
    if (_selectedImageItem?.content == null) return;

    _borderColor.value = color;
    _selectedImageItem!.content!.borderColor = color;
    _notifyImageUpdate();
    update(['border_page']);
  }

  void setShadowBlur(double blur) {
    if (_selectedImageItem?.content == null) return;

    _shadowBlur.value = blur;
    _selectedImageItem!.content!.shadowBlur = blur;
    if (blur > 0 && _shadowColor.value == null) {
      setShadowColor(Colors.black);
    }
    _notifyImageUpdate();
    update(['shadow_blur']);
  }

  void setShadowColor(Color? color) {
    if (_selectedImageItem?.content == null) return;

    _shadowColor.value = color;
    _selectedImageItem!.content!.shadowColor = color;
    _notifyImageUpdate();
    update(['border_page']);
  }

  // Method to set shadow offset
  void setShadowOffset(Offset offset) {
    if (_selectedImageItem?.content == null) return;

    _shadowOffset.value = offset;
    _selectedImageItem!.content!.shadowOffset = offset;
    _notifyImageUpdate();
    update(['effects_page']);
  }

  // Transform methods
  void setRotationAngle(double angle) {
    if (_selectedImageItem?.content == null) return;

    _rotationAngle.value = angle;
    _selectedImageItem!.content!.rotationAngle = angle;
    _notifyImageUpdate();
    update(['rotation_slider']);
  }

  void rotateQuick(double degrees) {
    final currentAngle = _rotationAngle.value;
    final newAngle = (currentAngle + degrees) % 360;
    setRotationAngle(newAngle);
  }

  void setFlipHorizontal(bool flip) {
    if (_selectedImageItem?.content == null) return;

    _flipHorizontal.value = flip;
    _selectedImageItem!.content!.flipHorizontal = flip;
    _notifyImageUpdate();
    update(['flip_buttons']);
  }

  void setFlipVertical(bool flip) {
    if (_selectedImageItem?.content == null) return;

    _flipVertical.value = flip;
    _selectedImageItem!.content!.flipVertical = flip;
    _notifyImageUpdate();
    update(['flip_buttons']);
  }

  // Reset methods
  void resetFilters() {
    if (_selectedImageItem?.content == null) return;

    _selectedImageItem!.content!.resetFilters();
    _activeFilter.value = 'none';
    _filterIntensity.value = 1.0;
    _loadImageProperties(_selectedImageItem);
    _notifyImageUpdate();
    update(['filters_page']);
  }

  void resetAdjustments() {
    if (_selectedImageItem?.content == null) return;

    final content = _selectedImageItem!.content!;
    content.adjustBrightness(0.0);
    content.adjustContrast(1.0);
    content.adjustSaturation(1.0);
    content.adjustHue(0.0);
    content.adjustOpacity(1.0);

    _adjustmentValues.clear();
    _notifyImageUpdate();
    update(['adjustment_tools', 'adjustment_slider']);
  }

  void resetTransforms() {
    if (_selectedImageItem?.content == null) return;

    final content = _selectedImageItem!.content!;
    content.rotationAngle = 0.0;
    content.flipHorizontal = false;
    content.flipVertical = false;

    _rotationAngle.value = 0.0;
    _flipHorizontal.value = false;
    _flipVertical.value = false;

    _notifyImageUpdate();
    update(['transform_page']);
  }

  void resetBorders() {
    if (_selectedImageItem?.content == null) return;

    final content = _selectedImageItem!.content!;
    content.borderWidth = 0.0;
    content.borderRadius = 0.0;
    content.borderColor = null;
    content.shadowBlur = 0.0;
    content.shadowColor = null;

    _borderWidth.value = 0.0;
    _borderRadius.value = 0.0;
    _borderColor.value = null;
    _shadowBlur.value = 0.0;
    _shadowColor.value = null;

    _notifyImageUpdate();
    update(['border_page']);
  }

  void resetAll() {
    resetFilters();
    resetAdjustments();
    resetTransforms();
    resetBorders();

    if (_selectedImageItem?.content != null) {
      final content = _selectedImageItem!.content!;
      content.maskShape = ImageMaskShape.none;
      content.overlayColor = null;

      _selectedMaskShape.value = ImageMaskShape.none;
      _overlayColor.value = null;
    }

    _notifyImageUpdate();
    update(['effects_page']);
  }

  // Methods to update shape borders
  void setShapeBorderWidth(double width) {
    if (_selectedImageItem?.content == null) return;

    _shapeBorderWidth.value = width;
    _selectedImageItem!.content!.shapeBorderWidth = width;
    _notifyImageUpdate();
    update(['shape_border_width']);
  }

  void setShapeBorderRadius(double radius) {
    if (_selectedImageItem?.content == null) return;

    _shapeBorderRadius.value = radius;
    _selectedImageItem!.content!.shapeBorderRadius = radius;
    _notifyImageUpdate();
    update(['shape_border_radius']);
  }

  void setShapeBorderColor(Color? color) {
    if (_selectedImageItem?.content == null) return;

    _shapeBorderColor.value = color;
    _selectedImageItem!.content!.shapeBorderColor = color;
    _notifyImageUpdate();
    update(['shape_border_color']);
  }

  // Private helper methods
  void _loadImageProperties(StackImageItem? item) {
    if (item?.content == null) return;

    final content = item!.content!;
    // Load shape border values
    _shapeBorderWidth.value = content.shapeBorderWidth;
    _shapeBorderRadius.value = content.shapeBorderRadius;
    _shapeBorderColor.value = content.shapeBorderColor;

    // Load current values
    _activeFilter.value = content.activeFilter ?? 'none';
    _selectedMaskShape.value = content.maskShape ?? ImageMaskShape.none;
    _overlayColor.value = content.overlayColor;
    _overlayOpacity.value = content.overlayOpacity ?? 0.4;
    _borderWidth.value = content.borderWidth ?? 0.0;
    _borderRadius.value = content.borderRadius ?? 0.0;
    _borderColor.value = content.borderColor;
    _shadowBlur.value = content.shadowBlur ?? 0.0;
    _shadowColor.value = content.shadowColor;

    _rotationAngle.value = content.rotationAngle ?? 0.0;
    _flipHorizontal.value = content.flipHorizontal ?? false;
    _flipVertical.value = content.flipVertical ?? false;

    // Clear adjustment cache to reload fresh values
    _adjustmentValues.clear();

    // Update all relevant UI components
    update([
      'adjustment_tools',
      'adjustment_slider',
      'filters_page',
      'effects_page',
      'border_page',
      'transform_page',
    ]);
  }

  void _notifyImageUpdate() {
    // Notify the main editor controller about the image update
    try {
      final editorController = Get.find<CanvasController>();
      editorController.update(['canvas_stack', 'stack_board']);
    } catch (e) {
      // EditorController might not be available in all contexts
      debugPrint(
        'ImageEditorController: Could not notify EditorController of update',
      );
    }
  }

  List<String> getAvailableAdjustments() {
    return ['brightness', 'contrast', 'saturation', 'hue', 'opacity'];
  }

  List<ImageMaskShape> getAvailableMaskShapes() {
    return ImageMaskShape.values;
  }

  @override
  void onClose() {
    _selectedImageItem = null;
    _adjustmentValues.clear();
    super.onClose();
  }
}
