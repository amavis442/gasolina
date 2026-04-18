// ABOUTME: Data layer exception classes for error handling
// ABOUTME: Defines DataException, ValidationException, NetworkException, AuthException

class DataException implements Exception {
  final String message;

  DataException(this.message);

  @override
  String toString() => 'DataException: $message';
}

class ValidationException implements Exception {
  final String message;

  ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}

class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  NetworkException(this.message, {this.statusCode});

  @override
  String toString() => 'NetworkException($statusCode): $message';
}

class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
