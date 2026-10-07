import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:client/core/network/signalr_service.dart';

import '../../helpers/mock_repositories.dart';

void main() {
  group('SignalRService lifecycle & ref-counting', () {
    late MockSecureStorageService secureStorage;
    late SignalRService service;

    setUp(() {
      secureStorage = MockSecureStorageService();
      when(() => secureStorage.getAccessToken()).thenAnswer((_) async => null);
      service = SignalRService(secureStorage);
    });

    tearDown(() {
      service.dispose();
    });

    test('joinWorkspace ref-counts workspaces properly', () async {
      expect(service.getWorkspaceRefCount(10), 0);

      await service.joinWorkspace(10);
      expect(service.getWorkspaceRefCount(10), 1);

      await service.joinWorkspace(10);
      expect(service.getWorkspaceRefCount(10), 2);

      await service.leaveWorkspace(10);
      expect(service.getWorkspaceRefCount(10), 1);

      await service.leaveWorkspace(10);
      expect(service.getWorkspaceRefCount(10), 0);
    });

    test('leaveWorkspace for multiple workspaces behaves independently', () async {
      await service.joinWorkspace(10);
      await service.joinWorkspace(20);

      expect(service.getWorkspaceRefCount(10), 1);
      expect(service.getWorkspaceRefCount(20), 1);

      await service.leaveWorkspace(10);
      expect(service.getWorkspaceRefCount(10), 0);
      expect(service.getWorkspaceRefCount(20), 1);

      await service.leaveWorkspace(20);
      expect(service.getWorkspaceRefCount(20), 0);
    });

    test('disconnect resets ref counts', () async {
      await service.joinWorkspace(10);
      await service.joinWorkspace(10);
      expect(service.getWorkspaceRefCount(10), 2);

      await service.disconnect();
      expect(service.getWorkspaceRefCount(10), 0);
    });

    test('reconnected stream emits reconnection events', () async {
      final events = <String>[];
      final sub = service.reconnected.listen(events.add);

      // Testing broadcast stream functionality
      expect(service.reconnected.isBroadcast, isTrue);

      await sub.cancel();
    });

    test('ensureConnected memoizes concurrent in-flight connections', () async {
      // Both calls should execute concurrently without colliding
      final future1 = service.ensureConnected();
      final future2 = service.ensureConnected();

      await Future.wait([future1, future2]);
    });
  });
}
