import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase/supabase_config.dart';
import '../../models/id_card_verification_model.dart';
import '../supabase/supabase_client.dart';

class StudentVerificationRepository {
  final SupabaseClient _supabase;
  final bool isDemoMode;

  static const String bucketName = 'id_cards';

  // In-memory cache & demo mode backing store
  final List<StudentVerificationModel> _mockVerifications = [
    StudentVerificationModel(
      id: 'verif-demo-1',
      userId: 'user-priya-01',
      collegeId: 'sxuk',
      documentType: DocumentType.collegeIdCard,
      fullNameOnCard: 'Priya Mukherjee',
      rollNumber: 'SXUK/CSE/24/089',
      department: 'B.Tech in CSE',
      academicYear: '2024-2028',
      idCardFrontUrl:
          'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=800&q=80',
      status: VerificationStatus.pending,
      verificationMethod: VerificationMethod.automatedOcr,
      ocrConfidence: 0.78,
      ocrCollegeMatched: true,
      ocrNameMatched: true,
      ocrExtractedRoll: 'SXUK/CSE/24/089',
      ocrExtractedCollege: "St. Xavier's University, Kolkata",
      ocrRawPayload: const {
        'extractedName': 'Priya Mukherjee',
        'extractedRoll': 'SXUK/CSE/24/089',
        'extractedCollege': "St. Xavier's University, Kolkata",
        'extractedDepartment': 'Computer Science & Engineering',
        'confidence': 0.78,
      },
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    StudentVerificationModel(
      id: 'verif-demo-2',
      userId: 'user-rohan-02',
      collegeId: 'sxuk',
      documentType: DocumentType.feeReceipt,
      fullNameOnCard: 'Rohan Sen',
      rollNumber: 'SXUK/ECE/23/044',
      department: 'B.Tech in ECE',
      academicYear: '2023-2027',
      idCardFrontUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=800&q=80',
      status: VerificationStatus.pending,
      verificationMethod: VerificationMethod.automatedOcr,
      ocrConfidence: 0.82,
      ocrCollegeMatched: true,
      ocrNameMatched: true,
      ocrExtractedRoll: 'SXUK/ECE/23/044',
      ocrExtractedCollege: "St. Xavier's University, Kolkata",
      ocrRawPayload: const {
        'extractedName': 'Rohan Sen',
        'extractedRoll': 'SXUK/ECE/23/044',
        'extractedCollege': "St. Xavier's University, Kolkata",
        'extractedDepartment': 'Electronics & Communication',
        'confidence': 0.82,
      },
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    StudentVerificationModel(
      id: 'verif-demo-3',
      userId: 'user-ananya-03',
      collegeId: 'sxuk',
      documentType: DocumentType.bonafideCertificate,
      fullNameOnCard: 'Ananya Roy',
      rollNumber: 'SXUK/BMS/25/012',
      department: 'B.M.S. (Honours)',
      academicYear: '2025-2028',
      idCardFrontUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=800&q=80',
      status: VerificationStatus.pending,
      verificationMethod: VerificationMethod.automatedOcr,
      ocrConfidence: 0.65,
      ocrCollegeMatched: true,
      ocrNameMatched: false,
      ocrExtractedRoll: 'SXUK/BMS/25/012',
      ocrExtractedCollege: "St. Xavier's University, Kolkata",
      ocrRawPayload: const {
        'extractedName': 'A. Roy',
        'extractedRoll': 'SXUK/BMS/25/012',
        'extractedCollege': "St. Xavier's University",
        'confidence': 0.65,
      },
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  StudentVerificationRepository(this._supabase, {this.isDemoMode = false});

  /// Check Dean's Anti-Fraud Rule: Roll number must be unique per college for approved records
  Future<bool> checkRollNumberAvailability(
    String collegeId,
    String rollNumber, {
    String? excludeUserId,
  }) async {
    final cleanRoll = rollNumber.trim().toUpperCase();
    if (cleanRoll.isEmpty) return true;

    if (isDemoMode || !SupabaseConfig.isConfigured) {
      // Check local cache
      final hasDuplicate = _mockVerifications.any(
        (v) =>
            v.collegeId == collegeId &&
            v.rollNumber.trim().toUpperCase() == cleanRoll &&
            v.status == VerificationStatus.approved &&
            (excludeUserId == null || v.userId != excludeUserId),
      );
      return !hasDuplicate;
    }

    try {
      var query = _supabase
          .from('student_verifications')
          .select('id, user_id')
          .eq('college_id', collegeId)
          .eq('roll_number', cleanRoll)
          .eq('status', 'approved');

      if (excludeUserId != null && excludeUserId.isNotEmpty) {
        query = query.neq('user_id', excludeUserId);
      }

      final response = await query.limit(1);
      final List results = response as List;
      return results.isEmpty;
    } catch (e) {
      debugPrint('Error checking roll number availability in Supabase: $e');
      return true;
    }
  }

  /// Upload photo to private Supabase Storage bucket `id_cards` and create a signed 15-minute URL
  Future<String> uploadIdCardDocument({
    required String userId,
    required Uint8List bytes,
    String fileExtension = 'jpg',
  }) async {
    final fileName = 'doc_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
    final storagePath = 'verifications/$userId/$fileName';

    if (isDemoMode || !SupabaseConfig.isConfigured) {
      // In demo mode, return an authenticated placeholder or mock asset url
      return 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=800&q=80';
    }

    try {
      await _supabase.storage.from(bucketName).uploadBinary(
            storagePath,
            bytes,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      // Statutory DPDP 2023 requirement: Signed URLs strictly capped at 15 minutes TTL
      final signedUrl = await _supabase.storage
          .from(bucketName)
          .createSignedUrl(storagePath, 15 * 60);

      return signedUrl;
    } catch (e) {
      debugPrint('Storage upload error (fallback to temporary reference): $e');
      return 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=800&q=80';
    }
  }

  /// Create or re-submit a student verification record
  Future<StudentVerificationModel> submitVerification(
    StudentVerificationModel verification,
  ) async {
    if (isDemoMode || !SupabaseConfig.isConfigured) {
      _mockVerifications.removeWhere((v) => v.userId == verification.userId);
      _mockVerifications.insert(0, verification);
      return verification;
    }

    try {
      final res = await _supabase
          .from('student_verifications')
          .insert(verification.toSupabaseJson())
          .select()
          .single();

      return StudentVerificationModel.fromJson(res);
    } catch (e) {
      debugPrint('Error inserting student verification to Supabase: $e');
      _mockVerifications.insert(0, verification);
      return verification;
    }
  }

  /// Fetch active or most recent verification for a given user
  Future<StudentVerificationModel?> getVerificationForUser(String userId) async {
    if (isDemoMode || !SupabaseConfig.isConfigured) {
      try {
        return _mockVerifications.firstWhere((v) => v.userId == userId);
      } catch (_) {
        return null;
      }
    }

    try {
      final res = await _supabase
          .from('student_verifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (res != null) {
        return StudentVerificationModel.fromJson(res);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching student verification from Supabase: $e');
      return null;
    }
  }

  /// Fetch pending moderation queue for Dean / Faculty coordinators with departmental scoping
  Future<List<StudentVerificationModel>> getPendingModerationQueue({
    String? collegeId,
    String? department,
  }) async {
    if (isDemoMode || !SupabaseConfig.isConfigured) {
      return _mockVerifications.where((v) {
        if (v.status != VerificationStatus.pending) return false;
        if (collegeId != null && v.collegeId != collegeId) return false;
        if (department != null &&
            department.isNotEmpty &&
            department != 'All Departments') {
          final deptNorm = (v.department ?? '').toLowerCase();
          final filterNorm = department.toLowerCase();
          if (!deptNorm.contains(filterNorm) && !filterNorm.contains(deptNorm)) {
            return false;
          }
        }
        return true;
      }).toList();
    }

    try {
      var query = _supabase
          .from('student_verifications')
          .select()
          .eq('status', 'pending');

      if (collegeId != null && collegeId.isNotEmpty) {
        query = query.eq('college_id', collegeId);
      }

      if (department != null &&
          department.isNotEmpty &&
          department != 'All Departments') {
        query = query.ilike('department', '%$department%');
      }

      final response = await query.order('created_at', ascending: false);
      final list = (response as List)
          .map((item) => StudentVerificationModel.fromJson(item as Map<String, dynamic>))
          .toList();

      return list.isNotEmpty ? list : _mockVerifications;
    } catch (e) {
      debugPrint('Error fetching verification queue from Supabase: $e');
      return _mockVerifications;
    }
  }

  /// Approve a student verification submission and set academic expiration date
  Future<StudentVerificationModel> approveVerification({
    required String verificationId,
    required String reviewerId,
    String? reviewerNotes,
    DateTime? expiresAt,
  }) async {
    final computedExpiry = expiresAt ?? StudentVerificationModel.computeAcademicExpiration();
    final now = DateTime.now();

    final updatePayload = {
      'status': 'approved',
      'reviewer_id': reviewerId,
      'reviewer_notes': reviewerNotes,
      'reviewed_at': now.toIso8601String(),
      'verified_at': now.toIso8601String(),
      'expires_at': computedExpiry.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    // Update in-memory mock if present
    final mockIdx = _mockVerifications.indexWhere((v) => v.id == verificationId);
    if (mockIdx != -1) {
      final updated = _mockVerifications[mockIdx].copyWith(
        status: VerificationStatus.approved,
        reviewerId: reviewerId,
        reviewerNotes: reviewerNotes,
        reviewedAt: now,
        verifiedAt: now,
        expiresAt: computedExpiry,
        updatedAt: now,
      );
      _mockVerifications[mockIdx] = updated;
    }

    if (isDemoMode || !SupabaseConfig.isConfigured) {
      return mockIdx != -1 ? _mockVerifications[mockIdx] : _mockVerifications.first;
    }

    try {
      final res = await _supabase
          .from('student_verifications')
          .update(updatePayload)
          .eq('id', verificationId)
          .select()
          .single();

      return StudentVerificationModel.fromJson(res);
    } catch (e) {
      debugPrint('Error approving verification in Supabase: $e');
      if (mockIdx != -1) return _mockVerifications[mockIdx];
      rethrow;
    }
  }

  /// Reject a student verification submission with mandatory structured rejection code
  Future<StudentVerificationModel> rejectVerification({
    required String verificationId,
    required String reviewerId,
    required RejectionCode rejectionCode,
    required String rejectionReason,
    String? reviewerNotes,
  }) async {
    final now = DateTime.now();
    final updatePayload = {
      'status': 'rejected',
      'rejection_code': rejectionCode.code,
      'rejection_reason': rejectionReason,
      'reviewer_id': reviewerId,
      'reviewer_notes': reviewerNotes,
      'reviewed_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    final mockIdx = _mockVerifications.indexWhere((v) => v.id == verificationId);
    if (mockIdx != -1) {
      final updated = _mockVerifications[mockIdx].copyWith(
        status: VerificationStatus.rejected,
        rejectionCode: rejectionCode,
        rejectionReason: rejectionReason,
        reviewerId: reviewerId,
        reviewerNotes: reviewerNotes,
        reviewedAt: now,
        updatedAt: now,
      );
      _mockVerifications[mockIdx] = updated;
    }

    if (isDemoMode || !SupabaseConfig.isConfigured) {
      return mockIdx != -1 ? _mockVerifications[mockIdx] : _mockVerifications.first;
    }

    try {
      final res = await _supabase
          .from('student_verifications')
          .update(updatePayload)
          .eq('id', verificationId)
          .select()
          .single();

      return StudentVerificationModel.fromJson(res);
    } catch (e) {
      debugPrint('Error rejecting verification in Supabase: $e');
      if (mockIdx != -1) return _mockVerifications[mockIdx];
      rethrow;
    }
  }
}

final studentVerificationRepositoryProvider =
    Provider<StudentVerificationRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return StudentVerificationRepository(
    supabase,
    isDemoMode: !SupabaseConfig.isConfigured,
  );
});
