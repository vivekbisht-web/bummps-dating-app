import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../constants/app_constants.dart';
import '../storage/secure_storage_service.dart';
import '../../utils/pretty_logger.dart';
import 'auth_interceptor.dart';
import 'dio_exception.dart';

class DioClient {
  late final Dio _dio;

  DioClient(SecureStorageService storageService) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        responseType: ResponseType.json,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Attach AuthInterceptor
    _dio.interceptors.add(AuthInterceptor(storageService));

    // Logging interceptor for debugging in development mode
    if (kDebugMode) {
      _dio.interceptors.add(PrettyDioInterceptor());
    }
  }

  // Generic GET Request
  Future<T> get<T>(
    String path, {
    required T Function(dynamic json) fromJson,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Generic POST Request
  Future<T> post<T>(
    String path, {
    required T Function(dynamic json) fromJson,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Generic PUT Request
  Future<T> put<T>(
    String path, {
    required T Function(dynamic json) fromJson,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Generic DELETE Request
  Future<T> delete<T>(
    String path, {
    required T Function(dynamic json) fromJson,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
