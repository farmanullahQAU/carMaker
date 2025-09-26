import 'package:cardmaker/app/features/home/category_templates/controller.dart';
import 'package:cardmaker/core/values/app_colors.dart';
import 'package:cardmaker/widgets/common/template_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

class CategoryTemplatesPage extends StatelessWidget {
  final dynamic arguments; // Accept any type of arguments

  const CategoryTemplatesPage({super.key, this.arguments});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryTemplatesController>(
      autoRemove: false,
      builder: (controller) {
        return Scaffold(
          body: RefreshIndicator(
            color: AppColors.branding,
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
      title: Obx(
        () => Text(
          controller.getPageTitle(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
      ),
      pinned: true,
      stretch: true,
      elevation: 0,
      scrolledUnderElevation: 0,
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
        controller: controller.searchController,
        onSubmitted: controller.onSearchSubmitted,
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
            child: Obx(
              () => controller.isSearchLoading.value
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.brandingLight,
                      ),
                    )
                  : const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF6B7280),
                      size: 20,
                    ),
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
                        onTap: () {
                          controller.searchController.clear();
                          controller.onSearchSubmitted('');
                        },
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
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: BottomSheet(
          onClosing: () {},
          builder: (context) => _buildModernFilterContent(controller),
        ),
      ),
    );
  }

  Widget _buildModernFilterContent(CategoryTemplatesController controller) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Get.theme.colorScheme.outline.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Get.theme.colorScheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Get.theme.colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => Get.back(),
                            child: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: Get.theme.colorScheme.onSurface
                                  .withOpacity(0.6),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                _buildModernFilterSection(
                  title: 'Template Type',
                  child: _buildModernTypeToggle(controller),
                ),
                const SizedBox(height: 24),
                _buildModernFilterSection(
                  title: 'Categories',
                  child: _buildModernCategoriesGrid(controller),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernFilterSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Get.theme.colorScheme.onSurface,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildModernTypeToggle(CategoryTemplatesController controller) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: _buildModernTypeOption(
                controller: controller,
                label: 'All Templates',
                icon: Icons.apps_rounded,
                isSelected: !controller.showFreeOnly.value,
                onTap: () => controller.toggleFreeFilter(false),
              ),
            ),
            Expanded(
              child: _buildModernTypeOption(
                controller: controller,
                label: 'Free Only',
                icon: Icons.star_rounded,
                isSelected: controller.showFreeOnly.value,
                onTap: () => controller.toggleFreeFilter(true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTypeOption({
    required CategoryTemplatesController controller,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isSelected
                ? Get.theme.colorScheme.surface
                : Colors.transparent,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? Get.theme.colorScheme.onSurface
                    : Get.theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? Get.theme.colorScheme.onSurface
                      : Get.theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernCategoriesGrid(CategoryTemplatesController controller) {
    return Obx(
      () => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildModernCategoryChip(
            label: 'All Categories',
            isSelected: controller.selectedCategory.value.isEmpty,
            onTap: () => controller.onCategoryFilterChanged(''),
          ),
          ...controller.availableCategories.map((categoryId) {
            final isSelected = controller.selectedCategory.value == categoryId;
            final categoryName = controller.getCategoryName(categoryId);
            final categoryColor = controller.getCategoryColor(categoryId);

            return _ModernCategoryFilterChip(
              label: categoryName,
              color: categoryColor,
              isSelected: isSelected,
              onTap: () => controller.onCategoryFilterChanged(categoryId),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildModernCategoryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.branding
                : Get.theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : Get.theme.colorScheme.onSurface.withOpacity(0.8),
            ),
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
            ? SliverFillRemaining(child: _buildLoadingState(controller))
            : controller.templates.isEmpty
            ? SliverFillRemaining(child: _buildEmptyState(controller))
            : SliverMasonryGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childCount: controller.templates.length,
                itemBuilder: (context, index) {
                  final template = controller.templates[index];
                  return TemplateCard(
                    template: template,
                    key: ValueKey('template_${template.id}'),
                    favoriteButton: FavoriteButton(
                      id: template.id,
                      onTap: () => controller.toggleFavorite(template.id),
                    ),
                    onTap: () => controller.onTemplateSelected(template),
                  );
                },
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
              color: AppColors.brandingLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.brandingLight,
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
                            color: AppColors.brandingLight,
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
                color: AppColors.amber400Light,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 40,
                color: AppColors.amber400,
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
              style: ElevatedButton.styleFrom(elevation: 0),
            ),
          ],
        ),
      ),
    );
  }
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
            color: AppColors.brandingLight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.brandingLight,
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
                          color: AppColors.brandingLight,
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
              color: AppColors.amber400Light,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 40,
              color: AppColors.amber400,
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
            style: ElevatedButton.styleFrom(elevation: 0),
          ),
        ],
      ),
    ),
  );
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
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(25)),
          child: Text(
            label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}

class FavoriteButton extends StatelessWidget {
  final double size;
  final VoidCallback onTap;
  final String id;

  const FavoriteButton({
    super.key,
    required this.onTap,
    this.size = 18,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.9),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          width: size + 12,
          height: size + 12,
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
          child: GetBuilder<CategoryTemplatesController>(
            id: 'favorite_$id',
            builder: (controller) {
              final isFav = controller.isTemplateFavorite(id);
              return Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                size: size,
                color: isFav ? AppColors.red400 : AppColors.gray400,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ModernCategoryFilterChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModernCategoryFilterChip({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        splashColor: color.withOpacity(0.1),
        highlightColor: color.withOpacity(0.05),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withOpacity(0.15)
                : Get.theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
            border: isSelected ? Border.all(color: color, width: 1.5) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isSelected ? color : color.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? color
                      : Get.theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:cardmaker/app/features/home/category_templates/controller.dart';
// import 'package:cardmaker/core/values/app_colors.dart';
// import 'package:cardmaker/models/card_template.dart';
// import 'package:cardmaker/widgets/common/template_card.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// import 'package:get/get.dart';

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
//           // backgroundColor: const Color(0xFFFAFAFA),
//           // backgroundColor: ,
//           body: RefreshIndicator(
//             color: AppColors.branding,
//             onRefresh: controller.onRefresh,
//             child: CustomScrollView(
//               controller: controller.scrollController,
//               physics: const BouncingScrollPhysics(
//                 parent: AlwaysScrollableScrollPhysics(),
//               ),
//               slivers: [
//                 _buildProfessionalSliverAppBar(controller, context),
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

//   SliverAppBar _buildProfessionalSliverAppBar(
//     CategoryTemplatesController controller,
//     BuildContext context,
//   ) {
//     return SliverAppBar(
//       expandedHeight: 140,
//       title: Text(
//         controller.getPageTitle(),
//         style: const TextStyle(
//           fontSize: 24,
//           fontWeight: FontWeight.w700,
//           letterSpacing: -0.5,
//         ),
//       ),
//       pinned: true,
//       stretch: true,
//       // backgroundColor: const Color(0xFFFAFAFA),
//       elevation: 0,
//       scrolledUnderElevation: 0,
//       // leading: Container(
//       //   margin: const EdgeInsets.all(8),
//       //   decoration: BoxDecoration(
//       //     color: Get.theme.colorScheme.surfaceBright,
//       //     borderRadius: BorderRadius.circular(12),
//       //     boxShadow: [
//       //       BoxShadow(
//       //         color: Colors.black.withOpacity(0.08),
//       //         blurRadius: 8,
//       //         offset: const Offset(0, 2),
//       //       ),
//       //     ],
//       //   ),
//       //   child: IconButton(
//       //     icon: const Icon(
//       //       Icons.arrow_back_ios_rounded,
//       //       // color: Color(0xFF374151),
//       //       size: 20,
//       //     ),
//       //     onPressed: () => Get.back(),
//       //   ),
//       // ),
//       actions: [
//         Container(
//           margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
//           decoration: BoxDecoration(
//             color: Get.theme.colorScheme.surfaceBright,
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.08),
//                 blurRadius: 8,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: IconButton(
//             icon: const Icon(Icons.tune_rounded, size: 20),
//             onPressed: () => _showFilterBottomSheet(context, controller),
//             tooltip: 'Filter Templates',
//           ),
//         ),
//       ],
//       flexibleSpace: FlexibleSpaceBar(
//         titlePadding: const EdgeInsets.only(left: 20, bottom: 80),

//         // title: Text(
//         //   controller.getPageTitle(),
//         //   style: const TextStyle(
//         //     fontSize: 24,
//         //     fontWeight: FontWeight.w700,
//         //     color: Color(0xFF111827),
//         //     letterSpacing: -0.5,
//         //   ),
//         // ),
//       ),
//       bottom: PreferredSize(
//         preferredSize: const Size.fromHeight(70),
//         child: Container(
//           padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
//           child: _buildProfessionalSearchBar(controller),
//         ),
//       ),
//     );
//   }

//   Widget _buildProfessionalSearchBar(CategoryTemplatesController controller) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: const Color(0xFFE5E7EB)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: TextField(
//         onChanged: controller.onSearchChanged,
//         style: const TextStyle(
//           color: Color(0xFF374151),
//           fontSize: 14,
//           fontWeight: FontWeight.w500,
//         ),
//         decoration: InputDecoration(
//           hintText: 'Search templates...',
//           hintStyle: const TextStyle(
//             color: Color(0xFF9CA3AF),
//             fontSize: 14,
//             fontWeight: FontWeight.w400,
//           ),
//           prefixIcon: Container(
//             margin: const EdgeInsets.all(12),
//             child: const Icon(
//               Icons.search_rounded,
//               color: Color(0xFF6B7280),
//               size: 20,
//             ),
//           ),
//           suffixIcon: Obx(
//             () => controller.searchQuery.value.isNotEmpty
//                 ? Container(
//                     margin: const EdgeInsets.all(8),
//                     child: Material(
//                       color: const Color(0xFFF3F4F6),
//                       borderRadius: BorderRadius.circular(8),
//                       child: InkWell(
//                         borderRadius: BorderRadius.circular(8),
//                         onTap: () => controller.onSearchChanged(''),
//                         child: const SizedBox(
//                           width: 32,
//                           height: 32,
//                           child: Icon(
//                             Icons.close_rounded,
//                             color: Color(0xFF6B7280),
//                             size: 16,
//                           ),
//                         ),
//                       ),
//                     ),
//                   )
//                 : const SizedBox(),
//           ),
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 20,
//             vertical: 16,
//           ),
//           border: InputBorder.none,
//           enabledBorder: InputBorder.none,
//           focusedBorder: InputBorder.none,
//         ),
//       ),
//     );
//   }

//   void _showFilterBottomSheet(
//     BuildContext context,
//     CategoryTemplatesController controller,
//   ) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         decoration: BoxDecoration(
//           color: Get.theme.colorScheme.surface,
//           borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         child: BottomSheet(
//           onClosing: () {},
//           // initialChildSize: 0.7,
//           // minChildSize: 0.5,
//           // maxChildSize: 0.9,
//           // expand: false,
//           builder: (context) => _buildModernFilterContent(controller),
//         ),
//       ),
//     );
//   }

//   Widget _buildModernFilterContent(CategoryTemplatesController controller) {
//     return SafeArea(
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 16),
//         decoration: BoxDecoration(
//           color: Get.theme.colorScheme.surface,
//           borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Modern Header
//             Container(
//               padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
//               child: Column(
//                 children: [
//                   // Handle bar
//                   Container(
//                     width: 36,
//                     height: 4,
//                     decoration: BoxDecoration(
//                       color: Get.theme.colorScheme.outline.withOpacity(0.3),
//                       borderRadius: BorderRadius.circular(2),
//                     ),
//                   ),
//                   const SizedBox(height: 20),

//                   // Header with close button
//                   Row(
//                     children: [
//                       Text(
//                         'Filters',
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.w700,
//                           color: Get.theme.colorScheme.onSurface,
//                           letterSpacing: -0.5,
//                         ),
//                       ),
//                       const Spacer(),
//                       Container(
//                         width: 32,
//                         height: 32,
//                         decoration: BoxDecoration(
//                           color: Get.theme.colorScheme.surfaceContainerHigh,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Material(
//                           color: Colors.transparent,
//                           borderRadius: BorderRadius.circular(8),
//                           child: InkWell(
//                             borderRadius: BorderRadius.circular(8),
//                             onTap: () => Get.back(),
//                             child: Icon(
//                               Icons.close_rounded,
//                               size: 18,
//                               color: Get.theme.colorScheme.onSurface
//                                   .withOpacity(0.6),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                 ],
//               ),
//             ),

//             // Scrollable Content
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const SizedBox(height: 16),

//                 // Template Type Section
//                 _buildModernFilterSection(
//                   title: 'Template Type',
//                   child: _buildModernTypeToggle(controller),
//                 ),
//                 const SizedBox(height: 24),

//                 // Categories Section
//                 _buildModernFilterSection(
//                   title: 'Categories',
//                   child: _buildModernCategoriesGrid(controller),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildModernFilterSection({
//     required String title,
//     required Widget child,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: Get.theme.colorScheme.onSurface,
//             letterSpacing: -0.2,
//           ),
//         ),
//         const SizedBox(height: 12),
//         child,
//       ],
//     );
//   }

//   Widget _buildModernTypeToggle(CategoryTemplatesController controller) {
//     return Container(
//       padding: const EdgeInsets.all(4),
//       decoration: BoxDecoration(
//         color: Get.theme.colorScheme.surfaceContainerHighest,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Obx(
//         () => Row(
//           children: [
//             Expanded(
//               child: _buildModernTypeOption(
//                 controller: controller,
//                 label: 'All Templates',
//                 icon: Icons.apps_rounded,
//                 isSelected: !controller.showFreeOnly.value,
//                 onTap: () => controller.toggleFreeFilter(false),
//               ),
//             ),
//             Expanded(
//               child: _buildModernTypeOption(
//                 controller: controller,
//                 label: 'Free Only',
//                 icon: Icons.star_rounded,
//                 isSelected: controller.showFreeOnly.value,
//                 onTap: () => controller.toggleFreeFilter(true),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildModernTypeOption({
//     required CategoryTemplatesController controller,
//     required String label,
//     required IconData icon,
//     required bool isSelected,
//     required VoidCallback onTap,
//   }) {
//     return Material(
//       color: Colors.transparent,
//       borderRadius: BorderRadius.circular(8),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(8),
//         onTap: onTap,
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8),
//             color: isSelected
//                 ? Get.theme.colorScheme.surface
//                 : Colors.transparent,
//             boxShadow: isSelected
//                 ? [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.08),
//                       blurRadius: 8,
//                       offset: const Offset(0, 2),
//                     ),
//                   ]
//                 : null,
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 icon,
//                 size: 16,
//                 color: isSelected
//                     ? Get.theme.colorScheme.onSurface
//                     : Get.theme.colorScheme.onSurface.withOpacity(0.6),
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                   color: isSelected
//                       ? Get.theme.colorScheme.onSurface
//                       : Get.theme.colorScheme.onSurface.withOpacity(0.6),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildModernCategoriesGrid(CategoryTemplatesController controller) {
//     return Obx(
//       () => Wrap(
//         spacing: 8,
//         runSpacing: 8,
//         children: [
//           // All Categories chip
//           _buildModernCategoryChip(
//             label: 'All Categories',
//             isSelected: controller.selectedCategory.value.isEmpty,
//             onTap: () => controller.onCategoryFilterChanged(''),
//           ),
//           // Individual category chips
//           ...controller.availableCategories.map((categoryId) {
//             final isSelected = controller.selectedCategory.value == categoryId;
//             final categoryName = controller.getCategoryName(categoryId);
//             final categoryColor = controller.getCategoryColor(categoryId);

//             return _ModernCategoryFilterChip(
//               label: categoryName,
//               color: categoryColor,
//               isSelected: isSelected,
//               onTap: () => controller.onCategoryFilterChanged(categoryId),
//             );
//           }),
//         ],
//       ),
//     );
//   }

//   Widget _buildModernCategoryChip({
//     required String label,
//     required bool isSelected,
//     required VoidCallback onTap,
//   }) {
//     return Material(
//       color: Colors.transparent,
//       borderRadius: BorderRadius.circular(20),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(20),
//         onTap: onTap,
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           decoration: BoxDecoration(
//             color: isSelected
//                 ? AppColors.branding
//                 : Get.theme.colorScheme.surfaceContainerHigh,
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Text(
//             label,
//             style: TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w500,
//               color: isSelected
//                   ? Colors.white
//                   : Get.theme.colorScheme.onSurface.withOpacity(0.8),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Widget _buildModernActionButtons(CategoryTemplatesController controller) {
//   //   return Row(
//   //     children: [
//   //       Expanded(
//   //         child: Container(
//   //           height: 44,
//   //           decoration: BoxDecoration(
//   //             border: Border.all(
//   //               color: Get.theme.colorScheme.outline.withOpacity(0.2),
//   //             ),
//   //             borderRadius: BorderRadius.circular(12),
//   //           ),
//   //           child: Material(
//   //             color: Colors.transparent,
//   //             borderRadius: BorderRadius.circular(12),
//   //             child: InkWell(
//   //               borderRadius: BorderRadius.circular(12),
//   //               onTap: controller.clearFilters,
//   //               child: Center(
//   //                 child: Text(
//   //                   'Clear All',
//   //                   style: TextStyle(
//   //                     fontSize: 14,
//   //                     fontWeight: FontWeight.w600,
//   //                     color: Get.theme.colorScheme.onSurface.withOpacity(0.8),
//   //                   ),
//   //                 ),
//   //               ),
//   //             ),
//   //           ),
//   //         ),
//   //       ),
//   //       const SizedBox(width: 12),
//   //       Expanded(
//   //         child: Container(
//   //           height: 44,
//   //           decoration: BoxDecoration(
//   //             color: AppColors.branding,
//   //             borderRadius: BorderRadius.circular(12),
//   //             boxShadow: [
//   //               BoxShadow(
//   //                 color: AppColors.branding.withOpacity(0.3),
//   //                 blurRadius: 8,
//   //                 offset: const Offset(0, 2),
//   //               ),
//   //             ],
//   //           ),
//   //           child: Material(
//   //             color: Colors.transparent,
//   //             borderRadius: BorderRadius.circular(12),
//   //             child: InkWell(
//   //               borderRadius: BorderRadius.circular(12),
//   //               onTap: () => Get.back(),
//   //               child: const Center(
//   //                 child: Text(
//   //                   'Apply',
//   //                   style: TextStyle(
//   //                     fontSize: 14,
//   //                     fontWeight: FontWeight.w600,
//   //                     color: Colors.white,
//   //                   ),
//   //                 ),
//   //               ),
//   //             ),
//   //           ),
//   //         ),
//   //       ),
//   //     ],
//   //   );
//   // }

//   Widget _buildTemplatesStaggeredGrid(CategoryTemplatesController controller) {
//     return Obx(
//       () => SliverPadding(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//         sliver: controller.templates.isEmpty && controller.isLoading.value
//             ? SliverFillRemaining(child: _buildLoadingState(controller))
//             : controller.templates.isEmpty
//             ? SliverFillRemaining(child: _buildEmptyState(controller))
//             : SliverMasonryGrid.count(
//                 crossAxisCount: 2,
//                 mainAxisSpacing: 16,
//                 crossAxisSpacing: 16,
//                 childCount: controller.templates.length,
//                 itemBuilder: (context, index) {
//                   final template = controller.templates[index];
//                   return TemplateCard(
//                     template: template,
//                     key: ValueKey('template_${template.id}'), // Add this
//                     // isFavorite: controller.isTemplateFavorite(template.id),
//                     favoriteButton: FavoriteButton(
//                       id: template.id,

//                       onTap: () => controller.toggleFavorite(template.id),
//                     ),
//                     onTap: () => controller.onTemplateSelected(template),
//                   );
//                 },
//               ),
//       ),
//     );
//   }
// }

// Widget _buildLoadingState(CategoryTemplatesController controller) {
//   return Center(
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Container(
//           width: 48,
//           height: 48,
//           decoration: BoxDecoration(
//             color: AppColors.brandingLight.withValues(alpha: 0.1),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Center(
//             child: SizedBox(
//               width: 24,
//               height: 24,
//               child: CircularProgressIndicator(
//                 strokeWidth: 2.5,
//                 color: AppColors.brandingLight,
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 16),
//         const Text(
//           'Loading templates...',
//           style: TextStyle(
//             color: Color(0xFF6B7280),
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     ),
//   );
// }

// Widget _buildLoadingIndicator(CategoryTemplatesController controller) {
//   return Obx(
//     () => controller.isLoading.value && controller.templates.isNotEmpty
//         ? SliverToBoxAdapter(
//             child: Container(
//               padding: const EdgeInsets.all(24),
//               child: Center(
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 20,
//                     vertical: 16,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(color: const Color(0xFFE5E7EB)),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.04),
//                         blurRadius: 12,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           color: AppColors.brandingLight,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       const Text(
//                         'Loading more...',
//                         style: TextStyle(
//                           color: Color(0xFF6B7280),
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           )
//         : const SliverToBoxAdapter(child: SizedBox.shrink()),
//   );
// }

// Widget _buildEmptyState(CategoryTemplatesController controller) {
//   return Center(
//     child: Container(
//       padding: const EdgeInsets.all(40),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 80,
//             height: 80,
//             decoration: BoxDecoration(
//               color: AppColors.amber400Light,
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Icon(
//               Icons.search_off_rounded,
//               size: 40,
//               color: AppColors.amber400,
//             ),
//           ),
//           const SizedBox(height: 24),
//           const Text(
//             'No Templates Found',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.w700,
//               color: Color(0xFF111827),
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             controller.searchQuery.value.isNotEmpty
//                 ? 'No templates match your search criteria'
//                 : 'No templates available for the selected filters',
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               color: Color(0xFF6B7280),
//               fontSize: 14,
//               height: 1.5,
//             ),
//           ),
//           const SizedBox(height: 32),
//           ElevatedButton.icon(
//             onPressed: controller.clearFilters,
//             icon: const Icon(Icons.refresh_rounded, size: 18),
//             label: const Text(
//               'Clear Filters',
//               style: TextStyle(fontWeight: FontWeight.w600),
//             ),
//             style: ElevatedButton.styleFrom(elevation: 0),
//           ),
//         ],
//       ),
//     ),
//   );
// }

// class _FilterChip extends StatelessWidget {
//   final String label;
//   final bool isSelected;
//   final VoidCallback onTap;

//   const _FilterChip({
//     required this.label,
//     required this.isSelected,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: isSelected ? AppColors.brandingLight : null,
//       borderRadius: BorderRadius.circular(25),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(25),
//         onTap: onTap,
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(25),
//             // border: Border.all(
//             //   color: isSelected ? AppColors.branding : const Color(0xFFE5E7EB),
//             // ),
//           ),
//           child: Text(
//             label,
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w500,
//               // color: isSelected ? AppColors.branding : const Color(0xFF6B7280),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class FavoriteButton extends StatelessWidget {
//   final double size;
//   final VoidCallback onTap;
//   final String id;

//   const FavoriteButton({
//     super.key,
//     required this.onTap,
//     this.size = 18,
//     required this.id,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.white.withOpacity(0.9),
//       borderRadius: BorderRadius.circular(8),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(8),
//         onTap: onTap,
//         child: Container(
//           width: size + 12,
//           height: size + 12,
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.9),
//             borderRadius: BorderRadius.circular(8),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 4,
//                 offset: const Offset(0, 1),
//               ),
//             ],
//           ),
//           child: GetBuilder<CategoryTemplatesController>(
//             id: 'favorite_$id',
//             builder: (controller) {
//               final isFav = controller.isTemplateFavorite(id);
//               return Icon(
//                 isFav ? Icons.favorite : Icons.favorite_border,
//                 size: size,
//                 color: isFav ? AppColors.red400 : AppColors.gray400,
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _ModernCategoryFilterChip extends StatelessWidget {
//   final String label;
//   final Color color;
//   final bool isSelected;
//   final VoidCallback onTap;

//   const _ModernCategoryFilterChip({
//     required this.label,
//     required this.color,
//     required this.isSelected,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.transparent,
//       borderRadius: BorderRadius.circular(20),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(20),
//         onTap: onTap,
//         splashColor: color.withOpacity(0.1),
//         highlightColor: color.withOpacity(0.05),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//           decoration: BoxDecoration(
//             color: isSelected
//                 ? color.withOpacity(0.15)
//                 : Get.theme.colorScheme.surfaceContainerHigh,
//             borderRadius: BorderRadius.circular(20),
//             border: isSelected ? Border.all(color: color, width: 1.5) : null,
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 6,
//                 height: 6,
//                 decoration: BoxDecoration(
//                   color: isSelected ? color : color.withOpacity(0.6),
//                   shape: BoxShape.circle,
//                 ),
//               ),
//               const SizedBox(width: 6),
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w500,
//                   color: isSelected
//                       ? color
//                       : Get.theme.colorScheme.onSurface.withOpacity(0.8),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
