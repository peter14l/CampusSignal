import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/services/fcm_notification_service.dart';
import '../../core/services/gemini_ocr_service.dart';
import '../../core/services/r2_storage_service.dart';
import '../../core/widgets/interactive_spring.dart';
import '../../data/repositories/events_repository.dart';
import '../../models/event_model.dart';
import '../feed/feed_controller.dart';
import '../search/search_controller.dart';

enum AiCreationStep {
  uploadImage,
  analyzing,
  reviewAndConfirm,
  publishing,
}

class AiAnnouncementCreatorScreen extends ConsumerStatefulWidget {
  final String initialCategory;

  const AiAnnouncementCreatorScreen({
    super.key,
    this.initialCategory = 'hackathon',
  });

  @override
  ConsumerState<AiAnnouncementCreatorScreen> createState() =>
      _AiAnnouncementCreatorScreenState();
}

class _AiAnnouncementCreatorScreenState
    extends ConsumerState<AiAnnouncementCreatorScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  AiCreationStep _currentStep = AiCreationStep.uploadImage;
  String _analysisStatus = 'Scanning poster typography...';
  double _analysisProgress = 0.2;

  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  String? _uploadedR2Url;

  late TextEditingController _titleController;
  late TextEditingController _organizerController;
  late TextEditingController _descriptionController;
  late TextEditingController _venueController;
  late TextEditingController _applyUrlController;
  late TextEditingController _eligibilityController;
  late TextEditingController _tagsController;

  late String _category;
  late String _format;
  late DateTime _startDate;
  late DateTime _deadlineDate;

  bool _isCampusWide = true;
  final Set<String> _selectedBranches = {};

  final List<String> _availableBranches = const [
    'Computer Science & Engineering',
    'Data Science & AI',
    'Information Technology',
    'Business Administration (BBA / MBA)',
    'Commerce & Finance (B.Com / M.Com)',
    'Economics & Data Analytics',
    'Law (BA.LLB / BBA.LLB)',
    'Mass Communication & Media',
    'Psychology & Social Sciences',
  ];

  final List<Map<String, dynamic>> _announcementTypes = const [
    {'id': 'hackathon', 'label': 'Hackathon', 'icon': LucideIcons.code},
    {'id': 'internship', 'label': 'Internship', 'icon': LucideIcons.briefcase},
    {'id': 'workshop', 'label': 'Workshop', 'icon': LucideIcons.wrench},
    {'id': 'fest', 'label': 'Fest', 'icon': LucideIcons.partyPopper},
    {'id': 'seminar', 'label': 'Seminar', 'icon': LucideIcons.graduationCap},
    {'id': 'club', 'label': 'Club Event', 'icon': LucideIcons.users},
  ];

  final List<String> _formats = const ['In-Person', 'Online', 'Hybrid'];

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
    _format = 'In-Person';
    _startDate = DateTime.now().add(const Duration(days: 7));
    _deadlineDate = DateTime.now().add(const Duration(days: 5));

    _titleController = TextEditingController();
    _organizerController = TextEditingController(text: 'SXUK Student Affairs');
    _descriptionController = TextEditingController();
    _venueController = TextEditingController(text: 'SXUK Campus');
    _applyUrlController = TextEditingController();
    _eligibilityController = TextEditingController(text: 'Open to all SXUK students');
    _tagsController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _organizerController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    _applyUrlController.dispose();
    _eligibilityController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickImageAndAnalyze() async {
    HapticFeedback.lightImpact();
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 88,
      );

      if (file == null) return;

      final bytes = await file.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageName = file.name;
        _currentStep = AiCreationStep.analyzing;
        _analysisStatus = 'Reading flyer with Gemini Vision OCR...';
        _analysisProgress = 0.3;
      });

      // Step 1: Upload to Cloudflare R2 Cache in background
      final r2Service = ref.read(r2StorageServiceProvider);
      r2Service.uploadPosterImage(
        bytes: bytes,
        preferredFileName: file.name,
        mimeType: file.mimeType ?? 'image/jpeg',
      ).then((url) {
        _uploadedR2Url = url;
      });

      // Step 2: Run Gemini Multimodal Vision OCR
      setState(() {
        _analysisStatus = 'Extracting event schedules, rules & links...';
        _analysisProgress = 0.65;
      });

      final ocrService = ref.read(geminiOcrServiceProvider);
      final extracted = await ocrService.extractAnnouncementFromImage(
        imageBytes: bytes,
        mimeType: file.mimeType ?? 'image/jpeg',
      );

      setState(() {
        _analysisStatus = 'Structuring department eligibility & fields...';
        _analysisProgress = 0.95;
      });

      await Future.delayed(const Duration(milliseconds: 400));

      // Populate form fields with extracted data
      _titleController.text = extracted.title;
      _organizerController.text = extracted.organizer;
      _descriptionController.text = extracted.description;
      _category = extracted.category;
      _format = extracted.format;
      _venueController.text = extracted.venue;
      _applyUrlController.text = extracted.applyUrl;
      _eligibilityController.text = extracted.eligibility;

      if (extracted.startDate != null) {
        _startDate = extracted.startDate!;
      }
      if (extracted.deadlineDate != null) {
        _deadlineDate = extracted.deadlineDate!;
      }

      if (extracted.tags.isNotEmpty) {
        _tagsController.text = extracted.tags.join(', ');
      }

      // Department & Branch Targeting
      if (extracted.targetBranches.isNotEmpty &&
          !extracted.targetBranches.contains('All') &&
          !extracted.targetBranches.contains('All Branches')) {
        _isCampusWide = false;
        _selectedBranches.clear();
        for (final b in extracted.targetBranches) {
          final matched = _availableBranches.firstWhere(
            (avail) => avail.toLowerCase().contains(b.toLowerCase()) || b.toLowerCase().contains(avail.toLowerCase()),
            orElse: () => b,
          );
          _selectedBranches.add(matched);
        }
      } else {
        _isCampusWide = true;
        _selectedBranches.clear();
      }

      HapticFeedback.mediumImpact();
      setState(() {
        _currentStep = AiCreationStep.reviewAndConfirm;
      });
    } catch (e) {
      debugPrint('Error in AI Image analysis: $e');
      setState(() {
        _currentStep = AiCreationStep.reviewAndConfirm;
      });
    }
  }

  Future<void> _publishAnnouncement() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    HapticFeedback.heavyImpact();
    setState(() {
      _currentStep = AiCreationStep.publishing;
    });

    final now = DateTime.now();
    final eventId = 'ann-${now.millisecondsSinceEpoch}';

    // Ensure R2 poster URL is ready
    String? posterKey = _uploadedR2Url;
    if (posterKey == null && _selectedImageBytes != null) {
      final r2Service = ref.read(r2StorageServiceProvider);
      posterKey = await r2Service.uploadPosterImage(
        bytes: _selectedImageBytes!,
        preferredFileName: _selectedImageName ?? '$eventId.jpg',
      );
    }

    final targetBranches = _isCampusWide
        ? const <String>['All Branches']
        : _selectedBranches.toList();

    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final newEvent = EventModel(
      id: eventId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _category,
      organizerName: _organizerController.text.trim(),
      startsAt: _startDate,
      endsAt: _startDate.add(const Duration(hours: 4)),
      deadlineAt: _deadlineDate,
      venue: _venueController.text.trim().isNotEmpty
          ? _venueController.text.trim()
          : 'SXUK Campus',
      format: _format,
      applyUrl: _applyUrlController.text.trim().isNotEmpty
          ? _applyUrlController.text.trim()
          : null,
      eligibilityText: _eligibilityController.text.trim().isNotEmpty
          ? _eligibilityController.text.trim()
          : (_isCampusWide ? 'Open to all SXUK students' : 'Targeted branches only'),
      eligibilityBranches: targetBranches,
      posterR2Key: posterKey,
      status: 'published',
      matchedTags: tags.isNotEmpty ? tags : ['SXUK', _category],
    );

    // 1. Save to Events Repository
    await ref.read(eventsRepositoryProvider).createEvent(newEvent);

    // 2. Update Feed & Search Controllers instantly
    ref.read(feedControllerProvider.notifier).addCreatedEvent(newEvent);
    ref.read(searchControllerProvider.notifier).addNewEvent(newEvent);

    // 3. Broadcast FCM Native Push Notifications across devices
    await ref
        .read(fcmNotificationServiceProvider)
        .broadcastAnnouncementNotification(newEvent);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.circleCheck, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Announcement published & broadcasted via FCM!',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );

    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/feed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(LucideIcons.sparkles, size: 18, color: colorScheme.primary),
            ),
            const SizedBox(width: 10),
            Text(
              'AI Announcement Studio',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/feed');
            }
          },
        ),
      ),
      body: switch (_currentStep) {
        AiCreationStep.uploadImage => _buildUploadStep(context),
        AiCreationStep.analyzing => _buildAnalyzingStep(context),
        AiCreationStep.reviewAndConfirm => _buildReviewForm(context),
        AiCreationStep.publishing => _buildPublishingStep(context),
      },
    );
  }

  // Step 1: Upload Flyer / Poster
  Widget _buildUploadStep(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // AI Flyer Scanner Icon Card
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  LucideIcons.scanLine,
                  size: 42,
                  color: colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Upload Poster & Auto-Extract',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              'Select an event flyer or poster from your gallery. Gemini Multimodal AI extracts all deadlines, rules, venues, and targets automatically.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),

            // Big Upload Touch Card
            InteractiveSpring(
              onTap: _pickImageAndAnalyze,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        LucideIcons.imagePlus,
                        size: 32,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Choose from Gallery',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'PNG, JPG, JPEG flyers supported',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Manual option
            TextButton.icon(
              onPressed: () {
                setState(() => _currentStep = AiCreationStep.reviewAndConfirm);
              },
              icon: const Icon(LucideIcons.filePenLine, size: 16),
              label: const Text('Or create manually without image'),
            ),
          ],
        ),
      ),
    );
  }

  // Step 2: AI Analyzing Loading Screen
  Widget _buildAnalyzingStep(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Poster thumbnail with scanning beam
            if (_selectedImageBytes != null)
              Container(
                width: 160,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.primary, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.memory(
                    _selectedImageBytes!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 28),

            SizedBox(
              width: 180,
              child: LinearProgressIndicator(
                value: _analysisProgress,
                backgroundColor: colorScheme.surfaceContainerHighest,
                color: colorScheme.primary,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Gemini AI Multimodal Vision',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 6),

            Text(
              _analysisStatus,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Step 3: Interactive Confirmation Form with Review & Branch Targeting
  Widget _buildReviewForm(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Form(
      key: _formKey,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          // AI Verification Banner
          if (_selectedImageBytes != null)
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      _selectedImageBytes!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(LucideIcons.sparkles,
                                size: 14, color: colorScheme.primary),
                            const SizedBox(width: 4),
                            Text(
                              'AI EXTRACTION COMPLETE',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                                letterSpacing: 0.8,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Review and confirm the details below before publishing.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Opportunity Category
          Text(
            'OPPORTUNITY TYPE',
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _announcementTypes.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final type = _announcementTypes[index];
                final isSelected = _category == type['id'];
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        type['icon'] as IconData,
                        size: 15,
                        color: isSelected
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(type['label'] as String),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() => _category = type['id'] as String);
                  },
                  selectedColor: colorScheme.primaryContainer,
                  backgroundColor: colorScheme.surfaceContainer,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Title
          TextFormField(
            controller: _titleController,
            textCapitalization: TextCapitalization.words,
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              labelText: 'Announcement / Event Title *',
              hintText: 'e.g. XavCode Hackathon 2026',
              prefixIcon: Icon(LucideIcons.heading,
                  color: colorScheme.onSurfaceVariant, size: 18),
            ),
            validator: (val) =>
                val == null || val.trim().isEmpty ? 'Please enter a title' : null,
          ),
          const SizedBox(height: 16),

          // Club / Organizer
          TextFormField(
            controller: _organizerController,
            textCapitalization: TextCapitalization.words,
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              labelText: 'Host Club / Department *',
              hintText: 'e.g. ACM SXUK / Dept of Computer Science',
              prefixIcon: Icon(LucideIcons.users,
                  color: colorScheme.onSurfaceVariant, size: 18),
            ),
            validator: (val) => val == null || val.trim().isEmpty
                ? 'Please enter the organizer name'
                : null,
          ),
          const SizedBox(height: 16),

          // Description
          TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              labelText: 'Event Details & Highlights',
              hintText:
                  'Provide key information, prizes, rounds, and eligibility instructions...',
              prefixIcon: Icon(LucideIcons.fileText,
                  color: colorScheme.onSurfaceVariant, size: 18),
            ),
          ),
          const SizedBox(height: 24),

          // Date & Deadline Bento
          Text(
            'SCHEDULE & TIMINGS',
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Event Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Event Date',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() => _startDate = picked);
                        }
                      },
                      icon: const Icon(LucideIcons.calendar, size: 15),
                      label: Text(
                        DateFormat('d MMM yyyy').format(_startDate),
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Deadline Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Registration Deadline',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _deadlineDate,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() => _deadlineDate = picked);
                        }
                      },
                      icon: const Icon(LucideIcons.clock, size: 15),
                      label: Text(
                        DateFormat('d MMM yyyy').format(_deadlineDate),
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Venue & Format
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _venueController,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Venue / Hall',
                    hintText: 'e.g. Lab 402 / Auditorium',
                    prefixIcon: Icon(LucideIcons.mapPin,
                        color: colorScheme.onSurfaceVariant, size: 18),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<String>(
                  initialValue: _format,
                  decoration: const InputDecoration(
                    labelText: 'Mode',
                  ),
                  items: _formats.map((f) {
                    return DropdownMenuItem(value: f, child: Text(f));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _format = val);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // TARGET AUDIENCE & DEPARTMENT VISIBILITY BENTO
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(LucideIcons.school,
                            size: 18, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'DEPARTMENT VISIBILITY',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: _isCampusWide,
                      onChanged: (val) {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _isCampusWide = val;
                          if (val) _selectedBranches.clear();
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _isCampusWide
                      ? 'Broadcast to ALL branches across SXUK'
                      : 'Target specific departments only (Exclusive access)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _isCampusWide
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.primary,
                    fontWeight: _isCampusWide ? FontWeight.w400 : FontWeight.w600,
                  ),
                ),
                if (!_isCampusWide) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _availableBranches.map((branch) {
                      final isSelected = _selectedBranches.contains(branch);
                      return FilterChip(
                        label: Text(branch),
                        selected: isSelected,
                        onSelected: (selected) {
                          HapticFeedback.selectionClick();
                          setState(() {
                            if (selected) {
                              _selectedBranches.add(branch);
                            } else {
                              _selectedBranches.remove(branch);
                            }
                          });
                        },
                        selectedColor: colorScheme.primaryContainer,
                        checkmarkColor: colorScheme.onPrimaryContainer,
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurface,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Registration / Apply URL
          TextFormField(
            controller: _applyUrlController,
            keyboardType: TextInputType.url,
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              labelText: 'Registration / Google Form Link',
              hintText: 'https://forms.gle/... or sxuk.edu.in',
              prefixIcon: Icon(LucideIcons.link,
                  color: colorScheme.onSurfaceVariant, size: 18),
            ),
          ),
          const SizedBox(height: 16),

          // Tags
          TextFormField(
            controller: _tagsController,
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              labelText: 'Keywords & Tags (comma separated)',
              hintText: 'e.g. AI, Coding, Cash Prize, Certificate',
              prefixIcon: Icon(LucideIcons.tag,
                  color: colorScheme.onSurfaceVariant, size: 18),
            ),
          ),
          const SizedBox(height: 32),

          // Submit & Publish Button
          FilledButton.icon(
            onPressed: _publishAnnouncement,
            icon: const Icon(LucideIcons.send, size: 18),
            label: const Text('Confirm & Broadcast Announcement'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/feed');
              }
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Step 4: Publishing & FCM Dispatch Screen
  Widget _buildPublishingStep(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              color: colorScheme.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Publishing to Cloudflare R2 & Broadcasting...',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Dispatching FCM system notifications to target students.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
