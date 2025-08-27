import 'package:cached_network_image/cached_network_image.dart';
import 'package:cardmaker/app/features/home/category_templates/controller.dart';
import 'package:cardmaker/core/values/app_colors.dart';
import 'package:cardmaker/models/card_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class CategoryTemplatesPage extends StatelessWidget {
  final CategoryModel category;
  final String controllerTag;

  CategoryTemplatesPage({super.key, required this.category})
    : controllerTag = 'category_${category.id}';

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryTemplatesController>(
      init: CategoryTemplatesController(category),
      tag: controllerTag,
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: RefreshIndicator(
            color: category.color,
            onRefresh: controller.onRefresh,
            child: CustomScrollView(
              controller: controller.scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                _buildEnhancedSliverAppBar(controller),
                _buildTemplatesStaggeredGrid(controller),
                _buildLoadingIndicator(controller),
                const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
              ],
            ),
          ),
        );
      },
    );
  }

  SliverAppBar _buildEnhancedSliverAppBar(
    CategoryTemplatesController controller,
  ) {
    return SliverAppBar(
      expandedHeight: 100, // Increased height to accommodate search bar
      pinned: true,
      stretch: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
      ),

      bottom: PreferredSize(
        preferredSize: Size.fromHeight(55),
        child: _buildSearchBar(controller),
      ),
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final expandedHeight = constraints.maxHeight;
          final isCollapsed = expandedHeight < 100;

          return FlexibleSpaceBar(
            stretchModes: const [
              StretchMode.zoomBackground,
              StretchMode.blurBackground,
            ],
            centerTitle: true,
            title: AnimatedOpacity(
              opacity: isCollapsed ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Text(
                '${category.name} Templates',
                style: Get.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Background with gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        category.color,
                        category.color.withOpacity(0.8),
                        category.color.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),

                // Subtle pattern overlay
                Opacity(
                  opacity: 0.05,
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/subtle_pattern.png"),
                        repeat: ImageRepeat.repeat,
                      ),
                    ),
                  ),
                ),

                // Decorative icon
                Positioned(
                  top: 70,
                  right: 30,
                  child: Icon(
                    category.icon,
                    size: 120,
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),

                // Bottom shadow overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.2),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(CategoryTemplatesController controller) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),

      child: TextField(
        onChanged: controller.onSearchChanged,

        style: Get.textTheme.bodyMedium?.copyWith(color: AppColors.branding),
        decoration: InputDecoration(
          filled: true,
          hintText: 'Search ${category.name.toLowerCase()} templates...',
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.search_rounded, color: category.color, size: 20),
          ),
          suffixIcon: Obx(
            () => controller.searchQuery.value.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear_rounded, color: AppColors.accent),
                    onPressed: () => controller.onSearchChanged(''),
                  )
                : const SizedBox.shrink(),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          hintStyle: Get.textTheme.bodyMedium?.copyWith(
            color: AppColors.accent.withOpacity(0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildTemplatesStaggeredGrid(CategoryTemplatesController controller) {
    return Obx(
      () => SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        sliver: controller.templates.isEmpty && controller.isLoading.value
            ? SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: category.color,
                  ),
                ),
              )
            : controller.templates.isEmpty
            ? SliverFillRemaining(child: _buildEmptyState())
            : SliverMasonryGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childCount: controller.templates.length,
                itemBuilder: (context, index) => _ProfessionalTemplateCard(
                  template: controller.templates[index],
                  onTap: () => controller.onTemplateSelected(
                    controller.templates[index],
                  ),
                  categoryColor: category.color,
                ),
              ),
      ),
    );
  }

  Widget _buildLoadingIndicator(CategoryTemplatesController controller) {
    return Obx(
      () => controller.isLoading.value && controller.templates.isNotEmpty
          ? SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: category.color,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Loading more templates...',
                          style: Get.textTheme.bodySmall?.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : const SliverToBoxAdapter(child: SizedBox.shrink()),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: category.color.withOpacity(0.1),
            ),
            child: Icon(
              category.icon,
              size: 60,
              color: category.color.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No ${category.name} Templates',
            style: Get.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.branding,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'We\'re working on adding amazing ${category.name.toLowerCase()} templates.\nCheck back soon!',
            textAlign: TextAlign.center,
            style: Get.textTheme.bodyMedium?.copyWith(
              color: AppColors.accent,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.explore_outlined),
            label: const Text('Explore Other Categories'),
            style: OutlinedButton.styleFrom(
              foregroundColor: category.color,
              side: BorderSide(color: category.color.withOpacity(0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfessionalTemplateCard extends StatelessWidget {
  final CardTemplate template;
  final VoidCallback onTap;
  final Color categoryColor;

  const _ProfessionalTemplateCard({
    required this.template,
    required this.onTap,
    required this.categoryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 15,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: template.aspectRatio > 0
                        ? template.aspectRatio
                        : 1.0,
                    child: _buildThumbnail(),
                  ),
                ),

                // Premium badge
                if (template.isPremium) _buildPremiumBadge(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    if (template.thumbnailUrl != null && template.thumbnailUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: template.thumbnailUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => _buildShimmerPlaceholder(),
        errorWidget: (context, url, error) => _buildPlaceholder(),
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 300),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(color: Colors.white),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Icon(Icons.image_outlined, size: 32, color: Colors.grey[400]),
      ),
    );
  }

  Widget _buildPremiumBadge() {
    return Positioned(
      top: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.workspace_premium, size: 12, color: AppColors.branding),
            const SizedBox(width: 4),
            Text(
              'PRO',
              style: Get.textTheme.labelSmall?.copyWith(
                color: AppColors.branding,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
