import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../constants/app_constants.dart';
import '../theme/motion.dart';
import 'interactive_spring.dart';

/// Premium, UX-first Department / Programme Selection Modal Sheet.
/// Features:
/// - Real-time instant search filter across all 28 SXUK programmes
/// - Visual Degree Level tabs (All / UG / PG / Ph.D.)
/// - Categorized faculty cards with clean hierarchy
/// - Smooth spring taps, haptics, and highlighted selection indicator
class DepartmentPickerSheet extends StatefulWidget {
  final String? initialSelection;
  final bool includeAllCampusOption;
  final ValueChanged<String> onSelected;

  const DepartmentPickerSheet({
    super.key,
    this.initialSelection,
    this.includeAllCampusOption = false,
    required this.onSelected,
  });

  static Future<void> show(
    BuildContext context, {
    String? currentSelection,
    bool includeAllCampus = false,
    required ValueChanged<String> onSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DepartmentPickerSheet(
        initialSelection: currentSelection,
        includeAllCampusOption: includeAllCampus,
        onSelected: onSelected,
      ),
    );
  }

  @override
  State<DepartmentPickerSheet> createState() => _DepartmentPickerSheetState();
}

class _DepartmentPickerSheetState extends State<DepartmentPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedLevel = 'All'; // 'All', 'Undergraduate (UG)', 'Postgraduate (PG)', 'Doctoral (Ph.D.)'

  final List<String> _levelFilters = [
    'All',
    'Undergraduate (UG)',
    'Postgraduate (PG)',
    'Doctoral (Ph.D.)',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _getFacultyIcon(String faculty) {
    if (faculty.contains('Engineering') || faculty.contains('Science')) {
      return LucideIcons.cpu;
    } else if (faculty.contains('Commerce') || faculty.contains('Management')) {
      return LucideIcons.trendingUp;
    } else if (faculty.contains('Arts') || faculty.contains('Social')) {
      return LucideIcons.bookOpen;
    } else if (faculty.contains('Law')) {
      return LucideIcons.scale;
    }
    return LucideIcons.graduationCap;
  }

  Color _getLevelColor(String level, ColorScheme colorScheme) {
    if (level.contains('Undergraduate')) {
      return colorScheme.primary;
    } else if (level.contains('Postgraduate')) {
      return colorScheme.secondary;
    } else {
      return colorScheme.tertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 30,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Pill Drag Indicator
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
            ),

            // Modal Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 12, 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      LucideIcons.graduationCap,
                      color: colorScheme.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Programme',
                          style: textTheme.titleMedium?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                        Text(
                          'St. Xavier\'s University, Kolkata',
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.surfaceContainerHigh,
                      foregroundColor: colorScheme.onSurfaceVariant,
                      padding: const EdgeInsets.all(8),
                    ),
                    icon: const Icon(LucideIcons.x, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Modern Search Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search department (e.g. CSE, Economics, M.Com)',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: Icon(
                      LucideIcons.search,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(LucideIcons.x, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Quick Category Filter Chips (Horizontal Scroll)
            if (_searchQuery.isEmpty)
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _levelFilters.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, idx) {
                    final filter = _levelFilters[idx];
                    final isSelected = _selectedLevel == filter;
                    final shortLabel = filter == 'All'
                        ? 'All'
                        : filter.split(' ').last.replaceAll('(', '').replaceAll(')', '');

                    return FilterChip(
                      label: Text(
                        filter == 'All' ? 'All (28)' : '$shortLabel (${_getCountForLevel(filter)})',
                      ),
                      selected: isSelected,
                      onSelected: (_) {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedLevel = filter);
                      },
                      showCheckmark: false,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                      ),
                      selectedColor: colorScheme.primary,
                      backgroundColor: colorScheme.surfaceContainerLow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.outlineVariant.withValues(alpha: 0.4),
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 10),
            Divider(
              height: 1,
              color: colorScheme.outlineVariant.withValues(alpha: 0.35),
            ),

            // Programme List View
            Expanded(
              child: _buildProgrammeList(context, colorScheme, textTheme),
            ),
          ],
        ),
      ),
    );
  }

  int _getCountForLevel(String level) {
    if (level.contains('Undergraduate')) return 11;
    if (level.contains('Postgraduate')) return 9;
    if (level.contains('Doctoral')) return 8;
    return 28;
  }

  Widget _buildProgrammeList(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final filteredCategories = <String, Map<String, List<String>>>{};

    for (final levelEntry in AppConstants.categorizedProgrammes.entries) {
      final levelTitle = levelEntry.key;
      if (_searchQuery.isEmpty && _selectedLevel != 'All' && _selectedLevel != levelTitle) {
        continue;
      }

      final facultyMap = <String, List<String>>{};
      for (final facultyEntry in levelEntry.value.entries) {
        final facultyName = facultyEntry.key;
        final programmes = facultyEntry.value.where((p) {
          if (_searchQuery.isEmpty) return true;
          return p.toLowerCase().contains(_searchQuery) ||
              facultyName.toLowerCase().contains(_searchQuery) ||
              levelTitle.toLowerCase().contains(_searchQuery);
        }).toList();

        if (programmes.isNotEmpty) {
          facultyMap[facultyName] = programmes;
        }
      }

      if (facultyMap.isNotEmpty) {
        filteredCategories[levelTitle] = facultyMap;
      }
    }

    if (filteredCategories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.searchX, size: 48, color: colorScheme.outline),
              const SizedBox(height: 12),
              Text(
                'No programmes found',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Try searching with abbreviations like "CSE", "B.Com", or "M.A."',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      children: [
        // "All Campus" option if enabled
        if (widget.includeAllCampusOption && _searchQuery.isEmpty) ...[
          _buildCampusWideOption(colorScheme, textTheme),
          const SizedBox(height: 16),
        ],

        ...filteredCategories.entries.map((levelEntry) {
          final levelTitle = levelEntry.key;
          final facultyMap = levelEntry.value;
          final levelColor = _getLevelColor(levelTitle, colorScheme);

          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Level Badge Header
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: levelColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      levelTitle.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: levelColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Faculty Container Cards
                ...facultyMap.entries.map((facultyEntry) {
                  final facultyName = facultyEntry.key;
                  final programmes = facultyEntry.value;
                  final facultyIcon = _getFacultyIcon(facultyName);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Faculty Header
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
                          child: Row(
                            children: [
                              Icon(
                                facultyIcon,
                                size: 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  facultyName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),

                        // Programmes list
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: programmes.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            indent: 14,
                            endIndent: 14,
                            color: colorScheme.outlineVariant.withValues(alpha: 0.15),
                          ),
                          itemBuilder: (context, pIdx) {
                            final programme = programmes[pIdx];
                            final isSelected = widget.initialSelection == programme;

                            return InteractiveSpring(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                widget.onSelected(programme);
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                color: isSelected
                                    ? colorScheme.primaryContainer.withValues(alpha: 0.5)
                                    : Colors.transparent,
                                child: Row(
                                  children: [
                                    AnimatedContainer(
                                      duration: AppMotion.durationShort3,
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected
                                            ? colorScheme.primary
                                            : colorScheme.surfaceContainerHigh,
                                        border: Border.all(
                                          color: isSelected
                                              ? colorScheme.primary
                                              : colorScheme.outlineVariant,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: isSelected
                                          ? Icon(
                                              LucideIcons.check,
                                              size: 13,
                                              color: colorScheme.onPrimary,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        programme,
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                          color: isSelected
                                              ? colorScheme.onPrimaryContainer
                                              : colorScheme.onSurface,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: colorScheme.primary,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'Selected',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: colorScheme.onPrimary,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCampusWideOption(ColorScheme colorScheme, TextTheme textTheme) {
    final isSelected = widget.initialSelection == 'all' || widget.initialSelection == null;

    return InteractiveSpring(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onSelected('all');
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer.withValues(alpha: 0.6)
              : colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outlineVariant.withValues(alpha: 0.4),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                LucideIcons.globe,
                size: 18,
                color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'All Campus & University-Wide',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'View opportunities across all SXUK disciplines',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(LucideIcons.circleCheck, size: 20, color: colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
