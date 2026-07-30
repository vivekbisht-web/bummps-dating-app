import 'package:dio/dio.dart';
import '../../core/services/storage/secure_storage_service.dart';
import '../models/login_response.dart';
import '../models/user_profile.dart';
import '../providers/auth_provider.dart';

class AuthRepository {
  final AuthProvider _authProvider;
  final SecureStorageService _secureStorageService;

  AuthRepository(this._authProvider, this._secureStorageService);

  Future<UserProfile> getProfile(String id) async {
    return await _authProvider.getProfile(id);
  }

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    // Perform API call
    final loginResponse = await _authProvider.login(
      email: email,
      password: password,
    );

    // Save tokens securely to device storage
    await _secureStorageService.saveToken(loginResponse.token);
    await _secureStorageService.saveUserId(loginResponse.id);
    
    // If the API returns a refresh token in the future, save it here as well
    // await _secureStorageService.saveRefreshToken(loginResponse.refreshToken);

    return loginResponse;
  }

  Future<LoginResponse> register({
    required FormData formData,
  }) async {
    // Perform API call
    final loginResponse = await _authProvider.register(
      formData: formData,
    );

    // Save tokens securely to device storage
    await _secureStorageService.saveToken(loginResponse.token);
    await _secureStorageService.saveUserId(loginResponse.id);

    return loginResponse;
  }
}
