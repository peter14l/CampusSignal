import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/events_repository.dart';
import '../../models/event_model.dart';
import '../auth/auth_controller.dart';
import '../profile/profile_controller.dart';

class FeedState {
  final String selectedCategory;
  final String selectedDepartment; // 'all' or specific department
  final List<EventModel> events;
  final bool isLoading;
  final bool isRefreshing;
  final String? errorMessage;
  final Set<String> savedEventIds;

  const FeedState({
    this.selectedCategory = 'for_you',
    this.selectedDepartment = 'all',
    this.events = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.errorMessage,
    this.savedEventIds = const {},
  });

  FeedState copyWith({
    String? selectedCategory,
    String? selectedDepartment,
    List<EventModel>? events,
    bool? isLoading,
    bool? isRefreshing,
    String? errorMessage,
    Set<String>? savedEventIds,
  }) {
    return FeedState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedDepartment: selectedDepartment ?? this.selectedDepartment,
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage,
      savedEventIds: savedEventIds ?? this.savedEventIds,
    );
  }
}

class FeedController extends Notifier<FeedState> {
  @override
  FeedState build() {
    Future.microtask(() => loadFeed());
    return const FeedState();
  }

  EventsRepository get _repository => ref.read(eventsRepositoryProvider);

  Future<void> loadFeed({bool isRefresh = false}) async {
    if (isRefresh) {
      state = state.copyWith(isRefreshing: true, errorMessage: null);
    } else {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }

    try {
      final userBranch = ref.read(authControllerProvider).profile?.branch ??
          ref.read(profileControllerProvider).profile?.branch;
      final events = await _repository.getFeedEvents(
        category: state.selectedCategory,
        userBranch: userBranch,
        targetDepartment: state.selectedDepartment != 'all' ? state.selectedDepartment : null,
      );
      final savedEvents = await _repository.getSavedEvents();
      final savedIds = savedEvents.map((e) => e.id).toSet();

      state = state.copyWith(
        events: events,
        savedEventIds: savedIds,
        isLoading: false,
        isRefreshing: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        errorMessage: 'Failed to load events: ${e.toString()}',
      );
    }
  }

  Future<void> selectCategory(String category) async {
    if (state.selectedCategory == category) return;
    state = state.copyWith(selectedCategory: category, isLoading: true);
    await loadFeed();
  }

  Future<void> selectDepartment(String department) async {
    if (state.selectedDepartment == department) return;
    state = state.copyWith(selectedDepartment: department, isLoading: true);
    await loadFeed();
  }

  void addCreatedEvent(EventModel event) {
    final updatedList = [event, ...state.events];
    state = state.copyWith(events: updatedList);
  }

  Future<void> toggleSave(String eventId) async {
    final currentlySaved = state.savedEventIds.contains(eventId);
    final newSavedIds = Set<String>.from(state.savedEventIds);
    if (currentlySaved) {
      newSavedIds.remove(eventId);
    } else {
      newSavedIds.add(eventId);
    }

    state = state.copyWith(savedEventIds: newSavedIds);
    await _repository.toggleSave(eventId);
  }
}

final feedControllerProvider =
    NotifierProvider<FeedController, FeedState>(FeedController.new);
