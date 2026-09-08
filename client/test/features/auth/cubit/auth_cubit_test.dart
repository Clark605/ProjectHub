import 'dart:convert';
import 'package:client/core/storage/prefs_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  @override
  Future<User> updateProfile({required String name, String? bio}) async {
    return currentUser = User(
      name: name,
      email: currentUser?.email ?? 'test@example.com',
      bio: bio ?? '',
    );
  }

  @override
  Future<User> externalLogin({
    required String provider,
    String? idToken,
    String? accessToken,
  }) async {
    if (shouldThrow) {
      throw ValidationException(message: errorMessage);
    }
    return currentUser ??
        const User(name: 'Test User', email: 'test@example.com');
  }
}

class FakeSecureStorageService extends SecureStorageService {
  bool tokensExist = true;
  String? accessToken;

  @override
  Future<bool> hasTokens() async => tokensExist;

  @override
  Future<String?> getAccessToken() async => accessToken;

  @override
  Future<void> clearTokens() async {
    tokensExist = false;
    accessToken = null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppAuthCubit', () {
    late FakeAuthRepository repository;
    late FakeSecureStorageService storage;
    late PrefsService prefs;
    late AppAuthCubit cubit;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final sp = await SharedPreferences.getInstance();
      repository = FakeAuthRepository();
      storage = FakeSecureStorageService();
      prefs = PrefsService(sp);
      cubit = AppAuthCubit(repository, storage, prefs);
    });

    test('initial state is AppAuthState.initial()', () {
      expect(cubit.state, const AppAuthState.initial());
    });

    test('checkAuthStatus emits unauthenticated when no tokens', () async {
      storage.tokensExist = false;
      await cubit.checkAuthStatus();
      expect(cubit.state, const AppAuthState.unauthenticated());
    });

    test('checkAuthStatus emits authenticated immediately from cache', () async {
      storage.tokensExist = true;
      await prefs.setCachedUserRaw(
        jsonEncode(
          const User(
            id: 'user_1',
            name: 'Cached Clark',
            email: 'cached@example.com',
          ).toJson(),
        ),
      );
      // Repository throws if called, ensuring it is NOT called when cache exists
      repository.shouldThrow = true;

      await cubit.checkAuthStatus();
      expect(
        cubit.state,
        const AppAuthState.authenticated(
          User(id: 'user_1', name: 'Cached Clark', email: 'cached@example.com'),
        ),
      );
    });

    test(
      'checkAuthStatus migrates ID from JWT access token when cached user has empty ID',
      () async {
        storage.tokensExist = true;
        // Header: {"alg":"HS256","typ":"JWT"}, Payload: {"sub":"jwt_user_42"}
        storage.accessToken =
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJqd3RfdXNlcl80MiJ9.signature';
        await prefs.setCachedUserRaw(
          jsonEncode(
            const User(
              id: '',
              name: 'Legacy Clark',
              email: 'legacy@example.com',
            ).toJson(),
          ),
        );
        repository.shouldThrow = true;

        await cubit.checkAuthStatus();

        expect(
          cubit.state,
          const AppAuthState.authenticated(
            User(
              id: 'jwt_user_42',
              name: 'Legacy Clark',
              email: 'legacy@example.com',
            ),
          ),
        );
        expect(
          User.fromJson(jsonDecode(prefs.getCachedUserRaw()!)).id,
          'jwt_user_42',
        );
      },
    );

    test(
      'checkAuthStatus migrates and caches user when tokens exist but cache is empty',
      () async {
        storage.tokensExist = true;
        await prefs.clearCachedUser();
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
        expect(
          User.fromJson(jsonDecode(prefs.getCachedUserRaw()!)),
          repository.currentUser,
        );
      },
    );

    test('syncUser updates cache and emits authenticated', () async {
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
      expect(
        User.fromJson(jsonDecode(prefs.getCachedUserRaw()!)),
        repository.currentUser,
      );
    });

    test('logout emits unauthenticated and clears cache', () async {
      await prefs.setCachedUserRaw(
        jsonEncode(
          const User(name: 'Clark', email: 'clark@example.com').toJson(),
        ),
      );
      await cubit.logout();
      expect(cubit.state, const AppAuthState.unauthenticated());
      expect(prefs.getCachedUserRaw(), isNull);
    });
  });

  group('LoginCubit', () {
    late FakeAuthRepository repository;
    late FakeSecureStorageService storage;
    late PrefsService prefs;
    late AppAuthCubit appAuthCubit;
    late LoginCubit loginCubit;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final sp = await SharedPreferences.getInstance();
      repository = FakeAuthRepository();
      storage = FakeSecureStorageService();
      prefs = PrefsService(sp);
      appAuthCubit = AppAuthCubit(repository, storage, prefs);
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
        expect(User.fromJson(jsonDecode(prefs.getCachedUserRaw()!)), user);
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
