import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'app_logo_badge.dart';
import 'micro_animated_icon.dart';

/// App Header with CampusSignal branding/logo, Screen Title, Search button, and Profile avatar.
class M3EHeaderBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onSearchTap;
  final VoidCallback? onProfileTap;
  final Widget? leading;
  final bool showLogo;
  final String? avatarUrl;

  const M3EHeaderBar({
    super.key,
    required this.title,
    this.onSearchTap,
    this.onProfileTap,
    this.leading,
    this.showLogo = true,
    this.avatarUrl,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Leading / Logo & Title
              Row(
                children: [
                  if (leading != null) ...[
                    leading!,
                    const SizedBox(width: 8),
                  ],
                  if (showLogo && leading == null) ...[
                    const AppLogoBadge(
                      size: 32,
                      borderRadius: 9,
                      hasShadow: false,
                    ),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),

              // Action Buttons: Search + Profile Avatar
              Row(
                children: [
                  if (onSearchTap != null) ...[
                    MicroAnimatedIconButton.circle(
                      size: 38,
                      iconSize: 19,
                      iconData: LucideIcons.search,
                      color: colorScheme.onSurfaceVariant,
                      backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                      onPressed: onSearchTap,
                      tooltip: 'Search Events',
                    ),
                    const SizedBox(width: 8),
                  ],
                  MicroAnimatedIcon(
                    onTap: onProfileTap,
                    pressedScale: 0.88,
                    bounceOvershoot: 1.12,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.18),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: avatarUrl != null && avatarUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: avatarUrl!,
                                width: 36,
                                height: 36,
                                memCacheWidth: 100,
                                memCacheHeight: 100,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => Center(
                                  child: Icon(
                                    LucideIcons.user,
                                    color: colorScheme.onPrimary,
                                    size: 18,
                                  ),
                                ),
                              )
                            : Center(
                                child: Icon(
                                  LucideIcons.user,
                                  color: colorScheme.onPrimary,
                                  size: 18,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
