import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:cardmaker/app/features/editor/edit_item/view.dart';
import 'package:cardmaker/app/features/editor/editor_canvas.dart';
import 'package:cardmaker/app/features/profile/controller.dart';
import 'package:cardmaker/app/features/profile/view.dart';
import 'package:cardmaker/app/routes/app_routes.dart';
import 'package:cardmaker/core/helper/image_helper.dart';
import 'package:cardmaker/core/utils/toast_helper.dart';
import 'package:cardmaker/core/values/enums.dart';
import 'package:cardmaker/models/card_template.dart';
import 'package:cardmaker/services/admob_service.dart';
import 'package:cardmaker/services/auth_service.dart';
import 'package:cardmaker/services/firestore_service.dart';
import 'package:cardmaker/services/permission_handler.dart';
import 'package:cardmaker/services/storage_service.dart';
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
  late bool isLocaleTemplate = true;
  late bool showSaveCopyBtn = true;

  final StackBoardController boardController = StackBoardController();
  final RxString selectedFont = 'Poppins'.obs;
  final RxDouble fontSize = 24.0.obs;
  final Rx<Color> fontColor = Colors.black.obs;
  final RxnString selectedBackground = RxnString();
  final RxDouble backgroundHue = 0.0.obs;
  final Rx<Color> backgroundColor = Colors.white.obs;
  final RxBool isBackgroundGradient =
      true.obs; // true for gradient, false for solid
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

  final RxList<StackImageItem> profileImageItems = <StackImageItem>[].obs;
  final RxBool showHueSlider = false.obs;
  final RxBool showStickerPanel = false.obs;
  final RxInt selectedToolIndex = 0.obs;
  final ImagePicker _picker = ImagePicker();

  final GlobalKey stackBoardKey = GlobalKey();
  final RxBool isTemplateLoaded = false.obs;
  final RxDouble canvasScale = 1.0.obs;
  final RxDouble scaledCanvasWidth = 0.0.obs;
  final RxDouble scaledCanvasHeight = 0.0.obs;
  bool get isOwner => authService.user?.uid == "aP3FVBY7kWgBnJorqVrYha3lFaa2";

  // ==================== RESPONSIVE HELPERS ====================
  Offset toRelativeOffset(Offset absolute, Size canvasSize) {
    return Offset(
      absolute.dx / canvasSize.width,
      absolute.dy / canvasSize.height,
    );
  }

  Size toRelativeSize(Size absolute, Size canvasSize) {
    return Size(
      absolute.width / canvasSize.width,
      absolute.height / canvasSize.height,
    );
  }

  Offset toAbsoluteOffset(Offset relative, Size canvasSize) {
    return Offset(
      relative.dx * canvasSize.width,
      relative.dy * canvasSize.height,
    );
  }

  Size toAbsoluteSize(Size relative, Size canvasSize) {
    return Size(
      relative.width * canvasSize.width,
      relative.height * canvasSize.height,
    );
  }

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
    backgroundHue.value = initialTemplate!.backgroundHue ?? 0.0;
    backgroundColor.value = initialTemplate?.backgroundColor ?? Colors.white;
    isBackgroundGradient.value = initialTemplate?.isBackgroundGradient ?? true;
    boardController.clear();

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
      boardController.updateItem(item);
      boardController.updateBasic(item.id, status: StackItemStatus.moving);

      if (activeItem.value?.id == item.id) {
        activeItem(item);
      }
      update(['canvas_stack', 'stack_board']);
    }
  }

  void addIcon(IconData icon) {
    final content = IconItemContent(
      icon: icon,
      color: Colors.black,
      size: 24.0,
    );
    final canvasSize = Size(scaledCanvasWidth.value, scaledCanvasHeight.value);
    final relSize = Size(0.1, 0.1);
    final absSize = toAbsoluteSize(relSize, canvasSize);

    final iconItem = StackIconItem(
      id: UniqueKey().toString(),
      size: absSize,
      offset: Offset(canvasSize.width * 0.4, canvasSize.height * 0.4),
      content: content,
    );

    boardController.addItem(iconItem);
    activeItem.value = iconItem;
    activePanel.value = PanelType.icons;
  }

  // ==================== DYNAMIC CANVAS SIZING (NO CONSTANTS) ====================
  void updateCanvasAndLoadTemplate(
    BoxConstraints constraints,
    BuildContext context,
  ) {
    if (isTemplateLoaded.value) return;

    final double screenWidth = constraints.maxWidth;
    final double screenHeight = constraints.maxHeight;
    final double usableWidth = screenWidth * 0.98;
    final double usableHeight = screenHeight * 0.82;
    final double aspectRatio = initialTemplate!.width / initialTemplate!.height;

    double targetWidth = usableWidth;
    double targetHeight = targetWidth / aspectRatio;

    if (targetHeight > usableHeight) {
      targetHeight = usableHeight;
      targetWidth = targetHeight * aspectRatio;
    }

    final double screenDiag = math.sqrt(
      screenWidth * screenWidth + screenHeight * screenHeight,
    );
    final double designDiag = math.sqrt(
      initialTemplate!.width * initialTemplate!.width +
          initialTemplate!.height * initialTemplate!.height,
    );
    final double boost = (screenDiag / designDiag).clamp(1.0, 2.5);

    double boostedW = targetWidth * boost;
    double boostedH = targetHeight * boost;

    if (boostedW <= screenWidth * 0.9 && boostedH <= screenHeight * 0.75) {
      targetWidth = boostedW;
      targetHeight = boostedH;
    }

    targetWidth = targetWidth.clamp(300.0, screenWidth * 0.95);
    targetHeight = targetHeight.clamp(200.0, screenHeight * 0.8);

    scaledCanvasWidth.value = targetWidth;
    scaledCanvasHeight.value = targetHeight;
    canvasScale.value = targetWidth / initialTemplate!.width;

    updateStackBoardRenderSize(Size(targetWidth, targetHeight));

    debugPrint(
      'Canvas: ${targetWidth.toStringAsFixed(0)}×${targetHeight.toStringAsFixed(0)} '
      '| Scale: ${canvasScale.value.toStringAsFixed(2)}x '
      '| Screen: ${screenWidth.toStringAsFixed(0)}×${screenHeight.toStringAsFixed(0)}',
    );

    populateData(initialTemplate!, context, targetWidth, targetHeight);
    isTemplateLoaded.value = true;
    update(['canvas_stack']);
  }

  // ==================== LOAD WITH RELATIVE → ABSOLUTE ====================
  void populateData(
    CardTemplate template,
    BuildContext context,
    double scaledCanvasWidth,
    double scaledCanvasHeight,
  ) async {
    selectedBackground.value = template.backgroundImageUrl;
    templateName.value = template.name;
    backgroundHue.value = template.backgroundHue ?? 0.0;
    backgroundColor.value = template.backgroundColor ?? Colors.white;
    isBackgroundGradient.value = template.isBackgroundGradient ?? true;
    boardController.clear();
    profileImageItems.clear();

    final Size canvasSize = Size(scaledCanvasWidth, scaledCanvasHeight);
    final Size originalCanvasSize = Size(template.width, template.height);

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

        // Extract relative values from JSON
        final double relX = itemJson['offset']['dx'].toDouble();
        final double relY = itemJson['offset']['dy'].toDouble();
        final double relW = itemJson['size']['width'].toDouble();
        final double relH = itemJson['size']['height'].toDouble();

        final Offset absOffset = toAbsoluteOffset(
          Offset(relX, relY),
          canvasSize,
        );
        final Size absSize = toAbsoluteSize(Size(relW, relH), canvasSize);

        StackItem updatedItem;

        if (item is StackTextItem) {
          final double baseFontSize = item.content!.style!.fontSize!;
          final double scaledFontSize = baseFontSize * canvasScale.value;
          final updatedStyle = item.content!.style!.copyWith(
            fontSize: scaledFontSize,
          );

          updatedItem = item.copyWith(
            offset: absOffset,
            size: absSize,
            status: StackItemStatus.idle,
            content: item.content!.copyWith(style: updatedStyle),
          );
        } else if (item is StackImageItem) {
          updatedItem = item.copyWith(
            offset: absOffset,
            size: absSize,
            status: StackItemStatus.idle,
          );
        } else if (item is StackShapeItem) {
          updatedItem = item.copyWith(
            offset: absOffset,
            size: absSize,
            status: StackItemStatus.idle,
          );
        } else if (item is StackIconItem) {
          updatedItem = item.copyWith(
            offset: absOffset,
            size: absSize,
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

    update(['canvas_stack', 'bottom_sheet']);
  }

  void addProfileImage(
    String assetPath, {
    Offset? offset,
    Size? size,
    bool isPlaceholder = false,
  }) {
    final canvasSize = Size(scaledCanvasWidth.value, scaledCanvasHeight.value);
    final relSize = Size(436 / 800, 574 / 600);
    final absSize = toAbsoluteSize(relSize, canvasSize);
    final absOffset =
        offset ?? toAbsoluteOffset(Offset(690 / 800, 115 / 600), canvasSize);

    final profileImage = StackImageItem(
      id: 'profile_image_${DateTime.now().millisecondsSinceEpoch}',
      offset: absOffset,
      size: absSize,
      content: ImageItemContent(
        assetName: assetPath,
        isPlaceholder: isPlaceholder,
      ),
      isProfileImage: true,
      lockZOrder: true,
      status: StackItemStatus.idle,
    );
    profileImageItems.add(profileImage);
    update(['canvas_stack']);
  }

  void addSticker(String data) {
    final canvasSize = Size(scaledCanvasWidth.value, scaledCanvasHeight.value);
    final relSize = Size(0.2, 0.2);
    final absSize = toAbsoluteSize(relSize, canvasSize);

    final content = TextItemContent(
      data: data,
      googleFont: 'Roboto',
      style: TextStyle(fontSize: 24 * canvasScale.value, color: Colors.black),
    );

    final textItem = StackTextItem(
      id: UniqueKey().toString(),
      size: absSize,
      offset: Offset(canvasSize.width * 0.4, canvasSize.height * 0.4),
      content: content,
    );

    boardController.addItem(textItem);
    activeItem.value = textItem;
    update(['canvas_stack', 'bottom_sheet']);
  }

  void updateBackgroundHue(double hue) {
    backgroundHue.value = hue;
    isBackgroundGradient.value = true;
    update(['canvas_stack']);
  }

  void updateBackgroundColor(Color color) {
    backgroundColor.value = color;
    isBackgroundGradient.value = false;
    update(['canvas_stack']);
  }

  void setBackgroundMode(bool isGradient) {
    isBackgroundGradient.value = isGradient;
    update(['canvas_stack']);
  }

  void toggleGrid() {
    showGrid.value = !showGrid.value;
    update(['canvas_stack']);
  }

  Future<void> uploadTemplate(CardTemplate template) async {
    try {
      if (authService.user == null) {
        Get.to(() => ProfileTab());
        return;
      }
      File? thumbnailFile;
      File? backgroundFile;
      String? backgroundImageUrl = template.backgroundImageUrl;

      if (selectedBackground.value?.isNotEmpty ?? false) {
        if (!selectedBackground.value!.startsWith('http')) {
          backgroundFile = File(selectedBackground.value!);
        } else {
          backgroundImageUrl = selectedBackground.value;
        }
      }

      if (template.thumbnailUrl != null) {
        thumbnailFile = File(template.thumbnailUrl!);
      }

      await firestoreService.addTemplate(
        template.copyWith(backgroundImageUrl: backgroundImageUrl),
        thumbnailFile: thumbnailFile,
        backgroundFile: backgroundFile,
      );

      if (thumbnailFile != null) {
        _cleanupTempFiles(thumbnailFile, backgroundFile);
      }
    } catch (err) {
      ToastHelper.error(err.toString());
    }
  }

  void _cleanupTempFiles(File thumbnailFile, File? backgroundFile) async {
    try {
      if (await thumbnailFile.exists()) await thumbnailFile.delete();
      if (backgroundFile != null && await backgroundFile.exists())
        await backgroundFile.delete();
    } catch (e) {
      debugPrint('Error cleaning up temp files: $e');
    }
  }

  Future<void> performHeavyOperation(Function operation) async {
    final loadingDialog = Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    try {
      await Future.microtask(() => operation());
    } finally {
      if (Get.isDialogOpen ?? false) Get.back();
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
      final newLockState = !(currentItem.lockZOrder);
      final updatedItem = currentItem.copyWith(lockZOrder: newLockState);
      boardController.updateItem(updatedItem);

      if (activeItem.value?.id == itemId) {
        activeItem.value = null;
        activeItem.value = updatedItem;
        activeItem.refresh();
      }
      update(['canvas_stack', 'export_button', 'z_lock_button']);
    }
  }

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

  bool isItemAtFront() {
    if (activeItem.value == null) return false;
    final itemId = activeItem.value!.id;
    try {
      final index = boardController.getIndexById(itemId);
      final totalItems = boardController.innerData.length;
      return totalItems > 0 && index == totalItems - 1;
    } catch (e) {
      return false;
    }
  }

  void toggleItemZOrder() {
    if (activeItem.value == null) return;
    if (isItemAtFront()) {
      sendToBack();
    } else {
      bringToFront();
    }
  }

  Future<void> replaceImageItem(StackImageItem item) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final canvasSize = Size(
          scaledCanvasWidth.value,
          scaledCanvasHeight.value,
        );
        final relSize = toRelativeSize(item.size, canvasSize);
        final absSize = toAbsoluteSize(relSize, canvasSize);

        final newItem = StackImageItem(
          offset: item.offset,
          size: absSize,
          content: item.content?.copyWith(
            filePath: image.path,
            isPlaceholder: false,
          ),
          lockZOrder: item.lockZOrder,
          angle: item.angle,
          isProfileImage: item.isProfileImage,
          isNewImage: true,
        );
        boardController.removeById(item.id);
        boardController.addItem(newItem);
        activeItem.value = newItem;
        update(['canvas_stack']);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to handle image: ${e.toString()}');
    }
  }

  Future<void> pickAndAddImage({bool isPlaceholder = false}) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final canvasSize = Size(
          scaledCanvasWidth.value,
          scaledCanvasWidth.value,
        );
        final relSize = Size(0.3, 0.3);
        final absSize = toAbsoluteSize(relSize, canvasSize);

        final newItem = StackImageItem(
          id: UniqueKey().toString(),
          offset: Offset(canvasSize.width * 0.1, canvasSize.height * 0.1),
          size: absSize,
          lockZOrder: false,
          isNewImage: !isPlaceholder,
          content: ImageItemContent(
            filePath: image.path,
            isPlaceholder: isPlaceholder,
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
    if (activeItem.value == null) {
      print("nnnnnnnnnnn");
      return;
    }

    final originalItem = activeItem.value!;
    final canvasSize = Size(scaledCanvasWidth.value, scaledCanvasHeight.value);

    final relOffset = toRelativeOffset(originalItem.offset, canvasSize);
    final relSize = toRelativeSize(originalItem.size, canvasSize);
    final newRelOffset = Offset(relOffset.dx + 0.05, relOffset.dy + 0.05);
    final newAbsOffset = toAbsoluteOffset(newRelOffset, canvasSize);
    final newAbsSize = toAbsoluteSize(relSize, canvasSize);

    StackItem newItem;

    if (originalItem is StackTextItem) {
      newItem = StackTextItem(
        id: UniqueKey().toString(),
        offset: newAbsOffset,
        size: newAbsSize,
        content: originalItem.content?.copyWith(),
      );
    } else if (originalItem is StackImageItem) {
      newItem = StackImageItem(
        id: UniqueKey().toString(),
        offset: newAbsOffset,
        size: newAbsSize,
        content: originalItem.content?.copyWith(),
        angle: originalItem.angle,
        isProfileImage: originalItem.isProfileImage,
      );
    } else if (originalItem is StackShapeItem) {
      newItem = StackShapeItem(
        id: UniqueKey().toString(),
        offset: newAbsOffset,
        size: newAbsSize,
        content: originalItem.content?.copyWith(),
        angle: originalItem.angle,
      );
    } else if (originalItem is StackChartItem) {
      newItem = StackChartItem(
        id: UniqueKey().toString(),
        offset: newAbsOffset,
        size: newAbsSize,
        content: originalItem.content?.copyWith(),
        angle: originalItem.angle,
      );
    } else if (originalItem is StackIconItem) {
      newItem = StackIconItem(
        id: UniqueKey().toString(),
        offset: newAbsOffset,
        size: newAbsSize,
        content: originalItem.content?.copyWith(),
        angle: originalItem.angle,
      );
    } else {
      return;
    }

    boardController.addItem(newItem);
    activeItem.value = newItem;
    update(['canvas_stack', 'bottom_sheet']);
  }

  final PermissionService permissionService = Get.find<PermissionService>();

  // ==================== EXPORT METHODS (UNCHANGED) ====================
  Future<File?> exportAsImage([String fileName = "inkaro_card"]) async {
    try {
      // Try to show rewarded ad before allowing export.
      await AdMobService().showRewardedAdBeforeExport();

      isExporting = true;
      update(['export_button']);
      boardController.unSelectAll();
      _showProgressDialog();
      exportProgress.value = 0.0;

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
        pixelRatio: 5, // Increased from 4 to 5 to match PDF quality
        delay: Duration(seconds: 4),
      );
      exportProgress.value = 50.0;

      if (kIsWeb) {
        exportProgress.value = 60.0;
        final blob = html.Blob([image]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', '$fileName.png')
          ..click();
        html.Url.revokeObjectUrl(url);
        exportProgress.value = 100.0;
        ToastHelper.success('Image downloaded');
        return File('$fileName.png');
      } else {
        exportProgress.value = 60.0;
        final tempDir = await getTemporaryDirectory();
        final tempPath = '${tempDir.path}/$fileName.png';
        final tempFile = File(tempPath);
        await tempFile.writeAsBytes(image);
        exportProgress.value = 80.0;

        final params = ShareParams(
          text: "$fileName card",
          title: fileName,
          files: [XFile(tempFile.path)],
        );
        final result = await SharePlus.instance.share(params);

        if (result.status == ShareResultStatus.success) {
          ToastHelper.success('Shared Successfully');
        }
        exportProgress.value = 100.0;
        _closeProgressDialog();
      }
    } catch (e, s) {
      debugPrint('Export Image failed: $e\nStack trace: $s');
      Get.snackbar('Error', 'Failed to export image: ${e.toString()}');
      _closeProgressDialog();
      return null;
    } finally {
      isExporting = false;
      _closeProgressDialog();
      update(['export_button']);
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

  void _closeProgressDialog() {
    try {
      if (Get.isDialogOpen ?? false) {
        Get.back(result: true);
      }
      exportProgress.value = 0.0;
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
      Get.snackbar('Permission Denied', 'Photos permission is required.');
      return false;
    }
    return true;
  }

  Future<void> exportAsPDF([String fileName = "invitation_card"]) async {
    try {
      // Try to show rewarded ad before allowing export.
      await AdMobService().showRewardedAdBeforeExport();

      isExporting = true;
      update(['export_button']);
      boardController.unSelectAll();
      final exportKey = GlobalKey();
      _showProgressDialog();
      exportProgress.value = 0.0;

      exportProgress.value = 20.0;
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

      exportProgress.value = 50.0;
      final pdf = pw.Document();
      final imageProvider = pw.MemoryImage(image);
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(
            scaledCanvasWidth.value,
            scaledCanvasHeight.value,
          ),
          build: (pw.Context context) =>
              pw.Center(child: pw.Image(imageProvider)),
        ),
      );
      final pdfBytes = await pdf.save();
      exportProgress.value = 70.0;

      if (kIsWeb) {
        exportProgress.value = 80.0;
        final blob = html.Blob([pdfBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', '$fileName.pdf')
          ..click();
        html.Url.revokeObjectUrl(url);
        exportProgress.value = 100.0;
      } else {
        exportProgress.value = 80.0;
        final tempDir = await getTemporaryDirectory();
        final pdfPath = '${tempDir.path}/$fileName.pdf';
        final pdfFile = File(pdfPath);
        await pdfFile.writeAsBytes(pdfBytes);
        exportProgress.value = 100.0;

        final params = ShareParams(
          text: 'Save or open your PDF',
          files: [XFile(pdfFile.path)],
          subject: '$fileName.pdf',
        );
        final result = await SharePlus.instance.share(params);

        if (result.status == ShareResultStatus.success) {
          ToastHelper.success('PDF shared successfully');
        }
        _closeProgressDialog();
      }
    } catch (e, s) {
      debugPrint('Export PDF failed: $e\n$s');
      Get.snackbar('Error', 'Failed to export PDF: ${e.toString()}');
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
      );
    }
  }

  void removeBackgroundImage() {
    selectedBackground.value = null;
    update(['canvas_stack']);
  }

  void saveCopy() => isLocaleTemplate
      ? _saveDraftLocale(isCopy: true)
      : _saveDraftLocale(isCopy: true);

  void saveDraft() =>
      isLocaleTemplate ? _saveDraftLocale() : _saveToFirestore();

  // ==================== SAVE WITH RELATIVE UNITS ====================
  Future<void> _saveToFirestore({bool isCopy = false}) async {
    try {
      ToastHelper.loading("uploading changes");
      final currentItems = boardController.getAllData();
      final Size canvasSize = Size(
        scaledCanvasWidth.value,
        scaledCanvasHeight.value,
      );

      final List<Map<String, dynamic>> relativeItems = currentItems.map((
        itemData,
      ) {
        final item = deserializeItem(itemData);
        final Offset relOffset = toRelativeOffset(item.offset, canvasSize);
        final Size relSize = toRelativeSize(item.size, canvasSize);

        dynamic content = item.content;
        if (item is StackTextItem && content?.style?.fontSize != null) {
          final double originalFontSize =
              content.style.fontSize! / canvasScale.value;
          content = content.copyWith(
            style: content.style.copyWith(fontSize: originalFontSize),
          );
        }

        return item
            .copyWith(offset: relOffset, size: relSize, content: content)
            .toJson();
      }).toList();

      CardTemplate template = CardTemplate(
        imagePath: "",
        categoryId: 'birthday',
        id: isCopy ? Uuid().v4() : initialTemplate!.id,
        name: templateName.isEmpty ? 'Untitled Template' : templateName.value,
        items: relativeItems,
        width: initialTemplate!.width,
        height: initialTemplate!.height,
        category: 'birthday',
        tags: ['default'],
        isPremium: false,
        isDraft: true,
        backgroundHue: backgroundHue.value.roundToDouble(),
        backgroundColor: backgroundColor.value,
        isBackgroundGradient: isBackgroundGradient.value,
      );

      final file = await _generateThumbnail(
        "${template.id}_${template.id}",
        showDialog: false,
      );
      if (file != null) template = template.copyWith(thumbnailUrl: file.path);
      await uploadTemplate(template);
      ToastHelper.dismissAll();
    } catch (err) {
      ToastHelper.error(err.toString());
    }
  }

  Future<void> saveAsPublicProject() async {
    // Navigate to publish project page to get category and project name
    final result = await Get.toNamed(AppRoutes.publishProject);

    if (result == null) {
      // User cancelled, do nothing
      return;
    }

    final categoryId = result['categoryId'] as String;
    final categoryName = result['categoryName'] as String;
    final projectName = result['projectName'] as String;
    final isPremium = result['isPremium'] as bool? ?? false;

    // Now publish with the selected details
    await publishProjectWithDetails(
      categoryId: categoryId,
      categoryName: categoryName,
      projectName: projectName,
      isPremium: isPremium,
    );
  }

  Future<void> publishProjectWithDetails({
    required String categoryId,
    required String categoryName,
    required String projectName,
    bool isPremium = false,
  }) async {
    try {
      ToastHelper.loading('Publishing template...');
      final currentItems = boardController.getAllData();
      final Size canvasSize = Size(
        scaledCanvasWidth.value,
        scaledCanvasHeight.value,
      );

      final List<Map<String, dynamic>> relativeItems = currentItems.map((
        itemData,
      ) {
        final item = deserializeItem(itemData);
        final Offset relOffset = toRelativeOffset(item.offset, canvasSize);
        final Size relSize = toRelativeSize(item.size, canvasSize);

        dynamic content = item.content;
        if (item is StackTextItem && content?.style?.fontSize != null) {
          final double originalFontSize =
              content.style.fontSize! / canvasScale.value;
          content = content.copyWith(
            style: content.style.copyWith(fontSize: originalFontSize),
          );
        }

        return item
            .copyWith(offset: relOffset, size: relSize, content: content)
            .toJson();
      }).toList();

      final thumbnailFile = await _generateThumbnail(
        "public_project_${Uuid().v4()}",
      );
      if (thumbnailFile == null)
        throw Exception('Failed to generate thumbnail');

      final template = CardTemplate(
        imagePath: "",
        categoryId: categoryId,
        id: Uuid().v4(),
        name: projectName.trim().isEmpty
            ? 'Untitled Template'
            : projectName.trim(),
        items: relativeItems,
        width: initialTemplate!.width,
        height: initialTemplate!.height,
        category: categoryName,
        tags: ['default'],
        isPremium: isPremium,
        isDraft: false,
        backgroundHue: backgroundHue.value.roundToDouble(),
        backgroundColor: backgroundColor.value,
        isBackgroundGradient: isBackgroundGradient.value,
        backgroundImageUrl: selectedBackground.value,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        thumbnailUrl: kIsWeb ? null : thumbnailFile.path,
      );

      await uploadTemplate(template);
      ToastHelper.dismissAll();
      ToastHelper.success('Template published successfully');
    } catch (err) {
      debugPrint('Error publishing template: $err');
      ToastHelper.dismissAll();
      ToastHelper.error('Failed to publish template: ${err.toString()}');
    }
  }

  Future<void> _saveDraftLocale({
    bool isCopy = false,
    bool showDialog = false,
  }) async {
    try {
      ToastHelper.loading('Saving template...');
      final currentItems = boardController.getAllData();
      final Size canvasSize = Size(
        scaledCanvasWidth.value,
        scaledCanvasHeight.value,
      );

      final List<Map<String, dynamic>> relativeItems = currentItems.map((
        itemData,
      ) {
        final item = deserializeItem(itemData);
        final Offset relOffset = toRelativeOffset(item.offset, canvasSize);
        final Size relSize = toRelativeSize(item.size, canvasSize);

        dynamic content = item.content;
        if (item is StackTextItem && content?.style?.fontSize != null) {
          final double originalFontSize =
              content.style.fontSize! / canvasScale.value;
          content = content.copyWith(
            style: content.style.copyWith(fontSize: originalFontSize),
          );
        }

        return item
            .copyWith(offset: relOffset, size: relSize, content: content)
            .toJson();
      }).toList();

      CardTemplate template = CardTemplate(
        imagePath: "",
        categoryId: 'birthday',
        id: isCopy ? Uuid().v4() : initialTemplate!.id,
        name: templateName.value.isEmpty
            ? 'Untitled Template'
            : templateName.value,
        items: relativeItems,
        width: initialTemplate?.width ?? 800,
        height: initialTemplate?.height ?? 600,
        category: 'birthday',
        tags: ['default'],
        isPremium: false,
        isDraft: true,
        backgroundHue: backgroundHue.value.roundToDouble(),
        backgroundColor: backgroundColor.value,
        isBackgroundGradient: isBackgroundGradient.value,
        backgroundImageUrl: selectedBackground.value,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        thumbnailUrl: null,
      );

      final file = await _generateThumbnail(
        "${template.id}_${template.id}",
        showDialog: showDialog,
      );
      if (file != null) {
        template = template.copyWith(thumbnailUrl: file.path);
        await StorageService.addDraft(template);

        try {
          final profileController = Get.find<ProfileController>();
          await profileController.loadLocalDrafts();
          await profileController.refreshDrafts();
        } catch (e) {}
        ToastHelper.success('Template saved locally!');
      } else {
        throw Exception('Failed to generate thumbnail');
      }
    } catch (err) {
      debugPrint('Error saving to local storage: $err');
      ToastHelper.error('Failed to save template locally: ${err.toString()}');
    } finally {
      ToastHelper.dismissAll();
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
      if (showDialog) _showProgressDialog();
      exportProgress.value = 0.0;

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

      if (kIsWeb) {
        exportProgress.value = 60.0;
        final blob = html.Blob([image]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', '$fileName.png');
        anchor.click();
        html.Url.revokeObjectUrl(url);
        exportProgress.value = 100.0;
        ToastHelper.success('Image saved for draft');
        return File('$fileName.png');
      } else {
        exportProgress.value = 60.0;
        final tempDir = await getTemporaryDirectory();
        final tempPath = '${tempDir.path}/$fileName.png';
        final tempFile = File(tempPath);
        await tempFile.writeAsBytes(image);
        exportProgress.value = 100.0;
        return tempFile;
      }
    } catch (e, s) {
      debugPrint('Export Image failed: $e\nStack trace: $s');
      ToastHelper.error('Failed to export image: ${e.toString()}');
      return null;
    } finally {
      isExporting = false;
      _closeProgressDialog();
      update(['export_button']);
    }
  }

  void setActiveItem(StackItem? item) {
    if (item == null && activeItem.value != null) {
      boardController.setAllItemStatuses(StackItemStatus.idle);
      activePanel.value = PanelType.none;
    }
    if (item == null) activePanel.value = PanelType.none;
    activeItem.value = item;
  }
}

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
