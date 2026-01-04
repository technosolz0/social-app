// ============================================
// lib/core/errors/exceptions.dart
// 🚨 CUSTOM EXCEPTIONS FOR ERROR HANDLING
// ============================================

/// Base exception class for all app-specific exceptions
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic data;

  const AppException(this.message, {this.code, this.data});

  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Authentication exceptions
class AuthException extends AppException {
  const AuthException(String message, {String? code, dynamic data})
      : super(message, code: code, data: data);
}

/// Network exceptions
class NetworkException extends AppException {
  const NetworkException(String message, {String? code, dynamic data})
      : super(message, code: code, data: data);
}

/// API exceptions
class ApiException extends AppException {
  final int? statusCode;

  const ApiException(String message, {this.statusCode, String? code, dynamic data})
      : super(message, code: code, data: data);

  @override
  String toString() => 'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}${code != null ? ' (Code: $code)' : ''}';
}

/// Database exceptions
class DatabaseException extends AppException {
  const DatabaseException(String message, {String? code, dynamic data})
      : super(message, code: code, data: data);
}

/// Cache exceptions
class CacheException extends AppException {
  const CacheException(String message, {String? code, dynamic data})
      : super(message, code: code, data: data);
}

/// Storage exceptions
class StorageException extends AppException {
  const StorageException(String message, {String? code, dynamic data})
      : super(message, code: code, data: data);
}

/// Validation exceptions
class ValidationException extends AppException {
  const ValidationException(String message, {String? code, dynamic data})
      : super(message, code: code, data: data);
}

/// Permission exceptions
class PermissionException extends AppException {
  const PermissionException(String message, {String? code, dynamic data})
      : super(message, code: code, data: data);
}

/// File exceptions
class FileException extends AppException {
  const FileException(String message, {String? code, dynamic data})
      : super(message, code: code, data: data);
}

/// Location exceptions
class LocationException extends AppException {
  const LocationException(String message, {String? code, dynamic data})
      : super(message, code: code, data: data);
}

/// Camera exceptions
class CameraException extends AppException {
  const CameraException(String message, {String? code, dynamic data})
      : super(message, code: code, data: data);
}

/// Notification exceptions
class NotificationException extends AppException {
  const NotificationException(String message, {String? code, dynamic data})
      : super(message, code: code, data: data);
}

/// Payment exceptions
class PaymentException extends AppException {
  const PaymentException(String message, {String? code, dynamic data})
      : super(message, code: code, data: data);
}

/// Rate limit exceptions
class RateLimitException extends AppException {
  final int retryAfterSeconds;

  const RateLimitException(String message, this.retryAfterSeconds, {String? code, dynamic data})
      : super(message, code: code, data: data);

  @override
  String toString() => 'RateLimitException: $message (Retry after: $retryAfterSeconds seconds)${code != null ? ' (Code: $code)' : ''}';
}

/// Timeout exceptions
class TimeoutException extends AppException {
  const TimeoutException(String message, {String? code, dynamic data})
      : super(message, code: code, data: data);
}

/// Serialization exceptions
class SerializationException extends AppException {
  const SerializationException(String message, {String? code, dynamic data})
      : super(message, code: code, data: data);
}

/// Configuration exceptions
class ConfigurationException extends AppException {
  const ConfigurationException(String message, {String? code, dynamic data})
      : super(message, code: code, data: data);
}

/// Unknown exceptions
class UnknownException extends AppException {
  const UnknownException(String message, {String? code, dynamic data})
      : super(message, code: code, data: data);
}

/// Custom exception for when a feature is not implemented
class NotImplementedException extends AppException {
  const NotImplementedException(String feature)
      : super('Feature not implemented: $feature');
}

/// Custom exception for invalid arguments
class InvalidArgumentException extends AppException {
  const InvalidArgumentException(String message, {String? code, dynamic data})
      : super(message, code: code, data: data);
}

/// Custom exception for when a resource is not found
class NotFoundException extends AppException {
  const NotFoundException(String resource)
      : super('Resource not found: $resource');
}

/// Custom exception for when user is not authorized
class UnauthorizedException extends AppException {
  const UnauthorizedException(String message)
      : super(message, code: 'UNAUTHORIZED');
}

/// Custom exception for when user is forbidden from accessing a resource
class ForbiddenException extends AppException {
  const ForbiddenException(String message)
      : super(message, code: 'FORBIDDEN');
}

/// Custom exception for when a resource already exists
class AlreadyExistsException extends AppException {
  const AlreadyExistsException(String resource)
      : super('Resource already exists: $resource');
}

/// Custom exception for when an operation is cancelled
class CancelledException extends AppException {
  const CancelledException(String operation)
      : super('Operation cancelled: $operation');
}
