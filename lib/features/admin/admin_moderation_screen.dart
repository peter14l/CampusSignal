import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/widgets/category_chip.dart';
import '../../models/id_card_verification_model.dart';
import '../../models/profile_model.dart';
import '../auth/auth_controller.dart';
import 'admin_controller.dart';

class AdminModerationScreen extends ConsumerStatefulWidget {
  const AdminModerationScreen({super.key});

  @override
  ConsumerState<AdminModerationScreen> createState() => _AdminModerationScreenState();
}

class _AdminModerationScreenState extends ConsumerState<AdminModerationScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _passkeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _passkeyController.dispose();
    super.dispose();
  }

  void _showRejectDialog(BuildContext context, String eventId, String eventTitle) {
    String selectedReason = 'Incomplete eligibility or registration details';
    final customReasonController = TextEditingController();

    final predefinedReasons = [
      'Incomplete eligibility or registration details',
      'Missing or invalid application/registration URL',
      'Duplicate submission or conflicting venue schedule',
      'Does not conform to campus publication guidelines',
      'Custom reason...',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final theme = Theme.of(ctx);
            final colorScheme = theme.colorScheme;

            return Container(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.alertTriangle, color: colorScheme.error, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Reject Event Submission',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.error,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.x, size: 18),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select a constructive reason to help the organizer revise: "$eventTitle"',
                    style: TextStyle(fontSize: 12.5, color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 14),
                  ...predefinedReasons.map((reason) {
                    final isSelected = selectedReason == reason;
                    return InkWell(
                      onTap: () {
                        setModalState(() {
                          selectedReason = reason;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Radio<String>(
                              value: reason,
                              groupValue: selectedReason,
                              onChanged: (val) {
                                if (val != null) {
                                  setModalState(() {
                                    selectedReason = val;
                                  });
                                }
                              },
                            ),
                            Expanded(
                              child: Text(
                                reason,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  if (selectedReason == 'Custom reason...') ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: customReasonController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Enter specific feedback for the organizer...',
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.onError,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        final finalReason = selectedReason == 'Custom reason...'
                            ? customReasonController.text.trim()
                            : selectedReason;
                        Navigator.pop(ctx);
                        ref.read(adminControllerProvider.notifier).rejectEvent(
                              eventId,
                              finalReason.isNotEmpty ? finalReason : 'Submission not approved',
                            );
                      },
                      child: const Text('Confirm Rejection', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final profile = ref.watch(authControllerProvider.select((s) => s.profile));
    final adminState = ref.watch(adminControllerProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Admin Moderation Hub',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: [
            Tab(
              icon: const Icon(LucideIcons.listFilter, size: 18),
              text: 'Triage (${adminState.pendingEvents.length})',
            ),
            const Tab(
              icon: Icon(LucideIcons.keyRound, size: 18),
              text: 'Fest Passkey',
            ),
            Tab(
              icon: const Icon(LucideIcons.badgeCheck, size: 18),
              text: 'ID Queue (${adminState.pendingVerifications.length})',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Header Role Summary Card
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primaryContainer.withValues(alpha: 0.5),
                  colorScheme.surfaceContainerLow,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(LucideIcons.shieldCheck, color: colorScheme.onPrimary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _getRoleLabel(profile?.role ?? UserRole.student),
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              profile?.collegeShortCode ?? 'SXUK',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profile?.managedFestIds.isNotEmpty == true
                            ? 'Authorized Convenor for ${profile!.managedFestIds.join(", ")}'
                            : 'Campus moderation authority enabled',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Feedback snack alert
          if (adminState.successMessage != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.checkCircle2, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      adminState.successMessage!,
                      style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

          if (adminState.errorMessage != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.alertCircle, color: colorScheme.onErrorContainer, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      adminState.errorMessage!,
                      style: TextStyle(fontSize: 12, color: colorScheme.onErrorContainer, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTriageTab(context, adminState, colorScheme),
                _buildPasskeyTab(context, adminState, colorScheme),
                _buildVerificationQueueTab(context, adminState, colorScheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.faculty:
        return '🏛️ Faculty Coordinator';
      case UserRole.festAdmin:
        return '⚡ Fest / Hackathon Convenor';
      case UserRole.clubLead:
        return '🎯 Club Lead';
      case UserRole.superAdmin:
        return '👑 Super Administrator';
      case UserRole.student:
        return '🎓 Authorized Student Admin';
    }
  }

  // TAB 1: Submission Triage
  Widget _buildTriageTab(BuildContext context, AdminState state, ColorScheme colorScheme) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.pendingEvents.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.checkCheck, size: 48, color: Colors.green.withValues(alpha: 0.7)),
              const SizedBox(height: 12),
              const Text(
                'Moderation Queue Clear!',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                'All campus submissions and hackathon tracks have been reviewed.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: state.pendingEvents.length,
      itemBuilder: (context, index) {
        final event = state.pendingEvents[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CategoryChip(category: event.category),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(LucideIcons.clock, size: 12, color: Colors.amber),
                          SizedBox(width: 4),
                          Text(
                            'Pending Review',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.amber),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  event.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Host: ${event.organizerName} • ${event.collegeShortCode ?? "SXUK"}',
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                ),
                if (event.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    event.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.5, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.85)),
                  ),
                ],
                const SizedBox(height: 14),
                // Action Buttons
                Row(
                  children: [
                    // Reject with reason
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.error,
                          side: BorderSide(color: colorScheme.error.withValues(alpha: 0.5)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => _showRejectDialog(context, event.id, event.title),
                        child: const Text('Reject', style: TextStyle(fontSize: 12.5)),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Promote to Inter-College
                    if (!event.isInternship) ...[
                      IconButton.filledTonal(
                        icon: const Icon(LucideIcons.arrowUpRight, size: 18),
                        tooltip: 'Promote to Pan-India Inter-College',
                        onPressed: () {
                          ref.read(adminControllerProvider.notifier).elevateToInterCollege(event.id);
                        },
                      ),
                      const SizedBox(width: 8),
                    ],

                    // Direct Approve
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          ref.read(adminControllerProvider.notifier).approveEvent(event.id);
                        },
                        child: const Text('Approve', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // TAB 2: Fest Convenor Key Redemption
  Widget _buildPasskeyTab(BuildContext context, AdminState state, ColorScheme colorScheme) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.keyRound, color: colorScheme.primary, size: 24),
                  const SizedBox(width: 10),
                  const Text(
                    'Redeem Fest Convenor Passkey',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Student organizers and track heads can elevate their session to Fest Admin without faculty intervention using an issued passkey.',
                style: TextStyle(fontSize: 12.5, color: colorScheme.onSurfaceVariant, height: 1.35),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passkeyController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'e.g. XAVHACKS-26 or DEMO-FEST-2026',
                  prefixIcon: const Icon(LucideIcons.lock, size: 18),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: state.isProcessing
                      ? null
                      : () {
                          final key = _passkeyController.text.trim();
                          if (key.isNotEmpty) {
                            ref.read(adminControllerProvider.notifier).redeemFestPasskey(key);
                          }
                        },
                  child: state.isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Claim Fest Admin Access', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'DEMO PASSKEYS AVAILABLE',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colorScheme.primary, letterSpacing: 0.8),
        ),
        const SizedBox(height: 8),
        _buildKeyPill('XAVHACKS-26', 'XavHacks 2026 Core Track Head', colorScheme),
        const SizedBox(height: 6),
        _buildKeyPill('DEMO-FEST-2026', 'Generic Institutional Fest Admin', colorScheme),
        const SizedBox(height: 6),
        _buildKeyPill('SRIJAN-26', 'Jadavpur University Srijan Convenor', colorScheme),
      ],
    );
  }

  Widget _buildKeyPill(String code, String desc, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(code, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              Text(desc, style: TextStyle(fontSize: 11.5, color: colorScheme.onSurfaceVariant)),
            ],
          ),
          IconButton(
            icon: const Icon(LucideIcons.copy, size: 16),
            tooltip: 'Copy Code',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              _passkeyController.text = code;
            },
          ),
        ],
      ),
    );
  }

  // TAB 3: ID Verification Queue (Dean & Faculty Moderation Hub)
  Widget _buildVerificationQueueTab(BuildContext context, AdminState state, ColorScheme colorScheme) {
    return Column(
      children: [
        // Department Scoping Filter Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: colorScheme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.filter, size: 14, color: colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        'DEPARTMENT MODERATION SCOPE',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${state.pendingVerifications.length} Pending',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: state.availableDepartments.map((dept) {
                    final isSelected = state.selectedDepartment == dept;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        label: Text(dept, style: const TextStyle(fontSize: 12)),
                        selected: isSelected,
                        onSelected: (_) {
                          ref.read(adminControllerProvider.notifier).filterDepartment(dept);
                        },
                        selectedColor: colorScheme.primaryContainer,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Queue List
        Expanded(
          child: state.pendingVerifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.badgeCheck, size: 48, color: Colors.green.withValues(alpha: 0.7)),
                      const SizedBox(height: 12),
                      const Text(
                        'No Pending ID Verifications',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'All student credentials in "${state.selectedDepartment}" are fully reviewed.',
                        style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: state.pendingVerifications.length,
                  itemBuilder: (context, index) {
                    final verif = state.pendingVerifications[index];
                    final confPercent = (verif.ocrConfidence * 100).toInt();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        verif.fullNameOnCard,
                                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                                      ),
                                      Text(
                                        'Roll: ${verif.rollNumber}',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    verif.documentType.label,
                                    style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Department & Academic Batch
                            Text(
                              '${verif.department ?? "General Department"} • Batch: ${verif.academicYear ?? "Current"}',
                              style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: 10),

                            // OCR Diagnostic Pill
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: confPercent >= 80
                                    ? Colors.green.withValues(alpha: 0.08)
                                    : Colors.amber.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: confPercent >= 80
                                      ? Colors.green.withValues(alpha: 0.3)
                                      : Colors.amber.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    confPercent >= 80 ? LucideIcons.cpu : LucideIcons.alertTriangle,
                                    size: 14,
                                    color: confPercent >= 80 ? Colors.green : Colors.orange,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'OCR Confidence: $confPercent% • ${verif.ocrCollegeMatched ? "College Verified" : "Institution Ambiguous"}',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: confPercent >= 80 ? Colors.green.shade800 : Colors.orange.shade800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(LucideIcons.eye, size: 15),
                                    label: const Text('Inspect OCR', style: TextStyle(fontSize: 12)),
                                    onPressed: () => _showInspectionDialog(context, verif),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: colorScheme.error,
                                    side: BorderSide(color: colorScheme.error.withValues(alpha: 0.5)),
                                  ),
                                  onPressed: () => _showRejectVerificationDialog(context, verif),
                                  child: const Text('Reject', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                ),
                                const SizedBox(width: 8),
                                FilledButton(
                                  onPressed: () {
                                    ref.read(adminControllerProvider.notifier).approveStudentVerification(verif.id);
                                  },
                                  child: const Text('Approve', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  /// Side-by-side zoomable photo inspection dialog with OCR field breakdown
  void _showInspectionDialog(BuildContext context, StudentVerificationModel verif) {
    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final colorScheme = theme.colorScheme;

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 650,
            constraints: const BoxConstraints(maxHeight: 700),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modal Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(LucideIcons.fileSearch, color: colorScheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Credential Inspection & OCR Audit',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 18),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Content Area
                Expanded(
                  child: ListView(
                    children: [
                      // Zoomable Photo Viewer
                      Container(
                        height: 240,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            InteractiveViewer(
                              minScale: 0.8,
                              maxScale: 4.0,
                              child: Center(
                                child: verif.idCardFrontUrl.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: verif.idCardFrontUrl,
                                        fit: BoxFit.contain,
                                        placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                                        errorWidget: (_, __, ___) => const Center(
                                          child: Icon(LucideIcons.imageOff, color: Colors.white54, size: 40),
                                        ),
                                      )
                                    : const Icon(LucideIcons.imageOff, color: Colors.white54, size: 40),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(LucideIcons.zoomIn, size: 12, color: Colors.white),
                                    SizedBox(width: 4),
                                    Text('Pinch to Zoom', style: TextStyle(color: Colors.white, fontSize: 10)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Side-by-side OCR Verification Data
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'OCR MULTIMODAL EXTRACTION AUDIT',
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 0.8),
                            ),
                            const SizedBox(height: 8),
                            _buildOcrAuditRow('Student Name', verif.fullNameOnCard, verif.ocrNameMatched, colorScheme),
                            const SizedBox(height: 6),
                            _buildOcrAuditRow('Roll Number', verif.rollNumber, verif.rollNumber.isNotEmpty, colorScheme),
                            const SizedBox(height: 6),
                            _buildOcrAuditRow('College Match', verif.ocrExtractedCollege ?? verif.collegeId, verif.ocrCollegeMatched, colorScheme),
                            const SizedBox(height: 6),
                            _buildOcrAuditRow('Document Type', verif.documentType.label, true, colorScheme),
                            const SizedBox(height: 6),
                            _buildOcrAuditRow('Department', verif.department ?? 'Allied Branch', true, colorScheme),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // DPDP Act 2023 Statutory Privacy Card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(LucideIcons.shieldCheck, size: 16, color: colorScheme.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'DPDP Act 2023 Compliant: Sensitive PII (Home address & Blood Group) was discarded during OCR processing.',
                                style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Dialog Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.error,
                        side: BorderSide(color: colorScheme.error.withValues(alpha: 0.5)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showRejectVerificationDialog(context, verif);
                      },
                      child: const Text('Reject Submission'),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ref.read(adminControllerProvider.notifier).approveStudentVerification(verif.id);
                      },
                      child: const Text('Approve & Issue SheerID Badge'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOcrAuditRow(String label, String value, bool isMatched, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
        Row(
          children: [
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(width: 4),
            Icon(
              isMatched ? LucideIcons.check : LucideIcons.alertCircle,
              size: 13,
              color: isMatched ? Colors.green : Colors.orange,
            ),
          ],
        ),
      ],
    );
  }

  /// Rejection sheet with predefined reason codes per Dean's governance
  void _showRejectVerificationDialog(BuildContext context, StudentVerificationModel verif) {
    RejectionCode selectedCode = RejectionCode.blurryUnreadable;
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final theme = Theme.of(ctx);
            final colorScheme = theme.colorScheme;

            return Container(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.alertTriangle, color: colorScheme.error, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Reject Student Verification',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.error,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.x, size: 18),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Select a structured rejection code for "${verif.fullNameOnCard}" (${verif.rollNumber}):',
                    style: TextStyle(fontSize: 12.5, color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),

                  // Predefined Rejection Codes
                  ...RejectionCode.values.map((code) {
                    final isSelected = selectedCode == code;
                    return InkWell(
                      onTap: () => setModalState(() => selectedCode = code),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Radio<RejectionCode>(
                              value: code,
                              groupValue: selectedCode,
                              onChanged: (val) {
                                if (val != null) setModalState(() => selectedCode = val);
                              },
                            ),
                            Expanded(
                              child: Text(
                                code.description,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 10),
                  TextField(
                    controller: notesController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Additional faculty notes / reviewer instructions...',
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
                      onPressed: () {
                        Navigator.pop(ctx);
                        ref.read(adminControllerProvider.notifier).rejectStudentVerification(
                              verifId: verif.id,
                              rejectionCode: selectedCode,
                              rejectionReason: selectedCode.description,
                              notes: notesController.text.trim(),
                            );
                      },
                      child: const Text('Confirm Rejection', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
