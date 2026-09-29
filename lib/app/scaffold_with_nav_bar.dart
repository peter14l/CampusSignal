import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../core/theme/motion.dart';

/// Item specification for the Fluid Navigation Bar
class _NavItemSpec {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavItemSpec({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

/// M3 Expressive Scaffold with an Apple-inspired Fluid Spring Bottom Navigation Bar
/// Featuring a continuous sliding capsule with velocity stretch & snap physics (without blur shaders).
class ScaffoldWithNavBar extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  @override
  State<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends State<ScaffoldWithNavBar>
    with TickerProviderStateMixin {
  static const List<_NavItemSpec> _items = [
    _NavItemSpec(
      icon: LucideIcons.house,
      selectedIcon: LucideIcons.house,
      label: 'Home',
    ),
    _NavItemSpec(
      icon: LucideIcons.calendar,
      selectedIcon: LucideIcons.calendarDays,
      label: 'Calendar',
    ),
    _NavItemSpec(
      icon: LucideIcons.bookmark,
      selectedIcon: LucideIcons.bookmarkCheck,
      label: 'Saved',
    ),
    _NavItemSpec(
      icon: LucideIcons.user,
      selectedIcon: LucideIcons.circleUser,
      label: 'Profile',
    ),
  ];

  late AnimationController _slideController;
  late Animation<double> _slideAnimation;

  // Icon bounce & scale pop controller for selected tab
  late List<AnimationController> _iconBounceControllers;
  late List<Animation<double>> _iconBounceAnimations;

  int _previousIndex = 0;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.navigationShell.currentIndex;
    _previousIndex = _currentIndex;

    // 1. Fluid glide controller (320ms spring settle)
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    );

    _slideAnimation = CurvedAnimation(
      parent: _slideController,
      curve: AppMotion.emphasizedDecelerate,
      reverseCurve: AppMotion.emphasizedAccelerate,
    );

    // 2. Individual icon spring pop animations
    _iconBounceControllers = List.generate(
      _items.length,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 320),
      ),
    );

    _iconBounceAnimations = _iconBounceControllers.map((controller) {
      return TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 0.84)
              .chain(CurveTween(curve: Curves.easeInCubic)),
          weight: 25,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.84, end: 1.16)
              .chain(CurveTween(curve: Curves.easeOutBack)),
          weight: 45,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.16, end: 1.0)
              .chain(CurveTween(curve: Curves.easeOutCubic)),
          weight: 30,
        ),
      ]).animate(controller);
    }).toList();

    _slideController.value = 1.0;
  }

  @override
  void didUpdateWidget(ScaffoldWithNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final shellIndex = widget.navigationShell.currentIndex;
    if (shellIndex != _currentIndex) {
      _animateToTab(shellIndex);
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    for (final ctrl in _iconBounceControllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _animateToTab(int newIndex) {
    if (newIndex == _currentIndex) return;

    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = newIndex;
    });

    _slideController.forward(from: 0.0);
    _iconBounceControllers[newIndex].forward(from: 0.0);
  }

  void _onTap(int index) {
    if (index != _currentIndex) {
      HapticFeedback.selectionClick();
      _animateToTab(index);
    }
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentIndex > 0) {
          _onTap(0);
        }
      },
      child: Scaffold(
        body: widget.navigationShell,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            border: Border(
              top: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                width: 0.8,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          padding: EdgeInsets.only(
            bottom: math.max(bottomPadding, 8),
            top: 6,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              final tabWidth = totalWidth / _items.length;
              const capsuleWidth = 64.0;
              const capsuleHeight = 32.0;

              return AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) {
                  final progress = _slideAnimation.value;

                  // Compute active X center position between previous and target tab
                  final startCenterX = (_previousIndex * tabWidth) + (tabWidth / 2);
                  final targetCenterX = (_currentIndex * tabWidth) + (tabWidth / 2);
                  final currentCenterX =
                      startCenterX + (targetCenterX - startCenterX) * progress;

                  // Liquid spring stretch: indicator stretches in transit, snaps at destination
                  final travelDirection = targetCenterX >= startCenterX ? 1.0 : -1.0;
                  final stretchProgress = math.sin(progress * math.pi);
                  final stretchAmount = stretchProgress * 18.0 * travelDirection.abs();
                  final dynamicCapsuleWidth = capsuleWidth + stretchAmount;

                  return Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      // Continuous Fluid Sliding Capsule Indicator
                      Positioned(
                        left: currentCenterX - (dynamicCapsuleWidth / 2),
                        top: 2,
                        child: Container(
                          width: dynamicCapsuleWidth,
                          height: capsuleHeight,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withValues(alpha: 0.12),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Navigation Bar Tab Items Row
                      Row(
                        children: List.generate(_items.length, (index) {
                          final item = _items[index];
                          final isSelected = index == _currentIndex;

                          return Expanded(
                            child: InkWell(
                              onTap: () => _onTap(index),
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Animated Icon with Spring Bounce Pop
                                    SizedBox(
                                      height: capsuleHeight,
                                      child: Center(
                                        child: ScaleTransition(
                                          scale: isSelected
                                              ? _iconBounceAnimations[index]
                                              : const AlwaysStoppedAnimation(0.95),
                                          child: Icon(
                                            isSelected ? item.selectedIcon : item.icon,
                                            size: 21,
                                            color: isSelected
                                              ? colorScheme.onPrimaryContainer
                                              : colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    // Animated Label
                                    AnimatedDefaultTextStyle(
                                      duration: const Duration(milliseconds: 200),
                                      curve: Curves.easeOut,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        letterSpacing: -0.1,
                                        color: isSelected
                                            ? colorScheme.primary
                                            : colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
                                        fontFamily: theme.textTheme.bodyMedium?.fontFamily,
                                      ),
                                      child: Text(
                                        item.label,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
