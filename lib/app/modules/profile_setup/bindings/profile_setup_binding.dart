import 'package:get/get.dart';

import '../../../core/services/network/dio_client.dart';
import '../../../core/services/storage/secure_storage_service.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/repositories/auth_repository.dart';
import '../controllers/profile_setup_controller.dart';

/// Provides the [ProfileSetupController] to the wizard route.
class ProfileSetupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SecureStorageService>(() => SecureStorageService(), fenix: true);
    Get.lazyPut<DioClient>(() => DioClient(Get.find<SecureStorageService>()), fenix: true);
    Get.lazyPut<AuthProvider>(() => AuthProvider(Get.find<DioClient>()), fenix: true);
    Get.lazyPut<AuthRepository>(
      () => AuthRepository(
        Get.find<AuthProvider>(),
        Get.find<SecureStorageService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<ProfileSetupController>(() => ProfileSetupController());
  }
}
