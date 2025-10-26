import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:cardmaker/app/features/editor/edit_item/view.dart';
import 'package:cardmaker/app/features/editor/editor_canvas.dart';
import 'package:cardmaker/app/features/profile/controller.dart';
import 'package:cardmaker/app/features/profile/view.dart';
import 'package:cardmaker/core/helper/image_helper.dart';
import 'package:cardmaker/core/values/enums.dart';
import 'package:cardmaker/models/card_template.dart';
import 'package:cardmaker/services/auth_service.dart';
import 'package:cardmaker/services/firestore_service.dart';
import 'package:cardmaker/services/permission_handler.dart';
import 'package:cardmaker/services/storage_service.dart';
import 'package:cardmaker/widgets/common/app_toast.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/flutter_stack_board.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/src/stack_board_items/items/shack_shape_item.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/src/stack_board_items/items/stack_chart_item.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/src/stack_board_items/items/stack_icon_item.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/stack_board_item.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/stack_items.dart';
import 'package:flutter/foundation.dart';
// Modern Minimalist Progress Dialog - Professional Design
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html; // For web support
import 'package:uuid/uuid.dart';

class CanvasController extends GetxController {
  final authService = Get.find<AuthService>();
  final firestoreService = FirestoreServices();
  late bool isLocaleTemplate =
      true; //to distinguish local or online user saved drafts

  late bool showSaveCopyBtn =
      true; // Show "Save a Copy" button only for drafts templates.
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

  CardTemplate? initialTemplate;
  var exportProgress = 0.0.obs;
  final RxDouble canvasWsidth = 0.0.obs;
  final List<StackItem<StackItemContent>> itemsToLoad = [];

  final Rx<StackItem?> draggedItem = Rx<StackItem?>(null);
  Rx<StackItem?> activeItem = Rx<StackItem?>(null);
  final RxBool showGrid = true.obs;
  final RxDouble gridSize = 20.0.obs;
  final Rx<Color> guideColor = Colors.black.obs;
  final Rx<OverlayEntry?> activeTextEditorOverlay = Rx<OverlayEntry?>(null);

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
  bool get isOwner => authService.user?.uid == "aP3FVBY7kWgBnJorqVrYha3lFaa2";
  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is Map<String, dynamic>) {
      initialTemplate = Get.arguments['template'];
      isLocaleTemplate = Get.arguments['isLocal'] ?? true;
      showSaveCopyBtn = Get.arguments['showSaveCopyBtn'] ?? true;
    } else {
      initialTemplate = Get.arguments as CardTemplate;
    }

    templateName.value = initialTemplate!.name;

    selectedBackground.value = initialTemplate?.backgroundImageUrl;
    backgroundHue.value = initialTemplate!.backgroundHue!;
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

  void updateItem(StackItem item) {
    final existingItem = boardController.getById(item.id);
    if (existingItem != null) {
      // Update the item in the board controller
      // boardController.removeById(item.id);
      boardController.updateItem(item);
      boardController.updateBasic(item.id, status: StackItemStatus.moving);

      // Update active item if it's the same
      if (activeItem.value?.id == item.id) {
        activeItem(item);
      }

      update(['canvas_stack', 'stack_board']);
    }
  }

  // Add to CanvasController class
  void addIcon(IconData icon) {
    final content = IconItemContent(
      icon: icon,
      color: Colors.black,
      size: 24.0,
    );

    final iconItem = StackIconItem(
      id: UniqueKey().toString(),
      size: const Size(80, 80),
      offset: Offset(200, 200),
      content: content,
    );

    boardController.addItem(iconItem);
    activeItem.value = iconItem;
    activePanel.value = PanelType.icons;
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

    populateData(
      initialTemplate!,
      context,
      scaledCanvasWidth.value,
      scaledCanvasHeight.value,
    );

    isTemplateLoaded.value = true;
    update(['canvas_stack']); // Trigger rebuild of canvas stack
  }

  void populateData(
    CardTemplate template,
    BuildContext context,
    double scaledCanvasWidth,
    double scaledCanvasHeight,
  ) async {
    print("Loading exported template...");
    selectedBackground.value = template.backgroundImageUrl;
    templateName.value = template.name;

    backgroundHue.value = template.backgroundHue!.toDouble();
    boardController.clear();
    profileImageItems.clear();

    for (final itemJson in template.items) {
      try {
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
            itemJson['size']['width'].toDouble(),
            itemJson['size']['height'].toDouble(),
          );

          updatedItem = item.copyWith(
            offset: Offset(scaledX, scaledY),
            size: itemSize,
            status: StackItemStatus.idle,
            content: item.content!.copyWith(style: updatedStyle),
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
        } else if (item is StackIconItem) {
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

        boardController.addItem(updatedItem);
      } catch (err) {
        debugPrint('Error loading item: $err');
      }
    }
    update([
      'canvas_stack',
      'bottom_sheet',
    ]); // Trigger rebuild of canvas and bottom sheet
  }

  void addProfileImage(
    String assetPath, {
    Offset? offset,
    Size? size,
    bool isPlaceholder = false,
  }) {
    final profileImage = StackImageItem(
      id: 'profile_image_${DateTime.now().millisecondsSinceEpoch}',
      offset: offset ?? const Offset(690.0, 115.0),
      size: size ?? const Size(436.0, 574.0),
      content: ImageItemContent(
        assetName: assetPath,
        isPlaceholder: isPlaceholder, // Set the flag
      ),
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

  Future<void> uploadTemplate(CardTemplate template) async {
    try {
      if (authService.user == null) {
        Get.to(() => ProfileTab());
        return;
      }
      File? thumbnailFile;

      // Handle background image
      File? backgroundFile;
      String? backgroundImageUrl = template.backgroundImageUrl;

      // Check if a new background image was selected (local file path)
      if (selectedBackground.value?.isNotEmpty ?? false) {
        if (!selectedBackground.value!.startsWith('http')) {
          // New local image selected
          backgroundFile = File(selectedBackground.value!);
        } else {
          // Retain the selected background URL (if it's a URL)
          backgroundImageUrl = selectedBackground.value;
        }
      }

      if (template.thumbnailUrl != null) {
        thumbnailFile = File(template.thumbnailUrl!);
      }

      // Use TemplateService to upload and save
      await firestoreService.addTemplate(
        template.copyWith(backgroundImageUrl: backgroundImageUrl),
        thumbnailFile: thumbnailFile,
        backgroundFile: backgroundFile,
      );
      if (thumbnailFile != null) {
        // Cleanup after successful upload
        _cleanupTempFiles(thumbnailFile, backgroundFile);
      }
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

  @override
  void onClose() {
    boardController.dispose();

    super.onClose();
  }

  Future<String?>? getImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      return image.path;
    }

    return null;
  }

  void toggleZLock(String itemId) {
    final currentItem = boardController.getById(itemId);
    if (currentItem != null) {
      print("Current item zlock ${currentItem.lockZOrder}");
      final newLockState = !(currentItem.lockZOrder);

      // Create updated item with new lock state
      final updatedItem = currentItem.copyWith(lockZOrder: newLockState);
      print("UpdatedItem ${updatedItem.lockZOrder}");
      print("UpdatedItem ID: ${updatedItem.id}");
      print("UpdatedItem hashCode: ${updatedItem.hashCode}");

      // Update the item in the board controller
      boardController.updateItem(updatedItem);

      // IMPORTANT: Force reactive update for activeItem with multiple approaches
      if (activeItem.value?.id == itemId) {
        print(
          "Before update - activeItem hashCode: ${activeItem.value.hashCode}",
        );

        // First, clear the active item to force a change
        activeItem.value = null;

        // Then set it to the updated item
        activeItem.value = updatedItem;

        print(
          "After update - activeItem hashCode: ${activeItem.value.hashCode}",
        );
        print(
          "Active item zorder after update ${activeItem.value?.lockZOrder}",
        );

        // Force refresh
        activeItem.refresh();
      }

      // Trigger UI updates
      update(['canvas_stack', 'export_button', 'z_lock_button']);
    }
  }

  /// Bring item to front (move to top of stack)
  void bringToFront() {
    if (activeItem.value != null) {
      final itemId = activeItem.value!.id;
      final currentItem = boardController.getById(itemId);
      if (currentItem != null && !currentItem.lockZOrder) {
        boardController.moveItemOnTop(itemId, force: true);
        activeItem.value = boardController.getById(itemId);
        update(['stack_board']);
      }
    }
  }

  /// Send item to back (move to bottom of stack)
  void sendToBack() {
    if (activeItem.value != null) {
      final itemId = activeItem.value!.id;
      final currentItem = boardController.getById(itemId);
      if (currentItem != null && !currentItem.lockZOrder) {
        boardController.moveItemToBack(itemId, force: true);
        activeItem.value = boardController.getById(itemId);
        update(['stack_board']);
      }
    }
  }

  Future<void> replaceImageItem(StackImageItem item) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final newItem = StackImageItem(
          offset: item.offset,
          size: item.size,
          content: item.content?.copyWith(
            filePath: image.path, // New image from phone
            isPlaceholder: false,
          ),
          lockZOrder: item.lockZOrder,
          angle: item.angle,
          isProfileImage: item.isProfileImage,
          isNewImage: true, // Mark for upload
        );
        boardController.removeById(item.id);
        boardController.addItem(newItem);

        activeItem.value = newItem;

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

  Future<void> pickAndAddImage({bool isPlaceholder = false}) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final newItem = StackImageItem(
          id: UniqueKey().toString(),
          offset: Offset(100, 100),
          size: Size(Get.width * 0.3, Get.width * 0.3),
          lockZOrder: false,
          isNewImage: !isPlaceholder, // Only mark as new if not placeholder
          content: ImageItemContent(
            filePath: image.path, // Local image from phone
            isPlaceholder: isPlaceholder, // Set based on parameter
          ),
        );
        boardController.addItem(newItem);

        activeItem.value = newItem;
        update(['canvas_stack']);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to handle image: ${e.toString()}');
    }
  }

  void editText() async {
    await Get.to(() => UpdateTextView(item: activeItem.value as StackTextItem));
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
    } else if (originalItem is StackShapeItem) {
      final id = UniqueKey().toString();

      newItem = StackShapeItem(
        id: id,

        offset: newOffset,
        size: originalItem.size,
        content: originalItem.content?.copyWith(),
        angle: originalItem.angle,
      );
    } else if (originalItem is StackChartItem) {
      final id = UniqueKey().toString();

      newItem = StackChartItem(
        id: id,

        offset: newOffset,
        size: originalItem.size,
        content: originalItem.content?.copyWith(),
        angle: originalItem.angle,
      );
    } else {
      return; // Unsupported item type
    }

    boardController.addItem(newItem);
    activeItem.value = newItem;

    update(['canvas_stack', 'bottom_sheet']);
  }

  // In CanvasController class, add:
  final PermissionService permissionService = Get.find<PermissionService>();

  // Updated exportAsImage method

  Future<File?> exportAsImage([String fileName = "inkaro_card"]) async {
    try {
      isExporting = true;
      update(['export_button']);
      boardController.unSelectAll();
      _showProgressDialog();
      exportProgress.value = 0.0;

      if (kDebugMode) debugPrint('Starting image export: $fileName');

      // Stage 1: Permission check (10%)
      exportProgress.value = 10.0;

      final exportKey = GlobalKey();
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
        pixelRatio: 4,
        delay: Duration(seconds: 4),
      );
      exportProgress.value = 50.0;
      if (kDebugMode) debugPrint('Widget captured successfully');

      if (kIsWeb) {
        // Stage 3: Web download (50%)
        exportProgress.value = 60.0;
        final blob = html.Blob([image]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', '$fileName.png')
          ..click();
        html.Url.revokeObjectUrl(url);
        exportProgress.value = 100.0;
        AppToast.success(message: 'Image downloaded');
        if (kDebugMode) debugPrint('Web download triggered');
        return File('$fileName.png'); // Dummy file for web
      } else {
        // Stage 3: Save to temporary file (20%)
        exportProgress.value = 60.0;
        final tempDir = await getTemporaryDirectory();
        final tempPath = '${tempDir.path}/$fileName.png';
        final tempFile = File(tempPath);
        await tempFile.writeAsBytes(image);
        exportProgress.value = 80.0;
        if (kDebugMode) debugPrint('Image saved to temp file: $tempPath');

        // Stage 4: Save to gallery (20%)
        exportProgress.value = 100.0;

        final params = ShareParams(
          text: "$fileName card",
          title: fileName,
          files: [XFile(tempFile.path)],
        );
        final result = await SharePlus.instance.share(params);

        if (result.status == ShareResultStatus.success) {
          AppToast.success(message: 'Shared Successfully');
        }
        // exportProgress.value = 100.0;
        _closeProgressDialog();

        // final success = await GallerySaver.saveImage(
        //   tempPath,
        //   albumName: 'Canva',
        // );

        // // Delay to ensure gallery save is fully processed
        // await Future.delayed(const Duration(milliseconds: 500));
        exportProgress.value = 100.0;
        // }
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
      _closeProgressDialog();

      return null;
    } finally {
      isExporting = false;
      _closeProgressDialog();
      update(['export_button']);
      if (kDebugMode) debugPrint('Export image cleanup completed');
    }
    return null;
  }

  void _showProgressDialog() {
    Get.dialog(
      ModernProgressDialog(
        progress: exportProgress,
        title: 'Exporting Your Design',
        message: 'This may take a moment...',
      ),
      barrierDismissible: false,
    );
  }

  // Optimized _closeProgressDialog
  void _closeProgressDialog() {
    try {
      if (Get.isDialogOpen ?? false) {
        Get.back(result: true);
      }
      exportProgress.value = 0.0;
      if (kDebugMode) {
        debugPrint('Progress dialog closed and exportProgress reset to 0.0');
      }
    } catch (e) {
      debugPrint('Error closing progress dialog: $e');
      exportProgress.value = 0.0;
    }
  }

  Future<bool> requestPhotosPermission() async {
    if (Platform.isAndroid || Platform.isIOS) {
      if (await Permission.photos.request().isGranted) {
        return true;
      }
      Get.snackbar(
        'Permission Denied',
        'Photos permission is required to save images to the gallery.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return false;
    }
    return true; // Web doesn't require permissions
  }

  Future<void> exportAsPDF([String fileName = "invitation_card"]) async {
    try {
      isExporting = true;
      update(['export_button']);
      boardController.unSelectAll();
      final exportKey = GlobalKey();
      _showProgressDialog();
      exportProgress.value = 0.0;

      // Stage 1: Capture widget (40%)
      exportProgress.value = 10.0;

      final image = await screenshotController.captureFromWidget(
        Material(
          shadowColor: Colors.transparent,
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
        pixelRatio: 5,
        delay: Duration(seconds: 4),
      );

      // Stage 2: Create PDF (30%)
      exportProgress.value = 50.0;
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
      final pdfBytes = await pdf.save();
      exportProgress.value = 70.0;

      if (kIsWeb) {
        // Stage 3: Web download (30%)
        exportProgress.value = 80.0;
        final blob = html.Blob([pdfBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', '$fileName.pdf')
          ..click();
        html.Url.revokeObjectUrl(url);
        exportProgress.value = 100.0;
      } else {
        // Stage 3: Save to temporary file and share (30%)
        exportProgress.value = 80.0;
        final tempDir = await getTemporaryDirectory();
        final pdfPath = '${tempDir.path}/$fileName.pdf';
        final pdfFile = File(pdfPath);
        await pdfFile.writeAsBytes(pdfBytes);
        exportProgress.value = 100.0;

        // Share the PDF
        final params = ShareParams(
          text: 'Save or open your PDF',
          files: [XFile(pdfFile.path)],
          subject: '$fileName.pdf',
        );
        final result = await SharePlus.instance.share(params);

        if (result.status == ShareResultStatus.success) {
          AppToast.success(message: 'PDF shared successfully');
        }
        _closeProgressDialog();

        if (await pdfFile.exists()) {
          // Get.to(() => ExportPreviewPage(imagePath: "", pdfPath: pdfPath));
        } else {
          throw Exception('Failed to create PDF file');
        }
      }
    } catch (e, s) {
      debugPrint('Export PDF failed: $e\n$s');
      Get.snackbar(
        'Error',
        'Failed to export PDF: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isExporting = false;
      _closeProgressDialog();
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

  void saveCopy() {
    if (isLocaleTemplate) {
      _saveDraftLocale(isCopy: true);
    } else {
      _saveDraftLocale(isCopy: true);

      // _saveToFirestore(isCopy: true);
    }
  }

  void saveDraft() {
    if (isLocaleTemplate) {
      _saveDraftLocale();
    } else {
      _saveToFirestore();
    }
  }

  /// Save current design as draft to Firebase
  Future<void> _saveToFirestore({bool isCopy = false}) async {
    try {
      AppToast.loading(message: "uploading changes");
      final currentItems = boardController.getAllData();

      CardTemplate template = CardTemplate(
        imagePath: "",
        categoryId: 'birthday',
        id: isCopy == true ? Uuid().v4() : initialTemplate!.id,
        name: templateName.isEmpty ? 'Untitled Template' : templateName.value,
        items: currentItems.map((e) => deserializeItem(e).toJson()).toList(),
        width: initialTemplate!.width,
        height: initialTemplate!.height,
        category: 'birthday',
        tags: ['default'],
        isPremium: false,

        isDraft: true,
        backgroundHue: backgroundHue.value.roundToDouble(),
      );
      final file = await _generateThumbnail(
        "${template.id}_${template.id}",
        showDialog: false,
      );

      if (file != null) {
        template = template.copyWith(thumbnailUrl: file.path);
      }
      await uploadTemplate(template);
      AppToast.closeLoading();
    } catch (err) {
      print("xxxxxxxxxxxxxxxxxxxx");
      print(err);
      AppToast.error(message: err.toString());
    }
  }

  Future<void> saveAsPublicProject() async {
    try {
      AppToast.loading(message: 'Publishing template...');
      final currentItems = boardController.getAllData();

      // Generate thumbnail for the public project
      final thumbnailFile = await _generateThumbnail(
        "public_project_${Uuid().v4()}",
      );

      if (thumbnailFile == null) {
        throw Exception('Failed to generate thumbnail for public project');
      }

      // Create the template with current state
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
        backgroundHue: backgroundHue.value.roundToDouble(),
        backgroundImageUrl: selectedBackground.value,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        thumbnailUrl: kIsWeb ? null : thumbnailFile.path, // Set thumbnail URL
      );

      // Upload template to Firebase
      await uploadTemplate(template);

      AppToast.closeLoading();
      AppToast.success(message: 'Template published successfully');
    } catch (err) {
      debugPrint('Error publishing template: $err');
      AppToast.closeLoading();
      AppToast.error(message: 'Failed to publish template: ${err.toString()}');
    }
  }
  // Add these methods to your CanvasController class

  Future<void> _saveDraftLocale({
    bool isCopy = false,
    bool showDialog = false,
  }) async {
    try {
      AppToast.loading(message: 'Saving template...');
      final currentItems = boardController.getAllData();

      // Create the template with current state
      CardTemplate template = CardTemplate(
        imagePath: "",
        categoryId: 'birthday',
        id: isCopy ? Uuid().v4() : initialTemplate!.id,
        name: templateName.value.isEmpty
            ? 'Untitled Template'
            : templateName.value,
        items: currentItems.map((e) => deserializeItem(e).toJson()).toList(),
        width: initialTemplate?.width ?? 800,
        height: initialTemplate?.height ?? 600,
        category: 'birthday',
        tags: ['default'],
        isPremium: false,
        isDraft: true,
        backgroundHue: backgroundHue.value.roundToDouble(),
        backgroundImageUrl: selectedBackground.value,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        thumbnailUrl: null,
      );

      // Generate thumbnail without sharing
      final file = await _generateThumbnail(
        "${template.id}_${template.id}",
        showDialog: showDialog,
      );

      if (file != null) {
        template = template.copyWith(thumbnailUrl: file.path);

        // Save to local storage
        await StorageService.addDraft(template);

        try {
          final profileController = Get.find<ProfileController>();
          await profileController.loadLocalDrafts(); // Reload from disk
          await profileController.refreshDrafts(); // Update UI
        } catch (e) {
          // Profile page not open, ignore
        }
        AppToast.success(message: 'Template saved locally!');
      } else {
        throw Exception('Failed to generate thumbnail');
      }
    } catch (err) {
      debugPrint('Error saving to local storage: $err');
      AppToast.error(
        message: 'Failed to save template locally: ${err.toString()}',
      );
    } finally {
      AppToast.closeLoading();
    }
  }

  Future<File?> _generateThumbnail(
    String fileName, {
    bool showDialog = false,
  }) async {
    try {
      isExporting = true;
      update(['export_button']);
      boardController.unSelectAll();
      if (showDialog) {
        _showProgressDialog();
      }
      exportProgress.value = 0.0;

      if (kDebugMode) debugPrint('Starting image export for draft: $fileName');

      // Stage 1: Capture widget (50%)
      exportProgress.value = 10.0;
      final exportKey = GlobalKey();
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
      exportProgress.value = 50.0;
      if (kDebugMode) debugPrint('Widget captured successfully');

      if (kIsWeb) {
        // Stage 2: Web handling (50%)
        exportProgress.value = 60.0;
        final blob = html.Blob([image]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', '$fileName.png');
        anchor.click();
        html.Url.revokeObjectUrl(url);
        exportProgress.value = 100.0;
        AppToast.success(message: 'Image saved for draft');
        if (kDebugMode) debugPrint('Web download triggered');
        return File('$fileName.png'); // Dummy file for web
      } else {
        // Stage 2: Save to temporary file (50%)
        exportProgress.value = 60.0;
        final tempDir = await getTemporaryDirectory();
        final tempPath = '${tempDir.path}/$fileName.png';
        final tempFile = File(tempPath);
        await tempFile.writeAsBytes(image);
        exportProgress.value = 100.0;
        if (kDebugMode) debugPrint('Image saved to temp file: $tempPath');
        return tempFile;
      }
    } catch (e, s) {
      debugPrint('Export Image failed: $e\nStack trace: $s');
      AppToast.error(message: 'Failed to export image: ${e.toString()}');
      return null;
    } finally {
      isExporting = false;
      _closeProgressDialog();
      update(['export_button']);
      if (kDebugMode) debugPrint('Export image cleanup completed');
    }
  }

  void setActiveItem(StackItem? item) {
    if (item == null && activeItem.value != null) {
      boardController.setAllItemStatuses(StackItemStatus.idle);
      activePanel.value = PanelType.none;
    }

    if (item == null) {
      activePanel.value = PanelType.none;
    }
    activeItem.value = item;
  }
}

// Enterprise-Grade Progress Dialog

class ModernProgressDialog extends StatelessWidget {
  final RxDouble progress;
  final String? title;
  final String? message;

  const ModernProgressDialog({
    super.key,
    required this.progress,
    this.title,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: ObxValue<RxDouble>(
          (progressValue) => Container(
            constraints: const BoxConstraints(maxWidth: 420),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF000000).withOpacity(0.04),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: const Color(0xFF000000).withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
              ],
            ),
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                          letterSpacing: -0.4,
                        ),
                      ),
                    if (message != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        message!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF6B7280),
                          letterSpacing: -0.2,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 32),
                // Progress Bar Section
                Column(
                  children: [
                    // Main Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        height: 6,
                        child: Stack(
                          children: [
                            // Background track
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5E7EB),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            // Progress fill
                            AnimatedFractionallySizedBox(
                              widthFactor: progressValue.value / 100,
                              alignment: Alignment.centerLeft,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF2563EB),
                                      const Color(0xFF1D4ED8),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Progress Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Processing...',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                            letterSpacing: -0.1,
                          ),
                        ),
                        Text(
                          '${progressValue.value.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          progress,
        ),
      ),
    );
  }
}

// Usage in CanvasController - Replace _showProgressDialog() with:
/*
void _showProgressDialog() {
  Get.dialog(
    ModernProgressDialog(
      progress: exportProgress,
      title: 'Preparing Your Export',
      message: 'Your file is being processed and will be ready shortly.',
    ),
    barrierDismissible: false,
  );
}
*/
class _ProgressRingPainter extends CustomPainter {
  final double progress;

  _ProgressRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 3.5;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background ring - very subtle
    final bgPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress ring with smooth gradient
    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.blue.shade300,
          Colors.blue.shade500,
          Colors.blue.shade400,
        ],
        stops: const [0.0, 0.6, 1.0],
        transform: GradientRotation(-math.pi / 2 + (progress * math.pi * 2)),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      progress * math.pi * 2,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// Usage in CanvasController - Replace _showProgressDialog() with:
/*
void _showProgressDialog() {
  Get.dialog(
    ModernProgressDialog(
      progress: exportProgress,
      title: 'Exporting Your Design',
      message: 'This may take a moment...',
    ),
    barrierDismissible: false,
  );
}
*/
class ProgressRingPainter extends CustomPainter {
  final double progress;

  ProgressRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 4.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background ring
    final bgPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress ring with gradient
    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.blue.shade300,
          Colors.blue.shade500,
          Colors.purple.shade400,
        ],
        stops: const [0.0, 0.5, 1.0],
        transform: GradientRotation(progress * math.pi * 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      progress * math.pi * 2,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class ProgressStep {
  final String label;

  ProgressStep({required this.label});
}
