import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as get_x;
import '../../../routes/app_pages.dart';
import '../../constants/app_constants.dart';
import '../../utils/app_snackbar.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../../modules/home/controllers/home_controller.dart';
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

      // Check for subscription expired/required status first (403 Forbidden)
      if (statusCode == 403) {
        final path = err.requestOptions.path;
        if (!path.contains('plans/subscription')) {
          final data = err.response!.data;
          if (data is Map<String, dynamic> && data['requiresSubscription'] == true) {
            final message = data['message']?.toString() ?? 'Your trial or subscription has expired. Please subscribe to a plan to continue.';
            if (get_x.Get.isRegistered<HomeController>()) {
              final homeController = get_x.Get.find<HomeController>();
              homeController.showSubscriptionRequiredDialog(message);
            } else {
              _showSubscriptionRequiredDialogDirectly(message);
            }
            return handler.next(err);
          }
        }
      }

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

  bool _isSubscriptionDialogOpen = false;

  void _showSubscriptionRequiredDialogDirectly(String message) {
    if (_isSubscriptionDialogOpen) return;
    if (get_x.Get.currentRoute == Routes.plans) return;

    _isSubscriptionDialogOpen = true;
    get_x.Get.dialog(
      WillPopScope(
        onWillPop: () async => true, // Allow dismissing via physical back button
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.gold, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Access Suspended',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () {
                _isSubscriptionDialogOpen = false;
                get_x.Get.back(); // Dismiss dialog
              },
              child: Text(
                'CLOSE',
                style: AppTextStyles.button.copyWith(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () {
                _isSubscriptionDialogOpen = false;
                get_x.Get.back(); // Dismiss dialog
                get_x.Get.toNamed(Routes.plans);
              },
              child: Text(
                'VIEW PLANS',
                style: AppTextStyles.button.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: true,
    ).then((_) {
      _isSubscriptionDialogOpen = false;
    });
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
