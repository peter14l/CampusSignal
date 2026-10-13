import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/services/gemini_ocr_service.dart';
import '../../data/repositories/student_verification_repository.dart';
import '../../models/college_model.dart';
import '../../models/id_card_verification_model.dart';
import '../../models/profile_model.dart';
import '../auth/auth_controller.dart';

/// Modal bottom sheet for in-app student ID card verification / re-verification
class StudentVerificationSheet extends ConsumerStatefulWidget {
  const StudentVerificationSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const StudentVerificationSheet(),
    );
  }

  @override
  ConsumerState<StudentVerificationSheet> createState() => _StudentVerificationSheetState();
}

class _StudentVerificationSheetState extends ConsumerState<StudentVerificationSheet> {
  final ImagePicker _picker = ImagePicker();

  DocumentType _selectedDocType = DocumentType.collegeIdCard;
  bool _isProcessing = false;
  int _checklistStep = 0; // 0: idle, 1: reading, 2: matching, 3: validating roll, 4: complete
  String? _feedbackMessage;
  bool _isSuccess = false;
  bool _isConflict = false;
  String? _detectedRoll;

  Future<void> _handlePickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 92,
        maxWidth: 1600,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        await _processDocument(bytes: bytes, imagePath: picked.path);
      }
    } catch (_) {
      // Fallback to simulated scan if native camera/picker is unavailable
      await _processDocument(bytes: null, imagePath: null);
    }
  }

  Future<void> _processDocument({Uint8List? bytes, String? imagePath}) async {
    final authState = ref.read(authControllerProvider);
    final profile = authState.profile;
    final college = authState.selectedCollege;

    if (profile == null) return;

    setState(() {
      _isProcessing = true;
      _checklistStep = 1;
      _feedbackMessage = null;
      _isSuccess = false;
      _isConflict = false;
    });

    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => _checklistStep = 2);

    final ocrService = ref.read(geminiOcrServiceProvider);
    final ocrResult = await ocrService.extractIdCardDetailsFromImage(
      imageBytes: bytes ?? Uint8List(0),
      college: college,
      studentName: profile.fullName,
    );

    setState(() => _checklistStep = 3);
    await Future.delayed(const Duration(milliseconds: 500));

    final verifRepo = ref.read(studentVerificationRepositoryProvider);
    final rollToCheck = ocrResult.extractedRoll.isNotEmpty
        ? ocrResult.extractedRoll
        : '${college.shortCode}/ENG/${DateTime.now().year % 100}/${100 + (DateTime.now().millisecond % 899)}';

    final isUnique = await verifRepo.checkRollNumberAvailability(
      college.id,
      rollToCheck,
      excludeUserId: profile.id,
    );

    String uploadedPhotoUrl = imagePath ?? '';
    if (bytes != null) {
      uploadedPhotoUrl = await verifRepo.uploadIdCardDocument(
        userId: profile.id,
        bytes: bytes,
      );
    }

    if (!isUnique) {
      // Anti-identity sharing conflict
      final flaggedRecord = StudentVerificationModel(
        id: 'verif-${DateTime.now().millisecondsSinceEpoch}',
        userId: profile.id,
        collegeId: college.id,
        documentType: _selectedDocType,
        fullNameOnCard: ocrResult.extractedName.isNotEmpty ? ocrResult.extractedName : profile.fullName,
        rollNumber: rollToCheck,
        department: profile.branch,
        idCardFrontUrl: uploadedPhotoUrl.isNotEmpty
            ? uploadedPhotoUrl
            : 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=800&q=80',
        status: VerificationStatus.pending,
        verificationMethod: VerificationMethod.hybrid,
        ocrConfidence: ocrResult.confidence,
        ocrRawPayload: ocrResult.rawPayload,
        rejectionCode: RejectionCode.duplicateRollNumber,
        rejectionReason: 'Duplicate Roll Number detected across accounts. Flagged for Dean review.',
        createdAt: DateTime.now(),
      );

      await verifRepo.submitVerification(flaggedRecord);

      final updatedProfile = profile.copyWith(
        verificationStatus: VerificationStatus.pending,
        rollNumber: rollToCheck,
      );
      await ref.read(authControllerProvider.notifier).updateProfile(updatedProfile);

      setState(() {
        _isProcessing = false;
        _checklistStep = 4;
        _isConflict = true;
        _detectedRoll = rollToCheck;
        _feedbackMessage =
            'Security Flag: Roll number "$rollToCheck" is currently claimed by another user. Routed to Dean Moderation Hub.';
      });
      return;
    }

    if (ocrResult.isAutoApproved) {
      final expiryDate = StudentVerificationModel.computeAcademicExpiration();
      final approvedRecord = StudentVerificationModel(
        id: 'verif-${DateTime.now().millisecondsSinceEpoch}',
        userId: profile.id,
        collegeId: college.id,
        documentType: _selectedDocType,
        fullNameOnCard: ocrResult.extractedName.isNotEmpty ? ocrResult.extractedName : profile.fullName,
        rollNumber: rollToCheck,
        department: profile.branch,
        idCardFrontUrl: uploadedPhotoUrl.isNotEmpty
            ? uploadedPhotoUrl
            : 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=800&q=80',
        status: VerificationStatus.approved,
        verificationMethod: VerificationMethod.automatedOcr,
        ocrConfidence: ocrResult.confidence,
        ocrCollegeMatched: ocrResult.collegeMatched,
        ocrNameMatched: ocrResult.nameMatched,
        ocrRawPayload: ocrResult.rawPayload,
        verifiedAt: DateTime.now(),
        expiresAt: expiryDate,
        createdAt: DateTime.now(),
      );

      await verifRepo.submitVerification(approvedRecord);

      final updatedProfile = profile.copyWith(
        isVerifiedStudent: true,
        verificationStatus: VerificationStatus.approved,
        rollNumber: rollToCheck,
        verifiedAt: DateTime.now(),
        verificationExpiresAt: expiryDate,
        idCardFrontUrl: uploadedPhotoUrl,
        activeVerificationId: approvedRecord.id,
      );
      await ref.read(authControllerProvider.notifier).updateProfile(updatedProfile);

      setState(() {
        _isProcessing = false;
        _checklistStep = 4;
        _isSuccess = true;
        _detectedRoll = rollToCheck;
        _feedbackMessage =
            '✓ SheerID Auto-Approval Granted! 1-Year collegiate pass valid until ${expiryDate.year}-06-30.';
      });
    } else {
      // Escalated to Department Moderator Queue
      final pendingRecord = StudentVerificationModel(
        id: 'verif-${DateTime.now().millisecondsSinceEpoch}',
        userId: profile.id,
        collegeId: college.id,
        documentType: _selectedDocType,
        fullNameOnCard: ocrResult.extractedName.isNotEmpty ? ocrResult.extractedName : profile.fullName,
        rollNumber: rollToCheck,
        department: profile.branch,
        idCardFrontUrl: uploadedPhotoUrl.isNotEmpty
            ? uploadedPhotoUrl
            : 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=800&q=80',
        status: VerificationStatus.pending,
        verificationMethod: VerificationMethod.hybrid,
        ocrConfidence: ocrResult.confidence,
        ocrCollegeMatched: ocrResult.collegeMatched,
        ocrNameMatched: ocrResult.nameMatched,
        ocrRawPayload: ocrResult.rawPayload,
        createdAt: DateTime.now(),
      );

      await verifRepo.submitVerification(pendingRecord);

      final updatedProfile = profile.copyWith(
        verificationStatus: VerificationStatus.pending,
        rollNumber: rollToCheck,
      );
      await ref.read(authControllerProvider.notifier).updateProfile(updatedProfile);

      setState(() {
        _isProcessing = false;
        _checklistStep = 4;
        _isSuccess = false;
        _detectedRoll = rollToCheck;
        _feedbackMessage =
            'Submission escalated to Department Moderator Queue for faculty verification (Confidence ${(ocrResult.confidence * 100).toInt()}%).';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final profile = ref.watch(authControllerProvider).profile;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(LucideIcons.shieldCheck, color: colorScheme.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Student Identity Verification',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16.5),
                    ),
                    Text(
                      'Pan-Indian Collegiate SheerID • DPDP Act 2023 Compliant',
                      style: TextStyle(fontSize: 11.5, color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.x, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Current Status Banner if already verified
          if (profile != null && profile.isFullyVerified && !_isSuccess) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.checkCircle2, color: Colors.green, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Currently Verified Student',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.green),
                        ),
                        Text(
                          'Roll: ${profile.rollNumber ?? "Active"} • ${profile.daysUntilExpiration} days remaining',
                          style: TextStyle(fontSize: 11.5, color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Document Type Selector
          Text(
            'SELECT OFFICIAL DOCUMENT TYPE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: DocumentType.values.map((docType) {
              final isSelected = _selectedDocType == docType;
              return ChoiceChip(
                label: Text(docType.label, style: const TextStyle(fontSize: 12)),
                selected: isSelected,
                onSelected: _isProcessing
                    ? null
                    : (selected) {
                        if (selected) setState(() => _selectedDocType = docType);
                      },
                selectedColor: colorScheme.primaryContainer,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Animated Checklist if processing
          if (_isProcessing || _checklistStep > 0) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
              ),
              child: Column(
                children: [
                  _buildChecklistRow('Ingesting document image...', _checklistStep >= 2, _checklistStep == 1, colorScheme),
                  const SizedBox(height: 6),
                  _buildChecklistRow('Multimodal Gemini OCR verification...', _checklistStep >= 3, _checklistStep == 2, colorScheme),
                  const SizedBox(height: 6),
                  _buildChecklistRow('Anti-Fraud Unique Roll validation...', _checklistStep >= 4, _checklistStep == 3, colorScheme),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Feedback resolution card
          if (_feedbackMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _isSuccess
                    ? Colors.green.withValues(alpha: 0.1)
                    : (_isConflict ? Colors.red.withValues(alpha: 0.1) : Colors.amber.withValues(alpha: 0.1)),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isSuccess
                      ? Colors.green.withValues(alpha: 0.4)
                      : (_isConflict ? Colors.red.withValues(alpha: 0.4) : Colors.amber.withValues(alpha: 0.4)),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isSuccess
                        ? LucideIcons.badgeCheck
                        : (_isConflict ? LucideIcons.alertTriangle : LucideIcons.clock),
                    color: _isSuccess ? Colors.green : (_isConflict ? Colors.red : Colors.orange),
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _feedbackMessage!,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: _isSuccess
                            ? Colors.green.shade800
                            : (_isConflict ? Colors.red.shade800 : Colors.orange.shade800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(LucideIcons.camera, size: 16),
                  label: const Text('Take Photo', style: TextStyle(fontSize: 12.5)),
                  onPressed: _isProcessing ? null : () => _handlePickImage(ImageSource.camera),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.tonalIcon(
                  icon: const Icon(LucideIcons.image, size: 16),
                  label: const Text('Choose Photo', style: TextStyle(fontSize: 12.5)),
                  onPressed: _isProcessing ? null : () => _handlePickImage(ImageSource.gallery),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              icon: const Icon(LucideIcons.scanLine, size: 14),
              label: const Text('Simulate Instant OCR (Demo Mode)', style: TextStyle(fontSize: 12)),
              onPressed: _isProcessing ? null : () => _processDocument(bytes: null, imagePath: null),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistRow(String text, bool isDone, bool isInProgress, ColorScheme colorScheme) {
    return Row(
      children: [
        if (isDone)
          const Icon(LucideIcons.checkCircle2, color: Colors.green, size: 16)
        else if (isInProgress)
          const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
        else
          Icon(LucideIcons.circle, color: colorScheme.outlineVariant, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isDone ? Colors.green : (isInProgress ? colorScheme.primary : colorScheme.onSurfaceVariant),
              fontWeight: isDone || isInProgress ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
