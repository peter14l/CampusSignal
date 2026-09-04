import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'core/storage/shared_preferences_provider.dart';
import 'core/supabase/supabase_config.dart';
import 'firebase_options.dart';

Future<void> _initFirebase() async {
  try {
    if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }
}

Future<void> _loadDotEnv() async {
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('.env notice: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable true edge-to-edge system UI (non-blocking)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
      systemStatusBarContrastEnforced: false,
    ),
  );

  // Load env config first, then bootstrap SharedPreferences, Firebase and Supabase concurrently
  await _loadDotEnv();

  final results = await Future.wait([
    SharedPreferences.getInstance(),
    _initFirebase(),
    SupabaseConfig.initialize(),
  ]);

  final sharedPreferences = results[0] as SharedPreferences;

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const CampusSignalApp(),
    ),
  );
}
