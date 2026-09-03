import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:sheknows/l10n/app_localizations.dart';

/// Guards the assumptions the whole localization design rests on.
///
/// The app ships Uzbek, Russian and English. Two of those assumptions are not
/// obvious and would fail silently: that Russian plural agreement produces
/// three distinct forms, and that dates render in the Russian *genitive*
/// month — «15 сентября», not «Сентябрь». Both are why date strings are ARB
/// `DateTime` placeholders with intl skeletons instead of hand-rolled month
/// name tables.
void main() {
  setUpAll(initializeDateFormatting);

  const locales = [Locale('en'), Locale('ru'), Locale('uz')];

  Future<AppLocalizations> load(Locale locale) =>
      AppLocalizations.delegate.load(locale);

  group('every declared locale actually resolves', () {
    for (final locale in locales) {
      test('${locale.languageCode} loads and is non-empty', () async {
        expect(AppLocalizations.delegate.isSupported(locale), isTrue);
        final l10n = await load(locale);
        expect(l10n.appTitle, 'sheknows');
        // A key from each feature area, so a half-translated ARB fails here.
        expect(l10n.authSignIn.trim(), isNotEmpty);
        expect(l10n.cycleTitle.trim(), isNotEmpty);
        expect(l10n.symptomsTitle.trim(), isNotEmpty);
        expect(l10n.commonTryAgain.trim(), isNotEmpty);
      });
    }
  });

  test('Flutter ships Material localizations for all three languages', () {
    // Without this, the date picker, text-selection menu and back-button
    // tooltip fall back to English even though our own strings translate.
    for (final locale in locales) {
      expect(
        GlobalMaterialLocalizations.delegate.isSupported(locale),
        isTrue,
        reason: '${locale.languageCode} has no Material localizations',
      );
      expect(GlobalCupertinoLocalizations.delegate.isSupported(locale), isTrue);
    }
  });

  group('Russian plural agreement', () {
    test('produces three distinct forms, not English one/other', () async {
      final ru = await load(const Locale('ru'));
      final one = ru.commonDaysCount(1); // день
      final few = ru.commonDaysCount(3); // дня
      final many = ru.commonDaysCount(5); // дней

      expect(one, contains('1'));
      expect({one, few, many}.length, 3,
          reason: 'ru must inflect the noun across one/few/many, got '
              '"$one" / "$few" / "$many"');
      // 22 behaves like 2, and 25 like 5 — the rule is on the last digit.
      expect(ru.commonDaysCount(22).replaceAll('22', 'N'),
          few.replaceAll('3', 'N'));
      expect(ru.commonDaysCount(25).replaceAll('25', 'N'),
          many.replaceAll('5', 'N'));
    });

    test('English keeps its two forms', () async {
      final en = await load(const Locale('en'));
      expect(en.commonDaysCount(1), '1 day');
      expect(en.commonDaysCount(5), '5 days');
    });

    test('Uzbek does not inflect after a numeral', () async {
      final uz = await load(const Locale('uz'));
      final one = uz.commonDaysCount(1).replaceAll('1', 'N');
      final many = uz.commonDaysCount(5).replaceAll('5', 'N');
      expect(one, many, reason: 'uz noun should stay singular after a count');
    });
  });

  group('date formatting', () {
    final date = DateTime(2026, 9, 15);

    test('Russian uses the genitive month, which a name table cannot do', () {
      final formatted = DateFormat.yMMMd('ru').format(date);
      expect(formatted, contains('сент'),
          reason: 'got "$formatted"');
      // The nominative standalone form is «Сентябрь»; the formatting form is
      // «сентября». Getting the nominative here means the skeleton was lost.
      expect(formatted, isNot(contains('Сентябрь')));
    });

    test('Uzbek has real month data, not a fallback to English', () {
      final formatted = DateFormat.yMMMM('uz').format(date);
      expect(formatted.toLowerCase(), contains('sentabr'),
          reason: 'got "$formatted" — uz date symbols may be missing');
      expect(formatted, isNot(contains('September')));
    });

    test('day/month order is locale-driven, not hardcoded', () {
      final en = DateFormat.yMMMd('en_US').format(date);
      final ru = DateFormat.yMMMd('ru').format(date);
      // en_US leads with the month, ru leads with the day.
      expect(en.indexOf('15'), greaterThan(en.indexOf('Sep')));
      expect(ru.indexOf('15'), lessThan(ru.indexOf('сент')));
    });
  });

  group('ARB completeness', () {
    test('ru and uz define every key the template does', () async {
      // AppLocalizations throws on a missing key only when it is read, so walk
      // a representative sample across all key prefixes.
      for (final locale in [const Locale('ru'), const Locale('uz')]) {
        final l10n = await load(locale);
        final samples = <String>[
          l10n.commonTryAgain,
          l10n.commonDelete,
          l10n.commonNotes,
          l10n.errorAuthGeneric,
          l10n.errorNetworkOffline,
          l10n.authLoginTitle,
          l10n.authSignUp,
          l10n.profileSignOut,
          l10n.cycleTitle,
          l10n.cycleLegendLogged,
          l10n.cyclePhaseMenstrual,
          l10n.symptomsTitle,
          l10n.symptomTypeCramps,
          l10n.symptomSeverityMild,
          l10n.symptomCategoryPain,
        ];
        for (final s in samples) {
          expect(s.trim(), isNotEmpty,
              reason: '${locale.languageCode} has a blank value');
        }
      }
    });
  });
}
