import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/services/calendar_sync_service.dart';
import '../../core/theme/motion.dart';
import '../../core/widgets/interactive_spring.dart';
import '../../core/widgets/m3e_header.dart';
import '../../core/widgets/m3e_states.dart';
import '../../models/event_model.dart';
import '../event_details/event_details_screen.dart';
import 'calendar_controller.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  final VoidCallback? onSearchTap;
  final VoidCallback? onProfileTap;

  const CalendarScreen({
    super.key,
    this.onSearchTap,
    this.onProfileTap,
  });

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _currentWeekStart;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calendarControllerProvider);
    final controller = ref.read(calendarControllerProvider.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: M3EHeaderBar(
        title: 'Calendar',
        onSearchTap: widget.onSearchTap,
        onProfileTap: widget.onProfileTap,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: colorScheme.primary,
          backgroundColor: colorScheme.surfaceContainerLowest,
          onRefresh: () => controller.loadCalendar(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // Segmented Sub-Header ("Month" vs "Agenda")
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Center(
                    child: Container(
                      width: 240,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: InteractiveSpring(
                              onTap: () =>
                                  controller.setViewMode(CalendarViewMode.month),
                              child: AnimatedContainer(
                                duration: AppMotion.durationShort3,
                                curve: AppMotion.emphasizedDecelerate,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  color: state.viewMode == CalendarViewMode.month
                                      ? colorScheme.secondaryContainer
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    'Month',
                                    style: textTheme.labelMedium?.copyWith(
                                      fontSize: 13,
                                      fontWeight: state.viewMode ==
                                              CalendarViewMode.month
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: state.viewMode ==
                                              CalendarViewMode.month
                                          ? colorScheme.onSecondaryContainer
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InteractiveSpring(
                              onTap: () =>
                                  controller.setViewMode(CalendarViewMode.agenda),
                              child: AnimatedContainer(
                                duration: AppMotion.durationShort3,
                                curve: AppMotion.emphasizedDecelerate,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  color: state.viewMode == CalendarViewMode.agenda
                                      ? colorScheme.secondaryContainer
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    'Agenda',
                                    style: textTheme.labelMedium?.copyWith(
                                      fontSize: 13,
                                      fontWeight: state.viewMode ==
                                              CalendarViewMode.agenda
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: state.viewMode ==
                                              CalendarViewMode.agenda
                                          ? colorScheme.onSecondaryContainer
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Scrollable Interactive Week Strip
              SliverToBoxAdapter(
                child: _buildWeekStrip(context, state, controller),
              ),

              // Agenda / Content
              if (state.isLoading)
                const SliverToBoxAdapter(
                  child: M3ELoadingState(itemCount: 3),
                )
              else if (state.errorMessage != null)
                SliverToBoxAdapter(
                  child: M3EErrorState(
                    message: state.errorMessage!,
                    onRetry: () => controller.loadCalendar(),
                  ),
                )
              else if (state.dayAgendas.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: M3EEmptyState(
                    icon: LucideIcons.calendarCheck,
                    title: 'No upcoming events',
                    message: 'Save events from the home feed to track them on your agenda.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final agenda = state.dayAgendas[index];
                        return _buildDayAgendaSection(context, agenda);
                      },
                      childCount: state.dayAgendas.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: InteractiveSpring(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Add personal event reminder')),
            );
          },
          pressedScale: 0.92,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              LucideIcons.plus,
              color: colorScheme.onPrimaryContainer,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeekStrip(
      BuildContext context, CalendarState state, CalendarController controller) {
    final days = List.generate(14, (i) => _currentWeekStart.add(Duration(days: i)));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      height: 94,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final date = days[index];
          final isSelected = date.year == state.selectedDate.year &&
              date.month == state.selectedDate.month &&
              date.day == state.selectedDate.day;

          final hasAgenda = state.dayAgendas.any((a) =>
              a.date.year == date.year &&
              a.date.month == date.month &&
              a.date.day == date.day);
          final hasConflict = state.dayAgendas.any((a) =>
              a.date.year == date.year &&
              a.date.month == date.month &&
              a.date.day == date.day &&
              a.hasConflict);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InteractiveSpring(
              onTap: () => controller.selectDate(date),
              pressedScale: 0.94,
              child: AnimatedContainer(
                duration: AppMotion.durationShort3,
                curve: AppMotion.emphasizedDecelerate,
                width: 56,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('E').format(date),
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? colorScheme.onPrimary.withValues(alpha: 0.9)
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      date.day.toString(),
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Indicator Dot
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.onPrimary
                            : (hasConflict
                                ? colorScheme.error
                                : (hasAgenda
                                    ? colorScheme.primary
                                    : Colors.transparent)),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDayAgendaSection(BuildContext context, CalendarDayAgenda agenda) {
    final dayLabel = DateFormat('EEE, d MMM').format(agenda.date);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day Header Label
          Text(
            dayLabel,
            style: textTheme.titleMedium?.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),

          // Time Conflict Detected Warning Badge (if conflict exists)
          if (agenda.hasConflict) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.error.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.triangleAlert,
                    size: 15,
                    color: colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Time Conflict Detected',
                    style: textTheme.labelSmall?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Event Cards inside this day
          if (agenda.hasConflict)
            _buildConflictingEventsLayout(context, agenda)
          else
            Column(
              children: agenda.events.map((event) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildAgendaEventCard(
                    context: context,
                    event: event,
                    accentColor: colorScheme.secondary,
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildConflictingEventsLayout(
    BuildContext context,
    CalendarDayAgenda agenda,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        // Connected vertical error line
        Positioned(
          left: 7,
          top: 24,
          bottom: 24,
          child: Container(
            width: 2,
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),

        // Events list with offset / highlighted design
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Column(
            children: agenda.events.asMap().entries.map((entry) {
              final index = entry.key;
              final event = entry.value;
              final isConflict = agenda.conflictingEventIds.contains(event.id);

              if (isConflict && index > 0) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8, left: 12),
                  child: _buildAgendaEventCard(
                    context: context,
                    event: event,
                    accentColor: colorScheme.tertiary,
                    isShiftedOverlapping: true,
                    timeHasConflict: true,
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildAgendaEventCard(
                  context: context,
                  event: event,
                  accentColor: isConflict ? colorScheme.primary : colorScheme.secondary,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAgendaEventCard({
    required BuildContext context,
    required EventModel event,
    required Color accentColor,
    bool isShiftedOverlapping = false,
    bool timeHasConflict = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final startTimeStr = event.startsAt != null
        ? DateFormat('h:mm a').format(event.startsAt!)
        : 'Time TBD';
    final endTimeStr = event.endsAt != null
        ? DateFormat('h:mm a').format(event.endsAt!)
        : '';
    final timeDisplay = endTimeStr.isNotEmpty
        ? '$startTimeStr - $endTimeStr'
        : startTimeStr;

    return InteractiveSpring(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(event: event),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isShiftedOverlapping
              ? colorScheme.surfaceContainerHighest
              : colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isShiftedOverlapping
                ? colorScheme.tertiary.withValues(alpha: 0.5)
                : colorScheme.outlineVariant.withValues(alpha: 0.22),
          ),
          boxShadow: isShiftedOverlapping
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Accent Color Bar
              Container(
                width: 4.5,
                color: accentColor,
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: textTheme.titleMedium?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            LucideIcons.clock,
                            size: 14,
                            color: timeHasConflict
                                ? colorScheme.error
                                : colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeDisplay,
                            style: textTheme.bodySmall?.copyWith(
                              fontSize: 13,
                              fontWeight: timeHasConflict
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: timeHasConflict
                                  ? colorScheme.error
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            event.format?.toLowerCase() == 'online'
                                ? LucideIcons.laptop
                                : LucideIcons.mapPin,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.venue != null && event.venue!.isNotEmpty
                                  ? event.venue!
                                  : 'SXUK Campus',
                              style: textTheme.bodySmall?.copyWith(
                                fontSize: 13,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Quick Add to Calendar Button
              Padding(
                padding: const EdgeInsets.only(right: 2),
                child: Center(
                  child: IconButton(
                    icon: Icon(
                      LucideIcons.calendarPlus,
                      color: colorScheme.primary,
                      size: 19,
                    ),
                    tooltip: 'Add to Calendar',
                    onPressed: () async {
                      final success = await ref
                          .read(calendarSyncServiceProvider)
                          .addEventToCalendar(event);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(
                                  success
                                      ? LucideIcons.calendarCheck
                                      : LucideIcons.calendar,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    success
                                        ? 'Added "${event.title}" to calendar!'
                                        : 'Opened calendar sync for "${event.title}"',
                                  ),
                                ),
                              ],
                            ),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),

              // Chevron Right
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Center(
                  child: Icon(
                    LucideIcons.chevronRight,
                    color: colorScheme.onSurfaceVariant,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
