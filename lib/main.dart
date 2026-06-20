import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_flutter_starter_kit/app.dart';
import 'package:supabase_flutter_starter_kit/config/environment.dart';
import 'package:supabase_flutter_starter_kit/core/di/injection.dart';
import 'package:supabase_flutter_starter_kit/utils/app_initializer.dart';

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
