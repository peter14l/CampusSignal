import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Step 2: AI Analyzing Loading Screen for Announcement Creator
class AnnouncementAnalyzingStep extends StatelessWidget {
  final Uint8List? selectedImageBytes;
  final double analysisProgress;
  final String analysisStatus;

  const AnnouncementAnalyzingStep({
    super.key,
    required this.selectedImageBytes,
    required this.analysisProgress,
    required this.analysisStatus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Poster thumbnail with scanning beam
            if (selectedImageBytes != null)
              Container(
                width: 160,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.primary, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.memory(
                    selectedImageBytes!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 28),

            SizedBox(
              width: 180,
              child: LinearProgressIndicator(
                value: analysisProgress,
                backgroundColor: colorScheme.surfaceContainerHighest,
                color: colorScheme.primary,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Gemini AI Multimodal Vision',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 6),

            Text(
              analysisStatus,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
