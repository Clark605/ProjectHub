import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:injectable/injectable.dart';
import 'package:client/core/utils/app_logger.dart';

@lazySingleton
class GithubAuthService {
  static const String callbackUrlScheme = 'projecthub';
  static const String redirectUri = 'projecthub://oauth/github';
  static const String _defaultScope = 'read:user user:email';

  final String _clientId;

  GithubAuthService()
    : _clientId = const String.fromEnvironment(
        'GITHUB_CLIENT_ID',
        defaultValue: '',
      );

  GithubAuthService.withClientId({required String clientId})
    : _clientId = clientId;

  String _generateState() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    return values.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Initiates interactive GitHub OAuth web flow via Chrome Custom Tabs / ASWebAuthenticationSession.
  /// Returns the authorization code if successful, or null if cancelled or failed.
  Future<String?> signIn() async {
    // If not configured or placeholder in debug mode, provide immediate mock fallback
    if (_clientId.isEmpty ||
        _clientId.startsWith('YOUR_') ||
        _clientId.startsWith('your_')) {
      AppLogger.warning(
        'GITHUB_CLIENT_ID is not configured. Falling back to mock_github_code in debug mode.',
        tag: 'GithubAuth',
      );
      if (kDebugMode) {
        return 'mock_github_code';
      }
      return null;
    }

    try {
      final state = _generateState();
      final authUrl = Uri.https('github.com', '/login/oauth/authorize', {
        'client_id': _clientId,
        'redirect_uri': redirectUri,
        'scope': _defaultScope,
        'state': state,
      }).toString();

      AppLogger.debug(
        'Launching GitHub OAuth flow: $authUrl',
        tag: 'GithubAuth',
      );

      final result = await FlutterWebAuth2.authenticate(
        url: authUrl,
        callbackUrlScheme: callbackUrlScheme,
      );

      final callbackUri = Uri.parse(result);
      final returnedState = callbackUri.queryParameters['state'];

      if (returnedState != state) {
        AppLogger.warning(
          'GitHub OAuth state mismatch. Possible CSRF attempt rejected.',
          tag: 'GithubAuth',
        );
        return null;
      }

      final error = callbackUri.queryParameters['error'];
      if (error != null) {
        final errorDescription =
            callbackUri.queryParameters['error_description'];
        AppLogger.warning(
          'GitHub OAuth returned error: $error ($errorDescription)',
          tag: 'GithubAuth',
        );
        return null;
      }

      final code = callbackUri.queryParameters['code'];
      if (code == null || code.isEmpty) {
        AppLogger.warning(
          'GitHub OAuth completed but no authorization code was returned',
          tag: 'GithubAuth',
        );
        return null;
      }

      return code;
    } on PlatformException catch (e, stackTrace) {
      if (e.code == 'CANCELED' ||
          e.code == 'canceled' ||
          e.message?.toLowerCase().contains('cancel') == true) {
        AppLogger.info(
          'GitHub sign-in was cancelled by user',
          tag: 'GithubAuth',
        );
        return null;
      }

      AppLogger.error(
        'GitHub sign-in platform error: ${e.code} - ${e.message}',
        tag: 'GithubAuth',
        error: e,
        stackTrace: stackTrace,
      );
      if (kDebugMode) {
        return 'mock_github_code';
      }
      return null;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected GitHub sign-in error',
        tag: 'GithubAuth',
        error: e,
        stackTrace: stackTrace,
      );
      if (kDebugMode) {
        return 'mock_github_code';
      }
      return null;
    }
  }
}
