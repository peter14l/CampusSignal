import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/motion.dart';
import 'interactive_spring.dart';

/// Material 3 Expressive Extended Floating Action Button & FAB Menu
/// Adheres strictly to official M3 Expressive guidelines:
/// - 56dp standard height
/// - Boxier 16dp rounded squircle corner radius (replaces legacy pill shape)
/// - PrimaryContainer tonal role with onPrimaryContainer contrast
/// - TitleMedium / LabelLarge expressive bold typography
/// - Anchored FAB Menu component with structured tonal cards & scope badges
/// - Spring-physics motion curves
class M3ESpeedDialFab extends StatefulWidget {
  final ValueChanged<bool>? onOpenChanged;

  const M3ESpeedDialFab({
    super.key,
    this.onOpenChanged,
  });

  @override
  State<M3ESpeedDialFab> createState() => M3ESpeedDialFabState();
}

class M3ESpeedDialFabState extends State<M3ESpeedDialFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotateAnimation;
  bool _isOpen = false;

  final List<Map<String, dynamic>> _menuActions = const [
    {
      'id': 'hackathon',
      'label': 'New Hackathon',
      'scopeHint': 'Pan-India',
      'icon': LucideIcons.code,
      'colorType': 'secondary',
    },
    {
      'id': 'fest',
      'label': 'Fest & Cultural',
      'scopeHint': 'Pan-India',
      'icon': LucideIcons.partyPopper,
      'colorType': 'tertiary',
    },
    {
      'id': 'club',
      'label': 'Club Activity',
      'scopeHint': 'Campus Only',
      'icon': LucideIcons.users,
      'colorType': 'primary',
    },
    {
      'id': 'internship',
      'label': 'Internship Drive',
      'scopeHint': 'Campus Only (Private)',
      'icon': LucideIcons.briefcase,
      'colorType': 'secondary',
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

  void close() {
    if (_isOpen) {
      _toggle();
    }
  }

  void _toggle() {
    HapticFeedback.selectionClick();
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
    widget.onOpenChanged?.call(_isOpen);
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

    return RepaintBoundary(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomRight,
        children: [
          // Dismiss Scrim when Menu is expanded
          if (_isOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggle,
                behavior: HitTestBehavior.opaque,
                child: const SizedBox.expand(),
              ),
            ),

          Align(
            alignment: Alignment.bottomRight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Material 3 Expressive FAB Menu
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
                          children: _menuActions.map((action) {
                            final isPrivate = action['id'] == 'internship';
                            final isPanIndia = action['scopeHint'] == 'Pan-India';

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: InteractiveSpring(
                                onTap: () => _openAnnouncement(action['id'] as String),
                                pressedScale: 0.97,
                                child: Container(
                                  constraints: const BoxConstraints(minWidth: 215, minHeight: 52),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerLowest,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.08),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: isPanIndia
                                              ? colorScheme.primaryContainer
                                              : (isPrivate
                                                  ? colorScheme.tertiaryContainer
                                                  : colorScheme.secondaryContainer),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          action['icon'] as IconData,
                                          size: 18,
                                          color: isPanIndia
                                              ? colorScheme.onPrimaryContainer
                                              : (isPrivate
                                                  ? colorScheme.onTertiaryContainer
                                                  : colorScheme.onSecondaryContainer),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            action['label'] as String,
                                            style: textTheme.labelLarge?.copyWith(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w700,
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              if (isPrivate)
                                                Padding(
                                                  padding: const EdgeInsets.only(right: 3),
                                                  child: Icon(LucideIcons.lock, size: 10, color: colorScheme.tertiary),
                                                ),
                                              Text(
                                                action['scopeHint'] as String,
                                                style: textTheme.labelSmall?.copyWith(
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: isPanIndia
                                                      ? colorScheme.primary
                                                      : (isPrivate ? colorScheme.tertiary : colorScheme.onSurfaceVariant),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 12),
                                      Icon(LucideIcons.chevronRight, size: 14, color: colorScheme.outline),
                                    ],
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

                // Material 3 Expressive Extended Floating Action Button (Post Signal)
                InteractiveSpring(
                  onTap: _toggle,
                  pressedScale: 0.95,
                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: _isOpen ? colorScheme.surfaceContainerHighest : colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isOpen
                            ? colorScheme.outlineVariant
                            : colorScheme.primary.withValues(alpha: 0.3),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _isOpen
                              ? Colors.black.withValues(alpha: 0.1)
                              : colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RotationTransition(
                          turns: _rotateAnimation,
                          child: Icon(
                            _isOpen ? LucideIcons.x : LucideIcons.plus,
                            color: _isOpen ? colorScheme.onSurface : colorScheme.onPrimaryContainer,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _isOpen ? 'Close' : 'Post Signal',
                          style: textTheme.titleMedium?.copyWith(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                            color: _isOpen ? colorScheme.onSurface : colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
