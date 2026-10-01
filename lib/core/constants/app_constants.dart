import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../models/college_model.dart';

/// Core application constants for CampusSignal
class AppConstants {
  AppConstants._();

  static const String appName = 'CampusSignal';
  static const String appTagline = 'Signal, not noise. Campus discovery simplified.';
  static const String appVersion = '1.4.0';
  static const String appBuildNumber = '15';
  static const String appVersionDisplay = 'v1.4.0 (Build 15)';

  /// Default College Fallback
  static const String defaultCollegeId = 'sxuk';
  static const String defaultCollegeName = "St. Xavier's University, Kolkata";
  static const String defaultCollegeShortCode = 'SXUK';

  /// Master Directory of Curated Indian Colleges & Universities
  static const List<CollegeModel> indianColleges = [
    CollegeModel(
      id: 'sxuk',
      name: "St. Xavier's University, Kolkata",
      shortCode: 'SXUK',
      city: 'Kolkata',
      state: 'West Bengal',
      domainPatterns: ['@sxuk.edu.in', '@sxuk.in'],
      popularBranches: [
        'B.Tech in CSE',
        'B.Tech in AI & ML',
        'B.Tech in ECE',
        'B.Sc. in Statistics and Data Science',
        'B.Com. (Honours)',
        'B.M.S. (Honours)',
        'M.Sc. Computer Science',
        'LLM. Law',
      ],
    ),
    CollegeModel(
      id: 'ju',
      name: 'Jadavpur University',
      shortCode: 'JU',
      city: 'Kolkata',
      state: 'West Bengal',
      domainPatterns: ['@jadavpuruniversity.in', '@jdvu.ac.in'],
      popularBranches: [
        'B.E. Computer Science & Engineering',
        'B.E. Electronics & Telecommunication',
        'B.E. Information Technology',
        'B.E. Mechanical Engineering',
        'B.E. Electrical Engineering',
        'M.C.A.',
        'M.Tech Computer Science',
      ],
    ),
    CollegeModel(
      id: 'iitkgp',
      name: 'Indian Institute of Technology Kharagpur',
      shortCode: 'IITKGP',
      city: 'Kharagpur',
      state: 'West Bengal',
      domainPatterns: ['@iitkgp.ac.in'],
      popularBranches: [
        'B.Tech in Computer Science and Engineering',
        'B.Tech in Artificial Intelligence',
        'B.Tech in Electronics & Electrical Comm.',
        'B.Tech in Mathematics & Computing',
        'Dual Degree B.Tech/M.Tech CSE',
      ],
    ),
    CollegeModel(
      id: 'iitb',
      name: 'Indian Institute of Technology Bombay',
      shortCode: 'IITB',
      city: 'Mumbai',
      state: 'Maharashtra',
      domainPatterns: ['@iitb.ac.in'],
      popularBranches: [
        'B.Tech Computer Science and Engineering',
        'B.Tech Electrical Engineering',
        'B.Tech Mechanical Engineering',
        'M.Tech Computer Science',
      ],
    ),
    CollegeModel(
      id: 'du',
      name: 'University of Delhi',
      shortCode: 'DU',
      city: 'New Delhi',
      state: 'Delhi',
      domainPatterns: ['@du.ac.in'],
      popularBranches: [
        'B.Sc. (Hons) Computer Science',
        'B.A. (Hons) Economics',
        'B.Com. (Honours)',
        'B.Sc. (Hons) Mathematics',
        'M.Sc. Informatics',
      ],
    ),
    CollegeModel(
      id: 'sxc',
      name: "St. Xavier's College (Autonomous), Kolkata",
      shortCode: 'SXC',
      city: 'Kolkata',
      state: 'West Bengal',
      domainPatterns: ['@sxccal.edu'],
      popularBranches: [
        'B.Sc. Computer Science (Honours)',
        'B.Com. (Honours)',
        'B.Sc. Statistics (Honours)',
        'B.Sc. Economics (Honours)',
        'B.Sc. Multimedia & Animation',
      ],
    ),
    CollegeModel(
      id: 'christ',
      name: 'Christ University',
      shortCode: 'CHRIST',
      city: 'Bengaluru',
      state: 'Karnataka',
      domainPatterns: ['@christuniversity.in'],
      popularBranches: [
        'B.Tech Computer Science & Engineering',
        'B.C.A. (Bachelor of Computer Applications)',
        'B.B.A. (Honours)',
        'B.Sc. Data Science',
      ],
    ),
    CollegeModel(
      id: 'bits',
      name: 'BITS Pilani',
      shortCode: 'BITS',
      city: 'Pilani',
      state: 'Rajasthan',
      domainPatterns: ['@pilani.bits-pilani.ac.in'],
      popularBranches: [
        'B.E. Computer Science',
        'B.E. Electrical & Electronics',
        'M.Sc. Mathematics',
        'M.Sc. Economics',
      ],
    ),
    CollegeModel(
      id: 'nitdgp',
      name: 'National Institute of Technology Durgapur',
      shortCode: 'NITDGP',
      city: 'Durgapur',
      state: 'West Bengal',
      domainPatterns: ['@nitdgp.ac.in'],
      popularBranches: [
        'B.Tech Computer Science and Engineering',
        'B.Tech Electronics & Comm. Engineering',
        'B.Tech Information Technology',
        'M.C.A.',
      ],
    ),
  ];

  /// Set of categories that are naturally open pan-India across institutions
  static const Set<String> defaultInterCollegeCategories = {
    'hackathon',
    'fest',
    'competition',
    'conference',
  };

  /// Pre-configured Fest Convenor Passkeys for demo & institutional staging
  static const Map<String, String> festPasskeyDirectory = {
    'XAVHACKS-26': 'fest-xavhacks',
    'DEMO-FEST-2026': 'fest-demo',
    'SRIJAN-26': 'fest-srijan',
    'KSHITIJ-26': 'fest-kshitij',
  };

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
