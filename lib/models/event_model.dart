import 'package:intl/intl.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String organizerName;
  final String? organizerClubId;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final DateTime? deadlineAt;
  final String? venue;
  final String? format;
  final String? eligibilityText;
  final List<String> eligibilityYears;
  final List<String> eligibilityBranches;
  final String? teamSizeText;
  final String? applyUrl;
  final String? sourceUrl;
  final String? posterR2Key;
  final String status;
  final Map<String, dynamic> metadata;
  final double? matchScore;
  final List<String> matchedTags;

  const EventModel({
    required this.id,
    required this.title,
    this.description = '',
    this.category = 'General',
    this.organizerName = 'Campus Organizer',
    this.organizerClubId,
    this.startsAt,
    this.endsAt,
    this.deadlineAt,
    this.venue,
    this.format,
    this.eligibilityText,
    this.eligibilityYears = const [],
    this.eligibilityBranches = const [],
    this.teamSizeText,
    this.applyUrl,
    this.sourceUrl,
    this.posterR2Key,
    this.status = 'published',
    this.metadata = const {},
    this.matchScore,
    this.matchedTags = const [],
  });

  /// Defensive JSON deserializer that safely handles nulls, missing keys,
  /// type mismatches, and nested collections.
  factory EventModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const EventModel(id: '', title: 'Untitled Event');
    }

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    List<String> parseStringList(dynamic value) {
      if (value == null) return const [];
      if (value is List) {
        return value
            .where((e) => e != null)
            .map((e) => e.toString().trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }
      if (value is String && value.isNotEmpty) {
        return value
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }
      return const [];
    }

    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    Map<String, dynamic> parseMetadata(dynamic value) {
      if (value is Map<String, dynamic>) return value;
      if (value is Map) {
        return value.map((k, v) => MapEntry(k.toString(), v));
      }
      return const {};
    }

    return EventModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled Event',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      organizerName: json['organizer_name']?.toString() ??
          json['organizerName']?.toString() ??
          'Campus Organizer',
      organizerClubId: json['organizer_club_id']?.toString() ??
          json['organizerClubId']?.toString(),
      startsAt: parseDate(json['starts_at'] ?? json['startsAt']),
      endsAt: parseDate(json['ends_at'] ?? json['endsAt']),
      deadlineAt: parseDate(
          json['deadline_at'] ?? json['deadlineAt'] ?? json['registration_deadline']),
      venue: json['venue']?.toString(),
      format: json['format']?.toString(),
      eligibilityText: json['eligibility_text']?.toString() ??
          json['eligibilityText']?.toString(),
      eligibilityYears: parseStringList(
          json['eligibility_years'] ?? json['eligibilityYears']),
      eligibilityBranches: parseStringList(
          json['eligibility_branches'] ?? json['eligibilityBranches']),
      teamSizeText: json['team_size_text']?.toString() ??
          json['teamSizeText']?.toString(),
      applyUrl: json['apply_url']?.toString() ?? json['applyUrl']?.toString(),
      sourceUrl: json['source_url']?.toString() ?? json['sourceUrl']?.toString(),
      posterR2Key: json['poster_r2_key']?.toString() ??
          json['posterR2Key']?.toString() ??
          json['poster_url']?.toString() ??
          json['posterUrl']?.toString(),
      status: json['status']?.toString() ?? 'published',
      metadata: parseMetadata(json['metadata']),
      matchScore: parseDouble(json['match_score'] ?? json['matchScore']),
      matchedTags: parseStringList(
          json['matched_tags'] ?? json['matchedTags'] ?? json['tags']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'organizer_name': organizerName,
      'organizer_club_id': organizerClubId,
      'starts_at': startsAt?.toIso8601String(),
      'ends_at': endsAt?.toIso8601String(),
      'deadline_at': deadlineAt?.toIso8601String(),
      'venue': venue,
      'format': format,
      'eligibility_text': eligibilityText,
      'eligibility_years': eligibilityYears,
      'eligibility_branches': eligibilityBranches,
      'team_size_text': teamSizeText,
      'apply_url': applyUrl,
      'source_url': sourceUrl,
      'poster_r2_key': posterR2Key,
      'status': status,
      'metadata': metadata,
      'match_score': matchScore,
      'matched_tags': matchedTags,
    };
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? organizerName,
    String? organizerClubId,
    DateTime? startsAt,
    DateTime? endsAt,
    DateTime? deadlineAt,
    String? venue,
    String? format,
    String? eligibilityText,
    List<String>? eligibilityYears,
    List<String>? eligibilityBranches,
    String? teamSizeText,
    String? applyUrl,
    String? sourceUrl,
    String? posterR2Key,
    String? status,
    Map<String, dynamic>? metadata,
    double? matchScore,
    List<String>? matchedTags,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      organizerName: organizerName ?? this.organizerName,
      organizerClubId: organizerClubId ?? this.organizerClubId,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      deadlineAt: deadlineAt ?? this.deadlineAt,
      venue: venue ?? this.venue,
      format: format ?? this.format,
      eligibilityText: eligibilityText ?? this.eligibilityText,
      eligibilityYears: eligibilityYears ?? this.eligibilityYears,
      eligibilityBranches: eligibilityBranches ?? this.eligibilityBranches,
      teamSizeText: teamSizeText ?? this.teamSizeText,
      applyUrl: applyUrl ?? this.applyUrl,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      posterR2Key: posterR2Key ?? this.posterR2Key,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      matchScore: matchScore ?? this.matchScore,
      matchedTags: matchedTags ?? this.matchedTags,
    );
  }

  /// True if deadline is approaching within next 48 hours and is in the future.
  bool get isDeadlineSoon {
    if (deadlineAt == null) return false;
    final now = DateTime.now();
    final difference = deadlineAt!.difference(now);
    return !difference.isNegative && difference.inHours <= 48;
  }

  /// Whether this announcement is visible campus-wide across all departments.
  bool get isCampusWide =>
      eligibilityBranches.isEmpty ||
      eligibilityBranches.contains('All Branches') ||
      eligibilityBranches.contains('All') ||
      eligibilityBranches.contains('Campus-Wide');

  /// Whether this announcement is accessible for a student's specific academic branch.
  bool isTargetedForBranch(String? userBranch) {
    if (isCampusWide) return true;
    if (userBranch == null || userBranch.isEmpty) return true;
    final bLower = userBranch.toLowerCase().trim();
    return eligibilityBranches.any((b) {
      final itemLower = b.toLowerCase().trim();
      return itemLower == bLower ||
          itemLower.contains(bLower) ||
          bLower.contains(itemLower);
    });
  }

  /// Formatted target branches label (e.g. "All Branches" or "CSE, AI, IT").
  String get targetAudienceLabel {
    if (isCampusWide) return 'All Departments (Campus-Wide)';
    if (eligibilityBranches.length == 1) return eligibilityBranches.first;
    return eligibilityBranches.join(', ');
  }

  /// True if deadline has already passed.
  bool get isDeadlinePassed {
    if (deadlineAt == null) return false;
    return deadlineAt!.isBefore(DateTime.now());
  }

  // Static cached date formatters to prevent GC churn during rapid list scrolling
  static final DateFormat _dateFormat = DateFormat('MMM d, yyyy');
  static final DateFormat _shortDateFormat = DateFormat('MMM d');
  static final DateFormat _timeFormat = DateFormat('h:mm a');

  /// Human friendly deadline string (e.g. "Closes in 4 hours", "Closes tomorrow", "Oct 24, 11:59 PM").
  String get deadlineLabel {
    if (deadlineAt == null) return 'No Deadline';
    final now = DateTime.now();
    final diff = deadlineAt!.difference(now);

    if (diff.isNegative) {
      return 'Registration Closed';
    }

    if (diff.inHours < 1) {
      final mins = diff.inMinutes;
      return mins <= 1 ? 'Closes in 1 min' : 'Closes in $mins mins';
    } else if (diff.inHours < 24) {
      return 'Closes in ${diff.inHours}h';
    } else if (diff.inDays == 1) {
      return 'Closes tomorrow';
    } else if (diff.inDays < 7) {
      return 'Closes in ${diff.inDays} days';
    } else {
      return 'Deadline: ${_dateFormat.format(deadlineAt!)}';
    }
  }

  /// Human friendly date range representation.
  String get formattedDateRange {
    if (startsAt == null) return 'Date TBD';
    final start = startsAt!;
    final end = endsAt;

    if (end == null) {
      return '${_dateFormat.format(start)} • ${_timeFormat.format(start)}';
    }

    final isSameDay = start.year == end.year &&
        start.month == end.month &&
        start.day == end.day;

    if (isSameDay) {
      return '${_dateFormat.format(start)} • ${_timeFormat.format(start)} - ${_timeFormat.format(end)}';
    } else {
      return '${_shortDateFormat.format(start)} - ${_dateFormat.format(end)}';
    }
  }

  /// Formatted format (e.g. "Online", "In-Person", "Hybrid").
  String get formattedFormat {
    if (format == null || format!.isEmpty) return 'In-Person';
    final f = format!.toLowerCase().trim();
    if (f == 'online') return 'Online';
    if (f == 'offline' || f == 'in-person' || f == 'in_person') return 'In-Person';
    if (f == 'hybrid') return 'Hybrid';
    return format![0].toUpperCase() + format!.substring(1);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
