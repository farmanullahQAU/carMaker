import 'package:cardmaker/core/values/app_colors.dart';
import 'package:cardmaker/services/auth_service.dart';
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 17,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Account Section
          _buildUserProfile(user),
          _buildDivider(),

          // Settings Options
          _buildSettingsTile(
            icon: Icons.person_outline,
            title: 'Account',
            onTap: () => Get.toNamed('/account'),
          ),

          _buildSettingsTile(
            icon: Icons.palette_outlined,
            title: 'Appearance',
            onTap: () => _showAppearanceSheet(context),
          ),

          _buildSettingsTile(
            icon: Icons.language_outlined,
            title: 'Language',
            subtitle: 'English',
            onTap: () => _showLanguageSheet(context),
          ),

          _buildDivider(),

          _buildSettingsTile(
            icon: Icons.share_outlined,
            title: 'Share App',
            onTap: _shareApp,
          ),

          _buildSettingsTile(
            icon: Icons.star_outline,
            title: 'Rate App',
            onTap: _launchAppStore,
          ),

          _buildDivider(),

          _buildSettingsTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () => Get.toNamed('/terms'),
          ),

          _buildSettingsTile(
            icon: Icons.security_outlined,
            title: 'Privacy Policy',
            onTap: () => Get.toNamed('/privacy'),
          ),

          _buildDivider(),

          _buildSettingsTile(
            icon: Icons.logout_outlined,
            title: 'Sign Out',
            titleColor: Colors.red.shade600,
            onTap: _showSignOutConfirmation,
          ),

          const SizedBox(height: 32),

          // Version
          Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildUserProfile(User? user) {
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
              color: Colors.grey.shade100,
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
                : Icon(Icons.person, size: 28, color: Colors.grey.shade600),
          ),

          const SizedBox(width: 16),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'Guest User',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.email ?? 'Not signed in',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w400,
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
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 22, color: titleColor ?? Colors.grey.shade700),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: titleColor ?? Colors.black,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            )
          : null,
      trailing: titleColor == null
          ? Icon(Icons.chevron_right, size: 18, color: Colors.grey.shade400)
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: Colors.grey.shade200,
      indent: 20,
      endIndent: 20,
    );
  }

  void _showAppearanceSheet(BuildContext context) {
    final RxString selectedTheme = 'System'.obs;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Appearance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),

            Obx(
              () => Column(
                children: [
                  _buildThemeOption('Light', selectedTheme),
                  _buildThemeOption('Dark', selectedTheme),
                  _buildThemeOption('System', selectedTheme),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(String theme, RxString selectedTheme) {
    return ListTile(
      title: Text(
        theme,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: selectedTheme.value == theme
          ? Icon(Icons.check, color: AppColors.branding, size: 20)
          : null,
      onTap: () {
        selectedTheme.value = theme;
        Get.back();
        // Implement theme change logic
      },
    );
  }

  void _showLanguageSheet(BuildContext context) {
    final languages = ['English', 'Spanish', 'French', 'German'];
    final RxString selectedLanguage = 'English'.obs;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Language',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),

            ...languages.map(
              (language) => ListTile(
                title: Text(
                  language,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: selectedLanguage.value == language
                    ? Icon(Icons.check, color: AppColors.branding, size: 20)
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
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Sign Out',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(fontSize: 15, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await FirebaseAuth.instance.signOut();
              Get.back();
            },
            child: Text(
              'Sign Out',
              style: TextStyle(
                color: Colors.red.shade600,
                fontWeight: FontWeight.w600,
                fontSize: 15,
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
