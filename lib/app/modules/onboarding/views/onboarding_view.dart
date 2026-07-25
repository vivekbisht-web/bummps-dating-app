import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final pageController = PageController();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Hero image carousel filling the upper portion of the screen.
          Positioned.fill(
            child: PageView.builder(
              controller: pageController,
              onPageChanged: controller.onPageChanged,
              itemCount: controller.slides.length,
              itemBuilder: (context, index) {
                return _HeroImage(image: controller.slides[index].image);
              },
            ),
          ),

          // Logo + Skip row at the top.
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Logo(),
                  _SkipButton(onTap: controller.skip),
                ],
              ),
            ),
          ),

          // Bottom content sheet with title, subtitle, dots and CTAs.
          Align(
            alignment: Alignment.bottomCenter,
            child: _BottomSheetContent(pageController: pageController),
          ),
        ],
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.image});

  final String image;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          image,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.surfaceElevated, AppColors.background],
              ),
            ),
            child: const Center(
              child: Icon(Icons.favorite,
                  color: AppColors.goldDark, size: 64),
            ),
          ),
        ),
        // Scrim so text stays legible against the photo.
        const DecoratedBox(
          decoration: BoxDecoration(gradient: AppColors.heroScrim),
        ),
      ],
    );
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'bummps.',
        style: AppTextStyles.titleMedium.copyWith(
          color: AppColors.background,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.gold,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Skip',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onGold,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomSheetContent extends StatelessWidget {
  const _BottomSheetContent({required this.pageController});

  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Obx(() {
              final slide = controller.slides[controller.currentPage.value];
              return Column(
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: slide.titleLead),
                        TextSpan(
                          text: slide.titleHighlight,
                          style: TextStyle(color: AppColors.gold),
                        ),
                        TextSpan(text: slide.titleTrail),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.displayLarge,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    slide.subtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              );
            }),
            const SizedBox(height: 24),
            SmoothPageIndicator(
              controller: pageController,
              count: controller.slides.length,
              effect: const ExpandingDotsEffect(
                dotHeight: 8,
                dotWidth: 8,
                spacing: 6,
                expansionFactor: 3,
                activeDotColor: AppColors.gold,
                dotColor: AppColors.inactiveDot,
              ),
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: 'Get Started',
              trailingIcon: Icons.arrow_forward,
              onPressed: controller.getStarted,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Already have an account? ',
                    style: AppTextStyles.caption),
                GestureDetector(
                  onTap: controller.goToLogin,
                  child: Text(
                    'Log in',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
