import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/mock/mock_data.dart';
import '../../models/event_model.dart';
import '../../models/reminder_model.dart';
import '../supabase/supabase_client.dart';
import '../../features/auth/auth_controller.dart';

export '../../core/mock/mock_data.dart' show kMockEvents, kMockSavedEventIds, kMockReminders;

/// Repository implementing the Events data layer.
class EventsRepository {
  final SupabaseClient _supabase;
  final bool isDemoMode;
  static const String _customEventsPrefKey = 'campussignal_custom_events';
  
  // Local in-memory caches for fast reactivity and offline fallback
  final List<EventModel> _cachedEvents;
  final Set<String> _savedEventIds;
  late final List<ReminderModel> _reminders;

  EventsRepository(this._supabase, {this.isDemoMode = false})
      : _cachedEvents = isDemoMode ? generateMockEvents() : [],
        _savedEventIds = isDemoMode ? Set<String>.from(kMockSavedEventIds) : <String>{},
        _reminders = isDemoMode ? generateMockReminders() : [] {
    _loadCustomEventsFromDisk();
  }

  Future<void> _loadCustomEventsFromDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList(_customEventsPrefKey) ?? [];
      for (final jsonStr in rawList) {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        final event = EventModel.fromJson(map);
        if (!_cachedEvents.any((e) => e.id == event.id)) {
          _cachedEvents.insert(0, event);
        }
      }
    } catch (e) {
      debugPrint('Error loading custom events from disk: $e');
    }
  }

  Future<void> _persistCustomEvent(EventModel event) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList(_customEventsPrefKey) ?? [];
      // Remove older copy if existing
      final updatedList = rawList.where((str) {
        try {
          final map = jsonDecode(str) as Map<String, dynamic>;
          return map['id'] != event.id;
        } catch (_) {
          return true;
        }
      }).toList();

      updatedList.insert(0, jsonEncode(event.toJson()));
      await prefs.setStringList(_customEventsPrefKey, updatedList);
    } catch (e) {
      debugPrint('Error saving custom event to disk: $e');
    }
  }

  /// Fetch ranked feed events with category and branch/department targeting filter.
  Future<List<EventModel>> getFeedEvents({
    String category = 'for_you',
    String? userBranch,
    String? targetDepartment,
  }) async {
    await _loadCustomEventsFromDisk();

    try {
      // In production with Supabase configured, query public published events
      var query = _supabase.from('events').select().eq('status', 'published');
      if (category != 'for_you' && category != 'deadlines_soon' && category != 'all' && category.isNotEmpty) {
        query = query.ilike('category', '%$category%');
      }
      final response = await query.order('starts_at', ascending: true);
      final List<dynamic> rows = (response as List<dynamic>?) ?? [];
      final dbEvents = rows
          .map((r) => EventModel.fromJson(r as Map<String, dynamic>))
          .toList();

      if (dbEvents.isNotEmpty || !isDemoMode) {
        // Merge custom user-created events with DB events
        for (final cached in _cachedEvents) {
          if (!dbEvents.any((e) => e.id == cached.id)) {
            dbEvents.insert(0, cached);
          }
        }
        return _filterAndRank(dbEvents, category, userBranch, targetDepartment);
      }
    } catch (e) {
      debugPrint('Supabase getFeedEvents fallback: $e');
    }

    if (!isDemoMode) {
      // Real mode with offline or empty DB: Only show custom events created by the user
      return _filterAndRank(_cachedEvents, category, userBranch, targetDepartment);
    }

    // Demo mode fallback to rich in-memory dataset
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
    if (catLower == 'for_you' || catLower == 'for you' || catLower.isEmpty || catLower == 'all') {
      filtered.sort((a, b) => (b.matchScore ?? 0.99).compareTo(a.matchScore ?? 0.99));
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
    final rankedEvent = event.copyWith(
      matchScore: event.matchScore ?? 0.99,
    );

    // Insert at index 0 in local cache for instant zero-latency UI update
    _cachedEvents.removeWhere((e) => e.id == rankedEvent.id);
    _cachedEvents.insert(0, rankedEvent);

    // Persist to local disk cache
    await _persistCustomEvent(rankedEvent);

    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await _supabase.from('events').insert({
          'id': rankedEvent.id,
          'title': rankedEvent.title,
          'description': rankedEvent.description,
          'category': rankedEvent.category,
          'organizer_name': rankedEvent.organizerName,
          'starts_at': rankedEvent.startsAt?.toIso8601String(),
          'deadline_at': rankedEvent.deadlineAt?.toIso8601String(),
          'venue': rankedEvent.venue,
          'format': rankedEvent.format,
          'eligibility_text': rankedEvent.eligibilityText,
          'eligibility_branches': rankedEvent.eligibilityBranches,
          'apply_url': rankedEvent.applyUrl,
          'poster_r2_key': rankedEvent.posterR2Key,
          'status': rankedEvent.status,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('Supabase createEvent sync error: $e');
    }

    return rankedEvent;
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
    if (!isDemoMode && _supabase.auth.currentUser != null) {
      try {
        final user = _supabase.auth.currentUser!;
        final response = await _supabase
            .from('saves')
            .select('event_id, events(*)')
            .eq('user_id', user.id)
            .order('saved_at', ascending: false);

        final events = <EventModel>[];
        for (final item in (response as List<dynamic>)) {
          if (item['events'] != null && item['events'] is Map<String, dynamic>) {
            events.add(EventModel.fromJson(item['events'] as Map<String, dynamic>));
          }
        }
        return events;
      } catch (e) {
        debugPrint('Supabase getSavedEvents fallback: $e');
      }
    }
    return _cachedEvents.where((e) => _savedEventIds.contains(e.id)).toList();
  }

  /// Get all active reminders.
  Future<List<ReminderModel>> getReminders() async {
    if (!isDemoMode && _supabase.auth.currentUser != null) {
      try {
        final user = _supabase.auth.currentUser!;
        final response = await _supabase
            .from('reminders')
            .select('id, user_id, event_id, remind_at, fired, events(*)')
            .eq('user_id', user.id)
            .order('remind_at', ascending: true);

        return (response as List<dynamic>).map((json) {
          final map = json as Map<String, dynamic>;
          EventModel? eventModel;
          if (map['events'] is Map<String, dynamic>) {
            eventModel = EventModel.fromJson(map['events']);
          }
          return ReminderModel(
            id: map['id']?.toString() ?? '',
            userId: map['user_id']?.toString() ?? user.id,
            eventId: map['event_id']?.toString() ?? '',
            remindAt: DateTime.tryParse(map['remind_at']?.toString() ?? '') ?? DateTime.now(),
            fired: map['fired'] == true,
            event: eventModel,
          );
        }).toList();
      } catch (e) {
        debugPrint('Supabase getReminders fallback: $e');
      }
    }
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
      userId: _supabase.auth.currentUser?.id ?? (isDemoMode ? 'mock-user-id' : 'current-user'),
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
  final isDemoMode = ref.watch(authControllerProvider.select((s) => s.isDemoMode));
  return EventsRepository(supabase, isDemoMode: isDemoMode);
});
