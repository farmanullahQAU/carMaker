import 'package:cardmaker/app/routes/app_routes.dart';
import 'package:cardmaker/models/card_template.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfessionalTemplatesPage extends StatelessWidget {
  const ProfessionalTemplatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.colorScheme.surface,
      appBar: AppBar(
        // title: const Text('Professional Templates'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildSocialMediaSection(),
              const SizedBox(height: 32.0),
              _buildPhotoDesignsSection(),
              const SizedBox(height: 32.0),
              _buildPrintDesignsSection(),
              const SizedBox(height: 32.0),
              _buildInvitationsGreetingsSection(), // New section added
              const SizedBox(height: 32.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialMediaSection() {
    final socialMediaTemplates = [
      CardTemplate(
        id: '1',
        name: 'Instagram Post',
        backgroundImageUrl: null,
        items: [],
        category: 'Social Media',
        categoryId: 'social_media',
        width: 1080,
        height: 1080,
        imagePath: '',
        icon: Icons.camera_alt,
        color: const Color(0xFFE91E63),
      ),
      CardTemplate(
        id: '2',
        name: 'Instagram Story',
        backgroundImageUrl: null,
        items: [],
        category: 'Social Media',
        categoryId: 'social_media',
        width: 1080,
        height: 1920,
        imagePath: '',
        icon: Icons.camera,
        color: const Color(0xFF9C27B0),
      ),
      CardTemplate(
        id: '3',
        name: 'Facebook Post',
        backgroundImageUrl: null,
        items: [],
        category: 'Social Media',
        categoryId: 'social_media',
        width: 1200,
        height: 630,
        imagePath: '',
        icon: Icons.facebook,
        color: const Color(0xFF1976D2),
      ),
      CardTemplate(
        id: '4',
        name: 'Twitter Header',
        backgroundImageUrl: null,
        items: [],
        category: 'Social Media',
        categoryId: 'social_media',
        width: 1500,
        height: 500,
        imagePath: '',
        icon: Icons.alternate_email,
        color: const Color(0xFF1DA1F2),
      ),
      CardTemplate(
        id: '5',
        name: 'LinkedIn Post',
        backgroundImageUrl: null,
        items: [],
        category: 'Social Media',
        categoryId: 'social_media',
        width: 1200,
        height: 627,
        imagePath: '',
        icon: Icons.work_outline,
        color: const Color(0xFF0077B5),
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Social Media',
            'Instagram, Facebook, Twitter & more',
            Icons.share_outlined,
            const Color(0xFFE91E63),
          ),
          const SizedBox(height: 16.0),
          SizedBox(
            height: 160.0,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 4.0, right: 4.0),
              itemCount: socialMediaTemplates.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16.0),
              itemBuilder: (context, index) {
                return _buildTemplateCard(socialMediaTemplates[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoDesignsSection() {
    final photoDesignTemplates = [
      CardTemplate(
        id: '6',
        name: '4x6 Photo',
        backgroundImageUrl: null,
        items: [],
        category: 'Photo Designs',
        categoryId: 'photo_designs',
        width: 1200,
        height: 1800,
        imagePath: '',
        icon: Icons.photo,
        color: const Color(0xFF4CAF50),
      ),
      CardTemplate(
        id: '7',
        name: '5x7 Photo',
        backgroundImageUrl: null,
        items: [],
        category: 'Photo Designs',
        categoryId: 'photo_designs',
        width: 1500,
        height: 2100,
        imagePath: '',
        icon: Icons.image,
        color: const Color(0xFF8BC34A),
      ),
      CardTemplate(
        id: '8',
        name: 'Square Photo',
        backgroundImageUrl: null,
        items: [],
        category: 'Photo Designs',
        categoryId: 'photo_designs',
        width: 1080,
        height: 1080,
        imagePath: '',
        icon: Icons.crop_square,
        color: const Color(0xFF009688),
      ),
      CardTemplate(
        id: '9',
        name: 'Polaroid',
        backgroundImageUrl: null,
        items: [],
        category: 'Photo Designs',
        categoryId: 'photo_designs',
        width: 1000,
        height: 1200,
        imagePath: '',
        icon: Icons.photo_camera,
        color: const Color(0xFF00BCD4),
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Photo Designs',
            'Perfect for printing and sharing',
            Icons.photo_outlined,
            const Color(0xFF4CAF50),
          ),
          const SizedBox(height: 16.0),
          SizedBox(
            height: 160.0,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 4.0, right: 4.0),
              itemCount: photoDesignTemplates.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16.0),
              itemBuilder: (context, index) {
                return _buildTemplateCard(photoDesignTemplates[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrintDesignsSection() {
    final printDesignTemplates = [
      CardTemplate(
        id: '10',
        name: 'A4 Flyer',
        backgroundImageUrl: null,
        items: [],
        category: 'Print Designs',
        categoryId: 'print_designs',
        width: 2480,
        height: 3508,
        imagePath: '',
        icon: Icons.description,
        color: const Color(0xFFFF9800),
      ),
      CardTemplate(
        id: '11',
        name: 'Poster',
        backgroundImageUrl: null,
        items: [],
        category: 'Print Designs',
        categoryId: 'print_designs',
        width: 3000,
        height: 4000,
        imagePath: '',
        icon: Icons.announcement,
        color: const Color(0xFFFF5722),
      ),
      CardTemplate(
        id: '12',
        name: 'Brochure',
        backgroundImageUrl: null,
        items: [],
        category: 'Print Designs',
        categoryId: 'print_designs',
        width: 2550,
        height: 3300,
        imagePath: '',
        icon: Icons.menu_book,
        color: const Color(0xFF795548),
      ),
      CardTemplate(
        id: '13',
        name: 'Business Card',
        backgroundImageUrl: null,
        items: [],
        category: 'Print Designs',
        categoryId: 'print_designs',
        width: 1050,
        height: 600,
        imagePath: '',
        icon: Icons.badge,
        color: const Color(0xFF607D8B),
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Print Designs',
            'Flyers, posters, brochures & more',
            Icons.print_outlined,
            const Color(0xFFFF9800),
          ),
          const SizedBox(height: 16.0),
          SizedBox(
            height: 160.0,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 4.0, right: 4.0),
              itemCount: printDesignTemplates.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16.0),
              itemBuilder: (context, index) {
                return _buildTemplateCard(printDesignTemplates[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvitationsGreetingsSection() {
    final invitationGreetingTemplates = [
      CardTemplate(
        id: '18',
        name: 'A5 Portrait',
        backgroundImageUrl: null,
        items: [],
        category: 'Invitations & Greetings',
        categoryId: 'invitations_greetings',
        width: 1240,
        height: 1748,
        imagePath: '',
        icon: Icons.mail_outline,
        color: const Color(0xFF9C27B0), // Purple for elegance
      ),
      CardTemplate(
        id: '19',
        name: 'A5 Landscape',
        backgroundImageUrl: null,
        items: [],
        category: 'Invitations & Greetings',
        categoryId: 'invitations_greetings',
        width: 1748,
        height: 1240,
        imagePath: '',
        icon: Icons.card_giftcard,
        color: const Color(0xFFF44336), // Red for festive theme
      ),
      CardTemplate(
        id: '14',
        name: 'Wedding Invitation',
        backgroundImageUrl: null,
        items: [],
        category: 'Invitations & Greetings',
        categoryId: 'invitations_greetings',
        width: 1500,
        height: 2100,
        imagePath: '',
        icon: Icons.favorite,
        color: const Color(0xFFD81B60), // Pink for wedding theme
      ),
      CardTemplate(
        id: '15',
        name: 'Birthday Greeting',
        backgroundImageUrl: null,
        items: [],
        category: 'Invitations & Greetings',
        categoryId: 'invitations_greetings',
        width: 1080,
        height: 1080,
        imagePath: '',
        icon: Icons.cake,
        color: const Color(0xFFFFC107), // Amber for festive theme
      ),
      CardTemplate(
        id: '16',
        name: 'Party Invitation',
        backgroundImageUrl: null,
        items: [],
        category: 'Invitations & Greetings',
        categoryId: 'invitations_greetings',
        width: 1200,
        height: 1800,
        imagePath: '',
        icon: Icons.celebration,
        color: const Color(0xFF2196F3), // Blue for party theme
      ),
      CardTemplate(
        id: '17',
        name: 'Holiday Card',
        backgroundImageUrl: null,
        items: [],
        category: 'Invitations & Greetings',
        categoryId: 'invitations_greetings',
        width: 1800,
        height: 1200,
        imagePath: '',
        icon: Icons.card_giftcard,
        color: const Color(0xFF4CAF50), // Green for holiday theme
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Invitations & Greetings',
            'Weddings, birthdays, parties & more',
            Icons.card_giftcard,
            const Color(0xFFD81B60),
          ),
          const SizedBox(height: 16.0),
          SizedBox(
            height: 160.0,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 4.0, right: 4.0),
              itemCount: invitationGreetingTemplates.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16.0),
              itemBuilder: (context, index) {
                return _buildTemplateCard(invitationGreetingTemplates[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Icon(icon, color: color, size: 24.0),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Get.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Get.theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                subtitle,
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: Get.theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateCard(CardTemplate template) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(
          Routes.editor,
          arguments: {"isblank": true, "template": template},
        );
      },
      child: SizedBox(
        width: Get.width * 0.3, // Fixed width for all cards
        height: 160.0, // Fixed height for all cards
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Card Preview Container
            Container(
              width: double.infinity,
              height: 120.0, // Fixed height for preview area
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    template.color.withOpacity(0.06),
                    template.color.withOpacity(0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: template.color.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: template.aspectRatio,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Get.theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: template.color.withOpacity(0.1),
                            blurRadius: 8.0,
                            offset: const Offset(0, 4.0),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Header bar
                          Container(
                            height: 16.0,
                            decoration: BoxDecoration(
                              color: template.color.withOpacity(0.1),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8.0),
                                topRight: Radius.circular(8.0),
                              ),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 6.0),
                                Icon(
                                  template.icon,
                                  size: 10.0,
                                  color: template.color,
                                ),
                                const Spacer(),
                                Container(
                                  width: 2.0,
                                  height: 2.0,
                                  decoration: BoxDecoration(
                                    color: template.color.withOpacity(0.3),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 3.0),
                                Container(
                                  width: 2.0,
                                  height: 2.0,
                                  decoration: BoxDecoration(
                                    color: template.color.withOpacity(0.3),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6.0),
                              ],
                            ),
                          ),
                          // Body content
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Column(
                                children: [
                                  const SizedBox(height: 2.0),
                                  _buildContentLine(width: double.infinity),
                                  const SizedBox(height: 2.0),
                                  _buildContentLine(width: double.infinity),
                                  const SizedBox(height: 2.0),
                                  _buildContentLine(width: 0.7),
                                  if (template.aspectRatio < 1.0) ...[
                                    const SizedBox(height: 2.0),
                                    _buildContentLine(width: 0.5),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            // Title and dimensions
            Expanded(
              child: Column(
                children: [
                  Text(
                    template.name,
                    style: Get.textTheme.labelMedium?.copyWith(
                      color: Get.theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    '${template.width.toInt()} x ${template.height.toInt()}',
                    style: Get.textTheme.bodySmall?.copyWith(
                      color: Get.theme.colorScheme.onSurfaceVariant,
                      fontSize: 10.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentLine({required double width}) {
    return FractionallySizedBox(
      widthFactor: width == double.infinity ? 1.0 : width,
      child: Container(
        height: 1.0,
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.outline.withOpacity(0.2),
          borderRadius: BorderRadius.circular(1.0),
        ),
      ),
    );
  }
}
