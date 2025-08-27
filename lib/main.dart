import 'package:cardmaker/app/bindings/initial.dart';
import 'package:cardmaker/app/routes/app_routes.dart';
import 'package:cardmaker/core/theme/app_theme.dart';
import 'package:cardmaker/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/routes/app_pages.dart'; // You need to create this file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Optional: Verify initialization
  print('Firebase initialized: ${Firebase.app().name}');
  runApp(const CardMakerApp());
}

class CardMakerApp extends StatelessWidget {
  const CardMakerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Card Maker',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      initialRoute: Routes.home,
      theme: CardMakerTheme.lightTheme(),

      darkTheme: CardMakerTheme.darkTheme(),

      getPages: AppPages.pages,
      initialBinding: InitialBindings(),
    );
  }
}
