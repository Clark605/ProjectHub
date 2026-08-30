import 'package:freezed_annotation/freezed_annotation.dart';

part 'failure.freezed.dart';

@freezed
sealed class Failure with _$Failure {
  const factory Failure.server({required String message, String? details}) =
      ServerFailure;
  const factory Failure.network({
    @Default('No internet connection') String message,
  }) = NetworkFailure;
  const factory Failure.auth({
    @Default('Authentication failed') String message,
  }) = AuthFailure;
  const factory Failure.notFound({
    @Default('Resource not found') String message,
  }) = NotFoundFailure;
  const factory Failure.validation({required String message, String? details}) =
      ValidationFailure;
  const factory Failure.unknown({
    @Default('An unexpected error occurred') String message,
  }) = UnknownFailure;
}
