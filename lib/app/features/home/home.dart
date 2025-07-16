import 'dart:ui';

import 'package:cardmaker/app/features/editor/editor_canvas.dart';
import 'package:cardmaker/app/features/home/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const SizedBox(height: 8),
              // const ModernSearchBar(),
              const SizedBox(height: 16),
              const ModernCarousel(),
              const SizedBox(height: 20),
              const SectionTitle(title: 'Quick Actions'),
              const SizedBox(height: 12),
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
          // Obx(
          //   () => Text(
          //     Get.find<HomeController>().getGreeting(),
          //     style: Get.textTheme.bodyMedium?.copyWith(
          //       color: Get.theme.colorScheme.onSurfaceVariant,
          //     ),
          //   ),
          // ),
          // const SizedBox(height: 2),
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

class ModernSearchBar extends StatelessWidget {
  const ModernSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        onChanged: Get.find<HomeController>().onSearchChanged,
        style: Get.textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Search templates, categories, or tags...',
          hintStyle: Get.textTheme.bodyMedium?.copyWith(
            color: Get.theme.colorScheme.onSurfaceVariant,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Get.theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
          suffixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.tune_rounded,
              color: Get.theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
          filled: true,
          fillColor: Get.theme.colorScheme.surfaceContainerHighest.withOpacity(
            0.5,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Get.theme.colorScheme.primary,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

class ModernCarousel extends StatelessWidget {
  const ModernCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find();
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      height: screenWidth * 0.48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemExtent: screenWidth * 0.72,
        itemCount: controller.trendingNow.length,
        itemBuilder: (context, index) {
          return ModernCarouselCard(category: controller.trendingNow[index]);
        },
      ),
    );
  }
}

class ModernCarouselCard extends StatelessWidget {
  final CategoryModel category;
  const ModernCarouselCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.find<HomeController>().onCategoryTap(category),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Get.theme.colorScheme.shadow.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                category.imagePath ?? "assets/placeholder.png",
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: Get.theme.colorScheme.primaryContainer),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.4, 0.6, 1.0],
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Trending',
                            style: Get.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category.name,
                      style: Get.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuickActionsGrid extends GetView<HomeController> {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: List.generate(controller.quickActions.length, (index) {
          final action = controller.quickActions[index];
          return GestureDetector(
            onTap: () => controller.onQuickActionTap(action),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: action.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: action.color.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(action.icon, color: action.color, size: 24),
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
        }),
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

class CategoriesList extends GetView<HomeController> {
  const CategoriesList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => controller.onCategoryTap(category),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Get.theme.colorScheme.surfaceContainerHighest,
                  border: Border.all(
                    color: Get.theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: category.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category.name,
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: Get.theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
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

class HorizontalCardList extends GetView<HomeController> {
  const HorizontalCardList({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the target height for the entire list.
    const double listHeight = 230;
    // Define the height for the image part of the card. The rest is for text.
    const double targetImageHeight = 150.0;

    return Obx(
      () => SizedBox(
        height: listHeight,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.featuredTemplates.length,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          // REMOVED: itemExtent, as we now have dynamic widths.
          itemBuilder: (context, index) {
            final template = controller.featuredTemplates[index];

            // 1. Calculate the aspect ratio safely.
            final double aspectRatio = (template.height > 0)
                ? template.width / template.height
                : 1.0; // Default to 1:1 if height is 0

            // 2. Calculate the required width for the card based on the target image height.
            final double cardWidth = targetImageHeight * aspectRatio;

            return GestureDetector(
              onTap: () => controller.onTemplateTap(template),
              child: Container(
                // 3. Apply the dynamic width to the card container.
                width: cardWidth,
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // This container now has a fixed height for the image.
                    Container(
                      height: targetImageHeight,
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
                        child: Image.asset(
                          template.backgroundImage,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Get.theme.colorScheme.primaryContainer,
                            child: Icon(
                              Icons.image_outlined,
                              color: Get.theme.colorScheme.onPrimaryContainer,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Text and tags remain the same
                    // Text(
                    //   template.name,
                    //   style: Get.textTheme.bodyMedium?.copyWith(
                    //     fontWeight: FontWeight.w500,
                    //     color: Get.theme.colorScheme.onSurface,
                    //   ),
                    //   maxLines: 1,
                    //   overflow: TextOverflow.ellipsis,
                    // ),
                    const SizedBox(height: 2),
                    Text(
                      template.category,
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: Get.theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                    ),
                    // if (template.tags.isNotEmpty) ...[
                    //   const SizedBox(height: 4),
                    //   Wrap(
                    //     spacing: 4,
                    //     runSpacing: 4,
                    //     children: template.tags.take(2).map((tag) {
                    //       return Container(
                    //         padding: const EdgeInsets.symmetric(
                    //           horizontal: 6,
                    //           vertical: 2,
                    //         ),
                    //         decoration: BoxDecoration(
                    //           color:
                    //               Get.theme.colorScheme.surfaceContainerHighest,
                    //           borderRadius: BorderRadius.circular(8),
                    //         ),
                    //         child: Text(
                    //           tag,
                    //           style: Get.textTheme.labelSmall?.copyWith(
                    //             color: Get.theme.colorScheme.onSurfaceVariant,
                    //           ),
                    //         ),
                    //       );
                    //     }).toList(),
                    //   ),
                    // ],
                  ],
                ),
              ),
            );
          },
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
