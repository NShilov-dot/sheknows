import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheknows/core/theme/app_spacing.dart';
import 'package:sheknows/features/period/domain/entities/cycle_stats.dart';
import 'package:sheknows/features/period/presentation/cubit/period_cubit.dart';
import 'package:sheknows/features/period/presentation/cubit/period_state.dart';
import 'package:sheknows/features/period/presentation/widgets/moon_cycle_indicator.dart';

class CycleMoonHeader extends StatelessWidget {
  const CycleMoonHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<PeriodCubit, PeriodState, CycleStats?>(
      selector: (state) => state is PeriodLoaded ? state.stats : null,
      builder: (context, stats) {
        if (stats == null || stats.currentCycleDay == null) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: MoonCycleIndicator(stats: stats),
        );
      },
    );
  }
}
