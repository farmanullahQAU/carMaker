import 'package:cardmaker/app/features/editor/controller.dart';
import 'package:cardmaker/app/features/home/category_templates/controller.dart';
import 'package:cardmaker/app/features/home/controller.dart';
import 'package:cardmaker/services/auth_service.dart';
import 'package:cardmaker/services/template_services.dart';
import 'package:get/get.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    try {
      Get.lazyPut(() => HomeController());

      Get.lazyPut(() => CanvasController());
      Get.lazyPut(() => CategoryTemplatesController(Get.arguments));

      Get.lazyPut(() => TemplateService());
      Get.lazyPut(() => AuthService());

      // Get.lazyPut(() => TrendingController());
    } catch (e) {}
  }
}
