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
  const AuthException(super.message, {super.code, super.data});
}

/// Network exceptions
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.data});
}

/// API exceptions
class ApiException extends AppException {
  final int? statusCode;

  const ApiException(super.message, {this.statusCode, super.code, super.data});

  @override
  String toString() => 'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}${code != null ? ' (Code: $code)' : ''}';
}

/// Database exceptions
class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.code, super.data});
}

/// Cache exceptions
class CacheException extends AppException {
  const CacheException(super.message, {super.code, super.data});
}

/// Storage exceptions
class StorageException extends AppException {
  const StorageException(super.message, {super.code, super.data});
}

/// Validation exceptions
class ValidationException extends AppException {
  const ValidationException(super.message, {super.code, super.data});
}

/// Permission exceptions
class PermissionException extends AppException {
  const PermissionException(super.message, {super.code, super.data});
}

/// File exceptions
class FileException extends AppException {
  const FileException(super.message, {super.code, super.data});
}

/// Location exceptions
class LocationException extends AppException {
  const LocationException(super.message, {super.code, super.data});
}

/// Camera exceptions
class CameraException extends AppException {
  const CameraException(super.message, {super.code, super.data});
}

/// Notification exceptions
class NotificationException extends AppException {
  const NotificationException(super.message, {super.code, super.data});
}

/// Payment exceptions
class PaymentException extends AppException {
  const PaymentException(super.message, {super.code, super.data});
}

/// Rate limit exceptions
class RateLimitException extends AppException {
  final int retryAfterSeconds;

  const RateLimitException(super.message, this.retryAfterSeconds, {super.code, super.data});

  @override
  String toString() => 'RateLimitException: $message (Retry after: $retryAfterSeconds seconds)${code != null ? ' (Code: $code)' : ''}';
}

/// Timeout exceptions
class TimeoutException extends AppException {
  const TimeoutException(super.message, {super.code, super.data});
}

/// Serialization exceptions
class SerializationException extends AppException {
  const SerializationException(super.message, {super.code, super.data});
}

/// Configuration exceptions
class ConfigurationException extends AppException {
  const ConfigurationException(super.message, {super.code, super.data});
}

/// Unknown exceptions
class UnknownException extends AppException {
  const UnknownException(super.message, {super.code, super.data});
}

/// Custom exception for when a feature is not implemented
class NotImplementedException extends AppException {
  const NotImplementedException(String feature)
      : super('Feature not implemented: $feature');
}

/// Custom exception for invalid arguments
class InvalidArgumentException extends AppException {
  const InvalidArgumentException(super.message, {super.code, super.data});
}

/// Custom exception for when a resource is not found
class NotFoundException extends AppException {
  const NotFoundException(String resource)
      : super('Resource not found: $resource');
}

/// Custom exception for when user is not authorized
class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message)
      : super(code: 'UNAUTHORIZED');
}

/// Custom exception for when user is forbidden from accessing a resource
class ForbiddenException extends AppException {
  const ForbiddenException(super.message)
      : super(code: 'FORBIDDEN');
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
