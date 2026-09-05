import 'package:flutter_test/flutter_test.dart';

import 'package:client/core/cubit/safe_action_cubit.dart';
import 'package:client/core/errors/app_exception.dart';

class _TestState {
  final String status;
  final String? error;

  const _TestState({required this.status, this.error});
}

class _TestCubit extends SafeActionCubit<_TestState> {
  _TestCubit() : super(const _TestState(status: 'initial'));

  Future<int?> performSuccessAction(int value) async {
    return await safeExecute<int>(() async {
      emit(const _TestState(status: 'running'));
      emit(const _TestState(status: 'success'));
      return value * 2;
    }, onError: (message) => emit(_TestState(status: 'error', error: message)));
  }

  Future<int?> performAppExceptionAction(String errorMessage) async {
    return await safeExecute<int>(
      () async {
        emit(const _TestState(status: 'running'));
        throw ValidationException(message: errorMessage);
      },
      onError: (message) => emit(_TestState(status: 'error', error: message)),
      defaultErrorMessage: 'Fallback message',
    );
  }

  Future<int?> performGenericExceptionAction() async {
    return await safeExecute<int>(
      () async {
        emit(const _TestState(status: 'running'));
        throw Exception('Something bad');
      },
      onError: (message) => emit(_TestState(status: 'error', error: message)),
      defaultErrorMessage: 'Custom unexpected error',
    );
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
      expect(cubit.state.error, isNull);
    });

    test('executes action successfully and returns value', () async {
      final result = await cubit.performSuccessAction(5);
      expect(result, 10);
      expect(cubit.state.status, 'success');
      expect(cubit.state.error, isNull);
    });

    test('catches AppException and passes message to onError', () async {
      final result = await cubit.performAppExceptionAction(
        'Specific validation error',
      );
      expect(result, isNull);
      expect(cubit.state.status, 'error');
      expect(cubit.state.error, 'Specific validation error');
    });

    test(
      'catches generic Exception and passes defaultErrorMessage to onError',
      () async {
        final result = await cubit.performGenericExceptionAction();
        expect(result, isNull);
        expect(cubit.state.status, 'error');
        expect(cubit.state.error, 'Custom unexpected error');
      },
    );
  });
}
