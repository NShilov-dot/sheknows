import 'package:hive_ce_flutter/hive_ce_flutter.dart';

/// Device-local flag for whether the value-first onboarding has been shown.
/// Backed by Hive (already initialised at bootstrap) — mirrors `SymptomsHive`.
/// Static, opened once in `main.dart`, read synchronously by the router.
class OnboardingPrefs {
  const OnboardingPrefs._();

  static const _boxName = 'app_prefs';
  static const _seenKey = 'onboarding_seen';

  static Future<void> openBox() => Hive.openBox<bool>(_boxName);

  static bool hasSeenOnboarding() =>
      Hive.box<bool>(_boxName).get(_seenKey, defaultValue: false)!;

  static Future<void> markSeen() =>
      Hive.box<bool>(_boxName).put(_seenKey, true);
}
