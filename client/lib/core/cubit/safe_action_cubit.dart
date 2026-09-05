import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client/core/errors/app_exception.dart';
import 'package:client/core/utils/app_logger.dart';

/// Base Cubit that provides standardized error handling via [safeExecute].
/// Catches [AppException] and generic [Exception]/[Error] objects, routing
/// failure messages through [onError].
abstract class SafeActionCubit<T> extends Cubit<T> {
  SafeActionCubit(super.initialState);

  /// Executes [action] within a standardized try/catch block.
  ///
  /// - Catches [AppException] and passes its `message` to [onError].
  /// - Catches generic exceptions and passes [defaultErrorMessage] to [onError].
  /// - Returns the computed value of type [R], or `null` on failure.
  Future<R?> safeExecute<R>(
    Future<R> Function() action, {
    void Function(String errorMessage)? onError,
    String defaultErrorMessage = 'An unexpected error occurred',
    String? logTag,
  }) async {
    try {
      return await action();
    } on AppException catch (e, st) {
      if (logTag != null) {
        AppLogger.warning(
          'AppException caught in $logTag: ${e.message}',
          tag: logTag,
          error: e,
          stackTrace: st,
        );
      }
      onError?.call(e.message);
      return null;
    } catch (e, st) {
      if (logTag != null) {
        AppLogger.error(
          'Unexpected error caught in $logTag: $e',
          tag: logTag,
          error: e,
          stackTrace: st,
        );
      }
      onError?.call(defaultErrorMessage);
      return null;
    }
  }
}
