import 'package:cardmaker/app/features/auth/controller.dart';
import 'package:cardmaker/app/features/editor/controller.dart';
import 'package:cardmaker/app/features/editor/shape_editor/controller.dart';
import 'package:cardmaker/app/features/home/category_templates/controller.dart';
import 'package:cardmaker/app/features/home/controller.dart';
import 'package:cardmaker/app/features/profile/controller.dart';
import 'package:cardmaker/services/auth_service.dart';
import 'package:cardmaker/services/firebase_storage_service.dart';
import 'package:cardmaker/services/firestore_service.dart';
import 'package:cardmaker/services/initialization_service.dart';
import 'package:cardmaker/services/permission_handler.dart';
import 'package:get/get.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    try {
      Get.lazyPut(() => HomeController());

      Get.lazyPut(() => CanvasController());
      Get.lazyPut(() => ProfileController());
      Get.lazyPut(() => AuthController());
      Get.lazyPut(() => ShapeEditorController());

      Get.lazyPut(() => CategoryTemplatesController());

      Get.lazyPut(() => InitializationService(), fenix: true);

      // Get.lazyPut(() => TrendingController());
      Get.lazyPut(() => PermissionService());
      Get.lazyPut(() => AuthService(), fenix: true);
      Get.lazyPut(() => FirestoreServices(), fenix: true);
      Get.lazyPut(() => FirebaseStorageService(), fenix: true);
    } catch (e) {}
  }
}
