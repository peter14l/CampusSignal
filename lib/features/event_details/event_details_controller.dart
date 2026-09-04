import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/repositories/events_repository.dart';
import '../../models/event_model.dart';
import '../../models/reminder_model.dart';

class EventDetailsState {
  final EventModel? event;
  final bool isLoading;
  final bool isSaved;
  final bool isReminded;
  final ReminderModel? reminder;
  final bool isApplying;
  final String? feedbackMessage;
  final String? errorMessage;

  const EventDetailsState({
    this.event,
    this.isLoading = false,
    this.isSaved = false,
    this.isReminded = false,
    this.reminder,
    this.isApplying = false,
    this.feedbackMessage,
    this.errorMessage,
  });

  EventDetailsState copyWith({
    EventModel? event,
    bool? isLoading,
    bool? isSaved,
    bool? isReminded,
    ReminderModel? reminder,
    bool? isApplying,
    String? feedbackMessage,
    String? errorMessage,
  }) {
    return EventDetailsState(
      event: event ?? this.event,
      isLoading: isLoading ?? this.isLoading,
      isSaved: isSaved ?? this.isSaved,
      isReminded: isReminded ?? this.isReminded,
      reminder: reminder ?? this.reminder,
      isApplying: isApplying ?? this.isApplying,
      feedbackMessage: feedbackMessage,
      errorMessage: errorMessage,
    );
  }
}

class EventDetailsController extends Notifier<EventDetailsState> {
  @override
  EventDetailsState build() {
    return const EventDetailsState();
  }

  EventsRepository get _repository => ref.read(eventsRepositoryProvider);

  Future<void> setEvent(EventModel event) async {
    final isSaved = _repository.isEventSaved(event.id);
    final isReminded = _repository.isEventReminded(event.id);
    state = state.copyWith(
      event: event,
      isSaved: isSaved,
      isReminded: isReminded,
      isLoading: false,
    );
  }

  Future<void> loadEventById(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final event = await _repository.getEventById(id);
      if (event != null) {
        final isSaved = _repository.isEventSaved(id);
        final isReminded = _repository.isEventReminded(id);
        state = state.copyWith(
          event: event,
          isSaved: isSaved,
          isReminded: isReminded,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Event not found',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load event details: $e',
      );
    }
  }

  Future<void> toggleSave() async {
    if (state.event == null) return;
    final eventId = state.event!.id;
    final newSavedState = await _repository.toggleSave(eventId);
    state = state.copyWith(
      isSaved: newSavedState,
      feedbackMessage: newSavedState
          ? 'Event saved to your bookmarks'
          : 'Event removed from bookmarks',
    );
  }

  Future<void> setReminder(DateTime remindAt) async {
    if (state.event == null) return;
    try {
      final reminder = await _repository.addReminder(state.event!.id, remindAt);
      state = state.copyWith(
        isReminded: true,
        reminder: reminder,
        feedbackMessage: 'Reminder scheduled successfully!',
      );
    } catch (e) {
      state = state.copyWith(
        feedbackMessage: 'Failed to set reminder: $e',
      );
    }
  }

  Future<void> removeReminder() async {
    if (state.event == null) return;
    try {
      await _repository.removeReminder(state.event!.id);
      state = state.copyWith(
        isReminded: false,
        reminder: null,
        feedbackMessage: 'Reminder cancelled',
      );
    } catch (e) {
      state = state.copyWith(
        feedbackMessage: 'Failed to remove reminder: $e',
      );
    }
  }

  Future<bool> launchApply() async {
    final urlString = state.event?.applyUrl;
    if (urlString == null || urlString.isEmpty) {
      state = state.copyWith(feedbackMessage: 'No application link provided');
      return false;
    }

    state = state.copyWith(isApplying: true);
    await _repository.logApplication(state.event!.id);

    try {
      final uri = Uri.parse(urlString);
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      state = state.copyWith(
        isApplying: false,
        feedbackMessage: launched
            ? 'Application link opened'
            : 'Could not open application link',
      );
      return launched;
    } catch (e) {
      debugPrint('Error launching URL: $e');
      state = state.copyWith(
        isApplying: false,
        feedbackMessage: 'Could not open link: $urlString',
      );
      return false;
    }
  }

  Future<void> shareEvent() async {
    final event = state.event;
    if (event == null) return;
    final shareText = '''
🎓 ${event.title}
📅 Date: ${event.formattedDateRange}
📍 Venue: ${event.venue ?? 'SXUK Campus'}
🔗 Apply: ${event.applyUrl ?? 'Check CampusSignal app'}

Discover more campus opportunities on CampusSignal!
''';

    // ignore: deprecated_member_use
    await Share.share(
      shareText,
      subject: event.title,
    );
  }
}

final eventDetailsControllerProvider =
    NotifierProvider<EventDetailsController, EventDetailsState>(
  EventDetailsController.new,
);
