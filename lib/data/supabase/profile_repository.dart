import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/mock/mock_data.dart';
import '../../models/profile_model.dart';
import 'supabase_client.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ProfileRepository(client);
});

class ProfileRepository {
  final SupabaseClient _client;

  ProfileRepository(this._client);

  /// Retrieves user profile by userId, with fallback to default mock student profile.
  Future<ProfileModel?> getProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        return ProfileModel.fromJson(response);
      }
    } catch (e) {
      debugPrint('Error getting profile for user $userId ($e). Using mock profile.');
    }
    return kDefaultProfile.copyWith(id: userId);
  }

  /// Updates or upserts user profile data.
  Future<ProfileModel?> updateProfile(ProfileModel profile) async {
    try {
      final payload = {
        ...profile.toJson(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from('profiles')
          .upsert(payload)
          .select()
          .maybeSingle();

      if (response != null) {
        return ProfileModel.fromJson(response);
      }
      return profile;
    } catch (e) {
      debugPrint('Error updating profile in Supabase ($e). Returning local updated profile.');
      return profile;
    }
  }

  /// Completes the student onboarding flow and stores personalized preferences.
  Future<ProfileModel?> completeOnboarding({
    required String userId,
    required String fullName,
    String? collegeEmail,
    String? branch,
    int? year,
    List<String> interests = const [],
    List<String> skills = const [],
    Map<String, dynamic>? extraMetadata,
  }) async {
    try {
      final existing = await getProfile(userId);

      final updatedMetadata = Map<String, dynamic>.from(existing?.metadata ?? {});
      if (extraMetadata != null) {
        updatedMetadata.addAll(extraMetadata);
      }
      updatedMetadata['onboarding_completed'] = true;
      updatedMetadata['onboarded_at'] = DateTime.now().toIso8601String();

      final updatedProfile = ProfileModel(
        id: userId,
        fullName: fullName.trim(),
        collegeEmail: collegeEmail?.trim() ?? existing?.collegeEmail,
        branch: branch?.trim() ?? existing?.branch,
        year: year ?? existing?.year,
        interests: interests.isNotEmpty ? interests : (existing?.interests ?? []),
        skills: skills.isNotEmpty ? skills : (existing?.skills ?? []),
        metadata: updatedMetadata,
        createdAt: existing?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return await updateProfile(updatedProfile);
    } catch (e) {
      debugPrint('Error completing onboarding: $e');
      return kDefaultProfile.copyWith(
        id: userId,
        fullName: fullName,
        collegeEmail: collegeEmail,
        branch: branch,
        year: year,
        interests: interests,
        skills: skills,
      );
    }
  }
}
