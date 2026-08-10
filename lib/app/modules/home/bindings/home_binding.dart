import 'package:get/get.dart';

import '../../../core/services/network/dio_client.dart';
import '../../../core/services/storage/secure_storage_service.dart';
import '../../../core/services/socket/socket_service.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/providers/chat_provider.dart';
import '../../../data/repositories/chat_repository.dart';
import '../controllers/home_controller.dart';
import '../controllers/help_support_controller.dart';

/// Provides dependency injection for the home screen flow.
class HomeBinding extends Bindings {
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

    Get.lazyPut<ChatProvider>(() => ChatProvider(Get.find<DioClient>()), fenix: true);
    Get.lazyPut<ChatRepository>(
      () => ChatRepository(
        Get.find<ChatProvider>(),
      ),
      fenix: true,
    );

    Get.lazyPut<SocketService>(() => SocketService(), fenix: true);
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<HelpSupportController>(() => HelpSupportController(), fenix: true);
  }
}
