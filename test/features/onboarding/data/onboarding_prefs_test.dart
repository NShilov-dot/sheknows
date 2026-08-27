import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:sheknows/features/onboarding/data/onboarding_prefs.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('onboarding_prefs_test');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    tempDir.deleteSync(recursive: true);
  });

  test('defaults to not-seen, then sticks after markSeen', () async {
    await OnboardingPrefs.openBox();
    expect(OnboardingPrefs.hasSeenOnboarding(), isFalse);

    await OnboardingPrefs.markSeen();
    expect(OnboardingPrefs.hasSeenOnboarding(), isTrue);
  });
}
