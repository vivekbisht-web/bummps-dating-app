import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/network/dio_client.dart';

class AuthProvider {
  final DioClient _dioClient;

  AuthProvider(this._dioClient);

  Future<Response> login({
    required String email,
    required String password,
  }) async {
    final response = await _dioClient.post(
      AppConstants.login,
      data: {
        'email': email,
        'password': password,
      },
    );
    return response;
  }
}
