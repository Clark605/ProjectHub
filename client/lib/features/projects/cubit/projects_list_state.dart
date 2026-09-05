import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:client/features/projects/data/models/project_dto.dart';

part 'projects_list_state.freezed.dart';

@freezed
abstract class ProjectsListState with _$ProjectsListState {
  const factory ProjectsListState.initial() = _ProjectsListInitial;
  const factory ProjectsListState.loading() = _ProjectsListLoading;
  const factory ProjectsListState.loaded({
    required List<ProjectDto> projects,
    required List<ProjectDto> allProjects,
    @Default('All') String selectedFilter,
  }) = ProjectsListLoaded;
  const factory ProjectsListState.empty({
    @Default('All') String selectedFilter,
  }) = _ProjectsListEmpty;
  const factory ProjectsListState.error(String message) = _ProjectsListError;
}
