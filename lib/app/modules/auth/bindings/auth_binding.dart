import 'package:get/get.dart';

import '../controllers/login_controller.dart';
import '../controllers/register_controller.dart';

/// Provides the login controller for the sign-in route.
class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
  }
}

/// Provides the register controller for the create-account route.
class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegisterController>(() => RegisterController());
  }
}
