import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/validators.dart';
import '../../../routes/app_pages.dart';

/// Handles the "Join Bummps" create-account form.
class RegisterController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool obscurePassword = true.obs;
  final RxBool isLoading = false.obs;

  String? validateName(String? v) => Validators.name(v);
  String? validateEmail(String? v) => Validators.email(v);
  String? validatePassword(String? v) => Validators.password(v);

  void togglePasswordVisibility() => obscurePassword.toggle();

  Future<void> createAccount() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    Get.toNamed(
      Routes.profileSetup,
      arguments: {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text,
      },
    );
  }

  void continueWithGoogle() => Get.snackbar('Bummps', 'Google sign-up tapped');

  void continueWithApple() => Get.snackbar('Bummps', 'Apple sign-up tapped');

  void goToLogin() {
    if (Get.previousRoute == Routes.login) {
      Get.back();
    } else {
      Get.offNamed(Routes.login);
    }
  }
}
