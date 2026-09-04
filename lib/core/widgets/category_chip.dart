import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../constants/app_constants.dart';
import '../theme/motion.dart';

/// Style configuration for a specific category badge/chip
class CategoryStyle {
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;

  const CategoryStyle({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
  });
}

/// M3 Expressive Category Chip / Badge with category-specific tinting and spring tap feedback
class CategoryChip extends StatefulWidget {
  final String category;
  final String? label;
  final bool isSelected;
  final bool isFilter;
  final ValueChanged<bool>? onSelected;
  final VoidCallback? onTap;
  final bool showIcon;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  const CategoryChip({
    super.key,
    required this.category,
    this.label,
    this.isSelected = false,
    this.isFilter = false,
    this.onSelected,
    this.onTap,
    this.showIcon = true,
    this.fontSize = 12,
    this.padding,
  });

  /// Retrieve category styling dynamically matching the active Theme ColorScheme
  static CategoryStyle getStyle(String category, BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    switch (category.toLowerCase()) {
      case AppConstants.categoryHackathon:
        return CategoryStyle(
          backgroundColor: scheme.secondaryContainer,
          foregroundColor: scheme.onSecondaryContainer,
          icon: LucideIcons.code,
        );
      case AppConstants.categoryInternship:
        return CategoryStyle(
          backgroundColor: scheme.tertiaryContainer,
          foregroundColor: scheme.onTertiaryContainer,
          icon: LucideIcons.briefcase,
        );
      case AppConstants.categoryWorkshop:
        return CategoryStyle(
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onPrimaryContainer,
          icon: LucideIcons.wrench,
        );
      case AppConstants.categoryFest:
        return CategoryStyle(
          backgroundColor: scheme.tertiaryContainer.withValues(alpha: 0.8),
          foregroundColor: scheme.onTertiaryContainer,
          icon: LucideIcons.partyPopper,
        );
      case AppConstants.categorySeminar:
        return CategoryStyle(
          backgroundColor: scheme.surfaceContainerHigh,
          foregroundColor: scheme.onSurface,
          icon: LucideIcons.graduationCap,
        );
      case AppConstants.categoryClub:
        return CategoryStyle(
          backgroundColor: scheme.secondaryContainer.withValues(alpha: 0.7),
          foregroundColor: scheme.onSecondaryContainer,
          icon: LucideIcons.users,
        );
      case AppConstants.categoryNetworking:
        return CategoryStyle(
          backgroundColor: scheme.primaryContainer.withValues(alpha: 0.7),
          foregroundColor: scheme.onPrimaryContainer,
          icon: LucideIcons.network,
        );
      case AppConstants.categorySports:
        return CategoryStyle(
          backgroundColor: scheme.secondaryContainer,
          foregroundColor: scheme.primary,
          icon: LucideIcons.trophy,
        );
      case AppConstants.categoryAll:
      default:
        return CategoryStyle(
          backgroundColor: scheme.surfaceContainerHighest,
          foregroundColor: scheme.onSurfaceVariant,
          icon: LucideIcons.layoutGrid,
        );
    }
  }

  @override
  State<CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<CategoryChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: AppMotion.durationShort2,
      reverseDuration: AppMotion.durationShort3,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: AppMotion.emphasizedAccelerate,
        reverseCurve: AppMotion.spring,
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails _) {
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final style = CategoryChip.getStyle(widget.category, context);
    final labelText = widget.label ??
        (widget.isFilter
            ? AppConstants.categoryLabels[widget.category] ?? widget.category
            : AppConstants.categoryBadgeLabels[widget.category] ??
                widget.category);

    final isInteractive =
        widget.isFilter || widget.onTap != null || widget.onSelected != null;
    final colorScheme = Theme.of(context).colorScheme;

    final Color effectiveBg = widget.isFilter
        ? (widget.isSelected
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerLow)
        : style.backgroundColor;

    final Color effectiveFg = widget.isFilter
        ? (widget.isSelected
            ? colorScheme.onPrimaryContainer
            : colorScheme.onSurfaceVariant)
        : style.foregroundColor;

    final Widget chipContent = AnimatedContainer(
      duration: AppMotion.durationShort3,
      curve: AppMotion.standardDecelerate,
      padding: widget.padding ??
          EdgeInsets.symmetric(
            horizontal: widget.isFilter ? 14 : 10,
            vertical: widget.isFilter ? 8 : 5,
          ),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(widget.isFilter ? 12 : 8),
        border: Border.all(
          color: widget.isFilter && !widget.isSelected
              ? colorScheme.outlineVariant.withValues(alpha: 0.6)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showIcon) ...[
            Icon(
              style.icon,
              size: widget.fontSize + 3,
              color: effectiveFg,
            ),
            const SizedBox(width: 5),
          ],
          Text(
            labelText,
            style: TextStyle(
              color: effectiveFg,
              fontSize: widget.fontSize,
              fontWeight: widget.isSelected || !widget.isFilter
                  ? FontWeight.w700
                  : FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );

    if (!isInteractive) {
      return chipContent;
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: () {
          HapticFeedback.selectionClick();
          if (widget.onSelected != null) {
            widget.onSelected!(!widget.isSelected);
          } else if (widget.onTap != null) {
            widget.onTap!();
          }
        },
        child: chipContent,
      ),
    );
  }
}
