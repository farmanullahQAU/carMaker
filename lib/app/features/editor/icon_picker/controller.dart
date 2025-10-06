import 'package:cardmaker/app/features/editor/controller.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/src/stack_board_items/items/stack_icon_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IconPickerController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final Rx<IconData?> selectedIcon = Rx<IconData?>(null);
  final Rx<Color> selectedColor = Colors.black.obs;
  final RxString selectedCategory = 'Design'.obs;

  late TabController tabController;

  final List<String> categories = [
    'Popular',
    'Action',
    'Content',
    'Communication',
    'Device',
    'Navigation',
    'Shapes',
    'Design',
  ];

  final Map<String, List<IconData>> categoryIcons = {
    'Popular': [
      Icons.home_rounded,
      Icons.favorite_rounded,
      Icons.star_rounded,
      Icons.person_rounded,
      Icons.settings_rounded,
      Icons.notifications_rounded,
      Icons.mail_rounded,
      Icons.phone_rounded,
      Icons.camera_alt_rounded,
      Icons.image_rounded,
      Icons.music_note_rounded,
      Icons.videocam_rounded,
      Icons.calendar_today_rounded,
      Icons.schedule_rounded,
      Icons.location_on_rounded,
      Icons.map_rounded,
      Icons.shopping_cart_rounded,
      Icons.payment_rounded,
      Icons.card_giftcard_rounded,
      Icons.local_offer_rounded,
      Icons.celebration_rounded,
      Icons.lightbulb_rounded,
      Icons.flag_rounded,
      Icons.trending_up_rounded,
    ],
    'Action': [
      Icons.search_rounded,
      Icons.add_circle_rounded,
      Icons.check_circle_rounded,
      Icons.cancel_rounded,
      Icons.delete_rounded,
      Icons.edit_rounded,
      Icons.save_rounded,
      Icons.done_rounded,
      Icons.close_rounded,
      Icons.refresh_rounded,
      Icons.sync_rounded,
      Icons.update_rounded,
      Icons.undo_rounded,
      Icons.redo_rounded,
      Icons.download_rounded,
      Icons.upload_rounded,
      Icons.content_copy_rounded,
      Icons.content_cut_rounded,
      Icons.content_paste_rounded,
      Icons.print_rounded,
      Icons.share_rounded,
      Icons.send_rounded,
      Icons.forward_rounded,
      Icons.reply_rounded,
      Icons.zoom_in_rounded,
      Icons.zoom_out_rounded,
    ],
    'Content': [
      Icons.add_box_rounded,
      Icons.remove_circle_rounded,
      Icons.block_rounded,
      Icons.clear_rounded,
      Icons.create_rounded,
      Icons.drafts_rounded,
      Icons.font_download_rounded,
      Icons.inbox_rounded,
      Icons.link_rounded,
      Icons.save_alt_rounded,
      Icons.text_fields_rounded,
      Icons.attach_file_rounded,
      Icons.cloud_rounded,
      Icons.folder_rounded,
      Icons.archive_rounded,
      Icons.description_rounded,
      Icons.article_rounded,
      Icons.note_rounded,
      Icons.format_list_bulleted_rounded,
      Icons.format_align_left_rounded,
      Icons.format_bold_rounded,
      Icons.format_italic_rounded,
      Icons.attachment_rounded,
    ],
    'Communication': [
      Icons.chat_rounded,
      Icons.message_rounded,
      Icons.textsms_rounded,
      Icons.call_rounded,
      Icons.phone_in_talk_rounded,
      Icons.voicemail_rounded,
      Icons.contact_phone_rounded,
      Icons.contacts_rounded,
      Icons.forum_rounded,
      Icons.comment_rounded,
      Icons.feedback_rounded,
      Icons.rate_review_rounded,
      Icons.mail_outline_rounded,
      Icons.mark_email_read_rounded,
      Icons.videocam_rounded,
      Icons.video_call_rounded,
      Icons.screen_share_rounded,
      Icons.present_to_all_rounded,
      Icons.public_rounded,
      Icons.group_rounded,
      Icons.tag_rounded,
      Icons.alternate_email_rounded,
      Icons.forum_rounded,
    ],
    'Device': [
      Icons.devices_rounded,
      Icons.phone_android_rounded,
      Icons.phone_iphone_rounded,
      Icons.tablet_rounded,
      Icons.laptop_rounded,
      Icons.desktop_windows_rounded,
      Icons.watch_rounded,
      Icons.headset_rounded,
      Icons.keyboard_rounded,
      Icons.mouse_rounded,
      Icons.gamepad_rounded,
      Icons.battery_full_rounded,
      Icons.bluetooth_rounded,
      Icons.wifi_rounded,
      Icons.signal_cellular_alt_rounded,
      Icons.brightness_high_rounded,
      Icons.volume_up_rounded,
      Icons.camera_rounded,
      Icons.qr_code_rounded,
      Icons.nfc_rounded,
      Icons.usb_rounded,
      Icons.sd_storage_rounded,
    ],
    'Navigation': [
      Icons.arrow_back_rounded,
      Icons.arrow_forward_rounded,
      Icons.arrow_upward_rounded,
      Icons.arrow_downward_rounded,
      Icons.chevron_left_rounded,
      Icons.chevron_right_rounded,
      Icons.expand_more_rounded,
      Icons.expand_less_rounded,
      Icons.menu_rounded,
      Icons.more_vert_rounded,
      Icons.more_horiz_rounded,
      Icons.apps_rounded,
      Icons.dashboard_rounded,
      Icons.home_rounded,
      Icons.account_circle_rounded,
      Icons.exit_to_app_rounded,
      Icons.first_page_rounded,
      Icons.last_page_rounded,
      Icons.grid_view_rounded,
      Icons.view_quilt_rounded,
      Icons.view_module_rounded,
      Icons.drag_handle_rounded,
    ],
    'Shapes': [
      Icons.crop_rounded,
      Icons.crop_square_rounded,
      Icons.panorama_fish_eye_rounded,
      Icons.lens_rounded,
      Icons.star_rounded,
      Icons.favorite_rounded,
      Icons.heart_broken_rounded,
      Icons.circle_rounded,
      Icons.square_rounded,
      Icons.adjust_rounded,
      Icons.opacity_rounded,
      Icons.gradient_rounded,
      Icons.line_weight_rounded,
      Icons.fullscreen_rounded,
      Icons.aspect_ratio_rounded,
      Icons.hexagon_rounded,
      Icons.diamond_rounded,
      Icons.pentagon_rounded,
    ],
    'Design': [
      Icons.brush_rounded,
      Icons.palette_rounded,
      Icons.format_paint_rounded,
      Icons.edit_rounded,
      Icons.tune_rounded,
      Icons.layers_rounded,
      Icons.format_shapes_rounded,
      Icons.border_color_rounded,
      Icons.photo_filter_rounded,
      Icons.opacity_rounded,
      Icons.gradient_rounded,
      Icons.texture_rounded,
      Icons.format_color_fill_rounded,
      Icons.format_color_text_rounded,
      Icons.draw_rounded,
      Icons.pan_tool_rounded,
      Icons.psychology_rounded,
      Icons.auto_awesome_rounded,
      Icons.leaderboard_rounded,
    ],
  };

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: categories.length, vsync: this);

    // Sync tab controller with selected category
    ever(selectedCategory, (category) {
      final index = categories.indexOf(category);
      if (index != -1 && tabController.index != index) {
        tabController.animateTo(index);
      }
    });
  }

  void selectIcon(IconData icon) {
    selectedIcon.value = icon;
  }

  void selectColor(Color color) {
    selectedColor.value = color;

    if (Get.find<CanvasController>().activeItem.value is StackIconItem) {
      addOrUpdateIcon(
        Get.find<CanvasController>().activeItem.value as StackIconItem?,
      );
    }
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
  }

  List<IconData> getCurrentIcons() {
    return categoryIcons[selectedCategory.value] ?? [];
  }

  List<IconData> getCategoryIcons(String category) {
    return categoryIcons[category] ?? [];
  }

  void addOrUpdateIcon(StackIconItem? iconItem) {
    final canvasController = Get.find<CanvasController>();
    final selectedIcon = this.selectedIcon.value;

    if (selectedIcon == null) {
      Get.snackbar(
        'Error',
        'No icon selected',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    if (iconItem != null) {
      final newContent = iconItem.content!.copyWith(
        icon: selectedIcon,
        color: selectedColor.value,
      );
      final newItem = iconItem.copyWith(content: newContent);
      canvasController.updateItem(newItem);
    } else {
      final content = IconItemContent(
        icon: selectedIcon,
        color: selectedColor.value,
        size: 24.0,
      );

      final newIconItem = StackIconItem(
        id: UniqueKey().toString(),
        size: const Size(80, 80),
        offset: canvasController.activeItem.value != null
            ? Offset(
                canvasController.activeItem.value!.offset.dx + 10,
                (canvasController.activeItem.value!.offset.dy + 20),
              )
            : const Offset(50, 50),
        content: content,
      );

      canvasController.boardController.addItem(newIconItem);

      canvasController.activeItem.value = newIconItem;
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    selectedIcon.value = null;
    super.onClose();
  }
}
