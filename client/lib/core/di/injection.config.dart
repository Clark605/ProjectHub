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

import '../network/auth_interceptor.dart' as _i908;
import '../network/dio_client.dart' as _i667;
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
    gh.lazySingleton<_i361.Dio>(
      () => dioModule.dio(gh<_i908.AuthInterceptor>()),
    );
    return this;
  }
}

class _$PrefsModule extends _i415.PrefsModule {}

class _$DioModule extends _i667.DioModule {}
