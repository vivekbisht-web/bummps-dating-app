import 'dart:convert';
import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic responseData;

  ApiException({required this.message, this.statusCode, this.responseData});

  @override
  String toString() => message;

  factory ApiException.fromDioException(DioException dioException) {
    String message = 'An unexpected error occurred. Please try again.';
    int? statusCode = dioException.response?.statusCode;

    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Send timeout while communicating with server.';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Receive timeout while receiving data from server.';
        break;
      case DioExceptionType.badResponse:
        message = _handleErrorResponse(dioException.response);
        break;
      case DioExceptionType.cancel:
        message = 'Request to server was cancelled.';
        break;
      case DioExceptionType.connectionError:
        message = 'No internet connection. Please verify your network settings.';
        break;
      case DioExceptionType.unknown:
      default:
        if (dioException.message != null && dioException.message!.contains('SocketException')) {
          message = 'No internet connection. Please verify your network settings.';
        }
        break;
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      responseData: dioException.response?.data,
    );
  }

  static String _handleErrorResponse(Response? response) {
    if (response == null || response.data == null) {
      return 'Received invalid response from server.';
    }

    int? statusCode = response.statusCode;
    dynamic data = response.data;

    // Decode String response data if server returned raw JSON string
    if (data is String && data.trim().startsWith('{')) {
      try {
        data = jsonDecode(data);
      } catch (_) {}
    }

    if (data is Map<String, dynamic>) {
      if (data.containsKey('message') && data['message'] != null) {
        final msg = data['message'];
        if (msg is List) {
          return msg.map((e) => e.toString()).join('\n');
        }
        return msg.toString();
      } else if (data.containsKey('error') && data['error'] != null) {
        final err = data['error'];
        if (err is Map && err.containsKey('message')) {
          return err['message'].toString();
        }
        return err.toString();
      } else if (data.containsKey('errors') && data['errors'] != null) {
        final errors = data['errors'];
        if (errors is Map) {
          return errors.values.map((e) => e.toString()).join('\n');
        } else if (errors is List) {
          return errors.map((e) => e.toString()).join('\n');
        }
      } else if (data.containsKey('msg') && data['msg'] != null) {
        return data['msg'].toString();
      } else if (data.containsKey('detail') && data['detail'] != null) {
        return data['detail'].toString();
      }
    }

    // Status code fallback messages for production readiness
    switch (statusCode) {
      case 400:
        return 'Invalid request data. Please check your inputs and try again.';
      case 401:
        return 'Invalid email or password. Please verify your credentials.';
      case 403:
        return 'Access denied. You do not have permission to perform this action.';
      case 404:
        return 'Account not found. Please register first to create your Bummps account.';
      case 409:
        return 'An account with this email address already exists.';
      case 422:
        return 'Validation failed. Please verify your profile and account details.';
      case 500:
      case 502:
      case 503:
        return 'Server error. Our team has been notified, please try again shortly.';
      default:
        return 'Server returned error (${statusCode ?? 'Unknown'})';
    }
  }
}

