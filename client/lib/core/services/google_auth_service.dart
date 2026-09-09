import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:client/core/utils/app_logger.dart';

@lazySingleton
class GoogleAuthService {
  final GoogleSignIn _googleSignIn;

  GoogleAuthService()
      : _googleSignIn = GoogleSignIn(
          scopes: const ['email', 'profile'],
        );

  GoogleAuthService.withClient({required GoogleSignIn googleSignIn})
      : _googleSignIn = googleSignIn;

  /// Initiates interactive Google sign-in flow.
  /// Returns the OpenID Connect idToken if successful, or null if cancelled or failed.
  Future<String?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        AppLogger.info('Google sign-in was cancelled by user', tag: 'GoogleAuth');
        return null;
      }
      final auth = await account.authentication;
      if (auth.idToken == null) {
        AppLogger.warning(
          'Google sign-in succeeded but returned null idToken',
          tag: 'GoogleAuth',
        );
      }
      return auth.idToken;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Google sign-in encountered an exception',
        tag: 'GoogleAuth',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Signs out of Google account.
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e, stackTrace) {
      AppLogger.error(
        'Google sign-out failed',
        tag: 'GoogleAuth',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
