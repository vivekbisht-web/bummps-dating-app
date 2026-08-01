import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/network/dio_client.dart';
import '../models/login_response.dart';
import '../models/user_profile.dart';

class AuthProvider {
  final DioClient _dioClient;

  AuthProvider(this._dioClient);

  Future<UserProfile> getProfile(String id) async {
    return await _dioClient.get<UserProfile>(
      '${AppConstants.profile}/$id',
      fromJson: (json) {
        if (json is String) {
          return UserProfile.fromJson(jsonDecode(json) as Map<String, dynamic>);
        }
        return UserProfile.fromJson(json as Map<String, dynamic>);
      },
    );
  }

  /// Fetch the discovery feed from the backend.
  /// Handles multiple response shapes:
  ///   - Plain list: [...]
  ///   - Wrapped object: { "users": [...] } | { "profiles": [...] } | { "feed": [...] } | { "data": [...] }
  Future<List<UserProfile>> getFeed({
    int page = 1,
    int limit = 10,
  }) async {
    return await _dioClient.get<List<UserProfile>>(
      AppConstants.feed,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
      fromJson: (json) {
        return _parseUserProfileList(json);
      },
    );
  }

  /// Fetch the confirmed mutual matches list for the current user.
  Future<List<UserProfile>> getMatches() async {
    return await _dioClient.get<List<UserProfile>>(
      AppConstants.matches,
      fromJson: (json) {
        return _parseUserProfileList(json);
      },
    );
  }

  /// Filter discovery feed — POST /api/matches/filter?page=X&limit=X
  /// Body fields match the API spec exactly.
  Future<List<UserProfile>> filterFeed({
    int page = 1,
    int limit = 10,
    String? ageGroup,          // e.g. "25-35"
    int? maxDistance,          // e.g. 25
    List<String>? interests,   // e.g. ["TRAVEL","FINE DINING"]
    List<String>? lifestyle,   // e.g. ["FITNESS"]
    List<String>? languages,   // e.g. ["English"]
    int? minHeight,            // e.g. 160
    int? maxHeight,            // e.g. 190
    bool? isVerified,          // e.g. false
  }) async {
    // Build body — only include non-null fields
    final Map<String, dynamic> body = {};
    if (ageGroup != null)   body['ageGroup']    = ageGroup;
    if (maxDistance != null) body['maxDistance'] = maxDistance;
    if (interests != null && interests.isNotEmpty) body['interests'] = interests;
    if (lifestyle != null && lifestyle.isNotEmpty) body['lifestyle']  = lifestyle;
    if (languages != null && languages.isNotEmpty) body['languages']  = languages;
    if (minHeight != null)  body['minHeight']   = minHeight;
    if (maxHeight != null)  body['maxHeight']   = maxHeight;
    if (isVerified != null) body['isVerified']  = isVerified;

    return await _dioClient.post<List<UserProfile>>(
      AppConstants.filter,
      queryParameters: {'page': page, 'limit': limit},
      data: body,
      fromJson: (json) => _parseUserProfileList(json),
    );
  }


  /// Send a like action — POST /api/matches/like  { "targetUserId": id }
  Future<Map<String, dynamic>> likeUser(String targetUserId) async {
    return await _dioClient.post<Map<String, dynamic>>(
      AppConstants.like,
      data: {'targetUserId': targetUserId},
      fromJson: (json) {
        if (json is Map<String, dynamic>) return json;
        return {};
      },
    );
  }

  /// Send a pass (X/nope) action — POST /api/matches/pass  { "targetUserId": id }
  Future<Map<String, dynamic>> passUser(String targetUserId) async {
    return await _dioClient.post<Map<String, dynamic>>(
      AppConstants.pass,
      data: {'targetUserId': targetUserId},
      fromJson: (json) {
        if (json is Map<String, dynamic>) return json;
        return {};
      },
    );
  }

  /// Rewind last swipe — POST /api/matches/rewind  { "targetUserId": id }
  Future<Map<String, dynamic>> rewindSwipe(String targetUserId) async {
    return await _dioClient.post<Map<String, dynamic>>(
      AppConstants.rewind,
      data: {'targetUserId': targetUserId},
      fromJson: (json) {
        if (json is Map<String, dynamic>) return json;
        return {};
      },
    );
  }

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

  Future<LoginResponse> register({
    required FormData formData,
  }) async {
    return await _dioClient.post<LoginResponse>(
      AppConstants.register,
      data: formData,
      fromJson: (json) {
        if (json is String) {
          return LoginResponse.fromJson(jsonDecode(json) as Map<String, dynamic>);
        }
        return LoginResponse.fromJson(json as Map<String, dynamic>);
      },
      options: Options(
        extra: {'requiresAuth': false},
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helper: robustly parse a backend response into List<UserProfile>
  // Handles:  List | { users/profiles/feed/data: List } | empty
  // ---------------------------------------------------------------------------
  List<UserProfile> _parseUserProfileList(dynamic json) {
    List<dynamic>? rawList;

    if (json is List) {
      rawList = json;
    } else if (json is Map<String, dynamic>) {
      // Try common wrapper keys in order of likelihood
      for (final key in ['users', 'profiles', 'feed', 'data', 'results']) {
        if (json.containsKey(key) && json[key] is List) {
          rawList = json[key] as List<dynamic>;
          break;
        }
      }
      // If still null, look for first list value in the map
      if (rawList == null) {
        for (final val in json.values) {
          if (val is List) {
            rawList = val;
            break;
          }
        }
      }
    } else if (json is String) {
      try {
        final decoded = jsonDecode(json);
        return _parseUserProfileList(decoded);
      } catch (_) {}
    }

    if (rawList == null || rawList.isEmpty) return [];

    return rawList
        .whereType<Map<String, dynamic>>()
        .map((e) => UserProfile.fromJson(e))
        .toList();
  }
}
