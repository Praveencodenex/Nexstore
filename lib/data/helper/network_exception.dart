import 'package:dio/dio.dart';

/// Network error messages for various HTTP and connection scenarios
class NetworkStrings {
  // Client-side timeout errors
  static const connectionTimeout = 'The request failed because the connection to the server took too long to establish';
  static const sendTimeout = 'The request failed because sending data to the server took too long';
  static const receiveTimeout = 'The request failed because receiving data from the server took too long';

  // Connection states
  static const noInternet = 'The request failed because there is no internet connection available';
  static const requestCancelled = 'The request was cancelled before completion';
  static const unknownError = 'The request failed due to an unknown error';
  static const defaultError = 'The request failed due to an unexpected server error';

  // HTTP Status code messages
  static const Map<int, String> httpErrors = {
    400: 'The request was invalid or cannot be processed by the server',
    401: 'The request requires user authentication',
    403: 'You do not have permission to access this resource',
    404: 'The requested resource was not found on the server',
    405: 'The request method is not supported for this resource',
    409: 'The request conflicts with the current state of the server',
    422: 'The server understood the request but cannot process it',
    429: 'Too many requests have been made, please try again later',
    500: 'An internal server error occurred',
    502: 'The server received an invalid response from the upstream server',
    503: 'The server is temporarily unavailable or under maintenance',
    504: 'The server timed out waiting for a response from the upstream server'
  };
}

/// Custom exception class to handle network-related errors
class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const NetworkException({
    required this.message,
    this.statusCode,
    this.data,
  });

  factory NetworkException.fromDioError(DioException error) {
    // First check if there's a custom error message in the response
    if (error.response?.data is Map<String, dynamic> &&
        error.response?.data['message'] != null) {
      return NetworkException(
        message: error.response!.data['message'],
        statusCode: error.response?.statusCode,
        data: error.response?.data,
      );
    }

    // If no custom message, then handle standard cases
    if (error.type == DioExceptionType.connectionTimeout) {
      return const NetworkException(
        message: NetworkStrings.connectionTimeout,
        statusCode: 408,
      );
    }

    if (error.type == DioExceptionType.sendTimeout) {
      return const NetworkException(
        message: NetworkStrings.sendTimeout,
        statusCode: 408,
      );
    }

    if (error.type == DioExceptionType.receiveTimeout) {
      return const NetworkException(
        message: NetworkStrings.receiveTimeout,
        statusCode: 408,
      );
    }

    if (error.type == DioExceptionType.connectionError) {
      return const NetworkException(
        message: NetworkStrings.noInternet,
        statusCode: -1,
      );
    }

    if (error.type == DioExceptionType.cancel) {
      return const NetworkException(
        message: NetworkStrings.requestCancelled,
        statusCode: 499,
      );
    }

    if (error.type == DioExceptionType.badResponse) {
      final statusCode = error.response?.statusCode;
      // Only use predefined HTTP errors if there's no custom message
      final message = error.response?.data['message'] ??
          NetworkStrings.httpErrors[statusCode] ??
          error.response?.statusMessage ??
          NetworkStrings.defaultError;

      return NetworkException(
        message: message,
        statusCode: statusCode,
        data: error.response?.data,
      );
    }

    if (error.type == DioExceptionType.unknown) {
      if (error.error is String) {
        return NetworkException(message: error.error as String);
      }
      return const NetworkException(message: NetworkStrings.unknownError);
    }

    return const NetworkException(
      message: NetworkStrings.defaultError,
      statusCode: 500,
    );
  }

  @override
  String toString() => message;
}