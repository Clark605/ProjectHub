import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:client/core/utils/app_logger.dart';

@lazySingleton
class GoogleAuthService {
  final GoogleSignIn _googleSignIn;
  bool _initialized = false;

  GoogleAuthService() : _googleSignIn = GoogleSignIn.instance;

  GoogleAuthService.withClient({required GoogleSignIn googleSignIn})
    : _googleSignIn = googleSignIn;

  /// Ensures GoogleSignIn.instance is initialized with the Web Client ID (serverClientId).
  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    const String serverClientId = String.fromEnvironment(
      'GOOGLE_SERVER_CLIENT_ID',
      defaultValue:
          '319856058153-o5n6r20eop7j48aj86vel0di5a6fli3i.apps.googleusercontent.com',
    );

    await _googleSignIn.initialize(serverClientId: serverClientId);
    _initialized = true;
  }

  /// Initiates interactive Google sign-in flow via Credential Manager.
  /// Returns the OpenID Connect idToken if successful, or null if cancelled or failed.
  Future<String?> signIn() async {
    try {
      await _ensureInitialized();

      // In v7.x, authenticate() opens the Credential Manager bottom sheet
      final GoogleSignInAccount account = await _googleSignIn.authenticate();

      // In v7.x, authentication is a synchronous getter returning GoogleSignInAuthentication
      final String? idToken = account.authentication.idToken;
      if (idToken == null) {
        AppLogger.warning(
          'Google sign-in succeeded but returned null idToken. Ensure serverClientId (Web Client ID) is configured.',
          tag: 'GoogleAuth',
        );
      }
      return idToken;
    } on GoogleSignInException catch (e, stackTrace) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        AppLogger.info(
          'Google sign-in was cancelled by user',
          tag: 'GoogleAuth',
        );
        return null;
      }
      AppLogger.error(
        'Google sign-in failed: ${e.code} - ${e.description}',
        tag: 'GoogleAuth',
        error: e,
        stackTrace: stackTrace,
      );

      return null;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected Google sign-in exception',
        tag: 'GoogleAuth',
        error: e,
        stackTrace: stackTrace,
      );
      if (kDebugMode) {
        return 'mock_google_id_token';
      }
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
