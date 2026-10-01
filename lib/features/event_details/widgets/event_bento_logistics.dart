import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../models/event_model.dart';

/// 2x2 Bento Logistics Grid for Event Details Screen
class EventBentoLogistics extends StatelessWidget {
  final EventModel event;
  final VoidCallback onAddToCalendar;

  const EventBentoLogistics({
    super.key,
    required this.event,
    required this.onAddToCalendar,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Row 1: Date & Time + Location & Mode
        Row(
          children: [
            Expanded(
              child: _buildBentoTile(
                context: context,
                icon: LucideIcons.calendar,
                iconColor: colorScheme.primary,
                label: 'WHEN',
                mainText: event.formattedDateRange,
                subText: event.startsAt != null
                    ? '${DateFormat('h:mm a').format(event.startsAt!)} onwards'
                    : 'Schedule',
                actionWidget: InkWell(
                  onTap: onAddToCalendar,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.calendarPlus, size: 11, color: colorScheme.primary),
                        const SizedBox(width: 3),
                        Text(
                          'Add to Cal',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildBentoTile(
                context: context,
                icon: LucideIcons.mapPin,
                iconColor: const Color(0xFFEF5350),
                label: 'WHERE',
                mainText: (event.venue != null && event.venue!.isNotEmpty)
                    ? event.venue!
                    : 'SXUK Campus',
                subText: 'Mode: ${event.formattedFormat}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Row 2: Team Size + Eligibility
        Row(
          children: [
            Expanded(
              child: _buildBentoTile(
                context: context,
                icon: LucideIcons.usersRound,
                iconColor: const Color(0xFF26C6DA),
                label: 'TEAM FORMAT',
                mainText: (event.teamSizeText != null && event.teamSizeText!.isNotEmpty)
                    ? event.teamSizeText!
                    : 'Individual / Teams',
                subText: 'Participation',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildBentoTile(
                context: context,
                icon: LucideIcons.shieldCheck,
                iconColor: const Color(0xFF66BB6A),
                label: 'ELIGIBILITY',
                mainText: (event.eligibilityText != null && event.eligibilityText!.isNotEmpty)
                    ? event.eligibilityText!
                    : 'All Branches',
                subText: 'SXUK Students',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBentoTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String mainText,
    required String subText,
    Widget? actionWidget,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
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
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 14, color: iconColor),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        label,
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (actionWidget != null) actionWidget,
            ],
          ),
          const SizedBox(height: 8),
          Text(
            mainText,
            style: textTheme.titleSmall?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subText,
            style: textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: colorScheme.outline,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
