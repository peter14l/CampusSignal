import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/events_repository.dart';
import '../../models/event_model.dart';
import '../auth/auth_controller.dart';

class SearchFilterState {
  final List<String> categories;
  final String format; // 'All', 'In-Person', 'Virtual', 'Hybrid'
  final String deadline; // 'All', 'Today', 'This Week', 'Next 30 Days'
  final List<String> eligibility; // 'Freshmen', 'Sophomores', 'Juniors', 'Seniors', 'Graduate'

  const SearchFilterState({
    this.categories = const [],
    this.format = 'All',
    this.deadline = 'All',
    this.eligibility = const [],
  });

  bool get isDefault =>
      categories.isEmpty &&
      format == 'All' &&
      deadline == 'All' &&
      eligibility.isEmpty;

  int get activeFiltersCount {
    int count = categories.length;
    if (format != 'All') count++;
    if (deadline != 'All') count++;
    count += eligibility.length;
    return count;
  }

  SearchFilterState copyWith({
    List<String>? categories,
    String? format,
    String? deadline,
    List<String>? eligibility,
  }) {
    return SearchFilterState(
      categories: categories ?? this.categories,
      format: format ?? this.format,
      deadline: deadline ?? this.deadline,
      eligibility: eligibility ?? this.eligibility,
    );
  }
}

class SearchState {
  final String query;
  final bool isSearching;
  final List<EventModel> allEvents;
  final List<EventModel> filteredResults;
  final List<String> recentSearches;
  final SearchFilterState filters;

  const SearchState({
    this.query = '',
    this.isSearching = false,
    this.allEvents = const [],
    this.filteredResults = const [],
    this.recentSearches = const [
      'UX Design Internship',
      'Google Developer Student Club',
      'Resume Workshop',
      'Hackathon 2026',
    ],
    this.filters = const SearchFilterState(),
  });

  SearchState copyWith({
    String? query,
    bool? isSearching,
    List<EventModel>? allEvents,
    List<EventModel>? filteredResults,
    List<String>? recentSearches,
    SearchFilterState? filters,
  }) {
    return SearchState(
      query: query ?? this.query,
      isSearching: isSearching ?? this.isSearching,
      allEvents: allEvents ?? this.allEvents,
      filteredResults: filteredResults ?? this.filteredResults,
      recentSearches: recentSearches ?? this.recentSearches,
      filters: filters ?? this.filters,
    );
  }
}

class SearchControllerNotifier extends Notifier<SearchState> {
  Timer? _debounceTimer;

  @override
  SearchState build() {
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });

    Future.microtask(() => _loadEvents());

    final isDemoMode = ref.watch(authControllerProvider.select((s) => s.isDemoMode));
    return SearchState(
      recentSearches: isDemoMode
          ? const [
              'UX Design Internship',
              'Google Developer Student Club',
              'Resume Workshop',
              'Hackathon 2026',
            ]
          : const [],
    );
  }

  Future<void> _loadEvents() async {
    final repository = ref.read(eventsRepositoryProvider);
    final events = await repository.getFeedEvents();
    state = state.copyWith(
      allEvents: events,
      filteredResults: events,
    );
  }

  void onQueryChanged(String query) {
    _debounceTimer?.cancel();
    state = state.copyWith(query: query, isSearching: true);

    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      _applyFilters();
    });
  }

  void clearQuery() {
    _debounceTimer?.cancel();
    state = state.copyWith(query: '', isSearching: false);
    _applyFilters();
  }

  void toggleCategory(String category) {
    final list = List<String>.from(state.filters.categories);
    if (list.contains(category)) {
      list.remove(category);
    } else {
      list.add(category);
    }
    state = state.copyWith(filters: state.filters.copyWith(categories: list));
    _applyFilters();
  }

  void setFormat(String format) {
    state = state.copyWith(filters: state.filters.copyWith(format: format));
    _applyFilters();
  }

  void setDeadline(String deadline) {
    state = state.copyWith(filters: state.filters.copyWith(deadline: deadline));
    _applyFilters();
  }

  void toggleEligibility(String yearGroup) {
    final list = List<String>.from(state.filters.eligibility);
    if (list.contains(yearGroup)) {
      list.remove(yearGroup);
    } else {
      list.add(yearGroup);
    }
    state = state.copyWith(filters: state.filters.copyWith(eligibility: list));
    _applyFilters();
  }

  void clearAllFilters() {
    state = state.copyWith(filters: const SearchFilterState());
    _applyFilters();
  }

  void addRecentSearch(String search) {
    final trimmed = search.trim();
    if (trimmed.isEmpty) return;
    final list = List<String>.from(state.recentSearches);
    list.remove(trimmed);
    list.insert(0, trimmed);
    if (list.length > 8) {
      list.removeLast();
    }
    state = state.copyWith(recentSearches: list);
  }

  void clearRecentSearches() {
    state = state.copyWith(recentSearches: const []);
  }

  void addNewEvent(EventModel event) {
    final updatedAll = [event, ...state.allEvents];
    state = state.copyWith(allEvents: updatedAll);
    _applyFilters();
  }

  void _applyFilters() {
    final query = state.query.toLowerCase().trim();
    final filters = state.filters;
    final now = DateTime.now();

    final results = state.allEvents.where((event) {
      if (query.isNotEmpty) {
        final inTitle = event.title.toLowerCase().contains(query);
        final inDesc = event.description.toLowerCase().contains(query);
        final inOrg = event.organizerName.toLowerCase().contains(query);
        final inCategory = event.category.toLowerCase().contains(query);
        final inTags = event.matchedTags.any((t) => t.toLowerCase().contains(query));

        if (!inTitle && !inDesc && !inOrg && !inCategory && !inTags) {
          return false;
        }
      }

      if (filters.categories.isNotEmpty) {
        if (!filters.categories.contains(event.category)) {
          return false;
        }
      }

      if (filters.format != 'All') {
        if (event.formattedFormat.toLowerCase() != filters.format.toLowerCase()) {
          return false;
        }
      }

      if (filters.deadline != 'All' && event.deadlineAt != null) {
        final diff = event.deadlineAt!.difference(now);
        if (filters.deadline == 'Today' && (diff.inHours > 24 || diff.isNegative)) {
          return false;
        }
        if (filters.deadline == 'This Week' && (diff.inDays > 7 || diff.isNegative)) {
          return false;
        }
        if (filters.deadline == 'Next 30 Days' && (diff.inDays > 30 || diff.isNegative)) {
          return false;
        }
      }

      return true;
    }).toList();

    state = state.copyWith(
      filteredResults: results,
      isSearching: false,
    );
  }
}

final searchControllerProvider =
    NotifierProvider<SearchControllerNotifier, SearchState>(
        SearchControllerNotifier.new);
