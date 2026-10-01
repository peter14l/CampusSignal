import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/motion.dart';
import 'onboarding_controller.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final TextEditingController _campusSearchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _skillInputController = TextEditingController();
  final TextEditingController _interestInputController = TextEditingController();

  String _campusSearchQuery = '';

  final List<String> _preMadeInterests = const [
    'Hackathons',
    'Internships',
    'Workshops',
    'Cultural Fests',
    'Clubs & Societies',
    'Seminars',
    'Case Competitions',
    'Networking',
    'Placement Drives',
    'Tech Talks',
    'Sports & Fitness',
    'Volunteering',
    'AI & Innovation',
    'Gaming & Esports',
    'Music & Arts',
  ];

  final List<String> _preMadeSkills = const [
    'Python',
    'Flutter & Dart',
    'Web Development',
    'React / Next.js',
    'UI/UX Design',
    'Machine Learning',
    'Data Analytics',
    'Cybersecurity',
    'Cloud / DevOps',
    'Public Speaking',
    'Content & Writing',
    'Competitive Programming',
    'Financial Modeling',
    'Robotics & IoT',
  ];

  @override
  void initState() {
    super.initState();
    final state = ref.read(onboardingControllerProvider);
    _nameController.text = state.fullName;
  }

  @override
  void dispose() {
    _campusSearchController.dispose();
    _nameController.dispose();
    _skillInputController.dispose();
    _interestInputController.dispose();
    super.dispose();
  }

  void _onNextPressed() async {
    final onboardingCtrl = ref.read(onboardingControllerProvider.notifier);
    final state = ref.read(onboardingControllerProvider);

    if (state.currentStep == 0) {
      onboardingCtrl.nextStep();
    } else if (state.currentStep == 1) {
      onboardingCtrl.updateFullName(_nameController.text.trim());
      onboardingCtrl.nextStep();
    } else if (state.currentStep == 2) {
      onboardingCtrl.nextStep();
    } else {
      // Step 3: Complete Onboarding
      final success = await onboardingCtrl.completeOnboarding();
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              state.verificationSuccess
                  ? 'ID Verified! Welcome to ${state.selectedCollegeShortCode} on CampusSignal.'
                  : 'Welcome to CampusSignal! You can verify your student ID anytime in Profile.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go('/feed');
      }
    }
  }

  void _onBackPressed() {
    ref.read(onboardingControllerProvider.notifier).previousStep();
  }

  void _addCustomSkill() {
    final skill = _skillInputController.text.trim();
    if (skill.isNotEmpty) {
      ref.read(onboardingControllerProvider.notifier).addCustomSkill(skill);
      _skillInputController.clear();
    }
  }

  void _addCustomInterest() {
    final interest = _interestInputController.text.trim();
    if (interest.isNotEmpty) {
      ref.read(onboardingControllerProvider.notifier).toggleInterest(interest);
      _interestInputController.clear();
    }
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Find Your Campus';
      case 1:
        return 'Academic Details';
      case 2:
        return 'Interests & Skills';
      case 3:
        return 'Student Verification';
      default:
        return 'Setup Profile';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: state.currentStep == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && state.currentStep > 0) {
          _onBackPressed();
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          elevation: 0,
          title: Text(
            _getStepTitle(state.currentStep),
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          leading: state.currentStep > 0
              ? IconButton(
                  icon: const Icon(LucideIcons.arrowLeft),
                  onPressed: _onBackPressed,
                )
              : null,
          actions: [
            if (state.currentStep == 3)
              TextButton(
                onPressed: () {
                  ref.read(onboardingControllerProvider.notifier).skipVerification();
                  _onNextPressed();
                },
                child: const Text('Skip for Now'),
              ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Top 4-Step Progress Indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: List.generate(4, (index) {
                    final isCompleted = index < state.currentStep;
                    final isCurrent = index == state.currentStep;
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        height: 5,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? colorScheme.primary
                              : isCurrent
                                  ? colorScheme.primary.withValues(alpha: 0.6)
                                  : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // Error Message Banner
              if (state.errorMessage != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.alertCircle, color: colorScheme.onErrorContainer, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.errorMessage!,
                          style: TextStyle(
                            color: colorScheme.onErrorContainer,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Body Content by Step
              Expanded(
                child: AnimatedSwitcher(
                  duration: AppMotion.durationMedium2,
                  switchInCurve: AppMotion.emphasizedDecelerate,
                  switchOutCurve: AppMotion.emphasizedAccelerate,
                  child: state.currentStep == 0
                      ? _buildStep0Campus(context, state, colorScheme)
                      : state.currentStep == 1
                          ? _buildStep1Academics(context, state, colorScheme)
                          : state.currentStep == 2
                              ? _buildStep2Personalize(context, state, colorScheme)
                              : _buildStep3Verification(context, state, colorScheme),
                ),
              ),

              // Bottom Navigation Action Bar
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: state.isSaving ? null : _onNextPressed,
                    child: state.isSaving
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                state.currentStep == 3
                                    ? (state.verificationSuccess ? 'Finish & Enter Campus' : 'Continue to Feed')
                                    : 'Next Step',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(LucideIcons.arrowRight, size: 18),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // STEP 0: Find Your Campus
  Widget _buildStep0Campus(BuildContext context, OnboardingState state, ColorScheme colorScheme) {
    final colleges = AppConstants.indianColleges.where((c) {
      if (_campusSearchQuery.isEmpty) return true;
      final query = _campusSearchQuery.toLowerCase();
      return c.name.toLowerCase().contains(query) ||
          c.shortCode.toLowerCase().contains(query) ||
          c.city.toLowerCase().contains(query);
    }).toList();

    return ListView(
      key: const ValueKey('step-0-campus'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        Text(
          'Select your University or College',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'CampusSignal connects your campus with inter-college discovery across India.',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 13.5,
          ),
        ),
        const SizedBox(height: 18),

        // Campus Search Box
        TextField(
          controller: _campusSearchController,
          onChanged: (val) {
            setState(() {
              _campusSearchQuery = val.trim();
            });
          },
          decoration: InputDecoration(
            hintText: 'Search college name, short code, or city...',
            prefixIcon: const Icon(LucideIcons.search, size: 20),
            suffixIcon: _campusSearchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(LucideIcons.x, size: 18),
                    onPressed: () {
                      _campusSearchController.clear();
                      setState(() {
                        _campusSearchQuery = '';
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 16),

        // Quick Pick Pills
        Text(
          'POPULAR UNIVERSITIES',
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
          children: AppConstants.indianColleges.take(6).map((college) {
            final isSelected = state.selectedCollegeId == college.id;
            return ChoiceChip(
              label: Text(college.shortCode),
              selected: isSelected,
              onSelected: (_) {
                ref.read(onboardingControllerProvider.notifier).selectCollege(college);
              },
              selectedColor: colorScheme.primaryContainer,
              labelStyle: TextStyle(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),

        // Colleges Directory List
        Text(
          'ALL INSTITUTIONS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        ...colleges.map((college) {
          final isSelected = state.selectedCollegeId == college.id;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primaryContainer.withValues(alpha: 0.4)
                  : colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: isSelected ? 1.8 : 1,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  college.shortCode.substring(0, college.shortCode.length >= 2 ? 2 : 1),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                    fontSize: 15,
                  ),
                ),
              ),
              title: Text(
                college.name,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 14.5,
                ),
              ),
              subtitle: Text(
                '${college.city}, ${college.state}',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: isSelected
                  ? Icon(LucideIcons.checkCircle2, color: colorScheme.primary)
                  : null,
              onTap: () {
                ref.read(onboardingControllerProvider.notifier).selectCollege(college);
              },
            ),
          );
        }),
      ],
    );
  }

  // STEP 1: Academic Background
  Widget _buildStep1Academics(BuildContext context, OnboardingState state, ColorScheme colorScheme) {
    // Lookup selected college's branches
    final currentCollege = AppConstants.indianColleges.firstWhere(
      (c) => c.id == state.selectedCollegeId,
      orElse: () => AppConstants.indianColleges.first,
    );

    final availableBranches = currentCollege.popularBranches.isNotEmpty
        ? currentCollege.popularBranches
        : AppConstants.branches.take(8).toList();

    return ListView(
      key: const ValueKey('step-1-academics'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        // Selected College Pill Reminder
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(LucideIcons.school, size: 16, color: colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${state.selectedCollegeName} (${state.selectedCollegeShortCode})',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () => ref.read(onboardingControllerProvider.notifier).setStep(0),
                child: Text(
                  'Change',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        Text(
          'Academic Information',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'We personalize notices and internship recommendations based on your branch and semester.',
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13.5),
        ),
        const SizedBox(height: 20),

        // Full Name
        Text(
          'FULL NAME',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: colorScheme.primary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'e.g. Aarav Sharma',
            prefixIcon: const Icon(LucideIcons.user, size: 19),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
            ),
          ),
          onChanged: (val) {
            ref.read(onboardingControllerProvider.notifier).updateFullName(val);
          },
        ),
        const SizedBox(height: 20),

        // Department / Branch Dropdown
        Text(
          'PROGRAMME / BRANCH',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: colorScheme.primary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: availableBranches.contains(state.branch)
                  ? state.branch
                  : (availableBranches.isNotEmpty ? availableBranches.first : null),
              icon: const Icon(LucideIcons.chevronDown, size: 18),
              onChanged: (newBranch) {
                ref.read(onboardingControllerProvider.notifier).updateBranch(newBranch);
              },
              items: availableBranches.map((b) {
                return DropdownMenuItem<String>(
                  value: b,
                  child: Text(
                    b,
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 22),

        // Semester Selector
        Text(
          'CURRENT SEMESTER',
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
          children: List.generate(8, (i) {
            final sem = i + 1;
            final isSelected = state.semester == sem;
            return ChoiceChip(
              label: Text('Sem $sem'),
              selected: isSelected,
              onSelected: (_) {
                ref.read(onboardingControllerProvider.notifier).updateSemester(sem);
              },
              selectedColor: colorScheme.primaryContainer,
              labelStyle: TextStyle(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
              ),
            );
          }),
        ),
      ],
    );
  }

  // STEP 2: Signal Radar (Interests & Skills)
  Widget _buildStep2Personalize(BuildContext context, OnboardingState state, ColorScheme colorScheme) {
    return ListView(
      key: const ValueKey('step-2-personalize'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        Text(
          'Signal Radar',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Choose your domain interests and skills to tune the match score for hackathons & events.',
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13.5),
        ),
        const SizedBox(height: 20),

        // Interests Section
        Text(
          'INTERESTS & OPPORTUNITY TYPES',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: colorScheme.primary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _preMadeInterests.map((interest) {
            final isSelected = state.selectedInterests.contains(interest);
            return FilterChip(
              label: Text(interest),
              selected: isSelected,
              onSelected: (_) {
                ref.read(onboardingControllerProvider.notifier).toggleInterest(interest);
              },
              selectedColor: colorScheme.primaryContainer,
              checkmarkColor: colorScheme.primary,
            );
          }).toList(),
        ),
        const SizedBox(height: 12),

        // Custom Interest Input
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _interestInputController,
                decoration: InputDecoration(
                  hintText: 'Add custom interest (e.g. Robotics, FinTech)...',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                onSubmitted: (_) => _addCustomInterest(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              icon: const Icon(LucideIcons.plus, size: 20),
              onPressed: _addCustomInterest,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Skills Section
        Text(
          'TECHNICAL & CREATIVE SKILLS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: colorScheme.primary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _preMadeSkills.map((skill) {
            final isSelected = state.selectedSkills.contains(skill);
            return FilterChip(
              label: Text(skill),
              selected: isSelected,
              onSelected: (_) {
                ref.read(onboardingControllerProvider.notifier).toggleSkill(skill);
              },
              selectedColor: colorScheme.primaryContainer,
              checkmarkColor: colorScheme.primary,
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Custom Skill Input
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _skillInputController,
                decoration: InputDecoration(
                  hintText: 'Add custom skill (e.g. Rust, Figma)...',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                onSubmitted: (_) => _addCustomSkill(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              icon: const Icon(LucideIcons.plus, size: 20),
              onPressed: _addCustomSkill,
            ),
          ],
        ),
      ],
    );
  }

  // STEP 3: Student Verification Fast-Track
  Widget _buildStep3Verification(BuildContext context, OnboardingState state, ColorScheme colorScheme) {
    return ListView(
      key: const ValueKey('step-3-verification'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        Text(
          'Verify Your Student Status',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'Indian universities rarely have .edu emails. Instant ID Card OCR lets you unlock campus-only features safely.',
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13.5),
        ),
        const SizedBox(height: 20),

        // Perks Callout Box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.primaryContainer.withValues(alpha: 0.5), colorScheme.surfaceContainerLow],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.badgeCheck, color: colorScheme.primary, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Verified Student Privileges',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildPerkItem(
                LucideIcons.lock,
                'Private Placement Wall',
                'Access internal campus-only internships and company placement notices.',
                colorScheme,
              ),
              const SizedBox(height: 8),
              _buildPerkItem(
                LucideIcons.vote,
                'Official Club Elections',
                'Cast votes and apply for student council / club coordinator positions.',
                colorScheme,
              ),
              const SizedBox(height: 8),
              _buildPerkItem(
                LucideIcons.trophy,
                'Verified Pan-India Teams',
                'Register for national inter-college hackathons with auto-vetted credentials.',
                colorScheme,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Verification Card Action
        if (state.verificationSuccess) ...[
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.checkCircle2, color: Colors.green, size: 36),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Student ID Verified!',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Roll No: ${state.verifiedRollNumber ?? "SXUK/2026/01"}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Campus: ${state.selectedCollegeShortCode}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  LucideIcons.camera,
                  size: 44,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Upload Student ID Card Photo',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gemini Vision OCR will verify your college name and roll number in seconds.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.tonalIcon(
                  icon: state.isVerifyingIdCard
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(LucideIcons.scanLine, size: 18),
                  label: Text(state.isVerifyingIdCard ? 'Scanning ID Card...' : 'Scan / Upload Student ID'),
                  onPressed: state.isVerifyingIdCard
                      ? null
                      : () {
                          ref.read(onboardingControllerProvider.notifier).verifyIdCard();
                        },
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPerkItem(IconData icon, String title, String description, ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
              ),
              Text(
                description,
                style: TextStyle(fontSize: 11.5, color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
