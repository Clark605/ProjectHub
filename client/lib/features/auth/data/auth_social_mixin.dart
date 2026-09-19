import 'package:client/core/services/github_auth_service.dart';
import 'package:client/core/services/google_auth_service.dart';
import 'package:client/features/auth/data/models/user.dart';

mixin AuthSocialMixin {
  GoogleAuthService get googleAuthService;
  GithubAuthService get githubAuthService;

  Future<User> externalLogin({
    required String provider,
    String? idToken,
    String? accessToken,
    String? code,
    String? redirectUri,
  });

  Future<User> loginWithGoogle() async {
    final idToken = await googleAuthService.signIn();
    if (idToken == null) {
      throw Exception('Google sign-in was cancelled');
    }
    return externalLogin(
      provider: 'Google',
      idToken: idToken,
    );
  }

  Future<User> loginWithGithub() async {
    final code = await githubAuthService.signIn();
    if (code == null) {
      throw Exception('GitHub sign-in was cancelled');
    }
    return externalLogin(
      provider: 'GitHub',
      code: code,
    );
  }
}
