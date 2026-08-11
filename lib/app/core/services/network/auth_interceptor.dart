import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' as get_x;
import '../../../routes/app_pages.dart';
import '../../constants/app_constants.dart';
import '../../utils/app_snackbar.dart';
import '../storage/secure_storage_service.dart';

class AuthInterceptor extends QueuedInterceptor {
  final SecureStorageService _storageService;
  final Dio _refreshDio; // Dedicated Dio client for token refreshing to avoid infinite loops

  AuthInterceptor(this._storageService)
      : _refreshDio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Check if the endpoint requires authorization (default is true unless set to false)
    final requiresAuth = options.extra['requiresAuth'] ?? true;

    if (requiresAuth) {
      final token = await _storageService.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final requiresAuth = err.requestOptions.extra['requiresAuth'] ?? true;

    // Check for 401 Unauthorized errors ONLY for protected endpoints requiring auth
    if (requiresAuth && err.response?.statusCode == 401) {
      final refreshToken = await _storageService.getRefreshToken();
      
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          debugPrint('[AuthInterceptor] Token expired. Attempting token refresh...');
          
          // Trigger refresh token API call
          final response = await _refreshDio.post(
            'auth/refresh',
            data: {'refreshToken': refreshToken},
          );

          if (response.statusCode == 200 && response.data != null) {
            final newToken = response.data['token'] as String?;
            final newRefreshToken = response.data['refreshToken'] as String?;

            if (newToken != null) {
              // Save new tokens
              await _storageService.saveToken(newToken);
              if (newRefreshToken != null) {
                await _storageService.saveRefreshToken(newRefreshToken);
              }

              debugPrint('[AuthInterceptor] Token refresh successful. Retrying original request.');
              
              // Clone options and retry the original request with new token
              final options = err.requestOptions;
              options.headers['Authorization'] = 'Bearer $newToken';

              // Create a temporary Dio to retry request
              final retryDio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
              final retryResponse = await retryDio.fetch(options);
              
              return handler.resolve(retryResponse);
            }
          }
        } catch (e) {
          debugPrint('[AuthInterceptor] Token refresh failed: $e');
        }
      }

      // If refresh failed or was not available, handle unauthorized (logout)
      await _handleLogout();
      
      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: 'Session expired. Please log in again.',
          type: DioExceptionType.unknown,
          response: err.response,
        ),
      );
    }

    // Global handling for other status codes: 403 Forbidden, 500 Server Error
    if (err.response != null) {
      final statusCode = err.response!.statusCode;
      final bool suppressGlobalError = err.requestOptions.extra['suppressGlobalError'] == true;

      if (!suppressGlobalError) {
        if (statusCode == 403) {
          _showGlobalError('Access Denied', 'You do not have permission to access this resource.');
        } else if (statusCode != null && statusCode >= 500) {
          _showGlobalError('Server Error', 'Our servers are currently experiencing issues. Please try again later.');
        }
      }
    }

    return handler.next(err);
  }

  Future<void> _handleLogout() async {
    debugPrint('[AuthInterceptor] Logging out due to unauthorized response.');
    await _storageService.clearAll();
    
    if (get_x.Get.currentRoute != Routes.login && get_x.Get.currentRoute != Routes.register) {
      _showGlobalError('Session Expired', 'Please log in again.');
      get_x.Get.offAllNamed(Routes.login);
    }
  }

  void _showGlobalError(String title, String message) {
    AppSnackbar.showError(
      title: title,
      message: message,
    );
  }
}
