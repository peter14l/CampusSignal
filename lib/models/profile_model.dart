enum UserRole {
  student,
  clubLead,
  festAdmin,
  faculty,
  superAdmin,
}

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

  // Pan-India Multi-College, Verification & Moderation fields
  final String? collegeId;
  final String? collegeName;
  final String? collegeShortCode;
  final UserRole role;
  final bool isVerifiedStudent;
  final String? rollNumber;
  final List<String> managedFestIds;
  final List<String> managedClubIds;

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
    this.collegeId = 'sxuk',
    this.collegeName = "St. Xavier's University, Kolkata",
    this.collegeShortCode = 'SXUK',
    this.role = UserRole.student,
    this.isVerifiedStudent = false,
    this.rollNumber,
    this.managedFestIds = const [],
    this.managedClubIds = const [],
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

    UserRole parseRole(dynamic value) {
      if (value == null) return UserRole.student;
      if (value is UserRole) return value;
      final s = value.toString().toLowerCase().trim();
      if (s == 'clublead' || s == 'club_lead') return UserRole.clubLead;
      if (s == 'festadmin' || s == 'fest_admin') return UserRole.festAdmin;
      if (s == 'faculty') return UserRole.faculty;
      if (s == 'superadmin' || s == 'super_admin') return UserRole.superAdmin;
      return UserRole.student;
    }

    final metadataMap = parseMetadata(json['metadata']);
    final parsedYear = parseInt(json['year'] ?? json['grad_year'] ?? json['academic_year'] ?? metadataMap['year']);
    final parsedSem = parseInt(json['semester'] ?? json['sem'] ?? metadataMap['semester']);
    final parsedAvatar = json['avatar_url']?.toString() ??
        json['avatarUrl']?.toString() ??
        json['photo_url']?.toString() ??
        metadataMap['avatar_url']?.toString() ??
        metadataMap['avatarUrl']?.toString();

    final parsedRole = parseRole(json['role'] ?? metadataMap['role']);
    final isVerified = json['is_verified_student'] == true ||
        json['isVerifiedStudent'] == true ||
        metadataMap['is_verified_student'] == true;

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
      collegeId: json['college_id']?.toString() ??
          json['collegeId']?.toString() ??
          metadataMap['college_id']?.toString() ??
          'sxuk',
      collegeName: json['college_name']?.toString() ??
          json['collegeName']?.toString() ??
          metadataMap['college_name']?.toString() ??
          "St. Xavier's University, Kolkata",
      collegeShortCode: json['college_short_code']?.toString() ??
          json['collegeShortCode']?.toString() ??
          metadataMap['college_short_code']?.toString() ??
          'SXUK',
      role: parsedRole,
      isVerifiedStudent: isVerified,
      rollNumber: json['roll_number']?.toString() ??
          json['rollNumber']?.toString() ??
          metadataMap['roll_number']?.toString(),
      managedFestIds: parseStringList(
          json['managed_fest_ids'] ?? json['managedFestIds'] ?? metadataMap['managed_fest_ids']),
      managedClubIds: parseStringList(
          json['managed_club_ids'] ?? json['managedClubIds'] ?? metadataMap['managed_club_ids']),
    );
  }

  /// Full JSON map for local cache (SharedPreferences)
  Map<String, dynamic> toJson() {
    final mergedMetadata = Map<String, dynamic>.from(metadata);
    if (semester != null) mergedMetadata['semester'] = semester;
    if (year != null) mergedMetadata['year'] = year;
    if (avatarUrl != null && avatarUrl!.isNotEmpty) mergedMetadata['avatar_url'] = avatarUrl;
    if (rollNumber != null) mergedMetadata['roll_number'] = rollNumber;
    mergedMetadata['college_id'] = collegeId;
    mergedMetadata['college_short_code'] = collegeShortCode;
    mergedMetadata['is_verified_student'] = isVerifiedStudent;

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
      'college_id': collegeId,
      'college_name': collegeName,
      'college_short_code': collegeShortCode,
      'role': role.name,
      'is_verified_student': isVerifiedStudent,
      'roll_number': rollNumber,
      'managed_fest_ids': managedFestIds,
      'managed_club_ids': managedClubIds,
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
    if (rollNumber != null) mergedMetadata['roll_number'] = rollNumber;
    mergedMetadata['college_id'] = collegeId;
    mergedMetadata['college_short_code'] = collegeShortCode;
    mergedMetadata['is_verified_student'] = isVerifiedStudent;

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
      'college_id': collegeId,
      'college_name': collegeName,
      'college_short_code': collegeShortCode,
      'role': role.name,
      'is_verified_student': isVerifiedStudent,
      'roll_number': rollNumber,
      'managed_fest_ids': managedFestIds,
      'managed_club_ids': managedClubIds,
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
    String? collegeId,
    String? collegeName,
    String? collegeShortCode,
    UserRole? role,
    bool? isVerifiedStudent,
    String? rollNumber,
    List<String>? managedFestIds,
    List<String>? managedClubIds,
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
      collegeId: collegeId ?? this.collegeId,
      collegeName: collegeName ?? this.collegeName,
      collegeShortCode: collegeShortCode ?? this.collegeShortCode,
      role: role ?? this.role,
      isVerifiedStudent: isVerifiedStudent ?? this.isVerifiedStudent,
      rollNumber: rollNumber ?? this.rollNumber,
      managedFestIds: managedFestIds ?? this.managedFestIds,
      managedClubIds: managedClubIds ?? this.managedClubIds,
    );
  }

  /// Whether user has privileged moderation rights over events or fests
  bool get canModerate =>
      role != UserRole.student || managedFestIds.isNotEmpty;

  /// Whether user can publish events directly without going to moderation triage
  bool get canPublishDirectly =>
      role == UserRole.faculty ||
      role == UserRole.clubLead ||
      role == UserRole.festAdmin ||
      role == UserRole.superAdmin;

  String get semesterLabel {
    final collegeTag = collegeShortCode ?? 'SXUK';
    if (semester != null && semester! > 0) {
      return 'Semester $semester';
    }
    if (year != null && year! > 0) {
      return 'Year $year';
    }
    return '$collegeTag Student';
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
