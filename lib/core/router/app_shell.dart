import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sheknows/core/di/injection.dart';
import 'package:sheknows/core/error/failure_messages.dart';
import 'package:sheknows/core/error/failures.dart';
import 'package:sheknows/features/auth/presentation/widgets/auth_gate.dart';
import 'package:sheknows/features/period/presentation/cubit/period_cubit.dart';
import 'package:sheknows/features/period/presentation/cubit/period_state.dart';
import 'package:sheknows/features/symptoms/presentation/cubit/symptoms_cubit.dart';
import 'package:sheknows/features/symptoms/presentation/cubit/symptoms_state.dart';
import 'package:sheknows/l10n/app_localizations.dart';

/// The signed-in frame: bottom navigation over the tab branches.
///
/// It also owns the [PeriodCubit] and [SymptomsCubit] the tabs share. The
/// dashboard shows the same periods and symptoms the Cycle and Symptoms tabs
/// edit, so one instance of each sits above all of them — per-tab cubits would
/// keep showing a period logged on Cycle as missing on Home until a reload,
/// because an indexed stack never rebuilds an inactive tab. The trends and
/// phase screens still create their own read-only instances.
///
/// Destinations are in branch order; keep them in step with `AppRouter`.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return AuthGate(
      builder: (context, userId) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => sl<PeriodCubit>()..load(userId)),
          BlocProvider(create: (_) => sl<SymptomsCubit>()..load(userId)),
        ],
        child: _ShellScaffold(navigationShell: navigationShell),
      ),
    );
  }
}

class _ShellScaffold extends StatelessWidget {
  const _ShellScaffold({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _announce(BuildContext context, Failure failure) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(failureMessage(AppLocalizations.of(context), failure)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Mutation failures from either shared cubit surface here, once, whichever
    // tab dispatched them. The messenger paints into the root Scaffold — this
    // one — so the snack bar lands above the navigation bar.
    return MultiBlocListener(
      listeners: [
        BlocListener<PeriodCubit, PeriodState>(
          listenWhen: (previous, current) =>
              current is PeriodLoaded &&
              current.mutationFailure != null &&
              (previous is! PeriodLoaded ||
                  previous.mutationFailure != current.mutationFailure),
          listener: (context, state) {
            if (state is PeriodLoaded && state.mutationFailure != null) {
              _announce(context, state.mutationFailure!);
            }
          },
        ),
        BlocListener<SymptomsCubit, SymptomsState>(
          listenWhen: (previous, current) =>
              current is SymptomsLoaded &&
              current.mutationFailure != null &&
              (previous is! SymptomsLoaded ||
                  previous.mutationFailure != current.mutationFailure),
          listener: (context, state) {
            if (state is SymptomsLoaded && state.mutationFailure != null) {
              _announce(context, state.mutationFailure!);
            }
          },
        ),
      ],
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) {
            HapticFeedback.selectionClick();
            // Re-tapping the active tab returns it to its root screen, the
            // way platform tab bars do.
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: l10n.navHome,
            ),
            NavigationDestination(
              icon: const Icon(Icons.calendar_month_outlined),
              selectedIcon: const Icon(Icons.calendar_month),
              label: l10n.cycleTitle,
            ),
            NavigationDestination(
              icon: const Icon(Icons.healing_outlined),
              selectedIcon: const Icon(Icons.healing),
              label: l10n.symptomsTitle,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person),
              label: l10n.profileTitle,
            ),
          ],
        ),
      ),
    );
  }
}
