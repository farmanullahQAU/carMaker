// import 'dart:io';
import 'dart:io';
import 'dart:typed_data';

import 'package:cardmaker/services/auth_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool _isPng(String path) {
    return path.toLowerCase().endsWith('.png');
  }

  Future<Uint8List> _compressImage(File file) async {
    final isPng = _isPng(file.path);

    final result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      format: CompressFormat.webp,
      quality: isPng ? 100 : 80,
      minWidth: 1440,
      minHeight: 1440,
    );

    if (result == null) throw Exception("Image compression failed");
    return result;
  }

  Future<String?> uploadImage(
    File imageFile,
    String parentId,
    String imageType, {
    String? fileName,
    bool isDraft = false,
  }) async {
    final authService = Get.find<AuthService>(); // Lazy-load
    final basePath = isDraft
        ? 'user_drafts/${authService.user!.uid}/$parentId'
        : 'public_templates/$parentId';

    final storageRef = _storage
        .ref()
        .child(basePath)
        .child(imageType)
        .child(fileName!);

    final compressedBytes = await _compressImage(imageFile);

    final uploadTask = await storageRef.putData(
      compressedBytes,
      SettableMetadata(contentType: 'image/webp'),
    );

    return await uploadTask.ref.getDownloadURL();
  }
}
