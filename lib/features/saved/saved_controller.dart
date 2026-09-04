import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/events_repository.dart';
import '../../models/event_model.dart';
import '../../models/reminder_model.dart';

enum SavedSegment { saved, reminders }

class SavedState {
  final SavedSegment selectedSegment;
  final List<EventModel> savedEvents;
  final List<ReminderModel> reminders;
  final bool isLoading;
  final String? errorMessage;

  const SavedState({
    this.selectedSegment = SavedSegment.saved,
    this.savedEvents = const [],
    this.reminders = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  SavedState copyWith({
    SavedSegment? selectedSegment,
    List<EventModel>? savedEvents,
    List<ReminderModel>? reminders,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SavedState(
      selectedSegment: selectedSegment ?? this.selectedSegment,
      savedEvents: savedEvents ?? this.savedEvents,
      reminders: reminders ?? this.reminders,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class SavedController extends Notifier<SavedState> {
  @override
  SavedState build() {
    Future.microtask(() => loadData());
    return const SavedState();
  }

  EventsRepository get _repository => ref.read(eventsRepositoryProvider);

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final saved = await _repository.getSavedEvents();
      final reminders = await _repository.getReminders();
      state = state.copyWith(
        savedEvents: saved,
        reminders: reminders,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load saved items: $e',
      );
    }
  }

  void setSegment(SavedSegment segment) {
    state = state.copyWith(selectedSegment: segment);
  }

  Future<void> toggleSave(String eventId) async {
    await _repository.toggleSave(eventId);
    await loadData();
  }

  Future<void> removeSavedEvent(String eventId) async {
    final updatedList =
        state.savedEvents.where((e) => e.id != eventId).toList();
    state = state.copyWith(savedEvents: updatedList);
    await _repository.toggleSave(eventId);
  }

  Future<void> removeReminder(String reminderIdOrEventId) async {
    final updatedList = state.reminders
        .where((r) =>
            r.id != reminderIdOrEventId && r.eventId != reminderIdOrEventId)
        .toList();
    state = state.copyWith(reminders: updatedList);
    await _repository.removeReminder(reminderIdOrEventId);
  }
}

final savedControllerProvider =
    NotifierProvider<SavedController, SavedState>(SavedController.new);
