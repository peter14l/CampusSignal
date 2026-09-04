import 'dart:developer' as developer;
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/event_model.dart';

/// Riverpod provider for [CalendarSyncService].
final calendarSyncServiceProvider = Provider<CalendarSyncService>((ref) {
  return CalendarSyncService();
});

/// Service responsible for syncing campus events and registration deadlines
/// directly into the device's native calendar using add_2_calendar.
class CalendarSyncService {
  /// Adds the event to the user's native calendar.
  ///
  /// Maps title, description, venue (location), startsAt (startDate),
  /// and endsAt (endDate). If startsAt is null, falls back to current time.
  /// If endsAt is null, defaults to 1 hour after start time.
  /// Also sets a 30-minute pre-event reminder alert.
  Future<bool> addEventToCalendar(EventModel event) async {
    try {
      final startDate = event.startsAt ?? DateTime.now().add(const Duration(hours: 1));
      final endDate = event.endsAt ?? startDate.add(const Duration(hours: 1));

      final calendarEvent = Event(
        title: event.title,
        description: _buildEventDescription(event),
        location: event.venue ?? (event.format == 'online' ? 'Online' : 'Campus Venue'),
        startDate: startDate,
        endDate: endDate.isAfter(startDate) ? endDate : startDate.add(const Duration(hours: 1)),
        iosParams: const IOSParams(
          reminder: Duration(minutes: 30),
        ),
        androidParams: const AndroidParams(
          emailInvites: [],
        ),
      );

      return await Add2Calendar.addEvent2Cal(calendarEvent);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to add event to calendar',
        name: 'CalendarSyncService',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Adds a registration deadline reminder event to the user's native calendar.
  ///
  /// Creates an event spanning 1 hour leading up to the registration deadline,
  /// with a 2-hour pre-deadline alarm alert.
  Future<bool> addDeadlineReminderToCalendar(EventModel event) async {
    try {
      final deadline = event.deadlineAt ?? event.startsAt;
      if (deadline == null) {
        developer.log(
          'Cannot add deadline reminder: deadlineAt is null',
          name: 'CalendarSyncService',
        );
        return false;
      }

      final startDate = deadline.subtract(const Duration(hours: 1));
      final endDate = deadline;

      final calendarEvent = Event(
        title: '⏰ DEADLINE: ${event.title}',
        description: _buildDeadlineDescription(event),
        location: event.applyUrl ?? event.venue ?? 'CampusSignal App',
        startDate: startDate,
        endDate: endDate,
        iosParams: const IOSParams(
          reminder: Duration(hours: 2),
        ),
        androidParams: const AndroidParams(
          emailInvites: [],
        ),
      );

      return await Add2Calendar.addEvent2Cal(calendarEvent);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to add deadline reminder to calendar',
        name: 'CalendarSyncService',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  String _buildEventDescription(EventModel event) {
    final buffer = StringBuffer();
    if (event.description.isNotEmpty) {
      buffer.writeln(event.description);
      buffer.writeln();
    }
    buffer.writeln('Organizer: ${event.organizerName}');
    buffer.writeln('Category: ${event.category}');
    if (event.venue != null && event.venue!.isNotEmpty) {
      buffer.writeln('Venue: ${event.venue}');
    }
    if (event.applyUrl != null && event.applyUrl!.isNotEmpty) {
      buffer.writeln('Registration: ${event.applyUrl}');
    }
    return buffer.toString().trim();
  }

  String _buildDeadlineDescription(EventModel event) {
    final buffer = StringBuffer();
    buffer.writeln('Registration deadline for ${event.title}.');
    buffer.writeln();
    if (event.applyUrl != null && event.applyUrl!.isNotEmpty) {
      buffer.writeln('Direct Application Link: ${event.applyUrl}');
    }
    buffer.writeln('Organizer: ${event.organizerName}');
    buffer.writeln('Category: ${event.category}');
    return buffer.toString().trim();
  }
}
