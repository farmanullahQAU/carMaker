// lib/services/remote_config_service.dart
import 'dart:convert';
import 'dart:developer';

import 'package:cardmaker/core/values/app_constants.dart';
import 'package:cardmaker/models/config_model.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  late final FirebaseRemoteConfig _remoteConfig;
  RemoteConfigModel _config;
  bool _isUsingFallback = false;

  RemoteConfigModel _defaultFallbackConfig() =>
      RemoteConfigModel(update: const AppUpdateConfig());

  RemoteConfigService._internal()
    : _remoteConfig = FirebaseRemoteConfig.instance,
      _config = RemoteConfigModel(update: const AppUpdateConfig()),
      _isUsingFallback = true {
    // Initialize with fallback config to prevent LateInitializationError
  }

  RemoteConfigModel get config => _config;
  bool get isUsingFallback => _isUsingFallback;

  Future<void> initialize() async {
    try {
      await _setupRemoteConfig();
      _config = await _fetchConfig();
      _isUsingFallback = false;
    } catch (e, stackTrace) {
      log('RemoteConfig initialization failed: $e', stackTrace: stackTrace);
      _config = _defaultFallbackConfig();
      _isUsingFallback = true;
    }
  }

  Future<void> _setupRemoteConfig() async {
    await _remoteConfig.setDefaults({
      kRemoteConfigKey: jsonEncode(_defaultConfig),
    });
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 8),
        minimumFetchInterval: const Duration(hours: 12),
      ),
    );
    await _remoteConfig.fetchAndActivate();
  }

  Future<RemoteConfigModel> _fetchConfig() async {
    final configJson = _remoteConfig.getString(kRemoteConfigKey);
    if (configJson.isEmpty) throw Exception('app_config is empty');

    try {
      final configMap = jsonDecode(configJson) as Map<String, dynamic>;
      return RemoteConfigModel.fromJson(configMap);
    } catch (e, stackTrace) {
      log('Failed to decode app_config: $e', stackTrace: stackTrace);
      throw Exception('Invalid JSON format in app_config');
    }
  }

  Map<String, dynamic> get _defaultConfig => {
    "update": {
      "current_version": "1.0.0",
      "min_supported_version": "1.0.0",
      "update_url": kPlaystoreUrl,
      "isForce_update": false,
      "isUpdate_available": false,
      "update_desc": "",
      "new_features": [
        "Minor Bugs fixed",
        "Login issue fixed",
        "Ui improvement",
      ],
    },
  };

  Future<void> refreshConfig() async {
    try {
      await _remoteConfig.fetchAndActivate();
      _config = await _fetchConfig();
      _isUsingFallback = false;
    } catch (e, stackTrace) {
      log('Refresh config failed: $e', stackTrace: stackTrace);
      _isUsingFallback = true;
    }
  }
}
