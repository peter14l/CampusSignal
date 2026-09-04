import 'event_model.dart';

class ReminderModel {
  final String id;
  final String userId;
  final String eventId;
  final DateTime remindAt;
  final bool fired;
  final EventModel? event;

  const ReminderModel({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.remindAt,
    this.fired = false,
    this.event,
  });

  factory ReminderModel.fromJson(Map<String, dynamic>? json, {EventModel? event}) {
    if (json == null) {
      return ReminderModel(
        id: '',
        userId: '',
        eventId: '',
        remindAt: DateTime.now(),
      );
    }

    DateTime parseDate(dynamic value) {
      if (value is DateTime) return value;
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    bool parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) return value.toLowerCase() == 'true' || value == '1';
      return false;
    }

    return ReminderModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      eventId: json['event_id']?.toString() ?? json['eventId']?.toString() ?? '',
      remindAt: parseDate(json['remind_at'] ?? json['remindAt']),
      fired: parseBool(json['fired']),
      event: event ?? (json['event'] != null ? EventModel.fromJson(json['event']) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'event_id': eventId,
      'remind_at': remindAt.toIso8601String(),
      'fired': fired,
      if (event != null) 'event': event!.toJson(),
    };
  }

  ReminderModel copyWith({
    String? id,
    String? userId,
    String? eventId,
    DateTime? remindAt,
    bool? fired,
    EventModel? event,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      eventId: eventId ?? this.eventId,
      remindAt: remindAt ?? this.remindAt,
      fired: fired ?? this.fired,
      event: event ?? this.event,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
