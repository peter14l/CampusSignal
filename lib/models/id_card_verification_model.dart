enum VerificationStatus {
  unverified,
  pending,
  approved,
  rejected,
  expired;

  String get dbValue => name;

  static VerificationStatus fromString(dynamic value) {
    if (value == null) return VerificationStatus.unverified;
    final str = value.toString().toLowerCase().trim();
    for (final status in VerificationStatus.values) {
      if (status.name.toLowerCase() == str) return status;
    }
    return VerificationStatus.unverified;
  }
}

enum DocumentType {
  collegeIdCard('college_id_card', 'College ID Card'),
  feeReceipt('fee_receipt', 'Semester Fee Receipt'),
  bonafideCertificate('bonafide_certificate', 'Bonafide Certificate'),
  libraryCard('library_card', 'Library Card');

  final String code;
  final String label;

  const DocumentType(this.code, this.label);

  static DocumentType fromString(dynamic value) {
    if (value == null) return DocumentType.collegeIdCard;
    final str = value.toString().toLowerCase().trim();
    for (final doc in DocumentType.values) {
      if (doc.code == str || doc.name.toLowerCase() == str) return doc;
    }
    return DocumentType.collegeIdCard;
  }
}

enum RejectionCode {
  blurryUnreadable('blurry_unreadable', 'Blurry / Unreadable photo'),
  wrongCollege('wrong_college', 'Institutional mismatch (Wrong college)'),
  nameMismatch('name_mismatch', 'Name on card does not match profile'),
  expiredCard('expired_card', 'Expired document / Old academic session'),
  duplicateRollNumber('duplicate_roll_number', 'Roll number already claimed by another user'),
  tamperedImage('tampered_image', 'Image appears edited or tampered'),
  other('other', 'Other administrative reason');

  final String code;
  final String description;

  const RejectionCode(this.code, this.description);

  static RejectionCode? fromString(dynamic value) {
    if (value == null) return null;
    final str = value.toString().toLowerCase().trim();
    for (final r in RejectionCode.values) {
      if (r.code == str || r.name.toLowerCase() == str) return r;
    }
    return null;
  }
}

enum VerificationMethod {
  automatedOcr('automated_ocr', 'Automated Gemini OCR'),
  manualFaculty('manual_faculty', 'Faculty / Dean Review'),
  hybrid('hybrid', 'Hybrid (OCR + Manual Approval)');

  final String code;
  final String label;

  const VerificationMethod(this.code, this.label);

  static VerificationMethod fromString(dynamic value) {
    if (value == null) return VerificationMethod.automatedOcr;
    final str = value.toString().toLowerCase().trim();
    for (final m in VerificationMethod.values) {
      if (m.code == str || m.name.toLowerCase() == str) return m;
    }
    return VerificationMethod.automatedOcr;
  }
}

/// Result returned from Gemini OCR analysis on student ID / institutional document
class IdCardOcrResult {
  final String extractedName;
  final String extractedRoll;
  final String extractedCollege;
  final String? extractedDepartment;
  final String? extractedAcademicYear;
  final double confidence;
  final bool collegeMatched;
  final bool nameMatched;
  final bool isAutoApproved;
  final String summaryFeedback;
  final Map<String, dynamic> rawPayload;

  const IdCardOcrResult({
    required this.extractedName,
    required this.extractedRoll,
    required this.extractedCollege,
    this.extractedDepartment,
    this.extractedAcademicYear,
    this.confidence = 0.0,
    this.collegeMatched = false,
    this.nameMatched = false,
    this.isAutoApproved = false,
    this.summaryFeedback = '',
    this.rawPayload = const {},
  });

  factory IdCardOcrResult.fromJson(Map<String, dynamic> json) {
    final conf = (json['confidence'] is num)
        ? (json['confidence'] as num).toDouble()
        : double.tryParse(json['confidence']?.toString() ?? '0.0') ?? 0.0;

    return IdCardOcrResult(
      extractedName: json['extractedName']?.toString().trim() ??
          json['name']?.toString().trim() ??
          '',
      extractedRoll: json['extractedRoll']?.toString().trim() ??
          json['rollNumber']?.toString().trim() ??
          '',
      extractedCollege: json['extractedCollege']?.toString().trim() ??
          json['college']?.toString().trim() ??
          '',
      extractedDepartment: json['extractedDepartment']?.toString().trim() ??
          json['department']?.toString().trim(),
      extractedAcademicYear: json['extractedAcademicYear']?.toString().trim() ??
          json['academicYear']?.toString().trim(),
      confidence: conf,
      collegeMatched: json['collegeMatched'] == true,
      nameMatched: json['nameMatched'] == true,
      isAutoApproved: json['isAutoApproved'] == true,
      summaryFeedback: json['summaryFeedback']?.toString() ?? '',
      rawPayload: (json['rawPayload'] is Map)
          ? Map<String, dynamic>.from(json['rawPayload'] as Map)
          : json,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'extractedName': extractedName,
      'extractedRoll': extractedRoll,
      'extractedCollege': extractedCollege,
      'extractedDepartment': extractedDepartment,
      'extractedAcademicYear': extractedAcademicYear,
      'confidence': confidence,
      'collegeMatched': collegeMatched,
      'nameMatched': nameMatched,
      'isAutoApproved': isAutoApproved,
      'summaryFeedback': summaryFeedback,
      'rawPayload': rawPayload,
    };
  }
}

/// Master Student Verification model adhering to Dean's Governance and DPDP 2023
class StudentVerificationModel {
  final String id;
  final String userId;
  final String collegeId;
  final DocumentType documentType;
  final String fullNameOnCard;
  final String rollNumber;
  final String? department;
  final String? academicYear;
  final String idCardFrontUrl;
  final String? idCardBackUrl;
  final String? storagePath;
  final VerificationStatus status;
  final VerificationMethod verificationMethod;
  final double ocrConfidence;
  final Map<String, dynamic> ocrRawPayload;
  final bool ocrCollegeMatched;
  final bool ocrNameMatched;
  final String? ocrExtractedRoll;
  final String? ocrExtractedCollege;
  final String? rejectionReason;
  final RejectionCode? rejectionCode;
  final String? reviewerId;
  final String? reviewerNotes;
  final DateTime? reviewedAt;
  final DateTime? verifiedAt;
  final DateTime? expiresAt;
  final int reverificationCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StudentVerificationModel({
    required this.id,
    required this.userId,
    required this.collegeId,
    this.documentType = DocumentType.collegeIdCard,
    required this.fullNameOnCard,
    required this.rollNumber,
    this.department,
    this.academicYear,
    required this.idCardFrontUrl,
    this.idCardBackUrl,
    this.storagePath,
    this.status = VerificationStatus.pending,
    this.verificationMethod = VerificationMethod.automatedOcr,
    this.ocrConfidence = 0.000,
    this.ocrRawPayload = const {},
    this.ocrCollegeMatched = false,
    this.ocrNameMatched = false,
    this.ocrExtractedRoll,
    this.ocrExtractedCollege,
    this.rejectionReason,
    this.rejectionCode,
    this.reviewerId,
    this.reviewerNotes,
    this.reviewedAt,
    this.verifiedAt,
    this.expiresAt,
    this.reverificationCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  /// Expiration calculations
  bool get isApproved => status == VerificationStatus.approved;
  bool get isPending => status == VerificationStatus.pending;
  bool get isRejected => status == VerificationStatus.rejected;

  bool get isExpired {
    if (status == VerificationStatus.expired) return true;
    if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) return true;
    return false;
  }

  int get daysUntilExpiration {
    if (expiresAt == null) return 0;
    final diff = expiresAt!.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }

  bool get isGraduationBound {
    if (expiresAt == null) return false;
    // Standard Indian collegiate academic session concludes June 30th
    return expiresAt!.month == 6 && expiresAt!.day == 30;
  }

  /// Calculates academic expiration:
  /// Standard grant is 365 days, or June 30th of the graduation year (whichever is earlier).
  static DateTime computeAcademicExpiration({
    DateTime? fromDate,
    DateTime? sessionEndDate,
  }) {
    final baseDate = fromDate ?? DateTime.now();
    final defaultOneYear = baseDate.add(const Duration(days: 365));

    if (sessionEndDate != null) {
      return defaultOneYear.isBefore(sessionEndDate)
          ? defaultOneYear
          : sessionEndDate;
    }
    return defaultOneYear;
  }

  factory StudentVerificationModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      final str = value.toString().trim();
      if (str.isEmpty || str == 'null') return null;
      return DateTime.tryParse(str);
    }

    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? 0;
    }

    Map<String, dynamic> parsePayload(dynamic value) {
      if (value is Map<String, dynamic>) return value;
      if (value is Map) return Map<String, dynamic>.from(value);
      return const {};
    }

    return StudentVerificationModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      collegeId: json['college_id']?.toString() ?? json['collegeId']?.toString() ?? 'sxuk',
      documentType: DocumentType.fromString(json['document_type'] ?? json['documentType']),
      fullNameOnCard: json['full_name_on_card']?.toString() ??
          json['fullNameOnCard']?.toString() ??
          json['name']?.toString() ??
          '',
      rollNumber: json['roll_number']?.toString() ?? json['rollNumber']?.toString() ?? '',
      department: json['department']?.toString(),
      academicYear: json['academic_year']?.toString() ?? json['academicYear']?.toString(),
      idCardFrontUrl: json['id_card_front_url']?.toString() ??
          json['idCardFrontUrl']?.toString() ??
          '',
      idCardBackUrl: json['id_card_back_url']?.toString() ?? json['idCardBackUrl']?.toString(),
      storagePath: json['storage_path']?.toString() ?? json['storagePath']?.toString(),
      status: VerificationStatus.fromString(json['status']),
      verificationMethod: VerificationMethod.fromString(
        json['verification_method'] ?? json['verificationMethod'],
      ),
      ocrConfidence: parseDouble(json['ocr_confidence'] ?? json['ocrConfidence']),
      ocrRawPayload: parsePayload(json['ocr_raw_payload'] ?? json['ocrRawPayload']),
      ocrCollegeMatched: json['ocr_college_matched'] == true || json['ocrCollegeMatched'] == true,
      ocrNameMatched: json['ocr_name_matched'] == true || json['ocrNameMatched'] == true,
      ocrExtractedRoll: json['ocr_extracted_roll']?.toString() ?? json['ocrExtractedRoll']?.toString(),
      ocrExtractedCollege: json['ocr_extracted_college']?.toString() ?? json['ocrExtractedCollege']?.toString(),
      rejectionReason: json['rejection_reason']?.toString() ?? json['rejectionReason']?.toString(),
      rejectionCode: RejectionCode.fromString(json['rejection_code'] ?? json['rejectionCode']),
      reviewerId: json['reviewer_id']?.toString() ?? json['reviewerId']?.toString(),
      reviewerNotes: json['reviewer_notes']?.toString() ?? json['reviewerNotes']?.toString(),
      reviewedAt: parseDate(json['reviewed_at'] ?? json['reviewedAt']),
      verifiedAt: parseDate(json['verified_at'] ?? json['verifiedAt']),
      expiresAt: parseDate(json['expires_at'] ?? json['expiresAt']),
      reverificationCount: parseInt(json['reverification_count'] ?? json['reverificationCount']),
      createdAt: parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: parseDate(json['updated_at'] ?? json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'college_id': collegeId,
      'document_type': documentType.code,
      'full_name_on_card': fullNameOnCard,
      'roll_number': rollNumber,
      'department': department,
      'academic_year': academicYear,
      'id_card_front_url': idCardFrontUrl,
      'id_card_back_url': idCardBackUrl,
      'storage_path': storagePath,
      'status': status.name,
      'verification_method': verificationMethod.code,
      'ocr_confidence': ocrConfidence,
      'ocr_raw_payload': ocrRawPayload,
      'ocr_college_matched': ocrCollegeMatched,
      'ocr_name_matched': ocrNameMatched,
      'ocr_extracted_roll': ocrExtractedRoll,
      'ocr_extracted_college': ocrExtractedCollege,
      'rejection_reason': rejectionReason,
      'rejection_code': rejectionCode?.code,
      'reviewer_id': reviewerId,
      'reviewer_notes': reviewerNotes,
      'reviewed_at': reviewedAt?.toIso8601String(),
      'verified_at': verifiedAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'reverification_count': reverificationCount,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toSupabaseJson() {
    final map = <String, dynamic>{
      'id': id,
      'user_id': userId,
      'college_id': collegeId,
      'document_type': documentType.code,
      'full_name_on_card': fullNameOnCard,
      'roll_number': rollNumber,
      'id_card_front_url': idCardFrontUrl,
      'status': status.name,
      'verification_method': verificationMethod.code,
      'ocr_confidence': ocrConfidence,
      'ocr_raw_payload': ocrRawPayload,
      'ocr_college_matched': ocrCollegeMatched,
      'ocr_name_matched': ocrNameMatched,
      'reverification_count': reverificationCount,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (department != null) map['department'] = department;
    if (academicYear != null) map['academic_year'] = academicYear;
    if (idCardBackUrl != null) map['id_card_back_url'] = idCardBackUrl;
    if (storagePath != null) map['storage_path'] = storagePath;
    if (ocrExtractedRoll != null) map['ocr_extracted_roll'] = ocrExtractedRoll;
    if (ocrExtractedCollege != null) map['ocr_extracted_college'] = ocrExtractedCollege;
    if (rejectionReason != null) map['rejection_reason'] = rejectionReason;
    if (rejectionCode != null) map['rejection_code'] = rejectionCode!.code;
    if (reviewerId != null) map['reviewer_id'] = reviewerId;
    if (reviewerNotes != null) map['reviewer_notes'] = reviewerNotes;
    if (reviewedAt != null) map['reviewed_at'] = reviewedAt!.toIso8601String();
    if (verifiedAt != null) map['verified_at'] = verifiedAt!.toIso8601String();
    if (expiresAt != null) map['expires_at'] = expiresAt!.toIso8601String();
    if (createdAt != null) map['created_at'] = createdAt!.toIso8601String();

    return map;
  }

  StudentVerificationModel copyWith({
    String? id,
    String? userId,
    String? collegeId,
    DocumentType? documentType,
    String? fullNameOnCard,
    String? rollNumber,
    String? department,
    String? academicYear,
    String? idCardFrontUrl,
    String? idCardBackUrl,
    String? storagePath,
    VerificationStatus? status,
    VerificationMethod? verificationMethod,
    double? ocrConfidence,
    Map<String, dynamic>? ocrRawPayload,
    bool? ocrCollegeMatched,
    bool? ocrNameMatched,
    String? ocrExtractedRoll,
    String? ocrExtractedCollege,
    String? rejectionReason,
    RejectionCode? rejectionCode,
    String? reviewerId,
    String? reviewerNotes,
    DateTime? reviewedAt,
    DateTime? verifiedAt,
    DateTime? expiresAt,
    int? reverificationCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudentVerificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      collegeId: collegeId ?? this.collegeId,
      documentType: documentType ?? this.documentType,
      fullNameOnCard: fullNameOnCard ?? this.fullNameOnCard,
      rollNumber: rollNumber ?? this.rollNumber,
      department: department ?? this.department,
      academicYear: academicYear ?? this.academicYear,
      idCardFrontUrl: idCardFrontUrl ?? this.idCardFrontUrl,
      idCardBackUrl: idCardBackUrl ?? this.idCardBackUrl,
      storagePath: storagePath ?? this.storagePath,
      status: status ?? this.status,
      verificationMethod: verificationMethod ?? this.verificationMethod,
      ocrConfidence: ocrConfidence ?? this.ocrConfidence,
      ocrRawPayload: ocrRawPayload ?? this.ocrRawPayload,
      ocrCollegeMatched: ocrCollegeMatched ?? this.ocrCollegeMatched,
      ocrNameMatched: ocrNameMatched ?? this.ocrNameMatched,
      ocrExtractedRoll: ocrExtractedRoll ?? this.ocrExtractedRoll,
      ocrExtractedCollege: ocrExtractedCollege ?? this.ocrExtractedCollege,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      rejectionCode: rejectionCode ?? this.rejectionCode,
      reviewerId: reviewerId ?? this.reviewerId,
      reviewerNotes: reviewerNotes ?? this.reviewerNotes,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      reverificationCount: reverificationCount ?? this.reverificationCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentVerificationModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
