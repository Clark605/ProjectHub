import 'package:dio/dio.dart';

import 'package:client/core/constants/api_constants.dart';
import 'package:client/core/errors/dio_error_handler.dart';
import 'package:client/core/utils/app_logger.dart';
import 'package:client/features/workspaces/data/models/add_member_request.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';

/// Mixin providing workspace members management and caching.
mixin WorkspaceMembersMixin {
  Dio get dio;

  final Map<int, List<MemberDto>> membersCache = {};

  Future<List<MemberDto>> getMembers(
    int workspaceId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && membersCache.containsKey(workspaceId)) {
      return membersCache[workspaceId]!;
    }
    AppLogger.debug(
      'Fetching members for workspace $workspaceId',
      tag: 'WorkspaceRepository',
    );
    try {
      final response = await dio.get(
        ApiConstants.workspaceMembers(workspaceId),
      );
      final list = response.data as List<dynamic>;
      final members = list
          .map((item) => MemberDto.fromJson(item as Map<String, dynamic>))
          .toList();
      membersCache[workspaceId] = members;
      return members;
    } on DioException catch (e) {
      AppLogger.error(
        'Failed to fetch members for $workspaceId: ${e.message}',
        tag: 'WorkspaceRepository',
      );
      throw DioErrorHandler.handle(e);
    }
  }

  Future<MemberDto> addMember(int workspaceId, AddMemberRequest request) async {
    AppLogger.info(
      'Adding member ${request.email} to workspace $workspaceId',
      tag: 'WorkspaceRepository',
    );
    try {
      final response = await dio.post(
        ApiConstants.workspaceMembers(workspaceId),
        data: request.toJson(),
      );
      final member = MemberDto.fromJson(response.data as Map<String, dynamic>);
      if (membersCache.containsKey(workspaceId)) {
        membersCache[workspaceId] = [...membersCache[workspaceId]!, member];
      }
      return member;
    } on DioException catch (e) {
      AppLogger.error(
        'Failed to add member: ${e.message}',
        tag: 'WorkspaceRepository',
      );
      throw DioErrorHandler.handle(e);
    }
  }

  Future<void> removeMember(int workspaceId, String userId) async {
    AppLogger.info(
      'Removing member $userId from workspace $workspaceId',
      tag: 'WorkspaceRepository',
    );
    try {
      await dio.delete(
        ApiConstants.removeWorkspaceMember(workspaceId, userId),
      );
      if (membersCache.containsKey(workspaceId)) {
        membersCache[workspaceId] = membersCache[workspaceId]!
            .where((m) => m.userId != userId)
            .toList();
      }
    } on DioException catch (e) {
      AppLogger.error(
        'Failed to remove member: ${e.message}',
        tag: 'WorkspaceRepository',
      );
      throw DioErrorHandler.handle(e);
    }
  }
}
