import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../models/event_model.dart';

/// Event coordinators and queries editor card for Announcement Creator
class AnnouncementCoordinatorsEditor extends StatelessWidget {
  final List<EventContact> contacts;
  final VoidCallback onAddContact;
  final void Function(int index) onRemoveContact;

  const AnnouncementCoordinatorsEditor({
    super.key,
    required this.contacts,
    required this.onAddContact,
    required this.onRemoveContact,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
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
                  Icon(LucideIcons.phoneCall, size: 18, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'STUDENT COORDINATORS',
                    style: textTheme.labelSmall?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: onAddContact,
                icon: const Icon(LucideIcons.userPlus, size: 14),
                label: const Text('Add Contact', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Students can tap these directly on the event details page to Call or WhatsApp coordinators for questions.',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
          if (contacts.isNotEmpty) ...[
            const SizedBox(height: 12),
            Column(
              children: contacts.asMap().entries.map((entry) {
                final idx = entry.key;
                final c = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: colorScheme.primaryContainer,
                        child: Icon(
                          LucideIcons.user,
                          size: 13,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.name.isNotEmpty ? c.name : 'Coordinator ${idx + 1}',
                              style: textTheme.titleSmall?.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              c.role != null && c.role!.isNotEmpty
                                  ? '${c.role!} • ${c.phone}'
                                  : c.phone,
                              style: textTheme.bodySmall?.copyWith(
                                fontSize: 11,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          LucideIcons.trash2,
                          size: 16,
                          color: Colors.redAccent,
                        ),
                        onPressed: () => onRemoveContact(idx),
                        tooltip: 'Remove contact',
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
