import 'package:flutter/material.dart';

/// Official branded App Logo Badge rendering the golden signal emblem
class AppLogoBadge extends StatelessWidget {
  final double size;
  final double borderRadius;
  final bool hasShadow;

  const AppLogoBadge({
    super.key,
    this.size = 56,
    this.borderRadius = 16,
    this.hasShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: size * 0.25,
                  offset: Offset(0, size * 0.08),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          'app_logo.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            final colorScheme = Theme.of(context).colorScheme;
            return Container(
              color: const Color(0xFF161616),
              child: Center(
                child: Icon(
                  Icons.radio,
                  size: size * 0.5,
                  color: colorScheme.primary,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
