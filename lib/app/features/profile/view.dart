import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cardmaker/app/features/auth/auth_wrapper.dart';
import 'package:cardmaker/app/features/profile/controller.dart';
import 'package:cardmaker/app/routes/app_routes.dart';
import 'package:cardmaker/app/settings/view.dart';
import 'package:cardmaker/core/values/app_colors.dart';
import 'package:cardmaker/models/card_template.dart';
import 'package:cardmaker/services/auth_service.dart';
import 'package:cardmaker/widgets/common/template_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class ProfileTab extends StatelessWidget {
  bool get isLoggedIn =>
      Get.find<AuthService>().user != null ||
      Get.find<AuthService>().isSkipped.value;
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AnimatedSwitcher(
        duration: Duration(milliseconds: 1000),
        child: isLoggedIn ? ProfilePage() : AuthWrapper(),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 150.0,
                floating: false,
                // pinned: true,
                snap: false,
                // backgroundColor: Colors.white,
                // elevation: 1,
                // surfaceTintColor: Colors.white,
                // leading: IconButton(
                //   icon: const Icon(
                //     Icons.arrow_back_ios_new,
                //     size: 20,
                //     color: Colors.black87,
                //   ),
                //   onPressed: () => Get.back(),
                // ),
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildUserHeader(controller),
                  // titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                  // centerTitle: false,
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Get.theme.colorScheme.surfaceContainerHighest,

                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: TabBar(
                      dividerHeight: 0,
                      controller: controller.tabController,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Get.theme.colorScheme.primary,
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorPadding: const EdgeInsets.symmetric(vertical: 0),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey.shade600,
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
            ];
          },
          body: TabBarView(
            controller: controller.tabController,
            children: [
              _buildDraftsTab(controller),
              _buildFavoritesTab(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeader(ProfileController controller) {
    final user = controller.authService.user;

    final isGuest = user == null || controller.authService.isSkipped.value;

    return Container(
      // color: Colors.red,
      padding: const EdgeInsets.only(
        // top: kToolbarHeight + 40,
        left: 16,
        right: 16,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.blue400Light,
            child: user?.photoURL != null
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: user?.photoURL ?? "",
                      fit: BoxFit.cover,
                      width: 56,
                      height: 56,
                      placeholder: (context, url) => _buildShimmerPlaceholder(),
                      errorWidget: (context, url, error) => Icon(
                        Icons.person,
                        size: 28,
                        color: AppColors.blue400Light,
                      ),
                    ),
                  )
                : Icon(Icons.person),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user?.displayName ?? 'Guest User',
                  style: const TextStyle(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (user?.email != null)
                  Text(
                    user!.email!,
                    style: Get.theme.textTheme.labelSmall?.copyWith(
                      color: Get.theme.hintColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (isGuest)
            ElevatedButton(
              onPressed: () {
                Get.toNamed(Routes.auth);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),

                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: const Text(
                'Login',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            )
          else
            IconButton(
              icon: Icon(
                Icons.settings_outlined,
                color: Colors.grey.shade700,
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
      onRefresh: () async {
        await controller.refreshDrafts();
      },
      child: Obx(() {
        // Use allDrafts instead of just drafts
        if (controller.isDraftsLoading.value && controller.allDrafts.isEmpty) {
          return buildLoading();
        }

        if (controller.hasDraftsError.value && controller.allDrafts.isEmpty) {
          return _buildErrorState('Failed to load drafts', () async {
            await controller.refreshDrafts();
            await controller.loadLocalDrafts();
          });
        }

        if (controller.allDrafts.isEmpty) {
          return _buildEmptyState(
            'No drafts yet',
            'Create and save your projects to see them here',
            Icons.drafts_outlined,
          );
        }

        return Column(
          children: [
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification.metrics.pixels >=
                          notification.metrics.maxScrollExtent &&
                      !controller.isDraftsLoading.value &&
                      controller.hasMoreDrafts.value) {
                    debugPrint(
                      'Drafts scroll within 100px of bottom: loading more...',
                    );
                    controller.loadMoreDrafts();
                  }
                  return false;
                },
                child: _buildStaggeredTemplateGrid(
                  controller.allDrafts,
                  null,
                  isDrafts: true,
                  isLoading: controller.isDraftsLoading.value,
                  hasMore: controller.hasMoreDrafts.value,
                  onDelete: controller.deleteDraft,
                  onEdit: (template) => _editDraft(template),
                  onBackup: controller.backupDraft, // Add this line
                  isBackedUp: (template) => controller.isBackedUp(
                    template,
                  ), // Changed from isLocalDraft
                ),
              ),
            ),
          ],
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
            null,
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
    ScrollController? scrollController, {
    required bool isDrafts,
    required bool isLoading,
    required bool hasMore,
    Function(String)? onDelete,
    Function(CardTemplate)? onEdit,
    Function(CardTemplate)? onBackup, // Add backup callback
    required bool Function(CardTemplate)
    isBackedUp, // Changed from isLocalDraft
  }) {
    return CustomScrollView(
      controller: scrollController,
      cacheExtent: 500,
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
              return DraftCard(
                key: ValueKey('draft-${template.id}-$index'),
                template: template,
                isDraft: isDrafts,
                isBackedUp: isBackedUp(template), // Changed parameter
                onTap: () => onEdit?.call(template),
                onDelete: () => _showDeleteDialog(
                  template.id,
                  onDelete,
                  isBackedUp(template), // Changed parameter
                ),
                onBackup: onBackup != null
                    ? () => onBackup(template)
                    : null, // Add backup callback
              );
            },
          ),
        ),
        if (isLoading && hasMore)
          SliverToBoxAdapter(child: buildLoading("Loading more drafts...")),
      ],
    );
  }
  // Widget _buildStaggeredTemplateGrid(
  //   List<CardTemplate> templates,
  //   ScrollController? scrollController, {
  //   required bool isDrafts,
  //   required bool isLoading,
  //   required bool hasMore,
  //   Function(String)? onDelete,
  //   Function(CardTemplate)? onEdit,
  //   required bool Function(CardTemplate) isLocalDraft, // Add this parameter
  // }) {
  //   return CustomScrollView(
  //     controller: scrollController,
  //     cacheExtent: 500,
  //     physics: const AlwaysScrollableScrollPhysics(),
  //     slivers: [
  //       SliverPadding(
  //         padding: const EdgeInsets.all(12),
  //         sliver: SliverMasonryGrid.count(
  //           crossAxisCount: 2,
  //           mainAxisSpacing: 12,
  //           crossAxisSpacing: 12,
  //           childCount: templates.length,
  //           itemBuilder: (context, index) {
  //             final template = templates[index];
  //             return DraftCard(
  //               key: ValueKey('draft-${template.id}-$index'),
  //               template: template,
  //               isDraft: isDrafts,
  //               isLocal: isLocalDraft(template), // Pass local status
  //               onTap: () => onEdit?.call(template),
  //               onDelete: () => _showDeleteDialog(
  //                 template.id,
  //                 onDelete,
  //                 isLocalDraft(template),
  //               ), // Update this
  //             );
  //           },
  //         ),
  //       ),
  //       if (isLoading && hasMore)
  //         SliverToBoxAdapter(child: buildLoading("Loading more drafts...")),
  //     ],
  //   );
  // }

  Widget buildLoading([String? message = "Loading templates..."]) {
    return Align(
      alignment: Alignment.center, // or .topCenter, .centerLeft, etc.
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Get.theme.colorScheme.shadow.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // 🔑 keeps it tight
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(
              message!,
              style: Get.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteTemplateGrid(
    List<CardTemplate> templates,
    ScrollController? scrollController, {
    required bool isLoading,
    required bool hasMore,
    Function(String)? onRemoveFromFavorites,
    Function(CardTemplate)? onEdit,
  }) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      cacheExtent: 1000,
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
              return TemplateCard(
                key: ValueKey('fav-${template.id}-$index'),
                template: template,
                onTap: () => onEdit?.call(template),
                favoriteButton: FavoriteButton(
                  isFav: true,
                  onTap: () => _showRemoveFromFavoritesDialog(
                    template.id,
                    onRemoveFromFavorites,
                  ),
                ),
              );
            },
          ),
        ),
        if (isLoading && hasMore)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Center(child: buildLoading("Loading more...")),
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
    Get.toNamed(Routes.editor, arguments: template);
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

  void _showDeleteDialog(
    String draftId,
    Function(String)? onDelete,
    bool isBackedUp,
  ) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          isBackedUp ? 'Delete Draft' : 'Delete Local Draft',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: Text(
          isBackedUp
              ? 'Are you sure you want to delete this draft from cloud? This action cannot be undone.'
              : 'Are you sure you want to delete this local draft? This action cannot be undone.',
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
              backgroundColor: isBackedUp
                  ? Colors.red.shade600
                  : Colors.orange.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Text(
              isBackedUp ? 'Delete' : 'Delete Local',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class DraftCard extends StatelessWidget {
  final CardTemplate template;
  final bool isDraft;
  final bool isBackedUp; // Changed from isLocal to isBackedUp
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onBackup; // Add backup callback

  const DraftCard({
    super.key,
    required this.template,
    required this.isDraft,
    required this.isBackedUp, // Changed parameter
    required this.onTap,
    this.onDelete,
    this.onBackup, // Add backup callback
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

              // Backup status icon in top-left corner
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(
                    isBackedUp ? Icons.cloud_done : Icons.cloud_off,
                    size: 14,
                    color: isBackedUp ? Colors.green : Colors.orange,
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
                      } else if (value == 'backup' && onBackup != null) {
                        onBackup?.call();
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
                      if (!isBackedUp) // Only show backup option if not backed up
                        PopupMenuItem(
                          value: 'backup',
                          child: Row(
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 16,
                                color: Colors.blue,
                              ),
                              SizedBox(width: 8),
                              Text('Backup Now'),
                            ],
                          ),
                        ),
                      PopupMenuItem(
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        template.name,
                        style: Get.textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _formatDate(template.updatedAt ?? template.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Get.theme.hintColor,
                      ),
                    ),
                  ],
                ),

                // Backup status text
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail() {
    if (template.thumbnailUrl != null && template.thumbnailUrl!.isNotEmpty) {
      if (template.thumbnailUrl!.startsWith("http")) {
        return CachedNetworkImage(
          imageUrl: template.thumbnailUrl!,
          fit: BoxFit.contain,
          placeholder: (context, url) => _buildShimmerPlaceholder(),
          errorWidget: (context, url, error) => _buildPlaceholder(),
          fadeInDuration: const Duration(milliseconds: 300),
          fadeOutDuration: const Duration(milliseconds: 300),
        );
      } else {
        return Image.file(
          File(template.thumbnailUrl!),
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        );
      }
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
        return difference.inMinutes < 1
            ? 'just now'
            : '${difference.inMinutes} min ago';
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

class FavoriteButton extends StatelessWidget {
  final bool isFav;
  final double size;
  final VoidCallback onTap;

  const FavoriteButton({
    super.key,
    required this.isFav,
    required this.onTap,
    this.size = 18,
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
          child: Icon(
            isFav ? Icons.favorite : Icons.favorite_border,
            size: size,
            color: isFav ? AppColors.red400 : AppColors.gray400,
          ),
        ),
      ),
    );
  }
}
