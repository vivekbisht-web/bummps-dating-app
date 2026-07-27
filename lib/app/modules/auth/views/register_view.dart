import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/auth_text_field.dart';
import '../../../core/widgets/labeled_divider.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/social_button.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leadingWidth: 90,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: Get.back,
            ),
            Image.asset(
              'assets/images/bummps-icon.png',
              height: 24,
              fit: BoxFit.contain,
            ),
          ],
        ),
        title: Image.asset(
          'assets/images/bummps..png',
          height: 18,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.divider),
            ),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Join Bummps',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headlineMedium
                        .copyWith(color: AppColors.gold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Begin your journey to meaningful connections.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  AuthTextField(
                    label: 'Full Name',
                    hint: 'Alexander Sterling',
                    controller: controller.nameController,
                    prefixIcon: Icons.person_outline,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    validator: controller.validateName,
                  ),
                  const SizedBox(height: 18),
                  AuthTextField(
                    label: 'Email Address',
                    hint: 'alexander@luxury.com',
                    controller: controller.emailController,
                    prefixIcon: Icons.alternate_email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: controller.validateEmail,
                  ),
                  const SizedBox(height: 18),
                  Obx(
                    () => AuthTextField(
                      label: 'Password',
                      hint: '••••••••••••',
                      controller: controller.passwordController,
                      prefixIcon: Icons.lock_outline,
                      obscureText: controller.obscurePassword.value,
                      isObscured: controller.obscurePassword.value,
                      onToggleObscure: controller.togglePasswordVisibility,
                      textInputAction: TextInputAction.done,
                      validator: controller.validatePassword,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Obx(
                    () => PrimaryButton(
                      label: controller.isLoading.value
                          ? 'Please wait...'
                          : 'Create Account',
                      trailingIcon: controller.isLoading.value
                          ? null
                          : Icons.arrow_forward,
                      onPressed: controller.isLoading.value
                          ? () {}
                          : controller.createAccount,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const LabeledDivider(label: 'or continue with'),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: SocialButton(
                          label: 'Google',
                          icon: const GoogleGlyph(),
                          onPressed: controller.continueWithGoogle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SocialButton(
                          label: 'Apple',
                          icon: const Icon(Icons.apple,
                              color: AppColors.textPrimary),
                          onPressed: controller.continueWithApple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account? ',
                          style: AppTextStyles.caption),
                      GestureDetector(
                        onTap: controller.goToLogin,
                        child: Text(
                          'Sign In',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.gold,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text.rich(
                    TextSpan(
                      style: AppTextStyles.caption,
                      children: [
                        const TextSpan(
                            text: 'By creating an account, you agree to our '),
                        TextSpan(
                          text: 'Terms of Service',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
