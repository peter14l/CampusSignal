import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase/supabase_config.dart';


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
