import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TutorialScreen extends StatefulWidget {
  final int initialTab;

  const TutorialScreen({super.key, this.initialTab = 0});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 2),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'App Guide & Platform Rules',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(LucideIcons.graduationCap, size: 18), text: 'Student Guide'),
            Tab(icon: Icon(LucideIcons.sparkles, size: 18), text: 'Organizers'),
            Tab(icon: Icon(LucideIcons.shieldCheck, size: 18), text: 'Admins & Fest'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStudentGuide(context, colorScheme),
          _buildOrganizersGuide(context, colorScheme),
          _buildAdminsGuide(context, colorScheme),
        ],
      ),
    );
  }

  // TAB 1: Student Guide
  Widget _buildStudentGuide(BuildContext context, ColorScheme colorScheme) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        _buildHeroBanner(
          icon: LucideIcons.compass,
          title: 'Discover Signals Across India',
          subtitle:
              'Learn how CampusSignal separates campus notices from pan-India hackathons, while protecting private internships.',
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 20),
        _buildSectionHeader('1. DUAL-SCOPE DISCOVERY ENGINE', colorScheme.primary),
        const SizedBox(height: 8),
        _buildFeatureCard(
          icon: LucideIcons.school,
          title: '"My Campus" View',
          body:
              'Shows official academic notices, club workshops, campus elections, and internal placement drives specifically for your enrolled institution (e.g. SXUK).',
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 10),
        _buildFeatureCard(
          icon: LucideIcons.globe,
          title: '"Pan-India Fests" View',
          body:
              'Federated network view surfacing open inter-college hackathons, national coding sprints, and cultural symposiums hosted by IITs, Jadavpur University, DU, and more.',
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 20),
        _buildSectionHeader('2. THE PRIVATE INTERNSHIP WALL', colorScheme.primary),
        const SizedBox(height: 8),
        _buildFeatureCard(
          icon: LucideIcons.lock,
          title: 'Zero-Leakage Placement Privacy',
          body:
              'Company drives, mock tests, and internship opportunities are strictly walled to your campus via Supabase Row-Level Security. Students from outside universities can never query or view your institution\'s internal drives.',
          colorScheme: colorScheme,
          highlightColor: colorScheme.secondaryContainer,
        ),
        const SizedBox(height: 20),
        _buildSectionHeader('3. TIMELINES & CALENDAR SYNC', colorScheme.primary),
        const SizedBox(height: 8),
        _buildFeatureCard(
          icon: LucideIcons.calendarCheck,
          title: '1-Tap Google Calendar & Alarms',
          body:
              'Add deadlines straight to your device calendar. If multiple events overlap on the same day, CampusSignal detects time conflicts and warns you proactively in the Calendar tab.',
          colorScheme: colorScheme,
        ),
      ],
    );
  }

  // TAB 2: Organizers Guide
  Widget _buildOrganizersGuide(BuildContext context, ColorScheme colorScheme) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        _buildHeroBanner(
          icon: LucideIcons.sparkles,
          title: 'Supercharge Your Event Reach',
          subtitle:
              'From poster upload to AI extraction and Pan-India broadcasting, here is your playbook as an organizer.',
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 20),
        _buildSectionHeader('1. AI POSTER STUDIO (GEMINI VISION)', colorScheme.primary),
        const SizedBox(height: 8),
        _buildFeatureCard(
          icon: LucideIcons.wand2,
          title: 'Instant Poster to Structured Event',
          body:
              'Upload your club poster image. Gemini Vision OCR auto-detects title, dates, registration deadlines, eligibility criteria, and organizer phone numbers in seconds.',
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 20),
        _buildSectionHeader('2. CHOOSING THE RIGHT SCOPE', colorScheme.primary),
        const SizedBox(height: 8),
        _buildFeatureCard(
          icon: LucideIcons.users,
          title: 'Campus Only vs Pan-India Inter-College',
          body:
              'Select "Campus Only" for local club meetings, auditions, and departmental seminars. Select "Pan-India Inter-College" for open hackathons, gaming tournaments, and major cultural fests.',
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 20),
        _buildSectionHeader('3. COORDINATOR CONTACT CARDS', colorScheme.primary),
        const SizedBox(height: 8),
        _buildFeatureCard(
          icon: LucideIcons.phoneCall,
          title: 'Direct WhatsApp & Phone Triggers',
          body:
              'Add student coordinator phone numbers and Instagram handles. Attendees can dial or message organizers in one tap directly from the Event Details bottom bar.',
          colorScheme: colorScheme,
        ),
      ],
    );
  }

  // TAB 3: Admins & Convenors Guide
  Widget _buildAdminsGuide(BuildContext context, ColorScheme colorScheme) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        _buildHeroBanner(
          icon: LucideIcons.shieldCheck,
          title: 'Admin Moderation & Fest Hub',
          subtitle:
              'Ensure quality control, approve student submissions, and manage annual fests with convenor passkeys.',
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 20),
        _buildSectionHeader('1. MODERATION QUEUE & TRIAGE', colorScheme.primary),
        const SizedBox(height: 8),
        _buildFeatureCard(
          icon: LucideIcons.checkCheck,
          title: 'Approve, Edit, or Reject with Feedback',
          body:
              'Submissions from unverified accounts or student clubs land in the moderation queue. Review the poster, verify eligibility details, and approve or reject with helpful reasons.',
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 20),
        _buildSectionHeader('2. FEST CONVENOR PASSKEYS', colorScheme.primary),
        const SizedBox(height: 8),
        _buildFeatureCard(
          icon: LucideIcons.keyRound,
          title: 'Delegated Passkey Elevation',
          body:
              'Student fest heads (e.g. XavHacks Core Team) can redeem a 6-character passkey (e.g. XAVHACKS-26) to manage their fest track without requiring full campus admin privileges.',
          colorScheme: colorScheme,
          highlightColor: colorScheme.tertiaryContainer,
        ),
        const SizedBox(height: 20),
        _buildSectionHeader('3. PAN-INDIA BROADCAST ELEVATION', colorScheme.primary),
        const SizedBox(height: 8),
        _buildFeatureCard(
          icon: LucideIcons.arrowUpRight,
          title: '1-Tap Inter-College Elevation',
          body:
              'Notice an exceptional intra-college hackathon that deserves national participation? Promote its scope to "Inter-College" in one tap from the moderation card.',
          colorScheme: colorScheme,
        ),
      ],
    );
  }

  Widget _buildHeroBanner({
    required IconData icon,
    required String title,
    required String subtitle,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.6),
            colorScheme.surfaceContainerLow,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: colorScheme.onPrimary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String body,
    required ColorScheme colorScheme,
    Color? highlightColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlightColor ?? colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
