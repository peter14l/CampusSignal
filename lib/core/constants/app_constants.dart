import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Core application constants for CampusSignal
class AppConstants {
  AppConstants._();

  static const String appName = 'CampusSignal';
  static const String appTagline = 'Signal, not noise. Campus discovery simplified.';

  /// SXUK College Email Domain
  static const String collegeEmailDomain = '@sxuk.edu.in';

  /// College Branches / Departments
  static const List<String> branches = [
    'Computer Science & Engg',
    'Information Technology',
    'Data Science',
    'Electronics & Comm',
    'BCA',
    'MCA',
    'Commerce & Finance',
    'Management',
    'Law',
    'Mass Comm',
  ];

  /// College Academic Years
  static const List<int> years = [1, 2, 3, 4, 5];

  /// Common interest & skill tags
  static const List<String> commonTags = [
    'AI/ML',
    'Web Development',
    'Mobile App Dev',
    'Flutter',
    'Cloud/DevOps',
    'Cybersecurity',
    'UI/UX Design',
    'Blockchain',
    'Competitive Programming',
    'Data Analytics',
    'Fintech',
    'Robotics',
    'IoT',
    'Content & Media',
    'Entrepreneurship',
  ];

  /// Event Categories IDs
  static const String categoryAll = 'all';
  static const String categoryHackathon = 'hackathon';
  static const String categoryInternship = 'internship';
  static const String categoryWorkshop = 'workshop';
  static const String categoryFest = 'fest';
  static const String categorySeminar = 'seminar';
  static const String categoryClub = 'club';
  static const String categoryNetworking = 'networking';
  static const String categorySports = 'sports';

  /// Category list in presentation order
  static const List<String> categories = [
    categoryAll,
    categoryHackathon,
    categoryInternship,
    categoryWorkshop,
    categoryFest,
    categorySeminar,
    categoryClub,
    categoryNetworking,
    categorySports,
  ];

  /// Human-readable category labels
  static const Map<String, String> categoryLabels = {
    categoryAll: 'All',
    categoryHackathon: 'Hackathons',
    categoryInternship: 'Internships',
    categoryWorkshop: 'Workshops',
    categoryFest: 'Fests & Culture',
    categorySeminar: 'Seminars & Talks',
    categoryClub: 'Club Activities',
    categoryNetworking: 'Networking',
    categorySports: 'Sports & Games',
  };

  /// Singular labels for event badges/chips
  static const Map<String, String> categoryBadgeLabels = {
    categoryAll: 'All',
    categoryHackathon: 'Hackathon',
    categoryInternship: 'Internship',
    categoryWorkshop: 'Workshop',
    categoryFest: 'Fest',
    categorySeminar: 'Seminar',
    categoryClub: 'Club',
    categoryNetworking: 'Networking',
    categorySports: 'Sports',
  };

  /// Category icon mappings
  static const Map<String, IconData> categoryIcons = {
    categoryAll: LucideIcons.layoutGrid,
    categoryHackathon: LucideIcons.code,
    categoryInternship: LucideIcons.briefcase,
    categoryWorkshop: LucideIcons.wrench,
    categoryFest: LucideIcons.partyPopper,
    categorySeminar: LucideIcons.graduationCap,
    categoryClub: LucideIcons.users,
    categoryNetworking: LucideIcons.network,
    categorySports: LucideIcons.trophy,
  };

  /// Storage & Table names
  static const String profilesTable = 'profiles';
  static const String eventsTable = 'events';
  static const String eventTagsTable = 'event_tags';
  static const String savesTable = 'saves';
  static const String remindersTable = 'reminders';
  static const String applicationsTable = 'applications';
  static const String notificationsTable = 'notifications';
  static const String clubsTable = 'clubs';
}
