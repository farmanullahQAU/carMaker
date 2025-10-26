import 'package:cardmaker/app/features/profile/controller.dart';
import 'package:cardmaker/app/routes/app_routes.dart';
import 'package:cardmaker/app/settings/controller.dart';
import 'package:cardmaker/core/values/app_constants.dart';
import 'package:cardmaker/services/auth_service.dart';
import 'package:cardmaker/services/update_service.dart';
import 'package:cardmaker/widgets/common/app_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  User? get user => Get.find<AuthService>().user;

  @override
  Widget build(BuildContext context) {
    final updateManger = UpdateManager();

    final theme = Theme.of(context);
    final settingsController = Get.find<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Account Section
          Obx(() => _buildUserProfile(user, theme)),

          _buildDivider(theme),

          // Appearance Section
          _buildSettingsTile(
            icon: Icons.palette_outlined,
            title: 'Appearance',
            theme: theme,
            onTap: () =>
                _showAppearanceSheet(context, theme, settingsController),
          ),

          _buildDivider(theme),

          // Terms and Privacy
          _buildSettingsTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            theme: theme,
            onTap: () => _launchUrl(kTermsOfServiceUrl),
          ),

          _buildSettingsTile(
            icon: Icons.security_outlined,
            title: 'Privacy Policy',
            theme: theme,
            onTap: () => _launchUrl(kPrivacyPolicyUrl),
          ),

          _buildDivider(theme),

          // Authentication Options
          Obx(
            () => user == null
                ? _buildSettingsTile(
                    icon: Icons.login_outlined,
                    title: 'Login',
                    titleColor: theme.colorScheme.error,
                    theme: theme,
                    onTap: () async {
                      await Get.toNamed(AppRoutes.auth);
                    },
                  )
                : Column(
                    children: [
                      _buildSettingsTile(
                        icon: Icons.logout_outlined,
                        title: 'Sign Out',
                        titleColor: theme.colorScheme.error,
                        theme: theme,
                        onTap: _showSignOutConfirmation,
                      ),
                      _buildSettingsTile(
                        icon: Icons.delete_outline,
                        title: 'Delete Account',
                        titleColor: Colors.red[700],
                        theme: theme,
                        onTap: () => _showDeleteAccountConfirmation(context),
                      ),
                    ],
                  ),
          ),

          const SizedBox(height: 32),

          // Version
          Center(
            child: Text(
              'Version ${updateManger.currVer}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildUserProfile(User? user, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.surfaceContainer,
            ),
            child: user?.photoURL != null
                ? ClipOval(
                    child: Image.network(
                      user!.photoURL!,
                      fit: BoxFit.cover,
                      width: 56,
                      height: 56,
                    ),
                  )
                : Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.surfaceContainer,
                    ),
                    child: ClipOval(
                      child: Icon(
                        Icons.person,
                        size: 28,
                        color: theme.disabledColor,
                      ),
                    ),
                  ),
          ),

          const SizedBox(width: 16),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user == null ? "Guest User" : user.displayName ?? "----",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'Not signed in',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? titleColor,
    required ThemeData theme,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 22, color: titleColor ?? theme.iconTheme.color),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: titleColor ?? theme.textTheme.bodyLarge?.color,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
            )
          : null,
      trailing: titleColor == null
          ? Icon(Icons.chevron_right, size: 22, color: theme.hintColor)
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      onTap: onTap,
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: theme.dividerColor,
      indent: 20,
      endIndent: 20,
    );
  }

  void _showAppearanceSheet(
    BuildContext context,
    ThemeData theme,
    SettingsController controller,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appearance',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Obx(
              () => Column(
                children: [
                  _buildThemeOption(
                    context: context,
                    theme: theme,
                    title: 'System',
                    value: ThemeMode.system,
                    groupValue: controller.themeMode.value,
                    onChanged: (value) {
                      if (value != null) {
                        controller.setThemeMode(value);
                      }
                    },
                  ),
                  _buildThemeOption(
                    context: context,
                    theme: theme,
                    title: 'Light',
                    value: ThemeMode.light,
                    groupValue: controller.themeMode.value,
                    onChanged: (value) {
                      if (value != null) {
                        controller.setThemeMode(value);
                      }
                    },
                  ),
                  _buildThemeOption(
                    context: context,
                    theme: theme,
                    title: 'Dark',
                    value: ThemeMode.dark,
                    groupValue: controller.themeMode.value,
                    onChanged: (value) {
                      if (value != null) {
                        controller.setThemeMode(value);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required ThemeData theme,
    required String title,
    required ThemeMode value,
    required ThemeMode groupValue,
    required ValueChanged<ThemeMode?> onChanged,
  }) {
    return RadioListTile<ThemeMode>(
      title: Text(title),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: theme.primaryColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  void _showSignOutConfirmation() {
    final theme = Theme.of(Get.context!);

    Get.dialog(
      AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w600)),
        content: Text(
          'Are you sure you want to sign out?',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await FirebaseAuth.instance.signOut();
              Get.back();

              if (Get.isRegistered<ProfileController>()) {
                Get.find<ProfileController>().drafts.clear();
              }
            },
            child: Text(
              'Sign Out',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountConfirmation(BuildContext context) {
    final theme = Theme.of(context);
    final authService = Get.find<AuthService>();
    final user = authService.user;

    if (user == null) return;

    final isEmailUser = user.providerData.any(
      (info) => info.providerId == 'password',
    );

    Get.dialog(
      AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red[700], size: 28),
            const SizedBox(width: 12),
            Text(
              'Delete Account',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.red[700],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This action cannot be undone. All your data including:',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            _buildDeleteWarningItem('• All your saved drafts', theme),
            _buildDeleteWarningItem('• Your favorites', theme),
            _buildDeleteWarningItem('• Your account information', theme),
            const SizedBox(height: 12),
            Text(
              'will be permanently deleted.',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              if (isEmailUser) {
                _showPasswordConfirmation(context);
              } else {
                _showFinalDeleteConfirmation(context);
              }
            },
            child: Text(
              'Continue',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.red[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteWarningItem(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
      ),
    );
  }

  void _showPasswordConfirmation(BuildContext context) {
    final theme = Theme.of(context);
    final passwordController = TextEditingController();
    final RxBool obscurePassword = true.obs;

    Get.dialog(
      AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Confirm Password',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Please enter your password to continue',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Obx(
              () => TextField(
                controller: passwordController,
                obscureText: obscurePassword.value,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword.value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => obscurePassword.toggle(),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              passwordController.dispose();
              Get.back();
            },
            child: Text(
              'Cancel',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final password = passwordController.text;
              passwordController.dispose();
              Get.back();
              _showFinalDeleteConfirmation(context, password: password);
            },
            child: Text(
              'Continue',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.red[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFinalDeleteConfirmation(BuildContext context, {String? password}) {
    final theme = Theme.of(context);
    final authService = Get.find<AuthService>();

    Get.dialog(
      AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Final Confirmation',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.red[700],
          ),
        ),
        content: Text(
          'Are you absolutely sure you want to delete your account? This action is permanent and irreversible.',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Obx(
            () => authService.isLoading.value
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : TextButton(
                    onPressed: () async {
                      try {
                        await authService.deleteAccount(password: password);
                        Get.back();
                        Get.back();
                        AppToast.success(
                          message: 'Account deleted successfully',
                        );
                      } catch (e) {
                        Get.back();
                        AppToast.error(message: e.toString());
                      }
                    },
                    child: Text(
                      'Delete Account',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.red[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _launchUrl(String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        AppToast.error(message: 'Cannot launch URL');
      }
    } catch (err) {
      AppToast.error(message: err.toString());
    }
  }
}
