import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/widgets/interactive_spring.dart';

/// Step 1: Upload Flyer / Image Touchpad for AI Announcement Creator
class AnnouncementUploadStep extends StatelessWidget {
  final VoidCallback onPickImage;
  final VoidCallback onManualCreate;

  const AnnouncementUploadStep({
    super.key,
    required this.onPickImage,
    required this.onManualCreate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pulse circle graphic
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.sparkles,
                size: 40,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Upload Poster for AI Extraction',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              'Select an event flyer or poster from your gallery. Gemini Multimodal AI extracts all deadlines, rules, venues, and targets automatically.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),

            // Big Upload Touch Card
            InteractiveSpring(
              onTap: onPickImage,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        LucideIcons.imagePlus,
                        size: 32,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Choose from Gallery',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'PNG, JPG, JPEG flyers supported',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Manual option
            TextButton.icon(
              onPressed: onManualCreate,
              icon: const Icon(LucideIcons.filePenLine, size: 16),
              label: const Text('Or create manually without image'),
            ),
          ],
        ),
      ),
    );
  }
}
