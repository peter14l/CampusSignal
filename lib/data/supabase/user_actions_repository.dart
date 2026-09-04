import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/mock/mock_data.dart';
import '../../models/event_model.dart';
import 'supabase_client.dart';

class UserStats {
  final int savedCount;
  final int appliedCount;
  final int remindersCount;

  const UserStats({
    this.savedCount = 0,
    this.appliedCount = 0,
    this.remindersCount = 0,
  });

  Map<String, int> toMap() => {
        'savedCount': savedCount,
        'appliedCount': appliedCount,
        'remindersCount': remindersCount,
      };
}

class UserReminder {
  final String id;
  final String userId;
  final String eventId;
  final DateTime remindAt;
  final EventModel? event;

  const UserReminder({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.remindAt,
    this.event,
  });

  factory UserReminder.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    EventModel? eventModel;
    if (json['events'] is Map<String, dynamic>) {
      eventModel = EventModel.fromJson(json['events']);
    }

    return UserReminder(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      eventId: json['event_id']?.toString() ?? '',
      remindAt: parseDate(json['remind_at']) ?? DateTime.now(),
      event: eventModel,
    );
  }
}

final userActionsRepositoryProvider = Provider<UserActionsRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return UserActionsRepository(client);
});

class UserActionsRepository {
  final SupabaseClient _client;

  // In-memory fallback caches initialized with rich mock dataset
  final Set<String> _cachedSavedEventIds = Set<String>.from(kMockSavedEventIds);
  final List<UserReminder> _cachedReminders = generateMockReminders().map((r) {
    return UserReminder(
      id: r.id,
      userId: r.userId,
      eventId: r.eventId,
      remindAt: r.remindAt,
      event: r.event,
    );
  }).toList();
  final Set<String> _cachedAppliedEventIds = {'evt-3'};

  UserActionsRepository(this._client);

  String? get _currentUserId => _client.auth.currentUser?.id;

  /// Checks if an event is bookmarked/saved by current user.
  Future<bool> isSaved(String eventId) async {
    final userId = _currentUserId;
    if (userId != null) {
      try {
        final response = await _client
            .from('saved_events')
            .select('id')
            .eq('user_id', userId)
            .eq('event_id', eventId)
            .maybeSingle();

        if (response != null) return true;
      } catch (e) {
        debugPrint('Error checking isSaved in Supabase for event $eventId: $e');
      }
    }

    return _cachedSavedEventIds.contains(eventId);
  }

  /// Toggles saved state for an event. Returns true if saved, false if unsaved.
  Future<bool> toggleSave(String eventId) async {
    final currentlySaved = _cachedSavedEventIds.contains(eventId);
    if (currentlySaved) {
      _cachedSavedEventIds.remove(eventId);
    } else {
      _cachedSavedEventIds.add(eventId);
    }

    final userId = _currentUserId;
    if (userId != null) {
      try {
        if (currentlySaved) {
          await _client
              .from('saved_events')
              .delete()
              .eq('user_id', userId)
              .eq('event_id', eventId);
        } else {
          await _client.from('saved_events').insert({
            'user_id': userId,
            'event_id': eventId,
            'created_at': DateTime.now().toIso8601String(),
          });
        }
      } catch (e) {
        debugPrint('Error syncing toggleSave to Supabase: $e');
      }
    }

    return !currentlySaved;
  }

  /// Fetches list of saved events for a specific user.
  Future<List<EventModel>> getSavedEvents(String userId) async {
    try {
      final response = await _client
          .from('saved_events')
          .select('event_id, events(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (response.isNotEmpty) {
        final events = <EventModel>[];
        for (final item in response) {
          if (item['events'] != null && item['events'] is Map<String, dynamic>) {
            events.add(EventModel.fromJson(item['events'] as Map<String, dynamic>));
          }
        }
        if (events.isNotEmpty) return events;
      }
    } catch (e) {
      debugPrint('Error fetching saved events from Supabase ($e). Using mock fallback.');
    }

    final allEvents = generateMockEvents();
    return allEvents.where((e) => _cachedSavedEventIds.contains(e.id)).toList();
  }

  /// Sets or toggles a reminder notification timestamp for an event.
  Future<bool> toggleReminder(String eventId, DateTime remindAt) async {
    final existingIndex = _cachedReminders.indexWhere((r) => r.eventId == eventId);
    final isReminded = existingIndex != -1;

    if (isReminded) {
      _cachedReminders.removeAt(existingIndex);
    } else {
      final allEvents = generateMockEvents();
      final event = allEvents.firstWhere(
        (e) => e.id == eventId,
        orElse: () => EventModel(id: eventId, title: 'Event $eventId'),
      );
      _cachedReminders.add(UserReminder(
        id: 'rem-${DateTime.now().millisecondsSinceEpoch}',
        userId: _currentUserId ?? 'user-sxuk-aarav-001',
        eventId: eventId,
        remindAt: remindAt,
        event: event,
      ));
    }

    final userId = _currentUserId;
    if (userId != null) {
      try {
        final existing = await _client
            .from('reminders')
            .select('id')
            .eq('user_id', userId)
            .eq('event_id', eventId)
            .maybeSingle();

        if (existing != null) {
          await _client
              .from('reminders')
              .delete()
              .eq('user_id', userId)
              .eq('event_id', eventId);
        } else {
          await _client.from('reminders').insert({
            'user_id': userId,
            'event_id': eventId,
            'remind_at': remindAt.toIso8601String(),
            'created_at': DateTime.now().toIso8601String(),
          });
        }
      } catch (e) {
        debugPrint('Error toggling reminder in Supabase: $e');
      }
    }

    return !isReminded;
  }

  /// Retrieves user reminders with embedded event details.
  Future<List<UserReminder>> getReminders(String userId) async {
    try {
      final response = await _client
          .from('reminders')
          .select('id, user_id, event_id, remind_at, events(*)')
          .eq('user_id', userId)
          .order('remind_at', ascending: true);

      if (response.isNotEmpty) {
        return response
            .map((json) => UserReminder.fromJson(json))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching reminders from Supabase ($e). Using mock fallback.');
    }

    return List.from(_cachedReminders);
  }

  /// Records an outgoing application click or submission for an event.
  Future<void> recordApplication(String eventId) async {
    _cachedAppliedEventIds.add(eventId);
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      await _client.from('applications').upsert({
        'user_id': userId,
        'event_id': eventId,
        'applied_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error recording application for event $eventId: $e');
    }
  }

  /// Returns user action statistics (saved, applied, reminders).
  Future<UserStats> getUserStats(String userId) async {
    int savedCount = _cachedSavedEventIds.length;
    int appliedCount = _cachedAppliedEventIds.length;
    int remindersCount = _cachedReminders.length;

    try {
      final savedResponse = await _client
          .from('saved_events')
          .select('id')
          .eq('user_id', userId);
      if (savedResponse.isNotEmpty) {
        savedCount = savedResponse.length;
      }
    } catch (e) {
      debugPrint('Error counting saved events: $e');
    }

    try {
      final appliedResponse = await _client
          .from('applications')
          .select('id')
          .eq('user_id', userId);
      if (appliedResponse.isNotEmpty) {
        appliedCount = appliedResponse.length;
      }
    } catch (e) {
      debugPrint('Error counting applications: $e');
    }

    try {
      final remindersResponse = await _client
          .from('reminders')
          .select('id')
          .eq('user_id', userId);
      if (remindersResponse.isNotEmpty) {
        remindersCount = remindersResponse.length;
      }
    } catch (e) {
      debugPrint('Error counting reminders: $e');
    }

    return UserStats(
      savedCount: savedCount,
      appliedCount: appliedCount,
      remindersCount: remindersCount,
    );
  }
}
