import 'package:cardmaker/app/bindings/initial.dart';
import 'package:cardmaker/app/routes/app_routes.dart';
import 'package:cardmaker/core/theme/app_theme.dart';
import 'package:cardmaker/firebase_options.dart';
import 'package:cardmaker/web/delete_ac.dart';
import 'package:cardmaker/web/web_home.dart';
import 'package:cardmaker/widgets/common/app_root_widget.dart';
import 'package:cardmaker/widgets/common/app_toast.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/routes/app_pages.dart'; // You need to create this file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const CardMakerApp());
}

class CardMakerApp extends StatelessWidget {
  const CardMakerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // For web, only show AccountDeletionPage
    if (kIsWeb) {
      return GetMaterialApp(
        theme: ThemeData(
          primaryColor: const Color(0xFF6366F1),
          scaffoldBackgroundColor: const Color(0xFF0F0F0F),
          fontFamily: 'SF Pro Display',
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.w700,
              letterSpacing: -2,
              height: 1.1,
            ),
            displayMedium: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.5,
            ),
            bodyLarge: TextStyle(
              fontSize: 18,
              height: 1.7,
              letterSpacing: -0.2,
            ),
          ),
        ),
        title: 'Inkkaro - Account Deletion',
        debugShowCheckedModeBanner: false,
        // theme: CardMakerTheme.lightTheme(),
        darkTheme: CardMakerTheme.darkTheme(),
        themeMode: ThemeMode.dark,
        // Define only the deletion route
        getPages: [
          GetPage(name: Routes.webLanding, page: () => const LandingPage()),
        ],
        // Start directly at deletion page
        initialRoute: Routes.webLanding,
        // Block navigation to other routes
        onUnknownRoute: (RouteSettings settings) {
          return GetPageRoute(
            page: () => const AccountDeletionPage(),
            routeName: Routes.webLanding,
          );
        },
      );
    }

    // For mobile, use full app routing
    return GetMaterialApp(
      title: 'Inkkaro',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      initialRoute: Routes.splash,
      theme: CardMakerTheme.lightTheme(),
      darkTheme: CardMakerTheme.darkTheme(),
      getPages: AppPages.pages,
      navigatorKey: navigatorKey,
      initialBinding: InitialBindings(),
      home: const SplashScreen(),
    );
  }
}
