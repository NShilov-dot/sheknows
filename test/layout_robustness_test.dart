import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheknows/core/theme/app_theme.dart';
import 'package:sheknows/core/widgets/section_label.dart';
import 'package:sheknows/features/auth/presentation/widgets/auth_alternative_actions.dart';
import 'package:sheknows/features/period/presentation/widgets/cycle_insights_card.dart';
import 'package:sheknows/features/symptoms/presentation/widgets/bar_row.dart';

/// Regression tests for Group 4 (layout robustness).
///
/// The app ships in Uzbek and Russian, so every user-facing string is roughly
/// 30% longer than the English in the source. These pump the widgets that used
/// to throw RenderFlex overflows under the three conditions that actually
/// reach users: a 320dp phone, translated copy, and a raised text scale.
///
/// `tester.takeException()` is the assertion that matters — a RenderFlex
/// overflow reports through `FlutterError.onError`, which the test binding
/// captures rather than throwing inline.
void main() {
  // The narrowest phone still receiving OS updates (iPhone SE 1st gen).
  const narrow = Size(320, 568);

  /// Russian renderings of the real strings these widgets carry.
  const ruInsightLabel = 'Текущие месячные';
  const ruInsightValue = '5-й день кровотечения';
  const ruSymptom = 'Раздражительность';
  const ruSectionTitle = 'Физическое состояние';

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    Size size = narrow,
    double textScale = 1.0,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        // The scaler has to be applied inside MaterialApp — it installs its
        // own MediaQuery from the view, which would discard an outer one.
        builder: (context, inner) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: inner!,
        ),
        home: Scaffold(
          // 16dp page gutter + 16dp card padding, matching the real screens.
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: child,
          ),
        ),
      ),
    );
  }

  group('InsightRow', () {
    testWidgets('does not overflow with Russian label and value', (t) async {
      await pump(
        t,
        const InsightRow(label: ruInsightLabel, value: ruInsightValue),
      );
      expect(t.takeException(), isNull);
    });

    testWidgets('does not overflow at text scale 2.0', (t) async {
      await pump(
        t,
        const InsightRow(label: 'Current period', value: 'Day 5 of bleeding'),
        textScale: 2.0,
      );
      expect(t.takeException(), isNull);
    });

    testWidgets('keeps the value right-aligned', (t) async {
      await pump(
        t,
        const InsightRow(label: 'Logged periods', value: '12'),
      );
      expect(t.takeException(), isNull);

      // The value ends flush against the trailing edge of the row, which is
      // what dropping `spaceBetween` in favour of Expanded had to preserve.
      final rowRight = t.getBottomRight(find.byType(InsightRow)).dx;
      final valueRight = t.getBottomRight(find.text('12')).dx;
      expect(valueRight, closeTo(rowRight, 1));
    });
  });

  group('BarRow', () {
    testWidgets('does not overflow with a long Russian symptom name',
        (t) async {
      await pump(
        t,
        const BarRow(
          label: ruSymptom,
          value: 8,
          fraction: 0.6,
          color: Colors.pink,
        ),
      );
      expect(t.takeException(), isNull);
    });

    testWidgets('does not clip a four-digit all-time total', (t) async {
      await pump(
        t,
        const BarRow(
          label: 'Cramps',
          value: 1234,
          fraction: 1.0,
          color: Colors.pink,
        ),
      );
      expect(t.takeException(), isNull);

      // The count column grows past its 28dp minimum rather than clipping.
      final count = t.renderObject<RenderBox>(find.text('1234'));
      expect(count.size.width, greaterThan(28));
    });

    testWidgets('survives text scale 2.0 with a translated label', (t) async {
      await pump(
        t,
        const BarRow(
          label: ruSymptom,
          value: 99,
          fraction: 0.4,
          color: Colors.pink,
        ),
        textScale: 2.0,
      );
      expect(t.takeException(), isNull);
    });

    testWidgets('bars start at the same x whatever the label length',
        (t) async {
      // A ranked chart is unreadable if its bars do not share a baseline, so
      // the label column must stay a fixed share of the row rather than
      // shrink-wrapping to each label.
      double trackLeftFor(String label) => t
          .getTopLeft(
            find.descendant(
              of: find.byType(BarRow),
              matching: find.byType(ClipRRect),
            ),
          )
          .dx;

      await pump(
        t,
        const BarRow(
          label: 'Acne',
          value: 3,
          fraction: 0.2,
          color: Colors.pink,
        ),
      );
      final shortLabelTrack = trackLeftFor('Acne');

      await pump(
        t,
        const BarRow(
          label: ruSymptom,
          value: 3,
          fraction: 0.2,
          color: Colors.pink,
        ),
      );
      final longLabelTrack = trackLeftFor(ruSymptom);

      expect(shortLabelTrack, closeTo(longLabelTrack, 0.5));
    });

    testWidgets('a zero fraction still lays out', (t) async {
      await pump(
        t,
        const BarRow(
          label: 'Nausea',
          value: 0,
          fraction: 0,
          color: Colors.pink,
        ),
      );
      expect(t.takeException(), isNull);
    });
  });

  group('SectionLabel', () {
    testWidgets('does not overflow with a translated heading', (t) async {
      await pump(
        t,
        const SectionLabel(ruSectionTitle, icon: Icons.favorite_border),
      );
      expect(t.takeException(), isNull);
    });

    testWidgets('does not overflow at text scale 2.0', (t) async {
      await pump(
        t,
        const SectionLabel('Symptoms', icon: Icons.healing_outlined),
        textScale: 2.0,
      );
      expect(t.takeException(), isNull);
    });
  });

  group('AuthAlternativeActions', () {
    testWidgets('wraps instead of overflowing with Russian copy', (t) async {
      await pump(
        t,
        AuthAlternativeActions(
          isLoading: false,
          onGooglePressed: () {},
          promptText: 'У вас нет аккаунта?',
          actionLabel: 'Зарегистрироваться',
          onActionPressed: () {},
        ),
      );
      expect(t.takeException(), isNull);
    });

    testWidgets('does not overflow at text scale 2.0', (t) async {
      await pump(
        t,
        AuthAlternativeActions(
          isLoading: false,
          onGooglePressed: () {},
          promptText: "Don't have an account?",
          actionLabel: 'Sign up',
          onActionPressed: () {},
        ),
        textScale: 2.0,
      );
      expect(t.takeException(), isNull);
    });
  });
}
