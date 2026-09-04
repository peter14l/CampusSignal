import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Stitch Design System Tokens & Material 3 Expressive Theme configuration
class AppColors {
  AppColors._();

  // Core Light Tokens based on Deep SXUK Indigo (0xFF353ABD) with distinct tonal variations
  static const Color primary = Color(0xFF353ABD);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFE0E2FF);
  static const Color onPrimaryContainer = Color(0xFF050868);
  static const Color inversePrimary = Color(0xFFBEC2FF);

  static const Color secondary = Color(0xFF585C77);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFDDE1FF);
  static const Color onSecondaryContainer = Color(0xFF151931);

  static const Color tertiary = Color(0xFF824D1E);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFFFDCC4);
  static const Color onTertiaryContainer = Color(0xFF2E1500);
  static const Color tertiaryAccent = Color(0xFF965B2D);

  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  static const Color surface = Color(0xFFFAF8FE);
  static const Color onSurface = Color(0xFF1B1B22);
  static const Color onSurfaceVariant = Color(0xFF454653);
  static const Color surfaceDim = Color(0xFFDDD9E2);
  static const Color surfaceBright = Color(0xFFFAF8FE);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF4F2FA);
  static const Color surfaceContainer = Color(0xFFEEEBF4);
  static const Color surfaceContainerHigh = Color(0xFFE8E5EE);
  static const Color surfaceContainerHighest = Color(0xFFE2DFE9);
  static const Color surfaceVariant = Color(0xFFE2DFE9);
  static const Color inverseSurface = Color(0xFF303037);
  static const Color inverseOnSurface = Color(0xFFF2EFF7);

  static const Color outline = Color(0xFF757685);
  static const Color outlineVariant = Color(0xFFC6C5D6);
  static const Color surfaceTint = Color(0xFF353ABD);

  static const Color primaryFixed = Color(0xFFE0E2FF);
  static const Color primaryFixedDim = Color(0xFFBEC2FF);
  static const Color onPrimaryFixed = Color(0xFF050868);
  static const Color onPrimaryFixedVariant = Color(0xFF242A9E);

  static const Color secondaryFixed = Color(0xFFDDE1FF);
  static const Color secondaryFixedDim = Color(0xFFC2C5E4);
  static const Color onSecondaryFixed = Color(0xFF151931);
  static const Color onSecondaryFixedVariant = Color(0xFF40445E);

  static const Color tertiaryFixed = Color(0xFFFFDCC4);
  static const Color tertiaryFixedDim = Color(0xFFF6B888);
  static const Color onTertiaryFixed = Color(0xFF2E1500);
  static const Color onTertiaryFixedVariant = Color(0xFF663B0F);

  // Category specific tint colors
  static const Color categoryHackathon = Color(0xFF353ABD);
  static const Color categoryHackathonBg = Color(0xFFE0E2FF);
  static const Color categoryInternship = Color(0xFF824D1E);
  static const Color categoryInternshipBg = Color(0xFFFFDCC4);
  static const Color categoryWorkshop = Color(0xFF242A9E);
  static const Color categoryWorkshopBg = Color(0xFFEBEBFF);
  static const Color categoryFest = Color(0xFFA34C00);
  static const Color categoryFestBg = Color(0xFFFFE3D2);
  static const Color categorySeminar = Color(0xFF585C77);
  static const Color categorySeminarBg = Color(0xFFE8E5EE);
  static const Color categoryClub = Color(0xFF006874);
  static const Color categoryClubBg = Color(0xFFD6F6FC);
  static const Color categoryNetworking = Color(0xFF5355A9);
  static const Color categoryNetworkingBg = Color(0xFFE5E5FF);
  static const Color categorySports = Color(0xFF006C4C);
  static const Color categorySportsBg = Color(0xFFD2F8E7);

  // Dark Scheme Counterparts based on #0C0F14 obsidian slate base
  static const Color darkPrimary = Color(0xFFBEC2FF);
  static const Color darkOnPrimary = Color(0xFF050868);
  static const Color darkPrimaryContainer = Color(0xFF242A9E);
  static const Color darkOnPrimaryContainer = Color(0xFFE0E2FF);

  static const Color darkSecondary = Color(0xFFC2C5E4);
  static const Color darkOnSecondary = Color(0xFF2A2E47);
  static const Color darkSecondaryContainer = Color(0xFF40445E);
  static const Color darkOnSecondaryContainer = Color(0xFFDDE1FF);

  static const Color darkTertiary = Color(0xFFF6B888);
  static const Color darkOnTertiary = Color(0xFF4A2800);
  static const Color darkTertiaryContainer = Color(0xFF663B0F);
  static const Color darkOnTertiaryContainer = Color(0xFFFFDCC4);

  static const Color darkError = Color(0xFFFFB4AB);
  static const Color darkOnError = Color(0xFF690005);
  static const Color darkErrorContainer = Color(0xFF93000A);
  static const Color darkOnErrorContainer = Color(0xFFFFDAD6);

  // Surface Tonal Hierarchy based on #0C0F14
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
}

class AppTheme {
  AppTheme._();

  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.onPrimaryContainer,
    inversePrimary: AppColors.inversePrimary,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    secondaryContainer: AppColors.secondaryContainer,
    onSecondaryContainer: AppColors.onSecondaryContainer,
    tertiary: AppColors.tertiary,
    onTertiary: AppColors.onTertiary,
    tertiaryContainer: AppColors.tertiaryContainer,
    onTertiaryContainer: AppColors.onTertiaryContainer,
    error: AppColors.error,
    onError: AppColors.onError,
    errorContainer: AppColors.errorContainer,
    onErrorContainer: AppColors.onErrorContainer,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    onSurfaceVariant: AppColors.onSurfaceVariant,
    surfaceDim: AppColors.surfaceDim,
    surfaceBright: AppColors.surfaceBright,
    surfaceContainerLowest: AppColors.surfaceContainerLowest,
    surfaceContainerLow: AppColors.surfaceContainerLow,
    surfaceContainer: AppColors.surfaceContainer,
    surfaceContainerHigh: AppColors.surfaceContainerHigh,
    surfaceContainerHighest: AppColors.surfaceContainerHighest,
    inverseSurface: AppColors.inverseSurface,
    onInverseSurface: AppColors.inverseOnSurface,
    outline: AppColors.outline,
    outlineVariant: AppColors.outlineVariant,
    surfaceTint: AppColors.surfaceTint,
  );

  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.darkPrimary,
    onPrimary: AppColors.darkOnPrimary,
    primaryContainer: AppColors.darkPrimaryContainer,
    onPrimaryContainer: AppColors.darkOnPrimaryContainer,
    inversePrimary: AppColors.primary,
    secondary: AppColors.darkSecondary,
    onSecondary: AppColors.darkOnSecondary,
    secondaryContainer: AppColors.darkSecondaryContainer,
    onSecondaryContainer: AppColors.darkOnSecondaryContainer,
    tertiary: AppColors.darkTertiary,
    onTertiary: AppColors.darkOnTertiary,
    tertiaryContainer: AppColors.darkTertiaryContainer,
    onTertiaryContainer: AppColors.darkOnTertiaryContainer,
    error: AppColors.darkError,
    onError: AppColors.darkOnError,
    errorContainer: AppColors.darkErrorContainer,
    onErrorContainer: AppColors.darkOnErrorContainer,
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkOnSurface,
    onSurfaceVariant: AppColors.darkOnSurfaceVariant,
    surfaceDim: AppColors.darkSurfaceDim,
    surfaceBright: AppColors.darkSurfaceBright,
    surfaceContainerLowest: AppColors.darkSurfaceContainerLowest,
    surfaceContainerLow: AppColors.darkSurfaceContainerLow,
    surfaceContainer: AppColors.darkSurfaceContainer,
    surfaceContainerHigh: AppColors.darkSurfaceContainerHigh,
    surfaceContainerHighest: AppColors.darkSurfaceContainerHighest,
    inverseSurface: AppColors.surface,
    onInverseSurface: AppColors.onSurface,
    outline: AppColors.darkOutline,
    outlineVariant: AppColors.darkOutlineVariant,
    surfaceTint: AppColors.darkPrimary,
  );

  static TextTheme _buildTextTheme(Brightness brightness) {
    final baseTextTheme = brightness == Brightness.light
        ? ThemeData.light().textTheme
        : ThemeData.dark().textTheme;

    final robotoTextTheme = GoogleFonts.robotoFlexTextTheme(baseTextTheme);

    return robotoTextTheme.copyWith(
      displaySmall: robotoTextTheme.displaySmall?.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        height: 44 / 36,
        letterSpacing: -0.5,
      ),
      headlineMedium: robotoTextTheme.headlineMedium?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 36 / 28,
      ),
      headlineSmall: robotoTextTheme.headlineSmall?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
      ),
      titleLarge: robotoTextTheme.titleLarge?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 28 / 22,
      ),
      titleMedium: robotoTextTheme.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 24 / 16,
        letterSpacing: 0.15,
      ),
      titleSmall: robotoTextTheme.titleSmall?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 20 / 14,
        letterSpacing: 0.1,
      ),
      bodyLarge: robotoTextTheme.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
      ),
      bodyMedium: robotoTextTheme.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
      ),
      bodySmall: robotoTextTheme.bodySmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 16 / 12,
      ),
      labelLarge: robotoTextTheme.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      labelMedium: robotoTextTheme.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
      ),
      labelSmall: robotoTextTheme.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 16 / 11,
        letterSpacing: 0.5,
      ),
    );
  }

  static ThemeData get lightTheme {
    return buildTheme(brightness: Brightness.light, colorScheme: lightColorScheme);
  }

  static ThemeData get darkTheme {
    return buildTheme(brightness: Brightness.dark, colorScheme: darkColorScheme);
  }

  /// Builds a complete M3E ThemeData adapting to custom/dynamic ColorScheme (e.g. Material You)
  static ThemeData buildTheme({
    required Brightness brightness,
    ColorScheme? colorScheme,
  }) {
    final scheme = colorScheme ?? (brightness == Brightness.light ? lightColorScheme : darkColorScheme);
    final textTheme = _buildTextTheme(brightness);
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        color: isDark ? scheme.surfaceContainerLow : scheme.surfaceContainerLow,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainer,
        disabledColor: scheme.surfaceContainerHigh.withValues(alpha: 0.38),
        selectedColor: scheme.primaryContainer,
        secondarySelectedColor: scheme.secondaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        labelStyle: textTheme.labelMedium?.copyWith(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
          color: scheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6), width: 1),
        ),
        elevation: 0,
        pressElevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? scheme.surfaceContainerLow : scheme.surfaceContainerLowest,
        indicatorColor: scheme.primaryContainer,
        elevation: 0,
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.primary,
            );
          }
          return textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: scheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(
              color: scheme.onPrimaryContainer,
              size: 24,
            );
          }
          return IconThemeData(
            color: scheme.onSurfaceVariant,
            size: 24,
          );
        }),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        modalBackgroundColor: scheme.surfaceContainerHighest,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        showDragHandle: true,
        dragHandleColor: scheme.outline,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? scheme.surfaceContainerLowest : scheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: textTheme.bodyMedium?.copyWith(color: scheme.outline),
        labelStyle: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        prefixIconColor: scheme.onSurfaceVariant,
        suffixIconColor: scheme.onSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.outlineVariant, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 3,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.5),
        thickness: 1,
        space: 1,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
