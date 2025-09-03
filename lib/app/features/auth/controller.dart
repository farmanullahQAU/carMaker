import 'package:cardmaker/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:validatorless/validatorless.dart';

// class AuthController extends GetxController {
//   final AuthService authService = Get.find<AuthService>();

//   // Form controllers
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final confirmPasswordController = TextEditingController();
//   final nameController = TextEditingController();

//   // Form keys
//   final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
//   final GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();
//   final GlobalKey<FormState> resetPasswordFormKey = GlobalKey<FormState>();

//   // Observables
//   final RxBool isLoginMode = true.obs;
//   final RxBool obscurePassword = true.obs;
//   final RxBool obscureConfirmPassword = true.obs;

//   void toggleAuthMode() {
//     isLoginMode.value = !isLoginMode.value;
//     clearForm();
//   }

//   void togglePasswordVisibility() {
//     obscurePassword.value = !obscurePassword.value;
//   }

//   void toggleConfirmPasswordVisibility() {
//     obscureConfirmPassword.value = !obscureConfirmPassword.value;
//   }

//   void clearForm() {
//     emailController.clear();
//     passwordController.clear();
//     confirmPasswordController.clear();
//     nameController.clear();
//     authService.errorMessage.value = '';
//   }

//   // Validation rules
//   String? Function(String?) get emailValidator => Validatorless.multiple([
//     Validatorless.required('Email is required'),
//     Validatorless.email('Invalid email format'),
//   ]);

//   String? Function(String?) get passwordValidator => Validatorless.multiple([
//     Validatorless.required('Password is required'),
//     Validatorless.min(6, 'Password must be at least 6 characters'),
//   ]);

//   String? Function(String?) get confirmPasswordValidator =>
//       Validatorless.multiple([
//         Validatorless.required('Please confirm your password'),
//         Validatorless.compare(passwordController, 'Passwords do not match'),
//       ]);

//   String? Function(String?) get nameValidator => Validatorless.multiple([
//     Validatorless.required('Name is required'),
//     Validatorless.min(2, 'Name must be at least 2 characters'),
//   ]);

//   // Auth methods
//   Future<void> submitAuthForm() async {
//     try {
//       final form = isLoginMode.value
//           ? loginFormKey.currentState
//           : signupFormKey.currentState;

//       if (form?.validate() ?? false) {
//         final String? error = isLoginMode.value
//             ? await authService.signInWithEmailAndPassword(
//                 email: emailController.text,
//                 password: passwordController.text,
//               )
//             : await authService.signUpWithEmailAndPassword(
//                 email: emailController.text,
//                 password: passwordController.text,
//                 confirmPassword: confirmPasswordController.text,
//               );

//         if (error != null) {
//           authService.errorMessage.value = error;
//         } else {
//           // Success - navigation will be handled by auth state changes
//           clearForm();
//         }
//       }
//     } catch (e) {
//       authService.errorMessage.value = 'An unexpected error occurred';
//     }
//   }

//   Future<void> signInWithGoogle() async {
//     final String? error = await authService.signInWithGoogle();
//     Get.back();
//     if (error != null) {
//       authService.errorMessage.value = error;
//     }
//   }

//   Future<void> resetPassword() async {
//     final form = resetPasswordFormKey.currentState;
//     if (form?.validate() ?? false) {
//       final String? error = await authService.sendPasswordResetEmail(
//         emailController.text,
//       );
//       if (error != null) {
//         authService.errorMessage.value = error;
//       } else {
//         Get.back(); // Close dialog
//         Get.snackbar(
//           'Success',
//           'Password reset email sent. Check your inbox.',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//         );
//       }
//     }
//   }

//   @override
//   void onClose() {
//     emailController.dispose();
//     passwordController.dispose();
//     confirmPasswordController.dispose();
//     nameController.dispose();
//     super.onClose();
//   }
// }
/// Professional Authentication Controller with comprehensive form management
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
    _authService.errorMessage.value = '';
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
      final String? error = await (isLoginMode.value
          ? _performLogin()
          : _performSignup());

      if (error != null) {
        _authService.errorMessage.value = error;
      } else {
        _clearForm();
        _showSuccessMessage();
      }
    } catch (e) {
      _authService.errorMessage.value =
          'An unexpected error occurred. Please try again.';
    }
  }

  /// Perform login operation
  Future<String?> _performLogin() => _authService.signInWithEmailAndPassword(
    email: emailController.text.trim(),
    password: passwordController.text,
  );

  /// Perform signup operation
  Future<String?> _performSignup() => _authService.signUpWithEmailAndPassword(
    email: emailController.text.trim(),
    password: passwordController.text,
    confirmPassword: confirmPasswordController.text,
  );

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      final String? error = await _authService.signInWithGoogle();
      if (error != null) {
        _authService.errorMessage.value = error;
      }
    } catch (e) {
      _authService.errorMessage.value =
          'Google sign-in failed. Please try again.';
    }
  }

  /// Reset password via email
  Future<void> resetPassword() async {
    if (!(resetPasswordFormKey.currentState?.validate() ?? false)) return;

    try {
      final String? error = await _authService.sendPasswordResetEmail(
        emailController.text.trim(),
      );

      if (error != null) {
        _authService.errorMessage.value = error;
      } else {
        Get.back(); // Close dialog
        _showPasswordResetSuccess();
      }
    } catch (e) {
      _authService.errorMessage.value =
          'Failed to send reset email. Please try again.';
    }
  }

  /// Show success message for authentication
  void _showSuccessMessage() {
    final message = isLoginMode.value
        ? 'Welcome back!'
        : 'Account created successfully!';

    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade800,
      duration: const Duration(seconds: 2),
    );
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
