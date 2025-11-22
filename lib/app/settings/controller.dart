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
  void setThemeMode(ThemeMode mode) {
    // Update UI immediately for smooth transition
    themeMode.value = mode;

    // Update theme immediately for instant feedback
    Get.changeThemeMode(mode);

    // Save to storage asynchronously (non-blocking)
    _saveThemeMode(mode);
  }

  /// Save theme mode to storage (non-blocking)
  void _saveThemeMode(ThemeMode mode) {
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
    // Fire and forget - don't block UI
    _storage.write(themeKey, themeString).catchError((error) {
      debugPrint('Error saving theme: $error');
    });
  }
}
