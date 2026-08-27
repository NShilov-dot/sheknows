import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sheknows/config/environment.dart';
import 'package:sheknows/features/auth/di/auth_injection.dart';
import 'package:sheknows/features/period/di/period_injection.dart';
import 'package:sheknows/features/profile/di/profile_injection.dart';
import 'package:sheknows/features/symptoms/di/symptoms_injection.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // In dev mode Supabase is never initialized; leave the client unregistered so
  // resolving it fails loudly instead of hitting an uninitialized SDK.
  if (!Environment.devMode) {
    sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  }
  registerAuthDependencies(sl);
  registerProfileDependencies(sl);
  registerPeriodDependencies(sl);
  registerSymptomsDependencies(sl);
}
