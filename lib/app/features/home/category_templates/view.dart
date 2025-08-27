import 'package:cached_network_image/cached_network_image.dart';
import 'package:cardmaker/app/features/home/category_templates/controller.dart';
import 'package:cardmaker/core/values/app_colors.dart';
import 'package:cardmaker/models/card_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class CategoryTemplatesPage extends StatelessWidget {
  final CategoryModel? category;
  const CategoryTemplatesPage({super.key, this.category});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryTemplatesController>(
      autoRemove: false,
      init: CategoryTemplatesController(category),
      builder: (controller) {
        return Scaffold(
          body: RefreshIndicator(
            color: controller.getPageColor(),
            onRefresh: controller.onRefresh,
            child: CustomScrollView(
              controller: controller.scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                _buildEnhancedSliverAppBar(controller, context),
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
    BuildContext context,
  ) {
    return SliverAppBar(
      expandedHeight: 100,
      pinned: true,
      stretch: true,
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      elevation: 0,
      actions: [
        Obx(
          () => IconButton(
            icon: Icon(
              Icons.filter_list_rounded,
              color:
                  (controller.selectedCategory.value.isNotEmpty ||
                      controller.selectedType.value.isNotEmpty)
                  ? controller.getPageColor()
                  : AppColors.accent,
            ),
            onPressed: () => _showFilterDrawer(context, controller),
            tooltip: 'Filter Templates',
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                controller.getPageColor().withOpacity(0.85),
                controller.getPageColor().withOpacity(0.45),
              ],
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _buildSearchBar(controller),
        ),
      ),
    );
  }

  Widget _buildSearchBar(CategoryTemplatesController controller) {
    return TextField(
      onChanged: controller.onSearchChanged,
      style: Get.textTheme.bodyMedium?.copyWith(color: AppColors.branding),
      decoration: InputDecoration(
        hintText: 'Search ${controller.getPageTitle().toLowerCase()}...',
        prefixIcon: Icon(
          Icons.search_rounded,
          color: controller.getPageColor(),
        ),
        suffixIcon: Obx(
          () => controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear_rounded,
                    color: AppColors.accent,
                  ),
                  onPressed: () => controller.onSearchChanged(''),
                )
              : const SizedBox(),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _showFilterDrawer(
    BuildContext context,
    CategoryTemplatesController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) =>
            _buildFilterDrawerContent(controller, scrollController),
      ),
    );
  }

  Widget _buildFilterDrawerContent(
    CategoryTemplatesController controller,
    ScrollController scrollController,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drawer Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: Get.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.branding,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.accent),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Category Filter
            Text(
              'Categories',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.branding,
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.availableCategories.map((categoryId) {
                  final isSelected =
                      controller.selectedCategory.value == categoryId;
                  final categoryName = controller.getCategoryName(categoryId);
                  final categoryColor = controller.getCategoryColor(categoryId);

                  return ChoiceChip(
                    label: Text(
                      categoryName,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : categoryColor,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) =>
                        controller.onCategoryFilterChanged(categoryId),
                    selectedColor: categoryColor,
                    backgroundColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: categoryColor.withOpacity(0.3)),
                    ),
                    showCheckmark: false,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Premium/Free Filter
            Text(
              'Template Type',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.branding,
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Free'),
                    selected: controller.selectedType.value == 'free',
                    onSelected: (_) => controller.onTypeFilterChanged('free'),
                    selectedColor: AppColors.branding,
                    backgroundColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: AppColors.branding.withOpacity(0.3),
                      ),
                    ),
                    showCheckmark: false,
                  ),
                  ChoiceChip(
                    label: const Text('Premium'),
                    selected: controller.selectedType.value == 'premium',
                    onSelected: (_) =>
                        controller.onTypeFilterChanged('premium'),
                    selectedColor: AppColors.branding,
                    backgroundColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: AppColors.branding.withOpacity(0.3),
                      ),
                    ),
                    showCheckmark: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Clear Filters Button
            OutlinedButton(
              onPressed: controller.clearFilters,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.branding,
                side: BorderSide(color: AppColors.branding.withOpacity(0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Clear Filters'),
            ),
          ],
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
                    color: controller.getPageColor(),
                  ),
                ),
              )
            : controller.templates.isEmpty
            ? SliverFillRemaining(child: _buildEmptyState(controller))
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
                  onFavoriteToggle: () =>
                      controller.toggleFavorite(controller.templates[index]),
                  categoryColor: controller.getPageColor(),
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
                            color: controller.getPageColor(),
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

  Widget _buildEmptyState(CategoryTemplatesController controller) {
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
              color: controller.getPageColor().withOpacity(0.1),
            ),
            child: Icon(
              Icons.image_search_rounded,
              size: 60,
              color: controller.getPageColor().withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Templates Found',
            style: Get.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.branding,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            controller.searchQuery.value.isNotEmpty
                ? 'No templates match your search "${controller.searchQuery.value}"'
                : 'No templates available for the selected filters.',
            textAlign: TextAlign.center,
            style: Get.textTheme.bodyMedium?.copyWith(
              color: AppColors.accent,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: controller.clearFilters,
            icon: const Icon(Icons.clear_rounded),
            label: const Text('Clear Filters'),
            style: OutlinedButton.styleFrom(
              foregroundColor: controller.getPageColor(),
              side: BorderSide(
                color: controller.getPageColor().withOpacity(0.3),
              ),
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
  final VoidCallback onFavoriteToggle;
  final Color categoryColor;

  const _ProfessionalTemplateCard({
    required this.template,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.categoryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 6,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: template.aspectRatio > 0
                        ? template.aspectRatio
                        : 1.0,
                    child: _buildThumbnail(),
                  ),
                ),
                _buildFavoriteButton(),
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

  Widget _buildFavoriteButton() {
    return Positioned(
      top: 12,
      left: 12,
      child: GetBuilder<CategoryTemplatesController>(
        builder: (controller) => InkWell(
          onTap: onFavoriteToggle,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Obx(
              () => Icon(
                controller.favoriteTemplateIds.contains(template.id)
                    ? Icons.favorite
                    : Icons.favorite_border,
                size: 20,
                color: controller.favoriteTemplateIds.contains(template.id)
                    ? Colors.red
                    : AppColors.accent,
              ),
            ),
          ),
        ),
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
// class CategoryTemplatesPage extends StatelessWidget {
//   final CategoryModel? category;
//   const CategoryTemplatesPage({super.key, this.category});

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<CategoryTemplatesController>(
//       autoRemove: false,
//       init: CategoryTemplatesController(category),
//       builder: (controller) {
//         return Scaffold(
//           body: RefreshIndicator(
//             color: controller.getPageColor(),
//             onRefresh: controller.onRefresh,
//             child: CustomScrollView(
//               controller: controller.scrollController,
//               physics: const BouncingScrollPhysics(
//                 parent: AlwaysScrollableScrollPhysics(),
//               ),
//               slivers: [
//                 _buildEnhancedSliverAppBar(controller, context),
//                 _buildTemplatesStaggeredGrid(controller),
//                 _buildLoadingIndicator(controller),
//                 const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   SliverAppBar _buildEnhancedSliverAppBar(
//     CategoryTemplatesController controller,
//     BuildContext context,
//   ) {
//     return SliverAppBar(
//       expandedHeight: 100,
//       pinned: true,
//       backgroundColor: Get.theme.scaffoldBackgroundColor,
//       title: Text("xxx"),

//       elevation: 0,
//       actions: [
//         IconButton(
//           icon: Icon(
//             Icons.filter_list_rounded,
//             color: Colors.white,
//             // color:
//             //     (controller.selectedCategory.value.isNotEmpty ||
//             //         controller.selectedType.value.isNotEmpty)
//             //     ? AppColors.branding
//             //     : AppColors.brandingLight,
//           ),
//           onPressed: () => _showFilterDrawer(context, controller),
//           tooltip: 'Filter Templates',
//         ),
//       ],
//       flexibleSpace: FlexibleSpaceBar(
//         background: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [
//                 AppColors.branding.withOpacity(0.85),
//                 AppColors.brandingLight.withOpacity(0.45),
//               ],
//             ),
//           ),
//         ),
//       ),
//       bottom: PreferredSize(
//         preferredSize: const Size.fromHeight(60),
//         child: Container(
//           padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
//           decoration: BoxDecoration(
//             color: Get.theme.scaffoldBackgroundColor,
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
//             // boxShadow: [
//             //   BoxShadow(
//             //     color: Colors.black.withOpacity(0.05),
//             //     blurRadius: 12,
//             //     offset: const Offset(0, 4),
//             //   ),
//             // ],
//           ),
//           child: _buildSearchBar(controller),
//         ),
//       ),
//     );
//   }

//   Widget _buildSearchBar(CategoryTemplatesController controller) {
//     return TextField(
//       onChanged: controller.onSearchChanged,
//       style: Get.textTheme.bodyMedium?.copyWith(color: AppColors.branding),
//       decoration: InputDecoration(
//         hintText: 'Search ${controller.getPageTitle().toLowerCase()}...',
//         prefixIcon: Icon(
//           Icons.search_rounded,
//           color: controller.getPageColor(),
//         ),
//         suffixIcon: Obx(
//           () => controller.searchQuery.value.isNotEmpty
//               ? IconButton(
//                   icon: const Icon(
//                     Icons.clear_rounded,
//                     color: AppColors.accent,
//                   ),
//                   onPressed: () => controller.onSearchChanged(''),
//                 )
//               : const SizedBox(),
//         ),
//         filled: true,
//         // fillColor: Colors.grey[50],
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 20,
//           vertical: 14,
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(50),
//           borderSide: BorderSide.none,
//         ),
//       ),
//     );
//   }

//   void _showFilterDrawer(
//     BuildContext context,
//     CategoryTemplatesController controller,
//   ) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => DraggableScrollableSheet(
//         initialChildSize: 0.6,
//         minChildSize: 0.3,
//         maxChildSize: 0.9,
//         expand: false,
//         builder: (context, scrollController) =>
//             _buildFilterDrawerContent(controller, scrollController),
//       ),
//     );
//   }

//   Widget _buildFilterDrawerContent(
//     CategoryTemplatesController controller,
//     ScrollController scrollController,
//   ) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       child: SingleChildScrollView(
//         controller: scrollController,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Drawer Header
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Filters',
//                   style: Get.textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.close, color: AppColors.accent),
//                   onPressed: () => Get.back(),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),

//             // Category Filter
//             Text(
//               'Categories',
//               style: Get.textTheme.titleSmall?.copyWith(
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Wrap(
//               spacing: 8,
//               runSpacing: 8,
//               children: controller.availableCategories.map((categoryId) {
//                 final isSelected =
//                     controller.selectedCategory.value == categoryId;
//                 final categoryName = controller.getCategoryName(categoryId);
//                 // final categoryColor = controller.getCategoryColor(categoryId);

//                 return ChoiceChip(
//                   label: Text(
//                     categoryName,
//                     style: TextStyle(fontWeight: FontWeight.w500),
//                   ),
//                   selected: isSelected,
//                   onSelected: (_) =>
//                       controller.onCategoryFilterChanged(categoryId),
//                   // backgroundColor: Colors.grey[100],
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                     side: BorderSide.none,
//                   ),
//                   showCheckmark: false,
//                 );
//               }).toList(),
//             ),
//             const SizedBox(height: 16),

//             // Premium/Free Filter
//             Text(
//               'Template Type',
//               style: Get.textTheme.titleSmall?.copyWith(
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Wrap(
//               spacing: 8,
//               runSpacing: 8,
//               children: [
//                 ChoiceChip(
//                   label: const Text('Free'),
//                   selected: controller.selectedType.value == 'free',
//                   onSelected: (_) => controller.onTypeFilterChanged('free'),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                     side: BorderSide.none,
//                   ),
//                   showCheckmark: false,
//                 ),
//                 ChoiceChip(
//                   label: const Text('Premium'),
//                   selected: controller.selectedType.value == 'premium',
//                   onSelected: (_) => controller.onTypeFilterChanged('premium'),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                     side: BorderSide.none,
//                   ),
//                   showCheckmark: false,
//                 ),
//               ],
//             ),

//             const SizedBox(height: 24),

//             // Clear Filters Button
//             OutlinedButton.icon(
//               onPressed: controller.clearFilters,
//               style: OutlinedButton.styleFrom(
//                 foregroundColor: AppColors.branding,
//                 side: BorderSide(color: AppColors.branding.withOpacity(0.3)),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 24,
//                   vertical: 12,
//                 ),
//               ),
//               label: const Text('Clear Filters'),
//               icon: Icon(Icons.clear),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTemplatesStaggeredGrid(CategoryTemplatesController controller) {
//     return Obx(
//       () => SliverPadding(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//         sliver: controller.templates.isEmpty && controller.isLoading.value
//             ? SliverFillRemaining(
//                 child: Center(
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     color: controller.getPageColor(),
//                   ),
//                 ),
//               )
//             : controller.templates.isEmpty
//             ? SliverFillRemaining(child: _buildEmptyState(controller))
//             : SliverMasonryGrid.count(
//                 crossAxisCount: 2,
//                 mainAxisSpacing: 16,
//                 crossAxisSpacing: 16,
//                 childCount: controller.templates.length,
//                 itemBuilder: (context, index) => _ProfessionalTemplateCard(
//                   template: controller.templates[index],
//                   onTap: () => controller.onTemplateSelected(
//                     controller.templates[index],
//                   ),
//                   categoryColor: controller.getPageColor(),
//                 ),
//               ),
//       ),
//     );
//   }

//   Widget _buildLoadingIndicator(CategoryTemplatesController controller) {
//     return Obx(
//       () => controller.isLoading.value && controller.templates.isNotEmpty
//           ? SliverToBoxAdapter(
//               child: Container(
//                 padding: const EdgeInsets.all(24),
//                 child: Center(
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 12,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(12),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.05),
//                           blurRadius: 16,
//                           offset: const Offset(0, 6),
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         SizedBox(
//                           width: 16,
//                           height: 16,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             color: controller.getPageColor(),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Text(
//                           'Loading more templates...',
//                           style: Get.textTheme.bodySmall?.copyWith(
//                             color: AppColors.accent,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             )
//           : const SliverToBoxAdapter(child: SizedBox.shrink()),
//     );
//   }

//   Widget _buildEmptyState(CategoryTemplatesController controller) {
//     return Container(
//       padding: const EdgeInsets.all(40),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 120,
//             height: 120,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: controller.getPageColor().withOpacity(0.1),
//             ),
//             child: Icon(
//               Icons.image_search_rounded,
//               size: 60,
//               color: controller.getPageColor().withOpacity(0.6),
//             ),
//           ),
//           const SizedBox(height: 24),
//           Text(
//             'No Templates Found',
//             style: Get.textTheme.headlineSmall?.copyWith(
//               fontWeight: FontWeight.w700,
//               color: AppColors.branding,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             controller.searchQuery.value.isNotEmpty
//                 ? 'No templates match your search "${controller.searchQuery.value}"'
//                 : 'No templates available for the selected filters.',
//             textAlign: TextAlign.center,
//             style: Get.textTheme.bodyMedium?.copyWith(
//               color: AppColors.accent,
//               height: 1.5,
//             ),
//           ),
//           const SizedBox(height: 32),
//           OutlinedButton.icon(
//             onPressed: controller.clearFilters,
//             icon: const Icon(Icons.clear_rounded),
//             label: const Text('Clear Filters'),
//             style: OutlinedButton.styleFrom(
//               foregroundColor: controller.getPageColor(),
//               side: BorderSide(
//                 color: controller.getPageColor().withOpacity(0.3),
//               ),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _ProfessionalTemplateCard extends StatelessWidget {
//   final CardTemplate template;
//   final VoidCallback onTap;
//   final Color categoryColor;

//   const _ProfessionalTemplateCard({
//     required this.template,
//     required this.onTap,
//     required this.categoryColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.transparent,

//         boxShadow: [
//           BoxShadow(
//             color: Get.theme.shadowColor.withOpacity(0.1),
//             blurRadius: 16,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),

//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Stack(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(16),
//                   child: AspectRatio(
//                     aspectRatio: template.aspectRatio > 0
//                         ? template.aspectRatio
//                         : 1.0,
//                     child: _buildThumbnail(),
//                   ),
//                 ),
//                 if (template.isPremium) _buildPremiumBadge(),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildThumbnail() {
//     if (template.thumbnailUrl != null && template.thumbnailUrl!.isNotEmpty) {
//       return CachedNetworkImage(
//         imageUrl: template.thumbnailUrl!,
//         fit: BoxFit.cover,
//         width: double.infinity,
//         height: double.infinity,
//         placeholder: (context, url) => _buildShimmerPlaceholder(),
//         errorWidget: (context, url, error) => _buildPlaceholder(),
//         fadeInDuration: const Duration(milliseconds: 300),
//         fadeOutDuration: const Duration(milliseconds: 300),
//       );
//     }
//     return _buildPlaceholder();
//   }

//   Widget _buildShimmerPlaceholder() {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey[300]!,
//       highlightColor: Colors.grey[100]!,
//       child: Container(color: Colors.white),
//     );
//   }

//   Widget _buildPlaceholder() {
//     return Container(
//       color: Colors.grey[100],
//       child: Center(
//         child: Icon(Icons.image_outlined, size: 32, color: Colors.grey[400]),
//       ),
//     );
//   }

//   Widget _buildPremiumBadge() {
//     return Positioned(
//       top: 12,
//       right: 12,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.workspace_premium, size: 12, color: AppColors.branding),
//             const SizedBox(width: 4),
//             Text(
//               'PRO',
//               style: Get.textTheme.labelSmall?.copyWith(
//                 color: AppColors.branding,
//                 fontWeight: FontWeight.w700,
//                 letterSpacing: 0.5,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
