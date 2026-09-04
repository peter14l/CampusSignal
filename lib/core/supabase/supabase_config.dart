import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Central Supabase environment configuration and client accessor
class SupabaseConfig {
  SupabaseConfig._();

  /// Supabase project URL loaded securely from compile-time environment or .env
  static String get url {
    const envUrl = String.fromEnvironment('SUPABASE_URL');
    if (envUrl.isNotEmpty) return envUrl;
    return dotenv.env['SUPABASE_URL'] ?? 'https://ksyvklijnkxfpiasncyr.supabase.co';
  }

  static String get supabaseUrl => url;

  /// Supabase anon public API key loaded securely from compile-time environment or .env
  static String get anonKey {
    const envKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (envKey.isNotEmpty) return envKey;
    return dotenv.env['SUPABASE_ANON_KEY'] ?? 'sb_publishable_VR_FIPoe9sLE4qGVLwF1tg_XW3Xuv9S';
  }

  static String get supabaseAnonKey => anonKey;

  static bool isConfigured = false;

  /// Initialize Supabase with resilient fallback
  static Future<void> initialize() async {
    try {
      final curUrl = url;
      final curKey = anonKey;
      if (curUrl.isNotEmpty &&
          curKey.isNotEmpty &&
          !curUrl.contains('placeholder') &&
          !curUrl.contains('mock')) {
        await Supabase.initialize(
          url: curUrl,
          // ignore: deprecated_member_use
          anonKey: curKey,
          debug: kDebugMode,
          authOptions: const FlutterAuthClientOptions(
            authFlowType: AuthFlowType.pkce,
          ),
        );
        isConfigured = true;
      } else {
        debugPrint('Supabase initialized in mock/test bypass mode.');
      }
    } catch (e) {
      debugPrint('Supabase initialization fallback: $e');
      isConfigured = false;
    }
  }

  /// Active Supabase client instance (or null if not configured)
  static SupabaseClient? get client {
    if (isConfigured) {
      return Supabase.instance.client;
    }
    return null;
  }
}
