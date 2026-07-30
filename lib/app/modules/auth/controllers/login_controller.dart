import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/network/dio_exception.dart';
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
    if (!(formKey.currentState?.validate() ?? false)) return;
    isLoading.value = true;
    try {
      final response = await _authRepository.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      
      Get.snackbar(
        'Success',
        'Signed in as ${response.name}',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Route to profileSetup or home on successful authentication
      Get.offAllNamed(Routes.home);
    } on ApiException catch (e) {
      Get.snackbar(
        'Authentication Failed',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e, stackTrace) {
      debugPrint('[LoginController] Unexpected error: $e');
      debugPrint('[LoginController] StackTrace: $stackTrace');
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void forgotPassword() {
    Get.snackbar('Bummps', 'Password reset flow coming soon');
  }

  void continueWithGoogle() => Get.snackbar('Bummps', 'Google sign-in tapped');

  void continueWithApple() => Get.snackbar('Bummps', 'Apple sign-in tapped');

  void goToRegister() => Get.toNamed(Routes.register);

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
