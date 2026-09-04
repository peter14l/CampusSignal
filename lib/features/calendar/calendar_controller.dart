import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/events_repository.dart';
import '../../models/event_model.dart';

enum CalendarViewMode { month, agenda }

/// Represents an identified time conflict between two or more events.
class EventConflict {
  final EventModel eventA;
  final EventModel eventB;
  final String description;

  const EventConflict({
    required this.eventA,
    required this.eventB,
    required this.description,
  });
}

class CalendarDayAgenda {
  final DateTime date;
  final List<EventModel> events;
  final List<EventConflict> conflicts;
  final Set<String> conflictingEventIds;

  const CalendarDayAgenda({
    required this.date,
    required this.events,
    required this.conflicts,
    required this.conflictingEventIds,
  });

  bool get hasConflict => conflicts.isNotEmpty;
}

class CalendarState {
  final CalendarViewMode viewMode;
  final DateTime selectedDate;
  final List<EventModel> allEvents;
  final List<CalendarDayAgenda> dayAgendas;
  final bool isLoading;
  final String? errorMessage;

  const CalendarState({
    this.viewMode = CalendarViewMode.agenda,
    required this.selectedDate,
    this.allEvents = const [],
    this.dayAgendas = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  CalendarState copyWith({
    CalendarViewMode? viewMode,
    DateTime? selectedDate,
    List<EventModel>? allEvents,
    List<CalendarDayAgenda>? dayAgendas,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CalendarState(
      viewMode: viewMode ?? this.viewMode,
      selectedDate: selectedDate ?? this.selectedDate,
      allEvents: allEvents ?? this.allEvents,
      dayAgendas: dayAgendas ?? this.dayAgendas,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class CalendarController extends Notifier<CalendarState> {
  @override
  CalendarState build() {
    Future.microtask(() => loadCalendar());
    return CalendarState(
      selectedDate: DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ),
    );
  }

  EventsRepository get _repository => ref.read(eventsRepositoryProvider);

  Future<void> loadCalendar() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final savedEvents = await _repository.getSavedEvents();
      final reminders = await _repository.getReminders();
      final reminderEvents = reminders
          .where((r) => r.event != null)
          .map((r) => r.event!)
          .toList();

      // Combine and deduplicate
      final Map<String, EventModel> eventMap = {};
      for (final e in savedEvents) {
        eventMap[e.id] = e;
      }
      for (final e in reminderEvents) {
        eventMap[e.id] = e;
      }

      // If user has few saved items, supplement with feed events so agenda is rich
      if (eventMap.length < 4) {
        final feedEvents = await _repository.getFeedEvents(category: 'for_you');
        for (final e in feedEvents) {
          eventMap[e.id] = e;
        }
      }

      final allEvents = eventMap.values.toList();
      final dayAgendas = _computeDayAgendas(allEvents);

      state = state.copyWith(
        allEvents: allEvents,
        dayAgendas: dayAgendas,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load calendar events: $e',
      );
    }
  }

  void selectDate(DateTime date) {
    state = state.copyWith(
      selectedDate: DateTime(date.year, date.month, date.day),
    );
  }

  void setViewMode(CalendarViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  /// Conflict Detection Engine
  /// Analyzes events occurring on each day and detects overlaps in start/end time windows.
  List<CalendarDayAgenda> _computeDayAgendas(List<EventModel> events) {
    // Group events by normalized date (year, month, day)
    final Map<DateTime, List<EventModel>> grouped = {};

    for (final event in events) {
      if (event.startsAt == null) continue;
      final dayKey = DateTime(
        event.startsAt!.year,
        event.startsAt!.month,
        event.startsAt!.day,
      );
      grouped.putIfAbsent(dayKey, () => []).add(event);
    }

    final List<CalendarDayAgenda> agendas = [];

    // Sort days chronologically
    final sortedDays = grouped.keys.toList()..sort();

    for (final day in sortedDays) {
      final dayEvents = grouped[day]!;
      // Sort events by start time
      dayEvents.sort((a, b) => a.startsAt!.compareTo(b.startsAt!));

      final List<EventConflict> conflicts = [];
      final Set<String> conflictingIds = {};

      // Pairwise overlap detection algorithm
      for (int i = 0; i < dayEvents.length; i++) {
        for (int j = i + 1; j < dayEvents.length; j++) {
          final a = dayEvents[i];
          final b = dayEvents[j];

          if (a.startsAt == null || b.startsAt == null) continue;

          // Compute effective endsAt (fallback to startsAt + 1 hour if unspecified)
          final endA = a.endsAt ?? a.startsAt!.add(const Duration(hours: 1));
          final endB = b.endsAt ?? b.startsAt!.add(const Duration(hours: 1));

          // Overlap condition: startA < endB AND startB < endA
          if (a.startsAt!.isBefore(endB) && b.startsAt!.isBefore(endA)) {
            conflicts.add(
              EventConflict(
                eventA: a,
                eventB: b,
                description:
                    'Overlap between "${a.title}" and "${b.title}"',
              ),
            );
            conflictingIds.add(a.id);
            conflictingIds.add(b.id);
          }
        }
      }

      agendas.add(
        CalendarDayAgenda(
          date: day,
          events: dayEvents,
          conflicts: conflicts,
          conflictingEventIds: conflictingIds,
        ),
      );
    }

    return agendas;
  }
}

final calendarControllerProvider =
    NotifierProvider<CalendarController, CalendarState>(CalendarController.new);
