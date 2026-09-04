class NotificationModel {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String body;
  final String? eventId;
  final String? customActionUrl;
  final bool read;
  final DateTime? createdAt;
  final Map<String, dynamic> metadata;

  const NotificationModel({
    required this.id,
    this.userId = '',
    this.type = 'general',
    required this.title,
    String? body,
    String? message,
    this.eventId,
    String? actionUrl,
    bool? read,
    bool? isRead,
    DateTime? createdAt,
    DateTime? timestamp,
    this.metadata = const {},
  })  : body = body ?? message ?? '',
        customActionUrl = actionUrl,
        read = isRead ?? read ?? false,
        createdAt = createdAt ?? timestamp;

  factory NotificationModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const NotificationModel(
        id: '',
        userId: '',
        title: '',
        body: '',
      );
    }

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    bool parseBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) return value.toLowerCase() == 'true' || value == '1';
      return false;
    }

    Map<String, dynamic> parseMetadata(dynamic value) {
      if (value is Map<String, dynamic>) return value;
      if (value is Map) {
        return value.map((k, v) => MapEntry(k.toString(), v));
      }
      return const {};
    }

    return NotificationModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      type: json['type']?.toString() ?? 'general',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? json['message']?.toString() ?? '',
      eventId: json['event_id']?.toString() ?? json['eventId']?.toString(),
      actionUrl: json['action_url']?.toString() ?? json['actionUrl']?.toString(),
      read: parseBool(json['read'] ?? json['is_read'] ?? json['isRead']),
      createdAt: parseDate(json['created_at'] ?? json['createdAt'] ?? json['timestamp']),
      metadata: parseMetadata(json['metadata']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'title': title,
      'body': body,
      'event_id': eventId,
      'action_url': actionUrl,
      'read': read,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      'metadata': metadata,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    String? body,
    String? message,
    String? eventId,
    String? actionUrl,
    bool? read,
    bool? isRead,
    DateTime? createdAt,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? message ?? this.body,
      eventId: eventId ?? this.eventId,
      actionUrl: actionUrl ?? customActionUrl,
      read: isRead ?? read ?? this.read,
      createdAt: createdAt ?? timestamp ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isRead => read;
  String get message => body;
  DateTime get timestamp => createdAt ?? DateTime.now();

  String? get actionUrl {
    if (customActionUrl != null && customActionUrl!.isNotEmpty) {
      return customActionUrl;
    }
    if (eventId != null && eventId!.isNotEmpty) {
      return '/event/$eventId';
    }
    return null;
  }

  bool get isToday {
    final now = DateTime.now();
    final dt = createdAt ?? now;
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }

  String get timeAgoLabel {
    if (createdAt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(createdAt!);

    if (diff.isNegative || diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24 && isToday) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1 || (diff.inHours < 48 && !isToday)) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Backward compatibility alias
typedef NotificationItem = NotificationModel;
