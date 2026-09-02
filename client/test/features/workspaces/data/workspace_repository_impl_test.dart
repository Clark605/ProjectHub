import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/core/constants/api_constants.dart';
import 'package:client/core/errors/app_exception.dart';
import 'package:client/features/workspaces/data/models/create_workspace_request.dart';
import 'package:client/features/workspaces/data/workspace_repository_impl.dart';

class FakeHttpClientAdapter implements HttpClientAdapter {
  late ResponseBody Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late Dio dio;
  late FakeHttpClientAdapter adapter;
  late WorkspaceRepositoryImpl repository;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://test'));
    adapter = FakeHttpClientAdapter();
    dio.httpClientAdapter = adapter;
    repository = WorkspaceRepositoryImpl(dio);
  });

  ResponseBody jsonResponse(dynamic data, {int statusCode = 200}) {
    final bytes = utf8.encode(jsonEncode(data));
    return ResponseBody.fromBytes(
      bytes,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  group('WorkspaceRepositoryImpl', () {
    test('getWorkspaces parses list with nested membership successfully', () async {
      adapter.handler = (options) {
        expect(options.path, ApiConstants.workspaces);
        return jsonResponse([
          {
            'id': 1,
            'name': 'Core Platform',
            'description': 'Dev team',
            'membership': {
              'role': 'Owner',
              'joinedAt': '2026-01-01T00:00:00Z',
            },
          },
          {
            'id': 2,
            'name': 'Mobile Team',
            'description': '',
            'membership': null,
          },
        ]);
      };

      final result = await repository.getWorkspaces();

      expect(result.length, 2);
      expect(result.first.id, 1);
      expect(result.first.name, 'Core Platform');
      expect(result.first.membership?.role, 'Owner');
      expect(result[1].id, 2);
      expect(result[1].membership, isNull);
    });

    test('getWorkspace parses single item successfully', () async {
      adapter.handler = (options) {
        expect(options.path, ApiConstants.workspaceById(5));
        return jsonResponse({
          'id': 5,
          'name': 'Design Systems',
          'description': 'Tokens and UI',
          'membership': {
            'role': 'Member',
            'joinedAt': '2026-02-15T00:00:00Z',
          },
        });
      };

      final result = await repository.getWorkspace(5);

      expect(result.id, 5);
      expect(result.name, 'Design Systems');
      expect(result.membership?.role, 'Member');
    });

    test('createWorkspace sends request and parses response', () async {
      adapter.handler = (options) {
        expect(options.path, ApiConstants.workspaces);
        expect(options.method, 'POST');
        return jsonResponse(
          {
            'id': 42,
            'name': 'Brand New Team',
            'description': 'Description',
            'membership': {
              'role': 'Owner',
              'joinedAt': '2026-03-01T00:00:00Z',
            },
          },
          statusCode: 201,
        );
      };

      final result = await repository.createWorkspace(
        const CreateWorkspaceRequest(
          name: 'Brand New Team',
          description: 'Description',
        ),
      );

      expect(result.id, 42);
      expect(result.name, 'Brand New Team');
      expect(result.membership?.role, 'Owner');
    });

    test('throws NotFoundException on 404 response', () async {
      adapter.handler = (options) {
        return jsonResponse({'message': 'Workspace not found'}, statusCode: 404);
      };

      expect(
        () => repository.getWorkspace(999),
        throwsA(isA<NotFoundException>()),
      );
    });
  });
}
