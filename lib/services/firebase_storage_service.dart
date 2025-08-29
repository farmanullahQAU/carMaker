import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// StorageService handles image uploads to Firebase Storage.
class FirebaseStorageService {
  static const String _imagesStoragePath = 'card_images/templates';
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads an image to Firebase Storage with compression, returns the download URL.
  Future<String> uploadImage(
    File imageFile,
    String templateId,
    String imageType, {
    String? fileName,
    required String extension,
  }) async {
    try {
      // final compressedBytes = await _compressImage(imageFile, extension);

      final storageRef = _storage
          .ref()
          .child(_imagesStoragePath)
          .child(templateId)
          .child(imageType)
          .child(fileName!);
      final uploadTask = await storageRef.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/$extension', // Explicitly set to PNG
        ),
      );
      // final uploadTask = await storageRef.putData(
      //   compressedBytes,
      //   SettableMetadata(
      //     contentType: 'image/$extension', // Explicitly set to PNG
      //   ),
      // );

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
}

/*class FirebaseStorageService {



  static const String _imagesStoragePath = 'card_images/templates';
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads an image to Firebase Storage with compression, returns the download URL.
  Future<String> uploadImage(
    File imageFile,
    String templateId,
    String imageType, {
    String? fileName,
    required String extension,
  }) async {
    try {
      // Normalize extension (e.g., 'png' or 'jpg')
      final normalizedExtension = extension.toLowerCase();

      // Determine file name with extension
      final fileNameWithExt = fileName ?? path.basename(imageFile.path);

      // Prepare storage reference
      final storageRef = _storage
          .ref()
          .child(_imagesStoragePath)
          .child(templateId)
          .child(imageType)
          .child(fileNameWithExt);

      // Set metadata based on extension
      final contentType = normalizedExtension == 'png'
          ? 'image/png'
          : 'image/jpeg';
      final metadata = SettableMetadata(contentType: contentType);

      // Compress the image and get bytes
      final compressedBytes = await _compressImage(
        imageFile,
        normalizedExtension,
      );

      // Upload compressed bytes
      final uploadTask = await storageRef.putData(compressedBytes, metadata);

      // Get the download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      debugPrint(
        'Uploaded image URL: $downloadUrl (compressed size: ${compressedBytes.length} bytes)',
      );
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

  /// Compresses an image using flutter_image_compress, preserving PNG transparency.
  Future<Uint8List> _compressImage(File imageFile, String extension) async {
    try {
      // Determine format: PNG for transparency, JPEG for others
      final compressFormat = extension == 'png'
          ? CompressFormat.png
          : CompressFormat.jpeg;

      // Compress with resizing (max 1920x1080) and quality (85% for balance)
      final Uint8List? compressedBytes =
          await FlutterImageCompress.compressWithFile(
            imageFile.absolute.path,
            autoCorrectionAngle: false,
            quality: 85, // Adjust 0-100; higher = better quality, larger file
            format: compressFormat,
            keepExif: false, // Remove EXIF to reduce size further
          );

      if (compressedBytes == null || compressedBytes.isEmpty) {
        throw Exception('Compression failed for ${imageFile.path}');
      }

      debugPrint(
        'Compressed ${extension.toUpperCase()}: Original ${await imageFile.length()} bytes → ${compressedBytes.length} bytes',
      );
      return compressedBytes;
    } catch (e) {
      debugPrint('Compression error: $e. Falling back to original file.');
      // Fallback: Return original bytes to preserve transparency
      return await imageFile.readAsBytes();
    }
  }
}
 */
