import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/motion.dart';

/// A refined, purposeful interactive icon button with subtle M3 tactile feedback,
/// smooth outline-to-filled state morphing, and gentle ripple for toggle actions.
class MicroAnimatedIconButton extends StatefulWidget {
  final Widget? icon;
  final IconData? iconData;
  final Widget? selectedIcon;
  final IconData? selectedIconData;
  final bool isSelected;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final Color? color;
  final Color? selectedColor;
  final Color? backgroundColor;
  final Color? splashColor;
  final ShapeBorder? shape;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final String? tooltip;
  final bool enableHaptic;
  final bool enableGlowBurst;
  final double pressedScale;

  const MicroAnimatedIconButton({
    super.key,
    this.icon,
    this.iconData,
    this.selectedIcon,
    this.selectedIconData,
    this.isSelected = false,
    this.onPressed,
    this.size = 40,
    this.iconSize = 20,
    this.color,
    this.selectedColor,
    this.backgroundColor,
    this.splashColor,
    this.shape,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.all(8),
    this.tooltip,
    this.enableHaptic = true,
    this.enableGlowBurst = true,
    this.pressedScale = 0.94,
  }) : assert(icon != null || iconData != null, 'Provide either icon or iconData');

  /// Circular frosted or solid badge button (ideal for AppBars and quick actions)
  const MicroAnimatedIconButton.circle({
    super.key,
    this.icon,
    this.iconData,
    this.selectedIcon,
    this.selectedIconData,
    this.isSelected = false,
    this.onPressed,
    this.size = 38,
    this.iconSize = 18,
    this.color,
    this.selectedColor,
    this.backgroundColor,
    this.splashColor,
    this.borderRadius = 19,
    this.padding = const EdgeInsets.all(8),
    this.tooltip,
    this.enableHaptic = true,
    this.enableGlowBurst = true,
    this.pressedScale = 0.93,
  }) : shape = const CircleBorder();

  /// Bordered squircle icon button
  const MicroAnimatedIconButton.squircle({
    super.key,
    this.icon,
    this.iconData,
    this.selectedIcon,
    this.selectedIconData,
    this.isSelected = false,
    this.onPressed,
    this.size = 36,
    this.iconSize = 18,
    this.color,
    this.selectedColor,
    this.backgroundColor,
    this.splashColor,
    this.borderRadius = 10,
    this.padding = const EdgeInsets.all(6),
    this.tooltip,
    this.enableHaptic = true,
    this.enableGlowBurst = true,
    this.pressedScale = 0.93,
  }) : shape = null;

  @override
  State<MicroAnimatedIconButton> createState() => _MicroAnimatedIconButtonState();
}

class _MicroAnimatedIconButtonState extends State<MicroAnimatedIconButton>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  late AnimationController _toggleController;
  late Animation<double> _toggleScaleAnimation;
  late Animation<double> _burstRadiusAnimation;
  late Animation<double> _burstOpacityAnimation;

  @override
  void initState() {
    super.initState();

    // Subtle M3 press response
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 180),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.pressedScale).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: Curves.easeInCubic,
        reverseCurve: Curves.easeOutCubic,
      ),
    );

    // Purposeful state toggle pop & ripple
    _toggleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _toggleScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.08)
            .chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.08, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInQuad)),
        weight: 60,
      ),
    ]).animate(_toggleController);

    _burstRadiusAnimation = Tween<double>(begin: 0.3, end: 1.25).animate(
      CurvedAnimation(parent: _toggleController, curve: Curves.easeOutQuad),
    );

    _burstOpacityAnimation = Tween<double>(begin: 0.45, end: 0.0).animate(
      CurvedAnimation(parent: _toggleController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(covariant MicroAnimatedIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      _toggleController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _pressController.dispose();
    _toggleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      _pressController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      if (widget.enableHaptic) {
        HapticFeedback.lightImpact();
      }
      _pressController.reverse();
      widget.onPressed!();
    }
  }

  void _handleTapCancel() {
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveColor = widget.isSelected
        ? (widget.selectedColor ?? colorScheme.primary)
        : (widget.color ?? colorScheme.onSurfaceVariant);

    final burstColor = widget.splashColor ??
        (widget.isSelected ? colorScheme.primary : colorScheme.primaryContainer);

    Widget iconWidget;
    if (widget.isSelected) {
      if (widget.selectedIcon != null) {
        iconWidget = widget.selectedIcon!;
      } else if (widget.selectedIconData != null) {
        iconWidget = Icon(
          widget.selectedIconData,
          size: widget.iconSize,
          color: effectiveColor,
        );
      } else if (widget.icon != null) {
        iconWidget = widget.icon!;
      } else {
        iconWidget = Icon(
          widget.iconData,
          size: widget.iconSize,
          color: effectiveColor,
        );
      }
    } else {
      if (widget.icon != null) {
        iconWidget = widget.icon!;
      } else {
        iconWidget = Icon(
          widget.iconData,
          size: widget.iconSize,
          color: effectiveColor,
        );
      }
    }

    final animatedChild = AnimatedBuilder(
      animation: Listenable.merge([_pressController, _toggleController]),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Radial Glow Burst Ring
            if (_toggleController.isAnimating && widget.enableGlowBurst)
              Positioned.fill(
                child: Transform.scale(
                  scale: _burstRadiusAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: widget.shape is CircleBorder
                          ? BoxShape.circle
                          : BoxShape.rectangle,
                      borderRadius: widget.shape is CircleBorder
                          ? null
                          : BorderRadius.circular(widget.borderRadius * 1.4),
                      border: Border.all(
                        color: burstColor.withValues(
                          alpha: _burstOpacityAnimation.value,
                        ),
                        width: 2.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: burstColor.withValues(
                            alpha: _burstOpacityAnimation.value * 0.35,
                          ),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Tactile Icon Container
            Transform.scale(
              scale: _scaleAnimation.value * _toggleScaleAnimation.value,
              child: child,
            ),
          ],
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? Colors.transparent,
          shape: widget.shape is CircleBorder ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: widget.shape is CircleBorder
              ? null
              : BorderRadius.circular(widget.borderRadius),
          border: widget.shape is! CircleBorder && widget.backgroundColor != null
              ? Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                  width: 1,
                )
              : null,
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: AppMotion.spring,
            switchOutCurve: AppMotion.emphasizedAccelerate,
            transitionBuilder: (child, anim) {
              return ScaleTransition(
                scale: anim,
                child: FadeTransition(
                  opacity: anim,
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey('${widget.isSelected}_${widget.iconData}'),
              child: iconWidget,
            ),
          ),
        ),
      ),
    );

    Widget result = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: animatedChild,
    );

    if (widget.tooltip != null && widget.tooltip!.isNotEmpty) {
      result = Tooltip(
        message: widget.tooltip!,
        waitDuration: const Duration(milliseconds: 600),
        child: result,
      );
    }

    return result;
  }
}

/// A lightweight interactive wrapper for subtle press response
class MicroAnimatedIcon extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final double bounceOvershoot;
  final bool enableHaptic;

  const MicroAnimatedIcon({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.94,
    this.bounceOvershoot = 1.05,
    this.enableHaptic = true,
  });

  @override
  State<MicroAnimatedIcon> createState() => _MicroAnimatedIconState();
}

class _MicroAnimatedIconState extends State<MicroAnimatedIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      reverseDuration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.pressedScale).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInQuad,
        reverseCurve: Curves.easeOutCubic,
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
    if (widget.onTap == null) {
      return widget.child;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        if (widget.enableHaptic) {
          HapticFeedback.lightImpact();
        }
        _controller.reverse();
        widget.onTap!();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
