import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants/app_constants.dart';
import '../../core/mock/mock_data.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/widgets/interactive_spring.dart';
import '../auth/auth_controller.dart';
import '../profile/profile_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out from your St. Xavier\'s University student account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/auth');
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _confirmClearCache(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Local Cache'),
        content: const Text(
          'This will refresh temporary image cache and synchronize newest notices from the SXUK cloud signal feed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Local cache refreshed successfully.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Clear & Refresh'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeSettings = ref.watch(themeControllerProvider);
    final themeNotifier = ref.read(themeControllerProvider.notifier);
    final profileState = ref.watch(profileControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final profile = profileState.profile ?? authState.profile ?? kDefaultProfile;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Settings & Preferences',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // Account Summary Header Card
          InteractiveSpring(
            onTap: () => context.push('/profile'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primaryContainer, colorScheme.secondaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipOval(
                    child: profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: profile.avatarUrl!,
                            width: 52,
                            height: 52,
                            memCacheWidth: 120,
                            memCacheHeight: 120,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => _buildAvatarFallback(colorScheme),
                          )
                        : _buildAvatarFallback(colorScheme),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.fullName.isNotEmpty ? profile.fullName : 'SXUK Student',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${profile.departmentLabel} • ${profile.semesterLabel}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onPrimaryContainer.withValues(alpha: 0.85),
                          ),
                        ),
                        if (profile.collegeEmail != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            profile.collegeEmail!,
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    LucideIcons.chevronRight,
                    color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Section 1: Appearance & Dynamic Palette
          _buildSectionHeader('APPEARANCE & DYNAMIC THEMING', colorScheme.primary),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Material You Toggle
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        LucideIcons.sparkles,
                        color: colorScheme.onPrimaryContainer,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Material You Wallpaper Theming',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Adapts app palette dynamically from your Android wallpaper.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: themeSettings.useMaterialYou,
                      onChanged: (val) {
                        themeNotifier.toggleMaterialYou(val);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              val
                                  ? 'Material You Dynamic Theming enabled.'
                                  : 'Reverted to CampusSignal Deep SXUK Indigo theme.',
                            ),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                const SizedBox(height: 16),

                // Theme Mode Selector
                Text(
                  'Theme Mode',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildThemeModeCard(
                        context: context,
                        title: 'System',
                        icon: LucideIcons.smartphone,
                        isSelected: themeSettings.themeMode == ThemeMode.system,
                        onTap: () => themeNotifier.setThemeMode(ThemeMode.system),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildThemeModeCard(
                        context: context,
                        title: 'Light',
                        icon: LucideIcons.sun,
                        isSelected: themeSettings.themeMode == ThemeMode.light,
                        onTap: () => themeNotifier.setThemeMode(ThemeMode.light),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildThemeModeCard(
                        context: context,
                        title: 'Dark',
                        icon: LucideIcons.moon,
                        isSelected: themeSettings.themeMode == ThemeMode.dark,
                        onTap: () => themeNotifier.setThemeMode(ThemeMode.dark),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section 2: Notifications & Signal Alerts
          _buildSectionHeader('NOTIFICATIONS & SIGNAL ALERTS', colorScheme.primary),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
            ),
            child: Column(
              children: [
                _buildSwitchTile(
                  icon: LucideIcons.bell,
                  title: 'Push Notifications',
                  subtitle: 'Receive instant signals for new hackathons and drives.',
                  value: themeSettings.pushNotificationsEnabled,
                  onChanged: (val) => themeNotifier.togglePushNotifications(val),
                  colorScheme: colorScheme,
                ),
                Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                _buildSwitchTile(
                  icon: LucideIcons.clock,
                  title: 'Deadline Countdown Alerts',
                  subtitle: 'Notify 24 hours and 2 hours before registrations close.',
                  value: themeSettings.deadlineAlertsEnabled,
                  onChanged: (val) => themeNotifier.toggleDeadlineAlerts(val),
                  colorScheme: colorScheme,
                ),
                Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                _buildSwitchTile(
                  icon: LucideIcons.bookmark,
                  title: 'Event Reminders',
                  subtitle: 'Alerts for saved calendar bookmarks.',
                  value: themeSettings.eventRemindersEnabled,
                  onChanged: (val) => themeNotifier.toggleEventReminders(val),
                  colorScheme: colorScheme,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section 3: Data & Storage
          _buildSectionHeader('DATA, CLOUD & PRIVACY', colorScheme.primary),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(LucideIcons.cloud, size: 18, color: colorScheme.onPrimaryContainer),
                  ),
                  title: const Text('Cloud Sync Status', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Synced with SXUK CampusSignal Engine', style: TextStyle(fontSize: 12)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                ),
                Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(LucideIcons.rotateCcw, size: 18, color: colorScheme.onSurface),
                  ),
                  title: const Text('Clear Local Cache', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Refresh cached images and feed items', style: TextStyle(fontSize: 12)),
                  trailing: Icon(LucideIcons.chevronRight, size: 18, color: colorScheme.onSurfaceVariant),
                  onTap: () => _confirmClearCache(context),
                ),
                Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(LucideIcons.sparkles, size: 18, color: colorScheme.onPrimaryContainer),
                  ),
                  title: const Text('In-App Updater', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Check for new APK releases on Cloudflare R2', style: TextStyle(fontSize: 12)),
                  trailing: Icon(LucideIcons.chevronRight, size: 18, color: colorScheme.onSurfaceVariant),
                  onTap: () => context.push('/app-update'),
                ),
                Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(LucideIcons.shield, size: 18, color: colorScheme.onSurface),
                  ),
                  title: const Text('Privacy Policy & DPDP Compliance', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Digital Personal Data Protection Act (India)', style: TextStyle(fontSize: 12)),
                  trailing: Icon(LucideIcons.chevronRight, size: 18, color: colorScheme.onSurfaceVariant),
                  onTap: () => context.push('/privacy-policy'),
                ),
                Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(LucideIcons.info, size: 18, color: colorScheme.onSurface),
                  ),
                  title: const Text('About CampusSignal', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Version ${AppConstants.appVersionDisplay}', style: TextStyle(fontSize: 12)),
                  trailing: Icon(LucideIcons.chevronRight, size: 18, color: colorScheme.onSurfaceVariant),
                  onTap: () => context.push('/about'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section 4: Sign Out Danger Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorScheme.error.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(LucideIcons.logOut, color: colorScheme.error, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Session',
                        style: TextStyle(fontWeight: FontWeight.w700, color: colorScheme.error, fontSize: 14),
                      ),
                      Text(
                        'Sign out of current SXUK student session',
                        style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () => _confirmSignOut(context, ref),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colorScheme.error),
                    foregroundColor: colorScheme.error,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  child: const Text('Sign Out'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.w800,
        fontSize: 11,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildThemeModeCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer : colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ColorScheme colorScheme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: colorScheme.onSurface),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                Text(subtitle, style: TextStyle(fontSize: 11.5, color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(ColorScheme colorScheme) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(LucideIcons.user, color: colorScheme.onPrimary, size: 26),
      ),
    );
  }
}
