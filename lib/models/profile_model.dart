class ProfileModel {
  final String id;
  final String fullName;
  final String? collegeEmail;
  final String? branch;
  final int? year;
  final int? semester;
  final String? avatarUrl;
  final List<String> interests;
  final List<String> skills;
  final Map<String, dynamic> metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProfileModel({
    required this.id,
    this.fullName = '',
    this.collegeEmail,
    this.branch,
    this.year,
    this.semester,
    this.avatarUrl,
    this.interests = const [],
    this.skills = const [],
    this.metadata = const {},
    this.createdAt,
    this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ProfileModel(id: '');
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

    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    Map<String, dynamic> parseMetadata(dynamic value) {
      if (value is Map<String, dynamic>) return value;
      if (value is Map) {
        return value.map((k, v) => MapEntry(k.toString(), v));
      }
      return const {};
    }

    final metadataMap = parseMetadata(json['metadata']);
    final parsedYear = parseInt(json['year'] ?? json['grad_year'] ?? json['academic_year'] ?? metadataMap['year']);
    final parsedSem = parseInt(json['semester'] ?? json['sem'] ?? metadataMap['semester']);
    final parsedAvatar = json['avatar_url']?.toString() ??
        json['avatarUrl']?.toString() ??
        json['photo_url']?.toString() ??
        metadataMap['avatar_url']?.toString() ??
        metadataMap['avatarUrl']?.toString();

    return ProfileModel(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ??
          json['fullName']?.toString() ??
          json['name']?.toString() ??
          '',
      collegeEmail: json['college_email']?.toString() ??
          json['collegeEmail']?.toString() ??
          json['email']?.toString(),
      branch: json['branch']?.toString() ?? json['department']?.toString() ?? metadataMap['branch']?.toString(),
      year: parsedYear ?? (parsedSem != null ? ((parsedSem + 1) ~/ 2) : null),
      semester: parsedSem ?? (parsedYear != null ? ((parsedYear * 2) - 1) : null),
      avatarUrl: parsedAvatar,
      interests: parseStringList(json['interests'] ?? metadataMap['interests']),
      skills: parseStringList(json['skills'] ?? metadataMap['skills']),
      metadata: metadataMap,
      createdAt: parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: parseDate(json['updated_at'] ?? json['updatedAt']),
    );
  }

  /// Full JSON map for local cache (SharedPreferences)
  Map<String, dynamic> toJson() {
    final mergedMetadata = Map<String, dynamic>.from(metadata);
    if (semester != null) mergedMetadata['semester'] = semester;
    if (year != null) mergedMetadata['year'] = year;
    if (avatarUrl != null && avatarUrl!.isNotEmpty) mergedMetadata['avatar_url'] = avatarUrl;

    return {
      'id': id,
      'full_name': fullName,
      'college_email': collegeEmail,
      'branch': branch,
      'year': year ?? (semester != null ? ((semester! + 1) ~/ 2) : null),
      'semester': semester ?? (year != null ? ((year! * 2) - 1) : null),
      'avatar_url': avatarUrl,
      'interests': interests,
      'skills': skills,
      'metadata': mergedMetadata,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  /// Supabase public.profiles schema-compliant payload
  Map<String, dynamic> toSupabaseJson() {
    final mergedMetadata = Map<String, dynamic>.from(metadata);
    if (semester != null) mergedMetadata['semester'] = semester;
    if (year != null) mergedMetadata['year'] = year;
    if (avatarUrl != null && avatarUrl!.isNotEmpty) mergedMetadata['avatar_url'] = avatarUrl;

    return {
      'id': id,
      'full_name': fullName,
      'college_email': collegeEmail,
      'branch': branch,
      'year': year ?? (semester != null ? ((semester! + 1) ~/ 2) : null),
      'semester': semester,
      'interests': interests,
      'skills': skills,
      'metadata': mergedMetadata,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  ProfileModel copyWith({
    String? id,
    String? fullName,
    String? collegeEmail,
    String? branch,
    int? year,
    int? semester,
    String? avatarUrl,
    List<String>? interests,
    List<String>? skills,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      collegeEmail: collegeEmail ?? this.collegeEmail,
      branch: branch ?? this.branch,
      year: year ?? this.year,
      semester: semester ?? this.semester,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      interests: interests ?? this.interests,
      skills: skills ?? this.skills,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get semesterLabel {
    if (semester != null && semester! > 0) {
      return 'Semester $semester';
    }
    if (year != null && year! > 0) {
      return 'Year $year';
    }
    return 'SXUK Student';
  }

  String get departmentLabel => branch ?? 'Computer Science';

  bool get isOnboardingComplete {
    return fullName.trim().isNotEmpty &&
        branch != null &&
        branch!.trim().isNotEmpty;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
