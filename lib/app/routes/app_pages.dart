import 'package:cardmaker/app/bindings/initial.dart';
import 'package:cardmaker/app/features/editor/editor_canvas.dart';
import 'package:cardmaker/app/features/home/category_templates/view.dart';
import 'package:cardmaker/app/features/home/home.dart';
import 'package:cardmaker/app/routes/app_routes.dart';
import 'package:cardmaker/models/card_template.dart';
import 'package:get/get.dart';

class AppPages {
  static final pages = [
    GetPage(name: Routes.home, page: () => HomePage()),
    // GetPage(
    //   name: Routes.bottomNavbarView,
    //   page: () => const BottomNavBarPage(),
    //   middlewares: [OnboardingMiddleware()],
    // ),
    // GetPage(name: Routes.onboarding, page: () => OnboardingScreen()),
    GetPage(
      name: Routes.editor,
      page: () => EditorPage(),
      binding: InitialBindings(),
    ),

    GetPage(
      name: Routes.categoryTemplates,
      page: () {
        final CategoryModel category = Get.arguments as CategoryModel;
        return CategoryTemplatesPage(category: category);
      },
    ),
  ];
}
