import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/core/cubit/safe_action_cubit.dart';
import 'package:client/core/errors/app_exception.dart';
import 'package:client/core/errors/app_failure.dart';
import 'package:client/core/l10n/l10n_extension.dart';
import 'package:client/l10n/generated/app_localizations.dart';
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
      throw ValidationException(message: message, serverMessage: message);
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
  const _CustomNotFoundException() : super(message: 'Custom resource missing');
}

void main() {
  group('AppFailure.fromException & AppFailureL10n', () {
    test(
      'maps exception types (including subclasses) to FailureKind and enforces isUserSafe only for 4xx/validation with serverMessage',
      () {
        final cases = <(Object, AppFailure)>[
          (
            const NetworkException(message: 'Socket closed'),
            const AppFailure(
              kind: FailureKind.network,
              serverMessage: null,
              isUserSafe: false,
            ),
          ),
          (
            const NetworkException(
              message: 'Socket closed',
              serverMessage: 'DNS failed',
            ),
            const AppFailure(
              kind: FailureKind.network,
              serverMessage: 'DNS failed',
              isUserSafe: false,
            ),
          ),
          (
            const UnauthorizedException(
              message: 'Invalid token',
              serverMessage: 'Invalid token',
            ),
            const AppFailure(
              kind: FailureKind.unauthorized,
              serverMessage: 'Invalid token',
              isUserSafe: true,
            ),
          ),
          (
            const UnauthorizedException(),
            const AppFailure(
              kind: FailureKind.unauthorized,
              serverMessage: null,
              isUserSafe: false,
            ),
          ),
          (
            const ForbiddenException(
              message: 'Owner role required',
              serverMessage: 'Owner role required',
            ),
            const AppFailure(
              kind: FailureKind.forbidden,
              serverMessage: 'Owner role required',
              isUserSafe: true,
            ),
          ),
          (
            const ForbiddenException(),
            const AppFailure(
              kind: FailureKind.forbidden,
              serverMessage: null,
              isUserSafe: false,
            ),
          ),
          (
            const NotFoundException(
              message: 'Task 42 not found',
              serverMessage: 'Task 42 not found',
            ),
            const AppFailure(
              kind: FailureKind.notFound,
              serverMessage: 'Task 42 not found',
              isUserSafe: true,
            ),
          ),
          (
            const NotFoundException(),
            const AppFailure(
              kind: FailureKind.notFound,
              serverMessage: null,
              isUserSafe: false,
            ),
          ),
          (
            const _CustomNotFoundException(),
            const AppFailure(
              kind: FailureKind.notFound,
              serverMessage: null,
              isUserSafe: false,
            ),
          ),
          (
            const ValidationException(
              message: 'Title is required',
              serverMessage: 'Title is required',
            ),
            const AppFailure(
              kind: FailureKind.validation,
              serverMessage: 'Title is required',
              isUserSafe: true,
            ),
          ),
          (
            const ValidationException(message: 'Title is required'),
            const AppFailure(
              kind: FailureKind.validation,
              serverMessage: null,
              isUserSafe: false,
            ),
          ),
          (
            const ValidationException(message: '   ', serverMessage: '   '),
            const AppFailure(
              kind: FailureKind.validation,
              serverMessage: null,
              isUserSafe: false,
            ),
          ),
          (
            const ServerException(
              message: 'NullReferenceException at line 9',
              serverMessage: 'NullReferenceException at line 9',
            ),
            const AppFailure(
              kind: FailureKind.server,
              serverMessage: 'NullReferenceException at line 9',
              isUserSafe: false,
            ),
          ),
          (
            const ServerException(message: 'NullReferenceException at line 9'),
            const AppFailure(
              kind: FailureKind.server,
              serverMessage: null,
              isUserSafe: false,
            ),
          ),
          (
            const AppException(
              message: 'Internal error',
              serverMessage: 'Internal error',
            ),
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

    testWidgets(
      'each default-constructed exception maps to localized string in en and ar via context',
      (tester) async {
        final exceptions = <AppException>[
          const UnauthorizedException(),
          const ForbiddenException(),
          const NotFoundException(),
          const NetworkException(),
          const ValidationException(message: 'Validation failed'),
          const ServerException(message: 'Server failed'),
        ];

        for (final locale in [const Locale('en'), const Locale('ar')]) {
          late BuildContext capturedContext;
          await tester.pumpWidget(
            MaterialApp(
              locale: locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Builder(
                builder: (context) {
                  capturedContext = context;
                  return const SizedBox.shrink();
                },
              ),
            ),
          );
          await tester.pumpAndSettle();

          final l10n = capturedContext.l10n;
          for (final ex in exceptions) {
            final failure = AppFailure.fromException(ex);
            final localized = failure.localized(capturedContext);
            expect(
              localized,
              failure.toLocalizedMessage(l10n),
              reason: 'Mismatch for ${ex.runtimeType} in $locale',
            );

            // In Arabic, English default messages should never leak
            if (locale == const Locale('ar')) {
              expect(localized, isNot(contains('Unauthorized')));
              expect(localized, isNot(contains('Forbidden')));
              expect(localized, isNot(contains('Not found')));
              expect(localized, isNot(contains('No internet connection')));
              expect(localized, isNot(contains('Validation failed')));
              expect(localized, isNot(contains('Server failed')));
            }
          }

          // ValidationException with a server message shows that message
          const validationWithMsg = ValidationException(
            message: 'Internal log msg',
            serverMessage: 'Email already exists',
          );
          expect(
            AppFailure.fromException(
              validationWithMsg,
            ).localized(capturedContext),
            'Email already exists',
          );

          // ServerException with a message still shows the localized generic
          const serverWithMsg = ServerException(
            message: 'Internal log msg',
            serverMessage: 'Database connection failed',
          );
          expect(
            AppFailure.fromException(serverWithMsg).localized(capturedContext),
            l10n.serverErrorMessage,
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
        () async => throw const ValidationException(
          message: 'Invalid input',
          serverMessage: 'Invalid input',
        ),
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
