import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Completeness gate over the ARB files themselves.
///
/// `AppLocalizations` only throws on a missing key when that key is *read*, so
/// a forgotten translation ships silently and surfaces as one English word on a
/// Russian screen. These tests read the ARBs directly, so a gap fails CI the
/// moment it is introduced rather than when a user finds it.
void main() {
  Map<String, dynamic> arb(String locale) => jsonDecode(
        File('lib/l10n/app_$locale.arb').readAsStringSync(),
      ) as Map<String, dynamic>;

  final en = arb('en');
  final ru = arb('ru');
  final uz = arb('uz');

  /// Message keys only — `@key` entries are translator metadata.
  final keys = en.keys.where((k) => !k.startsWith('@')).toList();

  /// Keys that are *legitimately* identical across locales.
  ///
  /// Two kinds, and nothing else belongs here:
  ///  * the product name, which is never translated or transliterated;
  ///  * pure placeholder templates, where the localization is done by the
  ///    intl skeleton or by the already-localized arguments, not by the
  ///    template text. `'{date}'` has nothing to translate.
  const identicalByDesign = {
    'appTitle',
    'homeAppBarTitle',
    'cycleDayCellSemantics',
    'cycleDayCellSemanticsDateOnly',
    'cycleDayHeaderDate',
    'cycleHistoryRange',
    'cycleNextPeriodDate',
    'cycleMoonPhaseLine',
    'symptomBarRowSemanticsLabel',
    'symptomHistoryTileSubtitle',
    // 'Email' is the same word in Uzbek.
    'authEmailLabel',
  };

  test('every locale declares its @@locale', () {
    expect(en['@@locale'], 'en');
    expect(ru['@@locale'], 'ru');
    expect(uz['@@locale'], 'uz');
  });

  test('ru and uz define every key the English template defines', () {
    expect(keys, isNotEmpty);
    expect(
      keys.where((k) => !ru.containsKey(k)),
      isEmpty,
      reason: 'missing Russian translations',
    );
    expect(
      keys.where((k) => !uz.containsKey(k)),
      isEmpty,
      reason: 'missing Uzbek translations',
    );
  });

  test('no locale has a blank value', () {
    for (final entry in {'ru': ru, 'uz': uz, 'en': en}.entries) {
      final blank = keys.where((k) => (entry.value[k] as String).trim().isEmpty);
      expect(blank, isEmpty, reason: '${entry.key} has blank values');
    }
  });

  test('no key silently stayed English', () {
    for (final entry in {'ru': ru, 'uz': uz}.entries) {
      final untranslated = keys
          .where((k) => !identicalByDesign.contains(k))
          .where((k) => entry.value[k] == en[k])
          .toList();
      expect(
        untranslated,
        isEmpty,
        reason: '${entry.key} still matches English for $untranslated. If one '
            'of these is genuinely the same word in that language, add it to '
            'identicalByDesign with a note — do not widen the rule silently.',
      );
    }
  });

  test('ICU plurals carry the Russian few/many forms', () {
    // Russian needs one/few/many where English has one/other. A plural key that
    // only declares one/other renders "5 день" instead of "5 дней".
    final plurals =
        keys.where((k) => (en[k] as String).contains(', plural,')).toList();
    expect(plurals, isNotEmpty, reason: 'expected at least one ICU plural');

    for (final key in plurals) {
      final value = ru[key] as String;
      for (final category in ['one{', 'few{', 'many{', 'other{']) {
        expect(
          value,
          contains(category),
          reason: 'ru "$key" is missing the $category branch',
        );
      }
    }
  });

  test('every placeholder used in ru/uz is declared in the template', () {
    final placeholderPattern = RegExp(r'\{(\w+)[,}]');
    const icuKeywords = {
      'plural', 'select', 'zero', 'one', 'two', 'few', 'many', 'other',
    };

    for (final key in keys) {
      final meta = en['@$key'] as Map<String, dynamic>?;
      final declared =
          ((meta?['placeholders'] as Map<String, dynamic>?) ?? {}).keys.toSet();

      for (final entry in {'en': en, 'ru': ru, 'uz': uz}.entries) {
        final used = placeholderPattern
            .allMatches(entry.value[key] as String)
            .map((m) => m.group(1)!)
            .where((name) => !icuKeywords.contains(name))
            .toSet();
        expect(
          used.difference(declared),
          isEmpty,
          reason: '${entry.key} "$key" uses placeholders that the template '
              'does not declare — gen-l10n would drop or mis-type them',
        );
      }
    }
  });

  test('braces balance in every value', () {
    for (final entry in {'en': en, 'ru': ru, 'uz': uz}.entries) {
      for (final key in keys) {
        final value = entry.value[key] as String;
        expect(
          value.split('{').length,
          value.split('}').length,
          reason: '${entry.key} "$key" has unbalanced ICU braces: $value',
        );
      }
    }
  });
}
