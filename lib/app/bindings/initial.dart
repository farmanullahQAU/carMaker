import 'package:cardmaker/app/features/auth/controller.dart';
import 'package:cardmaker/app/features/editor/controller.dart';
import 'package:cardmaker/app/features/editor/icon_picker/controller.dart';
import 'package:cardmaker/app/features/editor/shape_editor/controller.dart';
import 'package:cardmaker/app/features/home/category_templates/controller.dart';
import 'package:cardmaker/app/features/home/controller.dart';
import 'package:cardmaker/app/features/profile/controller.dart';
import 'package:cardmaker/app/settings/controller.dart';
import 'package:cardmaker/services/auth_service.dart';
import 'package:cardmaker/services/firebase_storage_service.dart';
import 'package:cardmaker/services/firestore_service.dart';
import 'package:cardmaker/services/permission_handler.dart';
import 'package:get/get.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    try {
      Get.lazyPut(() => CanvasController(), fenix: true);
      Get.lazyPut(() => HomeController());

      Get.lazyPut(() => ProfileController());
      Get.lazyPut(() => AuthController());
      Get.lazyPut(() => ShapeEditorController());
      Get.lazyPut(() => SettingsController());

      Get.lazyPut(() => IconPickerController(), fenix: true);

      Get.lazyPut(() => CategoryTemplatesController(), fenix: true);

      // Get.lazyPut(() => TrendingController());
      Get.lazyPut(() => PermissionService());
      Get.lazyPut(() => AuthService(), fenix: true);
      Get.lazyPut(() => FirestoreServices(), fenix: true);
      Get.lazyPut(() => FirebaseStorageService(), fenix: true);
    } catch (e) {}
  }
}
