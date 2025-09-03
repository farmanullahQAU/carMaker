// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cardmaker/app/features/home/category_templates/controller.dart';
// import 'package:cardmaker/core/values/app_colors.dart';
// import 'package:cardmaker/models/card_template.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// import 'package:get/get.dart';
// import 'package:shimmer/shimmer.dart';

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
//       stretch: true,
//       backgroundColor: Get.theme.scaffoldBackgroundColor,
//       elevation: 0,
//       actions: [
//         IconButton(
//           icon: Icon(
//             Icons.filter_list_rounded,
//             // color:
//             //     (controller.selectedCategory.value.isNotEmpty ||
//             //         controller.selectedType.value.isNotEmpty)
//             //     ? controller.getPageColor()
//             //     : AppColors.accent,
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
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           decoration: BoxDecoration(
//             // color: Colors.white,
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 12,
//                 offset: const Offset(0, 4),
//               ),
//             ],
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
//         hintText: 'Search ...',
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
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 20,
//           vertical: 14,
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(25),
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
//                     fontWeight: FontWeight.w700,
//                     color: AppColors.branding,
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.close),
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
//             Obx(
//               () => Wrap(
//                 spacing: 8,
//                 runSpacing: 8,
//                 children: controller.availableCategories.map((categoryId) {
//                   final isSelected =
//                       controller.selectedCategory.value == categoryId;
//                   final categoryName = controller.getCategoryName(categoryId);
//                   final categoryColor = controller.getCategoryColor(categoryId);

//                   return ChoiceChip(
//                     label: Text(
//                       categoryName,
//                       style: TextStyle(fontWeight: FontWeight.w500),
//                     ),
//                     selected: isSelected,
//                     onSelected: (_) =>
//                         controller.onCategoryFilterChanged(categoryId),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     showCheckmark: false,
//                   );
//                 }).toList(),
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Premium/Free Filter
//             // Text(
//             //   'Template Type',
//             //   style: Get.textTheme.titleMedium?.copyWith(
//             //     fontWeight: FontWeight.w600,
//             //     color: AppColors.branding,
//             //   ),
//             // ),
//             // const SizedBox(height: 8),
//             // Obx(
//             //   () => Wrap(
//             //     spacing: 8,
//             //     runSpacing: 8,
//             //     children: [
//             //       ChoiceChip(
//             //         label: const Text('Free'),
//             //         selected: controller.selectedType.value == 'free',
//             //         onSelected: (_) => controller.onTypeFilterChanged('free'),
//             //         shape: RoundedRectangleBorder(
//             //           borderRadius: BorderRadius.circular(20),
//             //           side: BorderSide(),
//             //         ),
//             //         showCheckmark: false,
//             //       ),
//             //       ChoiceChip(
//             //         label: const Text('Premium'),
//             //         selected: controller.selectedType.value == 'premium',
//             //         onSelected: (_) =>
//             //             controller.onTypeFilterChanged('premium'),
//             //         selectedColor: AppColors.branding,
//             //         backgroundColor: Colors.grey[100],
//             //         shape: RoundedRectangleBorder(
//             //           borderRadius: BorderRadius.circular(20),
//             //           side: BorderSide(
//             //             color: AppColors.branding.withOpacity(0.3),
//             //           ),
//             //         ),
//             //         showCheckmark: false,
//             //       ),
//             //     ],
//             //   ),
//             // ),
//             const SizedBox(height: 24),

//             // Clear Filters Button
//             OutlinedButton(
//               onPressed: controller.clearFilters,
//               style: OutlinedButton.styleFrom(
//                 side: BorderSide(color: AppColors.branding.withOpacity(0.3)),

//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 24,
//                   vertical: 12,
//                 ),
//               ),
//               child: const Text('Clear Filters'),
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
//                 crossAxisSpacing: 8,
//                 childCount: controller.templates.length,
//                 itemBuilder: (context, index) => _ProfessionalTemplateCard(
//                   template: controller.templates[index],
//                   onTap: () => controller.onTemplateSelected(
//                     controller.templates[index],
//                   ),
//                   onFavoriteToggle: () =>
//                       controller.toggleFavorite(controller.templates[index]),
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
//   final VoidCallback onFavoriteToggle;
//   final Color categoryColor;

//   const _ProfessionalTemplateCard({
//     required this.template,
//     required this.onTap,
//     required this.onFavoriteToggle,
//     required this.categoryColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Stack(
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Get.theme.colorScheme.shadow.withOpacity(0.05),
//                       blurRadius: 12,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(12),
//                   child: AspectRatio(
//                     aspectRatio: template.aspectRatio > 0
//                         ? template.aspectRatio
//                         : 1.0,
//                     child: _buildThumbnail(),
//                   ),
//                 ),
//               ),

//               _buildFavoriteButton(),
//               if (template.isPremium) _buildPremiumBadge(),
//             ],
//           ),
//         ],
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

//   Widget _buildFavoriteButton() {
//     return Positioned(
//       top: 12,
//       left: 12,
//       child: GetBuilder<CategoryTemplatesController>(
//         builder: (controller) => InkWell(
//           onTap: onFavoriteToggle,
//           child: Container(
//             padding: const EdgeInsets.all(6),
//             decoration: BoxDecoration(
//               color: Get.theme.colorScheme.surfaceContainer,
//               shape: BoxShape.circle,
//               boxShadow: [
//                 BoxShadow(
//                   color: Get.theme.colorScheme.shadow.withOpacity(0.1),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Obx(
//               () => Icon(
//                 controller.favoriteTemplateIds.contains(template.id)
//                     ? Icons.favorite
//                     : Icons.favorite_border,
//                 // size: 20,
//                 color: controller.favoriteTemplateIds.contains(template.id)
//                     ? AppColors.branding
//                     : AppColors.brandingLight,
//               ),
//             ),
//           ),
//         ),
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
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cardmaker/app/features/home/category_templates/controller.dart';
import 'package:cardmaker/core/values/app_colors.dart';
import 'package:cardmaker/models/card_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

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
          // backgroundColor: const Color(0xFFFAFAFA),
          // backgroundColor: ,
          body: RefreshIndicator(
            color: controller.getPageColor(),
            onRefresh: controller.onRefresh,
            child: CustomScrollView(
              controller: controller.scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                _buildProfessionalSliverAppBar(controller, context),
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

  SliverAppBar _buildProfessionalSliverAppBar(
    CategoryTemplatesController controller,
    BuildContext context,
  ) {
    return SliverAppBar(
      expandedHeight: 140,
      title: Text(
        controller.getPageTitle(),
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      pinned: true,
      stretch: true,
      // backgroundColor: const Color(0xFFFAFAFA),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surfaceBright,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            // color: Color(0xFF374151),
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surfaceBright,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.tune_rounded, size: 20),
            onPressed: () => _showFilterBottomSheet(context, controller),
            tooltip: 'Filter Templates',
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 80),

        // title: Text(
        //   controller.getPageTitle(),
        //   style: const TextStyle(
        //     fontSize: 24,
        //     fontWeight: FontWeight.w700,
        //     color: Color(0xFF111827),
        //     letterSpacing: -0.5,
        //   ),
        // ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: _buildProfessionalSearchBar(controller),
        ),
      ),
    );
  }

  Widget _buildProfessionalSearchBar(CategoryTemplatesController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: controller.onSearchChanged,
        style: const TextStyle(
          color: Color(0xFF374151),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Search templates...',
          hintStyle: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            child: const Icon(
              Icons.search_rounded,
              color: Color(0xFF6B7280),
              size: 20,
            ),
          ),
          suffixIcon: Obx(
            () => controller.searchQuery.value.isNotEmpty
                ? Container(
                    margin: const EdgeInsets.all(8),
                    child: Material(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => controller.onSearchChanged(''),
                        child: const SizedBox(
                          width: 32,
                          height: 32,
                          child: Icon(
                            Icons.close_rounded,
                            color: Color(0xFF6B7280),
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  void _showFilterBottomSheet(
    BuildContext context,
    CategoryTemplatesController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          // color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: DraggableScrollableSheet(
          // initialChildSize: 0.6,
          // minChildSize: 0.3,
          // maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) =>
              _buildFilterContent(controller, scrollController),
        ),
      ),
    );
  }

  Widget _buildFilterContent(
    CategoryTemplatesController controller,
    ScrollController scrollController,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Templates',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Categories Section
            const Text(
              'Categories',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.availableCategories.map((categoryId) {
                  final isSelected =
                      controller.selectedCategory.value == categoryId;
                  final categoryName = controller.getCategoryName(categoryId);

                  return _FilterChip(
                    label: categoryName,
                    isSelected: isSelected,
                    onTap: () => controller.onCategoryFilterChanged(categoryId),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 32),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: controller.clearFilters,

                    child: const Text('Clear All'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Get.back(),

                    child: const Text('Apply'),
                  ),
                ),
              ],
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
            ? SliverFillRemaining(child: _buildLoadingState(controller))
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

  Widget _buildLoadingState(CategoryTemplatesController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: controller.getPageColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: controller.getPageColor(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Loading templates...',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: controller.getPageColor(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Loading more...',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 14,
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
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: controller.getPageColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 40,
                color: controller.getPageColor().withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Templates Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.searchQuery.value.isNotEmpty
                  ? 'No templates match your search criteria'
                  : 'No templates available for the selected filters',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: controller.clearFilters,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(
                'Clear Filters',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: controller.getPageColor(),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.brandingLight : null,
      borderRadius: BorderRadius.circular(25),
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            // border: Border.all(
            //   color: isSelected ? AppColors.branding : const Color(0xFFE5E7EB),
            // ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              // color: isSelected ? AppColors.branding : const Color(0xFF6B7280),
            ),
          ),
        ),
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
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gray200, width: 0.4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Container
              Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: template.aspectRatio > 0
                            ? template.aspectRatio
                            : 1.0,
                        child: _buildThumbnail(),
                      ),
                    ),
                  ),
                  _buildFavoriteButton(),
                  if (template.isPremium) _buildPremiumBadge(),
                ],
              ),

              // Template Info
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (template.category.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          template.category,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: categoryColor,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
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
        fadeInDuration: const Duration(milliseconds: 200),
        fadeOutDuration: const Duration(milliseconds: 200),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildShimmerPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFFD1D5DB),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(Icons.image_outlined, size: 32, color: Color(0xFFD1D5DB)),
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return Positioned(
      top: 8,
      left: 8,
      child: GetBuilder<CategoryTemplatesController>(
        builder: (controller) => Material(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onFavoriteToggle,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
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
                  size: 16,
                  color: controller.favoriteTemplateIds.contains(template.id)
                      ? AppColors.red400
                      : AppColors.gray400,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumBadge() {
    return Positioned(
      top: 6,
      right: 6,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFF7C3AED),
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.star_rounded, size: 10, color: Colors.white),
            SizedBox(width: 2),
            Text(
              'PRO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
