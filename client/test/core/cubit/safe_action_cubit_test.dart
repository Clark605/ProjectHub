import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/core/cubit/safe_action_cubit.dart';
import 'package:client/core/errors/app_exception.dart';
import 'package:client/core/errors/app_failure.dart';
import 'package:client/core/l10n/l10n_extension.dart';
import 'package:client/l10n/generated/app_localizations_ar.dart';
import 'package:client/l10n/generated/app_localizations_en.dart';

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

class _CustomNotFoundException extends NotFoundException {
  const _CustomNotFoundException({super.message = 'Custom resource missing'});
}

void main() {
  group('AppFailure.fromException & AppFailureL10n', () {
    test(
      'maps exception types (including subclasses) to FailureKind and enforces isUserSafe only for 4xx/validation',
      () {
        final cases = <(Object, AppFailure)>[
          (
            const NetworkException(message: 'Socket closed'),
            const AppFailure(
              kind: FailureKind.network,
              serverMessage: 'Socket closed',
              isUserSafe: false,
            ),
          ),
          (
            const UnauthorizedException(message: 'Invalid token'),
            const AppFailure(
              kind: FailureKind.unauthorized,
              serverMessage: 'Invalid token',
              isUserSafe: true,
            ),
          ),
          (
            const ForbiddenException(message: 'Owner role required'),
            const AppFailure(
              kind: FailureKind.forbidden,
              serverMessage: 'Owner role required',
              isUserSafe: true,
            ),
          ),
          (
            const NotFoundException(message: 'Task 42 not found'),
            const AppFailure(
              kind: FailureKind.notFound,
              serverMessage: 'Task 42 not found',
              isUserSafe: true,
            ),
          ),
          (
            const _CustomNotFoundException(),
            const AppFailure(
              kind: FailureKind.notFound,
              serverMessage: 'Custom resource missing',
              isUserSafe: true,
            ),
          ),
          (
            const ValidationException(message: 'Title is required'),
            const AppFailure(
              kind: FailureKind.validation,
              serverMessage: 'Title is required',
              isUserSafe: true,
            ),
          ),
          (
            const ValidationException(message: '   '),
            const AppFailure(
              kind: FailureKind.validation,
              serverMessage: null,
              isUserSafe: false,
            ),
          ),
          (
            const ServerException(message: 'NullReferenceException at line 9'),
            const AppFailure(
              kind: FailureKind.server,
              serverMessage: 'NullReferenceException at line 9',
              isUserSafe: false,
            ),
          ),
          (
            const AppException(message: 'Internal error'),
            const AppFailure(
              kind: FailureKind.server,
              serverMessage: 'Internal error',
              isUserSafe: false,
            ),
          ),
          (
            StateError('bad state'),
            const AppFailure(kind: FailureKind.unknown, isUserSafe: false),
          ),
        ];

        for (final (exception, expected) in cases) {
          expect(
            AppFailure.fromException(exception),
            expected,
            reason: 'Failed mapping for ${exception.runtimeType}',
          );
        }
      },
    );

    test(
      'AppFailureL10n localizes every FailureKind and hides non-user-safe server messages',
      () {
        final en = AppLocalizationsEn();
        final ar = AppLocalizationsAr();

        // User-safe 4xx message is preserved
        expect(
          const AppFailure(
            kind: FailureKind.forbidden,
            serverMessage: 'Custom 403 reason',
            isUserSafe: true,
          ).toLocalizedMessage(en),
          'Custom 403 reason',
        );

        // Non-user-safe 5xx message uses localized generic server message
        expect(
          const AppFailure(
            kind: FailureKind.server,
            serverMessage: 'SQL timeout stacktrace',
            isUserSafe: false,
          ).toLocalizedMessage(en),
          en.serverErrorMessage,
        );

        // Fallback localization table when serverMessage is null
        for (final l10n in [en, ar]) {
          expect(
            const AppFailure(
              kind: FailureKind.network,
              isUserSafe: false,
            ).toLocalizedMessage(l10n),
            l10n.connectionErrorMessage,
          );
          expect(
            const AppFailure(
              kind: FailureKind.unauthorized,
              isUserSafe: false,
            ).toLocalizedMessage(l10n),
            l10n.sessionExpiredMessage,
          );
          expect(
            const AppFailure(
              kind: FailureKind.forbidden,
              isUserSafe: false,
            ).toLocalizedMessage(l10n),
            l10n.forbiddenErrorMessage,
          );
          expect(
            const AppFailure(
              kind: FailureKind.notFound,
              isUserSafe: false,
            ).toLocalizedMessage(l10n),
            l10n.notFoundErrorMessage,
          );
          expect(
            const AppFailure(
              kind: FailureKind.validation,
              isUserSafe: false,
            ).toLocalizedMessage(l10n),
            l10n.validationErrorMessage,
          );
          expect(
            const AppFailure(
              kind: FailureKind.server,
              isUserSafe: false,
            ).toLocalizedMessage(l10n),
            l10n.serverErrorMessage,
          );
          expect(
            const AppFailure(
              kind: FailureKind.speechUnavailable,
              isUserSafe: false,
            ).toLocalizedMessage(l10n),
            l10n.voiceTaskSpeechUnavailable,
          );
          expect(
            const AppFailure(
              kind: FailureKind.unknown,
              isUserSafe: false,
            ).toLocalizedMessage(l10n),
            l10n.error,
          );
        }
      },
    );
  });

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
      'catches AppException, logs with default runtimeType tag, and passes AppFailure to onFailure',
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
      'catches generic Exception, logs with default runtimeType tag, and passes non-user-safe unknown AppFailure',
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
      'safeExecute logs failure even after cubit is closed but skips onFailure',
      () async {
        final originalDebugPrint = debugPrint;
        final logs = <String>[];
        debugPrint = (String? message, {int? wrapWidth}) {
          if (message != null) logs.add(message);
        };
        addTearDown(() => debugPrint = originalDebugPrint);

        bool onFailureCalled = false;
        final future = cubit.safeExecute<int>(() async {
          await Future.delayed(const Duration(milliseconds: 10));
          throw Exception('late error after close');
        }, onFailure: (_) => onFailureCalled = true);
        await cubit.close();
        final result = await future;
        expect(result, isNull);
        expect(onFailureCalled, isFalse);
        expect(logs.any((l) => l.contains('late error after close')), isTrue);
      },
    );
  });
}
