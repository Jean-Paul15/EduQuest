/// Typed Result for operations that can fail.
/// §11.5: No try/catch scattered in widgets — every fallible operation returns Result.
sealed class Result<T> {
  const Result();

  R fold<R>({required R Function(T data) onSuccess, required R Function(AppError error) onFailure});

  bool get isSuccess => this is _Success<T>;
  bool get isFailure => this is _Failure<T>;

  T? get dataOrNull => this is _Success<T> ? (this as _Success<T>).data : null;
  AppError? get errorOrNull => this is _Failure<T> ? (this as _Failure<T>).error : null;

  T getOrElse(T Function(AppError error) orElse) =>
      this is _Success<T> ? (this as _Success<T>).data : orElse((this as _Failure<T>).error);
}

class _Success<T> extends Result<T> {
  const _Success(this.data);
  final T data;
  @override
  R fold<R>({required R Function(T data) onSuccess, required R Function(AppError error) onFailure}) => onSuccess(data);
}

class _Failure<T> extends Result<T> {
  const _Failure(this.error);
  final AppError error;
  @override
  R fold<R>({required R Function(T data) onSuccess, required R Function(AppError error) onFailure}) => onFailure(error);
}

Result<T> success<T>(T data) => _Success(data);
Result<T> failure<T>(AppError error) => _Failure(error);

// ─── AppError hierarchy (§14.3) ──────────────────────────────────────────────

sealed class AppError {
  const AppError({required this.message, this.cause});
  final String message;
  final Object? cause;
}

class NetworkError extends AppError {
  const NetworkError({required super.message, super.cause});
}

class AuthError extends AppError {
  const AuthError({required super.message, super.cause});
}

class StorageError extends AppError {
  const StorageError({required super.message, super.cause});
}

class ContentSecurityError extends AppError {
  const ContentSecurityError({required super.message, super.cause});
}

class SyncError extends AppError {
  const SyncError({required super.message, super.cause});
}

class MediaError extends AppError {
  const MediaError({required super.message, super.cause});
}

class ServerError extends AppError {
  const ServerError({required super.message, this.statusCode, super.cause});
  final int? statusCode;
}

class ParseError extends AppError {
  const ParseError({required super.message, super.cause});
}

class UnknownError extends AppError {
  const UnknownError({required super.message, super.cause});
}
