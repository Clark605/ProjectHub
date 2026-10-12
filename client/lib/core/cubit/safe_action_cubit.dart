import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client/core/errors/app_exception.dart';
import 'package:client/core/errors/app_failure.dart';
import 'package:client/core/utils/app_logger.dart';

/// Base Cubit that provides standardized error handling via [safeExecute].
/// Catches [AppException] and generic [Exception]/[Error] objects, routing
/// typed failures through [onFailure].
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
  /// - Logs every failure using [logTag] (defaulting to `runtimeType.toString()`).
  /// - Passes typed failure to [onFailure].
  /// - Returns the computed value of type [R], or `null` on failure.
  Future<R?> safeExecute<R>(
    Future<R> Function() action, {
    void Function(AppFailure failure)? onFailure,
    String? logTag,
  }) async {
    try {
      final result = await action();
      if (isClosed) return null;
      return result;
    } on Object catch (e, st) {
      return _handleFailure(e, st, onFailure: onFailure, logTag: logTag);
    }
  }

  R? _handleFailure<R>(
    Object error,
    StackTrace stackTrace, {
    void Function(AppFailure failure)? onFailure,
    String? logTag,
  }) {
    if (isClosed) return null;
    final tag = logTag ?? runtimeType.toString();
    if (error is AppException) {
      AppLogger.warning(
        'AppException caught in $tag: ${error.message}',
        tag: tag,
        error: error,
        stackTrace: stackTrace,
      );
    } else {
      AppLogger.error(
        'Unexpected error caught in $tag: $error',
        tag: tag,
        error: error,
        stackTrace: stackTrace,
      );
    }
    onFailure?.call(AppFailure.fromException(error));
    return null;
  }
}
