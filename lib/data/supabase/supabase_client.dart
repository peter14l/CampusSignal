import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase/supabase_config.dart';

/// Initializes the global Supabase singleton safely.
Future<Supabase?> initSupabase({
  String? url,
  String? anonKey,
}) async {
  final supabaseUrl = url ?? SupabaseConfig.url;
  final supabaseAnonKey = anonKey ?? SupabaseConfig.anonKey;

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    debugPrint('Supabase skipped: No environment credentials provided.');
    return null;
  }

  try {
    return await Supabase.initialize(
      url: supabaseUrl,
      // ignore: deprecated_member_use
      anonKey: supabaseAnonKey,
      debug: kDebugMode,
    );
  } catch (e) {
    debugPrint('Supabase initialization warning/error: $e');
    try {
      return Supabase.instance;
    } catch (_) {
      return null;
    }
  }
}

/// Provider for the SupabaseClient instance.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  try {
    return Supabase.instance.client;
  } catch (_) {
    // Return an unauthenticated standalone client if needed for mock fallback
    return SupabaseClient(
      SupabaseConfig.url.isNotEmpty ? SupabaseConfig.url : 'https://placeholder.supabase.co',
      SupabaseConfig.anonKey.isNotEmpty ? SupabaseConfig.anonKey : 'placeholder-anon-key',
    );
  }
});

/// Provider for the current authenticated user (if any).
final currentUserProvider = Provider<User?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.currentUser;
});

/// StreamProvider that emits auth state updates (sign in, sign out, token refresh).
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});
