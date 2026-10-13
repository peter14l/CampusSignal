import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../data/repositories/events_repository.dart';
import '../../data/repositories/student_verification_repository.dart';
import '../../models/event_model.dart';
import '../../models/id_card_verification_model.dart';
import '../../models/profile_model.dart';
import '../auth/auth_controller.dart';
import '../profile/profile_controller.dart';

class AdminState {
  final bool isLoading;
  final bool isProcessing;
  final List<EventModel> pendingEvents;
  final List<StudentVerificationModel> pendingVerifications;
  final String selectedDepartment;
  final List<String> availableDepartments;
  final String? successMessage;
  final String? errorMessage;
  final String? claimedKey;

  const AdminState({
    this.isLoading = false,
    this.isProcessing = false,
    this.pendingEvents = const [],
    this.pendingVerifications = const [],
    this.selectedDepartment = 'All Departments',
    this.availableDepartments = const [
      'All Departments',
      'CSE',
      'ECE',
      'Commerce',
      'Management',
      'Mass Communication',
    ],
    this.successMessage,
    this.errorMessage,
    this.claimedKey,
  });

  AdminState copyWith({
    bool? isLoading,
    bool? isProcessing,
    List<EventModel>? pendingEvents,
    List<StudentVerificationModel>? pendingVerifications,
    String? selectedDepartment,
    List<String>? availableDepartments,
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
      selectedDepartment: selectedDepartment ?? this.selectedDepartment,
      availableDepartments: availableDepartments ?? this.availableDepartments,
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
  StudentVerificationRepository get _verificationRepository =>
      ref.read(studentVerificationRepositoryProvider);

  Future<void> loadPendingQueue({String? department}) async {
    state = state.copyWith(isLoading: true, clearMessages: true);

    try {
      final profile = ref.read(authControllerProvider).profile ??
          ref.read(profileControllerProvider).profile;

      final pending = await _repository.getPendingEvents(
        collegeId: profile?.collegeId,
        festIds: profile?.managedFestIds,
      );

      final verifications = await _verificationRepository.getPendingModerationQueue(
        collegeId: profile?.collegeId,
        department: department ?? state.selectedDepartment,
      );

      // Extract unique department list
      final deptSet = <String>{'All Departments'};
      for (final v in verifications) {
        if (v.department != null && v.department!.isNotEmpty) {
          deptSet.add(v.department!);
        }
      }
      for (final def in [
        'CSE',
        'ECE',
        'Commerce',
        'Management',
        'Mass Communication',
      ]) {
        deptSet.add(def);
      }

      state = state.copyWith(
        isLoading: false,
        pendingEvents: pending,
        pendingVerifications: verifications,
        availableDepartments: deptSet.toList(),
        selectedDepartment: department ?? state.selectedDepartment,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load moderation queue: $e',
      );
    }
  }

  void filterDepartment(String department) {
    state = state.copyWith(selectedDepartment: department);
    loadPendingQueue(department: department);
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

  Future<void> approveStudentVerification(
    String verifId, {
    String? reviewerNotes,
    DateTime? expiresAt,
  }) async {
    state = state.copyWith(isProcessing: true, clearMessages: true);
    try {
      final currentProfile = ref.read(authControllerProvider).profile;
      final reviewerId = currentProfile?.id ?? 'faculty-dean-01';

      await _verificationRepository.approveVerification(
        verificationId: verifId,
        reviewerId: reviewerId,
        reviewerNotes: reviewerNotes,
        expiresAt: expiresAt ?? StudentVerificationModel.computeAcademicExpiration(),
      );

      final updated = state.pendingVerifications.where((v) => v.id != verifId).toList();
      state = state.copyWith(
        isProcessing: false,
        pendingVerifications: updated,
        successMessage: 'Student ID card approved with Dean-compliant academic expiration.',
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'Failed to approve student verification: $e',
      );
    }
  }

  Future<void> rejectStudentVerification({
    required String verifId,
    required RejectionCode rejectionCode,
    required String rejectionReason,
    String? reviewerNotes,
    String? notes,
  }) async {
    state = state.copyWith(isProcessing: true, clearMessages: true);
    try {
      final currentProfile = ref.read(authControllerProvider).profile;
      final reviewerId = currentProfile?.id ?? 'faculty-dean-01';

      await _verificationRepository.rejectVerification(
        verificationId: verifId,
        reviewerId: reviewerId,
        rejectionCode: rejectionCode,
        rejectionReason: rejectionReason,
        reviewerNotes: reviewerNotes ?? notes,
      );

      final updated = state.pendingVerifications.where((v) => v.id != verifId).toList();
      state = state.copyWith(
        isProcessing: false,
        pendingVerifications: updated,
        successMessage: 'Student verification rejected. Reason: ${rejectionCode.description}',
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'Failed to reject verification: $e',
      );
    }
  }
}

final adminControllerProvider =
    NotifierProvider<AdminController, AdminState>(AdminController.new);
