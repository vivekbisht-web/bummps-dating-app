import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

/// A single onboarding slide's content.
class OnboardingSlide {
  const OnboardingSlide({
    required this.image,
    this.textImage = 'assets/images/realPeopleRealMatches.png',
  });

  final String image;
  final String textImage;
}

/// Drives the onboarding carousel: tracks the active page and navigation.
class OnboardingController extends GetxController {
  final RxInt currentPage = 0.obs;

  final List<OnboardingSlide> slides = const [
    OnboardingSlide(
      image: 'assets/images/onboarding_1.png',
      textImage: 'assets/images/realPeopleRealMatches.png',
    ),
    OnboardingSlide(
      image: 'assets/images/onboarding_2.png',
      textImage: 'assets/images/realPeopleRealMatches.png',
    ),
    OnboardingSlide(
      image: 'assets/images/onboarding_3.png',
      textImage: 'assets/images/realPeopleRealMatches.png',
    ),
  ];

  bool get isLastPage => currentPage.value == slides.length - 1;

  void onPageChanged(int index) => currentPage.value = index;

  void getStarted() => Get.toNamed(Routes.signIn);

  void skip() => Get.toNamed(Routes.login);

  void goToLogin() => Get.toNamed(Routes.login);
}
