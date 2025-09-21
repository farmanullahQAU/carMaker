import 'package:cardmaker/app/features/profile/controller.dart';
import 'package:cardmaker/services/auth_service.dart';
import 'package:cardmaker/services/update_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  User? get user => Get.find<AuthService>().user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Account Section
          _buildUserProfile(user, theme),
          _buildDivider(theme),

          // Settings Options
          _buildSettingsTile(
            icon: Icons.palette_outlined,
            title: 'Appearance',
            theme: theme,
            onTap: () => _showAppearanceSheet(context, theme),
          ),

          _buildSettingsTile(
            icon: Icons.language_outlined,
            title: 'Language',
            subtitle: 'English',
            theme: theme,
            onTap: () => _showLanguageSheet(context, theme),
          ),

          _buildDivider(theme),

          _buildSettingsTile(
            icon: Icons.share_outlined,
            title: 'Share App',
            theme: theme,
            onTap: _shareApp,
          ),

          _buildSettingsTile(
            icon: Icons.star_outline,
            title: 'Rate App',
            theme: theme,
            onTap: _launchAppStore,
          ),

          _buildDivider(theme),

          _buildSettingsTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            theme: theme,
            onTap: () => Get.toNamed('/terms'),
          ),

          _buildSettingsTile(
            icon: Icons.security_outlined,
            title: 'Privacy Policy',
            theme: theme,
            onTap: () => Get.toNamed('/privacy'),
          ),

          _buildDivider(theme),

          Obx(
            () => user == null
                ? const SizedBox()
                : _buildSettingsTile(
                    icon: Icons.logout_outlined,
                    title: 'Sign Out',
                    titleColor: theme.colorScheme.error,
                    theme: theme,
                    onTap: _showSignOutConfirmation,
                  ),
          ),

          const SizedBox(height: 32),

          // Version
          Center(
            child: Text(
              'Version ${UpdateManager().currVer}',
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
              color: theme.cardColor,
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
                : Icon(Icons.person, size: 28, color: theme.disabledColor),
          ),

          const SizedBox(width: 16),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'Guest User',
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

  void _showAppearanceSheet(BuildContext context, ThemeData theme) {
    final RxString selectedTheme = 'System'.obs;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.dialogBackgroundColor,
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
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            Obx(
              () => Column(
                children: [
                  _buildThemeOption('Light', selectedTheme, theme),
                  _buildThemeOption('Dark', selectedTheme, theme),
                  _buildThemeOption('System', selectedTheme, theme),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    String themeOption,
    RxString selectedTheme,
    ThemeData theme,
  ) {
    return ListTile(
      title: Text(
        themeOption,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      trailing: selectedTheme.value == themeOption
          ? Icon(Icons.check, color: theme.primaryColor, size: 20)
          : null,
      onTap: () {
        selectedTheme.value = themeOption;
        Get.back();
        // Implement theme change logic
      },
    );
  }

  void _showLanguageSheet(BuildContext context, ThemeData theme) {
    final languages = ['English', 'Spanish', 'French', 'German'];
    final RxString selectedLanguage = 'English'.obs;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.dialogBackgroundColor,
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
              'Language',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            ...languages.map(
              (language) => ListTile(
                title: Text(
                  language,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: selectedLanguage.value == language
                    ? Icon(Icons.check, color: theme.primaryColor, size: 20)
                    : null,
                onTap: () {
                  selectedLanguage.value = language;
                  Get.back();
                  // Implement language change logic
                },
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showSignOutConfirmation() {
    final theme = Theme.of(Get.context!);

    Get.dialog(
      AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Sign Out',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
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

  void _launchAppStore() async {
    const url =
        'https://play.google.com/store/apps/details?id=com.example.inkkaro';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _shareApp() {
    Share.share(
      'Check out Inkkaro - Create stunning cards and invitations! https://play.google.com/store/apps/details?id=com.example.inkkaro',
    );
  }
}
