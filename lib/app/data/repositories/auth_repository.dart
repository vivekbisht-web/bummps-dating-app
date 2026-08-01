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

  /// Discovery feed — profiles the current user hasn't swiped on yet.
  Future<List<UserProfile>> getFeed({int page = 1, int limit = 10}) async {
    return await _authProvider.getFeed(page: page, limit: limit);
  }

  /// Confirmed mutual matches for the current user.
  Future<List<UserProfile>> getMatches() async {
    return await _authProvider.getMatches();
  }

  /// Filtered discovery feed — POST /api/matches/filter
  Future<List<UserProfile>> filterFeed({
    int page = 1,
    int limit = 10,
    String? ageGroup,
    int? maxDistance,
    List<String>? interests,
    List<String>? lifestyle,
    List<String>? languages,
    int? minHeight,
    int? maxHeight,
    bool? isVerified,
  }) async {
    return await _authProvider.filterFeed(
      page: page,
      limit: limit,
      ageGroup: ageGroup,
      maxDistance: maxDistance,
      interests: interests,
      lifestyle: lifestyle,
      languages: languages,
      minHeight: minHeight,
      maxHeight: maxHeight,
      isVerified: isVerified,
    );
  }


  /// Register a like swipe against [targetUserId].
  /// Returns the response body which may contain `{ "isMatch": true }`.
  Future<Map<String, dynamic>> likeUser(String targetUserId) async {
    return await _authProvider.likeUser(targetUserId);
  }

  /// Register a pass (X/nope) swipe against [targetUserId].
  Future<Map<String, dynamic>> passUser(String targetUserId) async {
    return await _authProvider.passUser(targetUserId);
  }

  /// Rewind (undo) the last swipe — sends the last swiped user's ID.
  Future<Map<String, dynamic>> rewindSwipe(String targetUserId) async {
    return await _authProvider.rewindSwipe(targetUserId);
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
