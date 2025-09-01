import 'package:cardmaker/app/features/auth/controller.dart';
import 'package:cardmaker/core/values/app_colors.dart';
import 'package:cardmaker/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:get/get.dart';

class AuthScreen extends GetView<AuthController> {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          // _buildBackground(),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Logo and Title
                  _buildHeader(),

                  const SizedBox(height: 40),

                  // Auth Forms
                  Obx(
                    () => controller.isLoginMode.value
                        ? _buildLoginForm()
                        : _buildSignupForm(),
                  ),

                  const SizedBox(height: 20),

                  // Error Message
                  _buildErrorMessage(),

                  const SizedBox(height: 20),

                  // Social Login Buttons
                  _buildSocialLoginButtons(),

                  const SizedBox(height: 20),

                  // Switch Auth Mode
                  _buildAuthModeSwitch(),
                ],
              ),
            ),
          ),

          // Loading Overlay
          _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.branding.withOpacity(0.1),
            AppColors.brandingLight.withOpacity(0.05),
            Colors.white,
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Professional logo container
        Container(
          width: 100,
          height: 100,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Get.theme.colorScheme.shadow.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Image.asset('assets/icon.png', fit: BoxFit.contain),
        ),

        const SizedBox(height: 24),

        // Title with clean typography
        Text(
          controller.isLoginMode.value ? 'Welcome Back' : 'Create Account',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 28),
        ),

        const SizedBox(height: 12),

        // Subtitle with clean styling
        Text(
          controller.isLoginMode.value
              ? 'Sign in to continue your creative journey'
              : 'Join us to start creating amazing designs',
          style: TextStyle(color: Colors.black54, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: controller.loginFormKey,
      child: Column(
        children: [
          // Email Field
          TextFormField(
            controller: controller.emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: controller.emailValidator,
          ),

          const SizedBox(height: 16),

          // Password Field
          TextFormField(
            controller: controller.passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscurePassword.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: controller.togglePasswordVisibility,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            obscureText: controller.obscurePassword.value,
            validator: controller.passwordValidator,
          ),

          const SizedBox(height: 8),

          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _showResetPasswordDialog,
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  color: AppColors.branding,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Login Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: controller.submitAuthForm,
              // style: ElevatedButton.styleFrom(
              //   backgroundColor: AppColors.branding,
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(12),
              //   ),
              //   elevation: 2,
              // ),
              child: Text(
                'Sign In',
                style: Get.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupForm() {
    return Form(
      key: controller.signupFormKey,
      child: Column(
        children: [
          // Name Field
          TextFormField(
            controller: controller.nameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: controller.nameValidator,
          ),

          const SizedBox(height: 16),

          // Email Field
          TextFormField(
            controller: controller.emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: controller.emailValidator,
          ),

          const SizedBox(height: 16),

          // Password Field
          TextFormField(
            controller: controller.passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscurePassword.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: controller.togglePasswordVisibility,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            obscureText: controller.obscurePassword.value,
            validator: controller.passwordValidator,
          ),

          const SizedBox(height: 16),

          // Confirm Password Field
          TextFormField(
            controller: controller.confirmPasswordController,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscureConfirmPassword.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: controller.toggleConfirmPasswordVisibility,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            obscureText: controller.obscureConfirmPassword.value,
            validator: controller.confirmPasswordValidator,
          ),

          const SizedBox(height: 24),

          // Sign Up Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: controller.submitAuthForm,

              child: Text(
                'Create Account',
                style: Get.textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Obx(() {
      if (Get.find<AuthService>().errorMessage.isEmpty) {
        return const SizedBox();
      }

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade100),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                Get.find<AuthService>().errorMessage.value,
                style: TextStyle(color: Colors.red.shade700, fontSize: 14),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.red.shade600, size: 18),
              onPressed: () => Get.find<AuthService>().errorMessage.value = '',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSocialLoginButtons() {
    return Column(
      children: [
        // Divider
        Row(
          children: [
            Expanded(
              child: Divider(
                color: Get.theme.colorScheme.onSurface.withOpacity(0.2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Or continue with',
                style: TextStyle(
                  color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: Get.theme.colorScheme.onSurface.withOpacity(0.2),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Google Sign In Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: SignInButton(
            Buttons.Google,
            text: 'Continue with Google',
            onPressed: controller.signInWithGoogle,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthModeSwitch() {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            controller.isLoginMode.value
                ? "Don't have an account?"
                : 'Already have an account?',
            style: TextStyle(
              color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          TextButton(
            onPressed: controller.toggleAuthMode,
            child: Text(
              controller.isLoginMode.value ? 'Sign Up' : 'Sign In',
              style: TextStyle(
                color: AppColors.branding,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Obx(() {
      if (!Get.find<AuthService>().isLoading.value) {
        return const SizedBox();
      }

      return Container(
        color: Colors.black.withOpacity(0.3),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.branding),
          ),
        ),
      );
    });
  }

  void _showResetPasswordDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: controller.resetPasswordFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Reset Password',
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Enter your email address to receive a password reset link',
                  style: Get.textTheme.bodyMedium?.copyWith(
                    color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: controller.emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: controller.emailValidator,
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: Get.back,
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: Get.theme.colorScheme.outline,
                          ),
                        ),
                        child: Text('Cancel'),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: controller.resetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.branding,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Send Link',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
