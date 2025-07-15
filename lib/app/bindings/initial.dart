import 'package:cardmaker/app/features/editor/controller.dart';
import 'package:cardmaker/app/features/home/controller.dart';
import 'package:get/get.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    try {
      Get.lazyPut(() => HomeController());

      Get.lazyPut(() => EditorController());

      // Get.lazyPut(() => HomeController());
      // Get.lazyPut(() => OnboardingController());
      // Get.lazyPut(() => TrendingController());
    } catch (e) {}
  }
}
