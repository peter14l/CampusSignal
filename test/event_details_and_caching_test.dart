import 'package:flutter_test/flutter_test.dart';
import 'package:campus_signal/core/services/app_update_service.dart';
import 'package:campus_signal/data/repositories/events_repository.dart';
import 'package:campus_signal/models/event_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SupabaseClient mockClient;

  setUp(() {
    mockClient = SupabaseClient(
      'https://placeholder.supabase.co',
      'placeholder-anon-key',
    );
  });

  group('EventsRepository & Fallback Cache Tests', () {
    test('getFeedEvents populates in-memory cache and returns valid events', () async {
      final repo = EventsRepository(mockClient, isDemoMode: true);
      final events = await repo.getFeedEvents();

      expect(events.isNotEmpty, true);
      final first = events.first;

      // In-memory cache lookup for that ID should be instant and non-null
      final cached = await repo.getEventById(first.id);
      expect(cached, isNotNull);
      expect(cached!.id, first.id);
      expect(cached.title, first.title);
    });

    test('getEventById falls back gracefully to mock catalog for mock IDs', () async {
      final repo = EventsRepository(mockClient, isDemoMode: false);
      // Even without demo mode or remote db, mock IDs like evt-1 or evt-2 should resolve
      final event = await repo.getEventById('evt-1');
      expect(event, isNotNull);
      expect(event!.id, 'evt-1');
      expect(event.title.isNotEmpty, true);
    });

    test('getEventById returns null gracefully for truly non-existent event', () async {
      final repo = EventsRepository(mockClient, isDemoMode: false);
      final event = await repo.getEventById('non-existent-random-id-999');
      expect(event, isNull);
    });

    test('Private Internship Wall strictly hides internships from other colleges', () async {
      final repo = EventsRepository(mockClient, isDemoMode: true);

      // SXUK student sees SXUK internships
      final sxukEvents = await repo.getFeedEvents(
        category: 'internship',
        userCollegeId: 'sxuk',
      );
      expect(sxukEvents.any((e) => e.id == 'evt-3'), true);

      // Student from Jadavpur University (JU) querying internships MUST NOT see SXUK's private internships
      final juEvents = await repo.getFeedEvents(
        category: 'internship',
        userCollegeId: 'ju',
      );
      expect(juEvents.any((e) => e.id == 'evt-3' || e.id == 'evt-4'), false);

      // Pan-India feed view strictly excludes all internships
      final panIndiaEvents = await repo.getFeedEvents(
        scopeFilter: EventScope.interCollege,
      );
      expect(panIndiaEvents.any((e) => e.isInternship), false);
    });

    test('Pan-India inter-college events are visible across universities', () async {
      final repo = EventsRepository(mockClient, isDemoMode: true);

      // An SXUK student should be able to discover JU Srijan and IIT Kharagpur events
      final feed = await repo.getFeedEvents(
        userCollegeId: 'sxuk',
      );
      expect(feed.any((e) => e.id == 'evt-ju-1'), true);
      expect(feed.any((e) => e.id == 'evt-iit-1'), true);

      // Pan-India filter returns only interCollege events
      final interOnly = await repo.getFeedEvents(
        scopeFilter: EventScope.interCollege,
      );
      for (final ev in interOnly) {
        expect(ev.scope, EventScope.interCollege);
      }
    });

    test('Moderation queue holds pending events and approveEvent publishes them', () async {
      final repo = EventsRepository(mockClient, isDemoMode: true);

      // Pending event should NOT appear in general feed
      final feed = await repo.getFeedEvents(userCollegeId: 'sxuk');
      expect(feed.any((e) => e.id == 'evt-pending-1'), false);

      // But should appear in pending moderation queue
      final pending = await repo.getPendingEvents(collegeId: 'sxuk');
      expect(pending.any((e) => e.id == 'evt-pending-1'), true);

      // Approving event publishes it
      await repo.approveEvent('evt-pending-1', approvedBy: 'Faculty Lead');
      final updatedFeed = await repo.getFeedEvents(userCollegeId: 'sxuk');
      expect(updatedFeed.any((e) => e.id == 'evt-pending-1'), true);
    });

    test('AppUpdateService getDeviceArchitecture compiles and returns valid arch string', () {
      final service = AppUpdateService();
      final arch = service.getDeviceArchitecture();
      expect(arch, isNotEmpty);
    });
  });
}
