import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/profile_model.dart';
import '../auth/auth_controller.dart';

class OnboardingState {
  final int currentStep; // 0 for Academics (Department & Semester), 1 for Personalize (Interests & Skills)
  final String fullName;
  final String? collegeEmail;
  final String? avatarUrl;
  final String? branch;
  final int? semester;
  final int year;
  final List<String> selectedInterests;
  final List<String> selectedSkills;
  final bool isSaving;
  final String? errorMessage;

  const OnboardingState({
    this.currentStep = 0,
    this.fullName = '',
    this.collegeEmail,
    this.avatarUrl,
    this.branch = 'Computer Science & Engineering',
    this.semester = 3,
    this.year = 2,
    this.selectedInterests = const [
      'Hackathons',
      'Workshops',
      'Cultural Fests',
      'Clubs & Societies',
      'Networking',
    ],
    this.selectedSkills = const [
      'Python',
      'UI/UX Design',
      'Public Speaking',
    ],
    this.isSaving = false,
    this.errorMessage,
  });

  bool get isAcademicValid =>
      fullName.trim().isNotEmpty &&
      branch != null &&
      branch!.isNotEmpty &&
      semester != null;

  bool get isPersonalizeValid =>
      selectedInterests.isNotEmpty || selectedSkills.isNotEmpty;

  OnboardingState copyWith({
    int? currentStep,
    String? fullName,
    String? collegeEmail,
    String? avatarUrl,
    String? branch,
    int? semester,
    int? year,
    List<String>? selectedInterests,
    List<String>? selectedSkills,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      fullName: fullName ?? this.fullName,
      collegeEmail: collegeEmail ?? this.collegeEmail,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      branch: branch ?? this.branch,
      semester: semester ?? this.semester,
      year: year ?? this.year,
      selectedInterests: selectedInterests ?? this.selectedInterests,
      selectedSkills: selectedSkills ?? this.selectedSkills,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class OnboardingController extends Notifier<OnboardingState> {
  @override
  OnboardingState build() {
    final profile = ref.watch(authControllerProvider).profile;
    if (profile != null) {
      final initialSemester = profile.semester ?? (profile.year != null ? (profile.year! * 2 - 1) : 3);
      final computedYear = (initialSemester + 1) ~/ 2;

      return OnboardingState(
        fullName: profile.fullName.isNotEmpty ? profile.fullName : 'SXUK Student',
        collegeEmail: profile.collegeEmail,
        avatarUrl: profile.avatarUrl,
        branch: profile.branch ?? 'Computer Science & Engineering',
        semester: initialSemester,
        year: computedYear,
        selectedInterests: profile.interests.isNotEmpty
            ? profile.interests
            : const [
                'Hackathons',
                'Workshops',
                'Cultural Fests',
                'Clubs & Societies',
                'Networking',
              ],
        selectedSkills: profile.skills.isNotEmpty
            ? profile.skills
            : const ['Python', 'UI/UX Design', 'Public Speaking'],
      );
    }
    return const OnboardingState();
  }

  void setStep(int step) {
    state = state.copyWith(currentStep: step, clearError: true);
  }

  void nextStep() {
    if (state.currentStep == 0) {
      if (state.fullName.trim().isEmpty) {
        state = state.copyWith(errorMessage: 'Please enter your full name');
        return;
      }
      if (state.branch == null || state.branch!.isEmpty) {
        state = state.copyWith(errorMessage: 'Please select your department / branch');
        return;
      }
      if (state.semester == null) {
        state = state.copyWith(errorMessage: 'Please select your current semester');
        return;
      }
      state = state.copyWith(currentStep: 1, clearError: true);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1, clearError: true);
    }
  }

  void updateFullName(String name) {
    state = state.copyWith(fullName: name, clearError: true);
  }

  void updateBranch(String? branch) {
    if (branch != null) {
      state = state.copyWith(branch: branch, clearError: true);
    }
  }

  void updateSemester(int semester) {
    final computedYear = (semester + 1) ~/ 2;
    state = state.copyWith(semester: semester, year: computedYear, clearError: true);
  }

  void toggleInterest(String interest) {
    final list = List<String>.from(state.selectedInterests);
    if (list.contains(interest)) {
      list.remove(interest);
    } else {
      list.add(interest);
    }
    state = state.copyWith(selectedInterests: list, clearError: true);
  }

  void toggleSkill(String skill) {
    final list = List<String>.from(state.selectedSkills);
    if (list.contains(skill)) {
      list.remove(skill);
    } else {
      list.add(skill);
    }
    state = state.copyWith(selectedSkills: list, clearError: true);
  }

  void addCustomSkill(String skill) {
    final trimmed = skill.trim();
    if (trimmed.isEmpty) return;
    final list = List<String>.from(state.selectedSkills);
    if (!list.contains(trimmed)) {
      list.add(trimmed);
      state = state.copyWith(selectedSkills: list, clearError: true);
    }
  }

  void removeSkill(String skill) {
    final list = List<String>.from(state.selectedSkills)..remove(skill);
    state = state.copyWith(selectedSkills: list);
  }

  Future<bool> completeOnboarding() async {
    if (state.selectedInterests.isEmpty && state.selectedSkills.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Please select at least one interest or skill to personalize your feed',
      );
      return false;
    }

    state = state.copyWith(isSaving: true, clearError: true);

    try {
      final existingProfile = ref.read(authControllerProvider).profile;
      final userId = existingProfile?.id ?? 'user-sxuk-${DateTime.now().millisecondsSinceEpoch}';
      final email = existingProfile?.collegeEmail ?? state.collegeEmail ?? 'student@sxuk.edu.in';
      final avatar = existingProfile?.avatarUrl ?? state.avatarUrl;

      final updatedProfile = ProfileModel(
        id: userId,
        fullName: state.fullName.trim().isNotEmpty
            ? state.fullName.trim()
            : 'SXUK Student',
        collegeEmail: email,
        avatarUrl: avatar,
        branch: state.branch,
        semester: state.semester,
        year: state.year,
        interests: state.selectedInterests,
        skills: state.selectedSkills,
        updatedAt: DateTime.now(),
      );

      await ref.read(authControllerProvider.notifier).updateProfile(updatedProfile);
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to save profile: $e',
      );
      return false;
    }
  }
}

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingState>(
        OnboardingController.new);
