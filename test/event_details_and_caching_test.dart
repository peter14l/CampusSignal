import 'package:flutter_test/flutter_test.dart';
import 'package:campus_signal/core/services/app_update_service.dart';
import 'package:campus_signal/data/repositories/events_repository.dart';
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

    test('AppUpdateService getDeviceArchitecture compiles and returns valid arch string', () {
      final service = AppUpdateService();
      final arch = service.getDeviceArchitecture();
      expect(arch, isNotEmpty);
    });
  });
}
