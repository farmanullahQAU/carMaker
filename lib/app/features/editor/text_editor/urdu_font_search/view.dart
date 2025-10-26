import 'package:cardmaker/core/values/app_colors.dart';
import 'package:cardmaker/services/urdu_font_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UrduFontSearchPage extends StatefulWidget {
  final String currentSelectedFont;
  final Function(String) onFontSelected;

  const UrduFontSearchPage({
    super.key,
    required this.currentSelectedFont,
    required this.onFontSelected,
  });

  @override
  State<UrduFontSearchPage> createState() => _UrduFontSearchPageState();
}

class _UrduFontSearchPageState extends State<UrduFontSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<UrduFont> _filteredFonts = UrduFontService.allFonts;
  String _searchQuery = '';
  final Map<String, bool> _downloadingFonts = {};

  @override
  void initState() {
    super.initState();
    _filteredFonts = UrduFontService.allFonts;
    _loadRemoteFonts();
  }

  Future<void> _loadRemoteFonts() async {
    try {
      // Load fonts efficiently (first 50, then remaining in background)
      await UrduFontService.loadRemoteFonts(
        autoDownload: true,
        limit: 50, // Show first 50 fonts immediately
      );

      if (mounted) {
        setState(() {
          _filteredFonts = UrduFontService.allFonts;
        });
      }

      // Load remaining fonts in background
      _loadMoreFontsInBackground();
    } catch (e) {
      print('Error loading fonts: $e');
      if (mounted) {}
    }
  }

  Future<void> _loadMoreFontsInBackground() async {
    // Load more fonts in background without blocking UI
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _filteredFonts = UrduFontService.allFonts;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchFonts(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredFonts = UrduFontService.allFonts;
      } else {
        _filteredFonts = UrduFontService.searchFonts(query);
      }
    });
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
                  'Urdu Fonts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Get.theme.colorScheme.onSurface,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  '${_filteredFonts.length} Urdu fonts available',
                  style: TextStyle(
                    fontSize: 12,
                    color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          // Quick access to current font
          if (widget.currentSelectedFont.isNotEmpty)
            GestureDetector(
              onTap: () {
                widget.onFontSelected(widget.currentSelectedFont);
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
                      widget.currentSelectedFont,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
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
        onChanged: _searchFonts,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: 'Search Urdu fonts...',
          hintStyle: TextStyle(fontWeight: FontWeight.w400),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.search_rounded,
              size: 24,
              color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    _searchFonts('');
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.clear_rounded,
                      size: 24,
                      color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
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
    if (_filteredFonts.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      physics: const BouncingScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemCount: _filteredFonts.length,
      itemBuilder: (context, index) {
        final font = _filteredFonts[index];
        final isSelected = font.family == widget.currentSelectedFont;

        return _buildFontItem(
          font: font,
          isSelected: isSelected,
          onTap: () {
            widget.onFontSelected(font.family);
            Get.back();
          },
        );
      },
    );
  }

  Widget _buildFontItem({
    required UrduFont font,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
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
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: AppColors.branding.withOpacity(0.3), width: 1)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.branding.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Font Preview
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.surfaceContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                font.previewText,
                style: UrduFontService.getTextStyle(
                  fontFamily: font.family,
                  fontSize: 24,
                  color: Get.theme.colorScheme.onSurface,
                ),
                textDirection: font.isRTL
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            // Font Info
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
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? AppColors.branding
                              : Get.theme.colorScheme.onSurface,
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        font.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Get.theme.colorScheme.onSurface.withOpacity(
                            0.6,
                          ),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  font.category == UrduFontCategory.traditional
                                  ? Colors.blue.withOpacity(0.1)
                                  : font.category == UrduFontCategory.modern
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.purple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              font.category.displayName,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color:
                                    font.category ==
                                        UrduFontCategory.traditional
                                    ? Colors.blue
                                    : font.category == UrduFontCategory.modern
                                    ? Colors.green
                                    : Colors.purple,
                              ),
                            ),
                          ),
                          if (!font.isLocal && font.remoteFont != null) ...[
                            const SizedBox(width: 8),
                            _buildDownloadButton(font),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Selection Indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 36,
                  height: 36,
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
                      ? Icon(Icons.check_rounded, size: 20, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadButton(UrduFont font) {
    final isDownloading = _downloadingFonts[font.family] ?? false;

    if (isDownloading) {
      return SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.branding),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _downloadFont(font),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.branding.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: AppColors.branding.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.download_rounded, size: 12, color: AppColors.branding),
            const SizedBox(width: 4),
            Text(
              'Download',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.branding,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadFont(UrduFont font) async {
    if (font.isLocal || font.remoteFont == null) return;

    setState(() {
      _downloadingFonts[font.family] = true;
    });

    try {
      final bool success = await UrduFontService.downloadFont(font);

      if (success && mounted) {
        setState(() {
          _downloadingFonts[font.family] = false;
          _filteredFonts = UrduFontService.allFonts
              .where(
                (f) =>
                    _searchQuery.isEmpty ||
                    f.displayName.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
              )
              .toList();
        });

        Get.snackbar(
          'Success',
          '${font.displayName} downloaded successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        setState(() {
          _downloadingFonts[font.family] = false;
        });

        Get.snackbar(
          'Error',
          'Failed to download ${font.displayName}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      setState(() {
        _downloadingFonts[font.family] = false;
      });

      Get.snackbar(
        'Error',
        'Download failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
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
            'No Urdu fonts found',
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
}
