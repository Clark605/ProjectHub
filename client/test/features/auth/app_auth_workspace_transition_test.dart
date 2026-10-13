import 'dart:async';

import 'package:client/app.dart';
import 'package:client/core/di/injection.dart';
import 'package:client/core/routes/app_navigator.dart';
import 'package:client/core/storage/prefs_service.dart';
import 'package:client/features/auth/cubit/app_auth_cubit.dart';
import 'package:client/features/auth/data/auth_repository.dart';
import 'package:client/features/auth/data/models/user.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/mock_repositories.dart';

class _SpyWorkspaceContextCubit extends WorkspaceContextCubit {
  int loadWorkspacesCallCount = 0;
  int resetCallCount = 0;

  _SpyWorkspaceContextCubit(super.repository, super.prefs);

  @override
  Future<void> loadWorkspaces() async {
    loadWorkspacesCallCount++;
    await super.loadWorkspaces();
  }

  @override
  Future<void> reset() async {
    resetCallCount++;
    await super.reset();
  }
}

class _FakeAuthRepository implements AuthRepository {
  final _controller = StreamController<User?>.broadcast(sync: true);
  User? _currentUser;

  @override
  Stream<User?> get authStateChanges => _controller.stream;

  @override
  Future<User?> restoreSession() async => _currentUser;

  @override
  Future<User> getCurrentUser() async =>
      _currentUser ?? const User(id: '1', email: 'u1@test.com', name: 'User 1');

  @override
  void setAuthenticated(User user) {
    _currentUser = user;
    _controller.add(user);
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    _controller.add(null);
  }

  void emitUser(User? user) {
    _currentUser = user;
    _controller.add(user);
  }

  void dispose() {
    _controller.close();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeAuthRepository fakeAuthRepo;
  late PrefsService prefs;
  late _SpyWorkspaceContextCubit spyWsCubit;
  late AppAuthCubit authCubit;

  const testUser1 = User(id: '1', email: 'alice@test.com', name: 'Alice');
  const testUser2 = User(id: '2', email: 'bob@test.com', name: 'Bob');

  Future<void> initTestScope({User? initialUser}) async {
    AppNavigator.resetKeyForTesting();
    await getIt.reset();
    SharedPreferences.setMockInitialValues({});
    await configureDependencies();

    prefs = getIt<PrefsService>();
    fakeAuthRepo = _FakeAuthRepository();
    final wsRepo = createMockWorkspaceRepository();
    spyWsCubit = _SpyWorkspaceContextCubit(wsRepo, prefs);
    authCubit = AppAuthCubit(fakeAuthRepo);
    if (initialUser != null) {
      fakeAuthRepo.emitUser(initialUser);
    }

    getIt.unregister<AuthRepository>();
    getIt.registerSingleton<AuthRepository>(fakeAuthRepo);

    getIt.unregister<AppAuthCubit>();
    getIt.registerSingleton<AppAuthCubit>(authCubit);

    getIt.unregister<WorkspaceContextCubit>();
    getIt.registerSingleton<WorkspaceContextCubit>(spyWsCubit);
  }

  tearDown(() async {
    fakeAuthRepo.dispose();
    await getIt.reset();
  });

  testWidgets(
    'at startup when AppAuthCubit is already authenticated, loads workspaces once',
    (tester) async {
      await initTestScope(initialUser: testUser1);

      await tester.pumpWidget(const ProjectHubApp(initialRoute: '/onboarding'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(spyWsCubit.loadWorkspacesCallCount, equals(1));
      expect(spyWsCubit.resetCallCount, equals(0));
    },
  );

  testWidgets(
    'at startup when AppAuthCubit is unauthenticated, does not load workspaces',
    (tester) async {
      await initTestScope();
      await authCubit.checkAuthStatus();

      await tester.pumpWidget(const ProjectHubApp(initialRoute: '/onboarding'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(spyWsCubit.loadWorkspacesCallCount, equals(0));
      expect(spyWsCubit.resetCallCount, equals(0));
    },
  );

  testWidgets(
    'when transitioning from unauthenticated to authenticated, loads workspaces',
    (tester) async {
      await initTestScope();
      await authCubit.checkAuthStatus();

      await tester.pumpWidget(const ProjectHubApp(initialRoute: '/onboarding'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(spyWsCubit.loadWorkspacesCallCount, equals(0));

      // Simulate user logging in
      fakeAuthRepo.emitUser(testUser1);
      await tester.pump(const Duration(milliseconds: 100));

      expect(spyWsCubit.loadWorkspacesCallCount, equals(1));
      expect(spyWsCubit.resetCallCount, equals(0));
    },
  );

  testWidgets(
    'when transitioning from authenticated to unauthenticated, calls reset',
    (tester) async {
      await initTestScope(initialUser: testUser1);

      await tester.pumpWidget(const ProjectHubApp(initialRoute: '/onboarding'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(spyWsCubit.loadWorkspacesCallCount, equals(1));

      // Simulate user logging out
      fakeAuthRepo.emitUser(null);
      await tester.pump(const Duration(milliseconds: 100));

      expect(spyWsCubit.resetCallCount, equals(1));
    },
  );

  testWidgets(
    'when logging out and logging into another account, resets and then loads workspaces',
    (tester) async {
      await initTestScope(initialUser: testUser1);

      await tester.pumpWidget(const ProjectHubApp(initialRoute: '/onboarding'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(spyWsCubit.loadWorkspacesCallCount, equals(1));
      expect(spyWsCubit.resetCallCount, equals(0));

      // Logout
      fakeAuthRepo.emitUser(null);
      await tester.pump(const Duration(milliseconds: 100));

      expect(spyWsCubit.resetCallCount, equals(1));

      // Login to second account
      fakeAuthRepo.emitUser(testUser2);
      await tester.pump(const Duration(milliseconds: 100));

      expect(spyWsCubit.loadWorkspacesCallCount, equals(2));
      expect(spyWsCubit.resetCallCount, equals(1));
    },
  );
}
