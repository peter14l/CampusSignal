import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../models/event_model.dart';
import '../search/search_controller.dart';

class CreateAnnouncementScreen extends ConsumerStatefulWidget {
  final String initialCategory;

  const CreateAnnouncementScreen({
    super.key,
    this.initialCategory = 'hackathon',
  });

  @override
  ConsumerState<CreateAnnouncementScreen> createState() =>
      _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState
    extends ConsumerState<CreateAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _selectedCategory;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _organizerController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();
  final TextEditingController _applyUrlController = TextEditingController();
  final TextEditingController _eligibilityController = TextEditingController();
  final TextEditingController _teamSizeController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  DateTime _startDate = DateTime.now().add(const Duration(days: 7));
  DateTime _deadlineDate = DateTime.now().add(const Duration(days: 5));
  String _format = 'In-Person';
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _announcementTypes = const [
    {'id': 'hackathon', 'label': 'Hackathon', 'icon': LucideIcons.code},
    {'id': 'internship', 'label': 'Internship', 'icon': LucideIcons.briefcase},
    {'id': 'workshop', 'label': 'Workshop', 'icon': LucideIcons.wrench},
    {'id': 'fest', 'label': 'Fest', 'icon': LucideIcons.partyPopper},
    {'id': 'seminar', 'label': 'Seminar', 'icon': LucideIcons.graduationCap},
    {'id': 'club', 'label': 'Club Event', 'icon': LucideIcons.users},
  ];

  final List<String> _categories = const [
    'hackathon',
    'internship',
    'workshop',
    'fest',
    'seminar',
    'club',
  ];

  final List<String> _formats = const [
    'In-Person',
    'Online',
    'Hybrid',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory.toLowerCase();
    if (!_categories.contains(_selectedCategory)) {
      _selectedCategory = 'hackathon';
    }
    _organizerController.text = 'SXUK Student Council';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _organizerController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    _applyUrlController.dispose();
    _eligibilityController.dispose();
    _teamSizeController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final newEvent = EventModel(
        id: 'ann-${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
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
            : 'Open to all SXUK students',
        teamSizeText: _teamSizeController.text.trim().isNotEmpty
            ? _teamSizeController.text.trim()
            : '1-4 Members',
        status: 'published',
        matchScore: 0.98,
        matchedTags: [_selectedCategory, 'SXUK', 'Campus Opportunity'],
      );

      // Add to search/feed state in memory and database
      ref.read(searchControllerProvider.notifier).addNewEvent(newEvent);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('🎉 Opportunity published successfully!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to publish announcement: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
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
          'Post Signal / Opportunity',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
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
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Hero Intro Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.megaphone,
                      color: colorScheme.onPrimaryContainer,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create New Announcement',
                          style: textTheme.titleMedium?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Publish events, hackathons, and drives directly to the campus signal feed.',
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Announcement Category Selector
            Text(
              'OPPORTUNITY CATEGORY',
              style: textTheme.labelSmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _announcementTypes.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final type = _announcementTypes[index];
                  final isSelected = _selectedCategory == type['id'];
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
                      setState(() {
                        _selectedCategory = type['id'] as String;
                      });
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
            const SizedBox(height: 24),

            // Title Field
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
              validator: (val) => val == null || val.trim().isEmpty
                  ? 'Please enter a title'
                  : null,
            ),
            const SizedBox(height: 16),

            // Club / Organizer Field
            TextFormField(
              controller: _organizerController,
              textCapitalization: TextCapitalization.words,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Organizer / Club Name *',
                hintText: 'e.g. SXUK ACM Student Chapter',
                prefixIcon: Icon(LucideIcons.users,
                    color: colorScheme.onSurfaceVariant, size: 18),
              ),
              validator: (val) => val == null || val.trim().isEmpty
                  ? 'Please enter the organizer name'
                  : null,
            ),
            const SizedBox(height: 16),

            // Description Field
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

            // Date & Deadline Section
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
                        style: textTheme.bodySmall?.copyWith(
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
                            lastDate: DateTime.now()
                                .add(const Duration(days: 365)),
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
                        'Deadline Date',
                        style: textTheme.bodySmall?.copyWith(
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
                            lastDate: DateTime.now()
                                .add(const Duration(days: 365)),
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
            const SizedBox(height: 24),

            // Venue & Mode Section
            Text(
              'LOCATION & FORMAT',
              style: textTheme.labelSmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),
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
            const SizedBox(height: 16),

            // Team Size & Tags
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _teamSizeController,
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'Team Size',
                      hintText: 'e.g. 2-4 Members',
                      prefixIcon: Icon(LucideIcons.usersRound,
                          color: colorScheme.onSurfaceVariant, size: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _tagsController,
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'Tags (comma separated)',
                      hintText: 'e.g. Python, AI, Web',
                      prefixIcon: Icon(LucideIcons.tag,
                          color: colorScheme.onSurfaceVariant, size: 18),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Apply URL
            TextFormField(
              controller: _applyUrlController,
              keyboardType: TextInputType.url,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Registration / Google Form URL',
                hintText: 'https://forms.gle/... or sxuk.edu.in',
                prefixIcon: Icon(LucideIcons.link,
                    color: colorScheme.onSurfaceVariant, size: 18),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Buttons
            FilledButton.icon(
              onPressed: _isSubmitting ? null : _submitForm,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(LucideIcons.send, size: 18),
              label: Text(_isSubmitting ? 'Publishing...' : 'Publish Announcement'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
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
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
