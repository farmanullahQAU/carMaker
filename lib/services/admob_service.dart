import 'dart:async';
import 'dart:developer';

import 'package:cardmaker/models/config_model.dart';
import 'package:cardmaker/services/remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;
  BannerAd? _bannerAd;
  bool _isRewardedAdReady = false;
  bool _isInterstitialAdReady = false;
  bool _isInitialized = false;

  int _templateViewCount = 0;

  // Test Ad Unit IDs (replace with your actual IDs in remote config)
  static const String _testRewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _testInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      log('AdMob initialized successfully');

      // Load ads if enabled
      final config = RemoteConfigService().config.ads;
      if (config.enabled) {
        _loadRewardedAd();
        _loadInterstitialAd();
      }
    } catch (e, stackTrace) {
      log('AdMob initialization failed: $e', stackTrace: stackTrace);
    }
  }

  AdMobConfig get _adConfig => RemoteConfigService().config.ads;

  bool get isEnabled => _adConfig.enabled && _isInitialized;

  // ========== REWARDED AD ==========
  void _loadRewardedAd() {
    if (!isEnabled || !_adConfig.showRewardedAdOnExport) return;

    // In release mode, only use configured ad unit IDs (no test IDs)
    String? adUnitId;
    if (_adConfig.rewardedAdUnitId.isNotEmpty) {
      adUnitId = _adConfig.rewardedAdUnitId;
    } else if (kDebugMode) {
      // Only use test IDs in debug mode
      adUnitId = _testRewardedAdUnitId;
    } else {
      // In release mode, don't load ads if no ad unit ID is configured
      log(
        'Rewarded ad unit ID not configured. Skipping ad load in release mode.',
      );
      return;
    }

    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;
          log('Rewarded ad loaded successfully');
          _setRewardedAdFullScreenContentCallback();
        },
        onAdFailedToLoad: (error) {
          log('Rewarded ad failed to load: ${error.message}');
          _isRewardedAdReady = false;
          // Retry after 30 seconds
          Future.delayed(const Duration(seconds: 30), () {
            if (isEnabled) _loadRewardedAd();
          });
        },
      ),
    );
  }

  void _setRewardedAdFullScreenContentCallback() {
    _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _isRewardedAdReady = false;
        // Reload for next time
        _loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        log('Rewarded ad failed to show: ${error.message}');
        ad.dispose();
        _rewardedAd = null;
        _isRewardedAdReady = false;
        _loadRewardedAd();
      },
    );
  }

  /// Shows rewarded ad before export. Returns true if ad was shown and user watched it.
  /// Returns false if ad was not shown (not ready, disabled, etc.)
  Future<bool> showRewardedAdBeforeExport() async {
    if (!isEnabled || !_adConfig.showRewardedAdOnExport) {
      return true; // Allow export if ads are disabled
    }

    if (!_isRewardedAdReady || _rewardedAd == null) {
      log('Rewarded ad not ready, allowing export without ad');
      // Try to load for next time
      _loadRewardedAd();
      return true; // Allow export even if ad is not ready
    }

    final completer = Completer<bool>();

    _rewardedAd?.show(
      onUserEarnedReward: (ad, reward) {
        log('User earned reward: ${reward.amount} ${reward.type}');
        completer.complete(true);
      },
    );

    // Set callback for when ad is dismissed without reward
    _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        if (!completer.isCompleted) {
          completer.complete(false);
        }
        ad.dispose();
        _rewardedAd = null;
        _isRewardedAdReady = false;
        _loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        log('Rewarded ad failed to show: ${error.message}');
        if (!completer.isCompleted) {
          completer.complete(false);
        }
        ad.dispose();
        _rewardedAd = null;
        _isRewardedAdReady = false;
        _loadRewardedAd();
      },
    );

    return completer.future;
  }

  // ========== INTERSTITIAL AD ==========
  void _loadInterstitialAd() {
    if (!isEnabled || !_adConfig.showInterstitialAdOnTemplateView) return;

    // In release mode, only use configured ad unit IDs (no test IDs)
    String? adUnitId;
    if (_adConfig.interstitialAdUnitId.isNotEmpty) {
      adUnitId = _adConfig.interstitialAdUnitId;
    } else if (kDebugMode) {
      // Only use test IDs in debug mode
      adUnitId = _testInterstitialAdUnitId;
    } else {
      // In release mode, don't load ads if no ad unit ID is configured
      log(
        'Interstitial ad unit ID not configured. Skipping ad load in release mode.',
      );
      return;
    }

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          log('Interstitial ad loaded successfully');
          _setInterstitialAdFullScreenContentCallback();
        },
        onAdFailedToLoad: (error) {
          log('Interstitial ad failed to load: ${error.message}');
          _isInterstitialAdReady = false;
          // Retry after 30 seconds
          Future.delayed(const Duration(seconds: 30), () {
            if (isEnabled) _loadInterstitialAd();
          });
        },
      ),
    );
  }

  void _setInterstitialAdFullScreenContentCallback() {
    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialAdReady = false;
        // Reload for next time
        _loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        log('Interstitial ad failed to show: ${error.message}');
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialAdReady = false;
        _loadInterstitialAd();
      },
    );
  }

  /// Call this when a template is viewed. Shows interstitial ad after N views.
  void onTemplateViewed() {
    if (!isEnabled || !_adConfig.showInterstitialAdOnTemplateView) {
      log('Interstitial ad not enabled or not shown on template view');
      return;
    }

    _templateViewCount++;
    final interval = _adConfig.interstitialAdInterval;

    if (_templateViewCount >= interval && _isInterstitialAdReady) {
      _templateViewCount = 0; // Reset counter
      showInterstitialAd();
    }
  }

  void showInterstitialAd() {
    if (!isEnabled || !_isInterstitialAdReady || _interstitialAd == null) {
      return;
    }

    _interstitialAd?.show();
  }

  // ========== BANNER AD ==========
  BannerAd? createBannerAd({
    required AdSize adSize,
    BannerAdListener? listener,
  }) {
    if (!isEnabled || !_adConfig.showBannerAd) return null;

    // In release mode, only use configured ad unit IDs (no test IDs)
    String? adUnitId;
    if (_adConfig.bannerAdUnitId.isNotEmpty) {
      adUnitId = _adConfig.bannerAdUnitId;
    } else if (kDebugMode) {
      // Only use test IDs in debug mode
      adUnitId = _testBannerAdUnitId;
    } else {
      // In release mode, don't create banner ad if no ad unit ID is configured
      log(
        'Banner ad unit ID not configured. Skipping banner ad creation in release mode.',
      );
      return null;
    }

    final bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: adSize,
      request: const AdRequest(),
      listener:
          listener ??
          BannerAdListener(
            onAdLoaded: (_) => log('Banner ad loaded'),
            onAdFailedToLoad: (ad, error) {
              log('Banner ad failed to load: ${error.message}');
              ad.dispose();
            },
            onAdOpened: (_) => log('Banner ad opened'),
            onAdClosed: (_) => log('Banner ad closed'),
          ),
    );

    bannerAd.load();
    return bannerAd;
  }

  // ========== CLEANUP ==========
  void dispose() {
    _rewardedAd?.dispose();
    _interstitialAd?.dispose();
    _bannerAd?.dispose();
    _rewardedAd = null;
    _interstitialAd = null;
    _bannerAd = null;
    _isRewardedAdReady = false;
    _isInterstitialAdReady = false;
  }

  // Reload ads when config changes
  void reloadAds() {
    dispose();
    if (isEnabled) {
      _loadRewardedAd();
      _loadInterstitialAd();
    }
  }
}
