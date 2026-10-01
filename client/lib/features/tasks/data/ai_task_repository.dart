import 'package:injectable/injectable.dart';

import 'package:client/features/tasks/data/ai_task_remote_data_source.dart';
import 'package:client/features/tasks/data/models/parsed_task_draft_dto.dart';

abstract class AiTaskRepository {
  Future<ParsedTaskDraftDto> parseTaskFromText({
    required String text,
    required int projectId,
    required int workspaceId,
  });
}

@LazySingleton(as: AiTaskRepository)
class AiTaskRepositoryImpl implements AiTaskRepository {
  final AiTaskRemoteDataSource _remoteDataSource;

  AiTaskRepositoryImpl(this._remoteDataSource);

  @override
  Future<ParsedTaskDraftDto> parseTaskFromText({
    required String text,
    required int projectId,
    required int workspaceId,
  }) {
    return _remoteDataSource.parseTaskFromText(
      text: text,
      projectId: projectId,
      workspaceId: workspaceId,
    );
  }
}
