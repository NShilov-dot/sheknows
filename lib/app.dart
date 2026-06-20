import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter_starter_kit/core/di/injection.dart';
import 'package:supabase_flutter_starter_kit/core/router/app_router.dart';
import 'package:supabase_flutter_starter_kit/core/theme/app_theme.dart';
import 'package:supabase_flutter_starter_kit/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:supabase_flutter_starter_kit/features/auth/presentation/bloc/auth_event.dart';
import 'package:supabase_flutter_starter_kit/features/auth/presentation/bloc/auth_state.dart';
import 'package:supabase_flutter_starter_kit/features/profile/presentation/cubit/profile_cubit.dart';

class SupabaseApp extends StatefulWidget {
  const SupabaseApp({super.key});

  @override
  State<SupabaseApp> createState() => _SupabaseAppState();
}

class _SupabaseAppState extends State<SupabaseApp> {
  late final AuthBloc _authBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>()..add(const AuthStarted());
    _router = AppRouter(_authBloc).router;
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<ProfileCubit>.value(value: sl<ProfileCubit>()),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            current is AuthUnauthenticated && previous is AuthAuthenticated,
        listener: (_, __) => sl<ProfileCubit>().reset(),
        child: MaterialApp.router(
          title: 'Supabase Starter',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,
          routerConfig: _router,
        ),
      ),
    );
  }
}
