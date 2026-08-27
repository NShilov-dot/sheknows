import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sheknows/core/di/injection.dart';
import 'package:sheknows/core/router/app_router.dart';
import 'package:sheknows/core/theme/app_theme.dart';
import 'package:sheknows/l10n/app_localizations.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_event.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_state.dart';
import 'package:sheknows/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:sheknows/features/symptoms/data/services/symptom_sync_service.dart';

class SupabaseApp extends StatefulWidget {
  const SupabaseApp({super.key});

  @override
  State<SupabaseApp> createState() => _SupabaseAppState();
}

class _SupabaseAppState extends State<SupabaseApp> {
  late final AuthBloc _authBloc;
  late final AppRouter _appRouter;
  late final GoRouter _router;
  late final ProfileCubit _profileCubit;
  late final SymptomSyncService _symptomSync;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>()..add(const AuthStarted());
    _appRouter = AppRouter(_authBloc);
    _router = _appRouter.router;
    _profileCubit = sl<ProfileCubit>();
    // Replay any queued offline symptom mutations whenever connectivity returns.
    _symptomSync = sl<SymptomSyncService>()..start();
  }

  @override
  void dispose() {
    _symptomSync.stop();
    // Dispose the router first: its refresh listenable subscribes to _authBloc.
    _appRouter.dispose();
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<ProfileCubit>.value(value: _profileCubit),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            current is AuthUnauthenticated && previous is! AuthUnauthenticated,
        listener: (_, __) => _profileCubit.reset(),
        child: MaterialApp.router(
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          // uz first: it is the primary market. Flutter falls back down this
          // list, then to the template locale, so an unsupported device
          // language lands on English rather than failing.
          supportedLocales: const [
            Locale('uz'),
            Locale('ru'),
            Locale('en'),
          ],
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.dark, // Lunar Bloom is dark-first.
          routerConfig: _router,
        ),
      ),
    );
  }
}
