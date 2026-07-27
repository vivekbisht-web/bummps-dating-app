import 'package:get/get.dart';

import '../controllers/profile_setup_controller.dart';

/// Provides the [ProfileSetupController] to the wizard route.
class ProfileSetupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileSetupController>(() => ProfileSetupController());
  }
}
