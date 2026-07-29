import 'package:get/get.dart';

import '../../../core/services/network/dio_client.dart';
import '../../../core/services/storage/secure_storage_service.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/repositories/auth_repository.dart';
import '../controllers/login_controller.dart';
import '../controllers/register_controller.dart';

/// Provides the login controller and network/auth dependencies for the sign-in route.
class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // Storage
    Get.lazyPut<SecureStorageService>(() => SecureStorageService(), fenix: true);

    // Register Core/Network dependencies if not already registered
    Get.lazyPut<DioClient>(() => DioClient(Get.find<SecureStorageService>()), fenix: true);
    Get.lazyPut<AuthProvider>(() => AuthProvider(Get.find<DioClient>()), fenix: true);
    Get.lazyPut<AuthRepository>(
      () => AuthRepository(
        Get.find<AuthProvider>(),
        Get.find<SecureStorageService>(),
      ),
      fenix: true,
    );

    // Register login controller
    Get.lazyPut<LoginController>(
      () => LoginController(authRepository: Get.find<AuthRepository>()),
    );
  }
}

/// Provides the register controller for the create-account route.
class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegisterController>(() => RegisterController());
  }
}
