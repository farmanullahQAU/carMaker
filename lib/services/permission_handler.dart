import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService extends GetxService {
  static PermissionService get to => Get.find();

  /// Requests photos permission for saving images to gallery.
  /// Shows dialog for denied/permanently denied cases, only opens settings on user confirmation.
  Future<PermissionStatus> requestPhotosPermission() async {
    try {
      // Check current status
      PermissionStatus status = await Permission.photos.status;

      if (status.isGranted) {
        if (kDebugMode) debugPrint('Photos permission already granted');
        return PermissionStatus.granted;
      }

      // if (status.isLimited) {
      //   if (kDebugMode)
      //     debugPrint('Photos permission limited (iOS partial access)');
      //   _showLimitedAccessMessage();
      //   return PermissionStatus.limited;
      // }

      if (status.isPermanentlyDenied || status.isDenied) {
        // Show dialog for both denied and permanently denied
        final shouldOpenSettings = await _showPermissionDialog();
        if (shouldOpenSettings) {
          await openAppSettings();
          // Recheck after user potentially changes settings
          status = await Permission.photos.status;
          if (status.isGranted) return PermissionStatus.granted;
          if (status.isLimited) {
            _showLimitedAccessMessage();
            return PermissionStatus.limited;
          }
        }
        return status;
      }

      // Request permission
      status = await Permission.photos.request();

      switch (status) {
        case PermissionStatus.granted:
          if (kDebugMode) debugPrint('Photos permission granted');
          return PermissionStatus.granted;
        case PermissionStatus.limited:
          if (kDebugMode) debugPrint('Photos permission limited (iOS)');
          _showLimitedAccessMessage();
          return PermissionStatus.limited;
        case PermissionStatus.denied:
        case PermissionStatus.permanentlyDenied:
          if (kDebugMode) {
            debugPrint(
              'Photos permission ${status.isPermanentlyDenied ? 'permanently denied' : 'denied'}',
            );
          }
          final shouldOpenSettings = await _showPermissionDialog();
          if (shouldOpenSettings) {
            await openAppSettings();
            // Recheck
            status = await Permission.photos.status;
            if (status.isGranted) return PermissionStatus.granted;
            if (status.isLimited) {
              _showLimitedAccessMessage();
              return PermissionStatus.limited;
            }
          }
          return status;
        case PermissionStatus.restricted:
          if (kDebugMode) debugPrint('Photos permission restricted');
          _showRestrictedMessage();
          return PermissionStatus.restricted;
        default:
          return status;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error requesting photos permission: $e');
      Get.snackbar(
        'Permission Error',
        'Failed to request photos permission: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return PermissionStatus.denied;
    }
  }

  /// Shows a dialog for denied/permanently denied cases, returns true if user selects "Open Settings".
  Future<bool> _showPermissionDialog() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Photos Permission Required'),
        content: const Text(
          'This app needs photos permission to save images to your gallery. Please enable it in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Open Settings'),
          ),
        ],
      ),
      barrierDismissible: true,
      name: 'permission_dialog',
    );
    return result ?? false;
  }

  /// Shows a message for limited access (iOS).
  void _showLimitedAccessMessage() {
    Get.snackbar(
      'Limited Access',
      'Partial access granted. Some images may not be saved.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.shade100,
      colorText: Colors.blue.shade900,
      duration: const Duration(seconds: 3),
    );
  }

  /// Shows a message for restricted access.
  void _showRestrictedMessage() {
    Get.snackbar(
      'Permission Restricted',
      'Photos access is restricted by device policy. Cannot save images.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade900,
      duration: const Duration(seconds: 4),
    );
  }

  /// Checks if photos permission is granted without requesting.
  Future<bool> hasPhotosPermission() async {
    final status = await Permission.photos.status;
    return status.isGranted || status.isLimited;
  }

  @override
  void onInit() {
    super.onInit();
    if (kDebugMode) debugPrint('PermissionService initialized');
  }

  @override
  void onClose() {
    super.onClose();
    if (kDebugMode) debugPrint('PermissionService disposed');
  }
}
