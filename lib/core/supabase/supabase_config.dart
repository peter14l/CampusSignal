import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Central Supabase environment configuration and client accessor
class SupabaseConfig {
  SupabaseConfig._();

  /// Supabase project URL loaded securely from .env or compile-time environment
  static String get url =>
      dotenv.env['SUPABASE_URL'] ??
      const String.fromEnvironment('SUPABASE_URL', defaultValue: '');

  static String get supabaseUrl => url;

  /// Supabase anon public API key loaded securely from .env or compile-time environment
  static String get anonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ??
      const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

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
