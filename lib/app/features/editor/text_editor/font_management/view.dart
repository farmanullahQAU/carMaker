import 'package:cardmaker/core/values/app_colors.dart';
import 'package:cardmaker/services/urdu_font_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';

class FontManagementPage extends StatefulWidget {
  final Function(String)? onFontSelected;
  final String? currentSelectedFont;

  const FontManagementPage({
    super.key,
    this.onFontSelected,
    this.currentSelectedFont,
  });

  @override
  State<FontManagementPage> createState() => _FontManagementPageState();
}

class _FontManagementPageState extends State<FontManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  final RxString _searchQuery = ''.obs;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FontManagementController());

    return Scaffold(
      backgroundColor: Get.theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(controller),
            _buildSearchBar(),
            Expanded(child: _buildFontList(controller)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(FontManagementController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                  'Font Management',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Get.theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Download and manage Urdu fonts',
                  style: TextStyle(
                    fontSize: 12,
                    color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => controller.isLoadingRemoteFonts.value
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : GestureDetector(
                    onTap: () => controller.loadRemoteFonts(forceRefresh: true),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.branding,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.refresh_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Get.theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          _searchQuery.value = value;
        },
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Get.theme.colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: 'Search fonts...',
          hintStyle: TextStyle(
            color: Get.theme.colorScheme.onSurface.withOpacity(0.5),
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.search_rounded,
              size: 20,
              color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          suffixIcon: Obx(() {
            if (_searchQuery.value.isEmpty) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.all(12),
              child: GestureDetector(
                onTap: () {
                  _searchController.clear();
                  _searchQuery.value = '';
                },
                child: Icon(
                  Icons.clear_rounded,
                  size: 20,
                  color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            );
          }),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildFontList(FontManagementController controller) {
    return Obx(() {
      // Show loading only on initial load, not when fonts are already loaded
      if (controller.isLoadingRemoteFonts.value &&
          controller.remoteFonts.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.remoteFonts.isEmpty &&
          !controller.isLoadingRemoteFonts.value) {
        return _buildEmptyState();
      }

      // Filter fonts based on search query (reactive)
      final searchQuery = _searchQuery.value;
      final filteredFonts = searchQuery.isEmpty
          ? controller.remoteFonts
          : controller.remoteFonts.where((font) {
              return font.displayName.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ) ||
                  font.description.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  );
            }).toList();

      if (filteredFonts.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
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

      return ListView.separated(
        padding: const EdgeInsets.all(16),
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemCount: filteredFonts.length,
        itemBuilder: (context, index) {
          final font = filteredFonts[index];
          return _buildFontCard(controller, font);
        },
      );
    });
  }

  Widget _buildFontCard(FontManagementController controller, UrduFont font) {
    final isSelected = font.family == widget.currentSelectedFont;

    return GestureDetector(
      onTap: () async {
        if (widget.onFontSelected == null) return;

        if (!font.isLocal) {
          final bool success = await controller.downloadFont(font);
          if (!success) return;
        }

        widget.onFontSelected!(font.family);
        Get.back();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
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
              ? Border.all(color: AppColors.branding.withOpacity(0.3), width: 2)
              : Border.all(
                  color: font.isLocal
                      ? Colors.green.withOpacity(0.3)
                      : Get.theme.colorScheme.outline.withOpacity(0.1),
                  width: 1,
                ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        font.displayName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Get.theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        font.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Get.theme.colorScheme.onSurface.withOpacity(
                            0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildFontStatus(font),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                font.previewText,
                style: UrduFontService.getTextStyle(
                  fontFamily: font.family,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Get.theme.colorScheme.onSurface.withOpacity(0.8),
                ),
                textDirection: font.isRTL
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildCategoryChip(font.category),
                const Spacer(),
                if (isSelected)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.branding,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  )
                else if (font.remoteFont != null) ...[
                  Text(
                    font.remoteFont!.formattedSize,
                    style: TextStyle(
                      fontSize: 12,
                      color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(controller, font),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontStatus(UrduFont font) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: font.isLocal
            ? Colors.green.withOpacity(0.1)
            : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            font.isLocal
                ? Icons.check_circle_rounded
                : Icons.cloud_download_rounded,
            size: 12,
            color: font.isLocal ? Colors.green : Colors.blue,
          ),
          const SizedBox(width: 4),
          Text(
            font.isLocal ? 'Downloaded' : 'Available',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: font.isLocal ? Colors.green : Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(UrduFontCategory category) {
    Color color;
    switch (category) {
      case UrduFontCategory.traditional:
        color = Colors.blue;
        break;
      case UrduFontCategory.modern:
        color = Colors.green;
        break;
      case UrduFontCategory.contemporary:
        color = Colors.purple;
        break;
      case UrduFontCategory.decorative:
        color = Colors.orange;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        category.displayName,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildActionButton(
    FontManagementController controller,
    UrduFont font,
  ) {
    return Obx(() {
      if (controller.downloadProgress.containsKey(font.family)) {
        // Show download progress
        return SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            value: controller.downloadProgress[font.family],
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.branding),
          ),
        );
      }

      if (font.isLocal) {
        // Show delete button
        return GestureDetector(
          onTap: () => _showDeleteConfirmation(controller, font),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.delete_rounded,
              size: 16,
              color: Colors.red,
            ),
          ),
        );
      } else {
        // Show download button
        return GestureDetector(
          onTap: () => controller.downloadFont(font),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.branding,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.download_rounded,
              size: 16,
              color: Colors.white,
            ),
          ),
        );
      }
    });
  }

  void _showDeleteConfirmation(
    FontManagementController controller,
    UrduFont font,
  ) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Get.theme.colorScheme.surface,
        title: Text(
          'Delete Font',
          style: TextStyle(
            color: Get.theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${font.displayName}"? This will free up ${font.remoteFont?.formattedSize ?? '0 B'} of storage.',
          style: TextStyle(color: Get.theme.colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteFont(font);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
            'No Remote Fonts Available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Get.theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check your internet connection and try again',
            style: TextStyle(
              fontSize: 14,
              color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
