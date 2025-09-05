// import 'dart:io';
// import 'dart:typed_data';

// import 'package:cardmaker/app/repositories/auth_repo.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';

// abstract class StorageRepository {
//   Future<String> uploadImage(
//     File imageFile,
//     String parentId,
//     String imageType, {
//     String? fileName,
//     bool isDraft = false,
//   });
// }

// class StorageRepositoryImpl implements StorageRepository {
//   final FirebaseStorage _storage;
//   final AuthRepository _authRepository;

//   StorageRepositoryImpl({
//     FirebaseStorage? storage,
//     required AuthRepository authRepository,
//   }) : _storage = storage ?? FirebaseStorage.instance,
//        _authRepository = authRepository;

//   bool _isPng(String path) => path.toLowerCase().endsWith('.png');

//   Future<Uint8List> _compressImage(File file) async {
//     final isPng = _isPng(file.path);

//     final result = await FlutterImageCompress.compressWithFile(
//       file.absolute.path,
//       format: CompressFormat.webp,
//       quality: isPng ? 100 : 80,
//       minWidth: 1440,
//       minHeight: 1440,
//     );

//     if (result == null) throw Exception("Image compression failed");
//     return result;
//   }

//   @override
//   Future<String> uploadImage(
//     File imageFile,
//     String parentId,
//     String imageType, {
//     String? fileName,
//     bool isDraft = false,
//   }) async {
//     final userId = _authRepository.currentUser?.uid;
//     if (userId == null) throw Exception('User not authenticated');

//     final basePath = isDraft
//         ? 'user_drafts/$userId/$parentId'
//         : 'public_templates/$parentId';

//     final storageRef = _storage
//         .ref()
//         .child(basePath)
//         .child(imageType)
//         .child(fileName!);

//     final compressedBytes = await _compressImage(imageFile);

//     final uploadTask = await storageRef.putData(
//       compressedBytes,
//       SettableMetadata(contentType: 'image/webp'),
//     );

//     return await uploadTask.ref.getDownloadURL();
//   }
// }
