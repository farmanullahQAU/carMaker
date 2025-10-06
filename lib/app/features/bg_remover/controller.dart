// import 'dart:async';
// import 'dart:io';
// import 'dart:typed_data';
// import 'dart:ui' as ui;

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';
// import 'package:image_picker/image_picker.dart';

// class BackgroundRemovalController extends GetxController {
//   final SelfieSegmenter segmenter = SelfieSegmenter(mode: SegmenterMode.single);

//   final Rx<File?> inputImage = Rx<File?>(null);
//   final Rx<Uint8List?> outputBytes = Rx<Uint8List?>(null);
//   final RxBool isProcessing = false.obs;

//   Future<void> pickAndProcessImage() async {
//     final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (picked != null) {
//       inputImage.value = File(picked.path);
//       await processImage();
//     }
//   }

//   Future<void> processImage() async {
//     if (inputImage.value == null) return;

//     isProcessing.value = true;

//     final input = InputImage.fromFile(inputImage.value!);
//     final mask = await segmenter.processImage(input);
//     if (mask == null) {
//       isProcessing.value = false;
//       return;
//     }

//     // Decode original
//     final originalBytes = await inputImage.value!.readAsBytes();
//     final codec = await ui.instantiateImageCodec(originalBytes);
//     final frame = await codec.getNextFrame();
//     final src = frame.image;

//     // Draw result
//     final recorder = ui.PictureRecorder();
//     final canvas = Canvas(recorder);
//     canvas.drawImage(src, Offset.zero, Paint());

//     final maskImage = await buildMaskImage(mask);

//     final paint = Paint()
//       ..blendMode = BlendMode.dstIn
//       ..shader = ImageShader(
//         maskImage,
//         TileMode.clamp,
//         TileMode.clamp,
//         Matrix4.identity().storage,
//       );

//     canvas.drawRect(
//       Rect.fromLTWH(0, 0, src.width.toDouble(), src.height.toDouble()),
//       paint,
//     );

//     final picture = recorder.endRecording();
//     final resultImage = await picture.toImage(src.width, src.height);

//     // Convert ui.Image → PNG Uint8List
//     final byteData = await resultImage.toByteData(
//       format: ui.ImageByteFormat.png,
//     );
//     outputBytes.value = byteData?.buffer.asUint8List();

//     isProcessing.value = false;
//   }

//   Future<ui.Image> buildMaskImage(SegmentationMask mask) async {
//     final pixels = Uint8List(mask.width * mask.height * 4);
//     for (int i = 0; i < mask.width * mask.height; i++) {
//       final v = (mask.confidences[i] * 255).clamp(0, 255).toInt();
//       final idx = i * 4;
//       pixels[idx] = 0;
//       pixels[idx + 1] = 0;
//       pixels[idx + 2] = 0;
//       pixels[idx + 3] = v;
//     }
//     final completer = Completer<ui.Image>();
//     ui.decodeImageFromPixels(
//       pixels,
//       mask.width,
//       mask.height,
//       ui.PixelFormat.rgba8888,
//       (img) => completer.complete(img),
//     );
//     return completer.future;
//   }

//   @override
//   void onClose() {
//     segmenter.close();
//     super.onClose();
//   }
// }
