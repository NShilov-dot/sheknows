import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sheknows/core/error/failures.dart';
import 'package:sheknows/features/symptoms/domain/entities/symptom_log_entity.dart';
import 'package:sheknows/features/symptoms/domain/usecases/symptom_usecases.dart';
import 'package:sheknows/features/symptoms/presentation/cubit/symptoms_cubit.dart';
import 'package:sheknows/features/symptoms/presentation/cubit/symptoms_state.dart';

class _MockGetSymptomLogs extends Mock implements GetSymptomLogsUseCase {}

class _MockLogSymptom extends Mock implements LogSymptomUseCase {}

class _MockUpdateSymptomLog extends Mock implements UpdateSymptomLogUseCase {}

class _MockDeleteSymptomLog extends Mock implements DeleteSymptomLogUseCase {}

SymptomLogEntity _log({
  String id = 'sym-1',
  SymptomType type = SymptomType.cramps,
  SymptomSeverity severity = SymptomSeverity.moderate,
  DateTime? loggedAt,
}) {
  return SymptomLogEntity(
    id: id,
    userId: 'user-1',
    type: type,
    severity: severity,
    loggedAt: loggedAt ?? DateTime(2026, 8, 20, 9),
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
}

void main() {
  late _MockGetSymptomLogs getSymptomLogs;
  late _MockLogSymptom logSymptom;
  late _MockUpdateSymptomLog updateSymptomLog;
  late _MockDeleteSymptomLog deleteSymptomLog;

  const userId = 'user-1';

  setUpAll(() {
    registerFallbackValue(const GetSymptomLogsParams(userId: userId));
    registerFallbackValue(
      LogSymptomParams(
        userId: userId,
        type: SymptomType.cramps,
        severity: SymptomSeverity.moderate,
        loggedAt: DateTime(2026, 8, 20, 9),
      ),
    );
    registerFallbackValue(const UpdateSymptomLogParams(id: 'sym-1'));
    registerFallbackValue(const DeleteSymptomLogParams('sym-1'));
  });

  setUp(() {
    getSymptomLogs = _MockGetSymptomLogs();
    logSymptom = _MockLogSymptom();
    updateSymptomLog = _MockUpdateSymptomLog();
    deleteSymptomLog = _MockDeleteSymptomLog();
  });

  SymptomsCubit buildCubit() => SymptomsCubit(
        getSymptomLogs: getSymptomLogs,
        logSymptom: logSymptom,
        updateSymptomLog: updateSymptomLog,
        deleteSymptomLog: deleteSymptomLog,
      );

  void stubLoad({List<SymptomLogEntity> logs = const []}) {
    when(() => getSymptomLogs(any())).thenAnswer((_) async => Right(logs));
  }

  group('load', () {
    blocTest<SymptomsCubit, SymptomsState>(
      'fetches symptom logs, newest first',
      build: () {
        stubLoad(logs: [
          _log(id: 'old', loggedAt: DateTime(2026, 8, 19, 9)),
          _log(id: 'new', loggedAt: DateTime(2026, 8, 20, 9)),
        ]);
        return buildCubit();
      },
      act: (cubit) => cubit.load(userId),
      expect: () => [
        isA<SymptomsLoading>(),
        isA<SymptomsLoaded>()
            .having((s) => s.logs.first.id, 'newest first', 'new')
            .having((s) => s.logs.length, 'count', 2),
      ],
    );

    blocTest<SymptomsCubit, SymptomsState>(
      'emits error when the load fails',
      build: () {
        when(() => getSymptomLogs(any()))
            .thenAnswer((_) async => const Left(ServerFailure()));
        return buildCubit();
      },
      act: (cubit) => cubit.load(userId),
      expect: () => [isA<SymptomsLoading>(), isA<SymptomsError>()],
    );
  });

  group('logSymptom', () {
    blocTest<SymptomsCubit, SymptomsState>(
      'optimistically flags loading, then inserts the saved log',
      build: () {
        stubLoad();
        when(() => logSymptom(any()))
            .thenAnswer((_) async => Right(_log(id: 'saved-1')));
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.load(userId);
        await cubit.logSymptom(
          type: SymptomType.cramps,
          severity: SymptomSeverity.moderate,
          loggedAt: DateTime(2026, 8, 20, 9),
        );
      },
      expect: () => [
        isA<SymptomsLoading>(),
        isA<SymptomsLoaded>().having((s) => s.logs, 'empty', isEmpty),
        isA<SymptomsLoaded>().having((s) => s.isLoading, 'loading', true),
        isA<SymptomsLoaded>()
            .having((s) => s.logs.single.id, 'saved id', 'saved-1')
            .having((s) => s.isLoading, 'loading', false),
      ],
    );

    blocTest<SymptomsCubit, SymptomsState>(
      'rolls back and surfaces the failure when the save fails',
      build: () {
        stubLoad();
        when(() => logSymptom(any()))
            .thenAnswer((_) async => const Left(ServerFailure('nope')));
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.load(userId);
        await cubit.logSymptom(
          type: SymptomType.cramps,
          severity: SymptomSeverity.moderate,
          loggedAt: DateTime(2026, 8, 20, 9),
        );
      },
      verify: (cubit) {
        final state = cubit.state as SymptomsLoaded;
        expect(state.logs, isEmpty);
        expect(state.mutationFailure, isNotNull);
      },
    );

    blocTest<SymptomsCubit, SymptomsState>(
      'clears a prior mutation failure once a later save succeeds',
      build: () {
        stubLoad();
        var calls = 0;
        when(() => logSymptom(any())).thenAnswer((_) async {
          calls++;
          return calls == 1
              ? const Left(ServerFailure('boom'))
              : Right(_log(id: 'saved-1'));
        });
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.load(userId);
        await cubit.logSymptom(
          type: SymptomType.cramps,
          severity: SymptomSeverity.mild,
          loggedAt: DateTime(2026, 8, 20, 9),
        );
        await cubit.logSymptom(
          type: SymptomType.cramps,
          severity: SymptomSeverity.severe,
          loggedAt: DateTime(2026, 8, 20, 10),
        );
      },
      verify: (cubit) {
        final state = cubit.state as SymptomsLoaded;
        expect(state.mutationFailure, isNull);
        expect(state.logs.single.id, 'saved-1');
      },
    );
  });

  group('updateSymptomLog', () {
    blocTest<SymptomsCubit, SymptomsState>(
      'replaces the edited log with the saved row',
      build: () {
        stubLoad(logs: [_log(id: 'sym-1', severity: SymptomSeverity.mild)]);
        when(() => updateSymptomLog(any())).thenAnswer(
          (_) async => Right(_log(id: 'sym-1', severity: SymptomSeverity.severe)),
        );
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.load(userId);
        await cubit.updateSymptomLog(
          id: 'sym-1',
          severity: SymptomSeverity.severe,
        );
      },
      verify: (cubit) {
        final state = cubit.state as SymptomsLoaded;
        expect(state.logs.single.severity, SymptomSeverity.severe);
        expect(state.mutationFailure, isNull);
      },
    );
  });

  group('deleteSymptomLog', () {
    blocTest<SymptomsCubit, SymptomsState>(
      'removes the log from state',
      build: () {
        stubLoad(logs: [_log(id: 'sym-1')]);
        when(() => deleteSymptomLog(any()))
            .thenAnswer((_) async => const Right(null));
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.load(userId);
        await cubit.deleteSymptomLog('sym-1');
      },
      verify: (cubit) {
        expect((cubit.state as SymptomsLoaded).logs, isEmpty);
        verify(() => deleteSymptomLog(any())).called(1);
      },
    );

    blocTest<SymptomsCubit, SymptomsState>(
      'restores the log and surfaces the failure when delete fails',
      build: () {
        stubLoad(logs: [_log(id: 'sym-1')]);
        when(() => deleteSymptomLog(any()))
            .thenAnswer((_) async => const Left(ServerFailure('nope')));
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.load(userId);
        await cubit.deleteSymptomLog('sym-1');
      },
      verify: (cubit) {
        final state = cubit.state as SymptomsLoaded;
        expect(state.logs.single.id, 'sym-1');
        expect(state.mutationFailure, isNotNull);
      },
    );
  });
}
