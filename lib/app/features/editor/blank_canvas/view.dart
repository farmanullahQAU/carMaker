import 'package:cardmaker/app/features/editor/blank_canvas/controller.dart';
import 'package:cardmaker/models/card_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

class CanvasSelectionPage extends StatelessWidget {
  final controller = Get.put(CanvasSelectionController());

  CanvasSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            // gradient: LinearGradient(
            //   begin: Alignment.topLeft,
            //   end: Alignment.bottomRight,
            //   colors: controller.isDarkMode.value
            //       ? [const Color(0xFF2C2C2C), const Color(0xFF4A4A4A)]
            //       : [const Color(0xFF6DD5FA), const Color(0xFFFFFFFF)],
            // ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildPresetGrid(context),
                        const SizedBox(height: 30),
                        _buildCustomForm(context),
                        const SizedBox(height: 30),
                        // _buildSocialMediaIcons(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          _buildNeumorphicButton(
            child: Icon(
              Icons.arrow_back,
              color: controller.isDarkMode.value
                  ? Colors.white
                  : Colors.black87,
            ),
            onTap: () => Get.back(),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              'New Canvas',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, 24),
                fontWeight: FontWeight.bold,
                color: controller.isDarkMode.value
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
          ),
          _buildThemeToggle(),
        ],
      ),
    );
  }

  Widget _buildThemeToggle() {
    return _buildNeumorphicButton(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Icon(
          controller.isDarkMode.value ? Icons.light_mode : Icons.dark_mode,
          key: ValueKey(controller.isDarkMode.value),
          color: controller.isDarkMode.value ? Colors.yellow : Colors.purple,
        ),
      ),
      onTap: controller.toggleTheme,
    );
  }

  Widget _buildPresetGrid(BuildContext context) {
    return MasonryGridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 3,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      itemCount: controller.cardTemplates.length,
      itemBuilder: (context, index) {
        final template = controller.cardTemplates[index];
        return _buildCanvasCard(template, context);
      },
    );
  }

  Widget _buildCanvasCard(CardTemplate template, BuildContext context) {
    return GestureDetector(
      onTap: () => controller.selectPresetCanvas(template),
      child: Container(
        constraints: BoxConstraints(
          minHeight: 150, // Set a minimum height
        ),
        child: _buildNeumorphicContainer(
          context: context,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Important change
              children: [
                // Remove Expanded widgets and use fixed height or flexible
                SizedBox(
                  height: 100, // Fixed height for preview
                  child: _buildCanvasPreview(
                    template.width,
                    template.height,
                    context,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '${template.name} (${template.width.toInt()}×${template.height.toInt()})',
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(context, 12),
                    fontWeight: FontWeight.w600,
                    color: controller.isDarkMode.value
                        ? Colors.white70
                        : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCanvasPreview(
    double width,
    double height,
    BuildContext context,
  ) {
    return AspectRatio(
      aspectRatio: width / height,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: controller.isDarkMode.value
                ? Colors.white30
                : Colors.black26,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          color: controller.isDarkMode.value
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
        ),
        child: Center(
          child: Text(
            '${width.toInt()}×${height.toInt()}',
            style: TextStyle(
              fontSize: _getResponsiveFontSize(context, 10),
              fontWeight: FontWeight.bold,
              color: controller.isDarkMode.value
                  ? Colors.white60
                  : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomForm(BuildContext context) {
    return _buildNeumorphicContainer(
      context: context,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Custom Dimensions',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, 18),
                fontWeight: FontWeight.bold,
                color: controller.isDarkMode.value
                    ? Colors.white
                    : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildNeumorphicTextField(
                    controller: controller.widthController,
                    label: 'Width',
                    hint: 'e.g., 1920',
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildNeumorphicTextField(
                    controller: controller.heightController,
                    label: 'Height',
                    hint: 'e.g., 1080',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildGlowingButton(
              text: 'Create Canvas',
              onPressed: controller.createCustomCanvas,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNeumorphicTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: this.controller.isDarkMode.value
                ? Colors.white70
                : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: this.controller.isDarkMode.value
                ? const Color(0xFF3A3A3A)
                : Colors.white,
            boxShadow: [
              BoxShadow(
                color: this.controller.isDarkMode.value
                    ? Colors.black.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(4, 4),
              ),
              BoxShadow(
                color: this.controller.isDarkMode.value
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white,
                blurRadius: 8,
                offset: const Offset(-4, -4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: TextStyle(
              color: this.controller.isDarkMode.value
                  ? Colors.white
                  : Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: this.controller.isDarkMode.value
                    ? Colors.white38
                    : Colors.black38,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGlowingButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(25),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialMediaIcons() {
    final socialIcons = [
      {
        'icon': Icons.camera_alt,
        'color': const Color(0xFFE4405F),
        'label': 'Instagram',
      },
      {
        'icon': Icons.alternate_email,
        'color': const Color(0xFF1DA1F2),
        'label': 'Twitter',
      },
      {
        'icon': Icons.play_arrow,
        'color': const Color(0xFFFF0000),
        'label': 'YouTube',
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: socialIcons.map((social) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: GestureDetector(
            onTap: () {
              Get.snackbar(
                social['label'] as String,
                'Feature coming soon!',
                backgroundColor: social['color'] as Color,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    (social['color'] as Color).withOpacity(0.8),
                    social['color'] as Color,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (social['color'] as Color).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                social['icon'] as IconData,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNeumorphicContainer({
    required Widget child,
    required BuildContext context,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(4),
        // color: controller.isDarkMode.value
        //     ? const Color(0xFF3A3A3A)
        //     : Colors.white,
        boxShadow: [
          // BoxShadow(
          //   color: controller.isDarkMode.value
          //       ? Colors.black.withOpacity(0.3)
          //       : Colors.grey.withOpacity(0.3),
          //   blurRadius: 15,
          //   offset: const Offset(8, 8),
          // ),
          // BoxShadow(
          //   color: controller.isDarkMode.value
          //       ? Colors.white.withOpacity(0.1)
          //       : Colors.white,
          //   blurRadius: 15,
          //   offset: const Offset(-8, -8),
          // ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildNeumorphicButton({
    required Widget child,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: controller.isDarkMode.value
              ? const Color(0xFF3A3A3A)
              : Colors.white,
          boxShadow: [
            BoxShadow(
              color: controller.isDarkMode.value
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(4, 4),
            ),
            BoxShadow(
              color: controller.isDarkMode.value
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white,
              blurRadius: 8,
              offset: const Offset(-4, -4),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }

  double _getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return baseSize * 0.9;
    } else if (screenWidth > 1200) {
      return baseSize * 1.1;
    }
    return baseSize;
  }
}
