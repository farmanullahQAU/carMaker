// widgets/app_root_widget.dart
import 'package:cardmaker/app/features/home/controller.dart';
import 'package:cardmaker/app/features/home/home.dart';
import 'package:cardmaker/services/initialization_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppRootWidget extends StatefulWidget {
  const AppRootWidget({super.key});

  @override
  State<AppRootWidget> createState() => _AppRootWidgetState();
}

class _AppRootWidgetState extends State<AppRootWidget>
    with WidgetsBindingObserver {
  final InitializationService _initService = Get.find<InitializationService>();
  bool _checkedForUpdates = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkForUpdates();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_checkedForUpdates) {
      _checkForUpdates();
    }
  }

  Future<void> _checkForUpdates() async {
    if (!_initService.isInitialized) return;

    final config = _initService.remoteConfig.config.update;
    if (config.isUpdateAvailable) {
      await _initService.updateManager.checkForUpdates(context);
      _checkedForUpdates = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) => HomePage(),
    );
  }
}
