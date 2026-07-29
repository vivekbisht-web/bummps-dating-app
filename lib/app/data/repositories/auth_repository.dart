import '../models/login_response.dart';
import '../providers/auth_provider.dart';

class AuthRepository {
  final AuthProvider _authProvider;

  AuthRepository(this._authProvider);

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _authProvider.login(
      email: email,
      password: password,
    );

    // Parse Response
    if (response.data != null) {
      final loginResponse = LoginResponse.fromJson(response.data);
      
      // TODO: Save token to secure storage / shared preferences
      // e.g., await storage.write('token', loginResponse.token);
      
      return loginResponse;
    } else {
      throw Exception('Failed to parse response data.');
    }
  }
}
