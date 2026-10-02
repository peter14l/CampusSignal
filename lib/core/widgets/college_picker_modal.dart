import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../constants/app_constants.dart';
import '../../models/college_model.dart';

/// Material 3 Expressive Searchable College / University Picker Modal Sheet
class CollegePickerModal extends StatefulWidget {
  final CollegeModel? initialSelectedCollege;
  final ValueChanged<CollegeModel> onCollegeSelected;

  const CollegePickerModal({
    super.key,
    this.initialSelectedCollege,
    required this.onCollegeSelected,
  });

  static Future<CollegeModel?> show(
    BuildContext context, {
    CollegeModel? initialSelectedCollege,
    required ValueChanged<CollegeModel> onCollegeSelected,
  }) {
    return showModalBottomSheet<CollegeModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CollegePickerModal(
        initialSelectedCollege: initialSelectedCollege,
        onCollegeSelected: onCollegeSelected,
      ),
    );
  }

  @override
  State<CollegePickerModal> createState() => _CollegePickerModalState();
}

class _CollegePickerModalState extends State<CollegePickerModal> {
  final TextEditingController _searchController = TextEditingController();
  late List<CollegeModel> _filteredColleges;
  CollegeModel? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelectedCollege ?? AppConstants.indianColleges.first;
    _filteredColleges = List.from(AppConstants.indianColleges);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredColleges = List.from(AppConstants.indianColleges);
      } else {
        _filteredColleges = AppConstants.indianColleges.where((c) {
          return c.name.toLowerCase().contains(query) ||
              c.shortCode.toLowerCase().contains(query) ||
              c.city.toLowerCase().contains(query) ||
              c.state.toLowerCase().contains(query) ||
              c.domainPatterns.any((d) => d.toLowerCase().contains(query));
        }).toList();
      }
    });
  }

  void _handleSelect(CollegeModel college) {
    HapticFeedback.selectionClick();
    setState(() => _selected = college);
    widget.onCollegeSelected(college);
    Navigator.of(context).pop(college);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        LucideIcons.school,
                        color: colorScheme.onPrimaryContainer,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Your Institution',
                          style: textTheme.titleMedium?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Connect to your campus signal network',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              autofocus: false,
              decoration: InputDecoration(
                hintText: 'Search by college name, code, or city...',
                prefixIcon: Icon(LucideIcons.search, size: 18, color: colorScheme.primary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, size: 16),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: colorScheme.surfaceContainerHigh,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Quick Selection Chips for Popular Universities
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: AppConstants.indianColleges.take(6).length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final college = AppConstants.indianColleges[index];
                  final isSelected = _selected?.id == college.id;
                  return ChoiceChip(
                    label: Text(college.shortCode),
                    selected: isSelected,
                    onSelected: (_) => _handleSelect(college),
                    selectedColor: colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Divider(height: 16, color: colorScheme.outlineVariant.withValues(alpha: 0.4)),

          // College Directory List
          Flexible(
            child: _filteredColleges.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.searchX, size: 40, color: colorScheme.outline),
                          const SizedBox(height: 10),
                          Text(
                            'No colleges found matching "${_searchController.text.trim()}"',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredColleges.length,
                    itemBuilder: (context, index) {
                      final college = _filteredColleges[index];
                      final isSelected = _selected?.id == college.id;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorScheme.primaryContainer.withValues(alpha: 0.35)
                              : colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.outlineVariant.withValues(alpha: 0.3),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          onTap: () => _handleSelect(college),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              college.shortCode.substring(0, college.shortCode.length.clamp(1, 3)),
                              style: TextStyle(
                                color: isSelected
                                    ? colorScheme.onPrimary
                                    : colorScheme.primary,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          title: Text(
                            college.name,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          subtitle: Row(
                            children: [
                              Icon(LucideIcons.mapPin, size: 12, color: colorScheme.outline),
                              const SizedBox(width: 4),
                              Text(
                                '${college.city}, ${college.state}',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                          trailing: isSelected
                              ? Icon(LucideIcons.checkCircle2, color: colorScheme.primary, size: 20)
                              : Icon(LucideIcons.chevronRight, size: 18, color: colorScheme.outline),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
