import 'package:cardmaker/app/bindings/initial.dart';
import 'package:cardmaker/app/routes/app_routes.dart';
import 'package:cardmaker/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/routes/app_pages.dart'; // You need to create this file

void main() {
  runApp(const CardMakerApp());
}

class CardMakerApp extends StatelessWidget {
  const CardMakerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Card Maker',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      initialRoute: Routes.home,
      theme: CardMakerTheme.lightTheme(),
      darkTheme: CardMakerTheme.darkTheme(),

      getPages: AppPages.pages,
      initialBinding: InitialBindings(),
    );
  }
}
