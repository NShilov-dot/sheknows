import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sheknows/features/auth/di/auth_injection.dart';
import 'package:sheknows/features/period/di/period_injection.dart';
import 'package:sheknows/features/profile/di/profile_injection.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  registerAuthDependencies(sl);
  registerProfileDependencies(sl);
  registerPeriodDependencies(sl);
}
