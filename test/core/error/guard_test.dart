import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheknows/core/error/exceptions.dart';
import 'package:sheknows/core/error/failures.dart';
import 'package:sheknows/core/error/guard.dart';

void main() {
  group('guard', () {
    test('passes a value straight through', () async {
      expect(await guard(() async => 7), const Right<Failure, int>(7));
    });

    test('carries a ServerException message onto ServerFailure', () async {
      final result = await guard<int>(
        () async => throw const ServerException('rls denied'),
      );
      expect(result, const Left<Failure, int>(ServerFailure('rls denied')));
    });

    test('maps anything else to UnknownFailure', () async {
      final result = await guard<int>(() async => throw StateError('boom'));
      expect(result, const Left<Failure, int>(UnknownFailure()));
    });

    test('supports void calls', () async {
      expect(await guard<void>(() async {}), isA<Right<Failure, void>>());
    });
  });

  group('guardAuth', () {
    test('maps AuthException onto AuthFailure, not UnknownFailure', () async {
      final result = await guardAuth<int>(
        () async => throw const AuthException('bad password'),
      );
      expect(result, const Left<Failure, int>(AuthFailure('bad password')));
    });

    test('still maps ServerException onto ServerFailure', () async {
      final result = await guardAuth<int>(
        () async => throw const ServerException('rpc failed'),
      );
      expect(result, const Left<Failure, int>(ServerFailure('rpc failed')));
    });
  });
}
