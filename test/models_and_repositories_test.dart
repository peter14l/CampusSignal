import 'package:flutter_test/flutter_test.dart';
import 'package:campus_signal/models/college_model.dart';
import 'package:campus_signal/models/event_model.dart';
import 'package:campus_signal/models/profile_model.dart';
import 'package:campus_signal/models/notification_model.dart';
import 'package:campus_signal/features/notifications/notifications_controller.dart';

void main() {
  group('CollegeModel Tests', () {
    test('Default fallback and JSON serialization works', () {
      final college = CollegeModel.fromJson(null);
      expect(college.id, 'sxuk');
      expect(college.shortCode, 'SXUK');
      expect(college.name, "St. Xavier's University, Kolkata");

      const customCollege = CollegeModel(
        id: 'ju',
        name: 'Jadavpur University',
        shortCode: 'JU',
        city: 'Kolkata',
        state: 'West Bengal',
        domainPatterns: ['@jadavpuruniversity.in'],
        popularBranches: ['B.E. Computer Science & Engineering', 'M.C.A.'],
      );

      final json = customCollege.toJson();
      expect(json['id'], 'ju');
      expect(json['short_code'], 'JU');

      final fromJson = CollegeModel.fromJson(json);
      expect(fromJson, customCollege);
      expect(fromJson.popularBranches.length, 2);
    });
  });
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

    test('Parses multi-college scoping and moderation status', () {
      final json = {
        'id': 'evt-inter-1',
        'title': 'National AI Challenge',
        'category': 'Hackathons',
        'scope': 'interCollege',
        'moderation_status': 'pendingApproval',
        'college_id': 'ju',
        'college_name': 'Jadavpur University',
        'college_short_code': 'JU',
        'fest_id': 'fest-srijan',
      };

      final event = EventModel.fromJson(json);
      expect(event.isInterCollege, true);
      expect(event.isIntraCollege, false);
      expect(event.moderationStatus, EventModerationStatus.pendingApproval);
      expect(event.collegeShortCode, 'JU');
      expect(event.festId, 'fest-srijan');
      expect(event.isInternship, false);

      final internshipJson = {
        'id': 'evt-intern-1',
        'title': 'Software Engineering Intern',
        'category': 'Internships',
        'college_id': 'sxuk',
      };
      final internEvent = EventModel.fromJson(internshipJson);
      expect(internEvent.isInternship, true);
      expect(internEvent.isIntraCollege, true);
    });
  });

  group('ProfileModel Tests', () {
    test('Parses profile json with multi-college role & verification', () {
      final json = {
        'id': 'user-1',
        'full_name': 'Alex Rivera',
        'college_email': 'alex@campus.edu',
        'college_id': 'ju',
        'college_short_code': 'JU',
        'role': 'festAdmin',
        'is_verified_student': true,
        'roll_number': 'JU/CSE/24/01',
        'managed_fest_ids': ['fest-srijan'],
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
      expect(profile.collegeShortCode, 'JU');
      expect(profile.role, UserRole.festAdmin);
      expect(profile.isVerifiedStudent, true);
      expect(profile.rollNumber, 'JU/CSE/24/01');
      expect(profile.canModerate, true);
      expect(profile.canPublishDirectly, true);
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

  group('NotificationModel Tests', () {
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
  });

  group('NotificationsState & Design Laws Tests', () {
    test('Restore notification supports Undo operation in state', () {
      final item = NotificationItem(
        id: 'test-undo-1',
        title: 'Important Notice',
        message: 'Classes rescheduled',
        type: 'event',
        createdAt: DateTime.now(),
        isRead: false,
      );

      final stateWithItem = NotificationsState(notifications: [item]);
      expect(stateWithItem.notifications.length, 1);

      // Simulating deletion
      final stateAfterDelete = stateWithItem.copyWith(
        notifications: stateWithItem.notifications.where((n) => n.id != item.id).toList(),
      );
      expect(stateAfterDelete.notifications.any((n) => n.id == item.id), false);

      // Simulating undo restoration
      final stateAfterUndo = stateAfterDelete.copyWith(
        notifications: [item, ...stateAfterDelete.notifications],
      );
      expect(stateAfterUndo.notifications.any((n) => n.id == item.id), true);
    });
  });
}
