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

  // Section keys for smooth scrolling
  final GlobalKey _heroKey = GlobalKey();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _comingSoonKey = GlobalKey();
  final GlobalKey _downloadKey = GlobalKey();

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

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
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
              SliverToBoxAdapter(
                key: _heroKey,
                child: _buildHeroSection(isMobile, size),
              ),

              // Features Section
              SliverToBoxAdapter(
                key: _featuresKey,
                child: _buildFeaturesSection(isMobile),
              ),

              // Coming Soon Section
              SliverToBoxAdapter(
                key: _comingSoonKey,
                child: _buildComingSoonSection(isMobile),
              ),

              // Download Section
              SliverToBoxAdapter(
                key: _downloadKey,
                child: _buildDownloadSection(isMobile),
              ),

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
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40),
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
                _NavLink(
                  text: 'Features',
                  onTap: () => _scrollToSection(_featuresKey),
                ),
                const SizedBox(width: 32),
                _NavLink(
                  text: 'Coming Soon',
                  onTap: () => _scrollToSection(_comingSoonKey),
                ),
                const SizedBox(width: 32),
                _NavLink(
                  text: 'Download',
                  onTap: () => _scrollToSection(_downloadKey),
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
                  'Available on iOS & Android',
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
              'Create stunning graphics, illustrations, and designs with powerful yet intuitive tools. Works offline, syncs when you login.',
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
              CustomPaint(
                size: Size(
                  isMobile ? size.width - 48 : 1100,
                  isMobile ? 500 : 700,
                ),
                painter: GridPainter(),
              ),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.palette_outlined,
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
        icon: Icons.flash_on_outlined,
        title: 'Lightning Fast',
        description:
            'Optimized rendering engine for smooth performance. Create without lag or delays.',
      ),
      _Feature(
        icon: Icons.gesture_outlined,
        title: 'Vector Drawing',
        description:
            'Create scalable vector graphics with bezier curves and advanced path tools.',
      ),
      _Feature(
        icon: Icons.cloud_download_outlined,
        title: 'Offline First',
        description:
            'Create beautiful designs without internet. Sync your work when you login.',
      ),
      _Feature(
        icon: Icons.file_download_outlined,
        title: 'Multiple Export Formats',
        description:
            'Export as PNG, JPG, SVG, or PDF with customizable quality settings.',
      ),
      _Feature(
        icon: Icons.lock_outlined,
        title: 'Secure Sync',
        description:
            'Optional login to securely sync your projects across all your devices.',
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

  Widget _buildComingSoonSection(bool isMobile) {
    final comingSoon = [
      _ComingSoonFeature(
        icon: Icons.layers_outlined,
        title: 'Layer & Grouping System',
        description:
            'Organize complex designs with unlimited layers, groups, and blending modes.',
      ),
      _ComingSoonFeature(
        icon: Icons.auto_awesome_outlined,
        title: 'AI-Powered Design',
        description:
            'Smart suggestions, auto-trace, and intelligent design generation (offline capable).',
      ),
      _ComingSoonFeature(
        icon: Icons.edit_outlined,
        title: 'Editable AI Designs',
        description:
            'Generate designs with AI and fully edit them to match your vision.',
      ),
    ];

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: isMobile ? 40 : 60,
      ),
      padding: EdgeInsets.all(isMobile ? 32 : 60),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Color(0xFF8B5CF6).withOpacity(0.2),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: Color(0xFF8B5CF6).withOpacity(0.5),
                width: 1,
              ),
            ),
            child: const Text(
              'Coming Soon',
              style: TextStyle(
                color: Color(0xFFC4B5FD),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          SizedBox(height: isMobile ? 24 : 32),
          Text(
            'Powerful Features on the Horizon',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 32 : 48,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 24),
          SizedBox(
            width: isMobile ? double.infinity : 600,
            child: Text(
              'We\'re actively developing advanced features to make designing even more powerful and creative.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                color: Colors.white.withOpacity(0.6),
                height: 1.6,
              ),
            ),
          ),
          SizedBox(height: isMobile ? 48 : 64),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: comingSoon
                .map(
                  (f) => _ComingSoonCard(
                    feature: f,
                    width: isMobile ? double.infinity : 300,
                  ),
                )
                .toList(),
          ),
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
            'Download Inkkaro and unlock your creative potential',
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

// Optimized Background
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

class _ComingSoonFeature {
  final IconData icon;
  final String title;
  final String description;

  _ComingSoonFeature({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _ComingSoonCard extends StatelessWidget {
  final _ComingSoonFeature feature;
  final double width;

  const _ComingSoonCard({required this.feature, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width == double.infinity ? null : width,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Color(0xFF8B5CF6).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFF8B5CF6).withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(feature.icon, size: 20, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            feature.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            feature.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
              height: 1.5,
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


/*
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
*/