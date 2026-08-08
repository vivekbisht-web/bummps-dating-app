import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Notification variant type for standardizing alert styling.
enum SnackbarType { success, error, warning, info }

/// Custom, theme-matched Snackbar service for the Bummps app.
///
/// Designed to reflect the "Midnight Gilded" dark luxury design system
/// across all screens and notification triggers.
class AppSnackbar {
  AppSnackbar._();

  /// Displays a success snackbar with gold accent styling.
  static void showSuccess({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 4),
    SnackPosition position = SnackPosition.BOTTOM,
  }) {
    show(
      title: title,
      message: message,
      type: SnackbarType.success,
      duration: duration,
      position: position,
    );
  }

  /// Displays an error snackbar with red error accent styling.
  static void showError({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 4),
    SnackPosition position = SnackPosition.BOTTOM,
  }) {
    show(
      title: title,
      message: message,
      type: SnackbarType.error,
      duration: duration,
      position: position,
    );
  }

  /// Displays a warning snackbar with amber accent styling.
  static void showWarning({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 4),
    SnackPosition position = SnackPosition.BOTTOM,
  }) {
    show(
      title: title,
      message: message,
      type: SnackbarType.warning,
      duration: duration,
      position: position,
    );
  }

  /// Displays an info snackbar with light gold accent styling.
  static void showInfo({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 4),
    SnackPosition position = SnackPosition.BOTTOM,
  }) {
    show(
      title: title,
      message: message,
      type: SnackbarType.info,
      duration: duration,
      position: position,
    );
  }

  /// Core presenter method for generating custom floating snackbar cards.
  static void show({
    required String title,
    required String message,
    required SnackbarType type,
    Duration duration = const Duration(seconds: 4),
    SnackPosition position = SnackPosition.BOTTOM,
  }) {
    // Dismiss active snackbars to prevent overlapping/queued cards
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    Color accentColor;
    IconData iconData;
    Color iconBgColor;

    switch (type) {
      case SnackbarType.success:
        accentColor = AppColors.gold;
        iconData = Icons.check_circle_rounded;
        iconBgColor = AppColors.gold.withOpacity(0.15);
        break;
      case SnackbarType.error:
        accentColor = AppColors.error;
        iconData = Icons.error_outline_rounded;
        iconBgColor = AppColors.error.withOpacity(0.15);
        break;
      case SnackbarType.warning:
        accentColor = const Color(0xFFF5A623); // Warm luxury amber
        iconData = Icons.warning_amber_rounded;
        iconBgColor = const Color(0xFFF5A623).withOpacity(0.15);
        break;
      case SnackbarType.info:
        accentColor = AppColors.goldLight;
        iconData = Icons.info_outline_rounded;
        iconBgColor = AppColors.goldLight.withOpacity(0.15);
        break;
    }

    Get.rawSnackbar(
      snackPosition: position,
      duration: duration,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: 16,
      backgroundColor: AppColors.surfaceElevated,
      borderWidth: 1.2,
      borderColor: accentColor.withOpacity(0.5),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.5),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: accentColor.withOpacity(0.1),
          blurRadius: 12,
          offset: const Offset(0, 0),
        ),
      ],
      titleText: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
      messageText: Text(
        message,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
          fontSize: 13,
          height: 1.35,
        ),
      ),
      icon: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconBgColor,
          shape: BoxShape.circle,
          border: Border.all(color: accentColor.withOpacity(0.3), width: 1),
        ),
        child: Icon(
          iconData,
          color: accentColor,
          size: 22,
        ),
      ),
      shouldIconPulse: false,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
    );
  }
}
