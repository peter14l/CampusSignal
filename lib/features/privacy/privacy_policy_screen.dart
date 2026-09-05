import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_constants.dart';
import '../../core/mock/mock_data.dart';
import '../../core/widgets/interactive_spring.dart';

class PrivacyPolicyScreen extends ConsumerWidget {
  const PrivacyPolicyScreen({super.key});

  void _exportPersonalData(BuildContext context) {
    final exportData = {
      'app': AppConstants.appName,
      'version': AppConstants.appVersionDisplay,
      'exported_at': DateTime.now().toIso8601String(),
      'profile': kDefaultProfile.toJson(),
      'data_retention_policy': 'Zero permanent telemetry. Ephemeral local caches only.',
    };

    final jsonStr = const JsonEncoder.withIndent('  ').convert(exportData);
    // ignore: deprecated_member_use
    Share.share(
      jsonStr,
      subject: 'CampusSignal_Personal_Data_Export.json',
    );
  }

  void _showDeleteDataConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete All Local Data?'),
        content: const Text(
          'This will purge all cached preferences, offline saved opportunities, and your local student academic profile from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('All local data and caches have been purged.'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Purge Data'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Privacy & Terms',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Header summary card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.lock,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Your Privacy at SXUK',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'CampusSignal is designed exclusively for St. Xavier\'s University Kolkata students. We collect only what is needed to personalize your event feed and deadline reminders. We never sell student data or show commercial ads.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Policy Sections
          _buildSectionTitle(context, '1. DATA WE COLLECT'),
          _buildPolicyCard(
            context,
            content:
                '• Profile Information: Name, SXUK college email (@sxuk.edu.in), academic branch, and year of study.\n• Preferences: Extracurricular interest tags (e.g. Hackathons, Workshops) and skills.\n• Activity: Saved events, scheduled deadline reminders, and recorded applications.',
          ),
          const SizedBox(height: 18),

          _buildSectionTitle(context, '2. HOW WE USE YOUR DATA'),
          _buildPolicyCard(
            context,
            content:
                '• Personalizing your Home Feed so events matching your branch, year, and skills rank higher.\n• Scheduling local push notifications for deadlines you have explicitly saved or requested.\n• Detecting calendar schedule conflicts between your saved events.',
          ),
          const SizedBox(height: 18),

          _buildSectionTitle(context, '3. DPDP ACT 2023 COMPLIANCE & STUDENT RIGHTS'),
          _buildPolicyCard(
            context,
            content:
                'In compliance with India\'s Digital Personal Data Protection (DPDP) Act 2023:\n• You have the right to view, update, or export your personal data at any time.\n• You can request complete deletion of your account and records.\n• For any questions or grievances, contact: support@campussignal.sxuk.edu.in',
          ),
          const SizedBox(height: 24),

          // Action Buttons: Export & Delete Account
          _buildSectionTitle(context, 'MANAGE YOUR DATA'),
          const SizedBox(height: 10),
          InteractiveSpring(
            onTap: () => _exportPersonalData(context),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.download,
                      color: theme.colorScheme.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Export My Data (JSON)',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Download a full copy of your profile and saved bookmarks.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(LucideIcons.chevronRight,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          InteractiveSpring(
            onTap: () => _showDeleteDataConfirmation(context),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: theme.colorScheme.error.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.trash2,
                      color: theme.colorScheme.error, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delete Account & Erasure Request',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Permanently erase all personal data from the servers.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(LucideIcons.chevronRight,
                      color: theme.colorScheme.error,
                      size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildPolicyCard(BuildContext context, {required String content}) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Text(
        content,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          height: 1.5,
        ),
      ),
    );
  }
}
