import 'package:injectable/injectable.dart';

import 'package:client/core/cubit/safe_action_cubit.dart';
import 'package:client/features/auth/data/auth_repository.dart';
import 'package:client/features/profile/cubit/profile_edit_state.dart';

@injectable
class ProfileEditCubit extends SafeActionCubit<ProfileEditState> {
  final AuthRepository _authRepository;

  ProfileEditCubit(this._authRepository) : super(const ProfileEditInitial());

  Future<void> updateProfile({required String name, String? bio}) async {
    emit(const ProfileEditLoading());
    await safeExecute(
      () async {
        final updatedUser = await _authRepository.updateProfile(
          name: name,
          bio: bio,
        );
        emit(ProfileEditSuccess(updatedUser));
      },
      onError: (err) => emit(ProfileEditFailure(err)),
      logTag: 'ProfileEditCubit',
    );
  }

  void reset() => emit(const ProfileEditInitial());
}
