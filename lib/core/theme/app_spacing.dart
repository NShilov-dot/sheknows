/// Layout tokens for "Lunar Bloom".
///
/// [AppTheme] owns colour and type; these own the geometry that a
/// [ThemeData] has nowhere to put. Every value here is one that was already
/// repeated across the app — this file names them, it does not introduce new
/// ones, so adopting it is a no-op visually.
library;

/// Vertical and horizontal rhythm. A 4dp scale; screens use [lg] as the page
/// gutter and [xl] inside cards and sheets.
abstract final class AppSpacing {
  /// 4 — hairline separation between a label and the thing it labels.
  static const double xs = 4;

  /// 8 — between related controls in a row or column.
  static const double sm = 8;

  /// 12 — between a heading and its content.
  static const double md = 12;

  /// 16 — the page gutter, and the gap between cards.
  static const double lg = 16;

  /// 24 — card and sheet inner padding; separation between sections.
  static const double xl = 24;

  /// 32 — separation between unrelated blocks on a screen.
  static const double xxl = 32;
}

/// Corner radii. The component themes in [AppTheme] read these, so a change
/// here moves the whole app.
abstract final class AppRadius {
  /// 6 — small swatches and progress tracks.
  static const double swatch = 6;

  /// 14 — floating snack bars.
  static const double snackBar = 14;

  /// 16 — text fields and list tiles.
  static const double field = 16;

  /// 18 — filled and outlined buttons.
  static const double button = 18;

  /// 20 — the calendar's period band, and pill-shaped day markers.
  static const double band = 20;

  /// 24 — cards and dialogs.
  static const double card = 24;

  /// 28 — the top corners of a modal bottom sheet.
  static const double sheet = 28;
}

/// Icon sizes. Material's default is 24; these are the deliberate departures.
abstract final class AppIconSize {
  /// 16 — inline with body text.
  static const double sm = 16;

  /// 18 — section labels and list-tile leading icons.
  static const double md = 18;

  /// 28 — a brand or provider mark inside a button.
  static const double lg = 28;

  /// 48 — the illustration in an empty state.
  static const double empty = 48;
}

/// Opacity steps applied over a surface. Named so the same wash means the same
/// thing on every screen.
abstract final class AppAlpha {
  /// 0.15 — a hint of fill, e.g. the predicted-period circle.
  static const double faint = 0.15;

  /// 0.25 — a future/inactive version of a filled element.
  static const double future = 0.25;

  /// 0.35 — a translucent field fill over a surface.
  static const double wash = 0.35;

  /// 0.6 — a de-emphasised but still readable element.
  static const double muted = 0.6;

  /// 0.75 — the card surface over the scaffold in dark mode.
  static const double surface = 0.75;

  /// 0.9 — a solid fill that still lets a little ground through.
  static const double solid = 0.9;
}
