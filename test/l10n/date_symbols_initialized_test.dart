import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sheknows/l10n/app_localizations.dart';

/// Regression guard for a crash this app actually shipped with.
///
/// Every ARB key carrying a `DateTime` placeholder compiles to
/// `intl.DateFormat.<skeleton>(localeName)`, which throws
/// `LocaleDataException: Locale data has not been initialized` unless
/// `initializeDateFormatting()` has run. `flutter_localizations` does **not**
/// do it for us — it calls `initializeDateFormattingCustom` for its own
/// internal subset only. So the cycle screen, the day-details header and the
/// period history list all threw on first paint, in every locale.
///
/// Two halves, because neither alone is enough:
///  * the functional tests prove the keys work once the symbols are registered;
///  * `boot wiring` proves `main()` still registers them. A unit test cannot
///    invoke `main()`, and moving the call behind a wrapper the test also calls
///    would pass even after someone deleted it from `main()` — so this asserts
///    on the source. Crude, but it is the only thing that fails if the call
///    goes away, which is the failure that matters.
void main() {
  group('boot wiring', () {
    test('main() registers intl locale data before anything can format', () {
      final source = File('lib/main.dart').readAsStringSync();
      expect(
        source,
        contains('initializeDateFormatting()'),
        reason: 'lib/main.dart must call initializeDateFormatting(). Without '
            'it every localized date throws LocaleDataException at runtime.',
      );
      expect(
        source,
        contains("import 'package:intl/date_symbol_data_local.dart';"),
        reason: 'the call must come from date_symbol_data_local, which is the '
            'variant that registers ALL locales',
      );
      // It has to precede the start-up work that builds the first frame.
      expect(
        source.indexOf('initializeDateFormatting()'),
        lessThan(source.indexOf('runApp(const SupabaseApp())')),
      );
    });
  });

  group('every DateTime-placeholder key formats in every locale', () {
    setUpAll(initializeDateFormatting);

    final date = DateTime(2026, 9, 15);

    for (final code in ['en', 'ru', 'uz']) {
      test(code, () async {
        final l10n = await AppLocalizations.delegate.load(Locale(code));
        // One per skeleton in use — each resolves its own locale data.
        expect(l10n.cycleDayHeaderDate(date), isNotEmpty); // yMMMMEEEEd
        expect(l10n.cycleNextPeriodDate(date), isNotEmpty); // yMMMd
        expect(l10n.cycleHistoryRangeOngoing(date), isNotEmpty); // MMMd
        expect(
          l10n.cycleHistoryRange(date, date.add(const Duration(days: 4))),
          isNotEmpty,
        );
        expect(l10n.cycleDayCellSemanticsDateOnly(date), isNotEmpty); // MMMMd
      });
    }

    test('each locale renders its own month names, with no silent fallback',
        () async {
      final en = await AppLocalizations.delegate.load(const Locale('en'));
      final ru = await AppLocalizations.delegate.load(const Locale('ru'));
      final uz = await AppLocalizations.delegate.load(const Locale('uz'));

      final enDate = en.cycleNextPeriodDate(date);
      final ruDate = ru.cycleNextPeriodDate(date);
      final uzDate = uz.cycleNextPeriodDate(date);

      expect(enDate, contains('Sep'));
      expect(ruDate, isNot(contains('Sep')));
      expect(uzDate, isNot(contains('Sep')));
      expect(
        {enDate, ruDate, uzDate}.length,
        3,
        reason: 'en=$enDate ru=$ruDate uz=$uzDate — a collision means at '
            'least one locale fell back to another',
      );
    });
  });
}
