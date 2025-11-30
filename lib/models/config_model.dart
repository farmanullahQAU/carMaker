// lib/models/remote_config_model.dart

class RemoteConfigModel {
  final AppUpdateConfig update;
  final AdMobConfig ads;

  RemoteConfigModel({required this.update, required this.ads});

  factory RemoteConfigModel.fromJson(Map<String, dynamic> json) {
    return RemoteConfigModel(
      update: AppUpdateConfig.fromJson(json['update'] ?? {}),
      ads: AdMobConfig.fromJson(json['ads'] ?? {}),
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

class AdMobConfig {
  final bool enabled;
  final String rewardedAdUnitId;
  final String interstitialAdUnitId;
  final String bannerAdUnitId;
  final int interstitialIntervalTemplate; // Show ad after N templates viewed
  final int
  interstitialIntervalExport; // Show ad after N exports (image or PDF)
  final bool showRewardedAdOnExport;
  final bool showInterstitialAdOnTemplateView;
  final bool showBannerAd;

  const AdMobConfig({
    this.enabled = true,
    this.rewardedAdUnitId = '',
    this.interstitialAdUnitId = '',
    this.bannerAdUnitId = '',
    this.interstitialIntervalTemplate = 5, // Default: show after 5 templates
    this.interstitialIntervalExport = 2, // Default: show after 2 exports
    this.showRewardedAdOnExport = false,
    this.showInterstitialAdOnTemplateView = true,
    this.showBannerAd = true,
  });

  factory AdMobConfig.fromJson(Map<String, dynamic> json) {
    return AdMobConfig(
      enabled: json['enabled'] ?? true,
      rewardedAdUnitId: json['rewarded_ad_unit_id'] ?? '',
      interstitialAdUnitId: json['interstitial_ad_unit_id'] ?? '',
      bannerAdUnitId: json['banner_ad_unit_id'] ?? '',
      interstitialIntervalTemplate: json['interstitial_interval_template'] ?? 5,
      interstitialIntervalExport: json['interstitial_interval_export'] ?? 2,
      showRewardedAdOnExport: json['show_rewarded_ad_on_export'] ?? false,
      showInterstitialAdOnTemplateView:
          json['show_interstitial_ad_on_template_view'] ?? true,
      showBannerAd: json['show_banner_ad'] ?? true,
    );
  }
}
