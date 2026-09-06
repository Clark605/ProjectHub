import 'dart:convert';

class JwtUtils {
  static Map<String, dynamic>? extractPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }
      final payload = parts[1];
      final String normalized = base64Url.normalize(payload);
      final String decoded = utf8.decode(base64Url.decode(normalized));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static String? extractUserId(String token) {
    final payload = extractPayload(token);
    if (payload == null) return null;

    final userId = payload['sub'] ??
        payload['nameid'] ??
        payload['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] ??
        payload['id'];

    final idStr = userId?.toString();
    return (idStr != null && idStr.isNotEmpty) ? idStr : null;
  }
}
