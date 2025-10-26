import 'dart:io' show Platform;
import 'dart:math';

import 'package:cardmaker/models/config_model.dart';
import 'package:cardmaker/services/remote_config.dart';
import 'package:cardmaker/widgets/common/update_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemNavigator
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateManager {
  static final UpdateManager _instance = UpdateManager._internal();
  factory UpdateManager() => _instance;
  UpdateManager._internal();

  PackageInfo? _pkg;
  String get currVer => _pkg?.version ?? "..";

  Future<void> checkForUpdates(BuildContext ctx) async {
    try {
      _pkg = await PackageInfo.fromPlatform();

      print("Current version: ${_pkg?.version}");
      final rc = RemoteConfigService();
      final cfg = rc.config.update;
      if (!rc.config.update.isUpdateAvailable) {
        return;
      }
      // Nothing to do?
      if (!cfg.isUpdateAvailable) return;
      if (!_isLower(currVer, cfg.currentVersion)) {
        // App is up-to-date; close dialog if open
        if (Navigator.of(ctx).canPop()) {
          Navigator.of(ctx).pop();
        }
        return;
      }

      // ---- FORCE UPDATE (Android and iOS) ------------------------------------
      if (cfg.isForceUpdate) {
        if (Platform.isAndroid) {
          final handled = await _runAndroidInAppUpdate(
            ctx,
            cfg,
            isImmediate: true,
          );
          if (handled) return; // Immediate update flow started
        }
        // Fallback to custom dialog for iOS or if Android immediate update fails
        return UpdateDialog.showRequired(
          ctx,
          title: cfg.title,
          newFeatures: cfg.newFeatures,
          onUpdatePressed: () => _launch(cfg.updateUrl, ctx, cfg),
        );
      }

      // ---- OPTIONAL UPDATE PATH -------------------------------------------
      if (Platform.isAndroid) {
        final handled = await _runAndroidInAppUpdate(
          ctx,
          cfg,
          isImmediate: false,
        );
        if (handled) return; // Flexible update flow started, dialog not needed
      }

      // Fallback: regular optional dialog (iOS or Play API failed)
      UpdateDialog.showOptional(
        ctx,
        title: cfg.title,
        newFeatures: cfg.newFeatures,
        onUpdatePressed: () => _launch(cfg.updateUrl, ctx, cfg),
      );
    } catch (e) {
      debugPrint('Update check failed: $e');
      /* silent */
    }
  }

  // -------- ANDROID IN-APP UPDATE (IMMEDIATE OR FLEXIBLE) -------------------
  Future<bool> _runAndroidInAppUpdate(
    BuildContext ctx,
    AppUpdateConfig cfg, {
    required bool isImmediate,
  }) async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability != UpdateAvailability.updateAvailable) {
        debugPrint('No update available on Play Store');
        return false; // No update available; show fallback dialog
      }

      if (isImmediate) {
        // Start immediate update
        final result = await InAppUpdate.performImmediateUpdate();
        // Handle the result of the immediate update
        switch (result) {
          case AppUpdateResult.success:
            // Update completed successfully; verify version
            final newPkg = await PackageInfo.fromPlatform();
            if (!_isLower(newPkg.version, cfg.currentVersion)) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                  content: Text('App updated to version ${newPkg.version}'),
                ),
              );
              if (Navigator.of(ctx).canPop()) {
                Navigator.of(ctx).pop();
              }
              _pkg = newPkg;
            } else {
              // Version still outdated despite success (unlikely, but handle it)
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content: Text('Update failed to apply')),
              );
              await SystemNavigator.pop();
            }
            break;
          case AppUpdateResult.userDeniedUpdate:
            // User canceled the update
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(content: Text('Update is required to continue')),
            );
            await SystemNavigator.pop();
            break;
          case AppUpdateResult.inAppUpdateFailed:
            // Update failed (e.g., network issue)
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(content: Text('Update failed; please try again')),
            );
            return false; // Fallback to custom dialog
          default:
            debugPrint('Unknown update result: $result');
            return false; // Fallback to custom dialog
        }
      } else {
        // Start flexible update
        await InAppUpdate.startFlexibleUpdate();
        // Show non-blocking progress sheet
        _showFlexibleSheet(ctx, cfg);
        // Wait until download finishes
        await InAppUpdate.completeFlexibleUpdate();
        // Check if updated
        final newPkg = await PackageInfo.fromPlatform();
        if (!_isLower(newPkg.version, cfg.currentVersion)) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text('App updated to version ${newPkg.version}')),
          );
          if (Navigator.of(ctx).canPop()) {
            Navigator.of(ctx).pop();
          }
          _pkg = newPkg;
        }
      }
      return true;
    } catch (e) {
      debugPrint('Android in-app update failed: $e');
      return false; // Fallback to custom dialog
    }
  }

  void _showFlexibleSheet(BuildContext ctx, AppUpdateConfig cfg) {
    showModalBottomSheet(
      context: ctx,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Theme.of(ctx).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => SizedBox(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                cfg.title,
                style: Theme.of(ctx).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                cfg.newFeatures.isNotEmpty
                    ? cfg.newFeatures.join('\n• ')
                    : cfg.updateDesc,
                textAlign: TextAlign.center,
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------- HELPERS --------------------------------------------------------
  bool _isLower(String cur, String latest) {
    try {
      if (cur.isEmpty || latest.isEmpty) {
        debugPrint('Empty version string: cur=$cur, latest=$latest');
        return false;
      }
      final a = cur.split('.').map(int.parse).toList();
      final b = latest.split('.').map(int.parse).toList();
      for (int i = 0; i < max(a.length, b.length); i++) {
        final x = i < a.length ? a[i] : 0;
        final y = i < b.length ? b[i] : 0;
        if (x < y) return true;
        if (x > y) return false;
      }
    } catch (e) {
      debugPrint('Invalid version format: cur=$cur, latest=$latest');
    }
    return false;
  }

  Future<void> _launch(
    String url,
    BuildContext ctx,
    AppUpdateConfig cfg,
  ) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri);
      // Check version after returning from Play Store or App Store
      final newPkg = await PackageInfo.fromPlatform();
      if (!_isLower(newPkg.version, cfg.currentVersion)) {
        // App is updated
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text('App updated to version ${newPkg.version}')),
        );
        if (Navigator.of(ctx).canPop()) {
          Navigator.of(ctx).pop();
        }
        _pkg = newPkg;
      } else if (cfg.isForceUpdate) {
        // User returned without updating; show message and exit
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(content: Text('Update is required to continue')),
        );
        await SystemNavigator.pop();
      } else {
        // Optional update canceled
        Navigator.of(ctx).pop();
        ScaffoldMessenger.of(
          ctx,
        ).showSnackBar(const SnackBar(content: Text('App update canceled')));
      }
    } else {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Could not open update link')),
      );
    }
  }

  void dispose() {
    // No observer to remove
  }
}


//withou flexible bottom sheet
/*



import 'dart:io' show Platform;
import 'dart:math';

import 'package:cardmaker/models/config_model.dart';
import 'package:cardmaker/services/remote_config.dart';
import 'package:cardmaker/widgets/common/update_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemNavigator
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateManager {
  static final UpdateManager _instance = UpdateManager._internal();
  factory UpdateManager() => _instance;
  UpdateManager._internal();

  PackageInfo? _pkg;
  String get currVer => _pkg?.version ?? "..";

  Future<void> checkForUpdates(BuildContext ctx) async {
    try {
      _pkg = await PackageInfo.fromPlatform();
      final rc = RemoteConfigService();
      final cfg = rc.config.update;

      // Nothing to do?
      if (!cfg.isUpdateAvailable) return;
      if (!_isLower(currVer, cfg.currentVersion)) {
        // App is up-to-date; close dialog if open
        if (Navigator.of(ctx).canPop()) {
          Navigator.of(ctx).pop();
        }
        return;
      }

      // ---- FORCE UPDATE (Android and iOS) ------------------------------------
      if (cfg.isForceUpdate) {
        if (Platform.isAndroid) {
          final handled = await _runAndroidInAppUpdate(ctx, cfg, isImmediate: true);
          if (handled) return; // Immediate update flow started
        }
        // Fallback to custom dialog for iOS or if Android immediate update fails
        return UpdateDialog.showRequired(
          ctx,
          title: cfg.title,
          newFeatures: cfg.newFeatures,
          onUpdatePressed: () => _launch(cfg.updateUrl, ctx, cfg),
        );
      }

      // ---- OPTIONAL UPDATE PATH -------------------------------------------
      if (Platform.isAndroid) {
        final handled = await _runAndroidInAppUpdate(ctx, cfg, isImmediate: false);
        if (handled) return; // Flexible update flow started, dialog not needed
      }

      // Fallback: regular optional dialog (iOS or Play API failed)
      UpdateDialog.showOptional(
        ctx,
        title: cfg.title,
        newFeatures: cfg.newFeatures,
        onUpdatePressed: () => _launch(cfg.updateUrl, ctx, cfg),
      );
    } catch (e) {
      debugPrint('Update check failed: $e');
      /* silent */
    }
  }

  // -------- ANDROID IN-APP UPDATE (IMMEDIATE OR FLEXIBLE) -------------------
  Future<bool> _runAndroidInAppUpdate(
    BuildContext ctx,
    AppUpdateConfig cfg, {
    required bool isImmediate,
  }) async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability != UpdateAvailability.updateAvailable) {
        debugPrint('No update available on Play Store');
        return false; // No update available; show fallback dialog
      }

      if (isImmediate) {
        // Start immediate update
        final result = await InAppUpdate.startImmediateUpdate();
        // Handle the result of the immediate update
        switch (result) {
          case AppUpdateResult.success:
            // Update completed successfully; verify version
            final newPkg = await PackageInfo.fromPlatform();
            if (!_isLower(newPkg.version, cfg.currentVersion)) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(content: Text('App updated to version ${newPkg.version}')),
              );
              if (Navigator.of(ctx).canPop()) {
                Navigator.of(ctx).pop();
              }
              _pkg = newPkg;
            } else {
              // Version still outdated despite success (unlikely, but handle it)
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content: Text('Update failed to apply')),
              );
              await SystemNavigator.pop();
            }
            break;
          case AppUpdateResult.userDeniedUpdate:
            // User canceled the update
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(content: Text('Update is required to continue')),
            );
            await SystemNavigator.pop();
            break;
          case AppUpdateResult.inAppUpdateFailed:
            // Update failed (e.g., network issue)
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(content: Text('Update failed; please try again')),
            );
            return false; // Fallback to custom dialog
          default:
            debugPrint('Unknown update result: $result');
            return false; // Fallback to custom dialog
        }
      } else {
        // Start flexible update (no bottom sheet)
        await InAppUpdate.startFlexibleUpdate();
        // Wait until download finishes and prompt for installation
        await InAppUpdate.completeFlexibleUpdate();
        // Check if updated
        final newPkg = await PackageInfo.fromPlatform();
        if (!_isLower(newPkg.version, cfg.currentVersion)) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text('App updated to version ${newPkg.version}')),
          );
          if (Navigator.of(ctx).canPop()) {
            Navigator.of(ctx).pop();
          }
          _pkg = newPkg;
        }
      }
      return true;
    } catch (e) {
      debugPrint('Android in-app update failed: $e');
      return false; // Fallback to custom dialog
    }
  }

  // -------- HELPERS --------------------------------------------------------
  bool _isLower(String cur, String latest) {
    try {
      if (cur.isEmpty || latest.isEmpty) {
        debugPrint('Empty version string: cur=$cur, latest=$latest');
        return false;
      }
      final a = cur.split('.').map(int.parse).toList();
      final b = latest.split('.').map(int.parse).toList();
      for (int i = 0; i < max(a.length, b.length); i++) {
        final x = i < a.length ? a[i] : 0;
        final y = i < b.length ? b[i] : 0;
        if (x < y) return true;
        if (x > y) return false;
      }
    } catch (e) {
      debugPrint('Invalid version format: cur=$cur, latest=$latest');
    }
    return false;
  }

  Future<void> _launch(
    String url,
    BuildContext ctx,
    AppUpdateConfig cfg,
  ) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri);
      // Check version after returning from Play Store or App Store
      final newPkg = await PackageInfo.fromPlatform();
      if (!_isLower(newPkg.version, cfg.currentVersion)) {
        // App is updated
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text('App updated to version ${newPkg.version}')),
        );
        if (Navigator.of(ctx).canPop()) {
          Navigator.of(ctx).pop();
        }
        _pkg = newPkg;
      } else if (cfg.isForceUpdate) {
        // User returned without updating; show message and exit
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(content: Text('Update is required to continue')),
        );
        await SystemNavigator.pop();
      } else {
        // Optional update canceled
        Navigator.of(ctx).pop();
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(content: Text('App update canceled')),
        );
      }
    } else {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Could not open update link')),
      );
    }
  }

  void dispose() {
    // No observer to remove
  }
} */