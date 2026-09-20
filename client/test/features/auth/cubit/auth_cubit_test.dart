import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:client/core/errors/app_exception.dart';
import 'package:client/features/auth/cubit/app_auth_cubit.dart';
import 'package:client/features/auth/cubit/app_auth_state.dart';
import 'package:client/features/auth/cubit/login_cubit.dart';
import 'package:client/features/auth/cubit/login_state.dart';
import 'package:client/features/auth/data/auth_repository.dart';
import 'package:client/features/auth/data/models/auth_dtos.dart';
import 'package:client/features/auth/data/models/user.dart';

class FakeAuthRepository implements AuthRepository {
  User? currentUser;
  bool shouldThrow = false;
  String errorMessage = 'Invalid credentials';
  final _authStateController = StreamController<User?>.broadcast();

  @override
  Stream<User?> get authStateChanges => _authStateController.stream;

  @override
  Future<User?> restoreSession() async {
    if (shouldThrow) {
      _authStateController.add(null);
      return null;
    }
    _authStateController.add(currentUser);
    return currentUser;
  }

  @override
  Future<User> login(LoginDto dto) async {
    if (shouldThrow) {
      throw ValidationException(message: errorMessage);
    }
    final user =
        currentUser ?? const User(name: 'Test User', email: 'test@example.com');
    setAuthenticated(user);
    return user;
  }

  @override
  Future<User> register(RegisterDto dto) async {
    if (shouldThrow) {
      throw ValidationException(message: errorMessage);
    }
    final user =
        currentUser ?? const User(name: 'Test User', email: 'test@example.com');
    setAuthenticated(user);
    return user;
  }

  @override
  Future<User> getCurrentUser() async {
    if (shouldThrow) {
      throw const UnauthorizedException(message: 'Unauthorized');
    }
    return currentUser ??
        const User(name: 'Test User', email: 'test@example.com');
  }

  @override
  Future<void> logout() async {
    currentUser = null;
    _authStateController.add(null);
  }

  @override
  Future<ForgotPasswordResponseDto> forgotPassword(
    ForgotPasswordDto dto,
  ) async {
    return const ForgotPasswordResponseDto(message: 'Reset sent');
  }

  @override
  Future<void> resetPassword(ResetPasswordDto dto) async {}

  @override
  Future<User> updateProfile({required String name, String? bio}) async {
    final user = currentUser = User(
      name: name,
      email: currentUser?.email ?? 'test@example.com',
      bio: bio ?? '',
    );
    setAuthenticated(user);
    return user;
  }

  @override
  Future<User> externalLogin({
    required String provider,
    String? idToken,
    String? accessToken,
    String? code,
    String? redirectUri,
  }) async {
    if (shouldThrow) {
      throw ValidationException(message: errorMessage);
    }
    final user =
        currentUser ?? const User(name: 'Test User', email: 'test@example.com');
    setAuthenticated(user);
    return user;
  }

  @override
  Future<User> loginWithGoogle() => externalLogin(provider: 'Google');

  @override
  Future<User> loginWithGithub() => externalLogin(provider: 'GitHub');

  @override
  void setAuthenticated(User user) {
    currentUser = user;
    _authStateController.add(user);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppAuthCubit', () {
    late FakeAuthRepository repository;
    late AppAuthCubit cubit;

    setUp(() {
      repository = FakeAuthRepository();
      cubit = AppAuthCubit(repository);
    });

    tearDown(() => cubit.close());

    test('initial state is AppAuthState.initial()', () {
      expect(cubit.state, const AppAuthState.initial());
    });

    test('checkAuthStatus emits unauthenticated when no session', () async {
      repository.currentUser = null;
      await cubit.checkAuthStatus();
      expect(cubit.state, const AppAuthState.unauthenticated());
    });

    test('checkAuthStatus emits authenticated when session restored', () async {
      repository.currentUser = const User(
        id: 'user_1',
        name: 'Cached Clark',
        email: 'cached@example.com',
      );

      await cubit.checkAuthStatus();
      await Future.delayed(Duration.zero);

      expect(
        cubit.state,
        const AppAuthState.authenticated(
          User(id: 'user_1', name: 'Cached Clark', email: 'cached@example.com'),
        ),
      );
    });

    test('syncUser updates and emits authenticated', () async {
      repository.currentUser = const User(
        name: 'Updated Clark',
        email: 'updated@example.com',
      );

      await cubit.syncUser();

      expect(
        cubit.state,
        const AppAuthState.authenticated(
          User(name: 'Updated Clark', email: 'updated@example.com'),
        ),
      );
    });

    test('logout emits unauthenticated', () async {
      await cubit.logout();
      expect(cubit.state, const AppAuthState.unauthenticated());
    });
  });

  group('LoginCubit', () {
    late FakeAuthRepository repository;
    late AppAuthCubit appAuthCubit;
    late LoginCubit loginCubit;

    setUp(() {
      repository = FakeAuthRepository();
      appAuthCubit = AppAuthCubit(repository);
      loginCubit = LoginCubit(repository);
    });

    test(
      'login success emits loading then success and updates AppAuthCubit',
      () async {
        const user = User(name: 'Clark', email: 'clark@example.com');
        repository.currentUser = user;

        final states = <LoginState>[];
        loginCubit.stream.listen(states.add);

        await loginCubit.login(
          email: 'clark@example.com',
          password: 'Password123!',
        );
        await Future.delayed(Duration.zero);

        expect(states, [
          const LoginState.loading(),
          const LoginState.success(user),
        ]);
        expect(appAuthCubit.state, const AppAuthState.authenticated(user));
      },
    );

    test('login failure emits loading then failure', () async {
      repository.shouldThrow = true;
      repository.errorMessage = 'Invalid credentials';

      final states = <LoginState>[];
      loginCubit.stream.listen(states.add);

      await loginCubit.login(
        email: 'clark@example.com',
        password: 'WrongPassword',
      );
      await Future.delayed(Duration.zero);

      expect(states, [
        const LoginState.loading(),
        const LoginState.failure('Invalid credentials'),
      ]);
    });

    test('externalLogin with GitHub code emits loading then success', () async {
      const user = User(name: 'GitHub User', email: 'github@example.com');
      repository.currentUser = user;

      final states = <LoginState>[];
      loginCubit.stream.listen(states.add);

      await loginCubit.externalLogin(
        provider: 'GitHub',
        code: 'valid_auth_code',
      );
      await Future.delayed(Duration.zero);

      expect(states, [
        const LoginState.loading(),
        const LoginState.success(user),
      ]);
      expect(appAuthCubit.state, const AppAuthState.authenticated(user));
    });

    test('externalLogin failure emits loading then failure', () async {
      repository.shouldThrow = true;
      repository.errorMessage = 'External authentication failed.';

      final states = <LoginState>[];
      loginCubit.stream.listen(states.add);

      await loginCubit.externalLogin(provider: 'GitHub', code: 'invalid_code');
      await Future.delayed(Duration.zero);

      expect(states, [
        const LoginState.loading(),
        const LoginState.failure('External authentication failed.'),
      ]);
    });
  });
}
