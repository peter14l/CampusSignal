import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/event_model.dart';

/// Service responsible for dispatching FCM and Native System Push Notifications
class FCMNotificationService {
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  FCMNotificationService() {
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    if (_isInitialized) return;

    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('Notification payload tapped: ${response.payload}');
        },
      );

      _isInitialized = true;
    } catch (e) {
      debugPrint('FCM / Local Notifications Init Fallback: $e');
    }
  }

  /// Broadcasts a native system push notification when an announcement is published
  Future<void> broadcastAnnouncementNotification(EventModel event) async {
    try {
      await _initNotifications();

      final targetLabel = event.isCampusWide
          ? 'Campus-Wide'
          : (event.eligibilityBranches.isNotEmpty
              ? event.eligibilityBranches.first
              : 'SXUK');

      final title = '📢 [$targetLabel] ${event.title}';
      final body = event.description.isNotEmpty
          ? '${event.organizerName}: ${event.description.length > 80 ? '${event.description.substring(0, 80)}...' : event.description}'
          : '${event.organizerName} just published a new opportunity for $targetLabel.';

      const androidDetails = AndroidNotificationDetails(
        'campussignal_announcements_v2',
        'Campus Announcements',
        channelDescription: 'High-priority notifications for new SXUK events, hackathons, and opportunities.',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      await _localNotifications.show(
        id: notificationId,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: event.id,
      );

      debugPrint('FCM Broadcast: Dispatched system notification for "${event.title}" to target [$targetLabel]');
    } catch (e) {
      debugPrint('Error broadcasting FCM announcement notification: $e');
    }
  }
}

final fcmNotificationServiceProvider = Provider<FCMNotificationService>((ref) {
  return FCMNotificationService();
});
