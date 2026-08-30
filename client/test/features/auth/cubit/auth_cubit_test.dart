import 'package:flutter_test/flutter_test.dart';
import 'package:client/core/errors/app_exception.dart';
import 'package:client/core/storage/secure_storage_service.dart';
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

  @override
  Future<User> login(LoginDto dto) async {
    if (shouldThrow) {
      throw ValidationException(message: errorMessage);
    }
    return currentUser ??
        const User(name: 'Test User', email: 'test@example.com');
  }

  @override
  Future<User> register(RegisterDto dto) async {
    if (shouldThrow) {
      throw ValidationException(message: errorMessage);
    }
    return currentUser ??
        const User(name: 'Test User', email: 'test@example.com');
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
  Future<void> logout() async {}

  @override
  Future<ForgotPasswordResponseDto> forgotPassword(
    ForgotPasswordDto dto,
  ) async {
    return const ForgotPasswordResponseDto(message: 'Reset sent');
  }

  @override
  Future<void> resetPassword(ResetPasswordDto dto) async {}
}

class FakeSecureStorageService extends SecureStorageService {
  bool tokensExist = true;

  @override
  Future<bool> hasTokens() async => tokensExist;

  @override
  Future<void> clearTokens() async {
    tokensExist = false;
  }
}

void main() {
  group('AppAuthCubit', () {
    late FakeAuthRepository repository;
    late FakeSecureStorageService storage;
    late AppAuthCubit cubit;

    setUp(() {
      repository = FakeAuthRepository();
      storage = FakeSecureStorageService();
      cubit = AppAuthCubit(repository, storage);
    });

    test('initial state is AppAuthState.initial()', () {
      expect(cubit.state, const AppAuthState.initial());
    });

    test('checkAuthStatus emits unauthenticated when no tokens', () async {
      storage.tokensExist = false;
      await cubit.checkAuthStatus();
      expect(cubit.state, const AppAuthState.unauthenticated());
    });

    test('checkAuthStatus emits authenticated when user found', () async {
      storage.tokensExist = true;
      repository.currentUser = const User(
        name: 'Clark',
        email: 'clark@example.com',
      );
      await cubit.checkAuthStatus();
      expect(
        cubit.state,
        const AppAuthState.authenticated(
          User(name: 'Clark', email: 'clark@example.com'),
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
    late FakeSecureStorageService storage;
    late AppAuthCubit appAuthCubit;
    late LoginCubit loginCubit;

    setUp(() {
      repository = FakeAuthRepository();
      storage = FakeSecureStorageService();
      appAuthCubit = AppAuthCubit(repository, storage);
      loginCubit = LoginCubit(repository, appAuthCubit);
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
  });
}
