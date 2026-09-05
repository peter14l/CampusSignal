import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/department_picker_modal.dart';
import '../../models/profile_model.dart';
import 'profile_controller.dart';
import 'tag_selection_sheet.dart';

class EditAcademicProfileScreen extends ConsumerStatefulWidget {
  const EditAcademicProfileScreen({super.key});

  @override
  ConsumerState<EditAcademicProfileScreen> createState() =>
      _EditAcademicProfileScreenState();
}

class _EditAcademicProfileScreenState
    extends ConsumerState<EditAcademicProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late String _selectedBranch;
  late int _selectedSemester;
  late List<String> _skills;
  late List<String> _interests;

  @override
  void initState() {
    super.initState();
    final currentProfile =
        ref.read(profileControllerProvider).profile ?? const ProfileModel(id: '');

    _nameController = TextEditingController(text: currentProfile.fullName);
    _selectedBranch = currentProfile.branch != null && AppConstants.branches.contains(currentProfile.branch)
        ? currentProfile.branch!
        : AppConstants.branches.first;
    _selectedSemester = currentProfile.semester ??
        (currentProfile.year != null ? (currentProfile.year! * 2 - 1) : 3);
    _skills = List<String>.from(currentProfile.skills);
    _interests = List<String>.from(currentProfile.interests);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.mediumImpact();

    ref.read(profileControllerProvider.notifier).updateFullAcademicProfile(
          fullName: _nameController.text.trim(),
          branch: _selectedBranch,
          semester: _selectedSemester,
          skills: _skills,
          interests: _interests,
        );

    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/profile');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.circleCheck, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Academic profile updated successfully!',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentProfile = ref.watch(profileControllerProvider).profile;
    final int calculatedYear = (_selectedSemester + 1) ~/ 2;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Edit Academic Profile',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
            }
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
          children: [
            // Student Identity Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: colorScheme.primaryContainer,
                        child: Text(
                          _nameController.text.isNotEmpty
                              ? _nameController.text.substring(0, 1).toUpperCase()
                              : 'S',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'STUDENT IDENTITY',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              currentProfile?.collegeEmail ?? 'SXUK Student Account',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.shieldCheck,
                                size: 12, color: colorScheme.primary),
                            const SizedBox(width: 4),
                            Text(
                              'SXUK',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'Full Name *',
                      hintText: 'e.g. Aritra Mondal',
                      prefixIcon: Icon(LucideIcons.user,
                          color: colorScheme.onSurfaceVariant, size: 18),
                    ),
                    onChanged: (_) => setState(() {}),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Please enter your full name'
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Academic Department & Degree Section
            Text(
              'DEPARTMENT & PROGRAMME',
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),

            InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                DepartmentPickerSheet.show(
                  context,
                  currentSelection: _selectedBranch,
                  onSelected: (programme) {
                    setState(() => _selectedBranch = programme);
                  },
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        LucideIcons.graduationCap,
                        color: colorScheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Enrolled Programme',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 11,
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _selectedBranch,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Change',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(LucideIcons.chevronRight, size: 14, color: colorScheme.primary),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Semester & Academic Year Selection
            Text(
              'ACADEMIC PROGRESS',
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current Semester',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Year $calculatedYear (${_getYearName(calculatedYear)})',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 4x2 Semester Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1.6,
                    ),
                    itemCount: 8,
                    itemBuilder: (context, i) {
                      final sem = i + 1;
                      final isSelected = _selectedSemester == sem;

                      return InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedSemester = sem);
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primaryContainer
                                : colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.outlineVariant
                                      .withValues(alpha: 0.4),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Sem $sem',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: isSelected
                                    ? colorScheme.onPrimaryContainer
                                    : colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Skills & Tech Domains
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(LucideIcons.wrench,
                              size: 16, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Skills & Tech Stack',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          await TagSelectionSheet.show(
                            context,
                            isSkill: true,
                            currentTags: _skills,
                          );
                          final latest =
                              ref.read(profileControllerProvider).profile?.skills;
                          if (latest != null) {
                            setState(() => _skills = List<String>.from(latest));
                          }
                        },
                        icon: const Icon(LucideIcons.plus, size: 14),
                        label: const Text('Manage', style: TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_skills.isEmpty)
                    Text(
                      'No skills configured. Tap Manage to add skills.',
                      style: TextStyle(
                          fontSize: 12, color: colorScheme.onSurfaceVariant),
                    )
                  else
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _skills.map((s) {
                        return Chip(
                          label: Text(s),
                          backgroundColor: colorScheme.surfaceContainer,
                          labelStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                          deleteIcon: const Icon(LucideIcons.x, size: 12),
                          onDeleted: () {
                            HapticFeedback.lightImpact();
                            setState(() => _skills.remove(s));
                          },
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Interests & Activities
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(LucideIcons.sparkles,
                              size: 16, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Campus Interests',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          await TagSelectionSheet.show(
                            context,
                            isSkill: false,
                            currentTags: _interests,
                          );
                          final latest = ref
                              .read(profileControllerProvider)
                              .profile
                              ?.interests;
                          if (latest != null) {
                            setState(() => _interests = List<String>.from(latest));
                          }
                        },
                        icon: const Icon(LucideIcons.plus, size: 14),
                        label: const Text('Manage', style: TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_interests.isEmpty)
                    Text(
                      'No interests configured. Tap Manage to add interests.',
                      style: TextStyle(
                          fontSize: 12, color: colorScheme.onSurfaceVariant),
                    )
                  else
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _interests.map((interest) {
                        return Chip(
                          label: Text(interest),
                          backgroundColor: colorScheme.primaryContainer,
                          labelStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onPrimaryContainer,
                          ),
                          deleteIcon: const Icon(LucideIcons.x, size: 12),
                          onDeleted: () {
                            HapticFeedback.lightImpact();
                            setState(() => _interests.remove(interest));
                          },
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Sticky Bottom Save Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          border: Border(
            top: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.of(context).padding.bottom + 12,
        ),
        child: FilledButton.icon(
          onPressed: _saveProfile,
          icon: const Icon(LucideIcons.check, size: 18),
          label: const Text('Save Academic Profile'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }

  String _getYearName(int year) {
    switch (year) {
      case 1:
        return '1st Year';
      case 2:
        return '2nd Year';
      case 3:
        return '3rd Year';
      case 4:
        return 'Final Year';
      default:
        return 'Year $year';
    }
  }
}
