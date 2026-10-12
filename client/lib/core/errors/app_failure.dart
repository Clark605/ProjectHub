import 'package:client/core/errors/app_exception.dart';

export 'package:client/core/errors/app_exception.dart' show FailureKind;

/// Represents a typed failure emitted from asynchronous operations.
class AppFailure {
  final FailureKind kind;
  final String? serverMessage;
  final bool isUserSafe;

  const AppFailure({
    required this.kind,
    this.serverMessage,
    this.isUserSafe = true,
  });

  static const Set<FailureKind> _userSafeKinds = {
    FailureKind.unauthorized,
    FailureKind.forbidden,
    FailureKind.notFound,
    FailureKind.validation,
  };

  factory AppFailure.fromException(Object error) {
    if (error is! AppException) {
      return const AppFailure(kind: FailureKind.unknown, isUserSafe: false);
    }
    final kind = error.kind;
    final trimmed = error.message.trim();
    final msg = trimmed.isNotEmpty ? error.message : null;
    return AppFailure(
      kind: kind,
      serverMessage: msg,
      isUserSafe: msg != null && _userSafeKinds.contains(kind),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppFailure &&
          runtimeType == other.runtimeType &&
          kind == other.kind &&
          serverMessage == other.serverMessage &&
          isUserSafe == other.isUserSafe;

  @override
  int get hashCode => Object.hash(kind, serverMessage, isUserSafe);

  @override
  String toString() =>
      'AppFailure(kind: $kind, serverMessage: $serverMessage, isUserSafe: $isUserSafe)';
}
