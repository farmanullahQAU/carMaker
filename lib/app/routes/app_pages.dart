import 'package:cardmaker/app/bindings/initial.dart';
import 'package:cardmaker/app/features/auth/auth_screen.dart';
import 'package:cardmaker/app/features/auth/auth_wrapper.dart';
import 'package:cardmaker/app/features/editor/editor_canvas.dart';
import 'package:cardmaker/app/features/home/category_templates/view.dart';
import 'package:cardmaker/app/features/home/home.dart';
import 'package:cardmaker/app/routes/app_routes.dart';
import 'package:cardmaker/app/routes/middleware.dart';
import 'package:cardmaker/widgets/common/app_root_widget.dart';
import 'package:get/get.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.home, page: () => HomePage()),
    GetPage(
      name: AppRoutes.authWrapper,
      page: () => AuthWrapper(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(
      name: AppRoutes.editor,
      page: () => EditorPage(),
      // middlewares: [AuthMiddleware()], // Remove if editor doesn't need protection
    ),
    GetPage(
      name: AppRoutes.categoryTemplates,
      page: () => CategoryTemplatesPage(),
      binding: InitialBindings(),
    ),
    GetPage(
      name: AppRoutes.auth,
      page: () => AuthScreen(),
      binding: InitialBindings(),
    ),

    GetPage(
      name: AppRoutes.editor,
      page: () => EditorPage(),
      binding: InitialBindings(),
    ),
  ];
}
