import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/widgets/m3e_states.dart';
import '../../models/notification_model.dart';
import 'notifications_controller.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifState = ref.watch(notificationsControllerProvider);
    final notifCtrl = ref.read(notificationsControllerProvider.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final todayList = notifState.todayNotifications;
    final earlierList = notifState.earlierNotifications;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notifState.unreadCount > 0)
            IconButton(
              icon: const Icon(LucideIcons.checkCheck),
              tooltip: 'Mark all as read',
              onPressed: () => notifCtrl.markAllAsRead(),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: notifState.notifications.isEmpty
          ? const M3EEmptyState(
              icon: LucideIcons.bellOff,
              title: 'No notifications yet',
              message: 'You are all caught up! We will notify you about deadlines, opportunities, and campus announcements.',
            )
          : ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                if (todayList.isNotEmpty) ...[
                  _buildSectionHeader('Today', context),
                  ...todayList.map((item) =>
                      _buildNotificationCard(context, ref, item, theme)),
                ],
                if (earlierList.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildSectionHeader('Earlier', context),
                  ...earlierList.map((item) =>
                      _buildNotificationCard(context, ref, item, theme)),
                ],
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    WidgetRef ref,
    NotificationItem item,
    ThemeData theme,
  ) {
    final notifCtrl = ref.read(notificationsControllerProvider.notifier);
    final colorScheme = theme.colorScheme;

    IconData icon;
    Color iconBg;
    Color iconColor;

    switch (item.type) {
      case 'group':
        icon = LucideIcons.sparkles;
        iconBg = colorScheme.primaryContainer;
        iconColor = colorScheme.onPrimaryContainer;
        break;
      case 'deadline':
        icon = LucideIcons.clock;
        iconBg = colorScheme.secondaryContainer;
        iconColor = colorScheme.onSecondaryContainer;
        break;
      case 'event':
        icon = LucideIcons.megaphone;
        iconBg = colorScheme.tertiaryContainer;
        iconColor = colorScheme.onTertiaryContainer;
        break;
      case 'advisor':
        icon = LucideIcons.messageSquare;
        iconBg = colorScheme.surfaceContainerHighest;
        iconColor = colorScheme.onSurfaceVariant;
        break;
      default:
        icon = LucideIcons.bell;
        iconBg = colorScheme.surfaceContainerHigh;
        iconColor = colorScheme.onSurfaceVariant;
    }

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => notifCtrl.deleteNotification(item.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child:
            Icon(LucideIcons.trash2, color: colorScheme.onErrorContainer, size: 20),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: item.isRead
              ? colorScheme.surfaceContainerLow
              : colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.isRead
                ? Colors.transparent
                : colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              notifCtrl.markAsRead(item.id);
              if (item.actionUrl != null && item.actionUrl!.isNotEmpty) {
                context.push(item.actionUrl!);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon bubble
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: iconBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 14),

                  // Notification Title & Message
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: item.isRead
                                      ? FontWeight.w600
                                      : FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              item.timeAgoLabel,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 11,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.message,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: item.isRead ? 0.75 : 0.95,
                            ),
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Unread indicator dot
                  if (!item.isRead) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
