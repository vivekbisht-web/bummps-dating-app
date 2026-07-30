import 'package:get/get.dart';

import '../controllers/home_controller.dart';

/// Provides dependency injection for the home screen flow.
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
