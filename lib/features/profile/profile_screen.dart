import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants/app_constants.dart';
import '../../core/mock/mock_data.dart';
import '../../core/widgets/interactive_spring.dart';
import '../auth/auth_controller.dart';
import 'profile_controller.dart';
import 'tag_selection_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text(
          'Are you sure you want to sign out of CampusSignal? Your offline saved events and preferences will remain cached.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/auth');
              }
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final profile = profileState.profile ?? authState.profile ?? kDefaultProfile;
    final stats = profileState.stats;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Student Profile',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.settings, size: 20),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
          IconButton(
            icon: const Icon(LucideIcons.bell, size: 20),
            tooltip: 'Notifications',
            onPressed: () => context.push('/notifications'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          children: [
            // Top Hero Card with Profile Information
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primaryContainer,
                    colorScheme.surfaceContainerLow,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  width: 1.2,
                ),
              ),
              child: Column(
                children: [
                  // Avatar with Google picture & Camera badge
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.surfaceContainerHighest,
                          border: Border.all(
                            color: colorScheme.primary,
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: profile.avatarUrl!,
                                  width: 92,
                                  height: 92,
                                  memCacheWidth: 200,
                                  memCacheHeight: 200,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => _buildAvatarFallback(colorScheme),
                                )
                              : _buildAvatarFallback(colorScheme),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: const Icon(
                            LucideIcons.camera,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Full Name
                  Text(
                    profile.fullName.isNotEmpty ? profile.fullName : 'SXUK Student',
                    style: textTheme.titleLarge?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),

                  // Verified SXUK Student Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.badgeCheck, size: 14, color: colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          'Verified SXUK Member',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Department & Semester Pills
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.graduationCap, size: 14, color: colorScheme.onSurfaceVariant),
                            const SizedBox(width: 6),
                            Text(
                              profile.departmentLabel,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.calendar, size: 14, color: colorScheme.onSecondaryContainer),
                            const SizedBox(width: 6),
                            Text(
                              profile.semesterLabel,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  if (profile.collegeEmail != null && profile.collegeEmail!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      profile.collegeEmail!,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Edit Profile CTA
                  OutlinedButton.icon(
                    onPressed: () => context.push('/edit-profile'),
                    icon: const Icon(LucideIcons.pencil, size: 15),
                    label: const Text('Edit Academic Details'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Stats Summary Grid (Saved, Applied, Reminders)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Saved Events',
                      count: '${stats.savedEventsCount}',
                      icon: LucideIcons.bookmark,
                      colorScheme: colorScheme,
                      onTap: () => context.push('/saved'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Applied Drives',
                      count: '${stats.appliedCount}',
                      icon: LucideIcons.send,
                      colorScheme: colorScheme,
                      onTap: () => context.push('/calendar'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Reminders',
                      count: '${stats.remindersCount}',
                      icon: LucideIcons.alarmClock,
                      colorScheme: colorScheme,
                      onTap: () => context.push('/calendar'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Interests & Discovery Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(LucideIcons.sparkles, size: 18, color: colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Interests & Activities',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(LucideIcons.circlePlus, size: 20, color: colorScheme.primary),
                          onPressed: () => TagSelectionSheet.show(
                            context,
                            isSkill: false,
                            currentTags: profile.interests,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (profile.interests.isEmpty)
                      Text(
                        'No interests added yet. Add chips to personalize your feed.',
                        style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: profile.interests.map((interest) {
                          return Chip(
                            label: Text(interest),
                            backgroundColor: colorScheme.primaryContainer,
                            labelStyle: TextStyle(
                              color: colorScheme.onPrimaryContainer,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                            deleteIcon: const Icon(LucideIcons.x, size: 13),
                            onDeleted: () {
                              HapticFeedback.lightImpact();
                              ref.read(profileControllerProvider.notifier).removeInterest(interest);
                            },
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Skills & Tech Domains Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(LucideIcons.wrench, size: 18, color: colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Skills & Tech Domains',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(LucideIcons.circlePlus, size: 20, color: colorScheme.primary),
                          onPressed: () => TagSelectionSheet.show(
                            context,
                            isSkill: true,
                            currentTags: profile.skills,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (profile.skills.isEmpty)
                      Text(
                        'No skills added yet. Add skills to match with hackathons & projects.',
                        style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: profile.skills.map((skill) {
                          return Chip(
                            label: Text(skill),
                            backgroundColor: colorScheme.secondaryContainer,
                            labelStyle: TextStyle(
                              color: colorScheme.onSecondaryContainer,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            deleteIcon: const Icon(LucideIcons.x, size: 13),
                            onDeleted: () {
                              HapticFeedback.lightImpact();
                              ref.read(profileControllerProvider.notifier).removeSkill(skill);
                            },
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick Hub Navigation Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    _buildHubTile(
                      icon: LucideIcons.palette,
                      title: 'Settings & Theming (Material You)',
                      subtitle: 'Dark mode, wallpapers & alerts',
                      onTap: () => context.push('/settings'),
                      colorScheme: colorScheme,
                    ),
                    Divider(height: 1, indent: 56, color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                    _buildHubTile(
                      icon: LucideIcons.shield,
                      title: 'Privacy Policy & DPDP Act',
                      subtitle: 'How your data is protected',
                      onTap: () => context.push('/privacy-policy'),
                      colorScheme: colorScheme,
                    ),
                    Divider(height: 1, indent: 56, color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                    _buildHubTile(
                      icon: LucideIcons.info,
                      title: 'About CampusSignal',
                      subtitle: 'Version ${AppConstants.appVersionDisplay}',
                      onTap: () => context.push('/about'),
                      colorScheme: colorScheme,
                    ),
                    Divider(height: 1, indent: 56, color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                    _buildHubTile(
                      icon: LucideIcons.logOut,
                      title: 'Sign Out',
                      subtitle: 'End current student session',
                      iconColor: colorScheme.error,
                      textColor: colorScheme.error,
                      onTap: () => _confirmSignOut(context, ref),
                      colorScheme: colorScheme,
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

  Widget _buildStatCard({
    required String title,
    required String count,
    required IconData icon,
    required ColorScheme colorScheme,
    required VoidCallback onTap,
  }) {
    return InteractiveSpring(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: colorScheme.primary),
            const SizedBox(height: 6),
            Text(
              count,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHubTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor ?? colorScheme.onSurface, size: 18),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? colorScheme.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 11.5,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        LucideIcons.chevronRight,
        color: colorScheme.onSurfaceVariant,
        size: 18,
      ),
      onTap: onTap,
    );
  }

  Widget _buildAvatarFallback(ColorScheme colorScheme) {
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(LucideIcons.user, color: colorScheme.onPrimary, size: 44),
      ),
    );
  }
}
