import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/shared_preferences_provider.dart';

class ThemeSettingsState {
  final ThemeMode themeMode;
  final bool useMaterialYou;
  final bool pushNotificationsEnabled;
  final bool deadlineAlertsEnabled;
  final bool eventRemindersEnabled;

  const ThemeSettingsState({
    this.themeMode = ThemeMode.system,
    this.useMaterialYou = false,
    this.pushNotificationsEnabled = true,
    this.deadlineAlertsEnabled = true,
    this.eventRemindersEnabled = true,
  });

  ThemeSettingsState copyWith({
    ThemeMode? themeMode,
    bool? useMaterialYou,
    bool? pushNotificationsEnabled,
    bool? deadlineAlertsEnabled,
    bool? eventRemindersEnabled,
  }) {
    return ThemeSettingsState(
      themeMode: themeMode ?? this.themeMode,
      useMaterialYou: useMaterialYou ?? this.useMaterialYou,
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      deadlineAlertsEnabled:
          deadlineAlertsEnabled ?? this.deadlineAlertsEnabled,
      eventRemindersEnabled:
          eventRemindersEnabled ?? this.eventRemindersEnabled,
    );
  }
}

class ThemeController extends Notifier<ThemeSettingsState> {
  static const String _keyThemeMode = 'campussignal_theme_mode';
  static const String _keyMaterialYou = 'campussignal_material_you';
  static const String _keyPushNotifs = 'campussignal_push_notifs';
  static const String _keyDeadlineAlerts = 'campussignal_deadline_alerts';
  static const String _keyEventReminders = 'campussignal_event_reminders';

  @override
  ThemeSettingsState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final modeIndex = prefs.getInt(_keyThemeMode);
    final useMaterialYou = prefs.getBool(_keyMaterialYou) ?? false;
    final pushNotifs = prefs.getBool(_keyPushNotifs) ?? true;
    final deadlineAlerts = prefs.getBool(_keyDeadlineAlerts) ?? true;
    final eventReminders = prefs.getBool(_keyEventReminders) ?? true;

    ThemeMode mode = ThemeMode.system;
    if (modeIndex != null && modeIndex >= 0 && modeIndex < ThemeMode.values.length) {
      mode = ThemeMode.values[modeIndex];
    }

    return ThemeSettingsState(
      themeMode: mode,
      useMaterialYou: useMaterialYou,
      pushNotificationsEnabled: pushNotifs,
      deadlineAlertsEnabled: deadlineAlerts,
      eventRemindersEnabled: eventReminders,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setInt(_keyThemeMode, mode.index);
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
  }

  Future<void> toggleMaterialYou(bool enabled) async {
    state = state.copyWith(useMaterialYou: enabled);
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setBool(_keyMaterialYou, enabled);
    } catch (e) {
      debugPrint('Error saving Material You preference: $e');
    }
  }

  Future<void> togglePushNotifications(bool enabled) async {
    state = state.copyWith(pushNotificationsEnabled: enabled);
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setBool(_keyPushNotifs, enabled);
    } catch (e) {
      debugPrint('Error saving push notification preference: $e');
    }
  }

  Future<void> toggleDeadlineAlerts(bool enabled) async {
    state = state.copyWith(deadlineAlertsEnabled: enabled);
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setBool(_keyDeadlineAlerts, enabled);
    } catch (e) {
      debugPrint('Error saving deadline alert preference: $e');
    }
  }

  Future<void> toggleEventReminders(bool enabled) async {
    state = state.copyWith(eventRemindersEnabled: enabled);
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setBool(_keyEventReminders, enabled);
    } catch (e) {
      debugPrint('Error saving event reminder preference: $e');
    }
  }
}

final themeControllerProvider =
    NotifierProvider<ThemeController, ThemeSettingsState>(
  ThemeController.new,
);
