import 'package:client/features/auth/data/models/auth_dtos.dart';
import 'package:client/features/auth/data/models/user.dart';

abstract class AuthRepository {
  Future<User> login(LoginDto dto);
  Future<User> register(RegisterDto dto);
  Future<User> getCurrentUser();
  Future<void> logout();
  Future<ForgotPasswordResponseDto> forgotPassword(ForgotPasswordDto dto);
  Future<void> resetPassword(ResetPasswordDto dto);
  Future<User> updateProfile({required String name, String? bio});
}
