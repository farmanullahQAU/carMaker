import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';

import 'auth_service.dart';

/// StorageService handles image uploads to Firebase Storage.
class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final authService = Get.find<AuthService>();

  /// Detect if file is PNG (likely has transparency)
  bool _isPng(String path) {
    return path.toLowerCase().endsWith('.png');
  }

  /// Compress & convert image to WebP before upload.
  Future<Uint8List> _compressImage(File file) async {
    final isPng = _isPng(file.path);

    final result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      format: CompressFormat.webp,
      quality: isPng ? 100 : 80, // keep max quality for PNGs to preserve alpha
      minWidth: 1440,
      minHeight: 1440,
    );

    if (result == null) throw Exception("Image compression failed");
    return result;
  }

  /// Uploads an image to Firebase Storage with compression, returns the download URL.
  Future<String?> uploadImage(
    File imageFile,
    String parentId, // templateId or draftId
    String imageType, {
    String? fileName,
    bool isDraft = false,
  }) async {
    final basePath = isDraft
        ? 'user_drafts/${authService.user!.uid}/$parentId'
        : 'public_templates/$parentId';

    final storageRef = _storage
        .ref()
        .child(basePath)
        .child(imageType)
        .child(fileName!);

    // compress before upload
    final compressedBytes = await _compressImage(imageFile);

    final uploadTask = await storageRef.putData(
      compressedBytes,
      SettableMetadata(contentType: 'image/webp'),
    );

    return await uploadTask.ref.getDownloadURL();
  }
}
