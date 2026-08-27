import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sheknows/core/di/injection.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_state.dart';
import 'package:sheknows/features/symptoms/presentation/cubit/symptoms_cubit.dart';
import 'package:sheknows/features/symptoms/presentation/cubit/symptoms_state.dart';
import 'package:sheknows/features/symptoms/presentation/widgets/symptom_trends_body.dart';

class SymptomTrendsPage extends StatelessWidget {
  const SymptomTrendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AuthBloc, AuthState, String?>(
      selector: (state) => state is AuthAuthenticated ? state.user.id : null,
      builder: (context, userId) {
        if (userId == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return BlocProvider(
          create: (_) => sl<SymptomsCubit>()..load(userId),
          child: const _TrendsView(),
        );
      },
    );
  }
}

class _TrendsView extends StatelessWidget {
  const _TrendsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trends'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/symptoms'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart_outline),
            tooltip: 'By cycle phase',
            onPressed: () => context.go('/symptom-phases'),
          ),
        ],
      ),
      body: BlocBuilder<SymptomsCubit, SymptomsState>(
        builder: (context, state) {
          return switch (state) {
            SymptomsInitial() || SymptomsLoading() =>
              const Center(child: CircularProgressIndicator()),
            SymptomsError(:final failure) =>
              Center(child: Text(failure.message)),
            SymptomsLoaded(:final logs) => SymptomTrendsBody(logs: logs),
          };
        },
      ),
    );
  }
}
