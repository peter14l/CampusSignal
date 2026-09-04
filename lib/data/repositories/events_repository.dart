import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/mock/mock_data.dart';
import '../../models/event_model.dart';
import '../../models/reminder_model.dart';
import '../supabase/supabase_client.dart';

export '../../core/mock/mock_data.dart' show kMockEvents, kMockSavedEventIds, kMockReminders;

/// Repository implementing the Events data layer.
class EventsRepository {
  final SupabaseClient _supabase;
  
  // Local in-memory caches for fast reactivity and offline fallback
  final List<EventModel> _cachedEvents = generateMockEvents();
  final Set<String> _savedEventIds = Set<String>.from(kMockSavedEventIds);
  late final List<ReminderModel> _reminders = generateMockReminders(events: _cachedEvents);

  EventsRepository(this._supabase);

  /// Fetch ranked feed events with category and branch/department targeting filter.
  Future<List<EventModel>> getFeedEvents({
    String category = 'for_you',
    String? userBranch,
    String? targetDepartment,
  }) async {
    try {
      // In production with Supabase configured:
      if (_supabase.auth.currentUser != null) {
        var query = _supabase.from('events').select().eq('status', 'published');
        if (category != 'for_you' && category != 'deadlines_soon') {
          query = query.ilike('category', '%$category%');
        }
        final response = await query.order('starts_at', ascending: true);
        if (response.isNotEmpty) {
          final List<dynamic> rows = response as List<dynamic>;
          final dbEvents = rows
              .map((r) => EventModel.fromJson(r as Map<String, dynamic>))
              .toList();
          return _filterAndRank(dbEvents, category, userBranch, targetDepartment);
        }
      }
    } catch (e) {
      debugPrint('Supabase getFeedEvents fallback: $e');
    }

    // Fallback to rich in-memory dataset
    return _filterAndRank(_cachedEvents, category, userBranch, targetDepartment);
  }

  List<EventModel> _filterAndRank(
    List<EventModel> events,
    String category,
    String? userBranch,
    String? targetDepartment,
  ) {
    final catLower = category.toLowerCase().trim();
    List<EventModel> filtered = List.from(events);

    // 1. Filter by Target Department / Branch Visibility
    if (targetDepartment != null &&
        targetDepartment.isNotEmpty &&
        targetDepartment.toLowerCase() != 'all' &&
        targetDepartment.toLowerCase() != 'all branches') {
      filtered = filtered.where((e) => e.isTargetedForBranch(targetDepartment)).toList();
    } else if (userBranch != null && userBranch.isNotEmpty) {
      // Show campus-wide events PLUS events targeted to user's branch
      filtered = filtered.where((e) => e.isTargetedForBranch(userBranch)).toList();
    }

    // 2. Filter by Category
    if (catLower == 'for_you' || catLower == 'for you' || catLower.isEmpty) {
      filtered.sort((a, b) => (b.matchScore ?? 0).compareTo(a.matchScore ?? 0));
    } else if (catLower == 'deadlines_soon' || catLower == 'deadlines soon') {
      filtered = filtered.where((e) => e.deadlineAt != null).toList();
      filtered.sort((a, b) => a.deadlineAt!.compareTo(b.deadlineAt!));
    } else if (catLower == 'hackathons' || catLower == 'hackathon') {
      filtered = filtered.where((e) => e.category.toLowerCase().contains('hack')).toList();
    } else if (catLower == 'internships' || catLower == 'internship') {
      filtered = filtered.where((e) => e.category.toLowerCase().contains('intern')).toList();
    } else if (catLower == 'workshops' || catLower == 'workshop') {
      filtered = filtered.where((e) => e.category.toLowerCase().contains('workshop')).toList();
    } else if (catLower == 'fests' || catLower == 'fest') {
      filtered = filtered.where((e) => e.category.toLowerCase().contains('fest')).toList();
    } else if (catLower == 'seminars' || catLower == 'seminar') {
      filtered = filtered.where((e) => e.category.toLowerCase().contains('seminar')).toList();
    } else if (catLower == 'clubs' || catLower == 'club') {
      filtered = filtered.where((e) => e.category.toLowerCase().contains('club')).toList();
    } else {
      filtered = filtered.where((e) => e.category.toLowerCase() == catLower).toList();
    }

    return filtered;
  }

  /// Create and publish a new announcement
  Future<EventModel> createEvent(EventModel event) async {
    // Insert at index 0 in local cache for instant zero-latency UI update
    _cachedEvents.removeWhere((e) => e.id == event.id);
    _cachedEvents.insert(0, event);

    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await _supabase.from('events').insert({
          'id': event.id,
          'title': event.title,
          'description': event.description,
          'category': event.category,
          'organizer_name': event.organizerName,
          'starts_at': event.startsAt?.toIso8601String(),
          'deadline_at': event.deadlineAt?.toIso8601String(),
          'venue': event.venue,
          'format': event.format,
          'eligibility_text': event.eligibilityText,
          'eligibility_branches': event.eligibilityBranches,
          'apply_url': event.applyUrl,
          'poster_r2_key': event.posterR2Key,
          'status': event.status,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('Supabase createEvent sync error: $e');
    }

    return event;
  }

  /// Get single event details by ID.
  Future<EventModel?> getEventById(String id) async {
    try {
      if (_supabase.auth.currentUser != null) {
        final res = await _supabase.from('events').select().eq('id', id).maybeSingle();
        if (res != null) {
          return EventModel.fromJson(res);
        }
      }
    } catch (e) {
      debugPrint('Supabase getEventById error: $e');
    }

    try {
      return _cachedEvents.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Check if an event is bookmarked / saved.
  bool isEventSaved(String eventId) {
    return _savedEventIds.contains(eventId);
  }

  /// Toggle saved state for an event.
  Future<bool> toggleSave(String eventId) async {
    final currentlySaved = _savedEventIds.contains(eventId);
    if (currentlySaved) {
      _savedEventIds.remove(eventId);
    } else {
      _savedEventIds.add(eventId);
    }

    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        if (currentlySaved) {
          await _supabase
              .from('saves')
              .delete()
              .eq('user_id', user.id)
              .eq('event_id', eventId);
        } else {
          await _supabase.from('saves').insert({
            'user_id': user.id,
            'event_id': eventId,
            'saved_at': DateTime.now().toIso8601String(),
          });
        }
      }
    } catch (e) {
      debugPrint('Supabase toggleSave error: $e');
    }

    return !currentlySaved;
  }

  /// Get all saved events.
  Future<List<EventModel>> getSavedEvents() async {
    return _cachedEvents.where((e) => _savedEventIds.contains(e.id)).toList();
  }

  /// Get all active reminders.
  Future<List<ReminderModel>> getReminders() async {
    return List.from(_reminders);
  }

  /// Check if an event has an active reminder.
  bool isEventReminded(String eventId) {
    return _reminders.any((r) => r.eventId == eventId);
  }

  /// Add a reminder for an event.
  Future<ReminderModel> addReminder(String eventId, DateTime remindAt) async {
    final event = await getEventById(eventId);
    final reminder = ReminderModel(
      id: 'rem-${DateTime.now().millisecondsSinceEpoch}',
      userId: _supabase.auth.currentUser?.id ?? 'mock-user-id',
      eventId: eventId,
      remindAt: remindAt,
      event: event,
    );

    _reminders.removeWhere((r) => r.eventId == eventId);
    _reminders.add(reminder);

    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await _supabase.from('reminders').insert({
          'user_id': user.id,
          'event_id': eventId,
          'remind_at': remindAt.toIso8601String(),
          'fired': false,
        });
      }
    } catch (e) {
      debugPrint('Supabase addReminder error: $e');
    }

    return reminder;
  }

  /// Remove a reminder.
  Future<void> removeReminder(String reminderOrEventId) async {
    _reminders.removeWhere(
        (r) => r.id == reminderOrEventId || r.eventId == reminderOrEventId);

    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await _supabase
            .from('reminders')
            .delete()
            .eq('user_id', user.id)
            .or('id.eq.$reminderOrEventId,event_id.eq.$reminderOrEventId');
      }
    } catch (e) {
      debugPrint('Supabase removeReminder error: $e');
    }
  }

  /// Log application submission.
  Future<void> logApplication(String eventId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await _supabase.from('applications').upsert({
          'user_id': user.id,
          'event_id': eventId,
          'applied_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('Supabase logApplication error: $e');
    }
  }
}

/// Provider for EventsRepository.
final eventsRepositoryProvider = Provider<EventsRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return EventsRepository(supabase);
});
