import 'package:cardmaker/core/values/app_constants.dart';
import 'package:cardmaker/services/app_locale_settings_service.dart';
import 'package:cardmaker/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;
  final StorageService _storage = StorageService();
  final AppLocaleSettingsService _localeSettings = AppLocaleSettingsService();

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  /// Load theme from AppLocaleSettingsService
  void _loadTheme() {
    themeMode.value = _localeSettings.getThemeMode();
  }

  /// Save theme to storage and update app theme
  void setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    String themeString;
    switch (mode) {
      case ThemeMode.light:
        themeString = 'light';
        break;
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      default:
        themeString = 'system';
    }
    await _storage.write(themeKey, themeString);
    Get.changeThemeMode(mode);
  }
}
