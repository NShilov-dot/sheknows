import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:sheknows/core/theme/app_theme.dart';

/// Initializes Flutter bindings and mobile-specific settings.
class AppInitializer {
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();
    await _setupDeviceOrientation();
  }

  static Future<void> _setupDeviceOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top],
    );

    // The three AppBar-less screens — splash, login and register — inherit
    // whatever the Android LaunchTheme left behind, which is a light style,
    // so dark status-bar icons sat on the #16142B background. AppBarTheme now
    // carries systemOverlayStyle for the rest of the app; this covers the
    // screens that have no AppBar to carry it, and themes the nav bar.
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppTheme.night,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }
}
