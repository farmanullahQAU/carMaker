import 'package:cardmaker/app/bindings/initial.dart';
import 'package:cardmaker/app/features/auth/auth_screen.dart';
import 'package:cardmaker/app/features/editor/editor_canvas.dart';
import 'package:cardmaker/app/features/home/category_templates/view.dart';
import 'package:cardmaker/app/features/home/home.dart';
import 'package:cardmaker/app/routes/app_routes.dart';
import 'package:cardmaker/widgets/common/app_root_widget.dart';
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
    GetPage(name: Routes.splash, page: () => const SplashScreen()),
    GetPage(
      name: Routes.editor,
      page: () => EditorPage(),
      binding: InitialBindings(),
    ),

    GetPage(
      name: Routes.categoryTemplates,
      page: () => CategoryTemplatesPage(),

      binding: InitialBindings(),
    ),

    GetPage(
      name: Routes.auth,
      page: () => AuthScreen(),
      binding: InitialBindings(),
    ),
  ];
}
