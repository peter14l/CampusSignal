import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/motion.dart';
import '../../core/widgets/interactive_spring.dart';
import 'auth_controller.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: AppMotion.durationMedium4,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: AppMotion.emphasizedDecelerate,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: AppMotion.spring,
    ));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final fn in _otpFocusNodes) {
      fn.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _otpFocusNodes[index + 1].requestFocus();
      } else {
        _otpFocusNodes[index].unfocus();
        _submitOtp();
      }
    } else if (value.isEmpty && index > 0) {
      _otpFocusNodes[index - 1].requestFocus();
    }
  }

  String _getCombinedOtp() {
    return _otpControllers.map((c) => c.text).join();
  }

  Future<void> _handleGoogleSignIn({bool forceMockExisting = false, bool forceMockNew = false}) async {
    final authCtrl = ref.read(authControllerProvider.notifier);
    GoogleAuthStatus status;

    if (forceMockExisting) {
      status = await authCtrl.demoGoogleSignIn(isExistingUser: true);
    } else if (forceMockNew) {
      status = await authCtrl.demoGoogleSignIn(isExistingUser: false);
    } else {
      status = await authCtrl.signInWithGoogle();
    }

    if (!mounted) return;

    if (status == GoogleAuthStatus.authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome back, ${ref.read(authControllerProvider).profile?.fullName ?? "Student"}!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go('/feed');
    } else if (status == GoogleAuthStatus.needsOnboarding) {
      context.go('/onboarding');
    } else if (status == GoogleAuthStatus.failed) {
      final errorMsg = ref.read(authControllerProvider).errorMessage ?? 'Google Sign-in failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _submitEmail() async {
    final email = _emailController.text.trim();
    final authCtrl = ref.read(authControllerProvider.notifier);
    final success = await authCtrl.sendOtp(email);
    if (success && mounted) {
      _otpControllers.first.clear();
      _otpFocusNodes.first.requestFocus();
    }
  }

  Future<void> _submitOtp() async {
    final otp = _getCombinedOtp();
    if (otp.length != 6) return;

    final authCtrl = ref.read(authControllerProvider.notifier);
    final success = await authCtrl.verifyOtp(otp);
    if (success && mounted) {
      final profile = ref.read(authControllerProvider).profile;
      if (profile != null && profile.isOnboardingComplete) {
        context.go('/feed');
      } else {
        context.go('/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // Background ambient gradient blobs
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.tertiaryContainer.withValues(alpha: 0.35),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Brand Hero Icon
                          Center(
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 92,
                                  height: 92,
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(28),
                                    boxShadow: [
                                      BoxShadow(
                                        color: colorScheme.primary
                                            .withValues(alpha: 0.08),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Icon(
                                      LucideIcons.radio,
                                      size: 44,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: -6,
                                  right: -6,
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: colorScheme.tertiaryContainer,
                                      shape: BoxShape.circle,
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      LucideIcons.graduationCap,
                                      size: 16,
                                      color: colorScheme.onTertiaryContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Title & Subtitle
                          Text(
                            authState.isOtpSent
                                ? 'Enter Verification Code'
                                : 'Welcome to CampusSignal',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            authState.isOtpSent
                                ? 'We sent a 6-digit code to ${authState.email}'
                                : 'Sign in with your Google or college account to discover personalized SXUK opportunities.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 28),

                          // Error Banner
                          if (authState.errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: colorScheme.errorContainer
                                    .withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(LucideIcons.alertCircle,
                                      color: colorScheme.onErrorContainer,
                                      size: 18),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      authState.errorMessage!,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onErrorContainer,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          if (!authState.isOtpSent) ...[
                            // Primary Google Sign-In Button
                            InteractiveSpring(
                              onTap: authState.isLoading ? null : () => _handleGoogleSignIn(),
                              child: Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: colorScheme.outlineVariant,
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildGoogleGLogo(),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Continue with Google',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Divider Row
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'OR USE COLLEGE EMAIL',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.8,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Form Area: Email or OTP
                          AnimatedSwitcher(
                            duration: AppMotion.durationMedium3,
                            switchInCurve: AppMotion.spring,
                            switchOutCurve: AppMotion.emphasizedAccelerate,
                            child: authState.isOtpSent
                                ? _buildOtpSection(context, authState)
                                : _buildEmailSection(context, authState),
                          ),

                          const SizedBox(height: 24),

                          // Quick Test Triggers for Google Sign-in Paths
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(LucideIcons.sparkles, size: 14, color: colorScheme.primary),
                                    const SizedBox(width: 6),
                                    Text(
                                      'GOOGLE AUTH PREVIEW MODES',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.6,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: authState.isLoading
                                            ? null
                                            : () => _handleGoogleSignIn(forceMockExisting: true),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                        child: const Text(
                                          'Existing User\n(Direct Feed)',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: authState.isLoading
                                            ? null
                                            : () => _handleGoogleSignIn(forceMockNew: true),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                        child: const Text(
                                          'New User\n(Department/Chips)',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Footer Terms Note
                          Text(
                            'By continuing you agree to the SXUK CampusSignal Terms & Privacy Policy',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleGLogo() {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(
        painter: _GoogleGLogoPainter(),
      ),
    );
  }

  Widget _buildEmailSection(BuildContext context, AuthState authState) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      key: const ValueKey('email_section'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submitEmail(),
          decoration: InputDecoration(
            prefixIcon: Icon(LucideIcons.mail,
                color: colorScheme.onSurfaceVariant, size: 18),
            hintText: 'e.g. name@sxuk.edu.in',
            labelText: 'College Email OTP',
            helperText: 'Must end with @sxuk.edu.in',
            suffixIcon: _emailController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(LucideIcons.x, size: 18),
                    onPressed: () {
                      _emailController.clear();
                      setState(() {});
                    },
                  )
                : null,
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: authState.isLoading ||
                  _emailController.text.trim().isEmpty
              ? null
              : _submitEmail,
          child: authState.isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: colorScheme.onPrimary,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Send Login Code'),
                    SizedBox(width: 8),
                    Icon(LucideIcons.arrowRight, size: 18),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildOtpSection(BuildContext context, AuthState authState) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      key: const ValueKey('otp_section'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 6-digit OTP fields
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 48,
              height: 58,
              child: TextField(
                controller: _otpControllers[index],
                focusNode: _otpFocusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHigh,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: colorScheme.primary, width: 2),
                  ),
                ),
                onChanged: (val) => _onOtpChanged(index, val),
              ),
            );
          }),
        ),
        const SizedBox(height: 24),

        FilledButton(
          onPressed: authState.isLoading ? null : _submitOtp,
          child: authState.isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: colorScheme.onPrimary,
                  ),
                )
              : const Text('Verify & Enter'),
        ),
        const SizedBox(height: 16),

        // Resend or Change Email Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                ref.read(authControllerProvider.notifier).resetOtpFlow();
              },
              child: const Text('Change Email'),
            ),
            if (authState.resendCountdown > 0)
              Text(
                'Resend in ${authState.resendCountdown}s',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              )
            else
              TextButton(
                onPressed: () {
                  if (authState.email != null) {
                    ref
                        .read(authControllerProvider.notifier)
                        .sendOtp(authState.email!);
                  }
                },
                child: const Text('Resend OTP'),
              ),
          ],
        ),
      ],
    );
  }
}

class _GoogleGLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Draw multi-colored Google "G" icon
    final bluePaint = Paint()..color = const Color(0xFF4285F4)..style = PaintingStyle.fill;
    final redPaint = Paint()..color = const Color(0xFFEA4335)..style = PaintingStyle.fill;
    final yellowPaint = Paint()..color = const Color(0xFFFBBC05)..style = PaintingStyle.fill;
    final greenPaint = Paint()..color = const Color(0xFF34A853)..style = PaintingStyle.fill;

    final center = Offset(w / 2, h / 2);
    final radius = w / 2;

    // Draw Blue bar & arc
    final bluePath = Path()
      ..moveTo(center.dx, center.dy - radius * 0.2)
      ..lineTo(w, center.dy - radius * 0.2)
      ..lineTo(w, center.dy + radius * 0.2)
      ..lineTo(center.dx, center.dy + radius * 0.2)
      ..close();
    canvas.drawPath(bluePath, bluePaint);

    // Green quadrant
    final greenPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(Rect.fromCircle(center: center, radius: radius), 0.25 * 3.14, 0.5 * 3.14, false)
      ..close();
    canvas.drawPath(greenPath, greenPaint);

    // Yellow quadrant
    final yellowPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(Rect.fromCircle(center: center, radius: radius), 0.75 * 3.14, 0.5 * 3.14, false)
      ..close();
    canvas.drawPath(yellowPath, yellowPaint);

    // Red quadrant
    final redPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(Rect.fromCircle(center: center, radius: radius), 1.25 * 3.14, 0.5 * 3.14, false)
      ..close();
    canvas.drawPath(redPath, redPaint);

    // Center cutout
    final whitePaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.58, whitePaint);

    // Re-draw Blue crossbar
    final barPath = Path()
      ..moveTo(center.dx, center.dy - radius * 0.22)
      ..lineTo(w, center.dy - radius * 0.22)
      ..lineTo(w, center.dy + radius * 0.22)
      ..lineTo(center.dx, center.dy + radius * 0.22)
      ..close();
    canvas.drawPath(barPath, bluePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
