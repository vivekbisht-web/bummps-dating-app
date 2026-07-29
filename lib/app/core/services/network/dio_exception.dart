import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

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
        message = 'Send timeout in association with server.';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Receive timeout in connection with server.';
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

    return ApiException(message: message, statusCode: statusCode);
  }

  static String _handleErrorResponse(Response? response) {
    if (response == null || response.data == null) {
      return 'Received invalid response from server.';
    }

    final data = response.data;
    if (data is Map<String, dynamic>) {
      // Check common API error formats
      if (data.containsKey('message')) {
        return data['message'].toString();
      } else if (data.containsKey('error')) {
        return data['error'].toString();
      } else if (data.containsKey('errors')) {
        final errors = data['errors'];
        if (errors is Map) {
          return errors.values.map((e) => e.toString()).join('\n');
        } else if (errors is List) {
          return errors.join('\n');
        }
      }
    }
    
    return 'Server returned error: ${response.statusCode}';
  }
}
