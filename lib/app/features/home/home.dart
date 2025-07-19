import 'package:cardmaker/app/features/editor/editor_canvas.dart';
import 'package:cardmaker/app/features/home/controller.dart';
import 'package:cardmaker/models/card_template.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// --- ENHANCED DATA MODELS ---
class CategoryModel {
  final String id;
  final String name;
  final Color color;
  final IconData icon;
  final String? imagePath;

  CategoryModel({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    this.imagePath,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'color': color.value,
    'icon': icon.codePoint,
    'imagePath': imagePath,
  };

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    id: json['id'],
    name: json['name'],
    color: Color(json['color']),
    icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
    imagePath: json['imagePath'],
  );
}

class QuickAction {
  final String title;
  final IconData icon;
  final Color color;

  QuickAction({required this.title, required this.icon, required this.color});

  Map<String, dynamic> toJson() => {
    'title': title,
    'icon': icon.codePoint,
    'color': color.value,
  };

  factory QuickAction.fromJson(Map<String, dynamic> json) => QuickAction(
    title: json['title'],
    icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
    color: Color(json['color']),
  );
}

// --- Main Home Page Widget ---
class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());

    return Scaffold(
      backgroundColor: Get.theme.colorScheme.surface,
      body: PageView(
        controller: controller.pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: controller.onPageChanged,
        children: const [
          HomeTab(),
          EditorPage(),
          PlaceholderPage(title: "My Designs", icon: Icons.palette_outlined),
          PlaceholderPage(
            title: "Premium",
            icon: Icons.workspace_premium_outlined,
          ),
        ],
      ),
      bottomNavigationBar: Obx(() => _buildModernBottomNav()),
    );
  }

  Widget _buildModernBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Get.theme.colorScheme.shadow.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: NavigationBar(
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: controller.onBottomNavTap,
          height: 68,
          backgroundColor: Colors.transparent,
          elevation: 0,
          indicatorColor: Get.theme.colorScheme.primaryContainer,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            _ModernNavDestination(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home_rounded,
              label: 'Home',
            ),
            _ModernNavDestination(
              icon: Icons.grid_view_outlined,
              selectedIcon: Icons.grid_view_rounded,
              label: 'Templates',
            ),
            _ModernNavDestination(
              icon: Icons.palette_outlined,
              selectedIcon: Icons.palette,
              label: 'My Designs',
            ),
            _ModernNavDestination(
              icon: Icons.workspace_premium_outlined,
              selectedIcon: Icons.workspace_premium,
              label: 'Premium',
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernNavDestination extends NavigationDestination {
  _ModernNavDestination({
    required IconData icon,
    required IconData selectedIcon,
    required super.label,
  }) : super(
         icon: Icon(icon, size: 22, color: Get.theme.colorScheme.outline),
         selectedIcon: Icon(
           selectedIcon,
           size: 22,
           color: Get.theme.colorScheme.primary,
         ),
       );
}

// --- The Main Scrollable Home Tab ---
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildModernAppBar(),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(width: 100, height: 200, color: Colors.red),

              const QuickActionsGrid(),
              const SizedBox(height: 20),
              const AIBanner(),
              const SizedBox(height: 20),
              const SectionTitle(title: 'Browse Categories', showSeeAll: true),
              const SizedBox(height: 12),
              const CategoriesList(),
              const SizedBox(height: 20),
              const SectionTitle(title: 'Featured Templates', showSeeAll: true),
              const SizedBox(height: 12),
              const HorizontalCardList(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  SliverAppBar _buildModernAppBar() {
    return SliverAppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Greetings, User!',
            style: Get.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Get.theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: IconButton(
            onPressed: () {},
            icon: Badge(
              backgroundColor: Get.theme.colorScheme.primary,
              child: Icon(
                Icons.notifications_none_rounded,
                color: Get.theme.colorScheme.onSurface,
                size: 24,
              ),
            ),
          ),
        ),
      ],
      pinned: false,
      floating: true,
      toolbarHeight: 84,
      backgroundColor: Get.theme.colorScheme.surface,
      elevation: 0,
    );
  }
}

// --- Modern UI Components ---
class SectionTitle extends StatelessWidget {
  final String title;
  final bool showSeeAll;

  const SectionTitle({super.key, required this.title, this.showSeeAll = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Get.theme.colorScheme.onSurface,
            ),
          ),
          if (showSeeAll)
            TextButton(
              onPressed: () {},
              child: Text(
                'See All',
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: Get.theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class QuickActionsGrid extends GetView<HomeController> {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemCount: controller.quickActions.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final action = controller.quickActions[index];
          return GestureDetector(
            onTap: () => controller.onQuickActionTap(action),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    color: action.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: action.color.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(action.icon, color: action.color, size: 30),
                ),
                const SizedBox(height: 8),
                Text(
                  action.title,
                  style: Get.textTheme.labelSmall?.copyWith(
                    color: Get.theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AIBanner extends StatelessWidget {
  const AIBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Get.theme.colorScheme.primary,
            Get.theme.colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Get.theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Design Studio',
                  style: Get.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Transform your ideas into stunning designs with AI.',
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: () => Get.find<HomeController>().onQuickActionTap(
                    QuickAction(
                      title: 'AI Generate',
                      icon: Icons.auto_awesome_outlined,
                      color: const Color(0xFF8B5CF6),
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Get.theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Try Now',
                    style: Get.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Icon(
            Icons.auto_awesome_rounded,
            size: 42,
            color: Colors.white.withOpacity(0.8),
          ),
        ],
      ),
    );
  }
}

class HorizontalCardList extends GetView<HomeController> {
  const HorizontalCardList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1748, // Reduced height for better visibility, adjust as needed
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double maxWidth = constraints.maxWidth; // Account for padding
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: controller.featuredTemplates.length,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemBuilder: (context, index) {
              final template = controller.featuredTemplates[index];

              // Calculate aspect ratio and card dimensions
              final double aspectRatio = template.width / template.height;
              final double targetWidth = (maxWidth * 0.35);
              final double targetHeight = targetWidth / aspectRatio;

              return GestureDetector(
                onTap: () => controller.onTemplateTap(template),
                child: Container(
                  width: targetWidth,
                  height: targetHeight,
                  margin: const EdgeInsets.only(right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: targetHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Get.theme.colorScheme.shadow.withOpacity(
                                0.1,
                              ),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                template.backgroundImage,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Get.theme.colorScheme.primaryContainer,
                                  child: Icon(
                                    Icons.image_outlined,
                                    color: Get
                                        .theme
                                        .colorScheme
                                        .onPrimaryContainer,
                                    size: 32,
                                  ),
                                ),
                              ),
                              ..._buildTemplateItems(
                                template,
                                targetHeight,
                                targetWidth,
                                context,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: targetWidth,
                        child: Text(
                          template.name,
                          style: Get.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Get.theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 2),
                      SizedBox(
                        width: targetWidth,
                        child: Text(
                          template.category,
                          style: Get.textTheme.bodySmall?.copyWith(
                            color: Get.theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<Widget> _buildTemplateItems(
    CardTemplate template,
    double targetHeight,
    double targetWidth,
    BuildContext context,
  ) {
    final List<Widget> items = [];

    for (final itemJson in template.items) {
      try {
        final Map<String, dynamic> item = itemJson;
        final String type = item['type'] as String;
        final Map<String, dynamic> relativeOffset =
            item['originalRelativeOffset'] as Map<String, dynamic>;
        final double relativeX = (relativeOffset['dx'] as num).toDouble();
        final double relativeY = (relativeOffset['dy'] as num).toDouble();
        final Map<String, dynamic> size = item['size'] as Map<String, dynamic>;
        final double width = (size['width'] as num).toDouble();
        final double height = (size['height'] as num).toDouble();
        final Map<String, dynamic>? content =
            item['content'] as Map<String, dynamic>?;
        final String? textAlignStr = item['textAlign'] as String?;
        bool isCentered = item['isCentered'];
        // Scale positions and sizes based on relative offsets
        final double scaledWidth = (width / template.width) * targetWidth;
        final double scaledHeight = (height / template.height) * targetHeight;
        final normalizedX = relativeX * targetWidth;
        final double normalizedY = relativeY * targetHeight;

        // Clamp to prevent overflow
        final double clampedWidth = scaledWidth.clamp(10.0, targetWidth);
        final double clampedHeight = scaledHeight.clamp(10.0, targetHeight);
        final double clampedX = normalizedX.clamp(
          0.0,
          targetWidth - clampedWidth,
        );
        final double clampedY = normalizedY.clamp(
          0.0,
          targetHeight - clampedHeight,
        );

        final double adjustedX = isCentered
            ? normalizedX -
                  (clampedWidth /
                      2) // Center by offsetting left by half the width
            : clampedX;

        debugPrint(
          'Rendering item: type=$type, relativeX=$relativeX, relativeY=$relativeY, '
          'adjustedX=$adjustedX, clampedY=$clampedY, clampedWidth=$clampedWidth, clampedHeight=$clampedHeight, '
          'isCentered=$isCentered',
        );

        if (type == 'StackTextItem' && content != null) {
          final String? data = content['data'] as String?;
          final Map<String, dynamic>? style =
              content['style'] as Map<String, dynamic>?;
          final String? googleFont = content['googleFont'] as String?;

          final double baseFontSize = (style?['fontSize'] as num? ?? 12.0)
              .toDouble();
          final double minFontSize = (style?['minFontSize'] as num? ?? 8.0)
              .toDouble();
          final double maxFontSize = (style?['maxFontSize'] as num? ?? 12.0)
              .toDouble();
          final double scaledFontSize = MediaQuery.textScalerOf(
            context,
          ).scale(baseFontSize).clamp(minFontSize, maxFontSize);
          final txtStyle = TextStyle(
            fontSize: scaledFontSize,
            fontFamily: googleFont != null
                ? GoogleFonts.getFont(googleFont).fontFamily
                : null,
            color: style?['color'] != null
                ? Color(int.parse(style!['color'].replaceAll('#', '0xFF')))
                : null,
            fontWeight: style?['fontWeight'] != null
                ? _parseFontWeight(style!['fontWeight'])
                : null,
          );

          items.add(
            Positioned(
              left: adjustedX,
              top: clampedY,
              right: isCentered ? adjustedX : null,
              child: Container(
                color: Colors.blueAccent.withOpacity(0.2),
                width: getTextWidth(text: data ?? "", style: txtStyle) + 10,
                child: Text(
                  data ?? "",
                  style: txtStyle,
                  textAlign: _parseTextAlign(textAlignStr),
                  maxLines: 5,
                  softWrap: true,
                ),
              ),
            ),
          );
        } else if (type == 'StackImageItem' && content != null) {
          final String? assetName = content['assetName'] as String?;
          final String? fitStr = item['fit'] as String?;

          items.add(
            Positioned(
              left: adjustedX,
              top: clampedY,
              child: Image.asset(
                assetName ?? "",
                width: clampedWidth,
                height: clampedHeight,
                fit: _parseFit(fitStr),
                errorBuilder: (_, __, ___) => Container(
                  color: Get.theme.colorScheme.primaryContainer,
                  width: clampedWidth,
                  height: clampedHeight,
                ),
              ),
            ),
          );
        }
      } catch (e) {
        debugPrint("Error rendering item: $e, JSON: $itemJson");
      }
    }
    return items;
  }

  FontWeight? _parseFontWeight(dynamic weight) {
    if (weight is String) {
      switch (weight) {
        case 'FontWeight.w100':
          return FontWeight.w100;
        case 'FontWeight.w200':
          return FontWeight.w200;
        case 'FontWeight.w300':
          return FontWeight.w300;
        case 'FontWeight.w400':
          return FontWeight.w400;
        case 'FontWeight.w500':
          return FontWeight.w500;
        case 'FontWeight.w600':
          return FontWeight.w600;
        case 'FontWeight.w700':
          return FontWeight.w700;
        case 'FontWeight.w800':
          return FontWeight.w800;
        case 'FontWeight.w900':
          return FontWeight.w900;
        default:
          return null;
      }
    }
    return null;
  }

  TextAlign _parseTextAlign(String? align) {
    switch (align?.toLowerCase()) {
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      case 'justify':
        return TextAlign.justify;
      default:
        return TextAlign.start;
    }
  }

  BoxFit _parseFit(String? fit) {
    switch (fit?.toLowerCase()) {
      case 'cover':
        return BoxFit.cover;
      case 'contain':
        return BoxFit.contain;
      case 'fill':
        return BoxFit.fill;
      default:
        return BoxFit.cover;
    }
  }
}

class PlaceholderPage extends StatelessWidget {
  final String title;
  final IconData icon;
  const PlaceholderPage({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Get.theme.colorScheme.primaryContainer,
            ),
            child: Icon(
              icon,
              size: 40,
              color: Get.theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: Get.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Get.theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This page is under construction.\nCheck back soon!',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Get.theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class CategoriesList extends GetView<HomeController> {
  const CategoriesList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          return Container(
            margin: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => controller.onCategoryTap(category),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      category.color.withOpacity(0.2),
                      category.color.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: category.color.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: category.color,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      category.name,
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: Get.theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

double getTextWidth({required String text, required TextStyle style}) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: 1,
    textDirection: TextDirection.ltr,
  )..layout();

  return textPainter.size.width;
}
