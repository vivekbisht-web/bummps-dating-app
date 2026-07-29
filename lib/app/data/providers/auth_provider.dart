import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/network/dio_client.dart';
import '../models/login_response.dart';

class AuthProvider {
  final DioClient _dioClient;

  AuthProvider(this._dioClient);

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    return await _dioClient.post<LoginResponse>(
      AppConstants.login,
      data: {
        'email': email,
        'password': password,
      },
      // Pass the parser callback with string decoding safety
      fromJson: (json) {
        if (json is String) {
          return LoginResponse.fromJson(jsonDecode(json) as Map<String, dynamic>);
        }
        return LoginResponse.fromJson(json as Map<String, dynamic>);
      },
      // Skip Authorization header because we don't have a token yet
      options: Options(
        extra: {'requiresAuth': false},
      ),
    );
  }
}
