import '../../models/event_model.dart';
import '../../models/notification_model.dart';
import '../../models/profile_model.dart';
import '../../models/reminder_model.dart';

/// Realistic default student profile for SXUK.
final ProfileModel kDefaultProfile = ProfileModel(
  id: 'user-sxuk-aarav-001',
  fullName: 'Aarav Sharma',
  collegeEmail: 'aarav.sharma@sxuk.edu.in',
  branch: 'B.Tech in CSE',
  year: 3,
  semester: 5,
  interests: const [
    'AI/ML',
    'Flutter',
    'Web Development',
    'Competitive Programming',
  ],
  skills: const [
    'Flutter',
    'Dart',
    'Python',
    'React',
    'Git',
    'FastAPI',
    'PostgreSQL',
  ],
  metadata: const {
    'bio':
        'Pre-final year CS student passionate about building AI-powered mobile apps and scalable cloud backends.',
    'avatar_url':
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
    'github': 'https://github.com/aaravsharma',
    'linkedin': 'https://linkedin.com/in/aaravsharma',
    'batch': '2023-2027',
    'roll_number': 'SXUK/CSE/23/042',
    'cgpa': 8.94,
    'onboarding_completed': true,
  },
  createdAt: DateTime(2024, 8, 1),
  updatedAt: DateTime.now(),
);

/// Factory generating fresh realistic events dynamically relative to DateTime.now().
List<EventModel> generateMockEvents() {
  final now = DateTime.now();
  final tomorrow = DateTime(now.year, now.month, now.day + 1);

  return [
    EventModel(
      id: 'evt-1',
      title: 'Global AI Challenge 2026',
      description:
          'Join the flagship 48-hour global AI & ML hackathon. Build next-gen generative AI applications, autonomous agents, and multi-modal workflows. Mentors from Google DeepMind, Microsoft, and OpenAI will be on-site to guide you. Free food, swag, and \$10,000 cloud credits for all finalist teams.',
      category: 'Hackathons',
      organizerName: 'Tech Society SXUK & GDSC',
      startsAt: now.add(const Duration(days: 3, hours: 9)),
      endsAt: now.add(const Duration(days: 5, hours: 18)),
      deadlineAt: now.add(const Duration(days: 2, hours: 23, minutes: 59)),
      venue: 'Innovation Hub & SXUK Central Auditorium',
      format: 'hybrid',
      eligibilityText:
          'Open to all college years. CS/IT preferred; multidisciplinary teams highly encouraged.',
      eligibilityYears: const ['1', '2', '3', '4'],
      eligibilityBranches: const ['CSE', 'IT', 'ECE', 'Data Science'],
      teamSizeText: '2 to 4 members',
      applyUrl: 'https://campus-signal.org/apply/global-ai-challenge-2026',
      posterR2Key:
          'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?auto=format&fit=crop&w=1200&q=80',
      matchScore: 0.98,
      matchedTags: const ['Python', 'AI/ML', 'Flutter', 'Hackathons'],
    ),
    EventModel(
      id: 'evt-2',
      title: 'XavCode Hackathon 2026',
      description:
          'SXUK\'s premier 24-hour algorithmic & rapid product development sprint. Tackle real-world campus sustainability and student productivity problem statements with cash prize pools up to ₹1,50,000.',
      category: 'Hackathons',
      organizerName: 'SXUK ACM Student Chapter',
      startsAt: now.add(const Duration(days: 6, hours: 10)),
      endsAt: now.add(const Duration(days: 7, hours: 10)),
      deadlineAt: now.add(const Duration(days: 4, hours: 20)),
      venue: 'Sci-Tech Lab Complex, 3rd Floor',
      format: 'in_person',
      eligibilityText: 'Open to all SXUK students (Years 1 to 4).',
      eligibilityYears: const ['1', '2', '3', '4'],
      eligibilityBranches: const ['CSE', 'IT', 'ECE', 'All Branches'],
      teamSizeText: '2 to 3 members',
      applyUrl: 'https://xavcode.sxuk.edu.in',
      posterR2Key:
          'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?auto=format&fit=crop&w=1200&q=80',
      matchScore: 0.94,
      matchedTags: const ['Competitive Programming', 'Web Dev', 'CS 3rd Year'],
    ),
    EventModel(
      id: 'evt-3',
      title: 'Google SWE Summer Intern 2026',
      description:
          'Applications are now open for Google Software Engineering Summer Internship 2026. Collaborate with engineering teams working on planetary-scale distributed systems, machine intelligence, and mobile operating systems.',
      category: 'Internships',
      organizerName: 'Placement Cell SXUK',
      startsAt: now.add(const Duration(days: 14, hours: 10)),
      endsAt: now.add(const Duration(days: 75)),
      // Closes in 36 hours to test "Closes tomorrow / Closes in 36h" deadline alert styling
      deadlineAt: now.add(const Duration(hours: 36)),
      venue: 'Bangalore / Hyderabad HQ (Hybrid)',
      format: 'hybrid',
      eligibilityText:
          'B.Tech 3rd year students graduating in 2027 majoring in CS, IT, or related fields.',
      eligibilityYears: const ['3'],
      eligibilityBranches: const ['CSE', 'IT', 'ECE'],
      teamSizeText: 'Individual',
      applyUrl: 'https://careers.google.com/students/swe-intern-2026',
      posterR2Key:
          'https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&w=1200&q=80',
      matchScore: 0.96,
      matchedTags: const ['CS 3rd Year', 'Python', 'Flutter', 'Algorithms'],
    ),
    EventModel(
      id: 'evt-4',
      title: 'FinTech Summer Analyst 2026',
      description:
          'High-impact quantitative engineering & algorithmic trading summer analyst role. Work alongside senior portfolio researchers to design low-latency execution engines and predictive financial data pipelines.',
      category: 'Internships',
      organizerName: 'Department of Management & Corporate Relations',
      startsAt: now.add(const Duration(days: 20, hours: 9)),
      endsAt: now.add(const Duration(days: 80)),
      deadlineAt: now.add(const Duration(days: 5, hours: 18)),
      venue: 'Mumbai Financial District (In-Person)',
      format: 'in_person',
      eligibilityText:
          'Pre-final year undergraduate students with strong analytical and programming acumen.',
      eligibilityYears: const ['3'],
      eligibilityBranches: const ['CSE', 'IT', 'Data Science', 'Economics'],
      teamSizeText: 'Individual',
      applyUrl: 'https://campus-signal.org/apply/fintech-summer-analyst',
      posterR2Key:
          'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?auto=format&fit=crop&w=1200&q=80',
      matchScore: 0.90,
      matchedTags: const ['CS 3rd Year', 'Python', 'Competitive Programming'],
    ),
    // TIME CONFLICT EVENT A (Tomorrow 14:00 - 16:30)
    EventModel(
      id: 'evt-5',
      title: 'Mastering React Server Components',
      description:
          'An intensive hands-on masterclass breaking down Next.js 15 App Router architecture, asynchronous server actions, React Compiler memoization, and low-latency SSR edge caching patterns.',
      category: 'Workshops',
      organizerName: 'Web Developers Guild SXUK',
      startsAt: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 14, 0),
      endsAt: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 16, 30),
      deadlineAt: now.add(const Duration(hours: 18)),
      venue: 'CS Block, Room 304',
      format: 'in_person',
      eligibilityText:
          'Students with foundational knowledge of JavaScript/TypeScript and React.',
      eligibilityYears: const ['1', '2', '3', '4'],
      eligibilityBranches: const ['All Branches'],
      teamSizeText: 'Individual',
      applyUrl: 'https://campus-signal.org/workshops/react-server-components',
      posterR2Key:
          'https://images.unsplash.com/photo-1633356122544-f134324a6cee?auto=format&fit=crop&w=1200&q=80',
      matchScore: 0.92,
      matchedTags: const ['Web Dev', 'React', 'CS 3rd Year'],
    ),
    // TIME CONFLICT EVENT B (Tomorrow 15:00 - 17:30 - Overlaps with evt-5 on the same day!)
    EventModel(
      id: 'evt-6',
      title: 'Hands-on Flutter & Riverpod',
      description:
          'Build reactive, production-grade cross-platform mobile applications using Flutter 3.x, Riverpod 2.x code generation, Supabase Auth/Postgres integration, and Material 3 Expressive motion designs.',
      category: 'Workshops',
      organizerName: 'Mobile Developers Club',
      startsAt: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 15, 0),
      endsAt: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 17, 30),
      deadlineAt: now.add(const Duration(hours: 16)),
      venue: 'Incubation Center Seminar Room B',
      format: 'in_person',
      eligibilityText:
          'Open to all years interested in mobile app craftsmanship and Dart.',
      eligibilityYears: const ['1', '2', '3', '4'],
      eligibilityBranches: const ['All Branches'],
      teamSizeText: 'Individual',
      applyUrl: 'https://campus-signal.org/workshops/flutter-riverpod',
      posterR2Key:
          'https://images.unsplash.com/photo-1551650975-87deedd944c3?auto=format&fit=crop&w=1200&q=80',
      matchScore: 0.97,
      matchedTags: const ['Flutter', 'Mobile Dev', 'AI/ML', 'CS 3rd Year'],
    ),
    EventModel(
      id: 'evt-7',
      title: 'Xavotsav Cultural & Tech Fest 2026',
      description:
          'The grand annual 3-day cultural and technology confluence of SXUK featuring Battle of Bands, Hack-in-the-Dark, Robowars, EDM Pro-Night, and theatrical exhibitions.',
      category: 'Fests',
      organizerName: 'Student Council SXUK',
      startsAt: now.add(const Duration(days: 5, hours: 10)),
      endsAt: now.add(const Duration(days: 7, hours: 23)),
      deadlineAt: now.add(const Duration(days: 3, hours: 12)),
      venue: 'Main Campus Grounds & Open Air Theatre',
      format: 'in_person',
      eligibilityText: 'Open to all college students with valid College ID Card.',
      eligibilityYears: const ['1', '2', '3', '4'],
      eligibilityBranches: const ['All Branches'],
      teamSizeText: 'Solo & Team Registrations',
      applyUrl: 'https://xavotsav.sxuk.edu.in',
      posterR2Key:
          'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=1200&q=80',
      matchScore: 0.88,
      matchedTags: const ['Fests', 'Tech', 'Music', 'Networking'],
    ),
    EventModel(
      id: 'evt-8',
      title: 'Next-Gen Cloud & Microservices Seminar',
      description:
          'Keynote session with AWS Principal Solutions Architects on serverless edge computing, Kubernetes multi-cluster mesh, zero-trust security architecture, and distributed observability.',
      category: 'Seminars',
      organizerName: 'Department of Computer Science & Engineering',
      startsAt: now.add(const Duration(days: 8, hours: 11)),
      endsAt: now.add(const Duration(days: 8, hours: 13, minutes: 30)),
      deadlineAt: now.add(const Duration(days: 7, hours: 18)),
      venue: 'Fr. Leeming Hall & Live Stream',
      format: 'hybrid',
      eligibilityText: 'Students, research scholars, and faculty members.',
      eligibilityYears: const ['2', '3', '4'],
      eligibilityBranches: const ['CSE', 'IT', 'ECE'],
      teamSizeText: 'Individual',
      applyUrl: 'https://campus-signal.org/seminars/cloud-microservices',
      posterR2Key:
          'https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&w=1200&q=80',
      matchScore: 0.86,
      matchedTags: const ['Web Dev', 'Cloud', 'Seminars', 'CS 3rd Year'],
    ),
    EventModel(
      id: 'evt-9',
      title: 'Algorithmic Problem Solving & System Design',
      description:
          'Intensive masterclass on dynamic programming, graph theory shortest path algorithms, scalable distributed cache design, and mock technical interview breakdowns.',
      category: 'Workshops',
      organizerName: 'Coding Ninjas & SXUK Tech Society',
      startsAt: now.add(const Duration(days: 3, hours: 16)),
      endsAt: now.add(const Duration(days: 3, hours: 18, minutes: 30)),
      deadlineAt: now.add(const Duration(days: 2, hours: 12)),
      venue: 'Sci-Tech Block, Rm 402',
      format: 'in_person',
      eligibilityText:
          'Recommended for 2nd and 3rd year engineering students preparing for technical placements.',
      eligibilityYears: const ['2', '3', '4'],
      eligibilityBranches: const ['CSE', 'IT', 'ECE'],
      teamSizeText: 'Individual',
      applyUrl: 'https://campus-signal.org/workshops/dsa-system-design',
      posterR2Key:
          'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80',
      matchScore: 0.93,
      matchedTags: const ['Competitive Programming', 'Python', 'CS 3rd Year'],
    ),
    EventModel(
      id: 'evt-10',
      title: 'Campus Robotics & Embedded AI Expo',
      description:
          'Annual robotics showcase featuring autonomous drones, computer vision rover bots, robotic arms, and TinyML sensor demonstrations developed by undergraduate innovators.',
      category: 'Seminars',
      organizerName: 'IEEE SXUK Student Branch',
      startsAt: now.add(const Duration(days: 9, hours: 10)),
      endsAt: now.add(const Duration(days: 9, hours: 17)),
      deadlineAt: now.add(const Duration(days: 8, hours: 12)),
      venue: 'Moot Court & Robotics Lab',
      format: 'in_person',
      eligibilityText: 'Open for all students, visitors, and robotics hobbyists.',
      eligibilityYears: const ['1', '2', '3', '4'],
      eligibilityBranches: const ['All Branches'],
      teamSizeText: 'Individual or Project Teams',
      applyUrl: 'https://campus-signal.org/expo/robotics-2026',
      posterR2Key:
          'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?auto=format&fit=crop&w=1200&q=80',
      matchScore: 0.84,
      matchedTags: const ['AI/ML', 'Robotics', 'Hardware', 'Seminars'],
    ),
    EventModel(
      id: 'evt-11',
      title: 'Venture Capital Pitch & Startup Showcase',
      category: 'Club',
      description:
          'Pitch your early-stage software or hardware startup idea before real venture capitalists, angel investors, and seasoned campus startup founders. Seed grant prizes up to ₹2,00,000.',
      organizerName: 'SXUK E-Cell (Entrepreneurship Cell)',
      startsAt: now.add(const Duration(days: 12, hours: 14)),
      endsAt: now.add(const Duration(days: 12, hours: 19)),
      deadlineAt: now.add(const Duration(days: 10, hours: 23, minutes: 59)),
      venue: 'Management Hall & Zoom',
      format: 'hybrid',
      eligibilityText:
          'All student startups with a working prototype or validated business model.',
      eligibilityYears: const ['1', '2', '3', '4'],
      eligibilityBranches: const ['All Branches'],
      teamSizeText: '1 to 4 founders',
      applyUrl: 'https://ecell.sxuk.edu.in/pitch2026',
      posterR2Key:
          'https://images.unsplash.com/photo-1556761175-5973dc0f32e7?auto=format&fit=crop&w=1200&q=80',
      matchScore: 0.82,
      matchedTags: const ['Web Dev', 'Entrepreneurship', 'Networking'],
    ),
    EventModel(
      id: 'evt-12',
      title: 'Inter-College Badminton Derby',
      category: 'Sports',
      description:
          'Annual inter-college badminton tournament under floodlights. Men singles, women singles, and mixed doubles fixtures.',
      organizerName: 'Sports Council SXUK',
      startsAt: now.add(const Duration(days: 4, hours: 17)),
      endsAt: now.add(const Duration(days: 4, hours: 21)),
      deadlineAt: now.add(const Duration(days: 3, hours: 18)),
      venue: 'Indoor Sports Complex, Court 1 & 2',
      format: 'in_person',
      eligibilityText:
          'Valid college ID required for participant registration & spectators.',
      eligibilityYears: const ['1', '2', '3', '4'],
      eligibilityBranches: const ['All Branches'],
      teamSizeText: 'Singles / Doubles',
      applyUrl: 'https://campus-signal.org/sports/badminton-2026',
      posterR2Key:
          'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?auto=format&fit=crop&w=1200&q=80',
      matchScore: 0.75,
      matchedTags: const ['Sports', 'Badminton', 'Clubs'],
    ),
  ];
}

/// Static snapshot list of mock events
final List<EventModel> kMockEvents = generateMockEvents();

/// Saved event IDs providing rich out-of-the-box saved items, including conflicting pair.
final Set<String> kMockSavedEventIds = {
  'evt-1', // Global AI Challenge
  'evt-3', // Google SWE Intern
  'evt-5', // React Server Components (conflicts with evt-6)
  'evt-6', // Flutter & Riverpod (conflicts with evt-5)
  'evt-7', // Xavotsav Fest
  'evt-9', // Algorithmic Problem Solving
};

/// Factory generating realistic reminders including both conflicting events for calendar testing.
List<ReminderModel> generateMockReminders({List<EventModel>? events}) {
  final eventList = events ?? generateMockEvents();
  final eventMap = {for (var e in eventList) e.id: e};
  final now = DateTime.now();

  return [
    ReminderModel(
      id: 'rem-1',
      userId: 'user-sxuk-aarav-001',
      eventId: 'evt-1',
      remindAt: now.add(const Duration(days: 2, hours: 12)),
      event: eventMap['evt-1'],
    ),
    ReminderModel(
      id: 'rem-2',
      userId: 'user-sxuk-aarav-001',
      eventId: 'evt-5',
      remindAt: now.add(const Duration(hours: 12)),
      event: eventMap['evt-5'],
    ),
    ReminderModel(
      id: 'rem-3',
      userId: 'user-sxuk-aarav-001',
      eventId: 'evt-6',
      remindAt: now.add(const Duration(hours: 14)),
      event: eventMap['evt-6'],
    ),
    ReminderModel(
      id: 'rem-4',
      userId: 'user-sxuk-aarav-001',
      eventId: 'evt-3',
      remindAt: now.add(const Duration(hours: 24)),
      event: eventMap['evt-3'],
    ),
  ];
}

final List<ReminderModel> kMockReminders = generateMockReminders();

/// Factory generating realistic notifications (today and earlier).
List<NotificationModel> generateMockNotifications() {
  final now = DateTime.now();

  return [
    NotificationModel(
      id: 'notif-1',
      userId: 'user-sxuk-aarav-001',
      type: 'deadline',
      title: 'Upcoming Deadline: Google SWE Intern',
      body:
          'Applications for Google SWE Summer Intern 2026 close tomorrow at 11:59 PM. Review your resume on the portal.',
      eventId: 'evt-3',
      actionUrl: '/event/evt-3',
      read: false,
      createdAt: now.subtract(const Duration(minutes: 25)),
    ),
    NotificationModel(
      id: 'notif-2',
      userId: 'user-sxuk-aarav-001',
      type: 'event',
      title: 'Time Conflict Detected',
      body:
          'You have overlapping events scheduled for tomorrow: "Mastering React Server Components" (2:00 PM) and "Hands-on Flutter & Riverpod" (3:00 PM).',
      eventId: 'evt-6',
      actionUrl: '/calendar',
      read: false,
      createdAt: now.subtract(const Duration(hours: 2)),
    ),
    NotificationModel(
      id: 'notif-3',
      userId: 'user-sxuk-aarav-001',
      type: 'group',
      title: 'Hackathon Team Invitation',
      body:
          'Priya Sen invited you to join team "NeuralCoders" for Global AI Challenge 2026.',
      eventId: 'evt-1',
      actionUrl: '/event/evt-1',
      read: false,
      createdAt: now.subtract(const Duration(hours: 5)),
    ),
    NotificationModel(
      id: 'notif-4',
      userId: 'user-sxuk-aarav-001',
      type: 'event',
      title: 'New Event Matching Your Profile',
      body:
          '"Hands-on Flutter & Riverpod" matches your Flutter & Mobile Dev skills (97% Match).',
      eventId: 'evt-6',
      actionUrl: '/event/evt-6',
      read: true,
      createdAt: now.subtract(const Duration(days: 1, hours: 4)),
    ),
    NotificationModel(
      id: 'notif-5',
      userId: 'user-sxuk-aarav-001',
      type: 'advisor',
      title: 'Placement Cell Announcement',
      body:
          'Please ensure your 5th semester marksheets and GitHub links are up to date on SXUK Portal before internship drives.',
      read: true,
      createdAt: now.subtract(const Duration(days: 2, hours: 6)),
    ),
    NotificationModel(
      id: 'notif-6',
      userId: 'user-sxuk-aarav-001',
      type: 'announcement',
      title: 'Xavotsav 2026 Registrations Open',
      body:
          'Battle of Bands, Robowars, and EDM Night passes are now available for registered SXUK students.',
      eventId: 'evt-7',
      actionUrl: '/event/evt-7',
      read: true,
      createdAt: now.subtract(const Duration(days: 3, hours: 2)),
    ),
  ];
}

final List<NotificationModel> kMockNotifications = generateMockNotifications();
