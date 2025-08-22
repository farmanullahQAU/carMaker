import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';

/// StorageService handles image uploads to Firebase Storage.
class FirebaseStorageService {
  static const String _imagesStoragePath = 'card_images/templates';
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  /// Uploads an image to Firebase Storage with compression, returns the download URL.
  Future<String> uploadImage(
    File imageFile,
    String templateId,
    String imageType, {
    String? fileName,
  }) async {
    try {
      final compressedBytes = await _compressImage(imageFile);
      final effectiveFileName = fileName ?? '${_uuid.v4()}.jpg';

      final storageRef = _storage
          .ref()
          .child(_imagesStoragePath)
          .child(templateId)
          .child(imageType)
          .child(effectiveFileName);

      final uploadTask = await storageRef.putData(
        compressedBytes,
        SettableMetadata(cacheControl: 'public, max-age=31536000'),
      );

      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to upload image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      rethrow;
    }
  }

  /// Compresses an image to reduce size (max 1920x1080, 85% quality).
  Future<Uint8List> _compressImage(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) throw Exception('Invalid image file');

      // Resize if needed
      if (image.width > 1920 || image.height > 1080) {
        image = img.copyResize(image, width: 1920);
      }

      // Encode as JPEG with 85% quality
      return Uint8List.fromList(img.encodeJpg(image, quality: 85));
    } catch (e) {
      return await imageFile.readAsBytes(); // Fallback to original
    }
  }
}
