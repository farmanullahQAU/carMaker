import 'package:cardmaker/app/features/home/category_templates/controller.dart';
import 'package:cardmaker/core/values/app_colors.dart';
import 'package:cardmaker/models/card_template.dart';
import 'package:cardmaker/widgets/common/template_card.dart';
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
      // leading: Container(
      //   margin: const EdgeInsets.all(8),
      //   decoration: BoxDecoration(
      //     color: Get.theme.colorScheme.surfaceBright,
      //     borderRadius: BorderRadius.circular(12),
      //     boxShadow: [
      //       BoxShadow(
      //         color: Colors.black.withOpacity(0.08),
      //         blurRadius: 8,
      //         offset: const Offset(0, 2),
      //       ),
      //     ],
      //   ),
      //   child: IconButton(
      //     icon: const Icon(
      //       Icons.arrow_back_ios_rounded,
      //       // color: Color(0xFF374151),
      //       size: 20,
      //     ),
      //     onPressed: () => Get.back(),
      //   ),
      // ),
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
                itemBuilder: (context, index) {
                  final template = controller.templates[index];
                  return TemplateCard(
                    template: template,
                    key: ValueKey('template_${template.id}'), // Add this
                    // isFavorite: controller.isTemplateFavorite(template.id),
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
