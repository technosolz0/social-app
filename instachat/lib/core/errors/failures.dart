// ============================================
// lib/core/errors/failures.dart
// ❌ FAILURE CLASSES FOR DOMAIN LAYER
// ============================================

/// Base failure class for all domain failures
abstract class Failure {
  final String message;
  final String? code;
  final dynamic data;

  const Failure(this.message, {this.code, this.data});

  @override
  List<Object?> get props => [message, code, data];

  @override
  String toString() =>
      'Failure: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure(String message, {String? code, dynamic data})
    : super(message, code: code, data: data);
}

/// Network failures
class NetworkFailure extends Failure {
  const NetworkFailure(String message, {String? code, dynamic data})
    : super(message, code: code, data: data);
}

/// API failures
class ApiFailure extends Failure {
  final int? statusCode;

  const ApiFailure(
    String message, {
    this.statusCode,
    String? code,
    dynamic data,
  }) : super(message, code: code, data: data);

  @override
  List<Object?> get props => [message, code, data, statusCode];

  @override
  String toString() =>
      'ApiFailure: $message${statusCode != null ? ' (Status: $statusCode)' : ''}${code != null ? ' (Code: $code)' : ''}';
}

/// Database failures
class DatabaseFailure extends Failure {
  const DatabaseFailure(String message, {String? code, dynamic data})
    : super(message, code: code, data: data);
}

/// Cache failures
class CacheFailure extends Failure {
  const CacheFailure(String message, {String? code, dynamic data})
    : super(message, code: code, data: data);
}

/// Storage failures
class StorageFailure extends Failure {
  const StorageFailure(String message, {String? code, dynamic data})
    : super(message, code: code, data: data);
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure(String message, {String? code, dynamic data})
    : super(message, code: code, data: data);
}

/// Permission failures
class PermissionFailure extends Failure {
  const PermissionFailure(String message, {String? code, dynamic data})
    : super(message, code: code, data: data);
}

/// File failures
class FileFailure extends Failure {
  const FileFailure(String message, {String? code, dynamic data})
    : super(message, code: code, data: data);
}

/// Location failures
class LocationFailure extends Failure {
  const LocationFailure(String message, {String? code, dynamic data})
    : super(message, code: code, data: data);
}

/// Camera failures
class CameraFailure extends Failure {
  const CameraFailure(String message, {String? code, dynamic data})
    : super(message, code: code, data: data);
}

/// Notification failures
class NotificationFailure extends Failure {
  const NotificationFailure(String message, {String? code, dynamic data})
    : super(message, code: code, data: data);
}

/// Payment failures
class PaymentFailure extends Failure {
  const PaymentFailure(String message, {String? code, dynamic data})
    : super(message, code: code, data: data);
}

/// Rate limit failures
class RateLimitFailure extends Failure {
  final int retryAfterSeconds;

  const RateLimitFailure(
    String message,
    this.retryAfterSeconds, {
    String? code,
    dynamic data,
  }) : super(message, code: code, data: data);

  @override
  List<Object?> get props => [message, code, data, retryAfterSeconds];

  @override
  String toString() =>
      'RateLimitFailure: $message (Retry after: $retryAfterSeconds seconds)${code != null ? ' (Code: $code)' : ''}';
}

/// Timeout failures
class TimeoutFailure extends Failure {
  const TimeoutFailure(String message, {String? code, dynamic data})
    : super(message, code: code, data: data);
}

/// Serialization failures
class SerializationFailure extends Failure {
  const SerializationFailure(String message, {String? code, dynamic data})
    : super(message, code: code, data: data);
}

/// Configuration failures
class ConfigurationFailure extends Failure {
  const ConfigurationFailure(String message, {String? code, dynamic data})
    : super(message, code: code, data: data);
}

/// Unknown failures
class UnknownFailure extends Failure {
  const UnknownFailure(String message, {String? code, dynamic data})
    : super(message, code: code, data: data);
}

/// Server failures (5xx status codes)
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure(
    String message, {
    this.statusCode,
    String? code,
    dynamic data,
  }) : super(message, code: code, data: data);

  @override
  List<Object?> get props => [message, code, data, statusCode];
}

/// Client failures (4xx status codes)
class ClientFailure extends Failure {
  final int? statusCode;

  const ClientFailure(
    String message, {
    this.statusCode,
    String? code,
    dynamic data,
  }) : super(message, code: code, data: data);

  @override
  List<Object?> get props => [message, code, data, statusCode];
}

/// Connection failures
class ConnectionFailure extends Failure {
  const ConnectionFailure(String message, {String? code, dynamic data})
    : super(message, code: code, data: data);
}

/// Offline failures
class OfflineFailure extends Failure {
  const OfflineFailure(String message, {String? code, dynamic data})
    : super(message, code: code, data: data);
}

/// Not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure(String resource)
    : super('Resource not found: $resource', code: 'NOT_FOUND');
}

/// Unauthorized failures
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(String message)
    : super(message, code: 'UNAUTHORIZED');
}

/// Forbidden failures
class ForbiddenFailure extends Failure {
  const ForbiddenFailure(String message) : super(message, code: 'FORBIDDEN');
}

/// Already exists failures
class AlreadyExistsFailure extends Failure {
  const AlreadyExistsFailure(String resource)
    : super('Resource already exists: $resource', code: 'ALREADY_EXISTS');
}

/// Validation failures with field information
class FieldValidationFailure extends ValidationFailure {
  final String field;
  final String fieldMessage;

  FieldValidationFailure(this.field, this.fieldMessage)
    : super(
        fieldMessage,
        code: 'FIELD_VALIDATION',
        data: {'field': field, 'message': fieldMessage},
      );

  @override
  List<Object?> get props => [message, code, data, field, fieldMessage];
}

/// Multiple validation failures
class MultiValidationFailure extends ValidationFailure {
  final List<FieldValidationFailure> fieldFailures;

  const MultiValidationFailure(this.fieldFailures)
    : super(
        'Multiple validation errors',
        code: 'MULTI_VALIDATION',
        data: fieldFailures,
      );

  @override
  List<Object?> get props => [message, code, data, fieldFailures];
}

/// Cancelled failures
class CancelledFailure extends Failure {
  const CancelledFailure(String operation)
    : super('Operation cancelled: $operation', code: 'CANCELLED');
}

/// Feature not implemented failures
class NotImplementedFailure extends Failure {
  const NotImplementedFailure(String feature)
    : super('Feature not implemented: $feature', code: 'NOT_IMPLEMENTED');
}

/// Insufficient permissions failures
class InsufficientPermissionsFailure extends Failure {
  const InsufficientPermissionsFailure(String permission)
    : super(
        'Insufficient permissions: $permission',
        code: 'INSUFFICIENT_PERMISSIONS',
      );
}

/// Quota exceeded failures
class QuotaExceededFailure extends Failure {
  const QuotaExceededFailure(String resource)
    : super('Quota exceeded for: $resource', code: 'QUOTA_EXCEEDED');
}

/// Maintenance mode failures
class MaintenanceFailure extends Failure {
  final DateTime? estimatedCompletion;

  const MaintenanceFailure(
    String message, {
    this.estimatedCompletion,
    String? code,
    dynamic data,
  }) : super(message, code: code, data: data);

  @override
  List<Object?> get props => [message, code, data, estimatedCompletion];
}

/// Dependency failures (when external services fail)
class DependencyFailure extends Failure {
  final String dependency;

  const DependencyFailure(
    this.dependency,
    String message, {
    String? code,
    dynamic data,
  }) : super(message, code: code, data: data);

  @override
  List<Object?> get props => [message, code, data, dependency];
}

/// Concurrency failures (when operations conflict)
class ConcurrencyFailure extends Failure {
  const ConcurrencyFailure(String message, {String? code, dynamic data})
    : super(message, code: code ?? 'CONCURRENCY', data: data);
}

/// Data integrity failures
class DataIntegrityFailure extends Failure {
  const DataIntegrityFailure(String message, {String? code, dynamic data})
    : super(message, code: code ?? 'DATA_INTEGRITY', data: data);
}

/// Business logic failures
class BusinessLogicFailure extends Failure {
  const BusinessLogicFailure(String message, {String? code, dynamic data})
    : super(message, code: code ?? 'BUSINESS_LOGIC', data: data);
}
