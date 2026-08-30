import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:client/core/errors/app_exception.dart';
import 'package:client/features/auth/cubit/app_auth_cubit.dart';
import 'package:client/features/auth/cubit/register_state.dart';
import 'package:client/features/auth/data/auth_repository.dart';
import 'package:client/features/auth/data/models/auth_dtos.dart';

@injectable
class RegisterCubit extends Cubit<RegisterState> {
  final AuthRepository _authRepository;
  final AppAuthCubit _appAuthCubit;

  RegisterCubit(this._authRepository, this._appAuthCubit)
    : super(const RegisterState.initial());

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(const RegisterState.loading());
    try {
      final user = await _authRepository.register(
        RegisterDto(name: name, email: email, password: password),
      );
      _appAuthCubit.setAuthenticated(user);
      emit(RegisterState.success(user));
    } on AppException catch (e) {
      emit(RegisterState.failure(e.message));
    } catch (_) {
      emit(const RegisterState.failure('An unexpected error occurred'));
    }
  }

  void reset() {
    emit(const RegisterState.initial());
  }
}
