import 'package:client/core/errors/app_failure.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'project_detail_state.freezed.dart';

@freezed
abstract class ProjectDetailState with _$ProjectDetailState {
  const factory ProjectDetailState.initial() = _ProjectDetailInitial;
  const factory ProjectDetailState.loading() = _ProjectDetailLoading;
  const factory ProjectDetailState.loaded({
    required ProjectDto project,
    @Default(false) bool isSaving,
    @Default(false) bool isDeleting,
    AppFailure? failure,
    String? actionSuccessMessage,
  }) = ProjectDetailLoaded;
  const factory ProjectDetailState.deleted() = _ProjectDetailDeleted;
  const factory ProjectDetailState.error(AppFailure failure) =
      _ProjectDetailError;
}
