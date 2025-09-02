import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

/// StorageService handles image uploads to Firebase Storage.
class FirebaseStorageService {
  static const String _imagesStoragePath = 'card_images/templates';
  final FirebaseStorage _storage = FirebaseStorage.instance;
  /*
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
*/

  Future<String> uploadImage(
    File imageFile,
    String parentId, // templateId or draftId
    String imageType, {
    String? fileName,
    required String extension,
    bool isDraft = false,
    String? userId,
  }) async {
    try {
      final basePath = isDraft
          ? 'user_drafts/$userId/$parentId'
          : 'public_templates/$parentId';

      final storageRef = _storage
          .ref()
          .child(basePath)
          .child(imageType)
          .child(fileName!);

      final uploadTask = await storageRef.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/$extension'),
      );

      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }
}
