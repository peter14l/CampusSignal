import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/calendar_sync_service.dart';
import '../../core/widgets/category_chip.dart';
import '../../core/widgets/interactive_spring.dart';
import '../../core/widgets/m3e_morph_button.dart';
import '../../core/widgets/m3e_states.dart';
import '../../core/widgets/micro_animated_icon.dart';
import '../../models/event_model.dart';
import 'event_details_controller.dart';

class EventDetailsScreen extends ConsumerStatefulWidget {
  final EventModel? event;
  final String? eventId;

  const EventDetailsScreen({
    super.key,
    this.event,
    this.eventId,
  });

  @override
  ConsumerState<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends ConsumerState<EventDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final controller = ref.read(eventDetailsControllerProvider.notifier);
      if (widget.event != null) {
        controller.setEvent(widget.event!);
      } else if (widget.eventId != null) {
        controller.loadEventById(widget.eventId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(eventDetailsControllerProvider);
    final controller = ref.read(eventDetailsControllerProvider.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    ref.listen(eventDetailsControllerProvider, (prev, next) {
      if (next.feedbackMessage != null &&
          next.feedbackMessage != prev?.feedbackMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.feedbackMessage!),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    final event = state.event ?? widget.event;

    if (state.isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (event == null) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(backgroundColor: colorScheme.surface),
        body: M3EErrorState(
          message: state.errorMessage ?? 'Event details could not be found.',
          onRetry: () {
            if (widget.eventId != null) {
              controller.loadEventById(widget.eventId!);
            }
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Collapsing Hero App Bar with Poster & Vignette
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: colorScheme.surface,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Center(
                child: MicroAnimatedIconButton.circle(
                  size: 38,
                  iconSize: 18,
                  iconData: LucideIcons.arrowLeft,
                  color: colorScheme.onSurface,
                  backgroundColor: colorScheme.surface.withValues(alpha: 0.85),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Back',
                ),
              ),
            ),
            actions: [
              MicroAnimatedIconButton.circle(
                size: 38,
                iconSize: 18,
                iconData: LucideIcons.calendarPlus,
                color: colorScheme.onSurface,
                backgroundColor: colorScheme.surface.withValues(alpha: 0.85),
                onPressed: () => _handleAddToCalendar(context, ref, event),
                tooltip: 'Add to Calendar',
              ),
              const SizedBox(width: 8),
              MicroAnimatedIconButton.circle(
                size: 38,
                iconSize: 18,
                iconData: LucideIcons.share2,
                color: colorScheme.onSurface,
                backgroundColor: colorScheme.surface.withValues(alpha: 0.85),
                onPressed: () => controller.shareEvent(),
                tooltip: 'Share Event',
              ),
              const SizedBox(width: 12),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (event.posterR2Key != null &&
                      event.posterR2Key!.startsWith('http'))
                    GestureDetector(
                      onTap: () => _showFullscreenImage(context, event.posterR2Key!),
                      child: CachedNetworkImage(
                        imageUrl: event.posterR2Key!,
                        memCacheWidth: 800,
                        memCacheHeight: 600,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: colorScheme.surfaceContainerHigh,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: colorScheme.primaryContainer,
                          child: const Center(
                            child: Icon(LucideIcons.imageOff,
                                color: Colors.white, size: 48),
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primaryContainer,
                            colorScheme.secondaryContainer,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Center(
                        child: Icon(LucideIcons.calendar, color: Colors.white, size: 64),
                      ),
                    ),
                  // Bottom vignette gradient
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.5),
                            Colors.transparent,
                            colorScheme.surface.withValues(alpha: 0.8),
                            colorScheme.surface,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.4, 0.85, 1.0],
                        ),
                      ),
                    ),
                  ),
                  if (event.posterR2Key != null && event.posterR2Key!.startsWith('http'))
                    Positioned(
                      bottom: 12,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.maximize2, size: 12, color: Colors.white),
                            SizedBox(width: 4),
                            Text('Tap to expand', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Main Event Details Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 130),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges: Category & Deadline
                  Row(
                    children: [
                      CategoryChip(category: event.category),
                      if (event.deadlineAt != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: event.isDeadlineSoon
                                ? colorScheme.errorContainer.withValues(alpha: 0.9)
                                : colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: event.isDeadlineSoon
                                  ? colorScheme.error.withValues(alpha: 0.4)
                                  : colorScheme.outlineVariant.withValues(alpha: 0.4),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.clock,
                                size: 13,
                                color: event.isDeadlineSoon
                                    ? colorScheme.onErrorContainer
                                    : colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                event.deadlineLabel,
                                style: textTheme.labelSmall?.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: event.isDeadlineSoon
                                      ? colorScheme.onErrorContainer
                                      : colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Event Title
                  Text(
                    event.title,
                    style: textTheme.headlineSmall?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                      height: 1.25,
                      letterSpacing: -0.4,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Host / Organizer Row with Instagram Action
                  Container(
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
                          radius: 16,
                          backgroundColor: colorScheme.primaryContainer,
                          child: Text(
                            event.organizerName.isNotEmpty
                                ? event.organizerName.substring(0, 1).toUpperCase()
                                : 'S',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.organizerName,
                                style: textTheme.titleSmall?.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'SXUK Verified Society / Club',
                                style: textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (event.instagramHandle != null && event.instagramHandle!.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () {
                              final raw = event.instagramHandle!.replaceAll('@', '').trim();
                              launchUrl(
                                Uri.parse('https://instagram.com/$raw'),
                                mode: LaunchMode.externalApplication,
                              );
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE1306C).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFE1306C).withValues(alpha: 0.35),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(LucideIcons.atSign, size: 14, color: Color(0xFFE1306C)),
                                  const SizedBox(width: 4),
                                  Text(
                                    event.instagramHandle!,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFE1306C),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ] else ...[
                          Icon(LucideIcons.badgeCheck, size: 18, color: colorScheme.primary),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 2x2 Bento Logistics Grid
                  _buildBentoLogistics(context, ref, event),

                  const SizedBox(height: 20),

                  // Personalized Fit Tags Section
                  _buildMatchedTagsBar(context, event),

                  const SizedBox(height: 24),

                  // About Event Section
                  Text(
                    'About this Opportunity',
                    style: textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    event.description.isNotEmpty
                        ? event.description
                        : 'No additional description provided for this campus opportunity.',
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),

                  // Registration Form / Decoded Link Card
                  if (event.applyUrl != null && event.applyUrl!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(LucideIcons.qrCode, size: 16, color: colorScheme.primary),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Official Registration Link (Decoded)',
                                      style: textTheme.titleSmall?.copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      event.applyUrl!,
                                      style: textTheme.bodySmall?.copyWith(
                                        fontSize: 11,
                                        color: colorScheme.primary,
                                        decoration: TextDecoration.underline,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(LucideIcons.copy, size: 16),
                                tooltip: 'Copy Link',
                                visualDensity: VisualDensity.compact,
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: event.applyUrl!));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Registration link copied to clipboard!'),
                                      duration: Duration(seconds: 2),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Application Deadline Card
                  if (event.deadlineAt != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.alarmClock, size: 20, color: colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Application Deadline',
                                  style: textTheme.titleSmall?.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  DateFormat('EEEE, d MMMM yyyy • h:mm a')
                                      .format(event.deadlineAt!),
                                  style: textTheme.bodySmall?.copyWith(
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => _handleSyncDeadlineToCalendar(context, ref, event),
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                            ),
                            child: const Text('Sync Deadline', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Student Coordinators / For Queries Section
                  if (event.contacts.isNotEmpty) ...[
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
                      children: event.contacts.map((contact) {
                        final rawPhone = contact.phone.replaceAll(RegExp(r'[^0-9]'), '');
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
                                child: Icon(LucideIcons.user, size: 16, color: colorScheme.onPrimaryContainer),
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
                                  icon: const Icon(LucideIcons.messageCircle, size: 18, color: Color(0xFF25D366)),
                                  tooltip: 'WhatsApp',
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () {
                                    final waNumber = rawPhone.startsWith('91') || rawPhone.length > 10
                                        ? rawPhone
                                        : '91$rawPhone';
                                    launchUrl(
                                      Uri.parse('https://wa.me/$waNumber?text=Hi%20${Uri.encodeComponent(contact.name)},%20reaching%20out%20regarding%20${Uri.encodeComponent(event.title)}'),
                                      mode: LaunchMode.externalApplication,
                                    );
                                  },
                                ),
                                // Direct Phone Call Action
                                IconButton(
                                  icon: Icon(LucideIcons.phone, size: 18, color: colorScheme.primary),
                                  tooltip: 'Call Coordinator',
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () {
                                    launchUrl(
                                      Uri.parse('tel:${contact.phone.replaceAll(' ', '')}'),
                                      mode: LaunchMode.externalApplication,
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  // Attached Images & Materials Gallery
                  if (event.attachments.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Attached Images & Materials',
                          style: textTheme.titleMedium?.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          '${event.attachments.length} files',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: event.attachments.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 10),
                        itemBuilder: (context, idx) {
                          final imgUrl = event.attachments[idx];
                          return GestureDetector(
                            onTap: () => _showFullscreenImage(context, imgUrl),
                            child: Container(
                              width: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(13),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: imgUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: colorScheme.surfaceContainer,
                                        child: const Center(
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        color: colorScheme.surfaceContainerHigh,
                                        child: const Icon(LucideIcons.fileText, size: 24),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 6,
                                      right: 6,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Icon(LucideIcons.zoomIn, size: 12, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),

      // Glassmorphic Floating Bottom Action Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.96),
          border: Border(
            top: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(
          16,
          10,
          16,
          MediaQuery.of(context).padding.bottom + 10,
        ),
        child: Row(
          children: [
            // Add to Calendar Quick Action
            M3EMorphIconButton(
              size: 46,
              iconSize: 20,
              icon: LucideIcons.calendarPlus,
              color: colorScheme.primary,
              backgroundColor: colorScheme.surfaceContainerLow,
              onPressed: () => _handleAddToCalendar(context, ref, event),
              tooltip: 'Sync with Calendar',
              morphShape: M3EMorphShape.circleToSquircle,
            ),

            const SizedBox(width: 8),

            // Remind Notification Morph Action (Circle <-> Squircle)
            M3EMorphIconButton(
              size: 46,
              iconSize: 20,
              icon: LucideIcons.bell,
              selectedIcon: LucideIcons.bellRing,
              isSelected: state.isReminded,
              color: colorScheme.onSurfaceVariant,
              selectedColor: colorScheme.onPrimaryContainer,
              backgroundColor: colorScheme.surfaceContainerLow,
              selectedBackgroundColor: colorScheme.primaryContainer,
              onPressed: () => _showReminderDialog(context, controller, state),
              tooltip: state.isReminded ? 'Reminder set' : 'Set reminder',
              morphShape: M3EMorphShape.circleToSquircle,
            ),

            const SizedBox(width: 8),

            // Bookmark Morph Action (Circle <-> Squircle)
            M3EMorphIconButton(
              size: 46,
              iconSize: 20,
              icon: LucideIcons.bookmark,
              selectedIcon: LucideIcons.bookmarkCheck,
              isSelected: state.isSaved,
              color: colorScheme.onSurfaceVariant,
              selectedColor: colorScheme.primary,
              backgroundColor: colorScheme.surfaceContainerLow,
              selectedBackgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.2),
              onPressed: () => controller.toggleSave(),
              tooltip: state.isSaved ? 'Saved' : 'Save event',
              morphShape: M3EMorphShape.circleToSquircle,
            ),

            const SizedBox(width: 12),

            // Primary Apply Now CTA Button
            Expanded(
              child: InteractiveSpring(
                onTap: state.isApplying ? null : () => controller.launchApply(),
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.primaryContainer,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: state.isApplying
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: colorScheme.onPrimary,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Apply Now',
                                style: textTheme.labelLarge?.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                LucideIcons.arrowUpRight,
                                color: colorScheme.onPrimary,
                                size: 18,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBentoLogistics(
    BuildContext context,
    WidgetRef ref,
    EventModel event,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Row 1: Date & Time + Location & Mode
        Row(
          children: [
            Expanded(
              child: _buildBentoTile(
                context: context,
                icon: LucideIcons.calendar,
                iconColor: colorScheme.primary,
                label: 'WHEN',
                mainText: event.formattedDateRange,
                subText: event.startsAt != null
                    ? '${DateFormat('h:mm a').format(event.startsAt!)} onwards'
                    : 'Schedule',
                actionWidget: InkWell(
                  onTap: () => _handleAddToCalendar(context, ref, event),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.calendarPlus, size: 11, color: colorScheme.primary),
                        const SizedBox(width: 3),
                        Text(
                          'Add to Cal',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildBentoTile(
                context: context,
                icon: LucideIcons.mapPin,
                iconColor: const Color(0xFFEF5350),
                label: 'WHERE',
                mainText: (event.venue != null && event.venue!.isNotEmpty)
                    ? event.venue!
                    : 'SXUK Campus',
                subText: 'Mode: ${event.formattedFormat}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Row 2: Team Size + Eligibility
        Row(
          children: [
            Expanded(
              child: _buildBentoTile(
                context: context,
                icon: LucideIcons.usersRound,
                iconColor: const Color(0xFF26C6DA),
                label: 'TEAM FORMAT',
                mainText: (event.teamSizeText != null && event.teamSizeText!.isNotEmpty)
                    ? event.teamSizeText!
                    : 'Individual / Teams',
                subText: 'Participation',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildBentoTile(
                context: context,
                icon: LucideIcons.shieldCheck,
                iconColor: const Color(0xFF66BB6A),
                label: 'ELIGIBILITY',
                mainText: (event.eligibilityText != null && event.eligibilityText!.isNotEmpty)
                    ? event.eligibilityText!
                    : 'All Branches',
                subText: 'SXUK Students',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBentoTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String mainText,
    required String subText,
    Widget? actionWidget,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
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
                  Icon(icon, size: 14, color: iconColor),
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              ?actionWidget,
            ],
          ),
          const SizedBox(height: 8),
          Text(
            mainText,
            style: textTheme.titleSmall?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subText,
            style: textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: colorScheme.outline,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMatchedTagsBar(BuildContext context, EventModel event) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final tags = event.matchedTags.isNotEmpty
        ? event.matchedTags
        : ['Tech', 'Coding', 'Innovation'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.sparkles, size: 14, color: colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                'PERSONALIZED FIT',
                style: textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: colorScheme.primary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${((event.matchScore ?? 0.95) * 100).toInt()}% Match',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: tags.map(
              (tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '#$tag',
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ).toList(),
          ),
        ],
      ),
    );
  }

  void _showReminderDialog(
    BuildContext context,
    EventDetailsController controller,
    EventDetailsState state,
  ) {
    if (state.isReminded) {
      showDialog(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          title: const Text('Remove Reminder?'),
          content: const Text(
              'Do you want to cancel the active reminder for this event?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Keep'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogCtx);
                controller.removeReminder();
              },
              child: const Text('Remove'),
            ),
          ],
        ),
      );
      return;
    }

    final event = state.event ?? widget.event;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetCtx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Text(
                'Set Event Reminder',
                style: textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Choose when you would like to receive an alert before the event deadline:',
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              if (event?.deadlineAt != null) ...[
                ListTile(
                  leading: Icon(LucideIcons.calendarCheck, color: colorScheme.primary, size: 20),
                  title: const Text('Add Deadline to Device Calendar'),
                  subtitle: Text(
                    'Syncs 2-hour pre-deadline alert to Google / Apple Calendar',
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(bottomSheetCtx);
                    _handleSyncDeadlineToCalendar(context, ref, event!);
                  },
                ),
                Divider(height: 16, color: colorScheme.surfaceContainerHighest),
              ],
              ListTile(
                leading: Icon(LucideIcons.alarmClock, color: colorScheme.primary, size: 20),
                title: const Text('1 Day Before Deadline (App Notification)'),
                onTap: () {
                  Navigator.pop(bottomSheetCtx);
                  final target = event?.deadlineAt ??
                      event?.startsAt ??
                      DateTime.now().add(const Duration(days: 1));
                  controller.setReminder(
                      target.subtract(const Duration(days: 1)));
                },
              ),
              ListTile(
                leading: Icon(LucideIcons.timer, color: colorScheme.primary, size: 20),
                title: const Text('2 Hours Before Deadline (App Notification)'),
                onTap: () {
                  Navigator.pop(bottomSheetCtx);
                  final target = event?.deadlineAt ??
                      event?.startsAt ??
                      DateTime.now().add(const Duration(hours: 4));
                  controller.setReminder(
                      target.subtract(const Duration(hours: 2)));
                },
              ),
              ListTile(
                leading: Icon(LucideIcons.calendarClock, color: colorScheme.primary, size: 20),
                title: const Text('Custom Date & Time'),
                onTap: () async {
                  Navigator.pop(bottomSheetCtx);
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (date != null && context.mounted) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 10, minute: 0),
                    );
                    if (time != null) {
                      final selectedDateTime = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                      controller.setReminder(selectedDateTime);
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleAddToCalendar(
    BuildContext context,
    WidgetRef ref,
    EventModel event,
  ) async {
    final success =
        await ref.read(calendarSyncServiceProvider).addEventToCalendar(event);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success ? LucideIcons.calendarCheck : LucideIcons.calendar,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  success
                      ? 'Added "${event.title}" to calendar!'
                      : 'Opened calendar sync for "${event.title}"',
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleSyncDeadlineToCalendar(
    BuildContext context,
    WidgetRef ref,
    EventModel event,
  ) async {
    final success = await ref
        .read(calendarSyncServiceProvider)
        .addDeadlineReminderToCalendar(event);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success ? LucideIcons.alarmClockCheck : LucideIcons.alarmClock,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  success
                      ? 'Added deadline reminder to calendar!'
                      : 'Opened deadline calendar sync',
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showFullscreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogCtx) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(LucideIcons.x, color: Colors.white, size: 24),
              onPressed: () => Navigator.pop(dialogCtx),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.8,
              maxScale: 4.0,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(LucideIcons.imageOff, color: Colors.white, size: 48),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
