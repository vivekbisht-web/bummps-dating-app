import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/bummps_logo.dart';
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
          // Full-screen swipeable slides (image + scrim + title/subtitle).
          Positioned.fill(
            child: PageView.builder(
              controller: pageController,
              onPageChanged: controller.onPageChanged,
              itemCount: controller.slides.length,
              itemBuilder: (context, index) {
                return _Slide(slide: controller.slides[index]);
              },
            ),
          ),

          // Logo + Skip row at the top.
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
              child: SizedBox(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const BummpsLogo(compact: true),
                    _SkipButton(onTap: controller.skip),
                  ],
                ),
              ),
            ),
          ),

          // Fixed, compact control strip: dots + CTA + login.
          Align(
            alignment: Alignment.bottomCenter,
            child: _BottomControls(pageController: pageController),
          ),
        ],
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({required this.slide});

  final OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          slide.image,
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
              child: Icon(Icons.favorite, color: AppColors.goldDark, size: 64),
            ),
          ),
        ),
        // Gradient scrim: photo dissolves smoothly into solid black at bottom.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.transparent,
                AppColors.background,
              ],
              stops: [0.0, 0.35, 0.78],
            ),
          ),
        ),
        // Title + subtitle sit above the fixed control strip.
        Positioned(
          left: 28,
          right: 28,
          bottom: 210,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: slide.titleLead),
                    TextSpan(
                      text: slide.titleHighlight,
                      style: const TextStyle(color: AppColors.gold),
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
          ),
        ),
      ],
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
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.onGold,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Skip',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomControls extends StatelessWidget {
  const _BottomControls({required this.pageController});

  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
      decoration: const BoxDecoration(color: AppColors.background),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Get Started',
              trailingIcon: Icons.arrow_forward,
              onPressed: controller.getStarted,
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Already have an account? ', style: AppTextStyles.caption),
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
