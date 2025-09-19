import 'package:cardmaker/app/bindings/initial.dart';
import 'package:cardmaker/app/routes/app_routes.dart';
import 'package:cardmaker/core/theme/app_theme.dart';
import 'package:cardmaker/firebase_options.dart';
// main.dart (updated)
import 'package:cardmaker/services/initialization_service.dart';
import 'package:cardmaker/widgets/common/app_root_widget.dart';
import 'package:cardmaker/widgets/common/app_toast.dart';
import 'package:firebase_core/firebase_core.dart';
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
    return FutureBuilder(
      future: Get.putAsync(() => InitializationService().initializeApp()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              // backgroundColor: Colors.white,
              body: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(),
                    Image.asset("assets/water_mark.png", width: 22, height: 22),
                  ],
                ),
              ),
            ),
          );
        }

        return GetMaterialApp(
          title: 'Card Maker',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.system,
          initialRoute: Routes.home,
          theme: CardMakerTheme.lightTheme(),
          darkTheme: CardMakerTheme.darkTheme(),
          getPages: AppPages.pages,
          navigatorKey: navigatorKey,
          initialBinding: InitialBindings(),
          home: const AppRootWidget(), // Wrap with root widget
        );
      },
    );
  }
}
