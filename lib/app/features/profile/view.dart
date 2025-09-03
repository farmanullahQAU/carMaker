import 'package:cached_network_image/cached_network_image.dart';
import 'package:cardmaker/app/features/auth/auth_wrapper.dart';
import 'package:cardmaker/app/features/profile/controller.dart';
import 'package:cardmaker/app/routes/app_routes.dart';
import 'package:cardmaker/app/settings/view.dart';
import 'package:cardmaker/core/values/app_colors.dart';
import 'package:cardmaker/models/card_template.dart';
import 'package:cardmaker/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class ProfileTab extends StatelessWidget {
  bool get isLoggedIn => Get.find<AuthService>().user != null;
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return isLoggedIn ? ProfilePage() : AuthWrapper();
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,

        // backgroundColor: Colors.white,
        backgroundColor: AppColors.brandingLight.withValues(alpha: 0.05),

        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Get.theme.colorScheme.surface,
            ),
            child: TabBar(
              dividerColor: Colors.transparent,
              controller: controller.tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Get.theme.colorScheme.primaryContainer,
              ),
              splashBorderRadius: BorderRadius.circular(25),
              indicatorSize: TabBarIndicatorSize.tab,
              unselectedLabelColor: Colors.grey.shade500,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'My Drafts'),
                Tab(text: 'Favorites'),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildUserHeader(controller),
          Expanded(
            child: TabBarView(
              controller: controller.tabController,
              children: [
                _buildDraftsTab(controller),
                _buildFavoritesTab(controller),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader(ProfileController controller) {
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      decoration: BoxDecoration(
        // color: Colors.white,
        color: AppColors.brandingLight.withValues(alpha: 0.05),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blue.shade50,
            child: user?.photoURL != null
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: user!.photoURL!,
                      fit: BoxFit.cover,
                      width: 64,
                      height: 64,
                      placeholder: (context, url) => _buildShimmerPlaceholder(),
                      errorWidget: (context, url, error) => Icon(
                        Icons.person,
                        size: 32,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  )
                : Icon(Icons.person, size: 32, color: Colors.blue.shade600),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'Anonymous User',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (user?.email != null)
                  Text(
                    user!.email!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: Colors.black54,
              size: 24,
            ),
            onPressed: () {
              Get.to(() => SettingsPage());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDraftsTab(ProfileController controller) {
    return RefreshIndicator(
      color: Colors.blue.shade600,
      backgroundColor: Colors.white,
      onRefresh: controller.refreshDrafts,
      child: Obx(() {
        if (controller.isDraftsLoading.value && controller.drafts.isEmpty) {
          return buildLoading();
        }

        if (controller.hasDraftsError.value && controller.drafts.isEmpty) {
          return _buildErrorState(
            'Failed to load drafts',
            controller.refreshDrafts,
          );
        }

        if (controller.drafts.isEmpty) {
          return _buildEmptyState(
            'No drafts yet',
            'Create and save your projects to see them here',
            Icons.drafts_outlined,
          );
        }

        return _buildStaggeredTemplateGrid(
          controller.drafts,
          controller.draftsScrollController,
          isDrafts: true,
          isLoading: controller.isDraftsLoading.value,
          hasMore: controller.hasMoreDrafts.value,
          onDelete: controller.deleteDraft,
          onEdit: (template) => _editDraft(template),
        );
      }),
    );
  }

  Widget _buildFavoritesTab(ProfileController controller) {
    return RefreshIndicator(
      color: Colors.blue.shade600,
      backgroundColor: Colors.white,
      onRefresh: controller.refreshFavorites,
      child: Obx(() {
        if (controller.isFavoritesLoading.value &&
            controller.favorites.isEmpty) {
          return buildLoading();
        }

        if (controller.hasFavoritesError.value &&
            controller.favorites.isEmpty) {
          return _buildErrorState(
            'Failed to load favorites',
            controller.refreshFavorites,
          );
        }

        if (controller.favorites.isEmpty) {
          return _buildEmptyState(
            'No favorites yet',
            'Add templates to favorites to see them here',
            Icons.favorite_outline,
          );
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            print(controller.hasMoreFavorites.value);
            if (notification.metrics.pixels >=
                    notification.metrics.maxScrollExtent - 100 &&
                !controller.isFavoritesLoading.value &&
                controller.hasMoreFavorites.value) {
              debugPrint(
                'Favorites scroll within 100px of bottom: loading more...',
              );
              controller.loadMoreFavorites();
            }
            return false; // Allow other listeners to process the notification
          },
          child: _buildFavoriteTemplateGrid(
            controller.favorites,
            null, // Remove ScrollController
            isLoading: controller.isFavoritesLoading.value,
            hasMore: controller.hasMoreFavorites.value,
            onRemoveFromFavorites: controller.removeFromFavorites,
            onEdit: (template) => _openTemplate(template),
          ),
        );
      }),
    );
  }

  Widget _buildStaggeredTemplateGrid(
    List<CardTemplate> templates,
    ScrollController scrollController, {
    required bool isDrafts,
    required bool isLoading,
    required bool hasMore,
    Function(String)? onDelete,
    Function(CardTemplate)? onEdit,
  }) {
    return CustomScrollView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(12),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              return _ProfessionalTemplateCard(
                template: template,
                isDraft: isDrafts,
                onTap: () => onEdit?.call(template),
                onDelete: () => _showDeleteDialog(template.id, onDelete),
              );
            },
          ),
        ),
        if (isLoading && hasMore) SliverToBoxAdapter(child: buildLoading()),
      ],
    );
  }

  Widget buildLoading() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Text(
                'Loading templates...',
                style: Get.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteTemplateGrid(
    List<CardTemplate> templates,
    ScrollController? scrollController, { // Made nullable
    required bool isLoading,
    required bool hasMore,
    Function(String)? onRemoveFromFavorites,
    Function(CardTemplate)? onEdit,
  }) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      cacheExtent: 1000, // Preload images for better performance
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(12),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              return _FavoriteTemplateCard(
                template: template,
                onTap: () => onEdit?.call(template),
                onRemoveFromFavorites: () => _showRemoveFromFavoritesDialog(
                  template.id,
                  onRemoveFromFavorites,
                ),
              );
            },
          ),
        ),
        if (isLoading && hasMore)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Center(child: buildLoading()),
            ),
          ),
      ],
    );
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

  Widget _buildErrorState(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.shade50,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.pink400Light,
              ),
              child: Icon(icon, size: 48, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _openTemplate(CardTemplate template) {
    Get.toNamed('/editor', arguments: template);
  }

  void _showRemoveFromFavoritesDialog(
    String templateId,
    Function(String)? onRemove,
  ) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Remove from Favorites',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: Text(
          'Are you sure you want to remove this template from your favorites?',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              onRemove?.call(templateId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text(
              'Remove',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _editDraft(CardTemplate template) {
    Get.toNamed(Routes.editor, arguments: template);
  }

  void _showDeleteDialog(String draftId, Function(String)? onDelete) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Delete Draft',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: Text(
          'Are you sure you want to delete this draft? This action cannot be undone.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              onDelete?.call(draftId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfessionalTemplateCard extends StatelessWidget {
  final CardTemplate template;
  final bool isDraft;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _ProfessionalTemplateCard({
    required this.template,
    required this.isDraft,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.brandingLight.withValues(alpha: 0.02),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: InkWell(
                  onTap: onTap,
                  radius: 12,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                        bottom: Radius.circular(8),
                      ),
                      child: AspectRatio(
                        aspectRatio: template.aspectRatio,
                        child: _buildThumbnail(),
                      ),
                    ),
                  ),
                ),
              ),
              if (isDraft)
                Positioned(
                  top: 0,
                  right: 0,
                  child: PopupMenuButton<String>(
                    icon: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.more_horiz,
                        color: Colors.black87,
                        size: 18,
                      ),
                    ),
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDelete?.call();
                      } else if (value == 'edit') {
                        onTap();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(template.updatedAt ?? template.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail() {
    if (template.thumbnailUrl != null && template.thumbnailUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: template.thumbnailUrl!,
        fit: BoxFit.contain,
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} min ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _FavoriteTemplateCard extends StatelessWidget {
  final CardTemplate template;
  final VoidCallback onTap;
  final VoidCallback? onRemoveFromFavorites;

  const _FavoriteTemplateCard({
    required this.template,
    required this.onTap,
    this.onRemoveFromFavorites,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.brandingLight.withValues(alpha: 0.06),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: InkWell(
                  onTap: onTap,
                  radius: 12,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                        bottom: Radius.circular(8),
                      ),
                      child: AspectRatio(
                        aspectRatio: template.aspectRatio,
                        child: _buildThumbnail(),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: onRemoveFromFavorites,
                  child: Container(
                    // padding: const EdgeInsets.all(6),
                    // decoration: BoxDecoration(
                    //   shape: BoxShape.circle,
                    //   color: Colors.white,
                    //   boxShadow: [
                    //     BoxShadow(
                    //       color: Colors.grey.withOpacity(0.2),
                    //       blurRadius: 4,
                    //       offset: const Offset(0, 2),
                    //     ),
                    //   ],
                    // ),
                    child: Icon(
                      Icons.favorite,
                      color: AppColors.red400,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(template.updatedAt ?? template.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail() {
    if (template.thumbnailUrl != null && template.thumbnailUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: template.thumbnailUrl!,
        fit: BoxFit.contain,
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} min ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
