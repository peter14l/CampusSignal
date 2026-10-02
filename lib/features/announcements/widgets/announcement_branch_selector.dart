import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Target audience and department visibility selector
class AnnouncementBranchSelector extends StatelessWidget {
  final bool isCampusWide;
  final Set<String> selectedBranches;
  final List<String> availableBranches;
  final String? collegeShortCode;
  final ValueChanged<bool> onCampusWideChanged;
  final void Function(String branch, bool selected) onBranchToggle;

  const AnnouncementBranchSelector({
    super.key,
    required this.isCampusWide,
    required this.selectedBranches,
    required this.availableBranches,
    this.collegeShortCode,
    required this.onCampusWideChanged,
    required this.onBranchToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.school, size: 18, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'DEPARTMENT VISIBILITY',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              Switch(
                value: isCampusWide,
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  onCampusWideChanged(val);
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isCampusWide
                ? 'Broadcast to ALL branches across ${collegeShortCode ?? "campus"}'
                : 'Target specific departments only (Exclusive access)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isCampusWide
                  ? colorScheme.onSurfaceVariant
                  : colorScheme.primary,
              fontWeight: isCampusWide ? FontWeight.w400 : FontWeight.w600,
            ),
          ),
          if (!isCampusWide) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: availableBranches.map((branch) {
                final isSelected = selectedBranches.contains(branch);
                return FilterChip(
                  label: Text(branch),
                  selected: isSelected,
                  onSelected: (selected) {
                    HapticFeedback.selectionClick();
                    onBranchToggle(branch, selected);
                  },
                  selectedColor: colorScheme.primaryContainer,
                  checkmarkColor: colorScheme.onPrimaryContainer,
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurface,
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
