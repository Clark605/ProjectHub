import 'package:client/features/auth/data/models/user.dart';

sealed class ProfileEditState {
  const ProfileEditState();
}

class ProfileEditInitial extends ProfileEditState {
  const ProfileEditInitial();
}

class ProfileEditLoading extends ProfileEditState {
  const ProfileEditLoading();
}

class ProfileEditSuccess extends ProfileEditState {
  final User user;
  const ProfileEditSuccess(this.user);
}

class ProfileEditFailure extends ProfileEditState {
  final String message;
  const ProfileEditFailure(this.message);
}
