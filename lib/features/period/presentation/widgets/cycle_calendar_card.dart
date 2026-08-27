import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheknows/core/theme/app_spacing.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_state.dart';
import 'package:sheknows/features/period/presentation/cubit/period_cubit.dart';
import 'package:sheknows/features/period/presentation/cubit/period_state.dart';
import 'package:sheknows/features/period/presentation/widgets/calendar/cycle_calendar.dart';
import 'package:sheknows/features/period/presentation/widgets/day_details_sheet.dart';

class CycleCalendarCard extends StatelessWidget {
  const CycleCalendarCard({super.key});

  void _onDaySelected(BuildContext context, DateTime day) {
    final cubit = context.read<PeriodCubit>();
    final state = cubit.state;
    if (state is! PeriodLoaded) {
      return;
    }
    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : null;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => DayDetailsSheet(
        day: day,
        logs: state.logs,
        stats: state.stats,
        dayLog: state.dayLogFor(day),
        cubit: cubit,
        userId: userId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.sm,
          AppSpacing.xs,
          AppSpacing.sm,
          AppSpacing.md,
        ),
        child: BlocBuilder<PeriodCubit, PeriodState>(
          // The calendar only reads these four fields. Without this, a
          // mutation's isLoading flip or a mutationFailure emit would rebuild
          // the whole 60-page calendar for nothing.
          buildWhen: (previous, current) =>
              previous is! PeriodLoaded ||
              current is! PeriodLoaded ||
              previous.displayedMonth != current.displayedMonth ||
              previous.logs != current.logs ||
              previous.dayLogs != current.dayLogs ||
              previous.stats != current.stats,
          builder: (context, state) {
            final loaded = state is PeriodLoaded ? state : null;
            return CycleCalendar(
              month: loaded?.displayedMonth ?? DateTime.now(),
              logs: loaded?.logs ?? const [],
              dayLogs: loaded?.dayLogs ?? const [],
              stats: loaded?.stats,
              onDaySelected: (day) => _onDaySelected(context, day),
              onMonthChanged: (month) =>
                  context.read<PeriodCubit>().goToMonth(month),
            );
          },
        ),
      ),
    );
  }
}
