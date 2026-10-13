import 'package:flutter_test/flutter_test.dart';
import 'package:campus_signal/models/college_model.dart';
import 'package:campus_signal/models/id_card_verification_model.dart';
import 'package:campus_signal/models/profile_model.dart';
import 'package:campus_signal/data/repositories/student_verification_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('StudentVerificationModel Tests', () {
    test('Default serialization and deserialization work accurately', () {
      final now = DateTime.now();
      final oneYearLater = now.add(const Duration(days: 365));

      final model = StudentVerificationModel(
        id: 'verif-test-101',
        userId: 'user-001',
        collegeId: 'sxuk',
        documentType: DocumentType.collegeIdCard,
        fullNameOnCard: 'Aarav Sharma',
        rollNumber: 'SXUK/CSE/23/042',
        department: 'B.Tech in CSE',
        academicYear: '2023-2027',
        idCardFrontUrl: 'https://storage.supabase.co/id_cards/test.jpg',
        status: VerificationStatus.approved,
        verificationMethod: VerificationMethod.automatedOcr,
        ocrConfidence: 0.94,
        ocrCollegeMatched: true,
        ocrNameMatched: true,
        ocrExtractedRoll: 'SXUK/CSE/23/042',
        ocrExtractedCollege: "St. Xavier's University, Kolkata",
        verifiedAt: now,
        expiresAt: oneYearLater,
        createdAt: now,
      );

      final json = model.toJson();
      expect(json['id'], 'verif-test-101');
      expect(json['document_type'], 'college_id_card');
      expect(json['status'], 'approved');
      expect(json['roll_number'], 'SXUK/CSE/23/042');

      final fromJson = StudentVerificationModel.fromJson(json);
      expect(fromJson.id, model.id);
      expect(fromJson.status, VerificationStatus.approved);
      expect(fromJson.documentType, DocumentType.collegeIdCard);
      expect(fromJson.isApproved, true);
      expect(fromJson.isPending, false);
      expect(fromJson.isExpired, false);
      expect(fromJson.daysUntilExpiration, greaterThanOrEqualTo(364));
    });

    test('Expired verification helper behaves correctly', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 5));

      final expiredModel = StudentVerificationModel(
        id: 'verif-expired-1',
        userId: 'user-002',
        collegeId: 'sxuk',
        fullNameOnCard: 'Expired Student',
        rollNumber: 'SXUK/CSE/20/001',
        idCardFrontUrl: 'https://storage.supabase.co/id_cards/test.jpg',
        status: VerificationStatus.expired,
        expiresAt: pastDate,
      );

      expect(expiredModel.isExpired, true);
      expect(expiredModel.daysUntilExpiration, 0);
    });

    test('Academic expiration calculation satisfies Dean requirement', () {
      final now = DateTime(2026, 4, 15);
      final finalYearSessionEnd = DateTime(2026, 6, 30);

      // Final year student: June 30th comes before 365 days
      final computedExpiry = StudentVerificationModel.computeAcademicExpiration(
        fromDate: now,
        sessionEndDate: finalYearSessionEnd,
      );

      expect(computedExpiry, finalYearSessionEnd);
      expect(computedExpiry.month, 6);
      expect(computedExpiry.day, 30);
    });
  });

  group('ProfileModel Verification Integration Tests', () {
    test('Profile verification status flags and getters work', () {
      final now = DateTime.now();
      final oneYearLater = now.add(const Duration(days: 365));

      final profile = ProfileModel(
        id: 'user-p1',
        fullName: 'Priya Mukherjee',
        collegeEmail: 'priya@sxuk.edu.in',
        collegeId: 'sxuk',
        isVerifiedStudent: true,
        verificationStatus: VerificationStatus.approved,
        rollNumber: 'SXUK/CSE/24/089',
        verifiedAt: now,
        verificationExpiresAt: oneYearLater,
      );

      expect(profile.isFullyVerified, true);
      expect(profile.isVerificationExpired, false);
      expect(profile.isVerificationPending, false);
      expect(profile.daysUntilExpiration, greaterThanOrEqualTo(364));

      final json = profile.toJson();
      expect(json['verification_status'], 'approved');
      expect(json['is_verified_student'], true);

      final reloaded = ProfileModel.fromJson(json);
      expect(reloaded.isFullyVerified, true);
      expect(reloaded.rollNumber, 'SXUK/CSE/24/089');
    });

    test('Expired profile flags isFullyVerified as false', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 2));

      final profile = ProfileModel(
        id: 'user-p2',
        fullName: 'Alumnus User',
        isVerifiedStudent: true,
        verificationStatus: VerificationStatus.expired,
        verificationExpiresAt: pastDate,
      );

      expect(profile.isFullyVerified, false);
      expect(profile.isVerificationExpired, true);
    });

    test('Pending profile flags isVerificationPending as true', () {
      const profile = ProfileModel(
        id: 'user-p3',
        fullName: 'Pending Student',
        verificationStatus: VerificationStatus.pending,
      );

      expect(profile.isVerificationPending, true);
      expect(profile.isFullyVerified, false);
    });
  });

  group('IdCardOcrResult Tests', () {
    test('JSON parsing and auto-approval evaluation', () {
      final json = {
        'extractedName': 'Aarav Sharma',
        'extractedRoll': 'SXUK/CSE/23/042',
        'extractedCollege': "St. Xavier's University, Kolkata",
        'department': 'Computer Science',
        'academicYear': '2023-2027',
        'confidence': 0.95,
        'collegeMatched': true,
        'nameMatched': true,
        'isAutoApproved': true,
      };

      final result = IdCardOcrResult.fromJson(json);
      expect(result.extractedName, 'Aarav Sharma');
      expect(result.extractedRoll, 'SXUK/CSE/23/042');
      expect(result.confidence, 0.95);
      expect(result.isAutoApproved, true);
      expect(result.collegeMatched, true);
      expect(result.nameMatched, true);
    });
  });

  group('StudentVerificationRepository Offline / Demo Mode Tests', () {
    test('Anti-fraud roll uniqueness detects duplicate roll and permits unique', () async {
      final standaloneClient = SupabaseClient('https://mock.supabase.co', 'anon-key');
      final repo = StudentVerificationRepository(standaloneClient, isDemoMode: true);

      // Verify a new student
      final approvedDoc = StudentVerificationModel(
        id: 'v-test-1',
        userId: 'student-A',
        collegeId: 'sxuk',
        documentType: DocumentType.collegeIdCard,
        fullNameOnCard: 'Student A',
        rollNumber: 'SXUK/TEST/2026/99',
        status: VerificationStatus.approved,
        idCardFrontUrl: 'https://example.com/card.jpg',
      );
      await repo.submitVerification(approvedDoc);

      // Check same roll for different user => should be duplicate (false)
      final isAvailableForOther = await repo.checkRollNumberAvailability(
        'sxuk',
        'SXUK/TEST/2026/99',
        excludeUserId: 'student-B',
      );
      expect(isAvailableForOther, false);

      // Check distinct roll => should be available (true)
      final isAvailableNew = await repo.checkRollNumberAvailability(
        'sxuk',
        'SXUK/DISTINCT/2026/100',
        excludeUserId: 'student-B',
      );
      expect(isAvailableNew, true);
    });

    test('Moderation approval flow sets expiration and updates status', () async {
      final standaloneClient = SupabaseClient('https://mock.supabase.co', 'anon-key');
      final repo = StudentVerificationRepository(standaloneClient, isDemoMode: true);

      final queue = await repo.getPendingModerationQueue();
      expect(queue.isNotEmpty, true);

      final firstPending = queue.first;
      final approved = await repo.approveVerification(
        verificationId: firstPending.id,
        reviewerId: 'dean-01',
        reviewerNotes: 'Approved by Dean of Student Affairs',
      );

      expect(approved.status, VerificationStatus.approved);
      expect(approved.reviewerId, 'dean-01');
      expect(approved.reviewerNotes, 'Approved by Dean of Student Affairs');
      expect(approved.expiresAt, isNotNull);
    });

    test('Moderation rejection flow records structured rejection code', () async {
      final standaloneClient = SupabaseClient('https://mock.supabase.co', 'anon-key');
      final repo = StudentVerificationRepository(standaloneClient, isDemoMode: true);

      final rejected = await repo.rejectVerification(
        verificationId: 'verif-demo-2',
        reviewerId: 'faculty-01',
        rejectionCode: RejectionCode.blurryUnreadable,
        rejectionReason: 'ID card text is too blurry to resolve registration seal.',
      );

      expect(rejected.status, VerificationStatus.rejected);
      expect(rejected.rejectionCode, RejectionCode.blurryUnreadable);
      expect(rejected.rejectionReason, contains('blurry'));
    });
  });
}
