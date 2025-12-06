import 'dart:async';
import 'dart:developer';

import 'package:cardmaker/models/config_model.dart';
import 'package:cardmaker/services/remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  int _exportCount = 0;

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

      // Don't load ads on initialization - load them lazily when actually needed
      // This prevents loading ads that might never be shown, which hurts eCPM
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
          // Only retry if ad will be shown next time
          Future.delayed(const Duration(seconds: 30), () {
            if (isEnabled && willShowRewardedAdOnNextExport()) {
              _loadRewardedAd();
            }
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
        // Only reload if it will be shown next time
        if (willShowRewardedAdOnNextExport()) {
          _loadRewardedAd();
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        log('Rewarded ad failed to show: ${error.message}');
        ad.dispose();
        _rewardedAd = null;
        _isRewardedAdReady = false;
        // Only reload if it will be shown next time
        if (willShowRewardedAdOnNextExport()) {
          _loadRewardedAd();
        }
      },
    );
  }

  /// Shows rewarded ad before export. Returns true if ad was shown and user watched it.
  /// Returns false if ad was not shown (not ready, disabled, etc.)
  /// First export is free (no ad shown), then every second export shows an ad
  Future<bool> showRewardedAdBeforeExport() async {
    // Initialize AdMob in background if not already initialized (non-blocking)
    if (!_isInitialized) {
      log('AdMob not initialized, starting non-blocking initialization');
      // Start initialization in background - don't await it
      initialize().catchError((error) {
        log('Background AdMob initialization failed: $error');
      });
      // Continue with export immediately without waiting
    }

    // First export is free (no ad)
    if (_exportCount == 0) {
      log('First export - skipping ad (free export)');
      _exportCount++;
      return true; // Allow export without ad
    }

    // Every second export shows an ad
    if (_exportCount == 1) {
      _exportCount = 0; // Reset counter for next cycle

      if (!isEnabled || !_adConfig.showRewardedAdOnExport) {
        return true; // Allow export if ads are disabled
      }

      if (!_isRewardedAdReady || _rewardedAd == null) {
        log('Rewarded ad not ready, allowing export without ad');
        // Only load if it will be shown next time (every second export)
        if (willShowRewardedAdOnNextExport()) {
          _loadRewardedAd();
        }
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
          // Only reload if it will be shown next time
          if (willShowRewardedAdOnNextExport()) {
            _loadRewardedAd();
          }
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          log('Rewarded ad failed to show: ${error.message}');
          if (!completer.isCompleted) {
            completer.complete(false);
          }
          ad.dispose();
          _rewardedAd = null;
          _isRewardedAdReady = false;
          // Only reload if it will be shown next time
          if (willShowRewardedAdOnNextExport()) {
            _loadRewardedAd();
          }
        },
      );

      return completer.future;
    }

    // Should not reach here, but allow export just in case
    return true;
  }

  /// Returns true when the next export attempt will require showing a rewarded ad.
  bool willShowRewardedAdOnNextExport() {
    if (!isEnabled || !_adConfig.showRewardedAdOnExport) return false;
    if (_exportCount == 1) {
      return _isRewardedAdReady && _rewardedAd != null;
    }
    return false;
  }

  // ========== INTERSTITIAL AD ==========
  Completer<void>? _interstitialAdLoadCompleter;
  bool _isInterstitialAdLoading = false;

  Future<bool> _loadInterstitialAd({bool willBeShown = false}) async {
    // Load interstitial ad if ads are enabled
    // (Used for both template views and exports)
    if (!isEnabled) return false;

    // Don't load if ad is already loaded
    if (_isInterstitialAdReady && _interstitialAd != null) {
      return true;
    }

    // If already loading, wait for existing load
    if (_isInterstitialAdLoading && _interstitialAdLoadCompleter != null) {
      try {
        await _interstitialAdLoadCompleter!.future.timeout(
          const Duration(seconds: 10),
        );
        return _isInterstitialAdReady && _interstitialAd != null;
      } catch (e) {
        log('Interstitial ad load timeout: $e');
        return false;
      }
    }

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
      return false;
    }

    _isInterstitialAdLoading = true;
    _interstitialAdLoadCompleter = Completer<void>();

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          _isInterstitialAdLoading = false;
          log('Interstitial ad loaded successfully');
          _setInterstitialAdFullScreenContentCallback();
          _interstitialAdLoadCompleter?.complete();
          _interstitialAdLoadCompleter = null;
        },
        onAdFailedToLoad: (error) {
          log('Interstitial ad failed to load: ${error.message}');
          _isInterstitialAdReady = false;
          _isInterstitialAdLoading = false;
          _interstitialAdLoadCompleter?.completeError(error);
          _interstitialAdLoadCompleter = null;

          // Only retry if ad will actually be shown
          if (willBeShown) {
            Future.delayed(const Duration(seconds: 30), () {
              // Check again if ad is still needed before retrying
              if (isEnabled && _shouldLoadInterstitialAd()) {
                _loadInterstitialAd(willBeShown: true); // Fire and forget
              }
            });
          }
        },
      ),
    );

    // Wait for ad to load with timeout
    try {
      await _interstitialAdLoadCompleter!.future.timeout(
        const Duration(seconds: 10),
      );
      return _isInterstitialAdReady && _interstitialAd != null;
    } catch (e) {
      log('Interstitial ad load timeout or error: $e');
      _isInterstitialAdLoading = false;
      _interstitialAdLoadCompleter = null;
      return false;
    }
  }

  /// Check if interstitial ad should be loaded based on current state
  bool _shouldLoadInterstitialAd() {
    if (!isEnabled) return false;

    // Check if ad will be shown on next export
    if (willShowInterstitialAdOnNextExport()) {
      return true;
    }

    // Check if ad will be shown on template view
    if (_adConfig.showInterstitialAdOnTemplateView) {
      final interval = _adConfig.interstitialIntervalTemplate;
      // Load if we're close to the interval (within 2 views)
      if (_templateViewCount >= interval - 2) {
        return true;
      }
    }

    return false;
  }

  void _setInterstitialAdFullScreenContentCallback() {
    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialAdReady = false;
        // Only reload if ad will actually be shown (prevents unnecessary loads)
        if (_shouldLoadInterstitialAd()) {
          _loadInterstitialAd(willBeShown: true); // Fire and forget
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        log('Interstitial ad failed to show: ${error.message}');
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialAdReady = false;
        // Only reload if ad will actually be shown
        if (_shouldLoadInterstitialAd()) {
          _loadInterstitialAd(willBeShown: true); // Fire and forget
        }
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
    final interval = _adConfig.interstitialIntervalTemplate;

    // Preload ad when we're close to showing it (2 views before)
    if (_templateViewCount == interval - 2 && !_isInterstitialAdReady) {
      _loadInterstitialAd(willBeShown: true); // Fire and forget
    }

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

  /// Shows interstitial ad before export. Returns true if ad was shown or skipped.
  /// Returns false if ad was not shown (not ready, disabled, etc.)
  /// Shows ad after every 2 exports (image or PDF)
  /// IMPROVED: When eligible, loads ad first, then shows it. If load fails, allows export.
  Future<bool> showInterstitialAdBeforeExport() async {
    // Initialize AdMob if not already initialized
    if (!_isInitialized) {
      log('AdMob not initialized, initializing...');
      try {
        await initialize();
      } catch (error) {
        log('AdMob initialization failed: $error');
        // Continue anyway - allow export if ads fail
      }
    }

    // Increment export count
    _exportCount++;

    // Get the interval from config (default is 2)
    final interval = _adConfig.interstitialIntervalExport;

    // Show ad after N exports (configured interval)
    if (_exportCount >= interval) {
      _exportCount = 0; // Reset counter after showing ad

      if (!isEnabled) {
        return true; // Allow export if ads are disabled
      }

      // User is eligible for ad - try to load it first if not ready
      if (!_isInterstitialAdReady || _interstitialAd == null) {
        log('User eligible for ad but ad not ready. Loading ad first...');

        // Show loading dialog to user
        _showAdLoadingDialog();

        try {
          final adLoaded = await _loadInterstitialAd(willBeShown: true);

          // Close loading dialog
          _hideAdLoadingDialog();

          if (!adLoaded) {
            log('Failed to load interstitial ad. Allowing export without ad.');
            // Preload for next time (fire and forget)
            if (_shouldLoadInterstitialAd()) {
              _loadInterstitialAd(willBeShown: true); // Fire and forget
            }
            return true; // Allow export even if ad failed to load
          }
        } catch (e) {
          // Close loading dialog on error
          _hideAdLoadingDialog();
          log('Error loading ad: $e');
          return true; // Allow export even if ad failed to load
        }
      }

      // Ad is ready, show it
      final completer = Completer<bool>();

      // Set callback for when ad is dismissed
      _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          log('Interstitial ad dismissed (shown after $interval exports)');
          completer.complete(true);
          ad.dispose();
          _interstitialAd = null;
          _isInterstitialAdReady = false;
          // Only reload if ad will actually be shown next time
          if (_shouldLoadInterstitialAd()) {
            _loadInterstitialAd(willBeShown: true); // Fire and forget
          }
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          log('Interstitial ad failed to show: ${error.message}');
          if (!completer.isCompleted) {
            completer.complete(true); // Allow export even if ad failed to show
          }
          ad.dispose();
          _interstitialAd = null;
          _isInterstitialAdReady = false;
          // Only reload if ad will actually be shown next time
          if (_shouldLoadInterstitialAd()) {
            _loadInterstitialAd(willBeShown: true); // Fire and forget
          }
        },
      );

      _interstitialAd?.show();

      return completer.future;
    }

    // Export count < interval, allow export without ad
    log(
      'Export $_exportCount - no ad shown (will show after $interval exports)',
    );
    return true;
  }

  /// Returns true when the next export attempt will require showing an interstitial ad.
  /// Returns true when count is (interval - 1), meaning next export will reach the interval
  bool willShowInterstitialAdOnNextExport() {
    if (!isEnabled) return false;
    final interval = _adConfig.interstitialIntervalExport;
    // If current count is (interval - 1), next export will reach interval, so show ad
    if (_exportCount == interval - 1) {
      // Preload ad if not ready yet (non-blocking)
      if (!_isInterstitialAdReady &&
          _interstitialAd == null &&
          !_isInterstitialAdLoading) {
        _loadInterstitialAd(willBeShown: true);
      }
      // Return true if ad is ready or will be loaded
      return true; // User is eligible, ad will be loaded when export happens
    }
    return false;
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

  // ========== AD LOADING DIALOG ==========
  void _showAdLoadingDialog() {
    if (Get.isDialogOpen == true) return; // Don't show if dialog already open

    Get.dialog(
      WillPopScope(
        onWillPop: () async => false, // Prevent dismissing while loading
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Preparing ad...',
                  style: Get.theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Get.theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please wait a moment',
                  style: Get.theme.textTheme.bodySmall?.copyWith(
                    color: Get.theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _hideAdLoadingDialog() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }

  // ========== CLEANUP ==========
  void dispose() {
    _hideAdLoadingDialog(); // Close loading dialog if open
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
      // Only load interstitial ads if they will be shown
      if (_shouldLoadInterstitialAd()) {
        _loadInterstitialAd(willBeShown: true); // Fire and forget
      }
    }
  }
}
