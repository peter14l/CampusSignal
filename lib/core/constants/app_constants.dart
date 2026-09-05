import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Core application constants for CampusSignal
class AppConstants {
  AppConstants._();

  static const String appName = 'CampusSignal';
  static const String appTagline = 'Signal, not noise. Campus discovery simplified.';
  static const String appVersion = '1.0.5';
  static const String appBuildNumber = '6';
  static const String appVersionDisplay = 'v1.0.5 (Build 6)';

  /// SXUK College Email Domain
  static const String collegeEmailDomain = '@sxuk.edu.in';

  /// College Branches / Academic Programmes categorized by Degree Level and School
  static const Map<String, Map<String, List<String>>> categorizedProgrammes = {
    'Undergraduate (UG)': {
      'Faculty of Commerce & Management': [
        'B.Com. (Honours)',
        'B.M.S. (Honours)',
      ],
      'Faculty of Arts & Humanities': [
        'B.A. (Honours) in English with Minor in Psychology & Mass Communication',
        'B.A. (Honours) in Economics with Minor in Statistics',
        'B.A. (Honours) in Mass Communication with Minor in Psychology and Film Studies',
        'B.A. (Honours) in Psychology with Minor in Mass Communication & Social Work',
      ],
      'Faculty of Science & Technology': [
        'B.Sc. (Honours) in Statistics and Data Science',
        'B.Tech in CSE',
        'B.Tech in AI & ML',
        'B.Tech in ECE',
        'B.Tech in IT',
      ],
    },
    'Postgraduate & Doctoral (PG / Ph.D.)': {
      'Postgraduate (PG)': [
        'M.A. Economics',
        'M.A. English',
        'M.A. Mass Communication',
        'M.A. Psychology',
        'M.S.W Social Work',
        'M.Com. Commerce',
        'M.Sc. Statistics',
        'LLM. Law',
        'M.Sc. Computer Science',
      ],
      'Doctoral (Ph.D.)': [
        'Ph.D. in Commerce',
        'Ph.D. in Economics',
        'Ph.D. in English',
        'Ph.D. in Law',
        'Ph.D. in Management',
        'Ph.D. in Mass Communication',
        'Ph.D. in Psychology',
        'Ph.D. in Social Work',
      ],
    },
  };

  /// All official SXUK programmes in a flat list
  static const List<String> branches = [
    // Undergraduate (UG)
    'B.Com. (Honours)',
    'B.M.S. (Honours)',
    'B.A. (Honours) in English with Minor in Psychology & Mass Communication',
    'B.A. (Honours) in Economics with Minor in Statistics',
    'B.A. (Honours) in Mass Communication with Minor in Psychology and Film Studies',
    'B.A. (Honours) in Psychology with Minor in Mass Communication & Social Work',
    'B.Sc. (Honours) in Statistics and Data Science',
    'B.Tech in CSE',
    'B.Tech in AI & ML',
    'B.Tech in ECE',
    'B.Tech in IT',
    // Postgraduate (PG)
    'M.A. Economics',
    'M.A. English',
    'M.A. Mass Communication',
    'M.A. Psychology',
    'M.S.W Social Work',
    'M.Com. Commerce',
    'M.Sc. Statistics',
    'LLM. Law',
    'M.Sc. Computer Science',
    // Doctoral (Ph.D.)
    'Ph.D. in Commerce',
    'Ph.D. in Economics',
    'Ph.D. in English',
    'Ph.D. in Law',
    'Ph.D. in Management',
    'Ph.D. in Mass Communication',
    'Ph.D. in Psychology',
    'Ph.D. in Social Work',
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
