import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sheknows/app.dart';
import 'package:sheknows/config/environment.dart';
import 'package:sheknows/core/di/injection.dart';
import 'package:sheknows/features/symptoms/data/datasources/symptom_local_datasource.dart';
import 'package:sheknows/utils/app_initializer.dart';

void main() async {
  await AppInitializer.initialize();
  if (!Environment.devMode) {
    Environment.validate();
    await Supabase.initialize(
      url: Environment.supabaseUrl,
      publishableKey: Environment.supabasePublishableKey,
    );
  }
  // Open the symptoms feature's local-store boxes before DI resolves them.
  await SymptomsHive.openBoxes();
  await initDependencies();
  runApp(const SupabaseApp());
}
