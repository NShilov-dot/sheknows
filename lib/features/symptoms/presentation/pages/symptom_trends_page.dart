import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sheknows/core/di/injection.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_state.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_log_entity.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_trends.dart';
import 'package:sheknows/features/symptoms/presentation/cubit/symptoms_cubit.dart';
import 'package:sheknows/features/symptoms/presentation/cubit/symptoms_state.dart';
import 'package:sheknows/features/symptoms/presentation/utils/analytics_range.dart';
import 'package:sheknows/features/symptoms/presentation/utils/symptom_labels.dart';
import 'package:sheknows/features/symptoms/presentation/widgets/bar_row.dart';

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

class _TrendsView extends StatefulWidget {
  const _TrendsView();

  @override
  State<_TrendsView> createState() => _TrendsViewState();
}

class _TrendsViewState extends State<_TrendsView> {
  static const _calculator = SymptomTrendsCalculator();
  AnalyticsRange _range = AnalyticsRange.days30;

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
            SymptomsLoaded(:final logs) => _buildTrends(logs),
          };
        },
      ),
    );
  }

  Widget _buildTrends(List<SymptomLogEntity> logs) {
    final from = _range.fromDate(DateTime.now());
    final trends = _calculator.calculate(logs, from: from);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _RangeSelector(
          range: _range,
          onChanged: (range) => setState(() => _range = range),
        ),
        const SizedBox(height: 16),
        if (trends.isEmpty)
          const _EmptyTrends()
        else ...[
          _SummaryCard(total: trends.totalEntries),
          const SizedBox(height: 24),
          _FrequencySection(trends: trends),
          const SizedBox(height: 24),
          _SeveritySection(trends: trends),
        ],
      ],
    );
  }
}

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({required this.range, required this.onChanged});

  final AnalyticsRange range;
  final ValueChanged<AnalyticsRange> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        for (final option in AnalyticsRange.values)
          ChoiceChip(
            label: Text(option.label),
            selected: range == option,
            onSelected: (_) => onChanged(option),
          ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.insights, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Text(
              '$total ${total == 1 ? 'entry' : 'entries'} logged',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _FrequencySection extends StatelessWidget {
  const _FrequencySection({required this.trends});

  final SymptomTrends trends;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Most frequent', style: theme.textTheme.titleSmall),
        const SizedBox(height: 12),
        for (final entry in trends.byType)
          BarRow(
            label: symptomTypeLabel(entry.type),
            value: entry.count,
            fraction: entry.count / trends.maxTypeCount,
            color: theme.colorScheme.primary,
          ),
      ],
    );
  }
}

class _SeveritySection extends StatelessWidget {
  const _SeveritySection({required this.trends});

  final SymptomTrends trends;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxCount = trends.bySeverity.values
        .fold<int>(1, (max, count) => count > max ? count : max);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('By severity', style: theme.textTheme.titleSmall),
        const SizedBox(height: 12),
        for (final severity in SymptomSeverity.values)
          BarRow(
            label: symptomSeverityLabel(severity),
            value: trends.bySeverity[severity] ?? 0,
            fraction: (trends.bySeverity[severity] ?? 0) / maxCount,
            color: theme.colorScheme.tertiary,
          ),
      ],
    );
  }
}

class _EmptyTrends extends StatelessWidget {
  const _EmptyTrends();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 64),
      child: Column(
        children: [
          Icon(Icons.insights_outlined,
              size: 48, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text('No symptoms in this window', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Log symptoms to see your trends.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
