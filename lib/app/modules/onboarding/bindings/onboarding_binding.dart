import 'package:get/get.dart';

import '../controllers/onboarding_controller.dart';

/// Lazily provides the [OnboardingController] to the onboarding view.
class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingController>(() => OnboardingController());
  }
}
