import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controllers/profile_setup_controller.dart';
import 'steps/about_you_step.dart';
import 'steps/basic_info_step.dart';
import 'steps/photos_step.dart';
import 'steps/preferences_step.dart';
import 'steps/preview_step.dart';
import 'steps/verification_step.dart';

class ProfileScreen extends GetView<ProfileSetupController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leadingWidth: 90,
        leading: GestureDetector(
          onTap: controller.back,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Image.asset(
              'assets/images/bummps-icon.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Image.asset(
          'assets/images/bummps..png',
          height: 18,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() => Text(
                            'STEP ${controller.currentStep.value + 1} OF ${ProfileSetupController.totalSteps}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.gold,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                            ),
                          )),
                      Obx(() => Text(
                            '${controller.percent}% Complete',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          )),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Obx(() => ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: controller.progress,
                          minHeight: 4,
                          backgroundColor: AppColors.divider,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.gold),
                        ),
                      )),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: controller.pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => controller.currentStep.value = index,
                children: [
                  BasicInfoStep(controller: controller),
                  AboutYouStep(controller: controller),
                  PhotosStep(controller: controller),
                  PreferencesStep(controller: controller),
                  PreviewStep(controller: controller),
                  VerificationStep(controller: controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}