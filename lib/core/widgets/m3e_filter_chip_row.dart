import 'package:flutter/material.dart';
import '../theme/motion.dart';
import 'interactive_spring.dart';

class FilterCategoryItem {
  final String key;
  final String label;
  final IconData? icon;

  const FilterCategoryItem({
    required this.key,
    required this.label,
    this.icon,
  });
}

/// Sticky/Horizontal filter chips row with physics-based spring selection animation.
class M3EFilterChipRow extends StatelessWidget {
  final List<FilterCategoryItem> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const M3EFilterChipRow({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      color: colorScheme.surface.withValues(alpha: 0.95),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: categories.map((item) {
            final isSelected =
                item.key.toLowerCase() == selectedCategory.toLowerCase();
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InteractiveSpring(
                onTap: () => onCategorySelected(item.key),
                pressedScale: 0.94,
                child: AnimatedContainer(
                  duration: AppMotion.durationShort3,
                  curve: AppMotion.emphasizedDecelerate,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primaryContainer
                          : colorScheme.outlineVariant.withValues(alpha: 0.6),
                      width: 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (item.icon != null) ...[
                        Icon(
                          item.icon,
                          size: 16,
                          color: isSelected
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        item.label,
                        style: textTheme.labelMedium?.copyWith(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
