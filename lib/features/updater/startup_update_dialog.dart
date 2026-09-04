import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../models/app_update_info.dart';
import 'update_controller.dart';

class StartupUpdateDialog extends ConsumerWidget {
  final AppUpdateInfo update;
  final bool isMandatory;

  const StartupUpdateDialog({
    super.key,
    required this.update,
    this.isMandatory = false,
  });

  static Future<void> show(
    BuildContext context, {
    required AppUpdateInfo update,
    bool isMandatory = false,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: !isMandatory,
      barrierLabel: 'App Update',
      barrierColor: Colors.black.withValues(alpha: 0.75),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) => PopScope(
        canPop: !isMandatory,
        child: StartupUpdateDialog(
          update: update,
          isMandatory: isMandatory,
        ),
      ),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return Transform.scale(
          scale: Curves.easeOutBack.transform(anim1.value),
          child: Opacity(
            opacity: anim1.value,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final updateState = ref.watch(updateControllerProvider);
    final updateNotifier = ref.read(updateControllerProvider.notifier);

    final isDownloading = updateState.isDownloading;
    final isInstalling = updateState.isInstalling;
    final progress = updateState.downloadProgress;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Icon
              Center(
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, colorScheme.tertiary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    LucideIcons.sparkles,
                    color: colorScheme.onPrimary,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Title
              Text(
                'CampusSignal Update',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),

              // Subtitle / Version Pill
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Version ${update.version} (${update.formattedFileSize})',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Changelog Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(LucideIcons.listChecks, size: 16, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'What\'s New in this Release',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...update.changelogItems.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('• ', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                            Expanded(
                              child: Text(
                                item,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Progress Bar if Downloading
              if (isDownloading || isInstalling) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isInstalling ? 'Launching Package Installer...' : 'Downloading Update...',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        if (isDownloading)
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: isInstalling ? null : progress,
                        minHeight: 8,
                        backgroundColor: colorScheme.surfaceContainerHigh,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ],

              // Error Notice
              if (updateState.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    updateState.errorMessage!,
                    style: TextStyle(fontSize: 11.5, color: colorScheme.onErrorContainer),
                  ),
                ),
              ],

              // Action Buttons
              if (!isDownloading && !isInstalling) ...[
                FilledButton.icon(
                  onPressed: () => updateNotifier.startDownloadAndInstall(update),
                  icon: const Icon(LucideIcons.download, size: 18),
                  label: const Text('Update Now & Install', style: TextStyle(fontWeight: FontWeight.w700)),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                if (!isMandatory) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      updateNotifier.dismissPopup();
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Remind Me Later',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
