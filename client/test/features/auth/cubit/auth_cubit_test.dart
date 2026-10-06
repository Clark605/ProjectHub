import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:client/core/errors/app_exception.dart';
import 'package:client/features/auth/cubit/app_auth_cubit.dart';
import 'package:client/features/auth/cubit/app_auth_state.dart';
import 'package:client/features/auth/cubit/login_cubit.dart';
import 'package:client/features/auth/cubit/login_state.dart';
import 'package:client/features/auth/data/auth_repository.dart';
import 'package:client/features/auth/data/models/auth_dtos.dart';
import 'package:client/features/auth/data/models/user.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(
      const LoginDto(email: 'test@example.com', password: 'password'),
    );
  });

  group('AppAuthCubit', () {
    late MockAuthRepository repository;
    late StreamController<User?> authStateController;

    setUp(() {
      repository = MockAuthRepository();
      authStateController = StreamController<User?>.broadcast();
      when(() => repository.authStateChanges).thenAnswer(
        (_) => authStateController.stream,
      );
    });

    tearDown(() async {
      await authStateController.close();
    });

    test('initial state is AppAuthState.initial()', () {
      final cubit = AppAuthCubit(repository);
      expect(cubit.state, const AppAuthState.initial());
      cubit.close();
    });

    blocTest<AppAuthCubit, AppAuthState>(
      'checkAuthStatus emits unauthenticated when no session',
      build: () {
        when(() => repository.restoreSession()).thenAnswer((_) async => null);
        return AppAuthCubit(repository);
      },
      act: (cubit) => cubit.checkAuthStatus(),
      expect: () => [const AppAuthState.unauthenticated()],
    );

    blocTest<AppAuthCubit, AppAuthState>(
      'checkAuthStatus emits authenticated when session restored',
      build: () {
        when(() => repository.restoreSession()).thenAnswer(
          (_) async => const User(
            id: 'user_1',
            name: 'Cached Clark',
            email: 'cached@example.com',
          ),
        );
        return AppAuthCubit(repository);
      },
      act: (cubit) => cubit.checkAuthStatus(),
      expect: () => [
        const AppAuthState.authenticated(
          User(id: 'user_1', name: 'Cached Clark', email: 'cached@example.com'),
        ),
      ],
    );

    blocTest<AppAuthCubit, AppAuthState>(
      'syncUser updates and emits authenticated',
      build: () {
        when(() => repository.getCurrentUser()).thenAnswer(
          (_) async => const User(
            name: 'Updated Clark',
            email: 'updated@example.com',
          ),
        );
        return AppAuthCubit(repository);
      },
      act: (cubit) => cubit.syncUser(),
      expect: () => [
        const AppAuthState.authenticated(
          User(name: 'Updated Clark', email: 'updated@example.com'),
        ),
      ],
    );

    blocTest<AppAuthCubit, AppAuthState>(
      'logout calls repository logout and handles state',
      build: () {
        when(() => repository.logout()).thenAnswer((_) async {});
        return AppAuthCubit(repository);
      },
      act: (cubit) async {
        await cubit.logout();
        authStateController.add(null);
      },
      expect: () => [const AppAuthState.unauthenticated()],
      verify: (_) {
        verify(() => repository.logout()).called(1);
      },
    );

    blocTest<AppAuthCubit, AppAuthState>(
      'reacts to authStateChanges stream',
      build: () => AppAuthCubit(repository),
      act: (_) {
        authStateController.add(
          const User(id: 'u1', name: 'Stream User', email: 'stream@test.com'),
        );
        authStateController.add(null);
      },
      expect: () => [
        const AppAuthState.authenticated(
          User(id: 'u1', name: 'Stream User', email: 'stream@test.com'),
        ),
        const AppAuthState.unauthenticated(),
      ],
    );
  });

  group('LoginCubit', () {
    late MockAuthRepository repository;

    const testUser = User(name: 'Clark', email: 'clark@example.com');

    setUp(() {
      repository = MockAuthRepository();
    });

    blocTest<LoginCubit, LoginState>(
      'login success emits [loading, success]',
      build: () {
        when(
          () => repository.login(any()),
        ).thenAnswer((_) async => testUser);
        return LoginCubit(repository);
      },
      act: (cubit) => cubit.login(
        email: 'clark@example.com',
        password: 'Password123!',
      ),
      expect: () => [
        const LoginState.loading(),
        const LoginState.success(testUser),
      ],
      verify: (_) {
        verify(
          () => repository.login(
            const LoginDto(
              email: 'clark@example.com',
              password: 'Password123!',
            ),
          ),
        ).called(1);
      },
    );

    blocTest<LoginCubit, LoginState>(
      'login failure emits [loading, failure]',
      build: () {
        when(
          () => repository.login(any()),
        ).thenThrow(const ValidationException(message: 'Invalid credentials'));
        return LoginCubit(repository);
      },
      act: (cubit) => cubit.login(
        email: 'clark@example.com',
        password: 'WrongPassword',
      ),
      expect: () => [
        const LoginState.loading(),
        const LoginState.failure('Invalid credentials'),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'externalLogin with GitHub code emits [loading, success]',
      build: () {
        when(
          () => repository.externalLogin(
            provider: 'GitHub',
            code: 'valid_auth_code',
          ),
        ).thenAnswer((_) async => testUser);
        return LoginCubit(repository);
      },
      act: (cubit) => cubit.externalLogin(
        provider: 'GitHub',
        code: 'valid_auth_code',
      ),
      expect: () => [
        const LoginState.loading(),
        const LoginState.success(testUser),
      ],
      verify: (_) {
        verify(
          () => repository.externalLogin(
            provider: 'GitHub',
            code: 'valid_auth_code',
          ),
        ).called(1);
      },
    );

    blocTest<LoginCubit, LoginState>(
      'externalLogin failure emits [loading, failure]',
      build: () {
        when(
          () => repository.externalLogin(
            provider: 'GitHub',
            code: 'invalid_code',
          ),
        ).thenThrow(
          const ValidationException(message: 'External authentication failed.'),
        );
        return LoginCubit(repository);
      },
      act: (cubit) => cubit.externalLogin(
        provider: 'GitHub',
        code: 'invalid_code',
      ),
      expect: () => [
        const LoginState.loading(),
        const LoginState.failure('External authentication failed.'),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'reset emits initial state',
      build: () => LoginCubit(repository),
      seed: () => const LoginState.failure('Some error'),
      act: (cubit) => cubit.reset(),
      expect: () => [const LoginState.initial()],
    );
  });
}
