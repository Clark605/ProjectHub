import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:client/features/auth/cubit/app_auth_cubit.dart';
import 'package:client/features/auth/data/auth_repository.dart';
import 'package:client/features/profile/cubit/profile_edit_state.dart';

@injectable
class ProfileEditCubit extends Cubit<ProfileEditState> {
  final AuthRepository _authRepository;
  final AppAuthCubit _appAuthCubit;

  ProfileEditCubit(this._authRepository, this._appAuthCubit)
      : super(const ProfileEditInitial());

  Future<void> updateProfile({required String name, String? bio}) async {
    emit(const ProfileEditLoading());
    try {
      final updatedUser = await _authRepository.updateProfile(
        name: name,
        bio: bio,
      );
      _appAuthCubit.setAuthenticated(updatedUser);
      emit(ProfileEditSuccess(updatedUser));
    } catch (e) {
      emit(ProfileEditFailure(e.toString()));
    }
  }

  void reset() => emit(const ProfileEditInitial());
}
