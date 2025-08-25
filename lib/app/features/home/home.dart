import 'package:cardmaker/app/features/editor/editor_canvas.dart';
import 'package:cardmaker/app/features/home/blank_templates/view.dart';
import 'package:cardmaker/app/features/home/controller.dart';
import 'package:cardmaker/core/values/app_colors.dart';
import 'package:cardmaker/models/card_template.dart';
import 'package:cardmaker/services/template_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:widget_mask/widget_mask.dart';

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

// --- Canvas Size Model ---
class CanvasSize {
  final String title;
  final double width;
  final double height;
  final IconData icon;
  final Color color;
  final String? thumbnailUrl;

  CanvasSize({
    required this.title,
    required this.width,
    required this.height,
    required this.icon,
    required this.color,
    this.thumbnailUrl,
  });
}

// --- Main Home Page Widget ---
class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());
    Get.put(TemplateService()); // Ensure TemplateService is initialized

    return Scaffold(
      backgroundColor: Get.theme.colorScheme.surface,
      body: PageView(
        controller: controller.pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: controller.onPageChanged,
        children: [
          HomeTab(),
          EditorPage(),
          const PlaceholderPage(
            title: "My Designs",
            icon: Icons.palette_outlined,
          ),
          const PlaceholderPage(
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
      child: SafeArea(
        child: NavigationBar(
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: controller.onBottomNavTap,
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
         icon: Icon(icon, size: 22),
         selectedIcon: Icon(
           selectedIcon,
           size: 22,
           color: Get.theme.colorScheme.primary,
         ),
       );
}

// --- The Main Scrollable Home Tab ---
class HomeTab extends GetView<HomeController> {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildModernAppBar(),
        const SliverToBoxAdapter(
          child: CanvasSizesRow(), // Simplified with only basic canvases
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const ProfessionalTemplatesBanner(),
              const SizedBox(height: 20),
              const SectionTitle(title: 'Browse Categories', showSeeAll: true),
              const SizedBox(height: 12),
              const CategoriesList(),
              const SizedBox(height: 20),
              const SectionTitle(title: 'Featured Templates', showSeeAll: true),
              const SizedBox(height: 12),
              HorizontalCardList(), // Updated to show templates
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
            'Hello, User!',
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
      backgroundColor: Get.theme.colorScheme.surface,
      elevation: 0,
    );
  }
}

// --- New HorizontalCardList Widget to Display Templates ---
class HorizontalCardList extends GetView<HomeController> {
  const HorizontalCardList({super.key});

  @override
  Widget build(BuildContext context) {
    final templateService = Get.find<TemplateService>();

    return SizedBox(
      height: 150, // Fixed height for the card list
      child: StreamBuilder<List<CardTemplate>>(
        stream: templateService.getTemplates(limit: 10), // Fetch templates
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading templates: ${snapshot.error}',
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: Get.theme.colorScheme.error,
                ),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No templates available',
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: Get.theme.colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          final templates = snapshot.data!;
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: TemplateCard(template: template),
              );
            },
          );
        },
      ),
    );
  }
}

// --- New TemplateCard Widget ---
class TemplateCard extends StatelessWidget {
  final CardTemplate template;

  const TemplateCard({super.key, required this.template});

  @override
  Widget build(BuildContext context) {
    // Calculate aspect ratio from template dimensions
    final aspectRatio = template.width / template.height;
    const cardWidth = 150.0; // Fixed width for each card
    final cardHeight = cardWidth / aspectRatio; // Height based on aspect ratio

    return GestureDetector(
      onTap: () {
        // Navigate to EditorPage with the selected template
        Get.to(() => EditorPage(), arguments: {'template': template});
      },
      child: Container(
        width: cardWidth,
        // height: cardHeight,
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Get.theme.colorScheme.shadow.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Template thumbnail or background
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Container(
                  width: cardWidth,
                  // height: cardHeight * 0.75, // 75% of card height for thumbnail
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.branding.withOpacity(0.2),
                        AppColors.branding.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: template.thumbnailUrl != null
                      ? Image.network(
                          template.thumbnailUrl!,
                          fit: BoxFit.contain,
                          // width: cardWidth,
                          // height: cardHeight * 0.75,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.broken_image,
                            size: 40,
                            color: Get.theme.colorScheme.onSurfaceVariant,
                          ),
                        )
                      : Icon(
                          Icons.image,
                          size: 40,
                          color: Get.theme.colorScheme.onSurfaceVariant,
                        ),
                ),
              ),
            ),

            // Template name
          ],
        ),
      ),
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
              onPressed: () {
                // Navigate to a full templates page or filter templates
                // Get.to(() => const ProfessionalTemplatesPage());
              },
              child: Text(
                'See All',
                style: Get.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ProfessionalTemplatesBanner extends StatelessWidget {
  const ProfessionalTemplatesBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.brandingLight,
            AppColors.branding,
            AppColors.brandingLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.3),
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
                  'Professional Templates',
                  style: Get.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Social media, business cards, prints & more.',
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: () => Get.to(() => ProfessionalTemplatesPage()),
                  child: Text(
                    'Explore',
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
            Icons.business_center_outlined,
            size: 42,
            color: Colors.white.withOpacity(0.8),
          ),
        ],
      ),
    );
  }
}

class CanvasSizesRow extends GetView<HomeController> {
  const CanvasSizesRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Start a new design',
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Get.theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16.0),
          // Only basic canvas sizes section
          _buildBasicCanvasSection(),
        ],
      ),
    );
  }

  Widget _buildBasicCanvasSection() {
    final basicSizes = [
      {
        'title': 'Square',
        'aspectRatio': 1.0,
        'gradient': LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.branding.withOpacity(0.01),
            AppColors.branding.withOpacity(0.02),
            AppColors.branding.withOpacity(0.3),
          ],
        ),
      },
      {
        'title': 'Portrait',
        'aspectRatio': 0.75,
        'gradient': LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.branding.withOpacity(0.8),
            AppColors.branding.withOpacity(0.6),
            AppColors.branding.withOpacity(0.4),
          ],
        ),
      },
      {
        'title': 'Landscape',
        'aspectRatio': 1.33,
        'gradient': LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.branding.withOpacity(0.85),
            AppColors.branding.withOpacity(0.65),
            AppColors.branding.withOpacity(0.45),
          ],
        ),
      },
    ];

    return SizedBox(
      height: 90.0,
      child: Row(
        spacing: 16,
        children: basicSizes.asMap().entries.map((entry) {
          final index = entry.key;
          final canvas = entry.value;
          return Expanded(
            child: Container(
              // margin: EdgeInsets.only(
              //   left: index == 0 ? 0 : 8.0,
              //   right: index == basicSizes.length - 1 ? 0 : 8.0,
              // ),
              child: _buildBasicCanvasCardWithGradient(
                canvas['title'] as String,
                canvas['aspectRatio'] as double,
                canvas['gradient'] as LinearGradient,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBasicCanvasCardWithGradient(
    String title,
    double aspectRatio,
    LinearGradient gradient,
  ) {
    return GestureDetector(
      onTap: () {
        // Handle tap
      },
      child: Container(
        decoration: BoxDecoration(
          // gradient: gradient,
          color: Get.theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(20.0),
          // boxShadow: [
          //   BoxShadow(
          //     color: Get.theme.colorScheme.shadow.withOpacity(0.05),
          //     blurRadius: 6.0,
          //     offset: const Offset(0, 2),
          //   ),
          // ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Canvas preview container
            Container(
              width: 60.0,
              height: 60.0 / aspectRatio,
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8.0),
                // border: Border.all(
                //   color: Get.theme.colorScheme.outline.withOpacity(0.2),
                //   width: 0.5,
                // ),
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.black.withOpacity(0.1),
                //     blurRadius: 4.0,
                //     offset: const Offset(0, 2.0),
                //   ),
                // ],
              ),
              child: Icon(Icons.add, color: AppColors.branding, size: 20.0),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Other Existing Widgets (Unchanged) ---
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

Size getTextWidth({required String text, required TextStyle style}) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: 300);

  return textPainter.size;
}

class MaskingExamplePage extends StatelessWidget {
  const MaskingExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mask Boundary Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Visualizing Mask Boundaries:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: Get.width * 0.8,
              height: 600,
              child: WidgetMask(
                blendMode: BlendMode.srcOver,
                childSaveLayer: true,
                mask: Image.asset('assets/card7.png'),
                child: InkWell(
                  onTap: () {
                    print("xxxxxxxxxxxxxxxxx");
                  },
                  child: PhotoView(
                    minScale: PhotoViewComputedScale.contained * 0.4,
                    maxScale: PhotoViewComputedScale.covered * 3.0,
                    initialScale: PhotoViewComputedScale.contained,
                    basePosition: Alignment.center,
                    enablePanAlways: true,
                    imageProvider: const AssetImage('assets/Farman.png'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
