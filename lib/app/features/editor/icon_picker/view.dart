import 'package:cardmaker/app/features/editor/icon_picker/controller.dart';
import 'package:cardmaker/core/values/app_colors.dart';
import 'package:cardmaker/widgets/common/colors_selector.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/src/stack_board_items/items/stack_icon_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IconPickerPanel extends GetView<IconPickerController> {
  final VoidCallback onClose;
  final StackIconItem? iconItem;

  const IconPickerPanel({super.key, required this.onClose, this.iconItem});

  @override
  Widget build(BuildContext context) {
    // Initialize if editing existing icon
    if (iconItem != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final content = iconItem!.content!;
        controller.selectIcon(content.icon);
        controller.selectedColor.value = content.color;
      });
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(child: _buildTabView()),
          _buildColorSection(),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(
          bottom: BorderSide(
            color: Get.theme.colorScheme.outline.withOpacity(0.12),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.category_rounded,
            size: 16,
            color: AppColors.branding,
          ),
          const SizedBox(width: 6),
          const Expanded(
            child: Text(
              'Choose Icon',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              // controller.addOrUpdateIcon(iconItem);
              onClose();
            },
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.close_rounded,
                size: 16,
                color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: TabBar(
        controller: controller.tabController,
        isScrollable: true,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        tabAlignment: TabAlignment.start,
        indicatorWeight: 2.0,
        // indicatorColor: AppColors.branding,
        indicatorSize: TabBarIndicatorSize.label,
        labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        // labelStyle: const TextStyle(
        //   fontSize: 12,
        //   fontWeight: FontWeight.w600,
        //   letterSpacing: 0.1,
        // ),
        // unselectedLabelStyle: TextStyle(
        //   fontSize: 12,
        //   fontWeight: FontWeight.w500,
        //   letterSpacing: 0.1,
        //   color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
        // ),
        // labelColor: AppColors.branding,
        // unselectedLabelColor: Get.theme.colorScheme.onSurface.withOpacity(0.7),
        dividerColor: Colors.transparent,
        tabs: controller.categories.map((category) {
          return Tab(text: category);
        }).toList(),
        onTap: (index) {
          controller.selectCategory(controller.categories[index]);
        },
      ),
    );
  }

  Widget _buildTabView() {
    return TabBarView(
      controller: controller.tabController,
      children: controller.categories.map((category) {
        return _buildIconGrid(category);
      }).toList(),
    );
  }

  Widget _buildIconGrid(String category) {
    final icons = controller.getCategoryIcons(category);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 4),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          childAspectRatio: 1.0,
        ),
        itemCount: icons.length,
        itemBuilder: (context, index) {
          final icon = icons[index];

          return Obx(
            () => InkWell(
              onTap: () {
                controller.selectIcon(icon);
                controller.addOrUpdateIcon(iconItem);
              },
              borderRadius: BorderRadius.circular(6),
              child: Container(
                decoration: BoxDecoration(
                  color: controller.selectedIcon.value == icon
                      ? AppColors.branding.withOpacity(0.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: controller.selectedIcon.value == icon
                        ? AppColors.branding.withOpacity(0.3)
                        : Colors.transparent,
                    width: 0.5,
                  ),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 16,
                    color: controller.selectedIcon.value == icon
                        ? controller.selectedColor.value
                        : Get.theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildColorSection() {
    return SafeArea(
      child: Obx(
        () => ColorSelector(
          title: "Icon Color",
          showTitle: false,
          paddingx: 0,
          colors: AppColors.predefinedColors,
          currentColor: controller.selectedColor.value,
          onColorSelected: controller.selectColor,
        ),
      ),
    );
  }
}
