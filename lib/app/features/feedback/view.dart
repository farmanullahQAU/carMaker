import 'package:cardmaker/app/features/feedback/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FeedbackView extends StatelessWidget {
  const FeedbackView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FeedbackController());
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Send Feedback',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: colorScheme.surface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeader(theme, colorScheme),
              const SizedBox(height: 32),

              // Feedback Input Section
              _buildFeedbackInput(controller, theme, colorScheme),
              const SizedBox(height: 24),

              // Character Counter
              _buildCharacterCounter(controller, theme, colorScheme),
              const SizedBox(height: 32),

              // Submit Button
              _buildSubmitButton(controller, theme, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.feedback_outlined,
            size: 48,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'We\'d love to hear from you!',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your feedback helps us improve Artnie. Share your thoughts, suggestions, or report any issues.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackInput(
    FeedbackController controller,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Feedback',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller.feedbackController,
          maxLength: controller.maxCharacters,
          maxLines: 5,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: 'Type your feedback here...',
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.6),
            ),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colorScheme.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colorScheme.error, width: 2),
            ),
            contentPadding: const EdgeInsets.all(20),
            counterText: '', // Hide default counter, we'll show custom one
          ),
          buildCounter:
              (
                context, {
                required currentLength,
                required isFocused,
                maxLength,
              }) => null, // Hide default counter
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your feedback';
            }
            if (value.length > controller.maxCharacters) {
              return 'Feedback must be ${controller.maxCharacters} characters or less';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCharacterCounter(
    FeedbackController controller,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Obx(() {
      final count = controller.characterCount.value;
      final maxCount = controller.maxCharacters;
      final isNearLimit = count > maxCount * 0.8;
      final isOverLimit = count > maxCount;

      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '$count / $maxCount',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isOverLimit
                  ? colorScheme.error
                  : isNearLimit
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              fontWeight: isNearLimit ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSubmitButton(
    FeedbackController controller,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      final canSubmit = controller.canSubmit.value;

      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: canSubmit && !isLoading ? controller.submitFeedback : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            disabledBackgroundColor: colorScheme.surfaceContainerHighest,
            disabledForegroundColor: colorScheme.onSurfaceVariant,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.onPrimary,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.send_rounded,
                      size: 20,
                      color: canSubmit
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Submit Feedback',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: canSubmit
                            ? colorScheme.onPrimary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
        ),
      );
    });
  }
}
