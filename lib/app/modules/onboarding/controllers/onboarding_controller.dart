import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

/// A single onboarding slide's content.
class OnboardingSlide {
  const OnboardingSlide({
    required this.image,
    required this.titleLead,
    required this.titleHighlight,
    required this.titleTrail,
    required this.subtitle,
  });

  final String image;
  final String titleLead;
  final String titleHighlight;
  final String titleTrail;
  final String subtitle;
}

/// Drives the onboarding carousel: tracks the active page and navigation.
class OnboardingController extends GetxController {
  final RxInt currentPage = 0.obs;

  final List<OnboardingSlide> slides = const [
    OnboardingSlide(
      image: 'assets/images/onboarding_1.png',
      titleLead: 'Find your ',
      titleHighlight: 'perfect',
      titleTrail: ' match',
      subtitle:
          'Discover meaningful connections built on shared values and genuine chemistry.',
    ),
    OnboardingSlide(
      image: 'assets/images/onboarding_2.png',
      titleLead: 'Spark real ',
      titleHighlight: 'conversations',
      titleTrail: '',
      subtitle:
          'Break the ice with prompts designed to reveal who people really are.',
    ),
    OnboardingSlide(
      image: 'assets/images/onboarding_3.png',
      titleLead: 'Date with ',
      titleHighlight: 'confidence',
      titleTrail: '',
      subtitle:
          'Verified profiles and thoughtful matching keep every connection safe.',
    ),
  ];

  bool get isLastPage => currentPage.value == slides.length - 1;

  void onPageChanged(int index) => currentPage.value = index;

  void getStarted() => Get.toNamed(Routes.signIn);

  void skip() => Get.toNamed(Routes.login);

  void goToLogin() => Get.toNamed(Routes.login);
}
