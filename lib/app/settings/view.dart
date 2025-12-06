// import 'package:cardmaker/app/features/profile/controller.dart';
// import 'package:cardmaker/app/routes/app_routes.dart';
// import 'package:cardmaker/app/settings/controller.dart';
// import 'package:cardmaker/core/utils/admin_utils.dart';
// import 'package:cardmaker/core/utils/toast_helper.dart';
// import 'package:cardmaker/core/values/app_constants.dart';
// import 'package:cardmaker/services/auth_service.dart';
// import 'package:cardmaker/services/remote_config.dart';
// import 'package:cardmaker/widgets/common/banner_ad_widget.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:url_launcher/url_launcher.dart';

import 'package:cardmaker/app/features/profile/controller.dart';
import 'package:cardmaker/app/routes/app_routes.dart';
import 'package:cardmaker/app/settings/controller.dart';
import 'package:cardmaker/core/utils/admin_utils.dart';
import 'package:cardmaker/core/utils/toast_helper.dart';
import 'package:cardmaker/core/values/app_constants.dart';
import 'package:cardmaker/services/app_review_service.dart';
import 'package:cardmaker/services/auth_service.dart';
import 'package:cardmaker/services/remote_config.dart';
import 'package:cardmaker/widgets/common/banner_ad_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  User? get user => Get.find<AuthService>().user;

  @override
  Widget build(BuildContext context) {
    // Note: The screenshot uses rounded containers for groups and a specific
    // surface color. We'll use theme colors for consistency.
    final theme = Theme.of(context);
    final settingsController = Get.find<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        // Match the screenshot's AppBar style
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        // No explicit elevation to match the flat look of the screenshot
        elevation: 0,
      ),
      body: ListView(
        // Add vertical padding and a bottom banner ad padding
        padding: const EdgeInsets.symmetric(vertical: 0),
        children: [
          // 1. Appearance Section
          _buildSectionHeader(theme, 'Appearance'),
          _buildAppearanceSettings(theme, settingsController),

          // 2. About & Support Section
          _buildSectionHeader(theme, 'About & Support'),
          _buildAboutSupportSettings(theme),

          // 6. Authentication Options (Original App Logic)
          // We keep this separate as it doesn't align with a section in the screenshot
          _buildSectionHeader(theme, 'Account'),
          Obx(() => _buildAccountOptions(theme)),

          // Original App's Admin Section (kept for functionality)
          FutureBuilder<bool>(
            future: AdminUtils.isAdmin(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data == true) {
                return _buildAdminSection(theme);
              }
              return const SizedBox.shrink();
            },
          ),

          const SizedBox(height: 32),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: BannerAdWidget(),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // --- Utility Widgets ---

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // --- Appearance Section ---

  Widget _buildAppearanceSettings(
    ThemeData theme,
    SettingsController controller,
  ) {
    return _buildGroupContainer(
      theme,
      children: [
        // Theme (Replaces the original appearance section with inline toggle)
        _buildThemeToggleTile(theme, controller),
      ],
    );
  }

  Widget _buildThemeToggleTile(ThemeData theme, SettingsController controller) {
    // Theme logic uses the controller and the custom toggle button
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildIconTitle(Icons.contrast, 'Theme', theme),
          // Theme Toggle Widget
          Obx(() => _buildThemeToggle(theme, controller)),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(ThemeData theme, SettingsController controller) {
    final currentMode = controller.themeMode.value;

    // Replicate the pill-shaped segmented control from the HTML/Screenshot
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildThemeOptionButton(
            theme: theme,
            title: 'Light',
            mode: ThemeMode.light,
            isSelected: currentMode == ThemeMode.light,
            onTap: () => controller.setThemeMode(ThemeMode.light),
          ),
          _buildThemeOptionButton(
            theme: theme,
            title: 'Dark',
            mode: ThemeMode.dark,
            isSelected: currentMode == ThemeMode.dark,
            onTap: () => controller.setThemeMode(ThemeMode.dark),
          ),
          _buildThemeOptionButton(
            theme: theme,
            title: 'System',
            mode: ThemeMode.system,
            isSelected: currentMode == ThemeMode.system,
            onTap: () => controller.setThemeMode(ThemeMode.system),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOptionButton({
    required ThemeData theme,
    required String title,
    required ThemeMode mode,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    // The button logic for the segmented control
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isSelected
              ? Border.all(color: theme.colorScheme.primary)
              : null,
        ),
        child: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? theme.colorScheme.onSurface : theme.hintColor,
          ),
        ),
      ),
    );
  }

  // --- About & Support Section (Using original app logic) ---

  Widget _buildAboutSupportSettings(ThemeData theme) {
    return _buildGroupContainer(
      theme,
      children: [
        // App Version (Original _buildInfoTile logic)
        _buildInfoTile(
          icon: Icons.info,
          title: 'App Version',
          value: RemoteConfigService().config.update.currentVersion,
          theme: theme,
        ),
        _buildDivider(theme),
        // Rate Us
        _buildSettingsTile(
          icon: Icons.star_outline,
          title: 'Rate Us',
          theme: theme,
          onTap: () => _handleRateUs(),
          showChevron: true,
        ),
        _buildDivider(theme),
        // Send Feedback
        _buildSettingsTile(
          icon: Icons.feedback,
          title: 'Send Feedback',
          theme: theme,
          onTap: () => _handleSendFeedback(),
          showChevron: true,
        ),
        _buildDivider(theme),
        // Privacy Policy
        _buildSettingsTile(
          icon: Icons.shield,
          title: 'Privacy Policy',
          theme: theme,
          onTap: () => _launchUrl(kPrivacyPolicyUrl),
          showChevron: true,
        ),
        // Terms of Service (Included here to keep the group clean)
        _buildDivider(theme),
        _buildSettingsTile(
          icon: Icons.description,
          title: 'Terms of Service',
          theme: theme,
          onTap: () => _launchUrl(kTermsOfServiceUrl),
          showChevron: true,
        ),
      ],
    );
  }

  // --- Account Section (Original App Logic) ---

  Widget _buildAccountOptions(ThemeData theme) {
    // This section is slightly modified to use the new tile style
    return _buildGroupContainer(
      theme,
      children: [
        user == null
            ? _buildSettingsTile(
                icon: Icons.login_outlined,
                title: 'Login',
                theme: theme,
                onTap: () async => await Get.toNamed(AppRoutes.auth),
                titleColor: theme.colorScheme.error,
                showChevron: true,
              )
            : Column(
                children: [
                  _buildSettingsTile(
                    icon: Icons.logout_outlined,
                    title: 'Sign Out',
                    theme: theme,
                    onTap: _showSignOutConfirmation,
                    titleColor: theme.colorScheme.error,
                    showChevron: false, // Sign out usually doesn't need chevron
                  ),
                  _buildDivider(theme),
                  _buildSettingsTile(
                    icon: Icons.delete_outline,
                    title: 'Delete Account',
                    theme: theme,
                    onTap: () => _showDeleteAccountConfirmation(Get.context!),
                    titleColor: Colors.red[700],
                    showChevron: false, // Delete usually doesn't need chevron
                  ),
                ],
              ),
      ],
    );
  }

  // --- Admin Section (Original App Logic) ---

  Widget _buildAdminSection(ThemeData theme) {
    return Column(
      children: [
        _buildSectionHeader(theme, 'Admin'),
        _buildGroupContainer(
          theme,
          children: [
            _buildSettingsTile(
              icon: Icons.admin_panel_settings_outlined,
              title: 'Manage Projects',
              subtitle: 'Admin only',
              theme: theme,
              onTap: () => Get.toNamed(AppRoutes.adminProjectManagement),
              showChevron: true,
            ),
          ],
        ),
      ],
    );
  }

  // --- Core Design Widgets ---

  // Replicates the rounded container for setting groups
  Widget _buildGroupContainer(
    ThemeData theme, {
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: theme
              .colorScheme
              .surfaceContainerLow, // Used surfaceContainerLow for group background
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(children: children),
        ),
      ),
    );
  }

  // Standard tile for navigation or information
  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? titleColor,
    required ThemeData theme,
    VoidCallback? onTap,
    Widget? trailingWidget,
    bool showChevron = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _buildIconTitle(icon, title, theme, titleColor: titleColor),
              const Spacer(),
              if (trailingWidget != null) trailingWidget,
              if (showChevron)
                Icon(Icons.arrow_forward_ios, size: 16, color: theme.hintColor),
            ],
          ),
        ),
      ),
    );
  }

  // Tile used for simple info display (e.g., App Version)
  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildIconTitle(icon, title, theme),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.hintColor),
          ),
        ],
      ),
    );
  }

  // Helper to build the leading icon and title part of a tile
  Widget _buildIconTitle(
    IconData icon,
    String title,
    ThemeData theme, {
    Color? titleColor,
  }) {
    return Row(
      children: [
        // Replicate the small rounded icon box
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: theme
                .colorScheme
                .surfaceContainerHigh, // Light gray background for icon
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: theme.colorScheme.onSurface),
        ),
        const SizedBox(width: 16),
        Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: titleColor ?? theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  // Divider used within the grouped container
  Widget _buildDivider(ThemeData theme) {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: theme.dividerColor.withOpacity(0.3),
      indent: 64, // To align with the start of the title text
      endIndent: 16,
    );
  }

  // --- Original Logic Functions (Kept for functionality) ---

  // NOTE: Keeping the original dialog and launch logic for sign out, delete, and URL handling.
  // The original body was replaced by the new layout structure.

  void _handleRateUs() {
    AppReviewService().openStoreListing();
  }

  void _handleSendFeedback() {
    // Navigate to feedback screen instead of opening email
    Get.toNamed(AppRoutes.feedback);
  }

  void _showSignOutConfirmation() {
    // Original Sign Out Confirmation Dialog
    final theme = Theme.of(Get.context!);
    Get.dialog(
      // ... (AlertDialog implementation)
      AlertDialog(
        backgroundColor: theme.dialogTheme.backgroundColor,
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
    // Original Delete Account Confirmation Dialog
    final theme = Theme.of(context);
    final authService = Get.find<AuthService>();
    final user = authService.user;

    if (user == null) return;

    final isEmailUser = user.providerData.any(
      (info) => info.providerId == 'password',
    );

    Get.dialog(
      // ... (AlertDialog implementation)
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
    // Original Password Confirmation Dialog
    final theme = Theme.of(context);
    final passwordController = TextEditingController();
    final RxBool obscurePassword = true.obs;

    Get.dialog(
      // ... (AlertDialog implementation)
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
    // Original Final Delete Confirmation Dialog
    final theme = Theme.of(context);
    final authService = Get.find<AuthService>();

    Get.dialog(
      // ... (AlertDialog implementation)
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
                        ToastHelper.success('Account deleted successfully');
                      } catch (e) {
                        Get.back();
                        ToastHelper.error(e.toString());
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
        ToastHelper.error('Cannot launch URL');
      }
    } catch (err) {
      ToastHelper.error(err.toString());
    }
  }
}
// class SettingsPage extends StatelessWidget {
//   const SettingsPage({super.key});
//   User? get user => Get.find<AuthService>().user;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final settingsController = Get.find<SettingsController>();

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Settings',
//           style: theme.textTheme.titleMedium?.copyWith(
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//         elevation: 0,
//       ),
//       body: ListView(
//         padding: const EdgeInsets.symmetric(vertical: 8),
//         children: [
//           // Account Section
//           Obx(() => _buildUserProfile(user, theme)),

//           _buildDivider(theme),

//           // Appearance Section with Inline Toggle
//           _buildAppearanceSection(context, theme, settingsController),

//           _buildDivider(theme),

//           // Admin Section (only for admins)
//           FutureBuilder<bool>(
//             future: AdminUtils.isAdmin(),
//             builder: (context, snapshot) {
//               if (snapshot.hasData && snapshot.data == true) {
//                 return Column(
//                   children: [
//                     _buildSettingsTile(
//                       icon: Icons.admin_panel_settings_outlined,
//                       title: 'Manage Projects',
//                       subtitle: 'Admin only',
//                       theme: theme,
//                       onTap: () =>
//                           Get.toNamed(AppRoutes.adminProjectManagement),
//                     ),
//                     _buildDivider(theme),
//                   ],
//                 );
//               }
//               return const SizedBox.shrink();
//             },
//           ),

//           // About & Support Section
//           _buildAboutSupportSection(context, theme),

//           _buildDivider(theme),

//           // Terms of Service
//           _buildSettingsTile(
//             icon: Icons.description_outlined,
//             title: 'Terms of Service',
//             theme: theme,
//             onTap: () => _launchUrl(kTermsOfServiceUrl),
//           ),

//           _buildDivider(theme),

//           // Authentication Options
//           Obx(
//             () => user == null
//                 ? _buildSettingsTile(
//                     icon: Icons.login_outlined,
//                     title: 'Login',
//                     titleColor: theme.colorScheme.error,
//                     theme: theme,
//                     onTap: () async {
//                       await Get.toNamed(AppRoutes.auth);
//                     },
//                   )
//                 : Column(
//                     children: [
//                       _buildSettingsTile(
//                         icon: Icons.logout_outlined,
//                         title: 'Sign Out',
//                         titleColor: theme.colorScheme.error,
//                         theme: theme,
//                         onTap: _showSignOutConfirmation,
//                       ),
//                       _buildSettingsTile(
//                         icon: Icons.delete_outline,
//                         title: 'Delete Account',
//                         titleColor: Colors.red[700],
//                         theme: theme,
//                         onTap: () => _showDeleteAccountConfirmation(context),
//                       ),
//                     ],
//                   ),
//           ),

//           const SizedBox(height: 32),

//           const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16),
//             child: BannerAdWidget(),
//           ),

//           const SizedBox(height: 32),
//         ],
//       ),
//     );
//   }

//   Widget _buildUserProfile(User? user, ThemeData theme) {
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Row(
//         children: [
//           // Avatar
//           Container(
//             width: 56,
//             height: 56,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: theme.colorScheme.surfaceContainer,
//             ),
//             child: user?.photoURL != null
//                 ? ClipOval(
//                     child: Image.network(
//                       user!.photoURL!,
//                       fit: BoxFit.cover,
//                       width: 56,
//                       height: 56,
//                     ),
//                   )
//                 : Container(
//                     width: 56,
//                     height: 56,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: theme.colorScheme.surfaceContainer,
//                     ),
//                     child: ClipOval(
//                       child: Icon(
//                         Icons.person,
//                         size: 28,
//                         color: theme.disabledColor,
//                       ),
//                     ),
//                   ),
//           ),

//           const SizedBox(width: 16),

//           // User Info
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   user == null ? "Guest User" : user.displayName ?? "----",
//                   style: theme.textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   user?.email ?? 'Not signed in',
//                   style: theme.textTheme.bodyMedium?.copyWith(
//                     color: theme.hintColor,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSettingsTile({
//     required IconData icon,
//     required String title,
//     String? subtitle,
//     Color? titleColor,
//     required ThemeData theme,
//     VoidCallback? onTap,
//   }) {
//     return ListTile(
//       leading: Icon(icon, size: 22, color: titleColor ?? theme.iconTheme.color),
//       title: Text(
//         title,
//         style: theme.textTheme.bodyLarge?.copyWith(
//           fontWeight: FontWeight.w500,
//           color: titleColor ?? theme.textTheme.bodyLarge?.color,
//         ),
//       ),
//       subtitle: subtitle != null
//           ? Text(
//               subtitle,
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 color: theme.hintColor,
//               ),
//             )
//           : null,
//       trailing: titleColor == null
//           ? Icon(Icons.chevron_right, size: 22, color: theme.hintColor)
//           : null,
//       contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
//       onTap: onTap,
//     );
//   }

//   Widget _buildDivider(ThemeData theme) {
//     return Divider(
//       height: 1,
//       thickness: 0.5,
//       color: theme.dividerColor,
//       indent: 20,
//       endIndent: 20,
//     );
//   }

//   Widget _buildAppearanceSection(
//     BuildContext context,
//     ThemeData theme,
//     SettingsController controller,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.palette_outlined,
//                 size: 22,
//                 color: theme.iconTheme.color,
//               ),
//               const SizedBox(width: 16),
//               Text(
//                 'Appearance',
//                 style: theme.textTheme.bodyLarge?.copyWith(
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Obx(() => _buildThemeToggle(context, theme, controller)),
//         ],
//       ),
//     );
//   }

//   Widget _buildThemeToggle(
//     BuildContext context,
//     ThemeData theme,
//     SettingsController controller,
//   ) {
//     final currentMode = controller.themeMode.value;

//     return Container(
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surfaceContainerLow,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: _buildThemeOptionButton(
//               context: context,
//               theme: theme,
//               title: 'Light',
//               mode: ThemeMode.light,
//               isSelected: currentMode == ThemeMode.light,
//               isFirst: true,
//               isLast: false,
//               onTap: () => _handleThemeChange(controller, ThemeMode.light),
//             ),
//           ),
//           Expanded(
//             child: _buildThemeOptionButton(
//               context: context,
//               theme: theme,
//               title: 'Dark',
//               mode: ThemeMode.dark,
//               isSelected: currentMode == ThemeMode.dark,
//               isFirst: false,
//               isLast: false,
//               onTap: () => _handleThemeChange(controller, ThemeMode.dark),
//             ),
//           ),
//           Expanded(
//             child: _buildThemeOptionButton(
//               context: context,
//               theme: theme,
//               title: 'System',
//               mode: ThemeMode.system,
//               isSelected: currentMode == ThemeMode.system,
//               isFirst: false,
//               isLast: true,
//               onTap: () => _handleThemeChange(controller, ThemeMode.system),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildThemeOptionButton({
//     required BuildContext context,
//     required ThemeData theme,
//     required String title,
//     required ThemeMode mode,
//     required bool isSelected,
//     required bool isFirst,
//     required bool isLast,
//     required VoidCallback onTap,
//   }) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(isFirst ? 8 : 0),
//           bottomLeft: Radius.circular(isFirst ? 8 : 0),
//           topRight: Radius.circular(isLast ? 8 : 0),
//           bottomRight: Radius.circular(isLast ? 8 : 0),
//         ),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           curve: Curves.easeInOut,
//           padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
//           decoration: BoxDecoration(
//             color: isSelected
//                 ? theme.colorScheme.surfaceContainer
//                 : Colors.transparent,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(isFirst ? 8 : 0),
//               bottomLeft: Radius.circular(isFirst ? 8 : 0),
//               topRight: Radius.circular(isLast ? 8 : 0),
//               bottomRight: Radius.circular(isLast ? 8 : 0),
//             ),
//           ),
//           child: Center(
//             child: Text(
//               title,
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 fontSize: 14,
//                 fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
//                 color: isSelected
//                     ? theme.colorScheme.onSurface
//                     : theme.colorScheme.onSurfaceVariant,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _handleThemeChange(SettingsController controller, ThemeMode mode) {
//     // Smooth transition with haptic feedback
//     controller.setThemeMode(mode);
//   }

//   Widget _buildAboutSupportSection(BuildContext context, ThemeData theme) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.info_outline, size: 22, color: theme.iconTheme.color),
//               const SizedBox(width: 16),
//               Text(
//                 'About & Support',
//                 style: theme.textTheme.bodyLarge?.copyWith(
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           // App Version
//           _buildInfoTile(
//             icon: Icons.info_outline,
//             title: 'App Version',
//             value: RemoteConfigService().config.update.currentVersion,
//             theme: theme,
//           ),
//           // Send Feedback
//           _buildSettingsTile(
//             icon: Icons.feedback_outlined,
//             title: 'Send Feedback',
//             theme: theme,
//             onTap: () => _handleSendFeedback(context, theme),
//           ),
//           // Rate Us
//           _buildSettingsTile(
//             icon: Icons.star_outline,
//             title: 'Rate Us',
//             theme: theme,
//             onTap: () => _handleRateUs(),
//           ),
//           // Privacy Policy
//           _buildSettingsTile(
//             icon: Icons.security_outlined,
//             title: 'Privacy Policy',
//             theme: theme,
//             onTap: () => _launchUrl(kPrivacyPolicyUrl),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoTile({
//     required IconData icon,
//     required String title,
//     required String value,
//     required ThemeData theme,
//   }) {
//     return ListTile(
//       leading: Icon(icon, size: 22, color: theme.iconTheme.color),
//       title: Text(
//         title,
//         style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
//       ),
//       trailing: Text(
//         value,
//         style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
//       ),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
//     );
//   }

//   void _handleSendFeedback(BuildContext context, ThemeData theme) {
//     final email = kContactEmail.isNotEmpty
//         ? kContactEmail
//         : 'support@inkkaro.com'; // Fallback email if not set

//     final subject = Uri.encodeComponent('CardMaker App Feedback');
//     final body = Uri.encodeComponent(
//       'Hi,\n\nI would like to share the following feedback:\n\n',
//     );

//     final mailtoUrl = 'mailto:$email?subject=$subject&body=$body';

//     _launchUrl(mailtoUrl);
//   }

//   void _handleRateUs() {
//     final storeUrl = (GetPlatform.isIOS && kAppstoreUrl.isNotEmpty)
//         ? kAppstoreUrl
//         : kPlaystoreUrl;

//     if (storeUrl.isNotEmpty) {
//       _launchUrl(storeUrl);
//     } else {
//       ToastHelper.error('Store URL not configured');
//     }
//   }

//   void _showSignOutConfirmation() {
//     final theme = Theme.of(Get.context!);

//     Get.dialog(
//       AlertDialog(
//         backgroundColor: theme.dialogTheme.backgroundColor,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         title: Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w600)),
//         content: Text(
//           'Are you sure you want to sign out?',
//           style: theme.textTheme.bodyMedium,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: Text(
//               'Cancel',
//               style: theme.textTheme.bodyLarge?.copyWith(
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           TextButton(
//             onPressed: () async {
//               Get.back();
//               await FirebaseAuth.instance.signOut();
//               Get.back();

//               if (Get.isRegistered<ProfileController>()) {
//                 Get.find<ProfileController>().drafts.clear();
//               }
//             },
//             child: Text(
//               'Sign Out',
//               style: theme.textTheme.bodyLarge?.copyWith(
//                 color: theme.colorScheme.error,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showDeleteAccountConfirmation(BuildContext context) {
//     final theme = Theme.of(context);
//     final authService = Get.find<AuthService>();
//     final user = authService.user;

//     if (user == null) return;

//     final isEmailUser = user.providerData.any(
//       (info) => info.providerId == 'password',
//     );

//     Get.dialog(
//       AlertDialog(
//         backgroundColor: theme.dialogBackgroundColor,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         title: Row(
//           children: [
//             Icon(Icons.warning_amber_rounded, color: Colors.red[700], size: 28),
//             const SizedBox(width: 12),
//             Text(
//               'Delete Account',
//               style: theme.textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.w600,
//                 color: Colors.red[700],
//               ),
//             ),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'This action cannot be undone. All your data including:',
//               style: theme.textTheme.bodyMedium,
//             ),
//             const SizedBox(height: 12),
//             _buildDeleteWarningItem('• All your saved drafts', theme),
//             _buildDeleteWarningItem('• Your favorites', theme),
//             _buildDeleteWarningItem('• Your account information', theme),
//             const SizedBox(height: 12),
//             Text(
//               'will be permanently deleted.',
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: Text(
//               'Cancel',
//               style: theme.textTheme.bodyLarge?.copyWith(
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           TextButton(
//             onPressed: () {
//               Get.back();
//               if (isEmailUser) {
//                 _showPasswordConfirmation(context);
//               } else {
//                 _showFinalDeleteConfirmation(context);
//               }
//             },
//             child: Text(
//               'Continue',
//               style: theme.textTheme.bodyLarge?.copyWith(
//                 color: Colors.red[700],
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDeleteWarningItem(String text, ThemeData theme) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2),
//       child: Text(
//         text,
//         style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
//       ),
//     );
//   }

//   void _showPasswordConfirmation(BuildContext context) {
//     final theme = Theme.of(context);
//     final passwordController = TextEditingController();
//     final RxBool obscurePassword = true.obs;

//     Get.dialog(
//       AlertDialog(
//         backgroundColor: theme.dialogBackgroundColor,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         title: Text(
//           'Confirm Password',
//           style: theme.textTheme.titleLarge?.copyWith(
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               'Please enter your password to continue',
//               style: theme.textTheme.bodyMedium,
//             ),
//             const SizedBox(height: 16),
//             Obx(
//               () => TextField(
//                 controller: passwordController,
//                 obscureText: obscurePassword.value,
//                 decoration: InputDecoration(
//                   labelText: 'Password',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       obscurePassword.value
//                           ? Icons.visibility_outlined
//                           : Icons.visibility_off_outlined,
//                     ),
//                     onPressed: () => obscurePassword.toggle(),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               passwordController.dispose();
//               Get.back();
//             },
//             child: Text(
//               'Cancel',
//               style: theme.textTheme.bodyLarge?.copyWith(
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           TextButton(
//             onPressed: () {
//               final password = passwordController.text;
//               passwordController.dispose();
//               Get.back();
//               _showFinalDeleteConfirmation(context, password: password);
//             },
//             child: Text(
//               'Continue',
//               style: theme.textTheme.bodyLarge?.copyWith(
//                 color: Colors.red[700],
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showFinalDeleteConfirmation(BuildContext context, {String? password}) {
//     final theme = Theme.of(context);
//     final authService = Get.find<AuthService>();

//     Get.dialog(
//       AlertDialog(
//         backgroundColor: theme.dialogBackgroundColor,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         title: Text(
//           'Final Confirmation',
//           style: theme.textTheme.titleLarge?.copyWith(
//             fontWeight: FontWeight.w600,
//             color: Colors.red[700],
//           ),
//         ),
//         content: Text(
//           'Are you absolutely sure you want to delete your account? This action is permanent and irreversible.',
//           style: theme.textTheme.bodyMedium,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: Text(
//               'Cancel',
//               style: theme.textTheme.bodyLarge?.copyWith(
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           Obx(
//             () => authService.isLoading.value
//                 ? const Padding(
//                     padding: EdgeInsets.all(8.0),
//                     child: SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(strokeWidth: 2),
//                     ),
//                   )
//                 : TextButton(
//                     onPressed: () async {
//                       try {
//                         await authService.deleteAccount(password: password);
//                         Get.back();
//                         Get.back();
//                         ToastHelper.success('Account deleted successfully');
//                       } catch (e) {
//                         Get.back();
//                         ToastHelper.error(e.toString());
//                       }
//                     },
//                     child: Text(
//                       'Delete Account',
//                       style: theme.textTheme.bodyLarge?.copyWith(
//                         color: Colors.red[700],
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _launchUrl(String url) async {
//     try {
//       if (await canLaunchUrl(Uri.parse(url))) {
//         await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
//       } else {
//         ToastHelper.error('Cannot launch URL');
//       }
//     } catch (err) {
//       ToastHelper.error(err.toString());
//     }
//   }
// }
