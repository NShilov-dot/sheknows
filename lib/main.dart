import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sheknows/app.dart';
import 'package:sheknows/config/environment.dart';
import 'package:sheknows/core/di/injection.dart';
import 'package:sheknows/core/startup_failure_app.dart';
import 'package:sheknows/features/onboarding/data/onboarding_prefs.dart';
import 'package:sheknows/features/symptoms/data/datasources/symptom_local_datasource.dart';
import 'package:sheknows/utils/app_initializer.dart';

void main() async {
  // runApp needs the binding whichever way start-up goes, so it stays outside
  // the guard. AppInitializer calls it again — that is idempotent.
  WidgetsFlutterBinding.ensureInitialized();
  // Registers intl's locale date symbols. Without this EVERY localized date
  // throws LocaleDataException at runtime — flutter_localizations only
  // initializes its own internal subset, not the global data the ARB
  // DateTime placeholders resolve against. Must run before the first format.
  initializeDateFormatting();
  try {
    await AppInitializer.initialize();
    if (!Environment.devMode) {
      Environment.validate();
      await Supabase.initialize(
        url: Environment.supabaseUrl,
        publishableKey: Environment.supabasePublishableKey,
      );
      await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.info);
      await Purchases.configure(
        PurchasesConfiguration(Environment.revenueCatApiKey),
      );
    }
    // Open the symptoms feature's local-store boxes before DI resolves them.
    await SymptomsHive.openBoxes();
    // Onboarding "seen" flag, read synchronously by the router redirect.
    await OnboardingPrefs.openBox();
    await initDependencies();
  } catch (error) {
    // A corrupt box or bad env would otherwise leave a blank screen forever.
    runApp(StartupFailureApp(error: error));
    return;
  }
  runApp(const SupabaseApp());
}
