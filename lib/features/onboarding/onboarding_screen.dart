import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/motion.dart';
import '../../core/widgets/department_picker_modal.dart';
import 'onboarding_controller.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _skillInputController = TextEditingController();
  final TextEditingController _interestInputController = TextEditingController();

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
    _nameController.dispose();
    _skillInputController.dispose();
    _interestInputController.dispose();
    super.dispose();
  }

  void _onNextPressed() async {
    final onboardingCtrl = ref.read(onboardingControllerProvider.notifier);
    final state = ref.read(onboardingControllerProvider);

    if (state.currentStep == 0) {
      onboardingCtrl.updateFullName(_nameController.text.trim());
      onboardingCtrl.nextStep();
    } else {
      final success = await onboardingCtrl.completeOnboarding();
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile setup complete! Welcome to CampusSignal.'),
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
            state.currentStep == 0 ? 'Academic Details' : 'Interests & Skills',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          leading: state.currentStep > 0
              ? IconButton(
                  icon: const Icon(LucideIcons.arrowLeft),
                  onPressed: _onBackPressed,
                )
              : null,
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Top Progress Indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AnimatedContainer(
                        duration: AppMotion.durationMedium2,
                        height: 4,
                        decoration: BoxDecoration(
                          color: state.currentStep >= 1
                              ? colorScheme.primary
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable Step Body
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: AnimatedSwitcher(
                    duration: AppMotion.durationMedium3,
                    switchInCurve: AppMotion.spring,
                    switchOutCurve: AppMotion.emphasizedAccelerate,
                    child: state.currentStep == 0
                        ? _buildStep1Academics(context, state, theme)
                        : _buildStep2Personalize(context, state, theme),
                  ),
                ),
              ),

              // Bottom Navigation Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLowest,
                  border: Border(
                    top: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (state.currentStep > 0)
                      OutlinedButton.icon(
                        onPressed: state.isSaving ? null : _onBackPressed,
                        icon: const Icon(LucideIcons.arrowLeft, size: 16),
                        label: const Text('Back'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      )
                    else
                      const SizedBox(width: 20),
                    const Spacer(),
                    FilledButton(
                      onPressed: state.isSaving ? null : _onNextPressed,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: state.isSaving
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onPrimary,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  state.currentStep == 0 ? 'Next: Personalize' : 'Complete & Launch Feed',
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  state.currentStep == 0 ? LucideIcons.arrowRight : LucideIcons.sparkles,
                                  size: 16,
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1Academics(BuildContext context, OnboardingState state, ThemeData theme) {
    final onboardingCtrl = ref.read(onboardingControllerProvider.notifier);
    final colorScheme = theme.colorScheme;

    return Column(
      key: const ValueKey('step_1_academics'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User Profile Header Card (if fetched from Google)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              if (state.avatarUrl != null && state.avatarUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: CachedNetworkImage(
                    imageUrl: state.avatarUrl!,
                    width: 48,
                    height: 48,
                    memCacheWidth: 120,
                    memCacheHeight: 120,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => _buildAvatarPlaceholder(colorScheme),
                  ),
                )
              else
                _buildAvatarPlaceholder(colorScheme),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.fullName.isNotEmpty ? state.fullName : 'SXUK Student',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (state.collegeEmail != null)
                      Text(
                        state.collegeEmail!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(LucideIcons.circleCheck, color: colorScheme.primary, size: 20),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Text(
          'Select your Department & Semester',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'We use this to rank notices, hackathons, and eligibility rules specific to your course.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),

        if (state.errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.alertCircle, color: colorScheme.onErrorContainer, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.errorMessage!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Full Name Field
        Text(
          'Full Name',
          style: theme.textTheme.titleSmall?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            prefixIcon: Icon(LucideIcons.user, color: colorScheme.onSurfaceVariant, size: 18),
            hintText: 'e.g. Aditi Sharma',
          ),
          onChanged: (val) => onboardingCtrl.updateFullName(val),
        ),
        const SizedBox(height: 20),

        // Department / Degree Program Selector
        Text(
          'Department / Degree Program *',
          style: theme.textTheme.titleSmall?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            _showDepartmentPicker(context, state.branch, (selected) {
              onboardingCtrl.updateBranch(selected);
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.graduationCap, color: colorScheme.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    state.branch != null && state.branch!.isNotEmpty
                        ? state.branch!
                        : 'Select your degree programme',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: state.branch != null && state.branch!.isNotEmpty
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Icon(LucideIcons.chevronDown, color: colorScheme.onSurfaceVariant, size: 18),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Semester Selector Chips (Semester 1 to 8 / 10)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Current Semester *',
              style: theme.textTheme.titleSmall?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w700),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Year ${state.year}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(8, (i) {
            final sem = i + 1;
            final isSelected = state.semester == sem;
            return ChoiceChip(
              label: Text('Semester $sem'),
              selected: isSelected,
              onSelected: (_) => onboardingCtrl.updateSemester(sem),
              selectedColor: colorScheme.primaryContainer,
              backgroundColor: colorScheme.surfaceContainer,
              labelStyle: TextStyle(
                color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            );
          }),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildStep2Personalize(BuildContext context, OnboardingState state, ThemeData theme) {
    final onboardingCtrl = ref.read(onboardingControllerProvider.notifier);
    final colorScheme = theme.colorScheme;

    return Column(
      key: const ValueKey('step_2_personalize'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personalize Interests & Skills',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Select from pre-made chips to train the recommendation engine on what matters to you.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),

        if (state.errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.alertCircle, color: colorScheme.onErrorContainer, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.errorMessage!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Section 1: Pre-made Interests
        Row(
          children: [
            Icon(LucideIcons.sparkles, size: 18, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'CAMPUS INTERESTS & EVENTS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: colorScheme.primary,
              ),
            ),
          ],
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
              avatar: isSelected ? Icon(LucideIcons.check, size: 14, color: colorScheme.onPrimaryContainer) : null,
              onSelected: (_) => onboardingCtrl.toggleInterest(interest),
              selectedColor: colorScheme.primaryContainer,
              backgroundColor: colorScheme.surfaceContainer,
              labelStyle: TextStyle(
                color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
              showCheckmark: false,
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
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _addCustomInterest(),
                decoration: InputDecoration(
                  hintText: 'Add custom interest...',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  suffixIcon: IconButton(
                    icon: Icon(LucideIcons.circlePlus, color: colorScheme.primary, size: 20),
                    onPressed: _addCustomInterest,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        // Section 2: Pre-made Skills
        Row(
          children: [
            Icon(LucideIcons.wrench, size: 18, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'SKILLS & DOMAINS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: colorScheme.primary,
              ),
            ),
          ],
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
              avatar: isSelected ? Icon(LucideIcons.check, size: 14, color: colorScheme.onSecondaryContainer) : null,
              onSelected: (_) => onboardingCtrl.toggleSkill(skill),
              selectedColor: colorScheme.secondaryContainer,
              backgroundColor: colorScheme.surfaceContainer,
              labelStyle: TextStyle(
                color: isSelected ? colorScheme.onSecondaryContainer : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
              showCheckmark: false,
            );
          }).toList(),
        ),
        const SizedBox(height: 12),

        // Custom Skill Input
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _skillInputController,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _addCustomSkill(),
                decoration: InputDecoration(
                  hintText: 'Add custom skill (e.g. Go, Figma, SQL)...',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  suffixIcon: IconButton(
                    icon: Icon(LucideIcons.circlePlus, color: colorScheme.primary, size: 20),
                    onPressed: _addCustomSkill,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildAvatarPlaceholder(ColorScheme colorScheme) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(LucideIcons.user, color: colorScheme.onPrimary, size: 24),
      ),
    );
  }

  void _showDepartmentPicker(
    BuildContext context,
    String? currentSelected,
    ValueChanged<String> onSelected,
  ) {
    DepartmentPickerSheet.show(
      context,
      currentSelection: currentSelected,
      onSelected: onSelected,
    );
  }
}
