import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sheknows/core/error/failures.dart';
import 'package:sheknows/features/profile/domain/entities/profile_entity.dart';
import 'package:sheknows/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:sheknows/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:sheknows/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:sheknows/features/profile/presentation/cubit/profile_state.dart';

class _MockGetProfile extends Mock implements GetProfileUseCase {}

class _MockUpdateProfile extends Mock implements UpdateProfileUseCase {}

void main() {
  late _MockGetProfile getProfile;
  late _MockUpdateProfile updateProfile;

  const userId = 'user-1';
  const stored = ProfileEntity(
    id: userId,
    displayName: 'Anna',
    avatarUrl: 'https://example.com/a.png',
  );
  const failure = ServerFailure('boom');

  setUpAll(() {
    registerFallbackValue(const GetProfileParams(userId));
    registerFallbackValue(
      const UpdateProfileParams(userId: userId, displayName: null),
    );
  });

  setUp(() {
    getProfile = _MockGetProfile();
    updateProfile = _MockUpdateProfile();
  });

  ProfileCubit buildCubit() =>
      ProfileCubit(getProfile: getProfile, updateProfile: updateProfile);

  void stubLoad(Either<Failure, ProfileEntity?> result) =>
      when(() => getProfile(any())).thenAnswer((_) async => result);

  void stubUpdate(Either<Failure, ProfileEntity> result) =>
      when(() => updateProfile(any())).thenAnswer((_) async => result);

  group('loadProfile', () {
    blocTest<ProfileCubit, ProfileState>(
      'emits loading then the stored row',
      build: () {
        stubLoad(const Right(stored));
        return buildCubit();
      },
      act: (cubit) => cubit.loadProfile(userId),
      expect: () => const [ProfileLoading(), ProfileLoaded(stored)],
    );

    blocTest<ProfileCubit, ProfileState>(
      'emits loaded(null) when the user has no row yet',
      build: () {
        stubLoad(const Right(null));
        return buildCubit();
      },
      act: (cubit) => cubit.loadProfile(userId),
      expect: () => const [ProfileLoading(), ProfileLoaded(null)],
    );

    blocTest<ProfileCubit, ProfileState>(
      'emits error when the load fails',
      build: () {
        stubLoad(const Left(failure));
        return buildCubit();
      },
      act: (cubit) => cubit.loadProfile(userId),
      expect: () => const [ProfileLoading(), ProfileError(failure)],
    );

    blocTest<ProfileCubit, ProfileState>(
      'skips a repeat load for the same user unless forced',
      build: () {
        stubLoad(const Right(stored));
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.loadProfile(userId);
        await cubit.loadProfile(userId);
        await cubit.loadProfile(userId, force: true);
      },
      expect: () => const [
        ProfileLoading(),
        ProfileLoaded(stored),
        ProfileLoading(),
        ProfileLoaded(stored),
      ],
      verify: (_) => verify(() => getProfile(any())).called(2),
    );
  });

  group('updateDisplayName', () {
    const saved = ProfileEntity(
      id: userId,
      displayName: 'Anna K.',
      avatarUrl: 'https://example.com/a.png',
    );

    blocTest<ProfileCubit, ProfileState>(
      'shows the trimmed name at once, then the row as stored',
      build: () {
        stubLoad(const Right(stored));
        stubUpdate(const Right(saved));
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.loadProfile(userId);
        await cubit.updateDisplayName('  Anna K.  ');
      },
      skip: 2,
      expect: () => const [
        // Optimistic: the new name with the avatar carried over.
        ProfileLoaded(saved, isSaving: true),
        ProfileLoaded(saved),
      ],
      // Params carry no ==, so capture and inspect instead of matching.
      verify: (_) {
        final params = verify(() => updateProfile(captureAny())).captured.single
            as UpdateProfileParams;
        expect(params.userId, userId);
        expect(params.displayName, 'Anna K.');
      },
    );

    blocTest<ProfileCubit, ProfileState>(
      'treats a blank name as clearing it',
      build: () {
        stubLoad(const Right(stored));
        stubUpdate(const Right(ProfileEntity(id: userId)));
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.loadProfile(userId);
        await cubit.updateDisplayName('   ');
      },
      skip: 3,
      expect: () => const [ProfileLoaded(ProfileEntity(id: userId))],
      verify: (_) {
        final params = verify(() => updateProfile(captureAny())).captured.single
            as UpdateProfileParams;
        expect(params.displayName, isNull);
      },
    );

    blocTest<ProfileCubit, ProfileState>(
      'rolls back to the stored row and surfaces the failure',
      build: () {
        stubLoad(const Right(stored));
        stubUpdate(const Left(failure));
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.loadProfile(userId);
        await cubit.updateDisplayName('Anna K.');
      },
      skip: 3,
      expect: () => const [ProfileLoaded(stored, mutationFailure: failure)],
    );

    blocTest<ProfileCubit, ProfileState>(
      'does nothing when the name is unchanged or nothing is loaded',
      build: () {
        stubLoad(const Right(stored));
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.updateDisplayName('Anna'); // before any load
        await cubit.loadProfile(userId);
        await cubit.updateDisplayName(' Anna ');
      },
      skip: 2,
      expect: () => const <ProfileState>[],
      verify: (_) => verifyNever(() => updateProfile(any())),
    );
  });

  blocTest<ProfileCubit, ProfileState>(
    'reset returns to initial and forgets the user',
    build: () {
      stubLoad(const Right(stored));
      return buildCubit();
    },
    act: (cubit) async {
      await cubit.loadProfile(userId);
      cubit.reset();
      await cubit.loadProfile(userId);
    },
    expect: () => const [
      ProfileLoading(),
      ProfileLoaded(stored),
      ProfileInitial(),
      ProfileLoading(),
      ProfileLoaded(stored),
    ],
  );
}
