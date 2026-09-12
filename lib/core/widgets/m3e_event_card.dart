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
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.25),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.025),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row: Category Badge + Approaching Deadline Pill
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
                          horizontal: 10,
                          vertical: 4.5,
                        ),
                        decoration: BoxDecoration(
                          color: event.isDeadlineSoon
                              ? colorScheme.errorContainer.withValues(alpha: 0.85)
                              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.clock,
                              size: 12.5,
                              color: event.isDeadlineSoon
                                  ? colorScheme.onErrorContainer
                                  : colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4.5),
                            Text(
                              event.deadlineLabel,
                              style: textTheme.labelSmall?.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
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

                const SizedBox(height: 12),

                // Title: Refined font weight and modern line height
                Text(
                  event.title,
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                    height: 1.3,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 10),

                // Streamlined Metadata: Unified, clean tags
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.calendar,
                          size: 13.5,
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          event.formattedDateRange,
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    if (event.venue != null && event.venue!.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.mapPin,
                            size: 13.5,
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${event.venue!} • ${event.formattedFormat}',
                            style: textTheme.bodySmall?.copyWith(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                const SizedBox(height: 14),

                // Footer: Clean whitespace separation, subtle match pill & bookmark toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Match / Organizer Tag Pill
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.sparkles,
                              size: 13,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                event.matchedTags.isNotEmpty
                                    ? 'Matches: ${event.matchedTags.take(2).join(', ')}'
                                    : event.organizerName,
                                style: textTheme.labelSmall?.copyWith(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.primary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
