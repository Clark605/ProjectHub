import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/core/constants/api_constants.dart';
import 'package:client/features/projects/data/models/create_project_request.dart';
import 'package:client/features/projects/data/models/update_project_request.dart';
import 'package:client/features/projects/data/project_repository_impl.dart';

class _FakeHttpClientAdapter implements HttpClientAdapter {
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
  late _FakeHttpClientAdapter adapter;
  late ProjectRepositoryImpl repository;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://test'));
    adapter = _FakeHttpClientAdapter();
    dio.httpClientAdapter = adapter;
    repository = ProjectRepositoryImpl(dio);
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

  group('ProjectRepositoryImpl', () {
    test('getProjects caches data and honors forceRefresh', () async {
      int requestCount = 0;
      adapter.handler = (options) {
        requestCount++;
        expect(options.path, ApiConstants.workspaceProjects(10));
        return jsonResponse([
          {
            'id': 101,
            'workspaceId': 10,
            'name': 'Project Alpha',
            'description': 'Desc Alpha',
            'status': 'Active',
            'createdAt': '2026-01-01T00:00:00Z',
            'createdBy': 'u_creator',
            'createdByName': 'Creator Name',
          },
        ]);
      };

      // 1. First fetch - hits network
      final firstFetch = await repository.getProjects(10);
      expect(firstFetch.length, 1);
      expect(firstFetch.first.name, 'Project Alpha');
      expect(requestCount, 1);

      // 2. Second fetch without forceRefresh - cache hit
      final cachedFetch = await repository.getProjects(10);
      expect(cachedFetch.length, 1);
      expect(requestCount, 1);

      // 3. Third fetch with forceRefresh - hits network
      final refreshedFetch = await repository.getProjects(
        10,
        forceRefresh: true,
      );
      expect(refreshedFetch.length, 1);
      expect(requestCount, 2);
    });

    test('getProject detail caches and returns project', () async {
      int requestCount = 0;
      adapter.handler = (options) {
        requestCount++;
        expect(options.path, ApiConstants.projectById(101));
        return jsonResponse({
          'id': 101,
          'workspaceId': 10,
          'name': 'Project Alpha',
          'description': 'Desc Alpha',
          'status': 'Active',
          'createdAt': '2026-01-01T00:00:00Z',
          'createdBy': 'u_creator',
          'createdByName': 'Creator Name',
        });
      };

      final project1 = await repository.getProject(101);
      expect(project1.id, 101);
      expect(requestCount, 1);

      // Cache hit
      final project2 = await repository.getProject(101);
      expect(project2.id, 101);
      expect(requestCount, 1);

      // Force refresh
      final project3 = await repository.getProject(101, forceRefresh: true);
      expect(project3.id, 101);
      expect(requestCount, 2);
    });

    test('createProject sends POST and invalidates workspace cache', () async {
      adapter.handler = (options) {
        expect(options.method, 'POST');
        expect(options.path, ApiConstants.workspaceProjects(10));
        return jsonResponse({
          'id': 102,
          'workspaceId': 10,
          'name': 'New Project',
          'description': 'New Desc',
          'status': 'Planning',
          'createdAt': '2026-01-01T00:00:00Z',
          'createdBy': 'u_creator',
          'createdByName': 'Creator Name',
        });
      };

      final created = await repository.createProject(
        10,
        const CreateProjectRequest(
          name: 'New Project',
          description: 'New Desc',
        ),
      );

      expect(created.id, 102);
      expect(created.name, 'New Project');
      expect(repository.hasCachedProjects(10), isFalse);
    });

    test('updateProject sends PUT and updates detail cache', () async {
      adapter.handler = (options) {
        expect(options.method, 'PUT');
        expect(options.path, ApiConstants.projectById(102));
        return jsonResponse({
          'id': 102,
          'workspaceId': 10,
          'name': 'Updated Project',
          'description': 'Updated Desc',
          'status': 'Active',
          'createdAt': '2026-01-01T00:00:00Z',
          'createdBy': 'u_creator',
          'createdByName': 'Creator Name',
        });
      };

      final updated = await repository.updateProject(
        102,
        const UpdateProjectRequest(
          name: 'Updated Project',
          description: 'Updated Desc',
          status: 'Active',
        ),
      );

      expect(updated.name, 'Updated Project');
      expect(updated.status, 'Active');
      expect(repository.hasCachedProject(102), isTrue);
    });

    test('deleteProject sends DELETE and clears caches', () async {
      adapter.handler = (options) {
        expect(options.method, 'DELETE');
        expect(options.path, ApiConstants.projectById(102));
        return jsonResponse(null, statusCode: 204);
      };

      await repository.deleteProject(102);
      expect(repository.hasCachedProject(102), isFalse);
    });

    test('clearCache clears all project caches', () {
      repository.clearCache();
      expect(repository.hasCachedProjects(10), isFalse);
    });
  });
}
