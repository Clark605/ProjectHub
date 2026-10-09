import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client/core/errors/app_exception.dart';
import 'package:client/core/errors/app_failure.dart';
import 'package:client/core/utils/app_logger.dart';

/// Base Cubit that provides standardized error handling via [safeExecute].
/// Catches [AppException] and generic [Exception]/[Error] objects, routing
/// failure messages through [onError] or typed failures through [onFailure].
abstract class SafeActionCubit<T> extends Cubit<T> {
  SafeActionCubit(super.initialState);

  @override
  void emit(T state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Executes [action] within a standardized try/catch block.
  ///
  /// - Catches [AppException] and generic exceptions, mapping them to [AppFailure].
  /// - Passes typed failure to [onFailure] and the raw/server message to [onError].
  /// - Returns the computed value of type [R], or `null` on failure.
  Future<R?> safeExecute<R>(
    Future<R> Function() action, {
    void Function(String errorMessage)? onError,
    void Function(AppFailure failure)? onFailure,
    String? defaultErrorMessage,
    String? logTag,
  }) async {
    try {
      final result = await action();
      if (isClosed) return null;
      return result;
    } on AppException catch (e, st) {
      if (isClosed) return null;
      if (logTag != null) {
        AppLogger.warning(
          'AppException caught in $logTag: ${e.message}',
          tag: logTag,
          error: e,
          stackTrace: st,
        );
      }
      final failure = AppFailure.fromException(e);
      onFailure?.call(failure);
      onError?.call(failure.serverMessage ?? defaultErrorMessage ?? e.message);
      return null;
    } on Object catch (e, st) {
      if (isClosed) return null;
      if (logTag != null) {
        AppLogger.error(
          'Unexpected error caught in $logTag: $e',
          tag: logTag,
          error: e,
          stackTrace: st,
        );
      }
      final failure = AppFailure.fromException(e);
      onFailure?.call(failure);
      onError?.call(
        defaultErrorMessage ??
            failure.serverMessage ??
            'An unexpected error occurred',
      );
      return null;
    }
  }
}
