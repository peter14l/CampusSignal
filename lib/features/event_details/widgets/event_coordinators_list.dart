import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/event_model.dart';

/// Coordinators & Contact queries widget for Event Details
class EventCoordinatorsList extends StatelessWidget {
  final List<EventContact> contacts;
  final String eventTitle;

  const EventCoordinatorsList({
    super.key,
    required this.contacts,
    required this.eventTitle,
  });

  Future<void> _launchWhatsApp(BuildContext context, String phone, String contactName) async {
    HapticFeedback.lightImpact();
    final rawPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final waNumber = rawPhone.startsWith('91') || rawPhone.length > 10
        ? rawPhone
        : '91$rawPhone';
    final url = Uri.parse(
      'https://wa.me/$waNumber?text=Hi%20${Uri.encodeComponent(contactName)},%20reaching%20out%20regarding%20${Uri.encodeComponent(eventTitle)}',
    );
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open WhatsApp. Please check if WhatsApp is installed.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening WhatsApp: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _callPhone(BuildContext context, String phone) async {
    HapticFeedback.lightImpact();
    final cleanPhone = phone.replaceAll(' ', '');
    final url = Uri.parse('tel:$cleanPhone');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not initiate phone call.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initiating phone call: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (contacts.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'For Queries & Contact',
          style: textTheme.titleMedium?.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        Column(
          children: contacts.map((contact) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      LucideIcons.user,
                      size: 16,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contact.name.isNotEmpty ? contact.name : 'Student Coordinator',
                          style: textTheme.titleSmall?.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          contact.role != null && contact.role!.isNotEmpty
                              ? '${contact.role!} • ${contact.phone}'
                              : contact.phone,
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (contact.phone.isNotEmpty) ...[
                    // WhatsApp Action
                    IconButton(
                      icon: const Icon(
                        LucideIcons.messageCircle,
                        size: 18,
                        color: Color(0xFF25D366),
                      ),
                      tooltip: 'WhatsApp',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _launchWhatsApp(
                        context,
                        contact.phone,
                        contact.name.isNotEmpty ? contact.name : 'Coordinator',
                      ),
                    ),
                    // Direct Phone Call Action
                    IconButton(
                      icon: Icon(
                        LucideIcons.phone,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      tooltip: 'Call Coordinator',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _callPhone(context, contact.phone),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
