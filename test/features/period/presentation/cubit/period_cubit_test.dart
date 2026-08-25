import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sheknows/core/error/failures.dart';
import 'package:sheknows/features/period/domain/entities/cycle_stats.dart';
import 'package:sheknows/features/period/domain/entities/day_log_entity.dart';
import 'package:sheknows/features/period/domain/entities/period_log_entity.dart';
import 'package:sheknows/features/period/domain/usecases/period_usecases.dart';
import 'package:sheknows/features/period/presentation/cubit/period_cubit.dart';
import 'package:sheknows/features/period/presentation/cubit/period_state.dart';

class _MockGetPeriodLogs extends Mock implements GetPeriodLogsUseCase {}

class _MockLogPeriodStart extends Mock implements LogPeriodStartUseCase {}

class _MockUpdatePeriodLog extends Mock implements UpdatePeriodLogUseCase {}

class _MockDeletePeriodLog extends Mock implements DeletePeriodLogUseCase {}

class _MockGetDayLogs extends Mock implements GetDayLogsUseCase {}

class _MockUpsertDayLog extends Mock implements UpsertDayLogUseCase {}

class _MockDeleteDayLog extends Mock implements DeleteDayLogUseCase {}

DayLogEntity _dayLog({
  String id = 'day-1',
  Mood? mood = Mood.happy,
  Set<Symptom> symptoms = const {},
}) {
  return DayLogEntity(
    id: id,
    userId: 'user-1',
    date: DateTime(2026, 8, 20),
    mood: mood,
    symptoms: symptoms,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
}

void main() {
  late _MockGetPeriodLogs getPeriodLogs;
  late _MockLogPeriodStart logPeriodStart;
  late _MockUpdatePeriodLog updatePeriodLog;
  late _MockDeletePeriodLog deletePeriodLog;
  late _MockGetDayLogs getDayLogs;
  late _MockUpsertDayLog upsertDayLog;
  late _MockDeleteDayLog deleteDayLog;

  const userId = 'user-1';
  final day = DateTime(2026, 8, 20);

  setUpAll(() {
    registerFallbackValue(const GetPeriodLogsParams(userId: userId));
    registerFallbackValue(const GetDayLogsParams(userId: userId));
    registerFallbackValue(UpsertDayLogParams(userId: userId, date: DateTime(2026, 8, 20)));
    registerFallbackValue(const DeleteDayLogParams('day-1'));
  });

  setUp(() {
    getPeriodLogs = _MockGetPeriodLogs();
    logPeriodStart = _MockLogPeriodStart();
    updatePeriodLog = _MockUpdatePeriodLog();
    deletePeriodLog = _MockDeletePeriodLog();
    getDayLogs = _MockGetDayLogs();
    upsertDayLog = _MockUpsertDayLog();
    deleteDayLog = _MockDeleteDayLog();
  });

  PeriodCubit buildCubit() => PeriodCubit(
        getPeriodLogs: getPeriodLogs,
        logPeriodStart: logPeriodStart,
        updatePeriodLog: updatePeriodLog,
        deletePeriodLog: deletePeriodLog,
        getDayLogs: getDayLogs,
        upsertDayLog: upsertDayLog,
        deleteDayLog: deleteDayLog,
        statsCalculator: const CycleStatsCalculator(),
      );

  void stubLoad({
    List<PeriodLogEntity> logs = const [],
    List<DayLogEntity> dayLogs = const [],
  }) {
    when(() => getPeriodLogs(any())).thenAnswer((_) async => Right(logs));
    when(() => getDayLogs(any())).thenAnswer((_) async => Right(dayLogs));
  }

  group('load', () {
    blocTest<PeriodCubit, PeriodState>(
      'fetches both period logs and day logs',
      build: () {
        stubLoad(dayLogs: [_dayLog()]);
        return buildCubit();
      },
      act: (cubit) => cubit.load(userId),
      expect: () => [
        isA<PeriodLoading>(),
        isA<PeriodLoaded>()
            .having((s) => s.dayLogs.length, 'dayLogs', 1)
            .having((s) => s.isLoading, 'isLoading', false),
      ],
      verify: (_) {
        verify(() => getPeriodLogs(any())).called(1);
        verify(() => getDayLogs(any())).called(1);
      },
    );

    blocTest<PeriodCubit, PeriodState>(
      'emits error when day logs fail to load',
      build: () {
        when(() => getPeriodLogs(any())).thenAnswer((_) async => const Right([]));
        when(() => getDayLogs(any()))
            .thenAnswer((_) async => const Left(ServerFailure()));
        return buildCubit();
      },
      act: (cubit) => cubit.load(userId),
      expect: () => [isA<PeriodLoading>(), isA<PeriodError>()],
    );
  });

  group('saveDayLog', () {
    blocTest<PeriodCubit, PeriodState>(
      'optimistically adds the log, then reconciles with the saved row',
      build: () {
        stubLoad();
        when(() => upsertDayLog(any()))
            .thenAnswer((_) async => Right(_dayLog(id: 'saved-1')));
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.load(userId);
        await cubit.saveDayLog(day, mood: Mood.happy);
      },
      expect: () => [
        isA<PeriodLoading>(),
        isA<PeriodLoaded>().having((s) => s.dayLogs, 'dayLogs', isEmpty),
        isA<PeriodLoaded>()
            .having((s) => s.dayLogs.length, 'optimistic', 1)
            .having((s) => s.isLoading, 'isLoading', true),
        isA<PeriodLoaded>()
            .having((s) => s.dayLogs.single.id, 'saved id', 'saved-1')
            .having((s) => s.isLoading, 'isLoading', false),
      ],
    );

    blocTest<PeriodCubit, PeriodState>(
      'rolls back to the previous logs when the save fails',
      build: () {
        stubLoad();
        when(() => upsertDayLog(any()))
            .thenAnswer((_) async => const Left(ServerFailure('nope')));
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.load(userId);
        await cubit.saveDayLog(day, mood: Mood.happy);
      },
      verify: (cubit) {
        final state = cubit.state as PeriodLoaded;
        expect(state.dayLogs, isEmpty);
        expect(state.mutationFailure, isNotNull);
      },
    );

    blocTest<PeriodCubit, PeriodState>(
      'clears a prior mutation failure once a later save succeeds',
      build: () {
        stubLoad();
        var calls = 0;
        when(() => upsertDayLog(any())).thenAnswer((_) async {
          calls++;
          return calls == 1
              ? const Left(ServerFailure('boom'))
              : Right(_dayLog(id: 'saved-1'));
        });
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.load(userId);
        await cubit.saveDayLog(day, mood: Mood.sad); // fails
        await cubit.saveDayLog(day, mood: Mood.happy); // succeeds
      },
      verify: (cubit) {
        final state = cubit.state as PeriodLoaded;
        expect(state.mutationFailure, isNull);
        expect(state.dayLogs.single.id, 'saved-1');
      },
    );

    blocTest<PeriodCubit, PeriodState>(
      'deletes an existing log when every tracker is cleared',
      build: () {
        stubLoad(dayLogs: [_dayLog(id: 'existing-1')]);
        when(() => deleteDayLog(any())).thenAnswer((_) async => const Right(null));
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.load(userId);
        // No trackers passed → the day log becomes empty and is removed.
        await cubit.saveDayLog(day);
      },
      verify: (cubit) {
        verify(() => deleteDayLog(any())).called(1);
        verifyNever(() => upsertDayLog(any()));
        expect((cubit.state as PeriodLoaded).dayLogs, isEmpty);
      },
    );
  });

  group('deleteDayLog', () {
    blocTest<PeriodCubit, PeriodState>(
      'removes the log from state',
      build: () {
        stubLoad(dayLogs: [_dayLog(id: 'existing-1')]);
        when(() => deleteDayLog(any())).thenAnswer((_) async => const Right(null));
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.load(userId);
        await cubit.deleteDayLog('existing-1');
      },
      verify: (cubit) {
        expect((cubit.state as PeriodLoaded).dayLogs, isEmpty);
        verify(() => deleteDayLog(any())).called(1);
      },
    );
  });
}
