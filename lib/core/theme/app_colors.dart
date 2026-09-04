import 'package:flutter/material.dart';

/// CampusSignal Material 3 Expressive Color Palette
class AppColors {
  // Brand / Primary
  static const Color primary = Color(0xFF353ABD);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF4F55D6);
  static const Color onPrimaryContainer = Color(0xFFE2E1FF);
  static const Color primaryFixed = Color(0xFFE1E0FF);
  static const Color primaryFixedDim = Color(0xFFBFC1FF);
  static const Color onPrimaryFixed = Color(0xFF03006D);
  static const Color onPrimaryFixedVariant = Color(0xFF2E32B6);
  static const Color inversePrimary = Color(0xFFBFC1FF);

  // Secondary
  static const Color secondary = Color(0xFF5B5B7B);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFDBD9FF);
  static const Color onSecondaryContainer = Color(0xFF5E5E7E);
  static const Color secondaryFixed = Color(0xFFE1DFFF);
  static const Color secondaryFixedDim = Color(0xFFC4C3E8);
  static const Color onSecondaryFixed = Color(0xFF181935);
  static const Color onSecondaryFixedVariant = Color(0xFF444462);

  // Tertiary
  static const Color tertiary = Color(0xFF7E3900);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFA34C00);
  static const Color onTertiaryContainer = Color(0xFFFFDCC9);
  static const Color tertiaryFixed = Color(0xFFFFDBC8);
  static const Color tertiaryFixedDim = Color(0xFFFFB68B);
  static const Color onTertiaryFixed = Color(0xFF321300);
  static const Color onTertiaryFixedVariant = Color(0xFF743400);
  static const Color tertiaryAccent = Color(0xFF82524A);

  // Surface Tones (Tonal Layering Elevation)
  static const Color surface = Color(0xFFFBF8FF);
  static const Color surfaceBright = Color(0xFFFEF7FF);
  static const Color surfaceDim = Color(0xFFDBD8E4);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF5F2FD);
  static const Color surfaceContainer = Color(0xFFEFECF8);
  static const Color surfaceContainerHigh = Color(0xFFE9E7F2);
  static const Color surfaceContainerHighest = Color(0xFFE4E1EC);
  static const Color surfaceVariant = Color(0xFFE4E1EC);
  static const Color surfaceTint = Color(0xFF484ECF);

  // On Surface & Background
  static const Color onSurface = Color(0xFF1B1B23);
  static const Color onSurfaceVariant = Color(0xFF454554);
  static const Color inverseSurface = Color(0xFF303038);
  static const Color inverseOnSurface = Color(0xFFF2EFFB);
  static const Color background = Color(0xFFFBF8FF);
  static const Color onBackground = Color(0xFF1B1B23);

  // Outline
  static const Color outline = Color(0xFF767685);
  static const Color outlineVariant = Color(0xFFC6C5D6);

  // Error & Alerts
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);
  static const Color errorAlert = Color(0xFFBA1A1A);

  // Success
  static const Color success = Color(0xFF2E7D32);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color successContainer = Color(0xFFE8F5E9);
  static const Color onSuccessContainer = Color(0xFF1B5E20);

  // Dark Scheme Surface Tones based on #0C0F14
  static const Color darkSurface = Color(0xFF0C0F14);
  static const Color darkOnSurface = Color(0xFFEDEFF5);
  static const Color darkOnSurfaceVariant = Color(0xFF9BA5B9);
  static const Color darkSurfaceDim = Color(0xFF0C0F14);
  static const Color darkSurfaceBright = Color(0xFF1A1F29);
  static const Color darkSurfaceContainerLowest = Color(0xFF090C10);
  static const Color darkSurfaceContainerLow = Color(0xFF141820);
  static const Color darkSurfaceContainer = Color(0xFF1B212B);
  static const Color darkSurfaceContainerHigh = Color(0xFF232A37);
  static const Color darkSurfaceContainerHighest = Color(0xFF2D3545);
  static const Color darkOutline = Color(0xFF454F63);
  static const Color darkOutlineVariant = Color(0xFF242B38);

  /// Helper to get category container background color
  static Color getCategoryContainerColor(String category) {
    switch (category.toLowerCase().trim()) {
      case 'hackathon':
      case 'hackathons':
        return secondaryContainer;
      case 'internship':
      case 'internships':
        return const Color(0xFFFFDCC9);
      case 'workshop':
      case 'workshops':
        return const Color(0xFFE2E1FF);
      case 'fest':
      case 'fests':
        return const Color(0xFFFFE082);
      case 'seminar':
      case 'seminars':
        return const Color(0xFFD1E7DD);
      case 'club':
      case 'clubs':
        return const Color(0xFFE0E0FF);
      case 'sports':
        return const Color(0xFFFFE0B2);
      default:
        return secondaryContainer;
    }
  }

  /// Helper to get category foreground / text color
  static Color getCategoryTextColor(String category) {
    switch (category.toLowerCase().trim()) {
      case 'hackathon':
      case 'hackathons':
        return onSecondaryContainer;
      case 'internship':
      case 'internships':
        return tertiaryContainer;
      case 'workshop':
      case 'workshops':
        return primaryContainer;
      case 'fest':
      case 'fests':
        return const Color(0xFF664D03);
      case 'seminar':
      case 'seminars':
        return const Color(0xFF0F5132);
      case 'club':
      case 'clubs':
        return onPrimaryFixedVariant;
      case 'sports':
        return const Color(0xFF8B4500);
      default:
        return onSecondaryContainer;
    }
  }
}
