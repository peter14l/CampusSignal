import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/mock/mock_data.dart';
import '../../models/profile_model.dart';
import '../auth/auth_controller.dart';

class ProfileStats {
  final int savedEventsCount;
  final int appliedCount;
  final int remindersCount;

  const ProfileStats({
    this.savedEventsCount = 0,
    this.appliedCount = 0,
    this.remindersCount = 0,
  });
}

class ProfileState {
  final ProfileModel? profile;
  final ProfileStats stats;
  final bool isLoading;
  final String? message;

  const ProfileState({
    this.profile,
    this.stats = const ProfileStats(),
    this.isLoading = false,
    this.message,
  });

  ProfileState copyWith({
    ProfileModel? profile,
    ProfileStats? stats,
    bool? isLoading,
    String? message,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      message: message ?? this.message,
    );
  }
}

class ProfileController extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    final authState = ref.watch(authControllerProvider);
    final isDemo = authState.isDemoMode;
    return ProfileState(
      profile: authState.profile ?? (isDemo ? kDefaultProfile : null),
      stats: isDemo
          ? const ProfileStats(savedEventsCount: 6, appliedCount: 3, remindersCount: 4)
          : const ProfileStats(savedEventsCount: 0, appliedCount: 0, remindersCount: 0),
    );
  }

  Future<void> updateBasicDetails({
    required String fullName,
    required String branch,
    int? semester,
    int? year,
  }) async {
    final current = state.profile;
    if (current == null) return;

    final effectiveSemester = semester ?? current.semester ?? (year != null ? (year * 2 - 1) : 3);
    final effectiveYear = year ?? ((effectiveSemester + 1) ~/ 2);

    final updated = current.copyWith(
      fullName: fullName,
      branch: branch,
      semester: effectiveSemester,
      year: effectiveYear,
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(profile: updated);
    await ref.read(authControllerProvider.notifier).updateProfile(updated);
  }

  Future<void> updateFullAcademicProfile({
    required String fullName,
    required String branch,
    required int semester,
    required List<String> skills,
    required List<String> interests,
  }) async {
    final current = state.profile;
    if (current == null) return;

    final updated = current.copyWith(
      fullName: fullName,
      branch: branch,
      semester: semester,
      year: (semester + 1) ~/ 2,
      skills: skills,
      interests: interests,
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(profile: updated);
    await ref.read(authControllerProvider.notifier).updateProfile(updated);
  }

  Future<void> addInterest(String interest) async {
    final current = state.profile;
    if (current == null) return;
    final trimmed = interest.trim();
    if (trimmed.isEmpty || current.interests.contains(trimmed)) return;

    final updatedList = List<String>.from(current.interests)..add(trimmed);
    final updated = current.copyWith(interests: updatedList);
    state = state.copyWith(profile: updated);
    await ref.read(authControllerProvider.notifier).updateProfile(updated);
  }

  Future<void> removeInterest(String interest) async {
    final current = state.profile;
    if (current == null) return;

    final updatedList = List<String>.from(current.interests)..remove(interest);
    final updated = current.copyWith(interests: updatedList);
    state = state.copyWith(profile: updated);
    await ref.read(authControllerProvider.notifier).updateProfile(updated);
  }

  Future<void> addSkill(String skill) async {
    final current = state.profile;
    if (current == null) return;
    final trimmed = skill.trim();
    if (trimmed.isEmpty || current.skills.contains(trimmed)) return;

    final updatedList = List<String>.from(current.skills)..add(trimmed);
    final updated = current.copyWith(skills: updatedList);
    state = state.copyWith(profile: updated);
    await ref.read(authControllerProvider.notifier).updateProfile(updated);
  }

  Future<void> removeSkill(String skill) async {
    final current = state.profile;
    if (current == null) return;

    final updatedList = List<String>.from(current.skills)..remove(skill);
    final updated = current.copyWith(skills: updatedList);
    state = state.copyWith(profile: updated);
    await ref.read(authControllerProvider.notifier).updateProfile(updated);
  }

  Future<void> signOut() async {
    await ref.read(authControllerProvider.notifier).signOut();
  }
}

final profileControllerProvider =
    NotifierProvider<ProfileController, ProfileState>(ProfileController.new);
