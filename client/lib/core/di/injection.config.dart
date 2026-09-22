// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/auth/cubit/app_auth_cubit.dart' as _i784;
import '../../features/auth/cubit/forgot_password_cubit.dart' as _i1;
import '../../features/auth/cubit/login_cubit.dart' as _i796;
import '../../features/auth/cubit/register_cubit.dart' as _i341;
import '../../features/auth/cubit/reset_password_cubit.dart' as _i835;
import '../../features/auth/data/auth_repository.dart' as _i726;
import '../../features/auth/data/auth_repository_impl.dart' as _i781;
import '../../features/comments/data/comment_remote_data_source.dart' as _i844;
import '../../features/comments/data/comment_repository.dart' as _i542;
import '../../features/comments/data/comment_repository_impl.dart' as _i808;
import '../../features/dashboard/cubit/activity_stream_cubit.dart' as _i1022;
import '../../features/dashboard/cubit/dashboard_cubit.dart' as _i949;
import '../../features/dashboard/data/activity_repository.dart' as _i568;
import '../../features/kanban/cubit/kanban_cubit.dart' as _i627;
import '../../features/profile/cubit/profile_edit_cubit.dart' as _i322;
import '../../features/projects/cubit/project_detail_cubit.dart' as _i566;
import '../../features/projects/cubit/projects_list_cubit.dart' as _i771;
import '../../features/projects/data/project_repository.dart' as _i405;
import '../../features/projects/data/project_repository_impl.dart' as _i396;
import '../../features/tags/data/tag_remote_data_source.dart' as _i749;
import '../../features/tags/data/tag_repository.dart' as _i800;
import '../../features/tags/data/tag_repository_impl.dart' as _i311;
import '../../features/tasks/cubit/my_tasks_cubit.dart' as _i816;
import '../../features/tasks/data/task_remote_data_source.dart' as _i538;
import '../../features/tasks/data/task_repository.dart' as _i241;
import '../../features/tasks/data/task_repository_impl.dart' as _i382;
import '../../features/workspaces/cubit/workspace_context_cubit.dart' as _i95;
import '../../features/workspaces/cubit/workspace_settings_cubit.dart' as _i259;
import '../../features/workspaces/data/workspace_repository.dart' as _i688;
import '../../features/workspaces/data/workspace_repository_impl.dart' as _i591;
import '../cubit/app_settings_cubit.dart' as _i30;
import '../network/auth_interceptor.dart' as _i908;
import '../network/dio_client.dart' as _i667;
import '../network/signalr_service.dart' as _i586;
import '../services/github_auth_service.dart' as _i103;
import '../services/google_auth_service.dart' as _i947;
import '../storage/prefs_service.dart' as _i415;
import '../storage/secure_storage_service.dart' as _i666;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final prefsModule = _$PrefsModule();
    final dioModule = _$DioModule();
    gh.lazySingleton<_i103.GithubAuthService>(() => _i103.GithubAuthService());
    gh.lazySingleton<_i947.GoogleAuthService>(() => _i947.GoogleAuthService());
    await gh.lazySingletonAsync<_i460.SharedPreferences>(
      () => prefsModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i666.SecureStorageService>(
      () => _i666.SecureStorageService(),
    );
    gh.lazySingleton<_i415.PrefsService>(
      () => _i415.PrefsService(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i908.AuthInterceptor>(
      () => _i908.AuthInterceptor(gh<_i666.SecureStorageService>()),
    );
    gh.lazySingleton<_i586.SignalRService>(
      () => _i586.SignalRService(gh<_i666.SecureStorageService>()),
    );
    gh.lazySingleton<_i361.Dio>(
      () => dioModule.dio(gh<_i908.AuthInterceptor>()),
    );
    gh.lazySingleton<_i749.TagRemoteDataSource>(
      () => _i749.TagRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i405.ProjectRepository>(
      () => _i396.ProjectRepositoryImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i688.WorkspaceRepository>(
      () => _i591.WorkspaceRepositoryImpl(gh<_i361.Dio>()),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i538.TaskRemoteDataSource>(
      () => _i538.TaskRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i844.CommentRemoteDataSource>(
      () => _i844.CommentRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.factory<_i566.ProjectDetailCubit>(
      () => _i566.ProjectDetailCubit(gh<_i405.ProjectRepository>()),
    );
    gh.factory<_i771.ProjectsListCubit>(
      () => _i771.ProjectsListCubit(gh<_i405.ProjectRepository>()),
    );
    gh.lazySingleton<_i568.ActivityRepository>(
      () => _i568.ActivityRepositoryImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i800.TagRepository>(
      () => _i311.TagRepositoryImpl(gh<_i749.TagRemoteDataSource>()),
    );
    gh.lazySingleton<_i30.AppSettingsCubit>(
      () => _i30.AppSettingsCubit(gh<_i415.PrefsService>()),
    );
    gh.factory<_i259.WorkspaceSettingsCubit>(
      () => _i259.WorkspaceSettingsCubit(gh<_i688.WorkspaceRepository>()),
    );
    gh.factory<_i1022.ActivityStreamCubit>(
      () => _i1022.ActivityStreamCubit(gh<_i568.ActivityRepository>()),
    );
    gh.lazySingleton<_i726.AuthRepository>(
      () => _i781.AuthRepositoryImpl(
        gh<_i361.Dio>(),
        gh<_i666.SecureStorageService>(),
        gh<_i415.PrefsService>(),
        gh<_i947.GoogleAuthService>(),
        gh<_i103.GithubAuthService>(),
      ),
    );
    gh.lazySingleton<_i542.CommentRepository>(
      () => _i808.CommentRepositoryImpl(gh<_i844.CommentRemoteDataSource>()),
    );
    gh.lazySingleton<_i241.TaskRepository>(
      () => _i382.TaskRepositoryImpl(gh<_i538.TaskRemoteDataSource>()),
    );
    gh.lazySingleton<_i95.WorkspaceContextCubit>(
      () => _i95.WorkspaceContextCubit(
        gh<_i688.WorkspaceRepository>(),
        gh<_i415.PrefsService>(),
      ),
    );
    gh.lazySingleton<_i784.AppAuthCubit>(
      () => _i784.AppAuthCubit(gh<_i726.AuthRepository>()),
    );
    gh.factory<_i1.ForgotPasswordCubit>(
      () => _i1.ForgotPasswordCubit(gh<_i726.AuthRepository>()),
    );
    gh.factory<_i796.LoginCubit>(
      () => _i796.LoginCubit(gh<_i726.AuthRepository>()),
    );
    gh.factory<_i341.RegisterCubit>(
      () => _i341.RegisterCubit(gh<_i726.AuthRepository>()),
    );
    gh.factory<_i835.ResetPasswordCubit>(
      () => _i835.ResetPasswordCubit(gh<_i726.AuthRepository>()),
    );
    gh.factory<_i322.ProfileEditCubit>(
      () => _i322.ProfileEditCubit(gh<_i726.AuthRepository>()),
    );
    gh.factory<_i627.KanbanCubit>(
      () => _i627.KanbanCubit(
        gh<_i241.TaskRepository>(),
        gh<_i405.ProjectRepository>(),
        gh<_i586.SignalRService>(),
      ),
    );
    gh.factory<_i816.MyTasksCubit>(
      () => _i816.MyTasksCubit(gh<_i241.TaskRepository>()),
    );
    gh.factory<_i949.DashboardCubit>(
      () => _i949.DashboardCubit(
        gh<_i568.ActivityRepository>(),
        gh<_i405.ProjectRepository>(),
        gh<_i241.TaskRepository>(),
      ),
    );
    return this;
  }
}

class _$PrefsModule extends _i415.PrefsModule {}

class _$DioModule extends _i667.DioModule {}
