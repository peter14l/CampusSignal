import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../models/event_model.dart';
import 'category_chip.dart';
import 'interactive_spring.dart';
import 'm3e_morph_button.dart';

/// Reusable M3 Expressive Event Card component matching the Stitch design specifications.
class M3EEventCard extends StatelessWidget {
  final EventModel event;
  final bool isSaved;
  final VoidCallback? onTap;
  final VoidCallback? onBookmarkTap;
  final String heroTagSuffix;

  const M3EEventCard({
    super.key,
    required this.event,
    this.isSaved = false,
    this.onTap,
    this.onBookmarkTap,
    this.heroTagSuffix = '',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final heroTag = 'event_card_${event.id}$heroTagSuffix';

    return RepaintBoundary(
      child: Hero(
        tag: heroTag,
        flightShuttleBuilder: (flightContext, animation, flightDirection,
            fromHeroContext, toHeroContext) {
          return Material(
            type: MaterialType.transparency,
            child: toHeroContext.widget,
          );
        },
        child: InteractiveSpring(
          onTap: onTap,
          pressedScale: 0.98,
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row: Category Badge + Deadline Chip
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Category Badge
                    CategoryChip(category: event.category),

                    // Deadline Badge if approaching
                    if (event.deadlineAt != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: event.isDeadlineSoon
                              ? colorScheme.errorContainer
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.clock,
                              size: 13,
                              color: event.isDeadlineSoon
                                  ? colorScheme.onErrorContainer
                                  : colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              event.deadlineLabel,
                              style: textTheme.labelSmall?.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: event.isDeadlineSoon
                                    ? colorScheme.onErrorContainer
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 10),

                // Title
                Text(
                  event.title,
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Info Lines: Date & Location
                Row(
                  children: [
                    Icon(
                      LucideIcons.calendar,
                      size: 15,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        event.formattedDateRange,
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                if (event.venue != null && event.venue!.isNotEmpty)
                  Row(
                    children: [
                      Icon(
                        LucideIcons.mapPin,
                        size: 15,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${event.venue} • ${event.formattedFormat}',
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 12),

                // Footer: Matched Tags & Save/Bookmark Button
                Container(
                  padding: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Matched tags
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.sparkles,
                              size: 14,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                event.matchedTags.isNotEmpty
                                    ? 'Matches: ${event.matchedTags.take(2).join(', ')}'
                                    : 'Organizer: ${event.organizerName}',
                                style: textTheme.bodySmall?.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.primary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // M3 Expressive Shape-Morphing Bookmark Button (Circle <-> Squircle)
                      M3EMorphIconButton.cardToggle(
                        size: 34,
                        iconSize: 18,
                        icon: LucideIcons.bookmark,
                        selectedIcon: LucideIcons.bookmarkCheck,
                        isSelected: isSaved,
                        color: colorScheme.onSurfaceVariant,
                        selectedColor: colorScheme.primary,
                        backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        selectedBackgroundColor: colorScheme.primaryContainer,
                        onPressed: onBookmarkTap,
                        tooltip: isSaved ? 'Remove from Saved' : 'Save Event',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
