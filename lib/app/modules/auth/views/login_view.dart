import 'package:bummps/app/core/widgets/bummps_logo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/auth_text_field.dart';
import '../../../core/widgets/labeled_divider.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/social_button.dart';
import '../controllers/login_controller.dart';
import '../widgets/auth_segmented_toggle.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              const BummpsLogo(),
              const SizedBox(height: 24),
              Text('Welcome back', style: AppTextStyles.displayLarge),
              const SizedBox(height: 8),
              Text(
                'Connect with souls that resonate with your energy.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 28),
              _AuthCard(controller: controller),
              const SizedBox(height: 24),
              Text.rich(
                TextSpan(
                  style: AppTextStyles.caption,
                  children: [
                    const TextSpan(text: 'By continuing, you agree to our '),
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(color: AppColors.gold),
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(color: AppColors.gold),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const _TrustFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({required this.controller});

  final LoginController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthSegmentedToggle(
              leftLabel: 'Sign In',
              rightLabel: 'Create Account',
              leftSelected: true,
              onLeft: () {},
              onRight: controller.goToRegister,
            ),
            const SizedBox(height: 20),
            AuthTextField(
              label: 'Email Address',
              hint: 'name@example.com',
              controller: controller.emailController,
              prefixIcon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: controller.validateEmail,
            ),
            const SizedBox(height: 16),
            Obx(
                  () => AuthTextField(
                label: 'Password',
                hint: '••••••••',
                controller: controller.passwordController,
                prefixIcon: Icons.lock_outline,
                obscureText: controller.obscurePassword.value,
                isObscured: controller.obscurePassword.value,
                onToggleObscure: controller.togglePasswordVisibility,
                textInputAction: TextInputAction.done,
                validator: controller.validatePassword,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: controller.forgotPassword,
                child: Text(
                  'Forgot password?',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Obx(
                  () => PrimaryButton(
                label: controller.isLoading.value
                    ? 'Please wait...'
                    : 'Continue with Email',
                onPressed: controller.isLoading.value
                    ? () {}
                    : controller.continueWithEmail,
              ),
            ),
            const SizedBox(height: 20),
            const LabeledDivider(label: 'or'),
            const SizedBox(height: 20),
            SocialButton(
              label: 'Continue with Google',
              icon: const GoogleGlyph(),
              onPressed: controller.continueWithGoogle,
            ),
            const SizedBox(height: 12),
            SocialButton(
              label: 'Continue with Apple',
              light: true,
              icon: const Icon(Icons.apple, color: AppColors.background),
              onPressed: controller.continueWithApple,
            ),
          ],
        ),
      ),
    );
  }
}

class _TrustFooter extends StatelessWidget {
  const _TrustFooter();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.shield_outlined, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Text('Secure Encryption', style: AppTextStyles.caption),
        const SizedBox(width: 16),
        Icon(Icons.lock_outline, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Text('Privacy Guaranteed', style: AppTextStyles.caption),
      ],
    );
  }
}