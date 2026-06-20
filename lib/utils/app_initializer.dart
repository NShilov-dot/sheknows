import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// Initializes Flutter bindings and mobile-specific settings.
class AppInitializer {
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
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
  }
}
