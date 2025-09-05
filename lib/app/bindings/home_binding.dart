import 'package:cardmaker/app/features/home/controller.dart';
import 'package:get/get.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    try {
      Get.lazyPut(() => HomeController());

      // Get.lazyPut(() => TopicsController());
    } catch (e) {}
  }
}
