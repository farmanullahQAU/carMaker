import 'package:cardmaker/app/features/editor/controller.dart';
import 'package:cardmaker/core/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Quick action floating buttons that appear when an item is selected
/// Provides fast access to common operations on mobile
class QuickActionButtons extends StatelessWidget {
  const QuickActionButtons({super.key, required this.controller});

  final CanvasController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final activeItem = controller.activeItem.value;
      if (activeItem == null) {
        return const SizedBox.shrink();
      }

      // Position at bottom center, above the bottom toolbar
      return Positioned(
        bottom: 100,
        left: 0,
        right: 0,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Alignment button
              _QuickActionButton(
                icon: Icons.format_align_center,
                label: 'Align',
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _showAlignmentMenu(context, controller);
                },
                color: AppColors.branding,
              ),
              const SizedBox(width: 12),
              // Delete button
              _QuickActionButton(
                icon: Icons.delete_outline,
                label: 'Delete',
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _showDeleteConfirmation(context, activeItem, controller);
                },
                color: Colors.red,
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showDeleteConfirmation(
    BuildContext context,
    dynamic item,
    CanvasController controller,
  ) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Get.back();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Get.back();
              controller.boardController.removeItem(item);
              controller.activeItem.value = null;
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAlignmentMenu(BuildContext context, CanvasController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Align Item',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              // Quick alignment buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _AlignmentButton(
                      icon: Icons.format_align_left,
                      label: 'Left',
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                        controller.alignItemLeft();
                      },
                    ),
                    _AlignmentButton(
                      icon: Icons.format_align_center,
                      label: 'Center',
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                        controller.alignItemCenter();
                      },
                    ),
                    _AlignmentButton(
                      icon: Icons.format_align_right,
                      label: 'Right',
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                        controller.alignItemRight();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _AlignmentButton(
                      icon: Icons.vertical_align_top,
                      label: 'Top',
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                        controller.alignItemTop();
                      },
                    ),
                    _AlignmentButton(
                      icon: Icons.vertical_align_center,
                      label: 'Middle',
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                        controller.alignItemMiddle();
                      },
                    ),
                    _AlignmentButton(
                      icon: Icons.vertical_align_bottom,
                      label: 'Bottom',
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                        controller.alignItemBottom();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Divider
              Divider(height: 1, thickness: 1, color: Colors.grey[300]),
              const SizedBox(height: 16),
              // Professional pixel-based alignment
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Precise Alignment (px)',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _PixelAlignmentInput(
                      controller: controller,
                      onApply: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(28),
      elevation: 4,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlignmentButton extends StatelessWidget {
  const _AlignmentButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 90,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28, color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PixelAlignmentInput extends StatefulWidget {
  const _PixelAlignmentInput({required this.controller, required this.onApply});

  final CanvasController controller;
  final VoidCallback onApply;

  @override
  State<_PixelAlignmentInput> createState() => _PixelAlignmentInputState();
}

class _PixelAlignmentInputState extends State<_PixelAlignmentInput> {
  late TextEditingController _leftController;
  late TextEditingController _rightController;
  late TextEditingController _topController;
  late TextEditingController _bottomController;

  @override
  void initState() {
    super.initState();
    final item = widget.controller.activeItem.value;
    if (item != null) {
      final canvasSize = Size(
        widget.controller.scaledCanvasWidth.value,
        widget.controller.scaledCanvasHeight.value,
      );
      // Calculate current pixel positions (edge positions, not center)
      final left = item.offset.dx - item.size.width / 2;
      final right = canvasSize.width - (item.offset.dx + item.size.width / 2);
      final top = item.offset.dy - item.size.height / 2;
      final bottom =
          canvasSize.height - (item.offset.dy + item.size.height / 2);

      _leftController = TextEditingController(text: left.toStringAsFixed(0));
      _rightController = TextEditingController(text: right.toStringAsFixed(0));
      _topController = TextEditingController(text: top.toStringAsFixed(0));
      _bottomController = TextEditingController(
        text: bottom.toStringAsFixed(0),
      );
    } else {
      _leftController = TextEditingController();
      _rightController = TextEditingController();
      _topController = TextEditingController();
      _bottomController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _leftController.dispose();
    _rightController.dispose();
    _topController.dispose();
    _bottomController.dispose();
    super.dispose();
  }

  void _applyAlignment() {
    final left = double.tryParse(_leftController.text) ?? 0;
    final right = double.tryParse(_rightController.text);
    final top = double.tryParse(_topController.text) ?? 0;
    final bottom = double.tryParse(_bottomController.text);

    HapticFeedback.lightImpact();
    widget.controller.alignItemByPixels(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
    );
    widget.onApply();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Horizontal alignment inputs
        Row(
          children: [
            Expanded(
              child: _PixelInputField(
                label: 'Left (px)',
                controller: _leftController,
                icon: Icons.format_align_left,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PixelInputField(
                label: 'Right (px)',
                controller: _rightController,
                icon: Icons.format_align_right,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Vertical alignment inputs
        Row(
          children: [
            Expanded(
              child: _PixelInputField(
                label: 'Top (px)',
                controller: _topController,
                icon: Icons.vertical_align_top,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PixelInputField(
                label: 'Bottom (px)',
                controller: _bottomController,
                icon: Icons.vertical_align_bottom,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Apply button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _applyAlignment,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.branding,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Apply Alignment',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}

class _PixelInputField extends StatelessWidget {
  const _PixelInputField({
    required this.label,
    required this.controller,
    required this.icon,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: Colors.grey[600]),
            hintText: '0',
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.branding, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}
