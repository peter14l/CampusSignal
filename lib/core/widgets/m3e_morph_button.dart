import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/motion.dart';

/// Material 3 Expressive (M3E) Shape Morphing Style Spec
enum M3EMorphShape {
  circleToSquircle,
  pillToSquircle,
  squircleToDiamond,
  asymmetricPill,
}

/// An authentic Material 3 Expressive (M3E) Shape-Morphing Icon Button.
///
/// In M3E, interactive buttons don't just change tint — their **geometry actively morphs**:
/// - Unselected state: Organic circular or soft pill geometry (e.g. radius 24)
/// - Pressed state: Tactile geometric compression (radius 14 + slight scale squeeze)
/// - Selected / Activated state: Vibrant expressive squircle (radius 8-10) with elevation bloom & glyph swap.
class M3EMorphIconButton extends StatefulWidget {
  final IconData icon;
  final IconData? selectedIcon;
  final bool isSelected;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final Color? color;
  final Color? selectedColor;
  final Color? backgroundColor;
  final Color? selectedBackgroundColor;
  final String? tooltip;
  final bool enableHaptics;
  final bool enableBloom;
  final M3EMorphShape morphShape;

  const M3EMorphIconButton({
    super.key,
    required this.icon,
    this.selectedIcon,
    this.isSelected = false,
    this.onPressed,
    this.size = 40,
    this.iconSize = 20,
    this.color,
    this.selectedColor,
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.tooltip,
    this.enableHaptics = true,
    this.enableBloom = true,
    this.morphShape = M3EMorphShape.circleToSquircle,
  });

  /// Quick preset for AppBars & Header action triggers
  const M3EMorphIconButton.appBar({
    super.key,
    required this.icon,
    this.selectedIcon,
    this.isSelected = false,
    this.onPressed,
    this.size = 38,
    this.iconSize = 18,
    this.color,
    this.selectedColor,
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.tooltip,
    this.enableHaptics = true,
    this.enableBloom = true,
    this.morphShape = M3EMorphShape.circleToSquircle,
  });

  /// Quick preset for Event Cards & Floating action toggles (Bookmarks, Reminders, Likes)
  const M3EMorphIconButton.cardToggle({
    super.key,
    required this.icon,
    this.selectedIcon,
    this.isSelected = false,
    this.onPressed,
    this.size = 36,
    this.iconSize = 18,
    this.color,
    this.selectedColor,
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.tooltip,
    this.enableHaptics = true,
    this.enableBloom = true,
    this.morphShape = M3EMorphShape.circleToSquircle,
  });

  @override
  State<M3EMorphIconButton> createState() => _M3EMorphIconButtonState();
}

class _M3EMorphIconButtonState extends State<M3EMorphIconButton>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _pressScaleAnimation;

  late AnimationController _morphController;
  late Animation<double> _morphAnimation;
  late Animation<double> _iconRotationAnimation;
  late Animation<double> _iconScaleAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Tactile press controller (fast 90ms entry, smooth 160ms return)
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 160),
    );

    _pressScaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: AppMotion.emphasizedAccelerate,
        reverseCurve: AppMotion.emphasizedDecelerate,
      ),
    );

    // 2. M3 Expressive Geometry & State Morph Controller
    _morphController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      value: widget.isSelected ? 1.0 : 0.0,
    );

    _morphAnimation = CurvedAnimation(
      parent: _morphController,
      curve: AppMotion.emphasizedDecelerate,
      reverseCurve: AppMotion.emphasizedAccelerate,
    );

    // Icon Expressive Swivel (anticipation twist into settle)
    _iconRotationAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -0.06)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.06, end: 0.04)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.04, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 30,
      ),
    ]).animate(_morphController);

    // Icon Expressive Pop
    _iconScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.80)
            .chain(CurveTween(curve: Curves.easeInQuad)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.80, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
    ]).animate(_morphController);
  }

  @override
  void didUpdateWidget(covariant M3EMorphIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _morphController.forward();
      } else {
        _morphController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _pressController.dispose();
    _morphController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      _pressController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      if (widget.enableHaptics) {
        HapticFeedback.lightImpact();
      }
      _pressController.reverse();
      widget.onPressed!();
    }
  }

  void _handleTapCancel() {
    _pressController.reverse();
  }

  /// Resolves the dynamically morphed BorderRadius based on the M3E morph shape
  BorderRadius _resolveMorphedRadius(double morphT, double size) {
    switch (widget.morphShape) {
      case M3EMorphShape.circleToSquircle:
        // Circle (size/2) -> Expressive Squircle (size * 0.26)
        final unselectedRadius = size / 2;
        final selectedRadius = size * 0.26;
        final current = unselectedRadius + (selectedRadius - unselectedRadius) * morphT;
        return BorderRadius.circular(current);

      case M3EMorphShape.asymmetricPill:
        // Symmetrical pill -> Asymmetric Expressive Leaf Shape
        return BorderRadius.only(
          topLeft: Radius.circular(size * (0.5 - 0.22 * morphT)),
          topRight: Radius.circular(size * (0.5 - 0.05 * morphT)),
          bottomRight: Radius.circular(size * (0.5 - 0.22 * morphT)),
          bottomLeft: Radius.circular(size * (0.5 - 0.05 * morphT)),
        );

      case M3EMorphShape.pillToSquircle:
      case M3EMorphShape.squircleToDiamond:
        final unselectedRadius = size * 0.45;
        final selectedRadius = size * 0.22;
        final current = unselectedRadius + (selectedRadius - unselectedRadius) * morphT;
        return BorderRadius.circular(current);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Unselected & Selected Color Palette
    final defaultBg = widget.backgroundColor ??
        colorScheme.surfaceContainerHighest.withValues(alpha: 0.45);
    final activeBg = widget.selectedBackgroundColor ??
        colorScheme.primaryContainer;

    final defaultFg = widget.color ?? colorScheme.onSurfaceVariant;
    final activeFg = widget.selectedColor ?? colorScheme.onPrimaryContainer;

    final activeIcon = widget.isSelected
        ? (widget.selectedIcon ?? widget.icon)
        : widget.icon;

    Widget buttonContent = AnimatedBuilder(
      animation: Listenable.merge([_pressController, _morphController]),
      builder: (context, child) {
        final morphT = _morphAnimation.value;
        final currentRadius = _resolveMorphedRadius(morphT, widget.size);

        // Interpolated background color
        final currentBg = Color.lerp(defaultBg, activeBg, morphT)!;
        final currentFg = Color.lerp(defaultFg, activeFg, morphT)!;

        // Border interpolation (from subtle outline to seamless container)
        final borderAlpha = (1.0 - morphT) * 0.35;
        final borderColor = colorScheme.outlineVariant.withValues(alpha: borderAlpha);

        return Transform.scale(
          scale: _pressScaleAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: currentBg,
              borderRadius: currentRadius,
              border: Border.all(
                color: borderColor,
                width: 1.0,
              ),
              boxShadow: [
                if (widget.enableBloom && morphT > 0.05)
                  BoxShadow(
                    color: activeBg.withValues(alpha: 0.35 * morphT),
                    blurRadius: 8 * morphT,
                    spreadRadius: 1 * morphT,
                    offset: Offset(0, 2 * morphT),
                  ),
              ],
            ),
            child: Center(
              child: Transform.rotate(
                angle: _iconRotationAnimation.value * math.pi,
                child: Transform.scale(
                  scale: _iconScaleAnimation.value,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    switchInCurve: AppMotion.spring,
                    switchOutCurve: AppMotion.emphasizedAccelerate,
                    transitionBuilder: (child, anim) => ScaleTransition(
                      scale: anim,
                      child: FadeTransition(opacity: anim, child: child),
                    ),
                    child: Icon(
                      activeIcon,
                      key: ValueKey('${widget.isSelected}_${activeIcon.codePoint}'),
                      size: widget.iconSize,
                      color: currentFg,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    Widget gestureWidget = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: buttonContent,
    );

    if (widget.tooltip != null && widget.tooltip!.isNotEmpty) {
      return Tooltip(
        message: widget.tooltip!,
        waitDuration: const Duration(milliseconds: 500),
        child: gestureWidget,
      );
    }

    return gestureWidget;
  }
}

/// An Expressive M3 Button with Corner Geometry Morphing on Touch & State.
class M3EMorphButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? pressedBackgroundColor;
  final EdgeInsetsGeometry padding;
  final double unselectedRadius;
  final double pressedRadius;
  final bool isElevated;

  const M3EMorphButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.pressedBackgroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    this.unselectedRadius = 24,
    this.pressedRadius = 12,
    this.isElevated = false,
  });

  @override
  State<M3EMorphButton> createState() => _M3EMorphButtonState();
}

class _M3EMorphButtonState extends State<M3EMorphButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _radiusAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      reverseDuration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: AppMotion.emphasizedAccelerate),
    );

    _radiusAnimation = Tween<double>(
      begin: widget.unselectedRadius,
      end: widget.pressedRadius,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppMotion.emphasizedAccelerate,
        reverseCurve: AppMotion.emphasizedDecelerate,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final defaultBg = widget.backgroundColor ?? colorScheme.primary;
    final pressedBg = widget.pressedBackgroundColor ?? colorScheme.primaryContainer;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        HapticFeedback.lightImpact();
        _controller.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final currentBg = Color.lerp(defaultBg, pressedBg, _controller.value)!;

          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                color: currentBg,
                borderRadius: BorderRadius.circular(_radiusAnimation.value),
                boxShadow: [
                  if (widget.isElevated)
                    BoxShadow(
                      color: defaultBg.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}
