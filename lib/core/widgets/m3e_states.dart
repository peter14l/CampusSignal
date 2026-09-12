import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'interactive_spring.dart';

/// Loading state widget with animated skeleton placeholders or circular indicator.
class M3ELoadingState extends StatelessWidget {
  final int itemCount;
  final String? message;
  final bool asSkeleton;

  const M3ELoadingState({
    super.key,
    this.itemCount = 3,
    this.message,
    this.asSkeleton = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (!asSkeleton) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                strokeWidth: 3,
                color: colorScheme.primary,
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) => _buildSkeletonCard(context),
    );
  }

  Widget _buildSkeletonCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildShimmerBlock(width: 80, height: 24, radius: 8, context: context),
              _buildShimmerBlock(width: 60, height: 20, radius: 4, context: context),
            ],
          ),
          const SizedBox(height: 14),
          _buildShimmerBlock(width: double.infinity, height: 20, radius: 4, context: context),
          const SizedBox(height: 8),
          _buildShimmerBlock(width: 200, height: 14, radius: 4, context: context),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildShimmerBlock(width: 120, height: 14, radius: 4, context: context),
              const SizedBox(width: 16),
              _buildShimmerBlock(width: 80, height: 14, radius: 4, context: context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBlock({
    required double width,
    required double height,
    required double radius,
    required BuildContext context,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Empty state widget matching the Material 3 Expressive design.
class M3EEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final String? message;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  const M3EEmptyState({
    super.key,
    this.icon = LucideIcons.inbox,
    required this.title,
    this.description,
    this.message,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveText = description ?? message ?? '';
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ambient halo icon container
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withValues(alpha: 0.08),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primary.withValues(alpha: 0.12),
                  ),
                  child: Icon(
                    icon,
                    size: 26,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
                letterSpacing: -0.2,
              ),
            ),
            if (effectiveText.isNotEmpty) ...[
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Text(
                  effectiveText,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              InteractiveSpring(
                onTap: onAction,
                child: FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: onAction,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (actionIcon != null) ...[
                        Icon(actionIcon, size: 16),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        actionLabel!,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error state with retry callback matching M3 Expressive tokens.
class M3EErrorState extends StatelessWidget {
  final String? title;
  final String? error;
  final String? message;
  final String retryLabel;
  final VoidCallback? onRetry;
  final IconData icon;

  const M3EErrorState({
    super.key,
    this.title,
    this.error,
    this.message,
    this.retryLabel = 'Retry',
    this.onRetry,
    this.icon = LucideIcons.alertCircle,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveError = error ?? message ?? 'An unexpected error occurred';
    final effectiveTitle = title ?? 'Something went wrong';
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 28,
                color: colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              effectiveTitle,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              effectiveError,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(LucideIcons.rotateCw, size: 18),
                label: Text(retryLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
