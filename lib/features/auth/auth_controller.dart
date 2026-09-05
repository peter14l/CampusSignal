import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/mock/mock_data.dart';
import '../../core/storage/shared_preferences_provider.dart';
import '../../core/supabase/supabase_config.dart';
import '../../models/profile_model.dart';

enum GoogleAuthStatus {
  authenticated,
  needsOnboarding,
  cancelled,
  failed,
}

class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final String? email;
  final bool isOtpSent;
  final int resendCountdown;
  final ProfileModel? profile;
  final bool isAuthenticated;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.email,
    this.isOtpSent = false,
    this.resendCountdown = 0,
    this.profile,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    String? email,
    bool? isOtpSent,
    int? resendCountdown,
    ProfileModel? profile,
    bool? isAuthenticated,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      email: email ?? this.email,
      isOtpSent: isOtpSent ?? this.isOtpSent,
      resendCountdown: resendCountdown ?? this.resendCountdown,
      profile: profile ?? this.profile,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthController extends Notifier<AuthState> {
  static const String _keyAuthProfile = 'campussignal_auth_profile';
  static const String _keyIsAuth = 'campussignal_is_authenticated';
  static const String _keyAuthEmail = 'campussignal_auth_email';

  Timer? _countdownTimer;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: '476399687886-2cg5sss23bq258a6o9afn4g78ltndnha.apps.googleusercontent.com',
  );

  @override
  AuthState build() {
    ref.onDispose(() {
      _countdownTimer?.cancel();
    });

    // 1. Read synchronous local storage
    final prefs = ref.watch(sharedPreferencesProvider);
    final isPersistedAuth = prefs.getBool(_keyIsAuth) ?? false;
    final savedEmail = prefs.getString(_keyAuthEmail);
    final profileJsonStr = prefs.getString(_keyAuthProfile);

    ProfileModel? restoredProfile;
    if (profileJsonStr != null && profileJsonStr.isNotEmpty) {
      try {
        final decoded = jsonDecode(profileJsonStr);
        if (decoded is Map<String, dynamic>) {
          restoredProfile = ProfileModel.fromJson(decoded);
        }
      } catch (e) {
        debugPrint('Error decoding restored profile: $e');
      }
    }

    // 2. Check active Firebase Auth user (if initialized)
    fb.User? fbUser;
    try {
      fbUser = fb.FirebaseAuth.instance.currentUser;
    } catch (_) {}

    // 3. Determine if authenticated from any valid session source
    final bool isAuthenticated = isPersistedAuth ||
        restoredProfile != null ||
        fbUser != null ||
        (SupabaseConfig.client?.auth.currentSession != null);

    final effectiveEmail = savedEmail ??
        restoredProfile?.collegeEmail ??
        fbUser?.email ??
        SupabaseConfig.client?.auth.currentSession?.user.email;

    final effectiveProfile = restoredProfile ??
        (fbUser != null
            ? ProfileModel(
                id: fbUser.uid,
                fullName: fbUser.displayName ?? 'SXUK Student',
                collegeEmail: fbUser.email,
                avatarUrl: fbUser.photoURL,
                branch: 'Computer Science & Engineering',
                semester: 3,
                year: 2,
                interests: const ['Hackathons', 'Workshops', 'Cultural Fests'],
                skills: const ['Python', 'UI/UX Design'],
              )
            : (isAuthenticated
                ? kDefaultProfile.copyWith(collegeEmail: effectiveEmail)
                : null));

    final initialAuthState = AuthState(
      isAuthenticated: isAuthenticated,
      email: effectiveEmail,
      profile: effectiveProfile,
    );

    _initAuthListener();
    return initialAuthState;
  }

  Future<void> _persistAuth(ProfileModel profile, String? email) async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setBool(_keyIsAuth, true);
      if (email != null) {
        await prefs.setString(_keyAuthEmail, email);
      }
      await prefs.setString(_keyAuthProfile, jsonEncode(profile.toJson()));
    } catch (e) {
      debugPrint('Error persisting auth state: $e');
    }
  }

  Future<void> _clearPersistedAuth() async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.remove(_keyIsAuth);
      await prefs.remove(_keyAuthEmail);
      await prefs.remove(_keyAuthProfile);
    } catch (e) {
      debugPrint('Error clearing persisted auth state: $e');
    }
  }

  void _initAuthListener() {
    final client = SupabaseConfig.client;
    if (client != null) {
      final session = client.auth.currentSession;
      if (session != null) {
        _fetchProfile(session.user.id, session.user.email);
      }

      client.auth.onAuthStateChange.listen((data) {
        final session = data.session;
        if (session != null) {
          _fetchProfile(session.user.id, session.user.email);
        } else if (data.event == AuthChangeEvent.signedOut) {
          _clearPersistedAuth();
          state = const AuthState();
        }
      });
    }
  }

  Future<void> _fetchProfile(String userId, String? email) async {
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        final res = await client
            .from('profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();

        if (res != null) {
          final remoteProfile = ProfileModel.fromJson(res);
          final current = state.profile;

          // Merge without losing locally cached skills/interests if remote has empty arrays
          final mergedProfile = remoteProfile.copyWith(
            collegeEmail: email ?? remoteProfile.collegeEmail ?? current?.collegeEmail,
            avatarUrl: (remoteProfile.avatarUrl != null && remoteProfile.avatarUrl!.isNotEmpty)
                ? remoteProfile.avatarUrl
                : current?.avatarUrl,
            interests: remoteProfile.interests.isNotEmpty
                ? remoteProfile.interests
                : (current?.interests ?? const []),
            skills: remoteProfile.skills.isNotEmpty
                ? remoteProfile.skills
                : (current?.skills ?? const []),
            branch: (remoteProfile.branch != null && remoteProfile.branch!.isNotEmpty)
                ? remoteProfile.branch
                : current?.branch,
            semester: remoteProfile.semester ?? current?.semester,
            year: remoteProfile.year ?? current?.year,
          );

          state = state.copyWith(
            isAuthenticated: true,
            profile: mergedProfile,
            email: email ?? mergedProfile.collegeEmail,
          );
          await _persistAuth(mergedProfile, email ?? mergedProfile.collegeEmail);

          // If local cache had interests/skills/branch missing in remote DB, sync back
          if (remoteProfile.interests.isEmpty && mergedProfile.interests.isNotEmpty ||
              remoteProfile.skills.isEmpty && mergedProfile.skills.isNotEmpty) {
            try {
              await client.from('profiles').upsert(mergedProfile.toSupabaseJson());
            } catch (_) {}
          }
          return;
        }
      } catch (e) {
        debugPrint('Error loading profile from Supabase: $e');
      }
    }

    // Merge with current state without losing details
    final current = state.profile;
    final fallbackProfile = current?.copyWith(
          id: userId,
          collegeEmail: email ?? current.collegeEmail,
        ) ??
        ProfileModel(
          id: userId,
          fullName: 'SXUK Student',
          collegeEmail: email,
          branch: 'Computer Science & Engineering',
          semester: 3,
          year: 2,
        );

    state = state.copyWith(
      isAuthenticated: true,
      email: email ?? fallbackProfile.collegeEmail,
      profile: fallbackProfile,
    );
    await _persistAuth(fallbackProfile, email);
  }

  /// Sign In using Google Account
  Future<GoogleAuthStatus> signInWithGoogle({bool mockAsExisting = false}) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);

    try {
      GoogleSignInAccount? googleUser;
      Object? signInError;
      try {
        googleUser = await _googleSignIn.signIn();
      } catch (e) {
        signInError = e;
        debugPrint('Native GoogleSignIn exception: $e');
      }

      if (signInError != null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Google Sign-in: ${signInError.toString()}',
        );
        return GoogleAuthStatus.failed;
      }

      // If user cancelled google sign in dialog
      if (googleUser == null) {
        if (mockAsExisting) {
          final existingProfile = kDefaultProfile;
          state = state.copyWith(
            isLoading: false,
            isAuthenticated: true,
            profile: existingProfile,
            email: existingProfile.collegeEmail,
          );
          await _persistAuth(existingProfile, existingProfile.collegeEmail);
          return GoogleAuthStatus.authenticated;
        }

        state = state.copyWith(isLoading: false);
        return GoogleAuthStatus.cancelled;
      }

      final googleAuth = await googleUser.authentication;
      final email = googleUser.email;
      final displayName = googleUser.displayName ?? 'SXUK Student';
      final photoUrl = googleUser.photoUrl;
      final userId = googleUser.id;

      // Authenticate with Firebase Auth
      try {
        if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)) {
          final credential = fb.GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          await fb.FirebaseAuth.instance.signInWithCredential(credential);
        }
      } catch (e) {
        debugPrint('Firebase Auth signInWithCredential notice: $e');
      }

      final client = SupabaseConfig.client;
      if (client != null && SupabaseConfig.isConfigured) {
        if (googleAuth.idToken == null) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: 'Google Sign-In did not return an ID token. Ensure serverClientId is configured correctly.',
          );
          return GoogleAuthStatus.failed;
        }

        try {
          final res = await client.auth.signInWithIdToken(
            provider: OAuthProvider.google,
            idToken: googleAuth.idToken!,
            accessToken: googleAuth.accessToken,
          );

          final authUser = res.user;
          if (authUser == null) {
            throw Exception('Supabase failed to create or return an authenticated user session.');
          }

          final authUserId = authUser.id; // Supabase UUID
          final existing = await client
              .from('profiles')
              .select()
              .eq('id', authUserId)
              .maybeSingle();

          if (existing != null) {
            var profile = ProfileModel.fromJson(existing);
            if (photoUrl != null && profile.avatarUrl != photoUrl) {
              profile = profile.copyWith(avatarUrl: photoUrl);
              try {
                await client.from('profiles').upsert(profile.toSupabaseJson());
              } catch (_) {}
            }

            state = state.copyWith(
              isLoading: false,
              isAuthenticated: true,
              profile: profile,
              email: email,
            );

            await _persistAuth(profile, email);

            return profile.isOnboardingComplete
                ? GoogleAuthStatus.authenticated
                : GoogleAuthStatus.needsOnboarding;
          } else {
            // New user registration in Supabase public.profiles
            final initialProfile = ProfileModel(
              id: authUserId,
              fullName: displayName,
              collegeEmail: email,
              avatarUrl: photoUrl,
              branch: null,
              year: null,
              semester: null,
              interests: const [],
              skills: const [],
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );

            try {
              await client.from('profiles').upsert(initialProfile.toSupabaseJson());
            } catch (e) {
              debugPrint('Notice: Initial Supabase profile row upsert: $e');
            }

            state = state.copyWith(
              isLoading: false,
              isAuthenticated: true,
              email: email,
              profile: initialProfile,
            );

            await _persistAuth(initialProfile, email);
            return GoogleAuthStatus.needsOnboarding;
          }
        } catch (e) {
          debugPrint('Supabase Google OAuth token verify error: $e');
          state = state.copyWith(
            isLoading: false,
            errorMessage: 'Supabase Auth Error: ${e.toString().replaceAll('AuthException', '').replaceAll('(', '').replaceAll(')', '').trim()}',
          );
          return GoogleAuthStatus.failed;
        }
      }

      // Offline / Mock Mode fallback (when Supabase is not configured):
      // Check if profile was already saved locally
      final currentProfile = state.profile;
      if (currentProfile != null &&
          currentProfile.collegeEmail == email &&
          currentProfile.isOnboardingComplete) {
        final mergedProfile = currentProfile.copyWith(avatarUrl: photoUrl ?? currentProfile.avatarUrl);
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          profile: mergedProfile,
          email: email,
        );
        await _persistAuth(mergedProfile, email);
        return GoogleAuthStatus.authenticated;
      }

      final initialProfile = ProfileModel(
        id: userId,
        fullName: displayName,
        collegeEmail: email,
        avatarUrl: photoUrl,
        branch: null,
        year: null,
        semester: null,
        interests: const [],
        skills: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        email: email,
        profile: initialProfile,
      );

      await _persistAuth(initialProfile, email);

      return GoogleAuthStatus.needsOnboarding;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Google Sign-in failed: ${e.toString()}',
      );
      return GoogleAuthStatus.failed;
    }
  }

  /// Demo / Mock Google Sign In (for testing both existing user and new user paths)
  Future<GoogleAuthStatus> demoGoogleSignIn({required bool isExistingUser}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future.delayed(const Duration(milliseconds: 600));

    if (isExistingUser) {
      final existingProfile = kDefaultProfile.copyWith(
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
      );
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        profile: existingProfile,
        email: existingProfile.collegeEmail,
      );
      await _persistAuth(existingProfile, existingProfile.collegeEmail);
      return GoogleAuthStatus.authenticated;
    } else {
      final newProfile = const ProfileModel(
        id: 'user-google-new-001',
        fullName: 'Rhea Sen',
        collegeEmail: 'rhea.sen@sxuk.edu.in',
        avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=400&q=80',
        branch: null,
        year: null,
        semester: null,
        interests: [],
        skills: [],
      );
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        email: newProfile.collegeEmail,
        profile: newProfile,
      );
      await _persistAuth(newProfile, newProfile.collegeEmail);
      return GoogleAuthStatus.needsOnboarding;
    }
  }

  bool validateEmail(String email) {
    final trimmed = email.trim().toLowerCase();
    if (trimmed.isEmpty) return false;
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@sxuk\.edu\.in$');
    if (kDebugMode) {
      return trimmed.endsWith('@sxuk.edu.in') || trimmed.contains('@');
    }
    return emailRegex.hasMatch(trimmed);
  }

  Future<bool> sendOtp(String email) async {
    final trimmed = email.trim().toLowerCase();
    if (!validateEmail(trimmed)) {
      state = state.copyWith(
        errorMessage: 'Please enter a valid SXUK college email (e.g. name@sxuk.edu.in)',
      );
      return false;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final client = SupabaseConfig.client;
      if (client != null && SupabaseConfig.isConfigured) {
        await client.auth.signInWithOtp(
          email: trimmed,
          emailRedirectTo: 'campussignal://login-callback',
        );
      } else {
        await Future.delayed(const Duration(milliseconds: 600));
      }

      state = state.copyWith(
        isLoading: false,
        isOtpSent: true,
        email: trimmed,
        resendCountdown: 60,
        successMessage: 'OTP sent to $trimmed',
      );
      _startCountdown();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to send OTP: ${e.toString()}',
      );
      return false;
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.resendCountdown <= 1) {
        timer.cancel();
        state = state.copyWith(resendCountdown: 0);
      } else {
        state = state.copyWith(resendCountdown: state.resendCountdown - 1);
      }
    });
  }

  Future<bool> verifyOtp(String token) async {
    final email = state.email;
    if (email == null || email.isEmpty) {
      state = state.copyWith(errorMessage: 'No email address registered');
      return false;
    }

    if (token.trim().length != 6) {
      state = state.copyWith(errorMessage: 'Please enter a valid 6-digit OTP code');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final client = SupabaseConfig.client;
      if (client != null && SupabaseConfig.isConfigured) {
        final res = await client.auth.verifyOTP(
          email: email,
          token: token.trim(),
          type: OtpType.email,
        );

        if (res.user != null) {
          await _fetchProfile(res.user!.id, email);
          state = state.copyWith(
            isLoading: false,
            isAuthenticated: true,
            isOtpSent: false,
          );
          if (state.profile != null) {
            await _persistAuth(state.profile!, email);
          }
          return true;
        }
      } else {
        // Mock Verification
        await Future.delayed(const Duration(milliseconds: 700));
        final mockProfile = kDefaultProfile.copyWith(
          collegeEmail: email,
        );

        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          isOtpSent: false,
          profile: mockProfile,
        );
        await _persistAuth(mockProfile, email);
        return true;
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Invalid OTP code. Please verify and try again.',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Verification failed: ${e.toString()}',
      );
      return false;
    }
  }

  /// Instant Development / Preview Bypass Mode
  void bypassSignIn({String email = 'aarav.sharma@sxuk.edu.in'}) async {
    final profile = kDefaultProfile.copyWith(
      collegeEmail: email,
    );

    state = state.copyWith(
      isAuthenticated: true,
      email: email,
      profile: profile,
      isOtpSent: false,
      isLoading: false,
      clearError: true,
    );
    await _persistAuth(profile, email);
  }

  Future<void> updateProfile(ProfileModel updatedProfile) async {
    final client = SupabaseConfig.client;
    final currentSupabaseUserId = client?.auth.currentUser?.id;
    final effectiveProfile = (currentSupabaseUserId != null && updatedProfile.id != currentSupabaseUserId)
        ? updatedProfile.copyWith(id: currentSupabaseUserId)
        : updatedProfile;

    state = state.copyWith(
      isAuthenticated: true,
      profile: effectiveProfile,
      email: effectiveProfile.collegeEmail ?? state.email,
    );
    await _persistAuth(effectiveProfile, state.email ?? effectiveProfile.collegeEmail);

    if (client != null && SupabaseConfig.isConfigured) {
      try {
        await client.from('profiles').upsert(effectiveProfile.toSupabaseJson());
      } catch (e) {
        debugPrint('Error persisting profile to Supabase: $e');
      }
    }
  }

  void resetOtpFlow() {
    _countdownTimer?.cancel();
    state = state.copyWith(
      isOtpSent: false,
      resendCountdown: 0,
      clearError: true,
      clearSuccess: true,
    );
  }

  Future<void> signOut() async {
    _countdownTimer?.cancel();
    await _clearPersistedAuth();

    try {
      await _googleSignIn.signOut();
    } catch (_) {}

    try {
      await fb.FirebaseAuth.instance.signOut();
    } catch (_) {}

    final client = SupabaseConfig.client;
    if (client != null && SupabaseConfig.isConfigured) {
      try {
        await client.auth.signOut();
      } catch (e) {
        debugPrint('Error signing out: $e');
      }
    }
    state = const AuthState();
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
