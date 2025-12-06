import 'package:cached_network_image/cached_network_image.dart';
import 'package:cardmaker/app/features/home/blank_templates/view.dart';
import 'package:cardmaker/app/features/home/controller.dart';
import 'package:cardmaker/app/features/profile/view.dart';
import 'package:cardmaker/app/routes/app_routes.dart';
import 'package:cardmaker/core/utils/responsive_helper.dart';
import 'package:cardmaker/core/values/app_colors.dart';
import 'package:cardmaker/core/values/app_constants.dart';
import 'package:cardmaker/models/card_template.dart';
import 'package:cardmaker/services/admob_service.dart';
import 'package:cardmaker/widgets/common/no_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:upgrader/upgrader.dart';
import 'package:widget_mask/widget_mask.dart';

// --- ENHANCED DATA MODELS ---

class QuickAction {
  final String title;
  final IconData icon;
  final Color color;

  const QuickAction({
    required this.title,
    required this.icon,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'icon': icon.codePoint,
    'color': color.value,
  };

  factory QuickAction.fromJson(Map<String, dynamic> json) => QuickAction(
    title: json['title'] as String,
    icon: IconData(json['icon'] as int, fontFamily: 'MaterialIcons'),
    color: Color(json['color'] as int),
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

  const CanvasSize({
    required this.title,
    required this.width,
    required this.height,
    required this.icon,
    required this.color,
    this.thumbnailUrl,
  });
}

// --- Main Home Page Widget ---
// --- Main Home Page Widget ---
class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      upgrader: Upgrader(
        // Upgrader automatically checks the app store for updates
        // and compares with current app version

        // FORCED UPDATES: Set minimum app version for forced updates.,.l;
        // If current app version < minAppVersion, it becomes a forced update
        // The dialog will keep showing until user updates, even if they:
        // - Go to Play Store and come back without updating
        // - Close the app and reopen its
        // minAppVersion: '1.0.8', // Uncomment and set your minimum version
        // How often to show the update dialog again after user dismisses
        // For forced updates (when minAppVersion is set), set to Duration(seconds: 0)
        // to show immediately every time app opens until user updates
        // For flexible updates, use Duration(days: 2) to remind after 2 days
        // durationUntilAlertAgain: const Duration(hours: 6),

        // For forced updates, change to: Duration(seconds: 0)
      ),

      // FLEXIBLE UPDATE CONFIGURATION (Current Setup):
      // Users can dismiss or postpone the update
      barrierDismissible: true, // Allow tapping outside to dismiss
      showIgnore: false, // Show "Ignore" button
      showLater: true, // Show "Later" button
      // FORCED UPDATE CONFIGURATION (When minAppVersion is set):
      // When minAppVersion is set and current version < minAppVersion:
      // - Upgrader automatically detects it's a forced update
      // - You should also set these to enforce forced behavior:
      // barrierDismissible: false,  // Prevent dismissing dialog
      // showIgnore: false,           // Hide "Ignore" button
      // showLater: false,            // Hide "Later" button
      // durationUntilAlertAgain: Duration(seconds: 0) // Show immediately on every app open

      // BEHAVIOR EXPLANATION:
      // 1. If user's app version < minAppVersion (forced update):
      //    - Dialog shows immediately when app opens
      //    - If user goes to Play Store and comes back WITHOUT updating:
      //      → Dialog will show again immediately (if durationUntilAlertAgain: Duration(seconds: 0))
      //      → Or after the duration specified
      //    - If user closes app and reopens:
      //      → Dialog will show again immediately (if durationUntilAlertAgain: Duration(seconds: 0))
      //      → This continues until user updates to >= minAppVersion
      //
      // 2. If user's app version >= minAppVersion (no forced update):
      //    - Dialog only shows if there's a newer version available (optional update)
      //    - User can dismiss and it won't show again for durationUntilAlertAgain period
      //
      // 3. ALTERNATIVE: Use app store description markers (recommended):
      //    - Google Play: Add "[Minimum supported app version: 1.2.3]" to description
      //    - App Store: Add "[:mav: 1.2.3]" to description
      //    - When detected, upgrader automatically handles forced updates
      //    - No need to set minAppVersion in code
      dialogStyle: UpgradeDialogStyle.cupertino,
      child: Obx(
        () => Scaffold(
          extendBody: controller.selectedIndex.value == 0,
          body: IndexedStack(
            index: controller.selectedIndex.value,
            children: const [
              HomeTab(),
              ProfessionalTemplatesPage(),
              ProfileTab(),
            ],
          ),
          bottomNavigationBar: _buildBottomNav(),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: controller.selectedIndex.value,
      onTap: controller.onBottomNavTap,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.apps_rounded),
          activeIcon: Icon(Icons.apps, size: 22),
          label: 'Canvas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          activeIcon: Icon(Icons.person, size: 22),
          label: 'Profile',
        ),
      ],
    );
  }
}

// --- The Main Scrollable Home Tab ---
class HomeTab extends GetView<HomeController> {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return _HomeTabStateful();
  }
}

class _HomeTabStateful extends StatefulWidget {
  const _HomeTabStateful();

  @override
  State<_HomeTabStateful> createState() => _HomeTabStatefulState();
}

class _HomeTabStatefulState extends State<_HomeTabStateful>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final controller = Get.find<HomeController>();

    return Scaffold(
      extendBody: true,
      appBar: _buildAppBar(controller),
      body: RefreshIndicator(
        onRefresh: () async {
          controller.refreshData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              CanvasSizesRow(),
              SizedBox(height: 12),
              ProfessionalTemplatesBanner(),
              SizedBox(height: 20),
              SectionTitle(title: 'Categories'),
              SizedBox(height: 12),
              CategoriesList(),
              SizedBox(height: 20),

              TrendingTemplatesList(),
              SizedBox(height: 12),

              SectionTitle(title: 'Free today', showSeeAll: false),
              SizedBox(height: 12),

              FreeTodayTemplatesList(),
              SizedBox(height: kBottomNavigationBarHeight),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(HomeController controller) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create Design',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: _shareApp,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.share_outlined, size: 20),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () {
              Get.toNamed(AppRoutes.settings);
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.settings, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _shareApp() async {
    final storeUrl = (GetPlatform.isIOS && kAppstoreUrl.isNotEmpty)
        ? kAppstoreUrl
        : kPlaystoreUrl;

    final shareText = storeUrl.isNotEmpty
        ? 'Create beautiful cards and invitations with CardMaker. Download now: $storeUrl'
        : 'Create beautiful cards and invitations with CardMaker.';

    try {
      await Share.share(
        shareText,
        subject: 'CardMaker - Design stunning cards',
      );
    } catch (error, stackTrace) {
      debugPrint('Share app failed: $error\n$stackTrace');
    }
  }
}

// --- Modern Loading Skeleton Widget ---
class ModernLoadingSkeleton extends StatefulWidget {
  const ModernLoadingSkeleton({super.key});

  @override
  State<ModernLoadingSkeleton> createState() => _ModernLoadingSkeletonState();
}

class _ModernLoadingSkeletonState extends State<ModernLoadingSkeleton> {
  @override
  Widget build(BuildContext context) {
    final cardHeight = ResponsiveHelper.getCardHeight(context);

    return SizedBox(
      height: cardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 4,
        itemBuilder: (context, index) => _buildSkeletonCard(cardHeight),
        separatorBuilder: (context, index) => const SizedBox(width: 12),
      ),
    );
  }

  Widget _buildSkeletonCard(double height) {
    final isDark = Get.theme.brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
      highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: 100,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : const Color(0xFFE5E7EB),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Professional HorizontalCardList Widget ---
class FreeTodayTemplatesList extends GetView<HomeController> {
  const FreeTodayTemplatesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final cardWidth = ResponsiveHelper.getCardWidth(context);
        final spacing = ResponsiveHelper.getGridSpacing(context);
        final padding = ResponsiveHelper.getResponsivePadding(context);

        final cardHeight = ResponsiveHelper.getCardHeight(context);

        return SizedBox(
          height: cardHeight,
          child: GetBuilder<HomeController>(
            id: 'freeTodayTemplates',
            builder: (controller) {
              if (!controller.hasLoadedFreeToday.value) {
                return const ModernLoadingSkeleton();
              }

              if (controller.freeTodayTemplates.isEmpty) {
                return NoDataWidget(icon: Icons.search_off_rounded);
              }

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                cacheExtent: 2000,
                padding: EdgeInsets.symmetric(horizontal: padding.horizontal),
                itemCount: controller.freeTodayTemplates.length + 1,
                itemBuilder: (context, index) {
                  if (index == controller.freeTodayTemplates.length) {
                    return _buildViewAllCard(context, cardWidth, cardHeight);
                  }
                  return SizedBox(
                    width: cardWidth,
                    height: cardHeight,
                    child: OptimizedTemplateCard(
                      template: controller.freeTodayTemplates[index],
                      onTap: () => controller.onTemplateTap(
                        controller.freeTodayTemplates[index],
                      ),
                      onFavoriteToggle: () => controller.toggleFavorite(
                        controller.freeTodayTemplates[index].id,
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => SizedBox(width: spacing),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildViewAllCard(BuildContext context, double width, double height) {
    // Use fixed height to match template cards
    return SizedBox(
      height: height,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => controller.onTapViewAll(true),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                // Background pattern/gradient
                Positioned(
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.branding.withOpacity(0.05),
                          AppColors.branding.withOpacity(0.02),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                // Content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.branding.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.card_giftcard_rounded,
                          color: AppColors.branding,
                          size: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'View All',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: context.theme.colorScheme.onSurface
                              .withOpacity(0.7),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Trending Templates List Widget ---
class TrendingTemplatesList extends GetView<HomeController> {
  const TrendingTemplatesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final cardWidth = ResponsiveHelper.getCardWidth(context);
        final spacing = ResponsiveHelper.getGridSpacing(context);
        final padding = ResponsiveHelper.getResponsivePadding(context);

        final cardHeight = ResponsiveHelper.getCardHeight(context);

        return SizedBox(
          height: cardHeight,
          child: GetBuilder<HomeController>(
            id: 'trendingTemplates',
            builder: (controller) {
              if (!controller.hasLoadedTrending.value) {
                return const ModernLoadingSkeleton();
              }

              if (controller.trendingTemplates.isEmpty) {
                return NoDataWidget(
                  title: 'No results found',
                  icon: Icons.search_off_rounded,
                );
              }

              return ListView.separated(
                scrollDirection: Axis.horizontal,

                cacheExtent: 2000,
                padding: EdgeInsets.symmetric(horizontal: padding.horizontal),
                itemCount: controller.trendingTemplates.length + 1,
                itemBuilder: (context, index) {
                  if (index == controller.trendingTemplates.length) {
                    return _buildViewAllCard(context, cardWidth, cardHeight);
                  }
                  return SizedBox(
                    width: cardWidth,
                    height: cardHeight,
                    child: OptimizedTemplateCard(
                      template: controller.trendingTemplates[index],
                      onTap: () => controller.onTemplateTap(
                        controller.trendingTemplates[index],
                      ),
                      onFavoriteToggle: () => controller.toggleFavorite(
                        controller.trendingTemplates[index].id,
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => SizedBox(width: spacing),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildViewAllCard(BuildContext context, double width, double height) {
    // Use fixed height to match template cards
    return SizedBox(
      height: height,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => controller.onTapViewAll(false),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                // Background pattern/gradient
                Positioned(
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.branding.withOpacity(0.05),
                          AppColors.branding.withOpacity(0.02),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                // Content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.branding.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.trending_up_rounded,
                          color: AppColors.branding,
                          size: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'View All',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: context.theme.colorScheme.onSurface
                              .withOpacity(0.7),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Professional TemplateCard Widget ---
class OptimizedTemplateCard extends StatelessWidget {
  final CardTemplate template;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const OptimizedTemplateCard({
    super.key,
    required this.template,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    // Get responsive fixed height
    final cardHeight = ResponsiveHelper.getCardHeight(context);

    return Stack(
      children: [
        SizedBox(
          height: cardHeight,
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onTap,
              child: Container(
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    // Image container with fixed height
                    Positioned.fill(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          // boxShadow: [
                          //   BoxShadow(
                          //     color: Colors.black.withOpacity(0.08),
                          //     blurRadius: 4,
                          //     offset: const Offset(0, 2),
                          //   ),
                          // ],
                        ),
                        child: _buildTemplateImage(),
                      ),
                    ),
                    _buildFavoriteButton(context),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Text(template.id),
      ],
    );
  }

  Widget _buildTemplateImage() {
    if (template.thumbnailUrl != null) {
      return CachedNetworkImage(
        imageUrl: template.thumbnailUrl!,
        fit: BoxFit.contain,
        fadeInDuration: const Duration(milliseconds: 200),

        placeholder: (context, url) => _buildShimmerPlaceholder(),
        errorWidget: (context, url, error) => _buildErrorWidget(),
        imageBuilder: (context, imageProvider) => Image(
          image: imageProvider,
          fit: BoxFit.contain,
          // width: double.infinity,
          // height: double.infinity,
        ),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return _buildShimmerPlaceholder();
  }

  Widget _buildShimmerPlaceholder() {
    final isDark = Get.theme.brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
      highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
      period: const Duration(milliseconds: 1500),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Icon(
            Icons.image_outlined,
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            size: 32,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        // border: Border.all(
        //   color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
        //   width: 1,
        // ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_rounded,
              size: 32,
              color: Get.theme.hintColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(BuildContext context) {
    return Positioned(
      top: 0,
      right: 0,
      child: GetBuilder<HomeController>(
        id: 'favorites',
        builder: (controller) => Material(
          color: context.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onFavoriteToggle,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: context.theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Obx(
                () => Icon(
                  controller.favoriteTemplateIds.contains(template.id)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  size: 14,
                  color: controller.favoriteTemplateIds.contains(template.id)
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF9CA3AF),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- Professional Section Title ---
class SectionTitle extends StatelessWidget {
  final String title;
  final bool showSeeAll;
  final VoidCallback? onSeeAllTap;

  const SectionTitle({
    super.key,
    required this.title,
    this.showSeeAll = false,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.theme.colorScheme.onSurface,
            ),
          ),
          if (showSeeAll)
            TextButton(onPressed: onSeeAllTap, child: const Text('See All')),
        ],
      ),
    );
  }
}

// --- Professional Templates Banner - Compact Version ---
class ProfessionalTemplatesBanner extends GetView<HomeController> {
  const ProfessionalTemplatesBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.branding, AppColors.brandingLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // Title
                    const Text(
                      'Import Design',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Description
                    Text(
                      'Import your saved .artnie designs',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // CTA Button
                  ],
                ),
              ),
              ElevatedButton(
                style: FilledButton.styleFrom(
                  elevation: 0,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () {
                  controller.importDesign();
                },
                child: const Text("Import"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Keep CanvasSizesRow exactly as provided ---
class CanvasSizesRow extends GetView<HomeController> {
  const CanvasSizesRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildBasicCanvasSection(context)],
      ),
    );
  }

  Widget _buildBasicCanvasSection(BuildContext context) {
    // Define list of CardTemplate constructors
    final basicTemplates = [
      CardTemplate(
        id: 'square',
        name: 'Square',
        width: 1000,
        height: 1000,
        categoryId: 'general',
        imagePath: 'assets/square.png',
        items: [],
      ),
      CardTemplate(
        id: 'portrait',
        name: 'Portrait',
        width: 750,
        height: 1000,
        categoryId: 'general',
        imagePath: 'assets/portrait.png',
        items: [],
      ),
      CardTemplate(
        id: 'landscape',
        name: 'Landscape',
        width: 1000,
        height: 750,
        categoryId: 'general',
        imagePath: 'assets/landscape.png',
        items: [],
      ),
    ];

    return SizedBox(
      height: 90.0,
      child: Row(
        spacing: 8,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: basicTemplates.asMap().entries.map((entry) {
          final template = entry.value;
          return Expanded(child: _buildBasicCanvasCard(template, context));
        }).toList(),
      ),
    );
  }

  Widget _buildBasicCanvasCard(CardTemplate template, BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        GestureDetector(
          onTap: () {
            AdMobService().onTemplateViewed();

            Get.toNamed(AppRoutes.editor, arguments: template);
          },
          child: Container(
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 55.0,
                    height: 55.0 / template.aspectRatio,
                    decoration: BoxDecoration(
                      color: context.theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(
                      Icons.add,
                      color: AppColors.branding,
                      size: 20.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        Positioned(
          bottom: -16,
          child: Text(template.name, style: Get.textTheme.labelSmall),
        ),
      ],
    );
  }
}

// --- Professional Categories List ---
class CategoriesList extends GetView<HomeController> {
  const CategoriesList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: controller.categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          return _CategoryChip(category: category, controller: controller);
        },
        separatorBuilder: (context, _) => const SizedBox(width: 8),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final dynamic category;
  final HomeController controller;

  const _CategoryChip({required this.category, required this.controller});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => controller.onCategoryTap(category),
      child: Card(
        // padding: const EdgeInsets.symmetric(horizontal: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: category.color,
                  // border: Border.all(
                  //   color: Colors.white.withOpacity(0.3),
                  //   width: 1,
                  // ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                category.name,
                style: Get.textTheme.bodySmall?.copyWith(
                  color: context.theme.colorScheme.onSurface,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Utility Functions ---
Size getTextWidth({
  required String text,
  required TextStyle style,
  TextDirection textDirection = TextDirection.ltr,
}) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: textDirection,
  )..layout();

  return textPainter.size;
}

// --- Professional Masking Example Page ---
class MaskingExamplePage extends StatelessWidget {
  const MaskingExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mask Preview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF6B7280)),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: Get.width * 0.8,
                height: 500,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: WidgetMask(
                    blendMode: BlendMode.srcOver,
                    childSaveLayer: true,
                    mask: Image.asset('assets/card7.png'),
                    child: PhotoView(
                      minScale: PhotoViewComputedScale.contained * 0.4,
                      maxScale: PhotoViewComputedScale.covered * 3.0,
                      initialScale: PhotoViewComputedScale.contained,
                      basePosition: Alignment.center,
                      enablePanAlways: true,
                      imageProvider: const AssetImage('assets/Farman.png'),
                      backgroundDecoration: const BoxDecoration(
                        color: Color(0xFFF9FAFB),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Professional Placeholder Page ---
class PlaceholderPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? subtitle;

  const PlaceholderPage({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 36, color: const Color(0xFF6B7280)),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle ?? 'Coming soon',
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
