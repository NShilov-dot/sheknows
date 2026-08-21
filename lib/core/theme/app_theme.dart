import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// "Lunar Bloom" — sheknows' visual identity.
///
/// A dark-first palette inspired by the ~29.5-day rhythm the menstrual
/// cycle shares with the lunar cycle: midnight-indigo night sky, soft
/// lavender moonlight, and a warm rose-gold accent reserved for period
/// data.
abstract final class AppTheme {
  // -- Palette ---------------------------------------------------------------

  /// Night sky — app background in dark mode.
  static const _night = Color(0xFF16142B);

  /// Elevated surfaces (cards, sheets) in dark mode.
  static const _nightSurface = Color(0xFF211D3E);

  /// Soft lavender — interactive elements, chrome.
  static const _lavender = Color(0xFFC9B8E8);
  static const _lavenderDeep = Color(0xFF7A5FA8);

  /// Rose-gold — period data, primary actions.
  static const _roseGold = Color(0xFFF4B8C1);
  static const _roseDeep = Color(0xFFC25B72);

  /// Warm cream — light mode background.
  static const _cream = Color(0xFFFBF8FC);

  /// Sage — success / fertile-window accents later on.
  static const _sage = Color(0xFFA8C5BA);

  // -- Fonts -----------------------------------------------------------------

  static TextStyle get displayStyle => GoogleFonts.fraunces();
  static TextStyle get bodyStyle => GoogleFonts.outfit();

  // -- Themes ----------------------------------------------------------------

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        scheme: ColorScheme.dark(
          primary: _lavender,
          onPrimary: _night,
          primaryContainer: _lavenderDeep,
          onPrimaryContainer: _cream,
          secondary: _roseGold,
          onSecondary: _night,
          secondaryContainer: _roseDeep,
          onSecondaryContainer: _cream,
          tertiary: _sage,
          onTertiary: _night,
          surface: _nightSurface,
          onSurface: const Color(0xFFEDE9F7),
          surfaceContainerHighest: const Color(0xFF2C2750),
          onSurfaceVariant: const Color(0xFFB3ABCE),
          outline: const Color(0xFF565074),
          error: const Color(0xFFFF8A80),
          onError: _night,
        ),
        scaffoldBackground: _night,
      );

  static ThemeData get light => _build(
        brightness: Brightness.light,
        scheme: ColorScheme.light(
          primary: _lavenderDeep,
          onPrimary: Colors.white,
          primaryContainer: _lavender,
          onPrimaryContainer: _night,
          secondary: _roseDeep,
          onSecondary: Colors.white,
          secondaryContainer: _roseGold,
          onSecondaryContainer: _night,
          tertiary: _sage,
          onTertiary: _night,
          surface: Colors.white,
          onSurface: const Color(0xFF241F3D),
          surfaceContainerHighest: const Color(0xFFEFEAF6),
          onSurfaceVariant: const Color(0xFF6B6486),
          outline: const Color(0xFFB0AAC4),
          error: const Color(0xFFB3261E),
          onError: Colors.white,
        ),
        scaffoldBackground: _cream,
      );

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
    required Color scaffoldBackground,
  }) {
    final display = GoogleFonts.fraunces();
    final body = GoogleFonts.outfit();

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBackground,
      textTheme: TextTheme(
        displayLarge: display.copyWith(fontSize: 57, fontWeight: FontWeight.w500),
        displayMedium: display.copyWith(fontSize: 45, fontWeight: FontWeight.w500),
        displaySmall: display.copyWith(fontSize: 36, fontWeight: FontWeight.w500),
        headlineLarge: display.copyWith(fontSize: 32, fontWeight: FontWeight.w600),
        headlineMedium: display.copyWith(fontSize: 28, fontWeight: FontWeight.w600),
        headlineSmall: display.copyWith(fontSize: 24, fontWeight: FontWeight.w600),
        titleLarge: body.copyWith(fontSize: 22, fontWeight: FontWeight.w600),
        titleMedium: body.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
        titleSmall: body.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
        bodyLarge: body.copyWith(fontSize: 16),
        bodyMedium: body.copyWith(fontSize: 14),
        bodySmall: body.copyWith(fontSize: 12),
        labelLarge: body.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
        labelMedium: body.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
        labelSmall: body.copyWith(fontSize: 11, fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackground,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: display.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface.withValues(alpha: brightness == Brightness.dark ? 0.75 : 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: body.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          side: BorderSide(color: scheme.outline),
          textStyle: body.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: body.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        modalBackgroundColor: scheme.surface,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: scheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
