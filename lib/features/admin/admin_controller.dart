import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../data/repositories/events_repository.dart';
import '../../models/event_model.dart';
import '../../models/profile_model.dart';
import '../auth/auth_controller.dart';
import '../profile/profile_controller.dart';

class FlaggedStudentVerification {
  final String id;
  final String studentName;
  final String rollNumber;
  final String collegeName;
  final String branch;
  final String semester;
  final String submittedAt;

  const FlaggedStudentVerification({
    required this.id,
    required this.studentName,
    required this.rollNumber,
    required this.collegeName,
    required this.branch,
    required this.semester,
    required this.submittedAt,
  });
}

class AdminState {
  final bool isLoading;
  final bool isProcessing;
  final List<EventModel> pendingEvents;
  final List<FlaggedStudentVerification> pendingVerifications;
  final String? successMessage;
  final String? errorMessage;
  final String? claimedKey;

  const AdminState({
    this.isLoading = false,
    this.isProcessing = false,
    this.pendingEvents = const [],
    this.pendingVerifications = const [],
    this.successMessage,
    this.errorMessage,
    this.claimedKey,
  });

  AdminState copyWith({
    bool? isLoading,
    bool? isProcessing,
    List<EventModel>? pendingEvents,
    List<FlaggedStudentVerification>? pendingVerifications,
    String? successMessage,
    String? errorMessage,
    String? claimedKey,
    bool clearMessages = false,
  }) {
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      isProcessing: isProcessing ?? this.isProcessing,
      pendingEvents: pendingEvents ?? this.pendingEvents,
      pendingVerifications: pendingVerifications ?? this.pendingVerifications,
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      claimedKey: claimedKey ?? this.claimedKey,
    );
  }
}

class AdminController extends Notifier<AdminState> {
  @override
  AdminState build() {
    Future.microtask(() => loadPendingQueue());
    return const AdminState();
  }

  EventsRepository get _repository => ref.read(eventsRepositoryProvider);

  Future<void> loadPendingQueue() async {
    state = state.copyWith(isLoading: true, clearMessages: true);

    try {
      final profile = ref.read(authControllerProvider).profile ??
          ref.read(profileControllerProvider).profile;

      final pending = await _repository.getPendingEvents(
        collegeId: profile?.collegeId,
        festIds: profile?.managedFestIds,
      );

      // Default mock pending verifications for demonstration
      final defaultVerifications = [
        const FlaggedStudentVerification(
          id: 'verif-1',
          studentName: 'Priya Mukherjee',
          rollNumber: 'SXUK/CSE/24/089',
          collegeName: "St. Xavier's University, Kolkata",
          branch: 'B.Tech in CSE',
          semester: 'Sem 4',
          submittedAt: 'Today, 2:15 PM',
        ),
        const FlaggedStudentVerification(
          id: 'verif-2',
          studentName: 'Rohan Sen',
          rollNumber: 'JU/ETCE/23/044',
          collegeName: 'Jadavpur University',
          branch: 'B.E. Electronics & Telecommunication',
          semester: 'Sem 6',
          submittedAt: 'Yesterday, 6:40 PM',
        ),
      ];

      state = state.copyWith(
        isLoading: false,
        pendingEvents: pending,
        pendingVerifications: defaultVerifications,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load moderation queue: $e',
      );
    }
  }

  Future<void> approveEvent(String eventId) async {
    state = state.copyWith(isProcessing: true, clearMessages: true);
    try {
      final profile = ref.read(authControllerProvider).profile;
      final approverName = profile?.fullName ?? 'Campus Admin';

      await _repository.approveEvent(eventId, approvedBy: approverName);
      final updatedList = state.pendingEvents.where((e) => e.id != eventId).toList();

      state = state.copyWith(
        isProcessing: false,
        pendingEvents: updatedList,
        successMessage: 'Event approved and published to live feeds!',
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'Failed to approve event: $e',
      );
    }
  }

  Future<void> rejectEvent(String eventId, String reason) async {
    state = state.copyWith(isProcessing: true, clearMessages: true);
    try {
      await _repository.rejectEvent(eventId, reason: reason);
      final updatedList = state.pendingEvents.where((e) => e.id != eventId).toList();

      state = state.copyWith(
        isProcessing: false,
        pendingEvents: updatedList,
        successMessage: 'Event rejected. Organizer notified with reason.',
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'Failed to reject event: $e',
      );
    }
  }

  Future<void> elevateToInterCollege(String eventId) async {
    state = state.copyWith(isProcessing: true, clearMessages: true);
    try {
      await _repository.elevateEventScope(eventId, EventScope.interCollege);
      await _repository.approveEvent(eventId);
      final updatedList = state.pendingEvents.where((e) => e.id != eventId).toList();

      state = state.copyWith(
        isProcessing: false,
        pendingEvents: updatedList,
        successMessage: 'Promoted to Pan-India Inter-College and published!',
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'Failed to promote event: $e',
      );
    }
  }

  Future<bool> redeemFestPasskey(String rawKey) async {
    final key = rawKey.trim().toUpperCase();
    state = state.copyWith(isProcessing: true, clearMessages: true);

    await Future.delayed(const Duration(milliseconds: 600));

    final directory = AppConstants.festPasskeyDirectory;
    if (directory.containsKey(key)) {
      final festId = directory[key]!;
      final currentProfile = ref.read(authControllerProvider).profile;

      if (currentProfile != null) {
        final managedFests = List<String>.from(currentProfile.managedFestIds);
        if (!managedFests.contains(festId)) {
          managedFests.add(festId);
        }

        final updatedProfile = currentProfile.copyWith(
          role: currentProfile.role == UserRole.student
              ? UserRole.festAdmin
              : currentProfile.role,
          managedFestIds: managedFests,
        );

        await ref.read(authControllerProvider.notifier).updateProfile(updatedProfile);
      }

      state = state.copyWith(
        isProcessing: false,
        claimedKey: key,
        successMessage: 'Passkey verified! You are now authorized as Fest Convenor for $key.',
      );
      await loadPendingQueue();
      return true;
    } else {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'Invalid or expired convenor passkey. Please check with your faculty lead.',
      );
      return false;
    }
  }

  Future<void> approveStudentVerification(String verifId) async {
    final updated = state.pendingVerifications.where((v) => v.id != verifId).toList();
    state = state.copyWith(
      pendingVerifications: updated,
      successMessage: 'Student ID card approved and verified badge granted.',
    );
  }
}

final adminControllerProvider =
    NotifierProvider<AdminController, AdminState>(AdminController.new);
