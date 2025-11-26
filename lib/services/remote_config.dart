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
  bool _isInitialized = false;

  RemoteConfigModel _defaultFallbackConfig() => RemoteConfigModel(
    update: const AppUpdateConfig(),
    ads: const AdMobConfig(),
  );

  RemoteConfigService._internal()
    : _remoteConfig = FirebaseRemoteConfig.instance,
      _config = RemoteConfigModel(
        update: const AppUpdateConfig(),
        ads: const AdMobConfig(),
      ),
      _isUsingFallback = true {
    // Initialize with fallback config to prevent LateInitializationError
  }

  RemoteConfigModel get config => _config;
  bool get isUsingFallback => _isUsingFallback;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    // Prevent multiple initializations
    if (_isInitialized) {
      log('RemoteConfig already initialized, skipping...');
      return;
    }

    try {
      await _setupRemoteConfig();
      _config = await _fetchConfig();
      _isUsingFallback = false;
      _isInitialized = true;
    } catch (e, stackTrace) {
      log('RemoteConfig initialization failed: $e', stackTrace: stackTrace);
      _config = _defaultFallbackConfig();
      _isUsingFallback = true;
      _isInitialized = true; // Mark as initialized even if using fallback
    }
  }

  Future<void> _setupRemoteConfig() async {
    await _remoteConfig.setDefaults({
      kRemoteConfigKey: jsonEncode(_defaultConfig),
    });
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
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
      "current_version": "1.0.8",
      "min_supported_version": "1.0.0",
      "update_url": kPlaystoreUrl,
      "isForce_update": false,
      "isUpdate_available": false,
      "update_desc": "",
      "new_features": [],
    },
    "ads": {
      "enabled": true,
      "rewarded_ad_unit_id": "ca-app-pub-9945712682375451/7138044017",
      "interstitial_ad_unit_id": "ca-app-pub-9945712682375451/3464724016",
      "banner_ad_unit_id": "ca-app-pub-9945712682375451/1511162871",
      "interstitial_ad_interval": 3,
      "show_rewarded_ad_on_export": true,
      "show_interstitial_ad_on_template_view": true,
      "show_banner_ad": true,
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
