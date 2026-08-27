import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sheknows/core/error/failures.dart';
import 'package:sheknows/features/period/domain/entities/cycle_phase.dart';
import 'package:sheknows/features/period/domain/usecases/period_usecases.dart';
import 'package:sheknows/features/symptoms/data/services/symptom_phase_analyzer.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_phase_trends.dart';
import 'package:sheknows/features/symptoms/domain/usecases/symptom_usecases.dart';
import 'package:sheknows/features/symptoms/presentation/cubit/symptom_phase_cubit.dart';
import 'package:sheknows/features/symptoms/presentation/cubit/symptom_phase_state.dart';
import 'package:sheknows/features/symptoms/presentation/utils/analytics_range.dart';

class _MockGetSymptomLogs extends Mock implements GetSymptomLogsUseCase {}

class _MockGetPeriodLogs extends Mock implements GetPeriodLogsUseCase {}

class _MockAnalyzer extends Mock implements SymptomPhaseAnalyzer {}

SymptomPhaseTrends _trends() => SymptomPhaseTrends(
      totalEntries: 0,
      phases: [
        for (final phase in CyclePhase.values)
          PhaseSummary(phase: phase, count: 0, topTypes: const []),
      ],
    );

void main() {
  late _MockGetSymptomLogs getSymptomLogs;
  late _MockGetPeriodLogs getPeriodLogs;
  late _MockAnalyzer analyzer;

  const userId = 'user-1';

  setUpAll(() {
    registerFallbackValue(const GetSymptomLogsParams(userId: userId));
    registerFallbackValue(const GetPeriodLogsParams(userId: userId));
    registerFallbackValue(
      SymptomPhaseInput(
        symptomLogs: const [],
        periodLogs: const [],
        now: DateTime(2026),
      ),
    );
  });

  setUp(() {
    getSymptomLogs = _MockGetSymptomLogs();
    getPeriodLogs = _MockGetPeriodLogs();
    analyzer = _MockAnalyzer();
  });

  SymptomPhaseCubit buildCubit() => SymptomPhaseCubit(
        getSymptomLogs: getSymptomLogs,
        getPeriodLogs: getPeriodLogs,
        analyzer: analyzer,
      );

  void stubLoad() {
    when(() => getSymptomLogs(any()))
        .thenAnswer((_) async => const Right([]));
    when(() => getPeriodLogs(any())).thenAnswer((_) async => const Right([]));
    when(() => analyzer.analyze(any())).thenAnswer((_) async => _trends());
  }

  group('load', () {
    blocTest<SymptomPhaseCubit, SymptomPhaseState>(
      'fetches both data sets and computes via the analyzer (isolate)',
      build: () {
        stubLoad();
        return buildCubit();
      },
      act: (cubit) => cubit.load(userId),
      expect: () => [
        isA<SymptomPhaseLoading>(),
        isA<SymptomPhaseLoaded>()
            .having((s) => s.range, 'range', AnalyticsRange.days30),
      ],
      verify: (_) {
        verify(() => getSymptomLogs(any())).called(1);
        verify(() => getPeriodLogs(any())).called(1);
        verify(() => analyzer.analyze(any())).called(1);
      },
    );

    blocTest<SymptomPhaseCubit, SymptomPhaseState>(
      'emits error when a load fails',
      build: () {
        when(() => getSymptomLogs(any()))
            .thenAnswer((_) async => const Left(ServerFailure()));
        when(() => getPeriodLogs(any()))
            .thenAnswer((_) async => const Right([]));
        return buildCubit();
      },
      act: (cubit) => cubit.load(userId),
      expect: () => [isA<SymptomPhaseLoading>(), isA<SymptomPhaseError>()],
      verify: (_) => verifyNever(() => analyzer.analyze(any())),
    );
  });

  group('setRange', () {
    blocTest<SymptomPhaseCubit, SymptomPhaseState>(
      'recomputes via the isolate without refetching data',
      build: () {
        stubLoad();
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.load(userId);
        await cubit.setRange(AnalyticsRange.days90);
      },
      expect: () => [
        isA<SymptomPhaseLoading>(),
        isA<SymptomPhaseLoaded>()
            .having((s) => s.range, 'range', AnalyticsRange.days30),
        isA<SymptomPhaseLoaded>()
            .having((s) => s.recomputing, 'recomputing', true),
        isA<SymptomPhaseLoaded>()
            .having((s) => s.range, 'range', AnalyticsRange.days90)
            .having((s) => s.recomputing, 'recomputing', false),
      ],
      verify: (_) {
        // Data fetched once (on load), analyzer runs twice (load + setRange).
        verify(() => getSymptomLogs(any())).called(1);
        verify(() => getPeriodLogs(any())).called(1);
        verify(() => analyzer.analyze(any())).called(2);
      },
    );
  });
}
