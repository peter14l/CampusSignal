import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/motion.dart';
import 'interactive_spring.dart';

class M3ESpeedDialFab extends StatefulWidget {
  const M3ESpeedDialFab({super.key});

  @override
  State<M3ESpeedDialFab> createState() => _M3ESpeedDialFabState();
}

class _M3ESpeedDialFabState extends State<M3ESpeedDialFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotateAnimation;
  bool _isOpen = false;

  final List<Map<String, dynamic>> _quickActions = const [
    {
      'id': 'hackathon',
      'label': 'New Hackathon',
      'icon': LucideIcons.code,
      'colorKey': 'secondary',
    },
    {
      'id': 'fest',
      'label': 'Fest & Cultural',
      'icon': LucideIcons.partyPopper,
      'colorKey': 'tertiary',
    },
    {
      'id': 'club',
      'label': 'Club Activity',
      'icon': LucideIcons.users,
      'colorKey': 'primary',
    },
    {
      'id': 'internship',
      'label': 'Internship Drive',
      'icon': LucideIcons.briefcase,
      'colorKey': 'secondary',
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.durationMedium3,
      reverseDuration: AppMotion.durationShort3,
    );

    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: AppMotion.spring,
      reverseCurve: AppMotion.emphasizedAccelerate,
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 0.125).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppMotion.emphasizedDecelerate,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _openAnnouncement(String category) {
    _toggle();
    context.push('/create-announcement?category=$category');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Align(
      alignment: Alignment.bottomRight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Action Options with smooth size/fade transition
          Align(
            alignment: Alignment.bottomRight,
            child: SizeTransition(
              sizeFactor: _expandAnimation,
              axisAlignment: 1.0,
              child: FadeTransition(
                opacity: _expandAnimation,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: _quickActions.map((action) {
                      return Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InteractiveSpring(
                            onTap: () => _openAnnouncement(action['id'] as String),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: colorScheme.outlineVariant
                                      .withValues(alpha: 0.5),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    action['label'] as String,
                                    style: textTheme.labelMedium?.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: colorScheme.primaryContainer,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      action['icon'] as IconData,
                                      size: 16,
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),

          // Main M3 Expressive Floating Action Button
          InteractiveSpring(
            onTap: _toggle,
            pressedScale: 0.93,
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.primaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RotationTransition(
                    turns: _rotateAnimation,
                    child: Icon(
                      LucideIcons.plus,
                      color: colorScheme.onPrimary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isOpen ? 'Close' : 'Post Signal',
                    style: textTheme.labelLarge?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onPrimary,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
