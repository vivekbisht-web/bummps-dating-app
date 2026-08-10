import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/network/dio_client.dart';
import '../models/login_response.dart';
import '../models/user_profile.dart';
import '../models/subscription_plan.dart';
import '../models/circle_dashboard.dart';

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

  /// Search user's likes — GET /api/matches/search-likes?query=X
  Future<List<UserProfile>> searchLikes(String query) async {
    return await _dioClient.get<List<UserProfile>>(
      AppConstants.searchLikes,
      queryParameters: {
        'query': query,
      },
      fromJson: (json) {
        return _parseUserProfileList(json);
      },
    );
  }

  /// Get users who liked current user: GET /api/matches/who-liked-me/filter?filter=all&page=1&limit=10
  Future<dynamic> getWhoLikedMe({
    required String filter,
    int page = 1,
    int limit = 10,
  }) async {
    return await _dioClient.get<dynamic>(
      AppConstants.whoLikedMeFilter,
      queryParameters: {
        'filter': filter,
        'page': page,
        'limit': limit,
      },
      fromJson: (json) => json,
    );
  }

  /// Check who liked me: GET /api/matches/who-liked-me
  Future<dynamic> checkWhoLikedMe() async {
    return await _dioClient.get<dynamic>(
      AppConstants.whoLikedMe,
      fromJson: (json) => json,
    );
  }

  /// Get all subscription plans: GET /api/plans/allplans
  Future<List<SubscriptionPlan>> getAllPlans() async {
    return await _dioClient.get<List<SubscriptionPlan>>(
      AppConstants.allPlans,
      fromJson: (json) {
        List<dynamic>? list;
        if (json is List) {
          list = json;
        } else if (json is Map && json.containsKey('plans') && json['plans'] is List) {
          list = json['plans'] as List<dynamic>;
        }
        if (list == null || list.isEmpty) return [];
        return list
            .whereType<Map<String, dynamic>>()
            .map((e) => SubscriptionPlan.fromJson(e))
            .toList();
      },
    );
  }

  /// Purchase a subscription plan: POST /api/plans/subscribe
  Future<Map<String, dynamic>> subscribe({
    required String planId,
    required String billingCycle,
  }) async {
    return await _dioClient.post<Map<String, dynamic>>(
      AppConstants.subscribe,
      data: {
        'planId': planId,
        'billingCycle': billingCycle,
      },
      fromJson: (json) {
        if (json is Map<String, dynamic>) return json;
        return {};
      },
    );
  }

  /// Fetch user active subscription: GET /api/plans/my-subscription
  Future<UserSubscription> getMySubscription() async {
    return await _dioClient.get<UserSubscription>(
      AppConstants.mySubscription,
      fromJson: (json) {
        if (json is Map<String, dynamic>) {
          return UserSubscription.fromJson(json);
        }
        return UserSubscription(hasActiveSubscription: false, isActive: false);
      },
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

  /// Send a super-like action — POST /api/swipes/super-like  { "targetUserId": id }
  Future<Map<String, dynamic>> superLikeUser(String targetUserId) async {
    return await _dioClient.post<Map<String, dynamic>>(
      AppConstants.superLike,
      data: {'targetUserId': targetUserId},
      fromJson: (json) {
        if (json is Map<String, dynamic>) return json;
        return {};
      },
    );
  }

  Future<Map<String, dynamic>> boostProfile() async{
    return await _dioClient.post<Map<String, dynamic>>(
      AppConstants.boost,
        fromJson: (json) {
          if (json is Map<String, dynamic>) return json;
          return{};
        }
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

  /// Submit support request: POST /api/auth/help-support
  Future<Map<String, dynamic>> submitHelpSupport({
    required String subject,
    required String category,
    required String message,
  }) async {
    return await _dioClient.post<Map<String, dynamic>>(
      AppConstants.helpSupport,
      data: {
        'subject': subject,
        'category': category,
        'message': message,
      },
      fromJson: (json) {
        if (json is Map<String, dynamic>) return json;
        if (json is String) {
          try {
            return jsonDecode(json) as Map<String, dynamic>;
          } catch (_) {}
        }
        return {};
      },
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
  // Circle Endpoints
  // ---------------------------------------------------------------------------

  /// Fetch circle dashboard — GET /api/circle/dashboard
  /// Returns events, trendingDiscussions, memberSpotlight, onlineCircleCount.
  Future<CircleDashboard> getCircleDashboard() async {
    return await _dioClient.get<CircleDashboard>(
      AppConstants.circleDashboard,
      fromJson: (json) {
        // The API wraps the payload inside a "data" key:
        // { "success": true, "data": { ... } }
        final Map<String, dynamic> dataMap;
        if (json is Map<String, dynamic> && json.containsKey('data')) {
          dataMap = json['data'] as Map<String, dynamic>;
        } else if (json is Map<String, dynamic>) {
          dataMap = json;
        } else if (json is String) {
          final decoded = jsonDecode(json) as Map<String, dynamic>;
          dataMap = decoded.containsKey('data')
              ? decoded['data'] as Map<String, dynamic>
              : decoded;
        } else {
          dataMap = {};
        }
        return CircleDashboard.fromJson(dataMap);
      },
    );
  }

  /// Fetch circle events — GET /api/circle/events
  /// Returns { "success": true, "data": [ ... ] }
  Future<List<CircleEvent>> getCircleEvents() async {
    return await _dioClient.get<List<CircleEvent>>(
      AppConstants.circleEvents,
      fromJson: (json) {
        List<dynamic>? list;
        if (json is Map<String, dynamic> && json.containsKey('data') && json['data'] is List) {
          list = json['data'] as List<dynamic>;
        } else if (json is List) {
          list = json;
        } else if (json is String) {
          final decoded = jsonDecode(json);
          if (decoded is Map<String, dynamic> && decoded.containsKey('data') && decoded['data'] is List) {
            list = decoded['data'] as List<dynamic>;
          } else if (decoded is List) {
            list = decoded;
          }
        }
        if (list == null || list.isEmpty) return [];
        return list
            .whereType<Map<String, dynamic>>()
            .map((e) => CircleEvent.fromJson(e))
            .toList();
      },
    );
  }

  /// Create a circle discussion — POST /api/circle/discussions
  /// Body: { category, title, subtitle, isNewTag }
  /// Returns { "success": true, "data": { ... } }
  Future<TrendingDiscussion> createDiscussion({
    required String category,
    required String title,
    required String subtitle,
    required bool isNewTag,
  }) async {
    return await _dioClient.post<TrendingDiscussion>(
      AppConstants.circleDiscussions,
      data: {
        'category': category,
        'title': title,
        'subtitle': subtitle,
        'isNewTag': isNewTag,
      },
      fromJson: (json) {
        Map<String, dynamic> dataMap;
        if (json is Map<String, dynamic> && json.containsKey('data') && json['data'] is Map) {
          dataMap = json['data'] as Map<String, dynamic>;
        } else if (json is Map<String, dynamic>) {
          dataMap = json;
        } else if (json is String) {
          final decoded = jsonDecode(json) as Map<String, dynamic>;
          dataMap = decoded.containsKey('data')
              ? decoded['data'] as Map<String, dynamic>
              : decoded;
        } else {
          dataMap = {};
        }
        return TrendingDiscussion.fromJson(dataMap);
      },
    );
  }

  /// Fetch all circle discussions — GET /api/circle/discussions
  /// Returns { "success": true, "data": [ ... ] }
  Future<List<TrendingDiscussion>> getCircleDiscussions() async {
    return await _dioClient.get<List<TrendingDiscussion>>(
      AppConstants.circleDiscussions,
      fromJson: (json) {
        List<dynamic>? list;
        if (json is Map<String, dynamic> && json.containsKey('data') && json['data'] is List) {
          list = json['data'] as List<dynamic>;
        } else if (json is List) {
          list = json;
        } else if (json is String) {
          final decoded = jsonDecode(json);
          if (decoded is Map<String, dynamic> && decoded.containsKey('data') && decoded['data'] is List) {
            list = decoded['data'] as List<dynamic>;
          } else if (decoded is List) {
            list = decoded;
          }
        }
        if (list == null || list.isEmpty) return [];
        return list
            .whereType<Map<String, dynamic>>()
            .map((e) => TrendingDiscussion.fromJson(e))
            .toList();
      },
    );
  }

  /// Connect with a circle member — POST /api/circle/connect/:userId
  Future<Map<String, dynamic>> connectWithMember(String userId) async {
    return await _dioClient.post<Map<String, dynamic>>(
      '${AppConstants.circleConnect}/$userId',
      fromJson: (json) {
        if (json is Map<String, dynamic>) return json;
        return {};
      },
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
