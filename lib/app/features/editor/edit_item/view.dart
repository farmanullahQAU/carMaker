import 'package:cardmaker/app/features/editor/edit_item/controller.dart';
import 'package:cardmaker/core/utils/language_detector.dart';
import 'package:cardmaker/widgets/common/stack_board/lib/stack_items.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdateTextView extends GetView<TextUpdateController> {
  final StackTextItem? item;

  const UpdateTextView({super.key, this.item});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TextUpdateController(existingItem: item));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          item != null ? 'Edit Text' : 'Add Text',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(
            () => controller.isSaving.value
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.check_rounded),
                    onPressed: controller.saveChanges,
                    tooltip: 'Save',
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.primaryContainer,
                      foregroundColor: colorScheme.onPrimaryContainer,
                    ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Language Selection - Professional Design
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
              child: Obx(
                () => _buildLanguageSelector(context, controller, theme),
              ),
            ),

            // Text editor area with proper constraints
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Obx(() => _buildTextEditor(context, controller, theme)),
              ),
            ),

            // Action buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outlineVariant.withOpacity(0.5),
                    width: 1,
                  ),
                ),
              ),
              child: Obx(() => _buildActionButtons(context, controller, theme)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(
    BuildContext context,
    TextUpdateController controller,
    ThemeData theme,
  ) {
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.translate_rounded,
                  size: 18,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Language',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildLanguageChip(
                  context,
                  controller,
                  LanguageType.english,
                  'English',
                  Icons.language,
                  theme,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildLanguageChip(
                  context,
                  controller,
                  LanguageType.urdu,
                  'Urdu',
                  Icons.text_fields_rounded,
                  theme,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildLanguageChip(
                  context,
                  controller,
                  LanguageType.auto,
                  'Auto',
                  Icons.auto_awesome_rounded,
                  theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageChip(
    BuildContext context,
    TextUpdateController controller,
    LanguageType type,
    String label,
    IconData icon,
    ThemeData theme,
  ) {
    final colorScheme = theme.colorScheme;
    final isSelected = controller.selectedLanguage.value == type;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          controller.selectedLanguage.value = type;
          controller.updateTextDirection();
        },
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.surfaceContainerLow
                : colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant.withOpacity(0.3),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 11,
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextEditor(
    BuildContext context,
    TextUpdateController controller,
    ThemeData theme,
  ) {
    final colorScheme = theme.colorScheme;

    return Directionality(
      textDirection: controller.textDirection.value,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: TextField(
            controller: controller.textController,
            maxLines: null,
            minLines: 5,
            keyboardType: TextInputType.multiline,
            textAlign: controller.textDirection.value == TextDirection.rtl
                ? TextAlign.right
                : TextAlign.left,
            textDirection: controller.textDirection.value,
            style: TextStyle(
              fontSize: 18,
              color: colorScheme.onSurface,
              height: 1.6,
              fontFamily: controller.isUrduFont.value
                  ? controller.selectedFont.value
                  : null,
            ),
            decoration: InputDecoration(
              hintText: controller.textDirection.value == TextDirection.rtl
                  ? 'اپنا متن یہاں ٹائپ کریں...'
                  : 'Type your text here...',
              hintStyle: TextStyle(
                color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                fontSize: 18,
              ),
              filled: false,
              fillColor: colorScheme.surfaceContainerLow,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
            autofocus: true,
            scrollController: ScrollController(),
            scrollPhysics: const ClampingScrollPhysics(),
            onChanged: (text) {
              if (controller.selectedLanguage.value == LanguageType.auto) {
                controller.detectAndUpdateLanguage(text);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    TextUpdateController controller,
    ThemeData theme,
  ) {
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: controller.isSaving.value ? null : () => Get.back(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: colorScheme.outlineVariant, width: 1.5),
            ),
            child: Text(
              'Cancel',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: FilledButton(
            onPressed: controller.isSaving.value
                ? null
                : controller.saveChanges,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              elevation: 0,
            ),
            child: controller.isSaving.value
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.onPrimary,
                      ),
                    ),
                  )
                : Text(
                    'Save',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimary,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
