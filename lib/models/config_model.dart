// lib/models/remote_config_model.dart

class RemoteConfigModel {
  final AppUpdateConfig update;

  RemoteConfigModel({required this.update});

  factory RemoteConfigModel.fromJson(Map<String, dynamic> json) {
    return RemoteConfigModel(
      update: AppUpdateConfig.fromJson(json['update'] ?? {}),
    );
  }
}

class AppUpdateConfig {
  final String currentVersion;
  final String minSupportedVersion;
  final String updateUrl;
  final bool isForceUpdate;
  final bool isUpdateAvailable;
  final String updateDesc;

  /// 👉 NEW FIELDS
  final String title;
  final List<String> newFeatures;

  const AppUpdateConfig({
    this.currentVersion = '',
    this.minSupportedVersion = '',
    this.updateUrl = '',
    this.isForceUpdate = false,
    this.isUpdateAvailable = false,
    this.updateDesc = '',
    this.title = '',
    this.newFeatures = const [],
  });

  factory AppUpdateConfig.fromJson(Map<String, dynamic> json) {
    return AppUpdateConfig(
      currentVersion: json['current_version'] ?? '',
      minSupportedVersion: json['min_supported_version'] ?? '',
      updateUrl: json['update_url'] ?? '',
      isForceUpdate: json['isForce_update'] ?? false,
      isUpdateAvailable: json['isUpdate_available'] ?? false,
      updateDesc: json['update_desc'] ?? '',

      /// NEW FIELDS
      title: json['title'] ?? '',
      newFeatures:
          (json['new_features'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
    );
  }
}
