import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/validators.dart';
import '../../../routes/app_pages.dart';

/// Handles the "Welcome back" sign-in form.
class LoginController extends GetxController {
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
    // TODO: replace with real auth service call.
    await Future.delayed(const Duration(milliseconds: 900));
    isLoading.value = false;
    Get.snackbar('Bummps', 'Signed in as ${emailController.text.trim()}');
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
