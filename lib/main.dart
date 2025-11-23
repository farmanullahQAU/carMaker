import 'package:cardmaker/app/bindings/initial.dart';
import 'package:cardmaker/app/routes/app_pages.dart';
import 'package:cardmaker/core/theme/app_theme.dart';
import 'package:cardmaker/core/utils/toast_helper.dart';
import 'package:cardmaker/firebase_options.dart';
import 'package:cardmaker/services/app_locale_settings_service.dart';
import 'package:cardmaker/services/firebase_font_service.dart';
import 'package:cardmaker/widgets/common/app_root_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:toastification/toastification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize SettingsController

  await initServices();

  runApp(const CardMakerApp());
}

Future<void> initServices() async {
  // Only initialize critical services that are needed before app shows
  await Get.putAsync(() async {
    final appSettings = AppLocaleSettingsService();
    await appSettings.initialize();

    return appSettings;
  });

  // Initialize font cache in background (non-blocking)
  _initializeFontCache();

  // RemoteConfig and AdMob will be initialized in splash screen
  // This allows app to show faster while services initialize in background
}

Future<void> _initializeFontCache() async {
  try {
    // Import FirebaseFontService and initialize cache
    await FirebaseFontService.initializeFontCache();
  } catch (e) {
    // Silently handle errors - fonts will load when needed
  }
}

class CardMakerApp extends StatelessWidget {
  const CardMakerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      // Wrap your app with this
      child: GetMaterialApp(
        title: 'Inkkaro',
        debugShowCheckedModeBanner: false,
        themeMode: AppLocaleSettingsService().getThemeMode(),
        theme: CardMakerTheme.lightTheme(),
        darkTheme: CardMakerTheme.darkTheme(),
        getPages: AppPages.pages,
        // initialRoute: AppRoutes.splash,
        navigatorKey: ToastHelper.navigatorKey,
        initialBinding: InitialBindings(),
        home: const SplashScreen(),
      ),
    );
  }
}
