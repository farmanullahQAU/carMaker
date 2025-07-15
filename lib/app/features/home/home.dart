import 'package:cardmaker/app/features/editor/editor_canvas.dart';
import 'package:cardmaker/app/features/home/controller.dart';
import 'package:cardmaker/app/routes/app_routes.dart';
import 'package:cardmaker/models/card_template.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Modern UI Theme & Constants ---

// --- Main Home Page Widget ---
class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());

    return Scaffold(
      body: PageView(
        controller: controller.pageController,
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: controller.onPageChanged,
        children: const [
          HomeTab(),
          EditorPage(),
          PlaceholderPage(title: "My Designs"),
          PlaceholderPage(title: "Premium"),
        ],
      ),
      bottomNavigationBar: Obx(() => _buildModernBottomNav()),
    );
  }

  Widget _buildModernBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 24,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: NavigationBar(
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: controller.onBottomNavTap,
          height: 70,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, size: 22),
              selectedIcon: Icon(Icons.home_rounded, size: 22),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.grid_view_outlined, size: 22),
              selectedIcon: Icon(Icons.grid_view_rounded, size: 22),
              label: 'Templates',
            ),
            NavigationDestination(
              icon: Icon(Icons.palette_outlined, size: 22),
              selectedIcon: Icon(Icons.palette_rounded, size: 22),
              label: 'My Designs',
            ),
            NavigationDestination(
              icon: Icon(Icons.workspace_premium_outlined, size: 22),
              selectedIcon: Icon(Icons.workspace_premium_rounded, size: 22),
              label: 'Premium',
            ),
          ],
        ),
      ),
    );
  }
}

// --- The Main Scrollable Home Tab ---
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildModernAppBar(),
        SliverList(
          delegate: SliverChildListDelegate([
            const SizedBox(height: 8),
            const ModernSearchBar(),
            const SizedBox(height: 32),
            const ModernCarousel(),
            const SizedBox(height: 32),
            const SectionTitle(title: 'Quick Actions'),
            const SizedBox(height: 16),
            const QuickActionsGrid(),
            const SizedBox(height: 32),
            const AIBanner(),
            const SizedBox(height: 32),
            const SectionTitle(title: 'Browse Categories'),
            const SizedBox(height: 16),
            const CategoriesList(),
            const SizedBox(height: 32),
            const SectionTitle(title: 'Minimalist Collection'),
            const SizedBox(height: 16),
            const HorizontalCardList(),
            const SizedBox(height: 32),
          ]),
        ),
      ],
    );
  }

  SliverAppBar _buildModernAppBar() {
    return SliverAppBar(
      // surfaceTintColor: Colors.transparent,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good morning',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Text(
            'Create Something Amazing',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: IconButton(
            onPressed: () {},
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(shape: BoxShape.circle),
              child: const Icon(Icons.notifications_outlined, size: 20),
            ),
          ),
        ),
      ],
      pinned: false,
      floating: true,
      toolbarHeight: 80,
    );
  }
}

// --- Modern UI Components ---

class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  const SectionTitle({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ModernSearchBar extends StatefulWidget {
  const ModernSearchBar({super.key});

  @override
  State<ModernSearchBar> createState() => _ModernSearchBarState();
}

class _ModernSearchBarState extends State<ModernSearchBar> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Focus(
          onFocusChange: (focused) => setState(() => _isFocused = focused),
          child: TextField(
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: 'Search templates, styles, or ideas...',
              hintStyle: GoogleFonts.inter(fontWeight: FontWeight.w500),
              prefixIcon: Container(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  Icons.search_rounded,
                  // color: _isFocused ? AppTheme.accent : AppTheme.tertiary,
                  size: 20,
                ),
              ),
              filled: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(width: 2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ModernCarousel extends StatelessWidget {
  const ModernCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find();

    return SizedBox(
      height: 220,
      // child: ListView.builder(
      //   shrinkWrap: true,
      //   scrollDirection: Axis.horizontal,
      //   itemCount: controller.trendingNow.length,
      //   itemBuilder: (context, index) {
      //     return ModernCarouselCard(
      //       category: controller.trendingNow.elementAt(index),
      //     );
      //   },
      // ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 8),

        itemExtent: MediaQuery.of(context).size.width * 0.6,

        children: controller.trendingNow.map((category) {
          return ModernCarouselCard(category: category);
        }).toList(),
      ),
    );
  }
}

class ModernCarouselCard extends StatelessWidget {
  final CategoryModel category;
  const ModernCarouselCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(0),
        child: Stack(
          children: [
            // Background image
            Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(0),
                image: DecorationImage(
                  image: AssetImage(category.imagePath ?? ""),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // // Gradient overlay
            // Container(
            //   decoration: BoxDecoration(
            //     gradient: LinearGradient(
            //       begin: Alignment.topCenter,
            //       end: Alignment.bottomCenter,
            //       colors: [
            //         Colors.transparent,
            //         Colors.black.withOpacity(0.3),
            //         Colors.black.withOpacity(0.7),
            //       ],
            //       stops: const [0.0, 0.6, 1.0],
            //     ),
            //   ),
            // ),
            // Content overlay
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Trending',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.name,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuickActionsGrid extends GetView<HomeController> {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.quickActions.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.7,
        ),
        itemBuilder: (context, index) {
          final action = controller.quickActions[index];
          return GestureDetector(
            onTap: () {
              final template = {
                "id": "wedding_invite_20250712",
                "name": "Wedding Invitation",
                "thumbnailPath": null,
                "backgroundImage": "assets/card1.png",
                "items": [
                  {
                    "type": "StackTextItem",
                    "id": "center",
                    "status": 0,
                    "size": {"width": 200.0, "height": 33.0},
                    "content": {
                      "data": "Weeding Invitation",
                      "googleFont": "Great Vibes",
                      "style": {"fontSize": 18.0},
                    },
                    "isCentered": false,
                    "originalRelativeOffset": {"dx": 0.5, "dy": 0.5},
                  },
                  {
                    "type": "StackTextItem",
                    "id": "text2_topRight",
                    "status": 0,
                    "size": {"width": 100.0, "height": 33.0},
                    "content": {
                      "data": "John & Jane",
                      "googleFont": "Great Vibes",
                      "style": {"fontSize": 11.0},
                    },
                    "isCentered": false,
                    "originalRelativeOffset": {"dx": 0.5, "dy": 0.5 + 0.05},
                  },
                  {
                    "type": "StackTextItem",
                    "id": "text3_bottomLeft",
                    "status": 0,
                    "size": {"width": 100.0, "height": 33.0},
                    "content": {
                      "data": "Saturday, July 12",
                      "googleFont": "Great Vibes",
                      "style": {"fontSize": 11.0},
                    },
                    "isCentered": false,
                    "originalRelativeOffset": {"dx": 0.5, "dy": 0.5 + 0.1},
                  },
                  {
                    "type": "StackTextItem",
                    "id": "text4_bottomRight",
                    "status": 0,
                    "size": {"width": 150.0, "height": 40.0},
                    "content": {
                      "data": "Save the Date",
                      "googleFont": "Great Vibes",
                      "style": {"fontSize": 11.0},
                    },
                    "isCentered": false,
                    "originalRelativeOffset": {"dx": 0.879, "dy": 0.977},
                  },
                  {
                    "type": "StackImageItem",
                    "id": "image_topLeft",
                    "status": 0,
                    "size": {"width": 200.0, "height": 200.0},
                    "content": {"assetName": "assets/Farman.png"},
                    "isCentered": false,
                    "originalRelativeOffset": {"dx": 0.1, "dy": 0.1},
                  },
                ],
                "createdAt": "2025-07-12T06:32:00Z",
                "updatedAt": null,
                "category": "wedding",
                "categoryId": "wedding",
                "compatibleDesigns": [],
                "width": 1240,
                "height": 1748,
                "isPremium": false,
                "tags": ["wedding", "invitation", "elegant"],
                "assetName": "assets/card1.png",
              };
              Get.toNamed(
                Routes.editor,
                arguments: CardTemplate.fromJson(template),
              );
            },

            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: action.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(action.icon, color: action.color, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    action.title,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
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
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'NEW',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'AI Design Studio',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Transform your ideas into stunning designs with AI',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Try Now',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome_rounded, size: 40),
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
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: category.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category.name,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
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

class HorizontalCardList extends GetView<HomeController> {
  const HorizontalCardList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.minimalistCollection.length,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemBuilder: (context, index) {
          final template = controller.minimalistCollection[index];
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        template.backgroundImage,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  template.name,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Minimalist',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(shape: BoxShape.circle),
              child: Icon(Icons.construction_outlined, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming soon...',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
