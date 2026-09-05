import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/widgets/app_logo_badge.dart';
import '../../core/widgets/category_chip.dart';
import '../../core/widgets/department_picker_modal.dart';
import '../../core/widgets/m3e_event_card.dart';
import '../../core/widgets/m3e_speed_dial_fab.dart';
import '../../core/widgets/micro_animated_icon.dart';
import '../auth/auth_controller.dart';
import '../notifications/notifications_controller.dart';
import '../saved/saved_controller.dart';
import '../updater/startup_update_dialog.dart';
import '../updater/update_controller.dart';
import 'feed_controller.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  String _selectedCategory = 'all';

  static const List<String> _categories = [
    'all',
    'hackathon',
    'internship',
    'workshop',
    'fest',
    'seminar',
    'club',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkStartupUpdate();
    });
  }

  Future<void> _checkStartupUpdate() async {
    final updateState = ref.read(updateControllerProvider);
    if (updateState.isPopupDismissed) return;

    final result = await ref.read(updateControllerProvider.notifier).checkForUpdates(isSilent: true);
    if (result.hasUpdate && result.updateInfo != null && mounted) {
      StartupUpdateDialog.show(
        context,
        update: result.updateInfo!,
        isMandatory: result.isMandatory,
      );
    }
  }

  String _selectedDepartment = 'all';

  static const List<String> _quickFilterDepts = [
    'all',
    'B.Tech in CSE',
    'B.Tech in AI & ML',
    'B.Sc. (Honours) in Statistics and Data Science',
    'B.Com. (Honours)',
    'B.M.S. (Honours)',
    'M.Sc. Computer Science',
    'LLM. Law',
  ];

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(authControllerProvider.select((s) => s.profile));
    final feedState = ref.watch(feedControllerProvider);
    final unreadNotifs = ref.watch(notificationsControllerProvider.select((s) => s.unreadCount));
    final savedState = ref.watch(savedControllerProvider);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final allEvents = feedState.events;
    final userBranch = profile?.branch;
    final filteredEvents = allEvents.where((e) {
      if (_selectedCategory != 'all' &&
          !e.category.toLowerCase().contains(_selectedCategory.toLowerCase())) {
        return false;
      }
      if (_selectedDepartment != 'all') {
        return e.isTargetedForBranch(_selectedDepartment);
      }
      return e.isTargetedForBranch(userBranch);
    }).toList();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Row(
          children: [
            const AppLogoBadge(
              size: 32,
              borderRadius: 9,
              hasShadow: false,
            ),
            const SizedBox(width: 10),
            Text(
              'CampusSignal',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.primary,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: [
          MicroAnimatedIconButton.circle(
            size: 38,
            iconSize: 19,
            iconData: LucideIcons.search,
            color: colorScheme.onSurfaceVariant,
            backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            onPressed: () => context.push('/search'),
            tooltip: 'Search Opportunities',
          ),
          const SizedBox(width: 6),
          Stack(
            clipBehavior: Clip.none,
            children: [
              MicroAnimatedIconButton.circle(
                size: 38,
                iconSize: 19,
                iconData: LucideIcons.bell,
                color: colorScheme.onSurfaceVariant,
                backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                onPressed: () => context.push('/notifications'),
                tooltip: 'Notifications',
              ),
              if (unreadNotifs > 0)
                Positioned(
                  right: 2,
                  top: 2,
                  child: IgnorePointer(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.error,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.error.withValues(alpha: 0.3),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        unreadNotifs > 9 ? '9+' : '$unreadNotifs',
                        style: TextStyle(
                          color: colorScheme.onError,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: colorScheme.primary,
        backgroundColor: colorScheme.surfaceContainerLowest,
        onRefresh: () async {
          await ref.read(feedControllerProvider.notifier).loadFeed(isRefresh: true);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // Greeting & Personalized Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, colorScheme.primaryContainer],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.onPrimary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(LucideIcons.sparkles,
                                    color: colorScheme.onPrimary, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '${profile?.departmentLabel ?? "Computer Science"} • ${profile?.semesterLabel ?? "Semester 3"}',
                                  style: TextStyle(
                                    color: colorScheme.onPrimary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Welcome back, ${profile?.fullName.split(" ").first ?? "Student"}! 👋',
                        style: textTheme.headlineSmall?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Here are high-priority campus opportunities tailored to your interests.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimary.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Horizontal Categories Filter Row
            SliverToBoxAdapter(
              child: SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, idx) {
                    final cat = _categories[idx];
                    final isSelected = _selectedCategory == cat;
                    return CategoryChip(
                      category: cat,
                      isFilter: true,
                      isSelected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      },
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // Department & Branch Filter Row with categorized bottom sheet
            SliverToBoxAdapter(
              child: SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _quickFilterDepts.length + 1,
                  separatorBuilder: (context, index) => const SizedBox(width: 6),
                  itemBuilder: (context, idx) {
                    if (idx == _quickFilterDepts.length) {
                      final isCustomSelected = !_quickFilterDepts.contains(_selectedDepartment) && _selectedDepartment != 'all';
                      return ActionChip(
                        label: Text(isCustomSelected ? _selectedDepartment : 'More Courses...'),
                        avatar: Icon(
                          isCustomSelected ? LucideIcons.circleCheck : LucideIcons.layers,
                          size: 13,
                          color: isCustomSelected ? colorScheme.onPrimaryContainer : colorScheme.primary,
                        ),
                        backgroundColor: isCustomSelected ? colorScheme.primaryContainer : colorScheme.surfaceContainer,
                        side: BorderSide(
                          color: isCustomSelected ? colorScheme.primary : colorScheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: isCustomSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isCustomSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                        ),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          _showDepartmentFilterSheet(context);
                        },
                      );
                    }

                    final dept = _quickFilterDepts[idx];
                    final isSelected = _selectedDepartment == dept;
                    final label = dept == 'all' ? 'All Campus' : dept;
                    return FilterChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (_) {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedDepartment = dept;
                        });
                      },
                      avatar: Icon(
                        dept == 'all' ? LucideIcons.globe : LucideIcons.school,
                        size: 13,
                        color: isSelected
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurfaceVariant,
                      ),
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      selectedColor: colorScheme.primaryContainer,
                      labelStyle: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurface,
                      ),
                    );
                  },
                ),
              ),
            ),

            // For You Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          _selectedDepartment == 'all'
                              ? 'Top Signals For You'
                              : '${_selectedDepartment.split(" (").first} Signals',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        if (_selectedDepartment != 'all') ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Targeted',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    TextButton(
                      onPressed: () => context.push('/search'),
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),
            ),

            // Virtualized Event Cards
            if (filteredEvents.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      'No events found in this category.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                sliver: SliverList.builder(
                  itemCount: filteredEvents.length,
                  itemBuilder: (context, index) {
                    final event = filteredEvents[index];
                    final isSaved = savedState.savedEvents.any((s) => s.id == event.id);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: M3EEventCard(
                        event: event,
                        isSaved: isSaved,
                        onTap: () => context.push('/event/${event.id}'),
                        onBookmarkTap: () {
                          ref.read(feedControllerProvider.notifier).toggleSave(event.id);
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: const M3ESpeedDialFab(),
    );
  }

  void _showDepartmentFilterSheet(BuildContext context) {
    DepartmentPickerSheet.show(
      context,
      currentSelection: _selectedDepartment,
      includeAllCampus: true,
      onSelected: (programme) {
        setState(() => _selectedDepartment = programme);
      },
    );
  }
}
