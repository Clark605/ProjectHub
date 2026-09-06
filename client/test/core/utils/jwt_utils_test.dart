import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:client/core/utils/jwt_utils.dart';

void main() {
  group('JwtUtils', () {
    String createToken(Map<String, dynamic> payload) {
      final header = base64Url.encode(utf8.encode(jsonEncode({'alg': 'HS256'})));
      final body = base64Url.encode(utf8.encode(jsonEncode(payload)));
      return '$header.$body.signature';
    }

    test('extractPayload returns valid payload', () {
      final token = createToken({'sub': '123', 'name': 'test'});
      final payload = JwtUtils.extractPayload(token);
      expect(payload, isNotNull);
      expect(payload!['sub'], '123');
      expect(payload['name'], 'test');
    });

    test('extractPayload returns null for invalid token', () {
      expect(JwtUtils.extractPayload('invalid.token'), isNull);
      expect(JwtUtils.extractPayload(''), isNull);
    });

    test('extractUserId returns sub', () {
      final token = createToken({'sub': 'user-123'});
      expect(JwtUtils.extractUserId(token), 'user-123');
    });

    test('extractUserId returns nameidentifier', () {
      final token = createToken({
        'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier': 'user-456'
      });
      expect(JwtUtils.extractUserId(token), 'user-456');
    });

    test('extractUserId returns nameid', () {
      final token = createToken({'nameid': 'user-789'});
      expect(JwtUtils.extractUserId(token), 'user-789');
    });

    test('extractUserId returns null if no valid id claim', () {
      final token = createToken({'email': 'test@test.com'});
      expect(JwtUtils.extractUserId(token), isNull);
    });
  });
}
