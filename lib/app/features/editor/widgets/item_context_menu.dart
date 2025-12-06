// import 'package:cardmaker/app/features/editor/controller.dart';
// import 'package:cardmaker/widgets/common/stack_board/lib/stack_board_item.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';

// /// Long-press context menu for stack items (mobile-friendly)
// class ItemContextMenu {
//   static void show(
//     BuildContext context,
//     StackItem item,
//     CanvasController controller,
//   ) {
//     // Haptic feedback for better UX
//     HapticFeedback.mediumImpact();

//     final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
//     final Offset position =
//         renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
//     final Size size = renderBox?.size ?? Size.zero;

//     // Calculate menu position (prefer showing above item, fallback to below)
//     final double menuY = position.dy > Get.height * 0.6
//         ? position.dy -
//               200 // Show above
//         : position.dy + size.height + 10; // Show below

//     showMenu<String>(
//       context: context,
//       position: RelativeRect.fromLTRB(
//         position.dx + size.width / 2 - 100,
//         menuY,
//         Get.width - (position.dx + size.width / 2 + 100),
//         Get.height - menuY - 200,
//       ),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       elevation: 8,
//       items: _buildMenuItems(item, controller),
//     ).then((value) {
//       // Handle menu selection after menu closes
//       if (value != null) {
//         _handleMenuAction(value, item, controller);
//       }
//     });
//   }

//   static List<PopupMenuEntry<String>> _buildMenuItems(
//     StackItem item,
//     CanvasController controller,
//   ) {
//     final items = <PopupMenuEntry<String>>[];

//     // Duplicate
//     items.add(
//       PopupMenuItem<String>(
//         value: 'duplicate',
//         child: _MenuItemRow(
//           icon: Icons.control_point_duplicate,
//           label: 'Duplicate',
//         ),
//       ),
//     );

//     items.add(const PopupMenuDivider());

//     // Copy (for future paste functionality)
//     items.add(
//       PopupMenuItem<String>(
//         value: 'copy',
//         child: _MenuItemRow(icon: Icons.copy_rounded, label: 'Copy'),
//       ),
//     );

//     items.add(const PopupMenuDivider());

//     // Layer controls
//     if (!item.lockZOrder) {
//       final isAtFront = controller.isItemAtFront();
//       items.add(
//         PopupMenuItem<String>(
//           value: isAtFront ? 'send_to_back' : 'bring_to_front',
//           child: _MenuItemRow(
//             icon: isAtFront
//                 ? Icons.vertical_align_bottom
//                 : Icons.vertical_align_top,
//             label: isAtFront ? 'Send to Back' : 'Bring to Front',
//           ),
//         ),
//       );
//       items.add(const PopupMenuDivider());
//     }

//     // Pixel Alignment Controls
//     // items.add(
//     //   PopupMenuItem<String>(
//     //     value: 'toggle_pixel_alignment',
//     //     child: _MenuItemRow(
//     //       icon: controller.showPixelAlignment.value ? Icons.close : Icons.tune,
//     //       label: controller.showPixelAlignment.value
//     //           ? 'Hide Alignment'
//     //           : 'Show Alignment',
//     //     ),
//     //   ),
//     // );

//     items.add(const PopupMenuDivider());

//     // Lock/Unlock
//     items.add(
//       PopupMenuItem<String>(
//         value: 'toggle_lock',
//         child: _MenuItemRow(
//           icon: item.lockZOrder ? Icons.lock_open : Icons.lock,
//           label: item.lockZOrder ? 'Unlock' : 'Lock',
//         ),
//       ),
//     );

//     items.add(const PopupMenuDivider());

//     // Delete (with confirmation)
//     items.add(
//       PopupMenuItem<String>(
//         value: 'delete',
//         child: _MenuItemRow(
//           icon: Icons.delete_outline,
//           label: 'Delete',
//           isDestructive: true,
//         ),
//       ),
//     );

//     return items;
//   }

//   static void _handleMenuAction(
//     String action,
//     StackItem item,
//     CanvasController controller,
//   ) {
//     HapticFeedback.lightImpact();

//     switch (action) {
//       case 'duplicate':
//         controller.duplicateItem();
//         break;

//       case 'copy':
//         // TODO: Implement copy to clipboard
//         Get.snackbar(
//           'Copied',
//           'Item copied to clipboard',
//           snackPosition: SnackPosition.BOTTOM,
//           duration: const Duration(seconds: 1),
//         );
//         break;

//       case 'bring_to_front':
//         controller.bringToFront();
//         break;

//       case 'send_to_back':
//         controller.sendToBack();
//         break;

//       case 'toggle_pixel_alignment':
//         controller.showPixelAlignment.value =
//             !controller.showPixelAlignment.value;
//         break;

//       case 'toggle_lock':
//         controller.toggleZLock(item.id);
//         break;

//       case 'delete':
//         HapticFeedback.mediumImpact();
//         _showDeleteConfirmation(item, controller);
//         break;
//     }
//   }

//   static void _showDeleteConfirmation(
//     StackItem item,
//     CanvasController controller,
//   ) {
//     Get.dialog(
//       AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text('Delete Item'),
//         content: const Text('Are you sure you want to delete this item?'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               HapticFeedback.lightImpact();
//               Get.back();
//             },
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               HapticFeedback.mediumImpact();
//               Get.back();
//               controller.boardController.removeItem(item);
//               controller.activeItem.value = null;
//             },
//             style: TextButton.styleFrom(foregroundColor: Colors.red),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _MenuItemRow extends StatelessWidget {
//   const _MenuItemRow({
//     required this.icon,
//     required this.label,
//     this.isDestructive = false,
//   });

//   final IconData icon;
//   final String label;
//   final bool isDestructive;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final color = isDestructive
//         ? Colors.red
//         : theme.colorScheme.onSurface.withOpacity(0.87);

//     return Row(
//       children: [
//         Icon(icon, size: 22, color: color),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Text(
//             label,
//             style: theme.textTheme.bodyMedium?.copyWith(color: color),
//           ),
//         ),
//       ],
//     );
//   }
// }
