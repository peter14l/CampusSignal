import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/widgets/micro_animated_icon.dart';
import '../../../models/event_model.dart';

/// Collapsing Hero SliverAppBar with poster image, vignette, and top actions
class EventDetailsSliverHeader extends StatelessWidget {
  final EventModel event;
  final VoidCallback onBackPressed;
  final VoidCallback onAddToCalendar;
  final VoidCallback onShare;
  final void Function(String imageUrl) onFullscreenImage;

  const EventDetailsSliverHeader({
    super.key,
    required this.event,
    required this.onBackPressed,
    required this.onAddToCalendar,
    required this.onShare,
    required this.onFullscreenImage,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverAppBar(
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
            onPressed: onBackPressed,
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
          onPressed: onAddToCalendar,
          tooltip: 'Add to Calendar',
        ),
        const SizedBox(width: 8),
        MicroAnimatedIconButton.circle(
          size: 38,
          iconSize: 18,
          iconData: LucideIcons.share2,
          color: colorScheme.onSurface,
          backgroundColor: colorScheme.surface.withValues(alpha: 0.85),
          onPressed: onShare,
          tooltip: 'Share Event',
        ),
        const SizedBox(width: 12),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (event.posterR2Key != null && event.posterR2Key!.startsWith('http'))
              GestureDetector(
                onTap: () => onFullscreenImage(event.posterR2Key!),
                child: CachedNetworkImage(
                  imageUrl: event.posterR2Key!,
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
                      child: Icon(LucideIcons.imageOff, color: Colors.white, size: 48),
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
                      Text(
                        'Tap to expand',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
