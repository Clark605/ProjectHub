import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:client/features/auth/data/models/user.dart';

part 'app_auth_state.freezed.dart';

@freezed
sealed class AppAuthState with _$AppAuthState {
  const factory AppAuthState.initial() = _AppAuthInitial;
  const factory AppAuthState.authenticated(User user) = _AppAuthAuthenticated;
  const factory AppAuthState.unauthenticated() = _AppAuthUnauthenticated;
}
