import 'package:flutter_test/flutter_test.dart';

import 'package:client/core/cubit/safe_action_cubit.dart';
import 'package:client/core/errors/app_exception.dart';
import 'package:client/core/errors/app_failure.dart';

class _TestState {
  final String status;
  final AppFailure? failure;

  const _TestState({required this.status, this.failure});
}

class _TestCubit extends SafeActionCubit<_TestState> {
  _TestCubit() : super(const _TestState(status: 'initial'));

  Future<int?> performSuccessAction(int value) async {
    return await safeExecute<int>(() async {
      emit(const _TestState(status: 'running'));
      emit(const _TestState(status: 'success'));
      return value * 2;
    }, onFailure: (f) => emit(_TestState(status: 'error', failure: f)));
  }

  Future<int?> performAppExceptionAction(String message) async {
    return await safeExecute<int>(() async {
      emit(const _TestState(status: 'running'));
      throw ValidationException(message: message);
    }, onFailure: (f) => emit(_TestState(status: 'error', failure: f)));
  }

  Future<int?> performGenericExceptionAction() async {
    return await safeExecute<int>(() async {
      emit(const _TestState(status: 'running'));
      throw Exception('Something bad');
    }, onFailure: (f) => emit(_TestState(status: 'error', failure: f)));
  }
}

void main() {
  group('SafeActionCubit', () {
    late _TestCubit cubit;

    setUp(() {
      cubit = _TestCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is correct', () {
      expect(cubit.state.status, 'initial');
      expect(cubit.state.failure, isNull);
    });

    test('executes action successfully and returns value', () async {
      final result = await cubit.performSuccessAction(5);
      expect(result, 10);
      expect(cubit.state.status, 'success');
      expect(cubit.state.failure, isNull);
    });

    test(
      'catches AppException and passes user-safe AppFailure to onFailure',
      () async {
        final result = await cubit.performAppExceptionAction(
          'Specific validation error',
        );
        expect(result, isNull);
        expect(cubit.state.status, 'error');
        expect(
          cubit.state.failure,
          const AppFailure(
            kind: FailureKind.validation,
            serverMessage: 'Specific validation error',
            isUserSafe: true,
          ),
        );
      },
    );

    test(
      'catches generic Exception and passes non-user-safe unknown AppFailure to onFailure',
      () async {
        final result = await cubit.performGenericExceptionAction();
        expect(result, isNull);
        expect(cubit.state.status, 'error');
        expect(
          cubit.state.failure,
          const AppFailure(kind: FailureKind.unknown, isUserSafe: false),
        );
      },
    );

    test('emit does not throw StateError after cubit is closed', () async {
      await cubit.close();
      expect(
        () => cubit.emit(const _TestState(status: 'after_close')),
        returnsNormally,
      );
    });

    test('passes typed AppFailure to onFailure callback', () async {
      AppFailure? capturedFailure;
      await cubit.safeExecute<int>(
        () async => throw const ValidationException(message: 'Invalid input'),
        onFailure: (failure) => capturedFailure = failure,
      );
      expect(capturedFailure, isNotNull);
      expect(capturedFailure!.kind, FailureKind.validation);
      expect(capturedFailure!.serverMessage, 'Invalid input');
      expect(capturedFailure!.isUserSafe, isTrue);
    });

    test(
      'safeExecute does not invoke onFailure or throw after cubit is closed',
      () async {
        bool onFailureCalled = false;
        final future = cubit.safeExecute<int>(() async {
          await Future.delayed(const Duration(milliseconds: 10));
          throw Exception('late error');
        }, onFailure: (_) => onFailureCalled = true);
        await cubit.close();
        final result = await future;
        expect(result, isNull);
        expect(onFailureCalled, isFalse);
      },
    );
  });
}
