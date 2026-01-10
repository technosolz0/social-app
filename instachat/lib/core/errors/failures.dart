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
  const AuthFailure(super.message, {super.code, super.data});
}

/// Network failures
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code, super.data});
}

/// API failures
class ApiFailure extends Failure {
  final int? statusCode;

  const ApiFailure(
    super.message, {
    this.statusCode,
    super.code,
    super.data,
  });

  @override
  List<Object?> get props => [message, code, data, statusCode];

  @override
  String toString() =>
      'ApiFailure: $message${statusCode != null ? ' (Status: $statusCode)' : ''}${code != null ? ' (Code: $code)' : ''}';
}

/// Database failures
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, {super.code, super.data});
}

/// Cache failures
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code, super.data});
}

//// Storage failures
class StorageFailure extends Failure {
  const StorageFailure(super.message, {super.code, super.data});
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code, super.data});
}

/// Permission failures
class PermissionFailure extends Failure {
  const PermissionFailure(super.message, {super.code, super.data});
}

/// File failures
class FileFailure extends Failure {
  const FileFailure(super.message, {super.code, super.data});
}

/// Location failures
class LocationFailure extends Failure {
  const LocationFailure(super.message, {super.code, super.data});
}

/// Camera failures
class CameraFailure extends Failure {
  const CameraFailure(super.message, {super.code, super.data});
}

/// Notification failures
class NotificationFailure extends Failure {
  const NotificationFailure(super.message, {super.code, super.data});
}

/// Payment failures
class PaymentFailure extends Failure {
  const PaymentFailure(super.message, {super.code, super.data});
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
  const TimeoutFailure(super.message, {super.code, super.data});
}

/// Serialization failures
class SerializationFailure extends Failure {
  const SerializationFailure(super.message, {super.code, super.data});
}

/// Configuration failures
class ConfigurationFailure extends Failure {
  const ConfigurationFailure(super.message, {super.code, super.data});
}

/// Unknown failures
class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.code, super.data});
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
  const ConnectionFailure(super.message, {super.code, super.data});
}

/// Offline failures
class OfflineFailure extends Failure {
  const OfflineFailure(super.message, {super.code, super.data});
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
  const ConcurrencyFailure(super.message, {super.code, super.data});
}

/// Data integrity failures
class DataIntegrityFailure extends Failure {
  const DataIntegrityFailure(super.message, {super.code, super.data});
}

/// Business logic failures
class BusinessLogicFailure extends Failure {
  const BusinessLogicFailure(super.message, {super.code, super.data});
}
