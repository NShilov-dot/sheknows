import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sheknows/app.dart';
import 'package:sheknows/config/environment.dart';
import 'package:sheknows/core/di/injection.dart';
import 'package:sheknows/utils/app_initializer.dart';

void main() async {
  await AppInitializer.initialize();
  Environment.validate();
  await Supabase.initialize(
    url: Environment.supabaseUrl,
    publishableKey: Environment.supabasePublishableKey,
  );
  await initDependencies();
  runApp(const SupabaseApp());
}
