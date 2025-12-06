import 'dart:math';

import 'package:cardmaker/core/utils/toast_helper.dart';
import 'package:cardmaker/services/auth_service.dart';
import 'package:cardmaker/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class FeedbackController extends GetxController {
  final TextEditingController feedbackController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxInt characterCount = 0.obs;
  final int maxCharacters = 100;
  final _storage = GetStorage();
  static const String _deviceIdKey = 'device_id';

  @override
  void onInit() {
    super.onInit();
    feedbackController.addListener(_updateCharacterCount);
    _ensureDeviceId();
    _updateCanSubmit(); // Initialize canSubmit
  }

  // Generate and store a unique device ID for anonymous users
  String _ensureDeviceId() {
    String? deviceId = _storage.read(_deviceIdKey);
    if (deviceId == null || deviceId.isEmpty) {
      // Generate a unique device ID
      deviceId = _generateDeviceId();
      _storage.write(_deviceIdKey, deviceId);
    }
    return deviceId;
  }

  String _generateDeviceId() {
    // Generate a unique ID using timestamp and random string
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999);
    return 'device_${timestamp}_$random';
  }

  @override
  void onClose() {
    feedbackController.removeListener(_updateCharacterCount);
    feedbackController.dispose();
    super.onClose();
  }

  void _updateCharacterCount() {
    characterCount.value = feedbackController.text.length;
    // Update canSubmit reactively
    _updateCanSubmit();
  }

  final RxBool canSubmit = false.obs;

  void _updateCanSubmit() {
    canSubmit.value =
        feedbackController.text.trim().isNotEmpty &&
        !isLoading.value &&
        characterCount.value <= maxCharacters;
  }

  Future<void> submitFeedback() async {
    if (!canSubmit.value) return;

    final feedbackText = feedbackController.text.trim();
    if (feedbackText.isEmpty) {
      ToastHelper.error('Please enter your feedback');
      return;
    }

    if (feedbackText.length > maxCharacters) {
      ToastHelper.error('Feedback must be $maxCharacters characters or less');
      return;
    }

    try {
      isLoading.value = true;
      _updateCanSubmit(); // Update button state when loading starts

      final authService = Get.find<AuthService>();
      final userId = authService.user?.uid;
      final userEmail = authService.user?.email;

      // Get device ID for anonymous users
      String? deviceId;
      if (userId == null) {
        deviceId = _ensureDeviceId();
      }

      // Check feedback count before submitting
      final feedbackCount = await FirestoreServices().getFeedbackCount(
        userId: userId,
        deviceId: deviceId,
      );

      if (feedbackCount >= 10) {
        ToastHelper.error(
          'You have reached the maximum limit of 10 feedbacks. Thank you for your continued support!',
        );
        return;
      }

      await FirestoreServices().saveFeedback(
        feedback: feedbackText,
        userId: userId,
        userEmail: userEmail,
        deviceId: deviceId,
      );

      ToastHelper.success('Thank you for your feedback!');
      feedbackController.clear();

      // Close the screen after successful submission
      Future.delayed(const Duration(milliseconds: 500), () {
        Get.back();
      });
    } catch (e) {
      final errorMessage = e.toString().contains('Maximum feedback limit')
          ? e.toString().replaceAll('Exception: ', '')
          : 'Failed to submit feedback. Please try again.';
      ToastHelper.error(errorMessage);
      debugPrint('Error submitting feedback: $e');
    } finally {
      isLoading.value = false;
      _updateCanSubmit(); // Update button state after loading
    }
  }
}
