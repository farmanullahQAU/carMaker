import 'dart:math' as math;

import 'package:cardmaker/app/features/editor/editor_canvas.dart';
import 'package:cardmaker/app/features/home/controller.dart';
import 'package:cardmaker/stack_board/lib/src/stack_board_items/item_case/stack_text_case.dart';
import 'package:cardmaker/stack_board/lib/stack_items.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// --- ENHANCED DATA MODELS ---
class CategoryModel {
  final String id;
  final String name;
  final Color color;
  final IconData icon;
  final String? imagePath;

  CategoryModel({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    this.imagePath,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'color': color.value,
    'icon': icon.codePoint,
    'imagePath': imagePath,
  };

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    id: json['id'],
    name: json['name'],
    color: Color(json['color']),
    icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
    imagePath: json['imagePath'],
  );
}

class QuickAction {
  final String title;
  final IconData icon;
  final Color color;

  QuickAction({required this.title, required this.icon, required this.color});

  Map<String, dynamic> toJson() => {
    'title': title,
    'icon': icon.codePoint,
    'color': color.value,
  };

  factory QuickAction.fromJson(Map<String, dynamic> json) => QuickAction(
    title: json['title'],
    icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
    color: Color(json['color']),
  );
}

// --- Main Home Page Widget ---
class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());

    return Scaffold(
      backgroundColor: Get.theme.colorScheme.surface,
      body: PageView(
        controller: controller.pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: controller.onPageChanged,
        children: [
          const HomeTab(),
          EditorPage(),
          const PlaceholderPage(
            title: "My Designs",
            icon: Icons.palette_outlined,
          ),
          const PlaceholderPage(
            title: "Premium",
            icon: Icons.workspace_premium_outlined,
          ),
        ],
      ),
      bottomNavigationBar: Obx(() => _buildModernBottomNav()),
    );
  }

  Widget _buildModernBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Get.theme.colorScheme.shadow.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: NavigationBar(
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: controller.onBottomNavTap,
          height: 68,
          backgroundColor: Colors.transparent,
          elevation: 0,
          indicatorColor: Get.theme.colorScheme.primaryContainer,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            _ModernNavDestination(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home_rounded,
              label: 'Home',
            ),
            _ModernNavDestination(
              icon: Icons.grid_view_outlined,
              selectedIcon: Icons.grid_view_rounded,
              label: 'Templates',
            ),
            _ModernNavDestination(
              icon: Icons.palette_outlined,
              selectedIcon: Icons.palette,
              label: 'My Designs',
            ),
            _ModernNavDestination(
              icon: Icons.workspace_premium_outlined,
              selectedIcon: Icons.workspace_premium,
              label: 'Premium',
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernNavDestination extends NavigationDestination {
  _ModernNavDestination({
    required IconData icon,
    required IconData selectedIcon,
    required super.label,
  }) : super(
         icon: Icon(icon, size: 22, color: Get.theme.colorScheme.outline),
         selectedIcon: Icon(
           selectedIcon,
           size: 22,
           color: Get.theme.colorScheme.primary,
         ),
       );
}

// --- The Main Scrollable Home Tab ---
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildModernAppBar(),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const QuickActionsGrid(),
              const SizedBox(height: 20),
              const AIBanner(),
              const SizedBox(height: 20),
              const SectionTitle(title: 'Browse Categories', showSeeAll: true),
              const SizedBox(height: 12),
              const CategoriesList(),
              const SizedBox(height: 20),
              const SectionTitle(title: 'Featured Templates', showSeeAll: true),
              const SizedBox(height: 12),
              const HorizontalCardList(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  SliverAppBar _buildModernAppBar() {
    return SliverAppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Greetings, User!',
            style: Get.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Get.theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: IconButton(
            onPressed: () {},
            icon: Badge(
              backgroundColor: Get.theme.colorScheme.primary,
              child: Icon(
                Icons.notifications_none_rounded,
                color: Get.theme.colorScheme.onSurface,
                size: 24,
              ),
            ),
          ),
        ),
      ],
      pinned: false,
      floating: true,
      toolbarHeight: 84,
      backgroundColor: Get.theme.colorScheme.surface,
      elevation: 0,
    );
  }
}

// --- Modern UI Components ---
class SectionTitle extends StatelessWidget {
  final String title;
  final bool showSeeAll;

  const SectionTitle({super.key, required this.title, this.showSeeAll = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Get.theme.colorScheme.onSurface,
            ),
          ),
          if (showSeeAll)
            TextButton(
              onPressed: () {},
              child: Text(
                'See All',
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: Get.theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class QuickActionsGrid extends GetView<HomeController> {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemCount: controller.quickActions.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final action = controller.quickActions[index];
          return GestureDetector(
            onTap: () => controller.onQuickActionTap(action),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    color: action.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: action.color.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(action.icon, color: action.color, size: 30),
                ),
                const SizedBox(height: 8),
                Text(
                  action.title,
                  style: Get.textTheme.labelSmall?.copyWith(
                    color: Get.theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AIBanner extends StatelessWidget {
  const AIBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Get.theme.colorScheme.primary,
            Get.theme.colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Get.theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Design Studio',
                  style: Get.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Transform your ideas into stunning designs with AI.',
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: () => Get.find<HomeController>().onQuickActionTap(
                    QuickAction(
                      title: 'AI Generate',
                      icon: Icons.auto_awesome_outlined,
                      color: const Color(0xFF8B5CF6),
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Get.theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Try Now',
                    style: Get.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Icon(
            Icons.auto_awesome_rounded,
            size: 42,
            color: Colors.white.withOpacity(0.8),
          ),
        ],
      ),
    );
  }
}

class HorizontalCardList extends GetView<HomeController> {
  const HorizontalCardList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 200, // Fixed height for scroll area
          child: Obx(
            () => ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.featuredTemplates.length,
              itemBuilder: (context, index) {
                final template = controller.featuredTemplates[index];
                double cumulativeYOffset = 0.0; // Reset for each card

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: GestureDetector(
                    onTap: () => controller.onTemplateTap(template),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Responsive width: min of 40% screen width or 400px
                        final maxWidth = math.min(
                          constraints.maxWidth * 0.4,
                          400.0,
                        );
                        // Calculate scale to fit template within constraints
                        final scale = math.min(
                          maxWidth / template.width,
                          constraints.maxHeight / template.height,
                        );
                        // Canvas dimensions
                        final canvasWidth = template.width * scale;
                        final canvasHeight = template.height * scale;

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints.tightFor(
                              width: canvasWidth,
                              height: canvasHeight,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              clipBehavior: Clip.hardEdge,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  // Background image
                                  Positioned.fill(
                                    child: Image.asset(
                                      template.backgroundImage,
                                      fit: BoxFit.cover,
                                      alignment: Alignment.center,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                color: Colors.grey[300],
                                              ),
                                    ),
                                  ),
                                  // Template items
                                  ...template.items.expand((item) {
                                    final type = item['type'];
                                    final originalX =
                                        (item['offset']['dx'] as num)
                                            .toDouble();
                                    final originalY =
                                        (item['offset']['dy'] as num)
                                            .toDouble();
                                    double scaledX = originalX * scale;
                                    double scaledY = originalY * scale;
                                    scaledY += cumulativeYOffset;

                                    if (type == 'RowStackItem') {
                                      final rowItems =
                                          (item['content']['items'] as List)
                                              .map(
                                                (subItem) =>
                                                    subItem
                                                        as Map<String, dynamic>,
                                              )
                                              .toList();
                                      double totalWidth = 0.0;
                                      final List<Widget> rowWidgets = [];

                                      // Calculate total width for centering
                                      for (final subItem in rowItems) {
                                        if (subItem['type'] ==
                                            'StackTextItem') {
                                          final textItem =
                                              StackTextItem.fromJson(subItem);
                                          final scaledTextStyle =
                                              _getScaledTextStyle(
                                                textItem,
                                                scale,
                                              );
                                          final textWidth = _getTextWidth(
                                            text: textItem.content!.data ?? "",
                                            style: scaledTextStyle,
                                            hasShadow:
                                                textItem
                                                    .content!
                                                    .style!
                                                    .shadows
                                                    ?.isNotEmpty ??
                                                false,
                                          ).width;
                                          totalWidth += textWidth;
                                        }
                                      }

                                      // Starting x-position for centering
                                      double startX = item['isCentered']
                                          ? (canvasWidth - totalWidth) / 2
                                          : scaledX;

                                      // Build widgets for row items
                                      for (final subItem in rowItems) {
                                        if (subItem['type'] ==
                                            'StackTextItem') {
                                          final textItem =
                                              StackTextItem.fromJson(subItem);
                                          final scaledTextStyle =
                                              _getScaledTextStyle(
                                                textItem,
                                                scale,
                                              );
                                          final textSize = _getTextWidth(
                                            text: textItem.content!.data ?? "",
                                            style: scaledTextStyle,
                                            hasShadow:
                                                textItem
                                                    .content!
                                                    .style!
                                                    .shadows
                                                    ?.isNotEmpty ??
                                                false,
                                          );
                                          final maxTextHeight = textSize.height;
                                          if (rowItems.length == 1) {
                                            cumulativeYOffset += maxTextHeight;
                                          }

                                          rowWidgets.add(
                                            Positioned(
                                              left: textItem.isCentered
                                                  ? 0
                                                  : startX,
                                              right: textItem.isCentered
                                                  ? 0
                                                  : null,
                                              top: scaledY,
                                              child: StackTextCase(
                                                isFitted: false,
                                                item: textItem.copyWith(
                                                  content: textItem.content!
                                                      .copyWith(
                                                        style: scaledTextStyle,
                                                        textAlign:
                                                            _getTextAlign(
                                                              textItem
                                                                      .content!
                                                                      .textAlign
                                                                      ?.name ??
                                                                  "center",
                                                            ),
                                                      ),
                                                ),
                                              ),
                                            ),
                                          );
                                          startX += textSize.width;
                                        }
                                      }

                                      if (rowItems.length > 1) {
                                        cumulativeYOffset += rowItems
                                            .map((subItem) {
                                              if (subItem['type'] ==
                                                  'StackTextItem') {
                                                final textItem =
                                                    StackTextItem.fromJson(
                                                      subItem,
                                                    );
                                                final scaledTextStyle =
                                                    _getScaledTextStyle(
                                                      textItem,
                                                      scale,
                                                    );
                                                return _getTextWidth(
                                                  text:
                                                      textItem.content!.data ??
                                                      "",
                                                  style: scaledTextStyle,
                                                  hasShadow:
                                                      textItem
                                                          .content!
                                                          .style!
                                                          .shadows
                                                          ?.isNotEmpty ??
                                                      false,
                                                ).height;
                                              }
                                              return 0.0;
                                            })
                                            .reduce(math.max);
                                      }

                                      return rowWidgets;
                                    } else if (type == 'StackTextItem') {
                                      final textItem = StackTextItem.fromJson(
                                        item,
                                      );
                                      final scaledTextStyle =
                                          _getScaledTextStyle(textItem, scale);
                                      final textSize = _getTextWidth(
                                        text: textItem.content!.data ?? "",
                                        style: scaledTextStyle,
                                        hasShadow:
                                            textItem
                                                .content!
                                                .style!
                                                .shadows
                                                ?.isNotEmpty ??
                                            false,
                                      );
                                      final maxTextHeight = textSize.height;
                                      cumulativeYOffset += maxTextHeight;

                                      return [
                                        Positioned(
                                          left: textItem.isCentered
                                              ? 0
                                              : scaledX,
                                          right: textItem.isCentered ? 0 : null,
                                          top: scaledY,
                                          child: StackTextCase(
                                            isFitted: false,

                                            item: textItem.copyWith(
                                              content: textItem.content!
                                                  .copyWith(
                                                    style: scaledTextStyle,
                                                    textAlign: _getTextAlign(
                                                      textItem
                                                              .content!
                                                              .textAlign
                                                              ?.name ??
                                                          "center",
                                                    ),
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ];
                                    } else if (type == 'StackImageItem') {
                                      final path =
                                          item['content']['assetName'] ?? '';
                                      final originalWidth =
                                          (item['size']['width'] ?? 100)
                                              .toDouble();
                                      final originalHeight =
                                          (item['size']['height'] ?? 100)
                                              .toDouble();
                                      final scaledWidth = originalWidth * scale;
                                      final scaledHeight =
                                          originalHeight * scale;

                                      return [
                                        Positioned(
                                          left: item['isCentered']
                                              ? (canvasWidth - scaledWidth) / 2
                                              : scaledX,
                                          top: scaledY,
                                          child: SizedBox(
                                            width: scaledWidth,
                                            height: scaledHeight,
                                            child: Image.asset(
                                              path,
                                              fit: BoxFit.contain,
                                              alignment: Alignment.center,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Container(
                                                    color: Colors.grey[300],
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ];
                                    }
                                    return [const SizedBox.shrink()];
                                  }),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // Utility method to calculate scaled text style
  TextStyle _getScaledTextStyle(StackTextItem textItem, double scale) {
    final originalStyle = textItem.content!.style!;
    final scaledFontSize = (originalStyle.fontSize! * scale).clamp(8.0, 15.0);
    final scaledLetterSpacing = ((originalStyle.letterSpacing ?? 0.0) * scale)
        .clamp(-2.0, 8.0);
    final scaledShadows = originalStyle.shadows?.map((shadow) {
      return Shadow(
        offset: Offset(shadow.offset.dx * scale, shadow.offset.dy * scale),
        blurRadius: (shadow.blurRadius * scale).clamp(0.0, 10.0),
        color: shadow.color,
      );
    }).toList();

    return originalStyle.copyWith(
      fontSize: scaledFontSize,
      letterSpacing: scaledLetterSpacing,
      shadows: scaledShadows,
    );
  }

  // Utility method to calculate text dimensions
  Size _getTextWidth({
    required String text,
    required TextStyle style,
    required bool hasShadow,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(text: text.isEmpty ? " " : text, style: style),
      maxLines: null,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 300.0);

    // Account for shadow bounds if present
    double shadowWidth = 0.0;
    double shadowHeight = 0.0;
    if (hasShadow && style.shadows != null) {
      for (final shadow in style.shadows!) {
        shadowWidth = math.max(
          shadowWidth,
          shadow.offset.dx.abs() + shadow.blurRadius,
        );
        shadowHeight = math.max(
          shadowHeight,
          shadow.offset.dy.abs() + shadow.blurRadius,
        );
      }
    }

    return Size(
      (textPainter.width + shadowWidth * 2).clamp(10.0, 300.0),
      (textPainter.height + shadowHeight * 2).clamp(10.0, 100.0),
    );
  }

  // Utility method to parse text alignment
  TextAlign _getTextAlign(String alignment) {
    switch (alignment.toLowerCase()) {
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      case 'justify':
        return TextAlign.justify;
      default:
        return TextAlign.left;
    }
  }
}
//befor maks
// class HorizontalCardList extends GetView<HomeController> {
//   const HorizontalCardList({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(
//           height: 200, // Fixed height for scroll area
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             itemCount: controller.featuredTemplates.length,
//             itemBuilder: (context, index) {
//               final template = controller.featuredTemplates[index];
//               double cumulativeYOffset = 0.0; // Reset for each card

//               return Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 8),
//                 child: GestureDetector(
//                   onTap: () => controller.onTemplateTap(template),
//                   child: LayoutBuilder(
//                     builder: (context, constraints) {
//                       // Responsive width: min of 40% screen width or 400px
//                       final maxWidth = constraints.maxWidth * 0.4;
//                       // Calculate scale to fit template within constraints
//                       final scale = math.min(
//                         maxWidth / template.width,
//                         constraints.maxHeight / template.height,
//                       );
//                       // Canvas dimensions
//                       final canvasWidth = template.width * scale;
//                       final canvasHeight = template.height * scale;

//                       return Container(
//                         color: Colors.blueAccent,
//                         child: ConstrainedBox(
//                           constraints: BoxConstraints.tightFor(
//                             width: canvasWidth,
//                             height: canvasHeight,
//                           ),
//                           child: ClipRect(
//                             clipBehavior: Clip.hardEdge,
//                             child: Stack(
//                               clipBehavior:
//                                   Clip.none, // Stack clips via ClipRect
//                               children: [
//                                 // Background image
//                                 Positioned.fill(
//                                   child: Image.asset(
//                                     template.backgroundImage,
//                                     fit: BoxFit.contain,
//                                     alignment: Alignment.center,
//                                   ),
//                                 ),
//                                 // Template items
//                                 ...template.items.expand((item) {
//                                   final type = item['type'];
//                                   final originalX =
//                                       (item['offset']['dx'] as num).toDouble();
//                                   final originalY =
//                                       (item['offset']['dy'] as num).toDouble();
//                                   double scaledX = originalX * scale;
//                                   double scaledY = originalY * scale;
//                                   scaledY += cumulativeYOffset;

//                                   if (type == 'RowStackItem') {
//                                     final rowItems =
//                                         (item['content']['items'] as List)
//                                             .map(
//                                               (subItem) =>
//                                                   subItem
//                                                       as Map<String, dynamic>,
//                                             )
//                                             .toList();
//                                     double totalWidth = 0.0;
//                                     final List<Widget> rowWidgets = [];

//                                     // Calculate total width for centering
//                                     for (final subItem in rowItems) {
//                                       if (subItem['type'] == 'StackTextItem') {
//                                         final textItem = StackTextItem.fromJson(
//                                           subItem,
//                                         );
//                                         final scaledFontSize =
//                                             (textItem
//                                                         .content!
//                                                         .style!
//                                                         .fontSize! *
//                                                     scale)
//                                                 .clamp(8.0, 15.0);
//                                         final scaledLetterSpacing =
//                                             ((textItem
//                                                     .content!
//                                                     .style
//                                                     ?.letterSpacing ??
//                                                 1) *
//                                             scale);
//                                         final scaledTextStyle = textItem
//                                             .content!
//                                             .style!
//                                             .copyWith(
//                                               fontSize: scaledFontSize,
//                                               letterSpacing:
//                                                   scaledLetterSpacing,
//                                             );

//                                         final textWidth = getTextWidth(
//                                           text: textItem.content!.data ?? "",
//                                           style: scaledTextStyle,
//                                         ).width;
//                                         totalWidth += textWidth;
//                                       }
//                                     }

//                                     // Starting x-position for centering
//                                     double startX = item['isCentered']
//                                         ? (canvasWidth - totalWidth) / 2
//                                         : scaledX;

//                                     // Build widgets for row items
//                                     for (final subItem in rowItems) {
//                                       if (subItem['type'] == 'StackTextItem') {
//                                         final textItem = StackTextItem.fromJson(
//                                           subItem,
//                                         );
//                                         final scaledFontSize =
//                                             (textItem
//                                                         .content!
//                                                         .style!
//                                                         .fontSize! *
//                                                     scale)
//                                                 .clamp(8.0, 15.0);
//                                         final scaledLetterSpacing =
//                                             ((textItem
//                                                     .content!
//                                                     .style
//                                                     ?.letterSpacing ??
//                                                 1) *
//                                             scale);
//                                         final scaledTextStyle = textItem
//                                             .content!
//                                             .style!
//                                             .copyWith(
//                                               fontSize: scaledFontSize,
//                                               letterSpacing:
//                                                   scaledLetterSpacing,
//                                             );

//                                         final textSize = getTextWidth(
//                                           text: textItem.content!.data ?? "",
//                                           style: scaledTextStyle,
//                                         );
//                                         final maxTextHeight = textSize.height;
//                                         if (rowItems.length == 1) {
//                                           cumulativeYOffset += maxTextHeight;
//                                         }

//                                         rowWidgets.add(
//                                           Positioned(
//                                             left: textItem.isCentered
//                                                 ? 0
//                                                 : startX,
//                                             right: textItem.isCentered
//                                                 ? 0
//                                                 : null,
//                                             top: scaledY,
//                                             child: StackTextCase(
//                                               item: textItem.copyWith(
//                                                 content: textItem.content!
//                                                     .copyWith(
//                                                       style: scaledTextStyle,
//                                                       textAlign: _getTextAlign(
//                                                         textItem
//                                                                 .content!
//                                                                 .textAlign
//                                                                 ?.name ??
//                                                             "center",
//                                                       ),
//                                                     ),
//                                               ),
//                                             ),
//                                           ),
//                                         );
//                                         startX += textSize.width;
//                                       }
//                                     }

//                                     if (rowItems.length > 1) {
//                                       cumulativeYOffset += rowItems
//                                           .map((subItem) {
//                                             if (subItem['type'] ==
//                                                 'StackTextItem') {
//                                               final textItem =
//                                                   StackTextItem.fromJson(
//                                                     subItem,
//                                                   );
//                                               final scaledFontSize =
//                                                   (textItem
//                                                               .content!
//                                                               .style!
//                                                               .fontSize! *
//                                                           scale)
//                                                       .clamp(8.0, 15.0);
//                                               final scaledTextStyle = textItem
//                                                   .content!
//                                                   .style!
//                                                   .copyWith(
//                                                     fontSize: scaledFontSize,
//                                                   );
//                                               return getTextWidth(
//                                                 text:
//                                                     textItem.content!.data ??
//                                                     "",
//                                                 style: scaledTextStyle,
//                                               ).height;
//                                             }
//                                             return 0.0;
//                                           })
//                                           .reduce(math.max);
//                                     }

//                                     return rowWidgets;
//                                   } else if (type == 'StackTextItem') {
//                                     final textItem = StackTextItem.fromJson(
//                                       item,
//                                     );
//                                     final scaledFontSize =
//                                         (textItem.content!.style!.fontSize! *
//                                                 scale)
//                                             .clamp(8.0, 15.0);
//                                     final scaledLetterSpacing =
//                                         ((textItem
//                                                 .content!
//                                                 .style
//                                                 ?.letterSpacing ??
//                                             1) *
//                                         scale);
//                                     final scaledTextStyle = textItem
//                                         .content!
//                                         .style!
//                                         .copyWith(
//                                           fontSize: scaledFontSize,
//                                           letterSpacing: scaledLetterSpacing,
//                                         );

//                                     final maxTextHeight = getTextWidth(
//                                       text: textItem.content!.data ?? "",
//                                       style: scaledTextStyle,
//                                     ).height;
//                                     cumulativeYOffset += maxTextHeight;

//                                     return [
//                                       Positioned(
//                                         left: textItem.isCentered ? 0 : scaledX,
//                                         right: textItem.isCentered ? 0 : null,
//                                         top: scaledY,
//                                         child: StackTextCase(
//                                           item: textItem.copyWith(
//                                             content: textItem.content!.copyWith(
//                                               style: scaledTextStyle,
//                                               textAlign: _getTextAlign(
//                                                 textItem
//                                                         .content!
//                                                         .textAlign
//                                                         ?.name ??
//                                                     "center",
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ];
//                                   } else if (type == 'StackImageItem') {
//                                     final path =
//                                         item['content']['assetName'] ?? '';
//                                     final originalWidth =
//                                         (item['size']['width'] ?? 100)
//                                             .toDouble();
//                                     final originalHeight =
//                                         (item['size']['height'] ?? 100)
//                                             .toDouble();
//                                     final scaledWidth = originalWidth * scale;
//                                     final scaledHeight = originalHeight * scale;

//                                     return [
//                                       Positioned(
//                                         left: item['isCentered']
//                                             ? (canvasWidth / 2) -
//                                                   (scaledWidth / 2)
//                                             : scaledX,
//                                         top: scaledY,
//                                         child: SizedBox(
//                                           width: scaledWidth,
//                                           height: scaledHeight,
//                                           child: Image.asset(
//                                             path,
//                                             fit: BoxFit.contain,
//                                             alignment: Alignment.center,
//                                           ),
//                                         ),
//                                       ),
//                                     ];
//                                   }
//                                   return [const SizedBox.shrink()];
//                                 }),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   // Utility method to calculate text dimensions
//   Size getTextWidth({required String text, required TextStyle style}) {
//     final TextPainter textPainter = TextPainter(
//       text: TextSpan(text: text, style: style),
//       maxLines: null,
//       textDirection: TextDirection.ltr,
//     )..layout();
//     return textPainter.size;
//   }

//   // Utility method to parse text alignment
//   TextAlign _getTextAlign(String alignment) {
//     switch (alignment.toLowerCase()) {
//       case 'center':
//         return TextAlign.center;
//       case 'right':
//         return TextAlign.right;
//       default:
//         return TextAlign.left;
//     }
//   }
// }

class PlaceholderPage extends StatelessWidget {
  final String title;
  final IconData icon;
  const PlaceholderPage({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Get.theme.colorScheme.primaryContainer,
            ),
            child: Icon(
              icon,
              size: 40,
              color: Get.theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: Get.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Get.theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This page is under construction.\nCheck back soon!',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Get.theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class CategoriesList extends GetView<HomeController> {
  const CategoriesList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          return Container(
            margin: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => controller.onCategoryTap(category),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      category.color.withOpacity(0.2),
                      category.color.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: category.color.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: category.color,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      category.name,
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: Get.theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

Size getTextWidth({required String text, required TextStyle style}) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: 300);

  return textPainter.size;
}
