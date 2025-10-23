import 'package:cardmaker/app/routes/app_routes.dart';
import 'package:cardmaker/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();

    // Redirect to home if user is not null or isSkipped is true
    if (authService.user != null || authService.isSkipped.value) {
      print('User is logged in or skipped: ${authService.isSkipped.value}');
      print('Redirecting to ${AppRoutes.home}');
      return const RouteSettings(name: AppRoutes.home);
    }
    // Redirect to authWrapper if user is null and isSkipped is false
    print('Redirecting to ${AppRoutes.authWrapper}');
    return const RouteSettings(name: AppRoutes.authWrapper);
  }
}
