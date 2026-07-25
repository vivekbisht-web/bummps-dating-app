import 'package:get/get.dart';

import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_view.dart';

part 'app_routes.dart';

/// Central page registry consumed by [GetMaterialApp.getPages].
class AppPages {
  AppPages._();

  static const initial = Routes.onboarding;

  static final routes = <GetPage>[
    GetPage(
      name: _Paths.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
      transition: Transition.fadeIn,
    ),
  ];
}
