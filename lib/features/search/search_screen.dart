import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/motion.dart';
import '../../models/event_model.dart';
import 'search_controller.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final query = ref.read(searchControllerProvider).query;
    _searchController.text = query;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _openFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: AppMotion.durationMedium4,
      ),
      builder: (ctx) => const _SearchFilterModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchControllerProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasQuery = searchState.query.trim().isNotEmpty;
    final results = searchState.filteredResults;
    final filterCount = searchState.filters.activeFiltersCount;

    return PopScope(
      canPop: !hasQuery && searchState.filters.isDefault,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _searchController.clear();
          ref.read(searchControllerProvider.notifier).clearQuery();
          ref.read(searchControllerProvider.notifier).clearAllFilters();
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: Column(
            children: [
              // Top App Bar & Search Input
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.arrowLeft, size: 20),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/feed');
                        }
                      },
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            Icon(
                              LucideIcons.search,
                              color: colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                textInputAction: TextInputAction.search,
                                onChanged: (val) {
                                  ref
                                      .read(searchControllerProvider.notifier)
                                      .onQueryChanged(val);
                                },
                                decoration: InputDecoration(
                                  hintText:
                                      'Search events, clubs, keywords...',
                                  hintStyle: TextStyle(
                                    color: colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.7),
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  filled: false,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            if (_searchController.text.isNotEmpty) ...[
                              IconButton(
                                icon: const Icon(LucideIcons.x, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  ref
                                      .read(searchControllerProvider.notifier)
                                      .clearQuery();
                                },
                              ),
                            ],
                            IconButton(
                              icon: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Icon(LucideIcons.slidersHorizontal,
                                      size: 20,
                                      color: colorScheme.primary),
                                  if (filterCount > 0)
                                    Positioned(
                                      top: -4,
                                      right: -4,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: colorScheme.tertiaryContainer,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '$filterCount',
                                          style: TextStyle(
                                            color: colorScheme
                                                .onTertiaryContainer,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              onPressed: () => _openFilterModal(context),
                            ),
                            const SizedBox(width: 6),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Horizontal active filter chips bar (if any active)
              if (!searchState.filters.isDefault) ...[
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    children: [
                      ActionChip(
                        avatar: const Icon(LucideIcons.x, size: 14),
                        label: const Text('Clear all filters'),
                        onPressed: () => ref
                            .read(searchControllerProvider.notifier)
                            .clearAllFilters(),
                        backgroundColor: colorScheme.surfaceContainerHigh,
                      ),
                      const SizedBox(width: 8),
                      ...searchState.filters.categories.map(
                        (cat) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Chip(
                            label: Text(cat),
                            deleteIcon: const Icon(LucideIcons.x, size: 14),
                            onDeleted: () => ref
                                .read(searchControllerProvider.notifier)
                                .toggleCategory(cat),
                            backgroundColor: colorScheme.primaryContainer
                                .withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      if (searchState.filters.format != 'All')
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Chip(
                            label: Text('Format: ${searchState.filters.format}'),
                            deleteIcon: const Icon(LucideIcons.x, size: 14),
                            onDeleted: () => ref
                                .read(searchControllerProvider.notifier)
                                .setFormat('All'),
                            backgroundColor: colorScheme.secondaryContainer
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      if (searchState.filters.deadline != 'All')
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Chip(
                            label: Text(
                                'Deadline: ${searchState.filters.deadline}'),
                            deleteIcon: const Icon(LucideIcons.x, size: 14),
                            onDeleted: () => ref
                                .read(searchControllerProvider.notifier)
                                .setDeadline('All'),
                            backgroundColor: colorScheme.tertiaryContainer
                                .withValues(alpha: 0.5),
                          ),
                        ),
                    ],
                  ),
                ),
              ],

              const Divider(height: 1),

              // Main Results or Recent Searches
              Expanded(
                child: hasQuery || !searchState.filters.isDefault
                    ? _buildSearchResults(results, searchState.query, theme)
                    : _buildRecentSearches(searchState, theme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(
      List<EventModel> results, String query, ThemeData theme) {
    final colorScheme = theme.colorScheme;

    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.searchX,
                  size: 32,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No matching events found',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your search terms or clearing active filters.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.tonal(
                onPressed: () {
                  _searchController.clear();
                  ref.read(searchControllerProvider.notifier).clearQuery();
                  ref.read(searchControllerProvider.notifier).clearAllFilters();
                },
                child: const Text('Reset Search'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final event = results[index];
        return _buildEventResultCard(event, query, theme);
      },
    );
  }

  Widget _buildEventResultCard(
      EventModel event, String query, ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            ref
                .read(searchControllerProvider.notifier)
                .addRecentSearch(event.title);
            context.push('/event/${event.id}');
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category & Deadline / Format badges row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        event.category.toUpperCase(),
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (event.deadlineAt != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: event.isDeadlineSoon
                              ? colorScheme.errorContainer
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.clock,
                              size: 13,
                              color: event.isDeadlineSoon
                                  ? colorScheme.onErrorContainer
                                  : colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              event.deadlineLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: event.isDeadlineSoon
                                    ? colorScheme.onErrorContainer
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),

                // Title with highlight
                _buildHighlightedText(
                  text: event.title,
                  query: query,
                  style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ) ??
                      const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                  highlightStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    backgroundColor: colorScheme.primaryContainer,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 6),

                // Organizer & Venue Info
                Row(
                  children: [
                    Icon(
                      LucideIcons.users,
                      size: 15,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        event.organizerName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      LucideIcons.mapPin,
                      size: 15,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      event.venue != null && event.venue!.isNotEmpty
                          ? event.venue!
                          : event.formattedFormat,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    if (event.matchScore != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer
                              .withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${(event.matchScore! * 100).toInt()}% Match',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSearches(SearchState searchState, ThemeData theme) {
    final colorScheme = theme.colorScheme;

    if (searchState.recentSearches.isEmpty) {
      return Center(
        child: Text(
          'Type in the search bar above to find events',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Searches',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: () {
                ref
                    .read(searchControllerProvider.notifier)
                    .clearRecentSearches();
              },
              child: const Text('Clear'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...searchState.recentSearches.map((item) {
          return ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            leading: Icon(
              LucideIcons.history,
              color: colorScheme.onSurfaceVariant,
              size: 18,
            ),
            title: Text(
              item,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Icon(
              LucideIcons.arrowUpLeft,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onTap: () {
              _searchController.text = item;
              ref
                  .read(searchControllerProvider.notifier)
                  .onQueryChanged(item);
            },
          );
        }),
      ],
    );
  }

  Widget _buildHighlightedText({
    required String text,
    required String query,
    required TextStyle style,
    required TextStyle highlightStyle,
  }) {
    if (query.trim().isEmpty) {
      return Text(text, style: style);
    }

    final queryLower = query.toLowerCase().trim();
    final textLower = text.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;

    while (start < text.length) {
      final index = textLower.indexOf(queryLower, start);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(start), style: style));
        break;
      }
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index), style: style));
      }
      spans.add(TextSpan(
        text: text.substring(index, index + queryLower.length),
        style: highlightStyle,
      ));
      start = index + queryLower.length;
    }

    return RichText(text: TextSpan(children: spans));
  }
}

class _SearchFilterModal extends ConsumerWidget {
  const _SearchFilterModal();

  final List<String> _categories = const [
    'Hackathons',
    'Internships',
    'Networking',
    'Workshops',
    'Social',
    'Cultural Fests',
    'Case Competitions',
    'Seminars',
  ];

  final List<String> _formats = const [
    'All',
    'In-Person',
    'Virtual',
    'Hybrid',
  ];

  final List<String> _deadlines = const [
    'All',
    'Today',
    'This Week',
    'Next 30 Days',
  ];

  final List<String> _eligibilityGroups = const [
    'Freshmen',
    'Sophomores',
    'Juniors',
    'Seniors',
    'Graduate',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchControllerProvider);
    final searchCtrl = ref.read(searchControllerProvider.notifier);
    final filters = searchState.filters;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    searchCtrl.clearAllFilters();
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
          ),
          const Divider(),

          // Filter Sections Scrollable
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category
                  _buildSectionTitle('Category', context),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((cat) {
                      final isSelected = filters.categories.contains(cat);
                      return FilterChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (_) => searchCtrl.toggleCategory(cat),
                        selectedColor: colorScheme.primaryContainer,
                        backgroundColor: colorScheme.surfaceContainer,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 13,
                        ),
                        showCheckmark: false,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Deadline
                  _buildSectionTitle('Deadline', context),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _deadlines.map((d) {
                      final isSelected = filters.deadline == d;
                      return ChoiceChip(
                        label: Text(d),
                        selected: isSelected,
                        onSelected: (_) => searchCtrl.setDeadline(d),
                        selectedColor: colorScheme.primaryContainer,
                        backgroundColor: colorScheme.surfaceContainer,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Format
                  _buildSectionTitle('Format', context),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _formats.map((fmt) {
                      final isSelected = filters.format == fmt;
                      return ChoiceChip(
                        label: Text(fmt),
                        selected: isSelected,
                        onSelected: (_) => searchCtrl.setFormat(fmt),
                        selectedColor: colorScheme.primaryContainer,
                        backgroundColor: colorScheme.surfaceContainer,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Eligibility
                  _buildSectionTitle('Eligibility', context),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _eligibilityGroups.map((el) {
                      final isSelected = filters.eligibility.contains(el);
                      return FilterChip(
                        label: Text(el),
                        selected: isSelected,
                        onSelected: (_) => searchCtrl.toggleEligibility(el),
                        selectedColor: colorScheme.primaryContainer,
                        backgroundColor: colorScheme.surfaceContainer,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        showCheckmark: false,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Bottom Action Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: () {
                      searchCtrl.clearAllFilters();
                      Navigator.pop(context);
                    },
                    child: const Text('Clear All'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                        'Show Results (${searchState.filteredResults.length})'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurfaceVariant,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
