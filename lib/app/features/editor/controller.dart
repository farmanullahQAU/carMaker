import 'dart:io' show File;
import 'dart:io';
import 'dart:math' as math;

import 'package:cardmaker/app/features/editor/editor_canvas.dart';
import 'package:cardmaker/app/features/editor/image_editor/controller.dart';
import 'package:cardmaker/app/routes/app_routes.dart';
import 'package:cardmaker/core/helper/image_helper.dart';
import 'package:cardmaker/core/values/enums.dart';
import 'package:cardmaker/models/card_template.dart';
import 'package:cardmaker/services/auth_service.dart';
import 'package:cardmaker/services/firestore_service.dart';
import 'package:cardmaker/services/storage_service.dart';
import 'package:cardmaker/widgets/common/app_toast.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/flutter_stack_board.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/src/stack_board_items/items/shack_shape_item.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/stack_board_item.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/stack_items.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:screenshot/screenshot.dart';
import 'package:universal_html/html.dart' as html; // For web support
import 'package:uuid/uuid.dart';

class CanvasController extends GetxController {
  final authService = Get.find<AuthService>();
  final firestoreService = FirestoreService();

  final StackBoardController boardController = StackBoardController();
  final RxString selectedFont = 'Poppins'.obs;
  final RxDouble fontSize = 24.0.obs;
  final Rx<Color> fontColor = Colors.black.obs;
  final RxnString selectedBackground = RxnString();
  final RxDouble backgroundHue = 0.0.obs; //add to cloude TODO
  final RxString templateName = ''.obs;
  bool isExporting = false;
  final ScreenshotController screenshotController = ScreenshotController();
  final RxBool allowTouch = false.obs;
  final Rx<StackImageItem?> activePhotoItem = Rx<StackImageItem?>(null);
  final Rx<PanelType> activePanel = PanelType.none.obs;
  RxBool isShowEditIcon = false.obs;
  final Rx<Size> actualStackBoardRenderSize = Size(100, 100).obs;
  final Map<String, bool> newImageFlags = {};
  CardTemplate? initialTemplate;

  final RxDouble canvasWsidth = 0.0.obs;
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

  // Profile images management
  final RxList<StackImageItem> profileImageItems = <StackImageItem>[].obs;

  final RxBool showHueSlider = false.obs;
  final RxBool showStickerPanel = false.obs;
  final RxInt selectedToolIndex = 0.obs;
  // image_picker
  final ImagePicker _picker = ImagePicker();

  // Canvas scaling properties
  final GlobalKey stackBoardKey = GlobalKey();
  final RxBool isTemplateLoaded = false.obs;
  final RxDouble canvasScale = 1.0.obs;
  final RxDouble scaledCanvasWidth = 0.0.obs;
  final RxDouble scaledCanvasHeight = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is Map<String, dynamic>) {
      initialTemplate = Get.arguments['template'];
    } else {
      initialTemplate = Get.arguments as CardTemplate;
    }

    templateName.value = initialTemplate!.name;

    selectedBackground.value = initialTemplate?.backgroundImageUrl;
    boardController.clear();

    // Collect all profile images from initialTemplate
    profileImageItems.clear();
    for (var itemJson in initialTemplate!.items) {
      if (itemJson['isProfileImage'] == true) {
        final item = deserializeItem(itemJson);
        if (item is StackImageItem) {
          profileImageItems.add(item);
        }
      }
    }
  }

  void addShapeItem(StackShapeItem shapeItem) {
    boardController.addItem(shapeItem);
    activeItem.value = shapeItem;
    activePanel.value = PanelType.shapeEditor;
    update(['canvas_stack', 'bottom_sheet']);
  }

  void updateItem(StackItem item) {
    final existingItem = boardController.getById(item.id);
    if (existingItem != null) {
      // Update the item in the board controller
      boardController.removeById(item.id);
      boardController.addItem(item);

      // Update active item if it's the same
      if (activeItem.value?.id == item.id) {
        activeItem.value = item;
      }

      update(['canvas_stack', 'stack_board']);
    }
  }

  // Add this to your PanelType enum (if not already present)

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

    loadDesignFromStorage(
      initialTemplate!,
      context,
      scaledCanvasWidth.value,
      scaledCanvasHeight.value,
    );

    isTemplateLoaded.value = true;
    update(['canvas_stack']); // Trigger rebuild of canvas stack
  }

  void loadDesignFromStorage(
    CardTemplate template,
    BuildContext context,
    double scaledCanvasWidth,
    double scaledCanvasHeight,
  ) async {
    print("Loading exported template...");
    selectedBackground.value = template.backgroundImageUrl;
    templateName.value = template.name;

    backgroundHue.value = 0.0;
    boardController.clear();
    profileImageItems.clear();

    for (final itemJson in template.items) {
      try {
        final bool isCentered = itemJson['isCentered'] ?? false;
        final bool isProfileImage = itemJson['isProfileImage'] ?? false;

        final item = deserializeItem(itemJson);
        if (isProfileImage) {
          if (item is StackImageItem) {
            profileImageItems.add(item);
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
          final double originalWidth = (itemJson['size']['width']).toDouble();
          final double originalHeight = (itemJson['size']['height']).toDouble();

          itemSize = Size(originalWidth, originalHeight);

          updatedItem = item.copyWith(
            offset: Offset(scaledX, scaledY),
            size: itemSize,
            status: StackItemStatus.idle,
          );
        } else if (item is StackShapeItem) {
          double scaledX = item.offset.dx;
          double scaledY = item.offset.dy;
          final double originalWidth = (itemJson['size']['width']).toDouble();
          final double originalHeight = (itemJson['size']['height']).toDouble();

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

        boardController.addItem(updatedItem);
        _undoStack.add(_ItemState(item: updatedItem, action: _ItemAction.add));
      } catch (err) {
        debugPrint('Error loading item: $err');
      }
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

  void addSticker(String data) {
    final content = TextItemContent(
      data: data,
      googleFont: 'Roboto',
      style: const TextStyle(fontSize: 24, color: Colors.black),
    );
    final textItem = StackTextItem(
      id: UniqueKey().toString(),
      size: Size(Get.width * 0.2, Get.width * 0.2),
      offset: Offset(200, 250),
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
    // _redoStack.clear();
    backgroundHue.value = hue;
    update(['canvas_stack']); // This line should trigger the rebuild
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
      activeItem.value = item;

      // If the selected item is an image, show the image editor
      if (item is StackImageItem && !item.isProfileImage) {
        _showImageEditor(item);
      }
    } else if (status == StackItemStatus.idle) {
      if (draggedItem.value?.id == item.id) {
        draggedItem.value = null;
      }
      if (activeItem.value?.id == item.id) {
        activeItem.value = null;
        _hideImageEditor();
      }
    }
    update([
      'canvas_stack',
      'bottom_sheet',
    ]); // Trigger rebuild of canvas and bottom sheet
  }

  void _showImageEditor(StackImageItem imageItem) {
    try {
      final imageEditorController = Get.find<ImageEditorController>();
      imageEditorController.showImageEditor(imageItem);
    } catch (e) {
      // ImageEditorController not found, create it
      final imageEditorController = Get.put(ImageEditorController());
      imageEditorController.showImageEditor(imageItem);
    }
  }

  void _hideImageEditor() {
    try {
      final imageEditorController = Get.find<ImageEditorController>();
      imageEditorController.hideImageEditor();
    } catch (e) {
      // ImageEditorController not found, ignore
    }
  }

  Future<void> uploadTemplate(CardTemplate template) async {
    try {
      if (authService.user == null) {
        Get.toNamed(Routes.auth);
        return;
      }

      final thumbnailFile = await exportAsImage();

      // Handle background image
      File? backgroundFile;
      if ((selectedBackground.value?.isNotEmpty ?? false) &&
          selectedBackground.value != template.backgroundImageUrl &&
          (!selectedBackground.value!.startsWith('https') ||
              !selectedBackground.value!.startsWith('http'))) {
        backgroundFile = File(selectedBackground.value!);
      }

      // Use TemplateService to upload and save
      await firestoreService.addTemplate(
        template,
        thumbnailFile: thumbnailFile,
        backgroundFile: backgroundFile,
        newImageFlags: newImageFlags,
      );

      // Cleanup after successful upload

      _cleanupTempFiles(thumbnailFile, backgroundFile);
    } catch (err) {
      AppToast.error(message: err.toString());
    }
  }

  void _cleanupTempFiles(File thumbnailFile, File? backgroundFile) async {
    try {
      if (await thumbnailFile.exists()) {
        await thumbnailFile.delete();
      }
      if (backgroundFile != null && await backgroundFile.exists()) {
        await backgroundFile.delete();
      }
    } catch (e) {
      debugPrint('Error cleaning up temp files: $e');
    }
  }

  // Add this method to handle background operations
  Future<void> performHeavyOperation(Function operation) async {
    // Show loading indicator
    final loadingDialog = Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      // Run in a separate microtask to avoid blocking UI
      await Future.microtask(() => operation());
    } finally {
      // Dismiss loading dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    }
  }

  void updateStackBoardRenderSize(Size size) {
    if (actualStackBoardRenderSize.value != size) {
      actualStackBoardRenderSize.value = size;
      _updateGridSize();
    }
  }

  Future<void> saveDesign() async {
    final double originalWidth = initialTemplate!.width.toDouble();
    final double originalHeight = initialTemplate!.height.toDouble();

    final List<Map<String, dynamic>> exportedItems = [];
    final currentItems = boardController.getAllData();

    debugPrint('Current Items: $currentItems', wrapWidth: 1000);

    // Include all profile images from profileImageItems
    if (profileImageItems.isNotEmpty) {
      for (final profileItem in profileImageItems) {
        exportedItems.add(profileItem.toJson());
      }
    }

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
        exportedItem['content'] = StackImageItem.fromJson(
          itemJson,
        ).content?.toJson();
      }

      exportedItems.add(exportedItem);
    }

    final temp = CardTemplate(
      id: 'exported_${initialTemplate!.id}_modified_${DateTime.now().millisecondsSinceEpoch}',
      name: templateName.value.isNotEmpty
          ? templateName.value
          : initialTemplate!.name,
      thumbnailUrl: initialTemplate!.thumbnailUrl,
      backgroundImageUrl: initialTemplate?.backgroundImageUrl ?? "",
      items: exportedItems,
      createdAt: DateTime.now(),
      updatedAt: null,
      category: initialTemplate!.category,

      categoryId: initialTemplate!.categoryId,
      compatibleDesigns: initialTemplate!.compatibleDesigns,
      width: originalWidth,
      height: originalHeight,
      isPremium: initialTemplate!.isPremium,
      tags: initialTemplate?.tags ?? [],
      imagePath: "",
    );
    await StorageService.addTemplate(temp);
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

  @override
  void onClose() {
    boardController.dispose();

    super.onClose();
  }

  Future<void> replaceImageItem() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var item = activeItem.value as StackImageItem;

        final newItem = StackImageItem(
          offset: item.offset,
          size: item.size,
          content: item.content?.copyWith(filePath: image.path),
          angle: item.angle,
          isProfileImage: item.isProfileImage,
          isNewImage: true,
        );
        boardController.removeById(item.id);
        boardController.addItem(newItem);

        activeItem.value = newItem;
        newImageFlags[item.id] = true; // Mark as new image

        update(['canvas_stack']);
      }
    } catch (e) {
      print(e);
      Get.snackbar(
        'Error',
        'Failed to handle image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  Future<void> pickAndAddImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final newItem = StackImageItem(
          id: UniqueKey().toString(),
          offset: Offset(100, 100),

          size: Size(Get.width * 0.3, Get.width * 0.3),
          lockZOrder: true,
          isNewImage: true,
          content: ImageItemContent(filePath: image.path),
        );
        boardController.addItem(newItem);
        newImageFlags[newItem.id] = true; // Mark as new image

        activeItem.value = newItem;
        update(['canvas_stack']);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to handle image: ${e.toString()}');
    }
  }

  void duplicateItem() {
    if (activeItem.value == null) return;

    final originalItem = activeItem.value!;
    final newOffset = Offset(
      originalItem.offset.dx + 20, // Offset by 20 pixels to the right
      originalItem.offset.dy + 20, // Offset by 20 pixels down
    );

    StackItem newItem;

    if (originalItem is StackTextItem) {
      newItem = StackTextItem(
        id: UniqueKey().toString(),
        offset: newOffset,
        size: originalItem.size,
        content: originalItem.content,
      );
    } else if (originalItem is StackImageItem) {
      final id = UniqueKey().toString();

      newItem = StackImageItem(
        id: id,

        offset: newOffset,
        size: originalItem.size,
        content: originalItem.content?.copyWith(),
        angle: originalItem.angle,
        isProfileImage: originalItem.isProfileImage,
      );

      newImageFlags[id] = false; // Mark as new image
    } else {
      return; // Unsupported item type
    }

    boardController.addItem(newItem);
    activeItem.value = newItem;

    update(['canvas_stack', 'bottom_sheet']);
  }

  Future<File> exportAsImage() async {
    try {
      isExporting = true;
      update(['export_button']);
      boardController.unSelectAll();
      final exportKey = GlobalKey();

      // Capture the widget as an image
      final image = await screenshotController.captureFromWidget(
        Material(
          elevation: 0,
          color: Colors.white,

          child: SizedBox(
            width: scaledCanvasWidth.value,
            height: scaledCanvasHeight.value,
            key: exportKey,
            child: CanvasStack(
              showGrid: false,
              showBorders: false,
              stackBoardKey: GlobalKey(),
              canvasScale: canvasScale,
              scaledCanvasWidth: scaledCanvasWidth,
              scaledCanvasHeight: scaledCanvasHeight,
            ),
          ),
        ),
        targetSize: Size(scaledCanvasWidth.value, scaledCanvasHeight.value),
        pixelRatio: 2,
      );

      if (kIsWeb) {
        // Web: Trigger a browser download
        final blob = html.Blob([image]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'invitation_card.png')
          ..click();
        html.Url.revokeObjectUrl(url);

        return File('invitation_card.png'); // Dummy file for web
      } else {
        // Android: Save to temporary directory
        final output = await getTemporaryDirectory();
        final file = File("${output.path}/invitation_card.png");
        await file.writeAsBytes(image);

        return file;
      }
    } catch (e, s) {
      debugPrint('Export Image failed: $e\nStack trace: $s');
      Get.snackbar(
        'Error',
        'Failed to export image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      rethrow;
    } finally {
      isExporting = false;
      update(['export_button']);
    }
  }

  Future<void> exportAsPDF() async {
    try {
      isExporting = true;
      update(['export_button']);
      boardController.unSelectAll();
      final exportKey = GlobalKey();
      final image = await screenshotController.captureFromWidget(
        Material(
          shadowColor: Colors.transparent,

          elevation: 0,
          color: Colors.white,
          child: SizedBox(
            width: scaledCanvasWidth.value,
            height: scaledCanvasHeight.value,
            key: exportKey,
            child: Transform.scale(
              scale: 1,
              child: CanvasStack(
                showGrid: false,
                showBorders: false,
                stackBoardKey: GlobalKey(),
                canvasScale: canvasScale,
                scaledCanvasWidth: scaledCanvasWidth,
                scaledCanvasHeight: scaledCanvasHeight,
              ),
            ),
          ),
        ),
        targetSize: Size(scaledCanvasWidth.value, scaledCanvasHeight.value),
        pixelRatio: 2,
      );

      final tempDir = await getTemporaryDirectory();
      final imagePath = '${tempDir.path}/temp_invitation_card.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(image);

      final pdf = pw.Document();
      final imageProvider = pw.MemoryImage(image);
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(
            scaledCanvasWidth.value,
            scaledCanvasHeight.value,
          ),
          build: (pw.Context context) {
            return pw.Center(child: pw.Image(imageProvider));
          },
        ),
      );

      final pdfPath = '${tempDir.path}/invitation_card.pdf';
      final pdfFile = File(pdfPath);
      await pdfFile.writeAsBytes(await pdf.save());

      if (await pdfFile.exists()) {
        Get.to(() => ExportPreviewPage(imagePath: imagePath, pdfPath: pdfPath));
      } else {
        Get.snackbar(
          'Error',
          'Failed to create PDF file',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
      }
    } catch (e, s) {
      debugPrint('Export PDF failed: $e\n$s');
      Get.snackbar(
        'Error',
        'Failed to export PDF due to widget issue',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isExporting = false;
      update(['export_button']);
    }
  }

  Future<void> pickAndUpdateBackground() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        selectedBackground.value = image.path;
        update(['canvas_stack']);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to handle background image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  // Replace the saveDraft method in CanvasController with this simplified version:

  /// Save current design as draft to Firebase
  Future<void> saveDraft() async {
    try {
      final currentItems = boardController.getAllData();

      print(currentItems);

      CardTemplate template = CardTemplate(
        imagePath: "",
        categoryId: 'birthday',
        id: initialTemplate!.isDraft ? initialTemplate!.id : Uuid().v4(),
        name: templateName.isEmpty ? 'Untitled Template' : templateName.value,
        items: currentItems.map((e) => deserializeItem(e).toJson()).toList(),
        width: initialTemplate!.width,
        height: initialTemplate!.height,
        category: 'birthday',
        tags: ['default'],
        isPremium: false,

        isDraft: true,
      );

      uploadTemplate(template);
    } catch (err) {
      print("xxxxxxxxxxxxxxxxxxxx");
      print(err);
      AppToast.error(message: err.toString());
    }
  }

  Future<void> saveAsPublicProject() async {
    try {
      final currentItems = boardController.getAllData();

      final template = CardTemplate(
        imagePath: "",
        categoryId: 'birthday',
        id: Uuid().v4(),
        name: templateName.isEmpty ? 'Untitled Template' : templateName.value,
        items: currentItems.map((e) => deserializeItem(e).toJson()).toList(),
        width: initialTemplate!.width,
        height: initialTemplate!.height,
        category: 'birthday',
        tags: ['default'],
        isPremium: false,

        isDraft: false,
      );

      uploadTemplate(template);
    } catch (err) {
      AppToast.error(message: err.toString());
    }
  }
}

class _ItemState {
  final StackItem item;
  final _ItemAction action;

  _ItemState({required this.item, required this.action});
}

enum _ItemAction { add, update }
