import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../models/event_model.dart';
import '../search/search_controller.dart';

class CreateAnnouncementSheet extends ConsumerStatefulWidget {
  final String initialCategory;

  const CreateAnnouncementSheet({
    super.key,
    this.initialCategory = 'hackathon',
  });

  static Future<void> show(BuildContext context, {String initialCategory = 'hackathon'}) async {
    Navigator.of(context).pushNamed(
      '/create-announcement',
      arguments: initialCategory,
    );
  }

  @override
  ConsumerState<CreateAnnouncementSheet> createState() =>
      _CreateAnnouncementSheetState();
}

class _CreateAnnouncementSheetState
    extends ConsumerState<CreateAnnouncementSheet> {
  final _formKey = GlobalKey<FormState>();

  late String _selectedCategory;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _organizerController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();
  final TextEditingController _applyUrlController = TextEditingController();
  final TextEditingController _teamSizeController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  DateTime _startDate = DateTime.now().add(const Duration(days: 3));
  final TimeOfDay _startTime = const TimeOfDay(hour: 10, minute: 0);
  DateTime _deadlineDate = DateTime.now().add(const Duration(days: 2));
  final TimeOfDay _deadlineTime = const TimeOfDay(hour: 23, minute: 59);

  String _format = 'In-Person';
  final List<String> _formats = const ['In-Person', 'Virtual', 'Hybrid'];

  final List<Map<String, dynamic>> _announcementTypes = const [
    {
      'id': 'hackathon',
      'label': 'Hackathon',
      'icon': LucideIcons.code,
    },
    {
      'id': 'fest',
      'label': 'Fest / Cultural',
      'icon': LucideIcons.partyPopper,
    },
    {
      'id': 'club',
      'label': 'Club Activity',
      'icon': LucideIcons.users,
    },
    {
      'id': 'internship',
      'label': 'Internship / Drive',
      'icon': LucideIcons.briefcase,
    },
    {
      'id': 'workshop',
      'label': 'Workshop / Seminar',
      'icon': LucideIcons.wrench,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _organizerController.text = 'SXUK Student Council';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _organizerController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    _applyUrlController.dispose();
    _teamSizeController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _submitAnnouncement() {
    if (!_formKey.currentState!.validate()) return;

    final startDateTime = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final deadlineDateTime = DateTime(
      _deadlineDate.year,
      _deadlineDate.month,
      _deadlineDate.day,
      _deadlineTime.hour,
      _deadlineTime.minute,
    );

    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (tags.isEmpty) {
      tags.addAll(['SXUK', _selectedCategory.toUpperCase(), 'Campus']);
    }

    final newEvent = EventModel(
      id: 'announcement-${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : 'New announcement created by ${_organizerController.text.trim()}.',
      category: _selectedCategory,
      organizerName: _organizerController.text.trim(),
      startsAt: startDateTime,
      endsAt: startDateTime.add(const Duration(hours: 4)),
      deadlineAt: deadlineDateTime,
      venue: _venueController.text.trim().isNotEmpty
          ? _venueController.text.trim()
          : 'SXUK Campus',
      format: _format,
      teamSizeText: _teamSizeController.text.trim().isNotEmpty
          ? _teamSizeController.text.trim()
          : 'Individual / Teams',
      eligibilityText: 'Open to SXUK students across all branches and years.',
      applyUrl: _applyUrlController.text.trim().isNotEmpty
          ? _applyUrlController.text.trim()
          : 'https://www.sxuk.edu.in',
      matchedTags: tags,
      matchScore: 0.95,
      status: 'published',
    );

    ref.read(searchControllerProvider.notifier).addNewEvent(newEvent);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.circleCheck, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Announcement "${newEvent.title}" published to live signal feed!',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle bar
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        LucideIcons.megaphone,
                        color: colorScheme.onPrimaryContainer,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create Announcement',
                          style: textTheme.titleMedium?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Publish opportunities to SXUK CampusSignal',
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Divider(height: 24, color: colorScheme.outlineVariant.withValues(alpha: 0.5)),

          // Form Body Scrollable
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Announcement Category Selector
                  Text(
                    'OPPORTUNITY TYPE',
                    style: textTheme.labelSmall?.copyWith(
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
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
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
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Please enter a title'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Club / Organizer
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

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'Event Details & Highlights',
                      hintText:
                          'Provide key information, prizes, rounds, and instructions...',
                      prefixIcon: Icon(LucideIcons.fileText,
                          color: colorScheme.onSurfaceVariant, size: 18),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Date & Deadline Row
                  Row(
                    children: [
                      // Event Date
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Event Date',
                              style: textTheme.labelSmall?.copyWith(
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
                              icon: const Icon(LucideIcons.calendar,
                                  size: 15),
                              label: Text(
                                DateFormat('d MMM yyyy').format(_startDate),
                                style: const TextStyle(fontSize: 12),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
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
                              style: textTheme.labelSmall?.copyWith(
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
                                    horizontal: 12, vertical: 10),
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
                        child: DropdownButtonFormField<String>(
                          initialValue: _format,
                          decoration: const InputDecoration(
                            labelText: 'Format',
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                          items: _formats
                              .map((f) => DropdownMenuItem(
                                    value: f,
                                    child: Text(f),
                                  ))
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _format = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _submitAnnouncement,
                    icon: const Icon(LucideIcons.send, size: 18),
                    label: const Text('Publish Announcement'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
