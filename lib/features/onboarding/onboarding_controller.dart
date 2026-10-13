import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/fcm_notification_service.dart';
import '../../core/services/gemini_ocr_service.dart';
import '../../data/repositories/student_verification_repository.dart';
import '../../models/college_model.dart';
import '../../models/id_card_verification_model.dart';
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

  // Student ID Verification (SheerID Standard)
  final DocumentType selectedDocumentType;
  final bool isVerifyingIdCard;
  final bool verificationSuccess;
  final VerificationStatus verificationStatus;
  final String? verifiedRollNumber;
  final String? idCardPath;
  final Uint8List? idCardBytes;
  final IdCardOcrResult? ocrResult;
  final int verificationChecklistStep; // 0: idle, 1: reading, 2: matching college, 3: validating roll, 4: done
  final bool isDuplicateRollDetected;
  final String? verificationNotes;

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
    this.selectedDocumentType = DocumentType.collegeIdCard,
    this.isVerifyingIdCard = false,
    this.verificationSuccess = false,
    this.verificationStatus = VerificationStatus.unverified,
    this.verifiedRollNumber,
    this.idCardPath,
    this.idCardBytes,
    this.ocrResult,
    this.verificationChecklistStep = 0,
    this.isDuplicateRollDetected = false,
    this.verificationNotes,
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
    DocumentType? selectedDocumentType,
    bool? isVerifyingIdCard,
    bool? verificationSuccess,
    VerificationStatus? verificationStatus,
    String? verifiedRollNumber,
    String? idCardPath,
    Uint8List? idCardBytes,
    IdCardOcrResult? ocrResult,
    int? verificationChecklistStep,
    bool? isDuplicateRollDetected,
    String? verificationNotes,
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
      selectedDocumentType: selectedDocumentType ?? this.selectedDocumentType,
      isVerifyingIdCard: isVerifyingIdCard ?? this.isVerifyingIdCard,
      verificationSuccess: verificationSuccess ?? this.verificationSuccess,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verifiedRollNumber: verifiedRollNumber ?? this.verifiedRollNumber,
      idCardPath: idCardPath ?? this.idCardPath,
      idCardBytes: idCardBytes ?? this.idCardBytes,
      ocrResult: ocrResult ?? this.ocrResult,
      verificationChecklistStep: verificationChecklistStep ?? this.verificationChecklistStep,
      isDuplicateRollDetected: isDuplicateRollDetected ?? this.isDuplicateRollDetected,
      verificationNotes: verificationNotes ?? this.verificationNotes,
    );
  }
}

class OnboardingController extends Notifier<OnboardingState> {
  final ImagePicker _picker = ImagePicker();

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
        verificationStatus: profile.verificationStatus,
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

  void setDocumentType(DocumentType docType) {
    state = state.copyWith(selectedDocumentType: docType);
  }

  void nextStep() {
    if (state.currentStep == 0) {
      if (state.selectedCollegeId.isEmpty) {
        state = state.copyWith(errorMessage: 'Please select your university/college');
        return;
      }
      state = state.copyWith(currentStep: 1, clearError: true);
    } else if (state.currentStep == 1) {
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

  /// Interactive camera or gallery document picker with automated Gemini OCR verification
  Future<void> pickAndVerifyDocument({ImageSource source = ImageSource.gallery}) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 92,
        maxWidth: 1600,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        await processIdCardVerification(bytes: bytes, imagePath: picked.path);
      }
    } catch (e) {
      // In case picker is unavailable or cancelled, fallback smoothly
      await verifyIdCard();
    }
  }

  /// Process ID Card verification using Gemini Multimodal OCR + Anti-Fraud Uniqueness
  Future<void> processIdCardVerification({
    Uint8List? bytes,
    String? imagePath,
    String? customRollNumber,
  }) async {
    state = state.copyWith(
      isVerifyingIdCard: true,
      verificationChecklistStep: 1, // 1: Reading document
      idCardPath: imagePath,
      idCardBytes: bytes,
      isDuplicateRollDetected: false,
      clearError: true,
    );

    final college = CollegeModel(
      id: state.selectedCollegeId,
      name: state.selectedCollegeName,
      shortCode: state.selectedCollegeShortCode,
      city: 'Kolkata',
      state: 'West Bengal',
      popularBranches: state.branch != null ? [state.branch!] : const [],
    );

    // Step 1: Ingest document
    await Future.delayed(const Duration(milliseconds: 600));

    // Step 2: OCR Analysis
    state = state.copyWith(verificationChecklistStep: 2); // 2: Matching college & department
    final ocrService = ref.read(geminiOcrServiceProvider);
    final IdCardOcrResult effectiveResult = await ocrService.extractIdCardDetailsFromImage(
      imageBytes: bytes ?? Uint8List(0),
      college: college,
      studentName: state.fullName,
    );

    // Step 3: Anti-Identity Sharing Check (Partial Unique Index Check)
    state = state.copyWith(
      verificationChecklistStep: 3, // 3: Verifying roll number uniqueness
      ocrResult: effectiveResult,
    );
    await Future.delayed(const Duration(milliseconds: 500));

    final verifRepo = ref.read(studentVerificationRepositoryProvider);
    final rollToCheck = customRollNumber ??
        (effectiveResult.extractedRoll.isNotEmpty
            ? effectiveResult.extractedRoll
            : '${state.selectedCollegeShortCode}/CSE/24/108');

    final isUnique = await verifRepo.checkRollNumberAvailability(
      state.selectedCollegeId,
      rollToCheck,
    );

    final currentUserId = ref.read(authControllerProvider).profile?.id ??
        'user-${DateTime.now().millisecondsSinceEpoch}';

    String photoUrl = imagePath ?? '';
    if (bytes != null) {
      photoUrl = await verifRepo.uploadIdCardDocument(
        userId: currentUserId,
        bytes: bytes,
      );
    }

    if (!isUnique) {
      // Flagged: Anti-Identity Conflict Alert
      final flaggedSubmission = StudentVerificationModel(
        id: 'verif-${DateTime.now().millisecondsSinceEpoch}',
        userId: currentUserId,
        collegeId: state.selectedCollegeId,
        documentType: state.selectedDocumentType,
        fullNameOnCard: effectiveResult.extractedName.isNotEmpty
            ? effectiveResult.extractedName
            : state.fullName,
        rollNumber: rollToCheck,
        department: state.branch,
        idCardFrontUrl: photoUrl.isNotEmpty
            ? photoUrl
            : 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=800&q=80',
        status: VerificationStatus.pending,
        verificationMethod: VerificationMethod.hybrid,
        ocrConfidence: effectiveResult.confidence,
        ocrRawPayload: effectiveResult.rawPayload,
        rejectionCode: RejectionCode.duplicateRollNumber,
        rejectionReason: 'Duplicate Roll Number detected across accounts. Flagged for Dean review.',
        createdAt: DateTime.now(),
      );

      await verifRepo.submitVerification(flaggedSubmission);

      state = state.copyWith(
        isVerifyingIdCard: false,
        verificationSuccess: false,
        verificationStatus: VerificationStatus.pending,
        verifiedRollNumber: rollToCheck,
        isDuplicateRollDetected: true,
        verificationChecklistStep: 4,
        verificationNotes:
            'Security Alert: Roll number "$rollToCheck" is currently claimed. Escalated to Dean Moderation Hub.',
      );
      return;
    }

    // Auto-approval vs Moderation Escalation
    if (effectiveResult.isAutoApproved) {
      final approvedSubmission = StudentVerificationModel(
        id: 'verif-${DateTime.now().millisecondsSinceEpoch}',
        userId: currentUserId,
        collegeId: state.selectedCollegeId,
        documentType: state.selectedDocumentType,
        fullNameOnCard: effectiveResult.extractedName.isNotEmpty
            ? effectiveResult.extractedName
            : state.fullName,
        rollNumber: rollToCheck,
        department: state.branch,
        idCardFrontUrl: photoUrl.isNotEmpty
            ? photoUrl
            : 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=800&q=80',
        status: VerificationStatus.approved,
        verificationMethod: VerificationMethod.automatedOcr,
        ocrConfidence: effectiveResult.confidence,
        ocrCollegeMatched: effectiveResult.collegeMatched,
        ocrNameMatched: effectiveResult.nameMatched,
        ocrRawPayload: effectiveResult.rawPayload,
        verifiedAt: DateTime.now(),
        expiresAt: StudentVerificationModel.computeAcademicExpiration(),
        createdAt: DateTime.now(),
      );

      await verifRepo.submitVerification(approvedSubmission);

      state = state.copyWith(
        isVerifyingIdCard: false,
        verificationSuccess: true,
        verificationStatus: VerificationStatus.approved,
        verifiedRollNumber: rollToCheck,
        verificationChecklistStep: 4,
        verificationNotes:
            '✓ Instant SheerID Auto-Approval: 1-Year Pan-India collegiate pass active.',
      );
    } else {
      // Escalated to Department Moderator Queue (50%-84% confidence or manual review)
      final pendingSubmission = StudentVerificationModel(
        id: 'verif-${DateTime.now().millisecondsSinceEpoch}',
        userId: currentUserId,
        collegeId: state.selectedCollegeId,
        documentType: state.selectedDocumentType,
        fullNameOnCard: effectiveResult.extractedName.isNotEmpty
            ? effectiveResult.extractedName
            : state.fullName,
        rollNumber: rollToCheck,
        department: state.branch,
        idCardFrontUrl: photoUrl.isNotEmpty
            ? photoUrl
            : 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=800&q=80',
        status: VerificationStatus.pending,
        verificationMethod: VerificationMethod.hybrid,
        ocrConfidence: effectiveResult.confidence,
        ocrCollegeMatched: effectiveResult.collegeMatched,
        ocrNameMatched: effectiveResult.nameMatched,
        ocrRawPayload: effectiveResult.rawPayload,
        createdAt: DateTime.now(),
      );

      await verifRepo.submitVerification(pendingSubmission);

      state = state.copyWith(
        isVerifyingIdCard: false,
        verificationSuccess: false,
        verificationStatus: VerificationStatus.pending,
        verifiedRollNumber: rollToCheck,
        verificationChecklistStep: 4,
        verificationNotes:
            'Document submitted for Departmental Coordinator review (Confidence ${(effectiveResult.confidence * 100).toInt()}%).',
      );
    }
  }

  /// Fast simulated verification for quick demo & testing
  Future<void> verifyIdCard({String? customRollNumber, String? imagePath}) async {
    await processIdCardVerification(
      bytes: null,
      imagePath: imagePath,
      customRollNumber: customRollNumber,
    );
  }

  void skipVerification() {
    state = state.copyWith(
      verificationSuccess: false,
      verificationStatus: VerificationStatus.unverified,
      verifiedRollNumber: null,
      idCardPath: null,
      idCardBytes: null,
      ocrResult: null,
      verificationChecklistStep: 0,
      isDuplicateRollDetected: false,
      verificationNotes: null,
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

      final expiryDate = state.verificationSuccess
          ? StudentVerificationModel.computeAcademicExpiration()
          : null;

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
        verificationStatus: state.verificationStatus,
        verifiedAt: state.verificationSuccess ? DateTime.now() : null,
        verificationExpiresAt: expiryDate,
        idCardFrontUrl: state.idCardPath,
        rollNumber: state.verifiedRollNumber,
        updatedAt: DateTime.now(),
      );

      await ref.read(authControllerProvider.notifier).updateProfile(updatedProfile);

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
