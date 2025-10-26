import 'package:cardmaker/core/values/app_constants.dart';
import 'package:cardmaker/models/locale_settings_model.dart';
import 'package:cardmaker/services/storage_service.dart';
import 'package:flutter/material.dart';

class AppLocaleSettingsService {
  static final AppLocaleSettingsService _instance =
      AppLocaleSettingsService._internal();
  factory AppLocaleSettingsService() => _instance;
  AppLocaleSettingsService._internal();

  final StorageService _storage = StorageService();
  late AppLocaleSettings _settings;

  AppLocaleSettings get settings => _settings;

  Future<void> initialize() async {
    _settings = await _loadSettings();
  }

  Future<AppLocaleSettings> _loadSettings() async {
    final savedTheme = _storage.read(themeKey);
    return AppLocaleSettings(theme: savedTheme ?? 'system');
  }

  ThemeMode getThemeMode() {
    switch (_settings.theme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
