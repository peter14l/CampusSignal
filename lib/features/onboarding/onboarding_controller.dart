import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/fcm_notification_service.dart';
import '../../models/college_model.dart';
import '../../models/profile_model.dart';
import '../auth/auth_controller.dart';

class OnboardingState {
  /// 0: College Selection, 1: Academic Details, 2: Interests & Skills, 3: Student Verification
  final int currentStep;
  final String selectedCollegeId;
  final String selectedCollegeName;
  final String selectedCollegeShortCode;
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

  // Student ID Verification
  final bool isVerifyingIdCard;
  final bool verificationSuccess;
  final String? verifiedRollNumber;
  final String? idCardPath;

  const OnboardingState({
    this.currentStep = 0,
    this.selectedCollegeId = 'sxuk',
    this.selectedCollegeName = "St. Xavier's University, Kolkata",
    this.selectedCollegeShortCode = 'SXUK',
    this.fullName = '',
    this.collegeEmail,
    this.avatarUrl,
    this.branch = 'B.Tech in CSE',
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
    this.isVerifyingIdCard = false,
    this.verificationSuccess = false,
    this.verifiedRollNumber,
    this.idCardPath,
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
    String? selectedCollegeId,
    String? selectedCollegeName,
    String? selectedCollegeShortCode,
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
    bool? isVerifyingIdCard,
    bool? verificationSuccess,
    String? verifiedRollNumber,
    String? idCardPath,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      selectedCollegeId: selectedCollegeId ?? this.selectedCollegeId,
      selectedCollegeName: selectedCollegeName ?? this.selectedCollegeName,
      selectedCollegeShortCode: selectedCollegeShortCode ?? this.selectedCollegeShortCode,
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
      isVerifyingIdCard: isVerifyingIdCard ?? this.isVerifyingIdCard,
      verificationSuccess: verificationSuccess ?? this.verificationSuccess,
      verifiedRollNumber: verifiedRollNumber ?? this.verifiedRollNumber,
      idCardPath: idCardPath ?? this.idCardPath,
    );
  }
}

class OnboardingController extends Notifier<OnboardingState> {
  @override
  OnboardingState build() {
    final authState = ref.watch(authControllerProvider);
    final profile = authState.profile;
    final selectedCollege = authState.selectedCollege;

    if (profile != null) {
      final initialSemester = profile.semester ?? (profile.year != null ? (profile.year! * 2 - 1) : 3);
      final computedYear = (initialSemester + 1) ~/ 2;

      return OnboardingState(
        selectedCollegeId: profile.collegeId ?? selectedCollege.id,
        selectedCollegeName: profile.collegeName ?? selectedCollege.name,
        selectedCollegeShortCode: profile.collegeShortCode ?? selectedCollege.shortCode,
        fullName: profile.fullName.isNotEmpty ? profile.fullName : '',
        collegeEmail: profile.collegeEmail,
        avatarUrl: profile.avatarUrl,
        branch: profile.branch ??
            (selectedCollege.popularBranches.isNotEmpty
                ? selectedCollege.popularBranches.first
                : 'B.Tech in CSE'),
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
        isVerifyingIdCard: false,
        verificationSuccess: profile.isVerifiedStudent,
        verifiedRollNumber: profile.rollNumber,
      );
    }
    return OnboardingState(
      selectedCollegeId: selectedCollege.id,
      selectedCollegeName: selectedCollege.name,
      selectedCollegeShortCode: selectedCollege.shortCode,
      branch: selectedCollege.popularBranches.isNotEmpty
          ? selectedCollege.popularBranches.first
          : 'B.Tech in CSE',
    );
  }

  void selectCollege(CollegeModel college) {
    // If college has default branches, select first popular branch
    final defaultBranch = college.popularBranches.isNotEmpty
        ? college.popularBranches.first
        : state.branch;

    state = state.copyWith(
      selectedCollegeId: college.id,
      selectedCollegeName: college.name,
      selectedCollegeShortCode: college.shortCode,
      branch: defaultBranch,
      clearError: true,
    );
  }

  void setStep(int step) {
    state = state.copyWith(currentStep: step, clearError: true);
  }

  void nextStep() {
    if (state.currentStep == 0) {
      // Validated campus selection
      if (state.selectedCollegeId.isEmpty) {
        state = state.copyWith(errorMessage: 'Please select your university/college');
        return;
      }
      state = state.copyWith(currentStep: 1, clearError: true);
    } else if (state.currentStep == 1) {
      // Validate Academic Details
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
      state = state.copyWith(currentStep: 2, clearError: true);
    } else if (state.currentStep == 2) {
      // Validate Interests & Skills
      if (state.selectedInterests.isEmpty && state.selectedSkills.isEmpty) {
        state = state.copyWith(errorMessage: 'Please select at least one interest or skill');
        return;
      }
      state = state.copyWith(currentStep: 3, clearError: true);
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

  /// Simulate instant OCR detection or process uploaded student ID card
  Future<void> verifyIdCard({String? customRollNumber, String? imagePath}) async {
    state = state.copyWith(isVerifyingIdCard: true, clearError: true);
    await Future.delayed(const Duration(milliseconds: 900));

    final generatedRoll = customRollNumber ??
        '${state.selectedCollegeShortCode}/${(state.branch ?? "ENG").split(" ").first.replaceAll(".", "")}/${DateTime.now().year % 100}/${(100 + (DateTime.now().millisecond % 899))}';

    state = state.copyWith(
      isVerifyingIdCard: false,
      verificationSuccess: true,
      verifiedRollNumber: generatedRoll,
      idCardPath: imagePath,
    );
  }

  void skipVerification() {
    state = state.copyWith(
      verificationSuccess: false,
      verifiedRollNumber: null,
      idCardPath: null,
    );
  }

  Future<bool> completeOnboarding() async {
    state = state.copyWith(isSaving: true, clearError: true);

    try {
      final existingProfile = ref.read(authControllerProvider).profile;
      final userId = existingProfile?.id ??
          'user-${state.selectedCollegeId}-${DateTime.now().millisecondsSinceEpoch}';
      final email = existingProfile?.collegeEmail ??
          state.collegeEmail ??
          'student@${state.selectedCollegeShortCode.toLowerCase()}.edu.in';
      final avatar = existingProfile?.avatarUrl ?? state.avatarUrl;

      final updatedProfile = ProfileModel(
        id: userId,
        fullName: state.fullName.trim().isNotEmpty
            ? state.fullName.trim()
            : '${state.selectedCollegeShortCode} Student',
        collegeEmail: email,
        avatarUrl: avatar,
        collegeId: state.selectedCollegeId,
        collegeName: state.selectedCollegeName,
        collegeShortCode: state.selectedCollegeShortCode,
        branch: state.branch,
        semester: state.semester,
        year: state.year,
        interests: state.selectedInterests,
        skills: state.selectedSkills,
        isVerifiedStudent: state.verificationSuccess,
        rollNumber: state.verifiedRollNumber,
        updatedAt: DateTime.now(),
      );

      await ref.read(authControllerProvider.notifier).updateProfile(updatedProfile);

      // Request notification permissions
      try {
        await ref.read(fcmNotificationServiceProvider).requestPermissions();
      } catch (_) {}

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
