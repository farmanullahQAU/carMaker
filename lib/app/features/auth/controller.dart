import 'package:cardmaker/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:validatorless/validatorless.dart';

class AuthController extends GetxController {
  final AuthService authService = Get.find<AuthService>();

  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();

  // Form keys
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> resetPasswordFormKey = GlobalKey<FormState>();

  // Observables
  final RxBool isLoginMode = true.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;

  void toggleAuthMode() {
    isLoginMode.value = !isLoginMode.value;
    clearForm();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  void clearForm() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    nameController.clear();
    authService.errorMessage.value = '';
  }

  // Validation rules
  String? Function(String?) get emailValidator => Validatorless.multiple([
    Validatorless.required('Email is required'),
    Validatorless.email('Invalid email format'),
  ]);

  String? Function(String?) get passwordValidator => Validatorless.multiple([
    Validatorless.required('Password is required'),
    Validatorless.min(6, 'Password must be at least 6 characters'),
  ]);

  String? Function(String?) get confirmPasswordValidator =>
      Validatorless.multiple([
        Validatorless.required('Please confirm your password'),
        Validatorless.compare(passwordController, 'Passwords do not match'),
      ]);

  String? Function(String?) get nameValidator => Validatorless.multiple([
    Validatorless.required('Name is required'),
    Validatorless.min(2, 'Name must be at least 2 characters'),
  ]);

  // Auth methods
  Future<void> submitAuthForm() async {
    try {
      final form = isLoginMode.value
          ? loginFormKey.currentState
          : signupFormKey.currentState;

      if (form?.validate() ?? false) {
        final String? error = isLoginMode.value
            ? await authService.signInWithEmailAndPassword(
                email: emailController.text,
                password: passwordController.text,
              )
            : await authService.signUpWithEmailAndPassword(
                email: emailController.text,
                password: passwordController.text,
                confirmPassword: confirmPasswordController.text,
              );

        if (error != null) {
          authService.errorMessage.value = error;
        } else {
          // Success - navigation will be handled by auth state changes
          clearForm();
        }
      }
    } catch (e) {
      authService.errorMessage.value = 'An unexpected error occurred';
    }
  }

  Future<void> signInWithGoogle() async {
    final String? error = await authService.signInWithGoogle();
    if (error != null) {
      authService.errorMessage.value = error;
    }
  }

  Future<void> resetPassword() async {
    final form = resetPasswordFormKey.currentState;
    if (form?.validate() ?? false) {
      final String? error = await authService.sendPasswordResetEmail(
        emailController.text,
      );
      if (error != null) {
        authService.errorMessage.value = error;
      } else {
        Get.back(); // Close dialog
        Get.snackbar(
          'Success',
          'Password reset email sent. Check your inbox.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    super.onClose();
  }
}
