import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/network/dio_exception.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/utils/validators.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_pages.dart';

/// Handles the "Welcome back" sign-in form.
class LoginController extends GetxController {
  final AuthRepository _authRepository;

  LoginController({required AuthRepository authRepository}) : _authRepository = authRepository;

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool obscurePassword = true.obs;
  final RxBool isLoading = false.obs;

  String? validateEmail(String? v) => Validators.email(v);
  String? validatePassword(String? v) => Validators.password(v);

  void togglePasswordVisibility() => obscurePassword.toggle();

  Future<void> continueWithEmail() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      AppSnackbar.showWarning(
        title: 'Form Incomplete',
        message: 'Please fill in a valid email address and password.',
      );
      return;
    }
    
    isLoading.value = true;
    try {
      final response = await _authRepository.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      
      AppSnackbar.showSuccess(
        title: 'Welcome Back',
        message: 'Successfully signed in as ${response.name}',
      );

      // Route to home on successful authentication
      Get.offAllNamed(Routes.home);
    } on ApiException catch (e) {
      final msg = e.message.toLowerCase();
      final isUserNotFound = e.statusCode == 404 ||
          msg.contains('not found') ||
          msg.contains('does not exist') ||
          msg.contains('doesn\'t exist') ||
          msg.contains('no user') ||
          msg.contains('not registered') ||
          msg.contains('unregistered');

      if (isUserNotFound) {
        AppSnackbar.showWarning(
          title: 'Account Not Found',
          message: 'No account exists with this email address. Please register first to get started.',
        );
      } else {
        AppSnackbar.showError(
          title: 'Authentication Failed',
          message: e.message,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('[LoginController] Unexpected error: $e');
      debugPrint('[LoginController] StackTrace: $stackTrace');
      AppSnackbar.showError(
        title: 'Login Error',
        message: 'An unexpected error occurred. Please check your connection and try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void forgotPassword() {
    AppSnackbar.showInfo(
      title: 'Password Reset',
      message: 'Password reset link will be sent to your email soon.',
    );
  }

  void continueWithGoogle() => AppSnackbar.showInfo(
        title: 'Social Sign-In',
        message: 'Google sign-in will be active shortly.',
      );

  void continueWithApple() => AppSnackbar.showInfo(
        title: 'Social Sign-In',
        message: 'Apple sign-in will be active shortly.',
      );

  void goToRegister() => Get.toNamed(Routes.register);
}

