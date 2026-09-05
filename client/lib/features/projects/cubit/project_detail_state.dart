import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:client/features/projects/data/models/project_dto.dart';

part 'project_detail_state.freezed.dart';

@freezed
abstract class ProjectDetailState with _$ProjectDetailState {
  const factory ProjectDetailState.initial() = _ProjectDetailInitial;
  const factory ProjectDetailState.loading() = _ProjectDetailLoading;
  const factory ProjectDetailState.loaded({
    required ProjectDto project,
    @Default(false) bool isSaving,
    @Default(false) bool isDeleting,
    String? errorMessage,
    String? actionSuccessMessage,
  }) = ProjectDetailLoaded;
  const factory ProjectDetailState.deleted() = _ProjectDetailDeleted;
  const factory ProjectDetailState.error(String message) = _ProjectDetailError;
}
