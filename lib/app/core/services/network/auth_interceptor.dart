import 'package:dio/dio.dart';
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
              homeController.setSubscriptionInactive(message);
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
        onWillPop: () async {
          _isSubscriptionDialogOpen = false;
          return true;
        },
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF141311),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.gold.withOpacity(0.4), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withOpacity(0.12),
                  blurRadius: 24,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.8),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Glowing crown icon badge
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF3D2C13),
                        Color(0xFF1E170A),
                      ],
                    ),
                    border: Border.all(color: AppColors.gold, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withOpacity(0.25),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: AppColors.gold,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 18),

                // Title
                Text(
                  'Subscription Expired',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),

                // Message
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.8),
                    height: 1.4,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    // Close Button
                    Expanded(
                      flex: 2,
                      child: TextButton(
                        onPressed: () {
                          _isSubscriptionDialogOpen = false;
                          get_x.Get.back();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: Colors.white.withOpacity(0.15)),
                          ),
                        ),
                        child: Text(
                          'LATER',
                          style: AppTextStyles.button.copyWith(
                            color: Colors.white60,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // View Plans CTA
                    Expanded(
                      flex: 3,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: Colors.black,
                          elevation: 4,
                          shadowColor: AppColors.gold.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          _isSubscriptionDialogOpen = false;
                          get_x.Get.back();
                          get_x.Get.toNamed(Routes.plans);
                        },
                        child: const Text(
                          'VIEW PLANS',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
