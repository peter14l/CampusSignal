import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/widgets/m3e_event_card.dart';
import '../../core/widgets/m3e_states.dart';
import '../../core/widgets/micro_animated_icon.dart';
import '../search/search_controller.dart';

class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchControllerProvider);
    final savedEvents = searchState.allEvents.take(4).toList();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Saved & Bookmarks'),
        actions: [
          MicroAnimatedIconButton.circle(
            size: 38,
            iconSize: 19,
            iconData: LucideIcons.search,
            color: colorScheme.onSurfaceVariant,
            backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            onPressed: () => context.push('/search'),
            tooltip: 'Search Saved',
          ),
          const SizedBox(width: 6),
          MicroAnimatedIconButton.circle(
            size: 38,
            iconSize: 19,
            iconData: LucideIcons.bell,
            color: colorScheme.onSurfaceVariant,
            backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            onPressed: () => context.push('/notifications'),
            tooltip: 'Notifications',
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: savedEvents.isEmpty
          ? const M3EEmptyState(
              icon: LucideIcons.bookmark,
              title: 'No saved items yet',
              message:
                  'Bookmark opportunities from your feed to view them here.',
            )
          : ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: savedEvents.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final event = savedEvents[index];
                return M3EEventCard(
                  event: event,
                  isSaved: true,
                  heroTagSuffix: '_saved',
                  onTap: () => context.push('/event/${event.id}'),
                );
              },
            ),
    );
  }
}
