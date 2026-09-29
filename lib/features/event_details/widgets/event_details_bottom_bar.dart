import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/widgets/interactive_spring.dart';
import '../../../core/widgets/m3e_morph_button.dart';

/// Glassmorphic floating bottom action bar with Reminder, Save, and Apply CTA
class EventDetailsBottomBar extends StatelessWidget {
  final bool isReminded;
  final bool isSaved;
  final bool isApplying;
  final VoidCallback onReminderPressed;
  final VoidCallback onSavePressed;
  final VoidCallback onApplyPressed;

  const EventDetailsBottomBar({
    super.key,
    required this.isReminded,
    required this.isSaved,
    required this.isApplying,
    required this.onReminderPressed,
    required this.onSavePressed,
    required this.onApplyPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.96),
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        MediaQuery.of(context).padding.bottom + 10,
      ),
      child: Row(
        children: [
          // Remind Notification Morph Action (Circle <-> Squircle)
          M3EMorphIconButton(
            size: 46,
            iconSize: 20,
            icon: LucideIcons.bell,
            selectedIcon: LucideIcons.bellRing,
            isSelected: isReminded,
            color: colorScheme.onSurfaceVariant,
            selectedColor: colorScheme.onPrimaryContainer,
            backgroundColor: colorScheme.surfaceContainerLow,
            selectedBackgroundColor: colorScheme.primaryContainer,
            onPressed: onReminderPressed,
            tooltip: isReminded ? 'Reminder set' : 'Set reminder',
            morphShape: M3EMorphShape.circleToSquircle,
          ),

          const SizedBox(width: 8),

          // Bookmark Morph Action (Circle <-> Squircle)
          M3EMorphIconButton(
            size: 46,
            iconSize: 20,
            icon: LucideIcons.bookmark,
            selectedIcon: LucideIcons.bookmarkCheck,
            isSelected: isSaved,
            color: colorScheme.onSurfaceVariant,
            selectedColor: colorScheme.primary,
            backgroundColor: colorScheme.surfaceContainerLow,
            selectedBackgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.2),
            onPressed: onSavePressed,
            tooltip: isSaved ? 'Saved' : 'Save event',
            morphShape: M3EMorphShape.circleToSquircle,
          ),

          const SizedBox(width: 12),

          // Primary Apply Now CTA Button
          Expanded(
            child: InteractiveSpring(
              onTap: isApplying ? null : onApplyPressed,
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: isApplying
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: colorScheme.onPrimary,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Apply Now',
                              style: textTheme.labelLarge?.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              LucideIcons.arrowUpRight,
                              color: colorScheme.onPrimary,
                              size: 18,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
