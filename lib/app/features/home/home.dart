// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cardmaker/app/features/home/blank_templates/view.dart';
// import 'package:cardmaker/app/features/home/controller.dart';
// import 'package:cardmaker/app/features/profile/view.dart';
// import 'package:cardmaker/app/routes/app_routes.dart';
// import 'package:cardmaker/core/values/app_colors.dart';
// import 'package:cardmaker/models/card_template.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:photo_view/photo_view.dart';
// import 'package:widget_mask/widget_mask.dart';

// // --- ENHANCED DATA MODELS ---

// class QuickAction {
//   final String title;
//   final IconData icon;
//   final Color color;

//   QuickAction({required this.title, required this.icon, required this.color});

//   Map<String, dynamic> toJson() => {
//     'title': title,
//     'icon': icon.codePoint,
//     'color': color.value,
//   };

//   factory QuickAction.fromJson(Map<String, dynamic> json) => QuickAction(
//     title: json['title'],
//     icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
//     color: Color(json['color']),
//   );
// }

// // --- Canvas Size Model ---
// class CanvasSize {
//   final String title;
//   final double width;
//   final double height;
//   final IconData icon;
//   final Color color;
//   final String? thumbnailUrl;

//   CanvasSize({
//     required this.title,
//     required this.width,
//     required this.height,
//     required this.icon,
//     required this.color,
//     this.thumbnailUrl,
//   });
// }

// // --- Main Home Page Widget ---
// class HomePage extends GetView<HomeController> {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Obx(
//       () => Scaffold(
//         backgroundColor: Get.theme.colorScheme.surface,
//         extendBody: controller.selectedIndex.value == 0 ? true : false,
//         // appBar: controller.selectedIndex.value == 0
//         //     ? null
//         //     : AppBar(
//         //         title: Text(
//         //           controller.selectedIndex.value == 1
//         //               ? 'Templates'
//         //               : 'My Designs',
//         //           style: Get.textTheme.titleLarge?.copyWith(
//         //             fontWeight: FontWeight.w600,
//         //             color: Get.theme.colorScheme.onSurface,
//         //           ),
//         //         ),
//         //         backgroundColor: Get.theme.colorScheme.surface,
//         //         elevation: 0,
//         //       ),
//         body: IndexedStack(
//           index: controller.selectedIndex.value,
//           children: [
//             const HomeTab(),
//             const ProfessionalTemplatesPage(),
//             ProfileTab(),
//             // PlaceholderPage(
//             //   title: "My Designs",
//             //   icon: Icons.palette_outlined,
//             // ),
//           ],
//         ),
//         bottomNavigationBar: _buildModernBottomNav(),
//       ),
//     );
//   }

//   Widget _buildModernBottomNav() {
//     return BottomNavigationBar(
//       currentIndex: controller.selectedIndex.value,
//       onTap: controller.onBottomNavTap,
//       elevation: 4,

//       items: [
//         _ModernNavDestination(
//           icon: Icons.home_outlined,
//           selectedIcon: Icons.home_rounded,
//           label: 'Home',
//         ),
//         _ModernNavDestination(
//           icon: Icons.grid_view_outlined,
//           selectedIcon: Icons.grid_view_rounded,
//           label: 'Templates',
//         ),
//         _ModernNavDestination(
//           icon: Icons.person_outline,
//           selectedIcon: Icons.person,
//           label: 'Profile',
//         ),
//       ],
//     );
//   }
// }

// class _ModernNavDestination extends BottomNavigationBarItem {
//   _ModernNavDestination({
//     required IconData icon,
//     required IconData selectedIcon,
//     required String label,
//   }) : super(icon: Icon(icon), activeIcon: Icon(selectedIcon), label: label);
// }

// // --- The Main Scrollable Home Tab ---
// class HomeTab extends GetView<HomeController> {
//   const HomeTab({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBody: true,
//       appBar: AppBar(
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Start a Design',
//               style: Get.textTheme.headlineSmall?.copyWith(
//                 fontWeight: FontWeight.w700,
//                 color: Get.theme.colorScheme.onSurface,
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 16),
//             child: IconButton(
//               onPressed: () {},
//               icon: Badge(
//                 backgroundColor: Get.theme.colorScheme.primary,
//                 child: Icon(
//                   Icons.notifications_none_rounded,
//                   color: Get.theme.colorScheme.onSurface,
//                   size: 24,
//                 ),
//               ),
//             ),
//           ),
//         ],
//         backgroundColor: Get.theme.colorScheme.surface,
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         // physics: const BouncingScrollPhysics(),
//         child: Column(
//           spacing: 8,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             const CanvasSizesRow(),
//             const ProfessionalTemplatesBanner(),
//             const SectionTitle(title: 'Browse Categories', showSeeAll: true),
//             const CategoriesList(),
//             const SectionTitle(title: 'Featured Templates', showSeeAll: true),
//             const HorizontalCardList(),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // --- New HorizontalCardList Widget to Display Templates ---
// class HorizontalCardList extends GetView<HomeController> {
//   const HorizontalCardList({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 150,
//       child: GetBuilder<HomeController>(
//         id: 'templates',
//         builder: (controller) => controller.isLoading.value
//             ? const Center(child: CircularProgressIndicator())
//             : controller.templates.isEmpty
//             ? Center(
//                 child: Text(
//                   'No templates available',
//                   style: Get.textTheme.bodyMedium?.copyWith(
//                     color: Get.theme.colorScheme.onSurfaceVariant,
//                   ),
//                 ),
//               )
//             : ListView.separated(
//                 scrollDirection: Axis.horizontal,
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 physics: const BouncingScrollPhysics(),
//                 cacheExtent: 500.0,
//                 itemCount: controller.templates.length + 1,
//                 itemBuilder: (context, index) {
//                   if (index == controller.templates.length) {
//                     return _buildViewAllButton();
//                   }
//                   final template = controller.templates[index];
//                   return TemplateCard(template: template);
//                 },
//                 separatorBuilder: (context, index) => const SizedBox(width: 8),
//               ),
//       ),
//     );
//   }

//   Widget _buildViewAllButton() {
//     return GestureDetector(
//       onTap: () => Get.to(() => const ProfessionalTemplatesPage()),
//       child: Container(
//         width: 100,
//         decoration: BoxDecoration(
//           color: Get.theme.colorScheme.surface,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: Get.theme.colorScheme.outline.withOpacity(0.1),
//             width: 1,
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 48,
//               height: 48,
//               decoration: BoxDecoration(
//                 color: AppColors.branding.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.arrow_forward_rounded,
//                 color: AppColors.branding,
//                 size: 24,
//               ),
//             ),
//             const SizedBox(height: 12),
//             const Text('View All'),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // --- New TemplateCard Widget ---
// class TemplateCard extends GetView<HomeController> {
//   final CardTemplate template;

//   const TemplateCard({super.key, required this.template});

//   @override
//   Widget build(BuildContext context) {
//     final aspectRatio = template.width / template.height;

//     return GestureDetector(
//       onTap: () => controller.onTemplateTap(template),
//       child: ConstrainedBox(
//         constraints: BoxConstraints(maxWidth: Get.width * 0.4),
//         child: AspectRatio(
//           aspectRatio: aspectRatio,
//           child: Stack(
//             children: [
//               Align(
//                 alignment: Alignment.topCenter,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Get.theme.shadowColor.withOpacity(0.1),
//                         blurRadius: 8,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(12),

//                     child: template.thumbnailUrl != null
//                         ? CachedNetworkImage(
//                             imageUrl: template.thumbnailUrl!,
//                             fit: BoxFit.cover,
//                             fadeInDuration: const Duration(milliseconds: 200),
//                             placeholder: (context, url) =>
//                                 Container(color: Colors.grey[200]),
//                             errorWidget: (context, url, error) =>
//                                 Icon(Icons.error, color: Colors.grey[400]),
//                           )
//                         : Icon(
//                             Icons.image,
//                             size: 40,
//                             color: Get.theme.colorScheme.onSurfaceVariant,
//                           ),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 top: 8,
//                 right: 8,
//                 child: GetBuilder<HomeController>(
//                   id: 'favorites',
//                   builder: (controller) => Container(
//                     width: 32,
//                     height: 32,
//                     decoration: BoxDecoration(
//                       color: Get.theme.colorScheme.surface.withOpacity(0.8),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Obx(
//                       () => IconButton(
//                         icon: Icon(
//                           controller.favoriteTemplateIds.contains(template.id)
//                               ? Icons.favorite_rounded
//                               : Icons.favorite_border_rounded,
//                           size: 18,
//                           color:
//                               controller.favoriteTemplateIds.contains(
//                                 template.id,
//                               )
//                               ? Colors.red
//                               : Get.theme.colorScheme.onSurface,
//                         ),
//                         onPressed: () async {
//                           await controller.toggleFavorite(template.id);
//                         },
//                         padding: EdgeInsets.zero,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // --- Modern UI Components ---
// class SectionTitle extends StatelessWidget {
//   final String title;
//   final bool showSeeAll;

//   const SectionTitle({super.key, required this.title, this.showSeeAll = false});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Text(
//             title,
//             style: Get.textTheme.titleMedium?.copyWith(
//               fontWeight: FontWeight.w600,
//               color: Get.theme.colorScheme.onSurface,
//             ),
//           ),
//           if (showSeeAll)
//             TextButton(
//               onPressed: () {
//                 Get.toNamed(Routes.auth);
//               },
//               child: Text(
//                 'See All',
//                 style: Get.textTheme.bodyMedium?.copyWith(
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// class ProfessionalTemplatesBanner extends StatelessWidget {
//   const ProfessionalTemplatesBanner({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             AppColors.brandingLight,
//             AppColors.branding,
//             AppColors.brandingLight,
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF667EEA).withOpacity(0.3),
//             blurRadius: 20,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Professional Templates',
//                   style: Get.textTheme.titleMedium?.copyWith(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Social media, business cards, prints & more.',
//                   style: Get.textTheme.bodySmall?.copyWith(
//                     color: Colors.white.withOpacity(0.9),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 FilledButton.tonal(
//                   onPressed: () => Get.to(() => ProfessionalTemplatesPage()),
//                   child: Text(
//                     'Explore',
//                     style: Get.textTheme.bodyMedium?.copyWith(
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 16),
//           Icon(
//             Icons.business_center_outlined,
//             size: 42,
//             color: Colors.white.withOpacity(0.8),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class CanvasSizesRow extends GetView<HomeController> {
//   const CanvasSizesRow({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [_buildBasicCanvasSection()],
//       ),
//     );
//   }

//   Widget _buildBasicCanvasSection() {
//     // Define list of CardTemplate constructors
//     final basicTemplates = [
//       CardTemplate(
//         id: 'square',
//         name: 'Square',
//         width: 1000,
//         height: 1000,
//         categoryId: 'general',
//         imagePath: 'assets/square.png',
//         items: [],
//       ),
//       CardTemplate(
//         id: 'portrait',
//         name: 'Portrait',
//         width: 750,
//         height: 1000,
//         categoryId: 'general',
//         imagePath: 'assets/portrait.png',
//         items: [],
//       ),
//       CardTemplate(
//         id: 'landscape',
//         name: 'Landscape',
//         width: 1000,
//         height: 750,
//         categoryId: 'general',
//         imagePath: 'assets/landscape.png',
//         items: [],
//       ),
//     ];

//     return SizedBox(
//       height: 90.0,
//       child: Row(
//         spacing: 8,
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: basicTemplates.asMap().entries.map((entry) {
//           final template = entry.value;
//           return Expanded(child: _buildBasicCanvasCard(template));
//         }).toList(),
//       ),
//     );
//   }

//   Widget _buildBasicCanvasCard(CardTemplate template) {
//     return GestureDetector(
//       onTap: () {
//         Get.toNamed(Routes.editor, arguments: template);
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: Get.theme.colorScheme.surfaceContainer,
//           borderRadius: BorderRadius.circular(12.0),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Align(
//               alignment: Alignment.bottomCenter,
//               child: Container(
//                 width: 60.0,
//                 height: 60.0 / template.aspectRatio,
//                 decoration: BoxDecoration(
//                   color: Get.theme.colorScheme.surface,
//                   borderRadius: BorderRadius.circular(8.0),
//                 ),
//                 child: Icon(Icons.add, color: AppColors.branding, size: 20.0),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // --- Other Existing Widgets (Unchanged) ---
// class CategoriesList extends GetView<HomeController> {
//   const CategoriesList({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 40,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         itemCount: controller.categories.length,
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         physics: const BouncingScrollPhysics(),
//         cacheExtent: 500.0,
//         itemBuilder: (context, index) {
//           final category = controller.categories[index];
//           return InkWell(
//             borderRadius: BorderRadius.circular(24),
//             onTap: () => controller.onCategoryTap(category),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 15),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     category.color.withOpacity(0.2),
//                     category.color.withOpacity(0.1),
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(24),
//                 boxShadow: [
//                   BoxShadow(
//                     color: category.color.withOpacity(0.1),
//                     blurRadius: 8,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Container(
//                     width: 10,
//                     height: 10,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: category.color,
//                       border: Border.all(
//                         color: Colors.white.withOpacity(0.3),
//                         width: 1,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Text(
//                     category.name,
//                     style: Get.textTheme.bodyMedium?.copyWith(
//                       color: Get.theme.colorScheme.onSurface,
//                       fontWeight: FontWeight.w600,
//                       letterSpacing: 0.2,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//         separatorBuilder: (context, _) => const SizedBox(width: 8),
//       ),
//     );
//   }
// }

// Size getTextWidth({required String text, required TextStyle style}) {
//   final TextPainter textPainter = TextPainter(
//     text: TextSpan(text: text, style: style),
//     textDirection: TextDirection.ltr,
//   )..layout(maxWidth: 300);

//   return textPainter.size;
// }

// class MaskingExamplePage extends StatelessWidget {
//   const MaskingExamplePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Mask Boundary Example')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//               'Visualizing Mask Boundaries:',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             SizedBox(
//               width: Get.width * 0.8,
//               height: 600,
//               child: WidgetMask(
//                 blendMode: BlendMode.srcOver,
//                 childSaveLayer: true,
//                 mask: Image.asset('assets/card7.png'),
//                 child: InkWell(
//                   onTap: () {
//                     print("xxxxxxxxxxxxxxxxx");
//                   },
//                   child: PhotoView(
//                     minScale: PhotoViewComputedScale.contained * 0.4,
//                     maxScale: PhotoViewComputedScale.covered * 3.0,
//                     initialScale: PhotoViewComputedScale.contained,
//                     basePosition: Alignment.center,
//                     enablePanAlways: true,
//                     imageProvider: const AssetImage('assets/Farman.png'),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class PlaceholderPage extends StatelessWidget {
//   final String title;
//   final IconData icon;
//   const PlaceholderPage({super.key, required this.title, required this.icon});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 80,
//             height: 80,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: Get.theme.colorScheme.primaryContainer,
//             ),
//             child: Icon(
//               icon,
//               size: 40,
//               color: Get.theme.colorScheme.onPrimaryContainer,
//             ),
//           ),
//           const SizedBox(height: 20),
//           Text(
//             title,
//             style: Get.textTheme.headlineSmall?.copyWith(
//               fontWeight: FontWeight.w600,
//               color: Get.theme.colorScheme.onSurface,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'This page is under construction.\nCheck back soon!',
//             style: Get.textTheme.bodyMedium?.copyWith(
//               color: Get.theme.colorScheme.onSurfaceVariant,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cardmaker/app/features/home/blank_templates/view.dart';
import 'package:cardmaker/app/features/home/controller.dart';
import 'package:cardmaker/app/features/profile/view.dart';
import 'package:cardmaker/app/routes/app_routes.dart';
import 'package:cardmaker/core/values/app_colors.dart';
import 'package:cardmaker/models/card_template.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:widget_mask/widget_mask.dart';

// --- ENHANCED DATA MODELS ---

class QuickAction {
  final String title;
  final IconData icon;
  final Color color;

  const QuickAction({
    required this.title,
    required this.icon,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'icon': icon.codePoint,
    'color': color.value,
  };

  factory QuickAction.fromJson(Map<String, dynamic> json) => QuickAction(
    title: json['title'] as String,
    icon: IconData(json['icon'] as int, fontFamily: 'MaterialIcons'),
    color: Color(json['color'] as int),
  );
}

// --- Canvas Size Model ---
class CanvasSize {
  final String title;
  final double width;
  final double height;
  final IconData icon;
  final Color color;
  final String? thumbnailUrl;

  const CanvasSize({
    required this.title,
    required this.width,
    required this.height,
    required this.icon,
    required this.color,
    this.thumbnailUrl,
  });
}

// --- Main Home Page Widget ---
class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        extendBody: controller.selectedIndex.value == 0,
        body: IndexedStack(
          index: controller.selectedIndex.value,
          children: const [
            HomeTab(),
            ProfessionalTemplatesPage(),
            ProfileTab(),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.black.withOpacity(0.05),
      //       blurRadius: 10,
      //       offset: const Offset(0, -2),
      //     ),
      //   ],
      // ),
      child: BottomNavigationBar(
        currentIndex: controller.selectedIndex.value,
        onTap: controller.onBottomNavTap,
        type: BottomNavigationBarType.fixed,
        // elevation: 0,
        // backgroundColor: Colors.transparent,
        // backgroundColor: Colors.white,
        // selectedFontSize: 11,
        // unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apps_rounded),
            activeIcon: Icon(Icons.apps, size: 22),
            label: 'Templates',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person, size: 22),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// --- The Main Scrollable Home Tab ---
class HomeTab extends GetView<HomeController> {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      extendBody: true,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              CanvasSizesRow(),
              SizedBox(height: 12),
              ProfessionalTemplatesBanner(),
              SizedBox(height: 20),
              SectionTitle(title: 'Categories'),
              SizedBox(height: 12),
              CategoriesList(),
              SizedBox(height: 20),
              SectionTitle(title: 'Featured Templates', showSeeAll: true),
              SizedBox(height: 12),
              HorizontalCardList(),
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFFAFAFA),
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create Design',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {},
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: Color(0xFF6B7280),
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// --- Professional HorizontalCardList Widget ---
class HorizontalCardList extends GetView<HomeController> {
  const HorizontalCardList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: GetBuilder<HomeController>(
        id: 'templates',
        builder: (controller) {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }

          if (controller.templates.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const BouncingScrollPhysics(),
            itemCount: controller.templates.length.clamp(0, 8) + 1,
            itemBuilder: (context, index) {
              if (index == controller.templates.length.clamp(0, 8)) {
                return _buildViewAllCard();
              }
              return TemplateCard(template: controller.templates[index]);
            },
            separatorBuilder: (context, index) => const SizedBox(width: 12),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'No templates available',
        style: TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildViewAllCard() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Get.to(() => const ProfessionalTemplatesPage()),
        child: Container(
          width: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFF6B7280),
                  size: 18,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'View All',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Professional TemplateCard Widget ---
class TemplateCard extends GetView<HomeController> {
  final CardTemplate template;

  const TemplateCard({super.key, required this.template});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => controller.onTemplateTap(template),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: Get.width * 0.4),
          child: AspectRatio(
            aspectRatio: template.aspectRatio,
            child: Container(
              width: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      // color: const Color(0xFFF9FAFB),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildTemplateImage(),
                    ),
                  ),
                  _buildFavoriteButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateImage() {
    if (template.thumbnailUrl != null) {
      return CachedNetworkImage(
        imageUrl: template.thumbnailUrl!,
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 200),
        placeholder: (context, url) => Container(
          color: const Color(0xFFF9FAFB),
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) => Container(
          color: const Color(0xFFF9FAFB),
          child: const Icon(
            Icons.image_outlined,
            color: Color(0xFFD1D5DB),
            size: 24,
          ),
        ),
      );
    }

    return Container(
      color: const Color(0xFFF9FAFB),
      child: const Center(
        child: Icon(Icons.image_outlined, color: Color(0xFFD1D5DB), size: 24),
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return Positioned(
      top: 6,
      right: 6,
      child: GetBuilder<HomeController>(
        id: 'favorites',
        builder: (controller) => Material(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () async => await controller.toggleFavorite(template.id),
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
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
                  size: 14,
                  color: controller.favoriteTemplateIds.contains(template.id)
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF9CA3AF),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- Professional Section Title ---
class SectionTitle extends StatelessWidget {
  final String title;
  final bool showSeeAll;
  final VoidCallback? onSeeAllTap;

  const SectionTitle({
    super.key,
    required this.title,
    this.showSeeAll = false,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Get.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (showSeeAll)
            TextButton(
              style: TextButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.comfortable,
              ),
              onPressed: () {},
              child: Text('See all'),
            ),
        ],
      ),
    );
  }
}

// --- Professional Templates Banner ---
// --- Professional Templates Banner - Compact Version ---
class ProfessionalTemplatesBanner extends StatelessWidget {
  const ProfessionalTemplatesBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Get.to(() => const ProfessionalTemplatesPage()),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.brandingLight, AppColors.pink400Light],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pro badge
                      // Container(
                      //   padding: const EdgeInsets.symmetric(
                      //     horizontal: 6,
                      //     vertical: 2,
                      //   ),
                      //   decoration: BoxDecoration(
                      //     color: Colors.white.withOpacity(0.2),
                      //     borderRadius: BorderRadius.circular(4),
                      //   ),
                      //   child: const Text(
                      //     'PRO',
                      //     style: TextStyle(
                      //       color: Colors.white,
                      //       fontSize: 9,
                      //       fontWeight: FontWeight.w700,
                      //       letterSpacing: 0.8,
                      //     ),
                      //   ),
                      // ),
                      const SizedBox(height: 8),
                      // Title
                      const Text(
                        'Professional Templates',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Description
                      Text(
                        'Business cards, social media & more',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // CTA Button
                      ElevatedButton(
                        style: FilledButton.styleFrom(
                          elevation: 0,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),

                        onPressed: () {},
                        child: Text("Browse"),
                      ),
                    ],
                  ),
                ),
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.star_rounded,
                    size: 22,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Keep CanvasSizesRow exactly as provided ---
class CanvasSizesRow extends GetView<HomeController> {
  const CanvasSizesRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildBasicCanvasSection()],
      ),
    );
  }

  Widget _buildBasicCanvasSection() {
    // Define list of CardTemplate constructors
    final basicTemplates = [
      CardTemplate(
        id: 'square',
        name: 'Square',
        width: 1000,
        height: 1000,
        categoryId: 'general',
        imagePath: 'assets/square.png',
        items: [],
      ),
      CardTemplate(
        id: 'portrait',
        name: 'Portrait',
        width: 750,
        height: 1000,
        categoryId: 'general',
        imagePath: 'assets/portrait.png',
        items: [],
      ),
      CardTemplate(
        id: 'landscape',
        name: 'Landscape',
        width: 1000,
        height: 750,
        categoryId: 'general',
        imagePath: 'assets/landscape.png',
        items: [],
      ),
    ];

    return SizedBox(
      height: 90.0,
      child: Row(
        spacing: 8,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: basicTemplates.asMap().entries.map((entry) {
          final template = entry.value;
          return Expanded(child: _buildBasicCanvasCard(template));
        }).toList(),
      ),
    );
  }

  Widget _buildBasicCanvasCard(CardTemplate template) {
    return Stack(
      fit: StackFit.passthrough,
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        GestureDetector(
          onTap: () {
            Get.toNamed(Routes.editor, arguments: template);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12.0),
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.black.withOpacity(0.05),
              //     blurRadius: 8,
              //     offset: const Offset(0, 2),
              //   ),
              // ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 55.0,
                    height: 55.0 / template.aspectRatio,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(
                      Icons.add,
                      color: AppColors.branding,
                      size: 20.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        Positioned(
          bottom: -16,
          child: Text(template.name, style: Get.textTheme.labelSmall),
        ),
      ],
    );
  }
}

// --- Professional Categories List ---
class CategoriesList extends GetView<HomeController> {
  const CategoriesList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: controller.categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          return _CategoryChip(category: category, controller: controller);
        },
        separatorBuilder: (context, _) => const SizedBox(width: 8),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final dynamic category;
  final HomeController controller;

  const _CategoryChip({required this.category, required this.controller});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => controller.onCategoryTap(category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          border: Border.all(width: 0.1),
          // gradient: LinearGradient(
          //   colors: [
          //     category.color.withOpacity(0.2),
          //     category.color.withOpacity(0.1),
          //   ],
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          // ),
          borderRadius: BorderRadius.circular(24),
          // boxShadow: [
          //   BoxShadow(
          //     color: category.color.withOpacity(0.1),
          //     blurRadius: 8,
          //     offset: const Offset(0, 4),
          //   ),
          // ],
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
              style: Get.textTheme.bodySmall?.copyWith(
                color: Get.theme.colorScheme.onSurface,
                // fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Utility Functions ---
Size getTextWidth({required String text, required TextStyle style}) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: 300);

  return textPainter.size;
}

// --- Professional Masking Example Page ---
class MaskingExamplePage extends StatelessWidget {
  const MaskingExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Mask Preview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF6B7280)),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: Get.width * 0.8,
                height: 500,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: WidgetMask(
                    blendMode: BlendMode.srcOver,
                    childSaveLayer: true,
                    mask: Image.asset('assets/card7.png'),
                    child: PhotoView(
                      minScale: PhotoViewComputedScale.contained * 0.4,
                      maxScale: PhotoViewComputedScale.covered * 3.0,
                      initialScale: PhotoViewComputedScale.contained,
                      basePosition: Alignment.center,
                      enablePanAlways: true,
                      imageProvider: const AssetImage('assets/Farman.png'),
                      backgroundDecoration: const BoxDecoration(
                        color: Color(0xFFF9FAFB),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Professional Placeholder Page ---
class PlaceholderPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? subtitle;

  const PlaceholderPage({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 36, color: const Color(0xFF6B7280)),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle ?? 'Coming soon',
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
