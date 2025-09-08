import 'package:cardmaker/app/features/editor/text_editor/fonts_search/controller.dart';
import 'package:cardmaker/core/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class FontSearchPage extends StatefulWidget {
  final String currentSelectedFont;
  final Function(String) onFontSelected;

  const FontSearchPage({
    super.key,
    required this.currentSelectedFont,
    required this.onFontSelected,
  });

  @override
  State<FontSearchPage> createState() => _FontSearchPageState();
}

class _FontSearchPageState extends State<FontSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FontSearchController _fontController = Get.put(FontSearchController());

  @override
  void initState() {
    super.initState();
    _fontController.initialize(widget.currentSelectedFont);
  }

  @override
  void dispose() {
    _searchController.dispose();
    Get.delete<FontSearchController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(child: _buildFontList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      // decoration: BoxDecoration(
      //   color: Get.theme.colorScheme.surfaceContainerHigh,
      //   border: Border(
      //     bottom: BorderSide(
      //       color: Get.theme.colorScheme.outline.withOpacity(0.1),
      //       width: 1,
      //     ),
      //   ),
      // ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: Get.theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose Font',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Get.theme.colorScheme.onSurface,
                    letterSpacing: -0.3,
                  ),
                ),
                GetBuilder<FontSearchController>(
                  builder: (controller) {
                    return Text(
                      '${controller.displayedFonts.length} fonts available',
                      style: TextStyle(
                        fontSize: 12,
                        color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Quick access to current font
          GetBuilder<FontSearchController>(
            builder: (controller) {
              if (controller.selectedFont.isEmpty) {
                return const SizedBox.shrink();
              }

              return GestureDetector(
                onTap: () {
                  widget.onFontSelected(controller.selectedFont);
                  Get.back();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.branding,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_rounded, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        controller.selectedFont,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Get.theme.colorScheme.outline.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => _fontController.searchFonts(value),
        style: TextStyle(
          fontSize: 16,
          // color: Get.theme.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Search fonts by name...',
          hintStyle: TextStyle(fontWeight: FontWeight.w400),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.search_rounded,
              size: 24,
              color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          suffixIcon: GetBuilder<FontSearchController>(
            builder: (controller) {
              return controller.searchQuery.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        _fontController.clearSearch();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          Icons.clear_rounded,
                          size: 24,
                          color: Get.theme.colorScheme.onSurface.withOpacity(
                            0.6,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildFontList() {
    return GetBuilder<FontSearchController>(
      builder: (controller) {
        if (controller.isLoading.isTrue && controller.displayedFonts.isEmpty) {
          return _buildLoadingState();
        }

        if (controller.displayedFonts.isEmpty &&
            controller.searchQuery.isNotEmpty) {
          return _buildEmptyState();
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels >
                scrollInfo.metrics.maxScrollExtent * 0.8) {
              controller.loadMoreFonts();
            }
            return false;
          },
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            physics: const BouncingScrollPhysics(),
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemCount:
                controller.displayedFonts.length +
                (controller.hasMoreFonts.isTrue ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.displayedFonts.length) {
                return _buildLoadingIndicator();
              }

              final font = controller.displayedFonts[index];
              final isSelected = font == controller.selectedFont;

              return _buildFontItem(
                font: font,
                isSelected: isSelected,
                onTap: () {
                  controller.selectFont(font);
                  widget.onFontSelected(font);
                  Get.back();
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFontItem({
    required String font,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.branding.withOpacity(0.1),
                    AppColors.branding.withOpacity(0.05),
                  ],
                )
              : null,
          color: isSelected ? null : Get.theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: AppColors.branding.withOpacity(0.3), width: 1)
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    font,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.branding
                          : Get.theme.colorScheme.onSurface,
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'The quick brown fox jumps',
                    style: GoogleFonts.getFont(
                      font,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Get.theme.colorScheme.onSurface.withOpacity(0.8),
                      letterSpacing: 0.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.branding : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.branding
                      : Get.theme.colorScheme.outline.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check_rounded, size: 18, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.branding),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading fonts...',
            style: TextStyle(
              fontSize: 16,
              color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.font_download_off_rounded,
            size: 64,
            color: Get.theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No fonts found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Get.theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: TextStyle(
              fontSize: 14,
              color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.branding),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Loading more fonts...',
            style: TextStyle(
              fontSize: 13,
              color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
