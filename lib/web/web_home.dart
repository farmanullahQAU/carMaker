import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  // Replace with your actual app store URLs
  final String playStoreUrl =
      'https://play.google.com/store/apps/details?id=your.app.id';
  final String appStoreUrl = 'https://apps.apple.com/app/your-app-id';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not open the store'),
            backgroundColor: Colors.red.shade900,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Optimized Background
          const _OptimizedBackground(),

          // Main Content
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                pinned: true,
                elevation: 0,
                backgroundColor: _scrollOffset > 50
                    ? const Color(0xFF0F0F0F).withOpacity(0.95)
                    : Colors.transparent,
                flexibleSpace: ClipRRect(
                  child: BackdropFilter(
                    filter: _scrollOffset > 50
                        ? ColorFilter.mode(
                            Colors.white.withOpacity(0.1),
                            BlendMode.srcOver,
                          )
                        : const ColorFilter.mode(
                            Colors.transparent,
                            BlendMode.srcOver,
                          ),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _scrollOffset > 50
                                ? Colors.white.withOpacity(0.1)
                                : Colors.transparent,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                title: _buildNavBar(isMobile),
                toolbarHeight: 80,
              ),

              // Hero Section
              SliverToBoxAdapter(child: _buildHeroSection(isMobile, size)),

              // Features Section
              SliverToBoxAdapter(child: _buildFeaturesSection(isMobile)),

              // Stats Section
              SliverToBoxAdapter(child: _buildStatsSection(isMobile)),

              // Download Section
              SliverToBoxAdapter(child: _buildDownloadSection(isMobile)),

              // Footer
              SliverToBoxAdapter(child: _buildFooter(isMobile)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavBar(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.brush, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              const Text(
                'Inkkaro',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          if (!isMobile)
            Row(
              children: [
                _NavLink(text: 'Features', onTap: () {}),
                const SizedBox(width: 32),
                _NavLink(text: 'Pricing', onTap: () {}),
                const SizedBox(width: 32),
                _NavLink(text: 'Support', onTap: () {}),
                const SizedBox(width: 32),
                _PrimaryButton(
                  text: 'Download',
                  onPressed: () {},
                  compact: true,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(bool isMobile, Size size) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: isMobile ? 100 : 140,
      ),
      child: Column(
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6366F1),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Now Available on iOS & Android',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: isMobile ? 32 : 48),

          // Main Heading
          SizedBox(
            width: isMobile ? double.infinity : 900,
            child: Column(
              children: [
                Text(
                  'Professional Design',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 48 : 72,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.1,
                    letterSpacing: -2,
                  ),
                ),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFF6366F1),
                      Color(0xFF8B5CF6),
                      Color(0xFFEC4899),
                    ],
                  ).createShader(bounds),
                  child: Text(
                    'Made Simple',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isMobile ? 48 : 72,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.1,
                      letterSpacing: -2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: isMobile ? 24 : 32),

          // Subtitle
          SizedBox(
            width: isMobile ? double.infinity : 600,
            child: Text(
              'Create stunning graphics, illustrations, and designs with powerful yet intuitive tools. Everything you need in one professional app.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 17 : 20,
                color: Colors.white.withOpacity(0.7),
                height: 1.7,
                letterSpacing: -0.2,
              ),
            ),
          ),

          SizedBox(height: isMobile ? 40 : 56),

          // Store Buttons
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _StoreButton(
                icon: Icons.apple,
                title: 'Download on the',
                subtitle: 'App Store',
                onPressed: () => _launchURL(appStoreUrl),
              ),
              _StoreButton(
                icon: Icons.play_arrow_rounded,
                title: 'GET IT ON',
                subtitle: 'Google Play',
                onPressed: () => _launchURL(playStoreUrl),
              ),
            ],
          ),

          SizedBox(height: isMobile ? 60 : 100),

          // App Preview
          _buildAppPreview(isMobile, size),
        ],
      ),
    );
  }

  Widget _buildAppPreview(bool isMobile, Size size) {
    return Hero(
      tag: 'app_preview',
      child: Container(
        width: isMobile ? size.width - 48 : 1100,
        height: isMobile ? 500 : 700,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF6366F1).withOpacity(0.15),
              const Color(0xFF8B5CF6).withOpacity(0.15),
              const Color(0xFFEC4899).withOpacity(0.15),
            ],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.2),
              blurRadius: 60,
              spreadRadius: 0,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            children: [
              // Grid Pattern
              CustomPaint(
                size: Size(
                  isMobile ? size.width - 48 : 1100,
                  isMobile ? 500 : 700,
                ),
                painter: GridPainter(),
              ),

              // Center Icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.phone_iphone_rounded,
                    size: isMobile ? 80 : 120,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(bool isMobile) {
    final features = [
      _Feature(
        icon: Icons.palette_outlined,
        title: 'Advanced Color Tools',
        description:
            'Professional color picker with HSL, RGB, and HEX support. Create and save custom palettes.',
      ),
      _Feature(
        icon: Icons.layers_outlined,
        title: 'Layer System',
        description:
            'Organize complex designs with unlimited layers, groups, and blending modes.',
      ),
      _Feature(
        icon: Icons.gesture_outlined,
        title: 'Vector Drawing',
        description:
            'Create scalable vector graphics with bezier curves and advanced path tools.',
      ),
      _Feature(
        icon: Icons.auto_awesome_outlined,
        title: 'AI-Powered',
        description:
            'Smart suggestions, auto-trace, and intelligent background removal.',
      ),
      _Feature(
        icon: Icons.cloud_outlined,
        title: 'Cloud Sync',
        description:
            'Access your projects anywhere with automatic cloud synchronization.',
      ),
      _Feature(
        icon: Icons.file_download_outlined,
        title: 'Export Formats',
        description:
            'Export in PNG, JPG, SVG, PDF with customizable quality settings.',
      ),
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: isMobile ? 80 : 120,
      ),
      child: Column(
        children: [
          Text(
            'Everything You Need',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 36 : 56,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -1.5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: isMobile ? double.infinity : 600,
            child: Text(
              'Professional-grade tools designed for creators, by creators',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                color: Colors.white.withOpacity(0.6),
                height: 1.7,
              ),
            ),
          ),
          SizedBox(height: isMobile ? 48 : 72),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: features
                .map(
                  (f) => _FeatureCard(
                    feature: f,
                    width: isMobile ? double.infinity : 350,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(bool isMobile) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: isMobile ? 40 : 60,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 32 : 80,
        vertical: isMobile ? 48 : 80,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
      ),
      child: Wrap(
        spacing: isMobile ? 40 : 80,
        runSpacing: 40,
        alignment: WrapAlignment.center,
        children: [
          _StatItem(value: '500K+', label: 'Active Users', isMobile: isMobile),
          _StatItem(
            value: '10M+',
            label: 'Designs Created',
            isMobile: isMobile,
          ),
          _StatItem(
            value: '4.8★',
            label: 'App Store Rating',
            isMobile: isMobile,
          ),
          _StatItem(value: '150+', label: 'Countries', isMobile: isMobile),
        ],
      ),
    );
  }

  Widget _buildDownloadSection(bool isMobile) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: isMobile ? 40 : 60,
      ),
      padding: EdgeInsets.all(isMobile ? 48 : 80),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 40,
            spreadRadius: 0,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Start Creating Today',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 36 : 56,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Join thousands of creators worldwide',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 16 : 20,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          SizedBox(height: isMobile ? 32 : 48),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _StoreButton(
                icon: Icons.apple,
                title: 'Download on the',
                subtitle: 'App Store',
                onPressed: () => _launchURL(appStoreUrl),
                isDark: true,
              ),
              _StoreButton(
                icon: Icons.play_arrow_rounded,
                title: 'GET IT ON',
                subtitle: 'Google Play',
                onPressed: () => _launchURL(playStoreUrl),
                isDark: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 32 : 48),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
        ),
      ),
      child: Column(
        children: [
          if (!isMobile)
            Wrap(
              spacing: 48,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _FooterLink(text: 'Privacy Policy'),
                _FooterLink(text: 'Terms of Service'),
                _FooterLink(text: 'Support'),
                _FooterLink(text: 'Contact'),
              ],
            ),
          if (!isMobile) const SizedBox(height: 24),
          Text(
            '© 2024 Inkkaro. All rights reserved.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// Optimized Background Widget
class _OptimizedBackground extends StatelessWidget {
  const _OptimizedBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topRight,
          radius: 1.5,
          colors: [Color(0xFF1E1E2E), Color(0xFF0F0F0F)],
        ),
      ),
      child: CustomPaint(painter: BackgroundPainter(), size: Size.infinite),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.3, -0.5),
        radius: 0.8,
        colors: [const Color(0xFF6366F1).withOpacity(0.08), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;

    const spacing = 40.0;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Reusable Widgets
class _NavLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _NavLink({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool compact;

  const _PrimaryButton({
    required this.text,
    required this.onPressed,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F0F0F),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 24 : 32,
          vertical: compact ? 12 : 16,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        elevation: 0,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: compact ? 14 : 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StoreButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onPressed;
  final bool isDark;

  const _StoreButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onPressed,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.2)
                  : Colors.white.withOpacity(0.15),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: Colors.white),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Feature {
  final IconData icon;
  final String title;
  final String description;

  _Feature({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _FeatureCard extends StatelessWidget {
  final _Feature feature;
  final double width;

  const _FeatureCard({required this.feature, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width == double.infinity ? null : width,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(feature.icon, size: 24, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Text(
            feature.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            feature.description,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.6),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final bool isMobile;

  const _StatItem({
    required this.value,
    required this.label,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isMobile ? double.infinity : null,
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
            ).createShader(bounds),
            child: Text(
              value,
              style: TextStyle(
                fontSize: isMobile ? 40 : 56,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -1.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.white.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String text;

  const _FooterLink({required this.text});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

// class LandingPage extends StatefulWidget {
//   const LandingPage({super.key});

//   @override
//   State<LandingPage> createState() => _LandingPageState();
// }

// class _LandingPageState extends State<LandingPage>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;

//   // Replace these with your actual app store URLs
//   final String playStoreUrl =
//       'https://play.google.com/store/apps/details?id=your.app.id';
//   final String appStoreUrl = 'https://apps.apple.com/app/your-app-id';

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 1200),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.3),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

//     _controller.forward();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   Future<void> _launchURL(String url) async {
//     final Uri uri = Uri.parse(url);
//     if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Could not open the store')),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final isMobile = size.width < 768;

//     return Scaffold(
//       body: Stack(
//         children: [
//           // Animated Background Gradient
//           AnimatedBackground(),

//           // Content
//           SingleChildScrollView(
//             child: Column(
//               children: [
//                 // Navigation Bar
//                 _buildNavBar(isMobile),

//                 // Hero Section
//                 _buildHeroSection(isMobile),

//                 // Features Section
//                 _buildFeaturesSection(isMobile),

//                 // Download Section
//                 _buildDownloadSection(isMobile),

//                 // Footer
//                 _buildFooter(),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNavBar(bool isMobile) {
//     return Container(
//       padding: EdgeInsets.symmetric(
//         horizontal: isMobile ? 20 : 80,
//         vertical: 20,
//       ),
//       decoration: BoxDecoration(
//         color: Colors.black.withOpacity(0.3),
//         border: Border(
//           bottom: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           ShaderMask(
//             shaderCallback: (bounds) => const LinearGradient(
//               colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
//             ).createShader(bounds),
//             child: Text(
//               'Inkkaro',
//               style: TextStyle(
//                 fontSize: isMobile ? 24 : 32,
//                 fontWeight: FontWeight.w900,
//                 color: Colors.white,
//                 letterSpacing: -1,
//               ),
//             ),
//           ),
//           if (!isMobile)
//             Row(
//               children: [
//                 _NavLink(text: 'Features'),
//                 const SizedBox(width: 40),
//                 _NavLink(text: 'About'),
//                 const SizedBox(width: 40),
//                 _NavLink(text: 'Contact'),
//               ],
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeroSection(bool isMobile) {
//     return FadeTransition(
//       opacity: _fadeAnimation,
//       child: SlideTransition(
//         position: _slideAnimation,
//         child: Container(
//           padding: EdgeInsets.symmetric(
//             horizontal: isMobile ? 20 : 80,
//             vertical: isMobile ? 60 : 120,
//           ),
//           child: Column(
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 8,
//                 ),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       const Color(0xFF667EEA).withOpacity(0.2),
//                       const Color(0xFF764BA2).withOpacity(0.2),
//                     ],
//                   ),
//                   borderRadius: BorderRadius.circular(50),
//                   border: Border.all(
//                     color: const Color(0xFF667EEA).withOpacity(0.3),
//                   ),
//                 ),
//                 child: const Text(
//                   '🎨 Professional Design Tool',
//                   style: TextStyle(
//                     color: Colors.white70,
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 30),
//               Text(
//                 'Design Your Vision',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: isMobile ? 48 : 72,
//                   fontWeight: FontWeight.w900,
//                   height: 1.1,
//                   letterSpacing: -2,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               ShaderMask(
//                 shaderCallback: (bounds) => const LinearGradient(
//                   colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
//                 ).createShader(bounds),
//                 child: Text(
//                   'With Inkkaro',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: isMobile ? 48 : 72,
//                     fontWeight: FontWeight.w900,
//                     color: Colors.white,
//                     height: 1.1,
//                     letterSpacing: -2,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 30),
//               Text(
//                 'Create stunning designs, illustrations, and graphics with\nprofessional-grade tools right at your fingertips',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: isMobile ? 16 : 20,
//                   color: Colors.white60,
//                   height: 1.6,
//                 ),
//               ),
//               const SizedBox(height: 50),

//               // App Store Buttons
//               Wrap(
//                 spacing: 20,
//                 runSpacing: 20,
//                 alignment: WrapAlignment.center,
//                 children: [
//                   _StoreButton(
//                     icon: Icons.apple,
//                     title: 'Download on the',
//                     subtitle: 'App Store',
//                     onPressed: () => _launchURL(appStoreUrl),
//                   ),
//                   _StoreButton(
//                     icon: Icons.play_arrow,
//                     title: 'GET IT ON',
//                     subtitle: 'Google Play',
//                     onPressed: () => _launchURL(playStoreUrl),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 80),

//               // App Screenshot Mockup
//               _buildAppMockup(isMobile),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildAppMockup(bool isMobile) {
//     return Container(
//       width: isMobile ? double.infinity : 900,
//       height: isMobile ? 400 : 600,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(30),
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             const Color(0xFF667EEA).withOpacity(0.3),
//             const Color(0xFF764BA2).withOpacity(0.3),
//           ],
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF667EEA).withOpacity(0.3),
//             blurRadius: 60,
//             spreadRadius: 10,
//           ),
//         ],
//       ),
//       child: Center(
//         child: Icon(
//           Icons.phone_android,
//           size: isMobile ? 120 : 200,
//           color: Colors.white24,
//         ),
//       ),
//     );
//   }

//   Widget _buildFeaturesSection(bool isMobile) {
//     return Container(
//       padding: EdgeInsets.symmetric(
//         horizontal: isMobile ? 20 : 80,
//         vertical: isMobile ? 60 : 100,
//       ),
//       child: Column(
//         children: [
//           Text(
//             'Powerful Features',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: isMobile ? 36 : 48,
//               fontWeight: FontWeight.w900,
//             ),
//           ),
//           const SizedBox(height: 60),
//           Wrap(
//             spacing: 30,
//             runSpacing: 30,
//             alignment: WrapAlignment.center,
//             children: [
//               _FeatureCard(
//                 icon: Icons.brush,
//                 title: 'Professional Tools',
//                 description:
//                     'Access industry-standard design tools for creating stunning visuals',
//                 isMobile: isMobile,
//               ),
//               _FeatureCard(
//                 icon: Icons.layers,
//                 title: 'Layer Management',
//                 description:
//                     'Organize your designs with advanced layer controls and blending modes',
//                 isMobile: isMobile,
//               ),
//               _FeatureCard(
//                 icon: Icons.palette,
//                 title: 'Color Studio',
//                 description:
//                     'Explore millions of colors with advanced color picking and palettes',
//                 isMobile: isMobile,
//               ),
//               _FeatureCard(
//                 icon: Icons.cloud_upload,
//                 title: 'Cloud Sync',
//                 description:
//                     'Seamlessly sync your work across all your devices',
//                 isMobile: isMobile,
//               ),
//               _FeatureCard(
//                 icon: Icons.share,
//                 title: 'Easy Export',
//                 description:
//                     'Export in multiple formats including PNG, SVG, and PDF',
//                 isMobile: isMobile,
//               ),
//               _FeatureCard(
//                 icon: Icons.auto_awesome,
//                 title: 'AI Assistance',
//                 description: 'Get smart suggestions and automated enhancements',
//                 isMobile: isMobile,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDownloadSection(bool isMobile) {
//     return Container(
//       margin: EdgeInsets.symmetric(
//         horizontal: isMobile ? 20 : 80,
//         vertical: isMobile ? 40 : 60,
//       ),
//       padding: EdgeInsets.all(isMobile ? 40 : 80),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
//         ),
//         borderRadius: BorderRadius.circular(30),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF667EEA).withOpacity(0.4),
//             blurRadius: 40,
//             spreadRadius: 5,
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Text(
//             'Ready to Start Designing?',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: isMobile ? 32 : 48,
//               fontWeight: FontWeight.w900,
//             ),
//           ),
//           const SizedBox(height: 20),
//           Text(
//             'Download Inkkaro now and unleash your creativity',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: isMobile ? 16 : 20,
//               color: Colors.white70,
//             ),
//           ),
//           const SizedBox(height: 40),
//           Wrap(
//             spacing: 20,
//             runSpacing: 20,
//             alignment: WrapAlignment.center,
//             children: [
//               _StoreButton(
//                 icon: Icons.apple,
//                 title: 'Download on the',
//                 subtitle: 'App Store',
//                 onPressed: () => _launchURL(appStoreUrl),
//                 isDark: true,
//               ),
//               _StoreButton(
//                 icon: Icons.play_arrow,
//                 title: 'GET IT ON',
//                 subtitle: 'Google Play',
//                 onPressed: () => _launchURL(playStoreUrl),
//                 isDark: true,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFooter() {
//     return Container(
//       padding: const EdgeInsets.all(40),
//       decoration: BoxDecoration(
//         border: Border(
//           top: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
//         ),
//       ),
//       child: Column(
//         children: [
//           Text(
//             '© 2024 Inkkaro. All rights reserved.',
//             style: TextStyle(
//               color: Colors.white.withOpacity(0.4),
//               fontSize: 14,
//             ),
//           ),
//           const SizedBox(height: 10),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               TextButton(onPressed: () {}, child: const Text('Privacy Policy')),
//               const Text('•', style: TextStyle(color: Colors.white24)),
//               TextButton(
//                 onPressed: () {},
//                 child: const Text('Terms of Service'),
//               ),
//               const Text('•', style: TextStyle(color: Colors.white24)),
//               TextButton(onPressed: () {}, child: const Text('Contact Us')),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _NavLink extends StatefulWidget {
//   final String text;

//   const _NavLink({required this.text});

//   @override
//   State<_NavLink> createState() => _NavLinkState();
// }

// class _NavLinkState extends State<_NavLink> {
//   bool isHovered = false;

//   @override
//   Widget build(BuildContext context) {
//     return MouseRegion(
//       onEnter: (_) => setState(() => isHovered = true),
//       onExit: (_) => setState(() => isHovered = false),
//       child: AnimatedDefaultTextStyle(
//         duration: const Duration(milliseconds: 200),
//         style: TextStyle(
//           color: isHovered ? Colors.white : Colors.white60,
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//         ),
//         child: Text(widget.text),
//       ),
//     );
//   }
// }

// class _StoreButton extends StatefulWidget {
//   final IconData icon;
//   final String title;
//   final String subtitle;
//   final VoidCallback onPressed;
//   final bool isDark;

//   const _StoreButton({
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//     required this.onPressed,
//     this.isDark = false,
//   });

//   @override
//   State<_StoreButton> createState() => _StoreButtonState();
// }

// class _StoreButtonState extends State<_StoreButton> {
//   bool isHovered = false;

//   @override
//   Widget build(BuildContext context) {
//     return MouseRegion(
//       onEnter: (_) => setState(() => isHovered = true),
//       onExit: (_) => setState(() => isHovered = false),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         transform: Matrix4.identity()..scale(isHovered ? 1.05 : 1.0),
//         child: Material(
//           color: Colors.transparent,
//           child: InkWell(
//             onTap: widget.onPressed,
//             borderRadius: BorderRadius.circular(15),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//               decoration: BoxDecoration(
//                 color: widget.isDark
//                     ? Colors.black
//                     : Colors.white.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(15),
//                 border: Border.all(
//                   color: widget.isDark
//                       ? Colors.white.withOpacity(0.2)
//                       : Colors.white.withOpacity(0.1),
//                   width: 1,
//                 ),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(widget.icon, size: 35, color: Colors.white),
//                   const SizedBox(width: 12),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         widget.title,
//                         style: const TextStyle(
//                           fontSize: 10,
//                           color: Colors.white70,
//                           fontWeight: FontWeight.w400,
//                         ),
//                       ),
//                       Text(
//                         widget.subtitle,
//                         style: const TextStyle(
//                           fontSize: 18,
//                           color: Colors.white,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _FeatureCard extends StatefulWidget {
//   final IconData icon;
//   final String title;
//   final String description;
//   final bool isMobile;

//   const _FeatureCard({
//     required this.icon,
//     required this.title,
//     required this.description,
//     required this.isMobile,
//   });

//   @override
//   State<_FeatureCard> createState() => _FeatureCardState();
// }

// class _FeatureCardState extends State<_FeatureCard> {
//   bool isHovered = false;

//   @override
//   Widget build(BuildContext context) {
//     return MouseRegion(
//       onEnter: (_) => setState(() => isHovered = true),
//       onExit: (_) => setState(() => isHovered = false),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         width: widget.isMobile ? double.infinity : 350,
//         padding: const EdgeInsets.all(35),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(isHovered ? 0.08 : 0.05),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: Colors.white.withOpacity(isHovered ? 0.2 : 0.1),
//             width: 1,
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(15),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
//                 ),
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               child: Icon(widget.icon, size: 30, color: Colors.white),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               widget.title,
//               style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               widget.description,
//               style: TextStyle(
//                 fontSize: 15,
//                 color: Colors.white.withOpacity(0.6),
//                 height: 1.6,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class AnimatedBackground extends StatefulWidget {
//   const AnimatedBackground({super.key});

//   @override
//   State<AnimatedBackground> createState() => _AnimatedBackgroundState();
// }

// class _AnimatedBackgroundState extends State<AnimatedBackground>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(seconds: 10),
//       vsync: this,
//     )..repeat();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _controller,
//       builder: (context, child) {
//         return Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 const Color(0xFF0A0A0A),
//                 Color.lerp(
//                   const Color(0xFF667EEA).withOpacity(0.1),
//                   const Color(0xFF764BA2).withOpacity(0.1),
//                   _controller.value,
//                 )!,
//                 const Color(0xFF0A0A0A),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
