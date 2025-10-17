import 'package:cardmaker/app/features/profile/controller.dart';
import 'package:cardmaker/services/auth_service.dart';
import 'package:cardmaker/widgets/common/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:validatorless/validatorless.dart';

class AuthController extends GetxController {
  // Constants
  static const int _minPasswordLength = 6;
  static const int _minNameLength = 2;

  // Services
  final AuthService _authService = Get.find<AuthService>();

  // Form Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();

  // Form Keys
  final loginFormKey = GlobalKey<FormState>();
  final signupFormKey = GlobalKey<FormState>();
  final resetPasswordFormKey = GlobalKey<FormState>();

  // Observable State
  final RxBool isLoginMode = true.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;

  // Getters
  AuthService get authService => _authService;
  FormState? get _currentForm => isLoginMode.value
      ? loginFormKey.currentState
      : signupFormKey.currentState;

  @override
  void onClose() {
    _disposeControllers();
    super.onClose();
  }

  /// Toggle between login and signup modes
  void toggleAuthMode() {
    isLoginMode.toggle();
    _clearForm();
  }

  /// Toggle password visibility
  void togglePasswordVisibility() => obscurePassword.toggle();

  /// Toggle confirm password visibility
  void toggleConfirmPasswordVisibility() => obscureConfirmPassword.toggle();

  /// Clear all form fields and errors
  void _clearForm() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    nameController.clear();
  }

  /// Email validation with comprehensive rules
  String? Function(String?) get emailValidator => Validatorless.multiple([
    Validatorless.required('Email is required'),
    Validatorless.email('Please enter a valid email address'),
  ]);

  /// Password validation with security requirements
  String? Function(String?) get passwordValidator => Validatorless.multiple([
    Validatorless.required('Password is required'),
    Validatorless.min(
      _minPasswordLength,
      'Password must be at least $_minPasswordLength characters',
    ),
  ]);

  /// Confirm password validation with matching check
  String? Function(String?) get confirmPasswordValidator =>
      Validatorless.multiple([
        Validatorless.required('Please confirm your password'),
        Validatorless.compare(passwordController, 'Passwords do not match'),
      ]);

  /// Name validation for signup
  String? Function(String?) get nameValidator => Validatorless.multiple([
    Validatorless.required('Full name is required'),
    Validatorless.min(
      _minNameLength,
      'Name must be at least $_minNameLength characters',
    ),
  ]);

  /// Submit authentication form (login or signup)
  Future<void> submitAuthForm() async {
    if (!(_currentForm?.validate() ?? false)) return;

    try {
      AppToast.loading(message: "Authenticating...");

      await (isLoginMode.value ? _performLogin() : _performSignup());

      if (isLoginMode.isFalse) {
        toggleAuthMode();
      }
      _clearForm();

      AppToast.closeLoading();
    } catch (e) {
      AppToast.error(message: e.toString());
    }
  }

  /// Perform login operation
  Future<void> _performLogin() async {
    await authService.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    if (Get.isRegistered<ProfileController>()) {
      Future.wait([
        Get.find<ProfileController>().refreshDrafts(),
        Get.find<ProfileController>().refreshFavorites(),
      ]);
    }
    Get.back();
  }

  /// Perform signup operation
  Future<void> _performSignup() => _authService.signUpWithEmailAndPassword(
    email: emailController.text.trim(),
    password: passwordController.text,
    confirmPassword: confirmPasswordController.text,
  );

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      AppToast.loading(message: "Signing in with Google...", showLogo: false);

      await _authService.signInWithGoogle();
      AppToast.closeLoading();
      if (Get.isRegistered<ProfileController>()) {
        Future.wait([
          Get.find<ProfileController>().refreshDrafts(),
          Get.find<ProfileController>().refreshFavorites(),
        ]);
      }

      // Get.back();
    } catch (e) {
      AppToast.error(message: e.toString());
    } finally {
      if (authService.user != null) {
        Get.back();
      }
    }
  }

  /// Reset password via email
  Future<void> resetPassword() async {
    if (!(resetPasswordFormKey.currentState?.validate() ?? false)) return;

    try {
      await _authService.sendPasswordResetEmail(emailController.text.trim());

      Get.back(); // Close dialog
      _showPasswordResetSuccess();
    } catch (e) {
      AppToast.error(message: e.toString());
    }
  }

  /// Show password reset success message
  void _showPasswordResetSuccess() {
    Get.snackbar(
      'Email Sent',
      'Password reset link sent to your email address.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.shade100,
      colorText: Colors.blue.shade800,
      duration: const Duration(seconds: 3),
    );
  }

  /// Dispose all text controllers
  void _disposeControllers() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
  }
}
