import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sheknows/core/theme/app_spacing.dart';

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

  /// The night sky, for the platform chrome that sits outside the widget tree
  /// (the Android system navigation bar) and cannot read the [ColorScheme].
  static const night = _night;

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

  /// The moon's unlit side. Deliberately NOT derived from `onSurface`, which
  /// is near-white in dark and near-black in light — deriving from it would
  /// render the shadow lighter than the sky in dark mode and darker in light,
  /// flipping the moon's meaning with the theme.
  static const _moonShadowDark = Color(0xFF2C2750);
  static const _moonShadowLight = Color(0xFFD8D2E4);

  /// The unlit-disc shade for the current theme.
  static Color moonShadowOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _moonShadowDark
          : _moonShadowLight;

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
          // #B0AAC4 topped out at 2.12:1 on the light scaffold — unusable at
          // any alpha. Same hue, dark enough to clear WCAG 1.4.11's 3:1 on
          // both card (3.46:1) and scaffold (3.29:1).
          outline: const Color(0xFF8C879C),
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
        displayLarge:
            display.copyWith(fontSize: 57, fontWeight: FontWeight.w500),
        displayMedium:
            display.copyWith(fontSize: 45, fontWeight: FontWeight.w500),
        displaySmall:
            display.copyWith(fontSize: 36, fontWeight: FontWeight.w500),
        headlineLarge:
            display.copyWith(fontSize: 32, fontWeight: FontWeight.w600),
        headlineMedium:
            display.copyWith(fontSize: 28, fontWeight: FontWeight.w600),
        headlineSmall:
            display.copyWith(fontSize: 24, fontWeight: FontWeight.w600),
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
        // NOT the bare SystemUiOverlayStyle.light/.dark constants: they carry
        // systemNavigationBarColor black/white, which Flutter forwards to
        // Android and which clobbers the nav bar AppInitializer sets.
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: const Color(0x00000000),
          statusBarIconBrightness: brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
          statusBarBrightness: brightness == Brightness.dark
              ? Brightness.dark
              : Brightness.light,
          systemNavigationBarColor: scaffoldBackground,
          systemNavigationBarIconBrightness: brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
        ),
        titleTextStyle: display.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface.withValues(
            alpha: brightness == Brightness.dark ? AppAlpha.surface : 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          // Light mode puts a white card on a near-white scaffold — 1.02:1,
          // an invisible rectangle at elevation 0. Dark mode separates on
          // its own, so it keeps the borderless look.
          side: brightness == Brightness.light
              ? BorderSide(
                  color: scheme.outline.withValues(alpha: AppAlpha.muted))
              : BorderSide.none,
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button)),
          textStyle: body.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button)),
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
        // 35% reads on the dark surface; over a white one it composites to
        // roughly the background, leaving the field with no affordance at all
        // until it is tapped. Light mode takes the tint at full strength.
        fillColor: scheme.surfaceContainerHighest.withValues(
          alpha: brightness == Brightness.dark ? AppAlpha.wash : 1,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
          // Dark mode separates on the fill alone. Light mode does not — the
          // tint sits at ~1.2:1 on a white card — so the field gets a real
          // edge there, which is what WCAG 1.4.11 asks of a form control.
          borderSide: brightness == Brightness.dark
              ? BorderSide.none
              : BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        modalBackgroundColor: scheme.surface,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: scheme.surface,
        // No border here, unlike cardTheme: a dialog floats over a scrim with
        // its own elevation, so it separates from the page without one.
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.snackBar)),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.field)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        // M3's default elevation 3 tints the bar toward primary; the bar is a
        // flat surface band, the same tone as the cards.
        elevation: 0,
        // NOT secondaryContainer (the default): rose-gold is reserved for
        // period data, and a rose pill under the active tab would read as one.
        indicatorColor: scheme.primary.withValues(alpha: AppAlpha.future),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => body.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? scheme.onSurface
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
