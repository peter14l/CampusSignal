import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'profile_controller.dart';

class TagSelectionSheet extends ConsumerStatefulWidget {
  final bool isSkill;
  final List<String> currentTags;

  const TagSelectionSheet({
    super.key,
    required this.isSkill,
    required this.currentTags,
  });

  static Future<void> show(
    BuildContext context, {
    required bool isSkill,
    required List<String> currentTags,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => TagSelectionSheet(
        isSkill: isSkill,
        currentTags: currentTags,
      ),
    );
  }

  @override
  ConsumerState<TagSelectionSheet> createState() => _TagSelectionSheetState();
}

class _TagSelectionSheetState extends ConsumerState<TagSelectionSheet> {
  final TextEditingController _customTagController = TextEditingController();
  late List<String> _selectedTags;

  final List<String> _popularSkills = const [
    'Flutter',
    'Python',
    'AI / ML',
    'Data Science',
    'Next.js',
    'UI/UX Design',
    'Cloud Computing',
    'Cybersecurity',
    'SQL & Databases',
    'Robotics & IoT',
    'DSA in Java/C++',
    'Backend (Go/Node)',
    'Mobile Development',
    'DevOps & Docker',
  ];

  final List<String> _popularInterests = const [
    'Hackathons',
    'Internship Drives',
    'AI & Robotics',
    'Cultural Fests',
    'Workshops & Bootcamps',
    'Case Competitions',
    'Debating & MUN',
    'Sports & Athletics',
    'Fintech & Trading',
    'Entrepreneurship',
    'Photography & Media',
    'Open Source Dev',
    'Club Activities',
    'Gaming & Esports',
  ];

  @override
  void initState() {
    super.initState();
    _selectedTags = List<String>.from(widget.currentTags);
  }

  @override
  void dispose() {
    _customTagController.dispose();
    super.dispose();
  }

  void _addCustomTag() {
    final val = _customTagController.text.trim();
    if (val.isEmpty) return;

    if (!_selectedTags.contains(val)) {
      setState(() {
        _selectedTags.add(val);
      });
      HapticFeedback.lightImpact();
      if (widget.isSkill) {
        ref.read(profileControllerProvider.notifier).addSkill(val);
      } else {
        ref.read(profileControllerProvider.notifier).addInterest(val);
      }
    }
    _customTagController.clear();
  }

  void _toggleTag(String tag) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
        if (widget.isSkill) {
          ref.read(profileControllerProvider.notifier).removeSkill(tag);
        } else {
          ref.read(profileControllerProvider.notifier).removeInterest(tag);
        }
      } else {
        _selectedTags.add(tag);
        if (widget.isSkill) {
          ref.read(profileControllerProvider.notifier).addSkill(tag);
        } else {
          ref.read(profileControllerProvider.notifier).addInterest(tag);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final title = widget.isSkill ? 'Select Skills' : 'Select Interests';
    final icon = widget.isSkill ? LucideIcons.code : LucideIcons.sparkles;
    final popularList = widget.isSkill ? _popularSkills : _popularInterests;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header Row
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: colorScheme.onPrimaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Tap suggestions or type your custom tags',
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.x, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Custom Tag Input Field
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customTagController,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _addCustomTag(),
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: widget.isSkill
                        ? 'Add custom skill (e.g. Kotlin)'
                        : 'Add custom interest (e.g. FinTech)',
                    hintStyle: TextStyle(fontSize: 13, color: colorScheme.outline),
                    prefixIcon: Icon(LucideIcons.tag, size: 16, color: colorScheme.primary),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _addCustomTag,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Popular / Recommended Suggestions
          Text(
            'POPULAR SXUK RECOMMENDATIONS',
            style: textTheme.labelSmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),

          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 260),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: popularList.map((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (_) => _toggleTag(tag),
                    selectedColor: colorScheme.primaryContainer,
                    backgroundColor: colorScheme.surfaceContainer,
                    checkmarkColor: colorScheme.onPrimaryContainer,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurface,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.outlineVariant.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Done CTA
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}
