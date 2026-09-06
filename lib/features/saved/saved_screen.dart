import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/widgets/interactive_spring.dart';
import '../../core/widgets/m3e_event_card.dart';
import '../../core/widgets/m3e_states.dart';
import '../../core/widgets/micro_animated_icon.dart';
import '../../models/reminder_model.dart';
import 'saved_controller.dart';

class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedState = ref.watch(savedControllerProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final isSavedSegment = savedState.selectedSegment == SavedSegment.saved;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Saved & Reminders',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          MicroAnimatedIconButton.circle(
            size: 38,
            iconSize: 19,
            iconData: LucideIcons.search,
            color: colorScheme.onSurfaceVariant,
            backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            onPressed: () => context.push('/search'),
            tooltip: 'Search Opportunities',
          ),
          const SizedBox(width: 6),
          MicroAnimatedIconButton.circle(
            size: 38,
            iconSize: 19,
            iconData: LucideIcons.bell,
            color: colorScheme.onSurfaceVariant,
            backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            onPressed: () => context.push('/notifications'),
            tooltip: 'Notifications',
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: RefreshIndicator(
        color: colorScheme.primary,
        backgroundColor: colorScheme.surfaceContainerLowest,
        onRefresh: () => ref.read(savedControllerProvider.notifier).loadData(),
        child: Column(
          children: [
            // Segmented Button Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<SavedSegment>(
                  segments: [
                    ButtonSegment<SavedSegment>(
                      value: SavedSegment.saved,
                      icon: const Icon(LucideIcons.bookmark, size: 16),
                      label: Text(
                        'Bookmarks (${savedState.savedEvents.length})',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                    ButtonSegment<SavedSegment>(
                      value: SavedSegment.reminders,
                      icon: const Icon(LucideIcons.clock, size: 16),
                      label: Text(
                        'Reminders (${savedState.reminders.length})',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                  ],
                  selected: {savedState.selectedSegment},
                  onSelectionChanged: (Set<SavedSegment> newSelection) {
                    HapticFeedback.selectionClick();
                    ref.read(savedControllerProvider.notifier).setSegment(newSelection.first);
                  },
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ),
            ),

            // Content Area
            Expanded(
              child: savedState.isLoading && savedState.savedEvents.isEmpty && savedState.reminders.isEmpty
                  ? Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: colorScheme.primary,
                      ),
                    )
                  : isSavedSegment
                      ? _buildSavedEventsList(context, ref, savedState)
                      : _buildRemindersList(context, ref, savedState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedEventsList(
    BuildContext context,
    WidgetRef ref,
    SavedState savedState,
  ) {
    final savedEvents = savedState.savedEvents;

    if (savedEvents.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        children: const [
          SizedBox(height: 80),
          M3EEmptyState(
            icon: LucideIcons.bookmark,
            title: 'No saved items yet',
            message: 'Tap the bookmark icon on any campus signal or notice to save it for quick reference.',
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
      itemCount: savedEvents.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final event = savedEvents[index];
        return M3EEventCard(
          event: event,
          isSaved: true,
          heroTagSuffix: '_saved_${event.id}',
          onTap: () => context.push('/event/${event.id}'),
          onBookmarkTap: () {
            ref.read(savedControllerProvider.notifier).removeSavedEvent(event.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Removed "${event.title}" from saved items.'),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'UNDO',
                  onPressed: () {
                    ref.read(savedControllerProvider.notifier).toggleSave(event.id);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRemindersList(
    BuildContext context,
    WidgetRef ref,
    SavedState savedState,
  ) {
    final reminders = savedState.reminders;

    if (reminders.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        children: const [
          SizedBox(height: 80),
          M3EEmptyState(
            icon: LucideIcons.clock,
            title: 'No active reminders',
            message: 'Set deadline reminders on opportunities from event details to receive push notifications.',
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
      itemCount: reminders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final reminder = reminders[index];
        return _ReminderCard(
          reminder: reminder,
          onTap: () {
            if (reminder.eventId.isNotEmpty) {
              context.push('/event/${reminder.eventId}');
            }
          },
          onDelete: () {
            ref.read(savedControllerProvider.notifier).removeReminder(reminder.id);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Reminder removed.'),
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      },
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final ReminderModel reminder;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ReminderCard({
    required this.reminder,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final event = reminder.event;

    final dateFormat = DateFormat('EEE, MMM d, y • h:mm a');
    final formattedDate = dateFormat.format(reminder.remindAt);

    return InteractiveSpring(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Calendar Clock Icon Badge
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                LucideIcons.bellRing,
                color: colorScheme.onPrimaryContainer,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event?.title ?? 'Campus Opportunity Reminder',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  if (event?.organizerName != null) ...[
                    Text(
                      event!.organizerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 3),
                  ],
                  Row(
                    children: [
                      Icon(LucideIcons.alarmClock, size: 12, color: colorScheme.primary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Delete action button
            IconButton(
              icon: Icon(LucideIcons.trash2, size: 18, color: colorScheme.error),
              tooltip: 'Delete Reminder',
              onPressed: () {
                HapticFeedback.lightImpact();
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}

