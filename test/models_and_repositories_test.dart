import 'package:flutter_test/flutter_test.dart';
import 'package:campus_signal/models/event_model.dart';
import 'package:campus_signal/models/profile_model.dart';
import 'package:campus_signal/models/club_model.dart';
import 'package:campus_signal/models/notification_model.dart';
import 'package:campus_signal/data/supabase/user_actions_repository.dart';

void main() {
  group('EventModel Tests', () {
    test('Defensive parsing handles null and empty map', () {
      final event = EventModel.fromJson(null);
      expect(event.id, isEmpty);
      expect(event.title, 'Untitled Event');
      expect(event.category, 'General');
      expect(event.matchedTags, isEmpty);
      expect(event.isDeadlineSoon, false);
      expect(event.isDeadlinePassed, false);
      expect(event.deadlineLabel, 'No Deadline');
    });

    test('Parses full json payload and helpers work accurately', () {
      final now = DateTime.now();
      final deadline = now.add(const Duration(hours: 12));
      final starts = now.add(const Duration(days: 2));
      final ends = now.add(const Duration(days: 2, hours: 4));

      final json = {
        'id': 'evt-123',
        'title': 'Hackathon 2026',
        'description': 'AI Builders Hackathon',
        'category': 'Technical',
        'organizer_name': 'GDG Campus',
        'organizer_club_id': 'club-01',
        'starts_at': starts.toIso8601String(),
        'ends_at': ends.toIso8601String(),
        'deadline_at': deadline.toIso8601String(),
        'venue': 'Auditorium A',
        'format': 'hybrid',
        'eligibility_text': 'All engineering students',
        'eligibility_years': ['3rd Year', '4th Year'],
        'eligibility_branches': ['CSE', 'ECE'],
        'team_size_text': '2-4 members',
        'apply_url': 'https://example.com/apply',
        'source_url': 'https://example.com/source',
        'poster_r2_key': 'posters/hack2026.jpg',
        'status': 'published',
        'metadata': {'featured': true},
        'match_score': 0.95,
        'matched_tags': ['AI', 'Flutter'],
      };

      final event = EventModel.fromJson(json);

      expect(event.id, 'evt-123');
      expect(event.title, 'Hackathon 2026');
      expect(event.isDeadlineSoon, true);
      expect(event.isDeadlinePassed, false);
      expect(event.deadlineLabel.startsWith('Closes in'), true);
      expect(event.formattedFormat, 'Hybrid');
      expect(event.eligibilityYears.length, 2);
      expect(event.eligibilityBranches.length, 2);
      expect(event.matchScore, 0.95);

      final exported = event.toJson();
      expect(exported['id'], 'evt-123');
      expect(exported['format'], 'hybrid');
    });

    test('Handles dirty data types without throwing', () {
      final dirtyJson = {
        'id': 999,
        'title': 12345,
        'starts_at': 'invalid-date',
        'deadline_at': null,
        'eligibility_years': '1st Year, 2nd Year',
        'match_score': '0.88',
        'metadata': 'not a map',
      };

      final event = EventModel.fromJson(dirtyJson);
      expect(event.id, '999');
      expect(event.title, '12345');
      expect(event.startsAt, isNull);
      expect(event.eligibilityYears, ['1st Year', '2nd Year']);
      expect(event.matchScore, 0.88);
      expect(event.metadata, isEmpty);
    });
  });

  group('ProfileModel Tests', () {
    test('Parses profile json properly', () {
      final json = {
        'id': 'user-1',
        'full_name': 'Alex Rivera',
        'college_email': 'alex@campus.edu',
        'branch': 'CSE',
        'year': '3',
        'semester': 5,
        'avatar_url': 'https://photos.google.com/avatar123',
        'interests': ['AI', 'Robotics'],
        'skills': ['Dart', 'Flutter', 'Python'],
        'metadata': {'theme': 'dark'},
      };

      final profile = ProfileModel.fromJson(json);
      expect(profile.id, 'user-1');
      expect(profile.fullName, 'Alex Rivera');
      expect(profile.year, 3);
      expect(profile.semester, 5);
      expect(profile.semesterLabel, 'Semester 5');
      expect(profile.avatarUrl, 'https://photos.google.com/avatar123');
      expect(profile.isOnboardingComplete, true);
      expect(profile.interests.contains('AI'), true);
      expect(profile.skills.contains('Flutter'), true);
    });

    test('Detects incomplete Google profile needing onboarding', () {
      const newGoogleProfile = ProfileModel(
        id: 'google-user-123',
        fullName: 'New Student',
        collegeEmail: 'student@sxuk.edu.in',
        avatarUrl: 'https://lh3.googleusercontent.com/a/photo',
        branch: null,
        semester: null,
      );

      expect(newGoogleProfile.isOnboardingComplete, false);
    });
  });

  group('ClubModel and NotificationModel Tests', () {
    test('ClubModel parsing and serializing', () {
      final json = {
        'id': 'club-99',
        'name': 'Robotics Club',
        'description': 'Building next-gen bots',
        'logo_r2_key': 'logos/robotics.png',
      };
      final club = ClubModel.fromJson(json);
      expect(club.id, 'club-99');
      expect(club.name, 'Robotics Club');
      expect(club.logoR2Key, 'logos/robotics.png');
    });

    test('NotificationModel parsing', () {
      final json = {
        'id': 'notif-1',
        'user_id': 'u1',
        'type': 'deadline',
        'title': 'Deadline Tomorrow',
        'body': 'Hackathon closes in 24 hours',
        'read': 0,
      };
      final notif = NotificationModel.fromJson(json);
      expect(notif.id, 'notif-1');
      expect(notif.read, false);
      expect(notif.type, 'deadline');
    });

    test('UserStats data object test', () {
      const stats = UserStats(savedCount: 5, appliedCount: 2, remindersCount: 3);
      expect(stats.savedCount, 5);
      expect(stats.appliedCount, 2);
      expect(stats.remindersCount, 3);
      expect(stats.toMap()['savedCount'], 5);
    });
  });
}
