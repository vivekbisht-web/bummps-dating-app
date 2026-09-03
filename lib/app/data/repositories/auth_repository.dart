import 'package:dio/dio.dart';
import '../../core/services/storage/secure_storage_service.dart';
import '../models/login_response.dart';
import '../models/user_profile.dart';
import '../models/subscription_plan.dart';
import '../models/wallet.dart';
import '../models/circle_dashboard.dart';
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

  /// Search user's likes — GET /api/matches/search-likes?query=X
  Future<List<UserProfile>> searchLikes(String query) async {
    return await _authProvider.searchLikes(query);
  }

  /// Get users who liked current user: GET /api/matches/who-liked-me/filter
  Future<dynamic> getWhoLikedMe({
    required String filter,
    int page = 1,
    int limit = 10,
  }) async {
    return await _authProvider.getWhoLikedMe(
      filter: filter,
      page: page,
      limit: limit,
    );
  }

  /// Check who liked me base: GET /api/matches/who-liked-me
  Future<dynamic> checkWhoLikedMe() async {
    return await _authProvider.checkWhoLikedMe();
  }

  /// Get all subscription plans
  Future<List<SubscriptionPlan>> getAllPlans() async {
    return await _authProvider.getAllPlans();
  }

  /// Purchase a subscription plan
  Future<Map<String, dynamic>> subscribe({
    required String planId,
    required String billingCycle,
    String paymentMethod = 'wallet',
  }) async {
    return await _authProvider.subscribe(
      planId: planId,
      billingCycle: billingCycle,
      paymentMethod: paymentMethod,
    );
  }

  /// Fetch user active subscription
  Future<UserSubscription> getMySubscription() async {
    return await _authProvider.getMySubscription();
  }

  // ---------------------------------------------------------------------------
  // Wallet
  // ---------------------------------------------------------------------------

  /// Get wallet balance
  Future<WalletBalance> getWalletBalance() async {
    return await _authProvider.getWalletBalance();
  }

  /// Fetch circle dashboard — GET /api/circle/dashboard
  /// Returns events, trendingDiscussions, memberSpotlight, onlineCircleCount.
  Future<CircleDashboard> getCircleDashboard() async {
    return await _authProvider.getCircleDashboard();
  }

  /// Fetch circle events — GET /api/circle/events
  Future<List<CircleEvent>> getCircleEvents() async {
    return await _authProvider.getCircleEvents();
  }

  /// Fetch all circle discussions — GET /api/circle/discussions
  Future<List<TrendingDiscussion>> getCircleDiscussions() async {
    return await _authProvider.getCircleDiscussions();
  }

  /// Create a circle discussion — POST /api/circle/discussions
    Future<TrendingDiscussion> createDiscussion({
    required String category,
    required String title,
    required String subtitle,
    required bool isNewTag,
  }) async {
    return await _authProvider.createDiscussion(
      category: category,
      title: title,
      subtitle: subtitle,
      isNewTag: isNewTag,
    );
  }

  /// Connect with a circle member — POST /api/circle/connect/:userId
  Future<Map<String, dynamic>> connectWithMember(String userId) async {
    return await _authProvider.connectWithMember(userId);
  }

  /// Register a like swipe against [targetUserId].
  /// Returns the response body which may contain `{ "isMatch": true }`.
  Future<Map<String, dynamic>> likeUser(String targetUserId) async {
    return await _authProvider.likeUser(targetUserId);
  }

  /// Register a super-like swipe against [targetUserId].
  Future<Map<String, dynamic>> superLikeUser(String targetUserId) async {
    return await _authProvider.superLikeUser(targetUserId);
  }

  //boost api
  Future<Map<String, dynamic>> boostProfile () async {
    return _authProvider.boostProfile();
  }

  /// Register a pass (X/nope) swipe against [targetUserId].
  Future<Map<String, dynamic>> passUser(String targetUserId) async {
    return await _authProvider.passUser(targetUserId);
  }

  /// Rewind (undo) the last swipe — sends the last swiped user's ID.
  Future<Map<String, dynamic>> rewindSwipe(String targetUserId) async {
    return await _authProvider.rewindSwipe(targetUserId);
  }

  /// Submit support request: POST /api/auth/help-support
  Future<Map<String, dynamic>> submitHelpSupport({
    required String subject,
    required String category,
    required String message,
  }) async {
    return await _authProvider.submitHelpSupport(
      subject: subject,
      category: category,
      message: message,
    );
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

  Future<UserProfile> updateProfile({
    required FormData formData,
  }) async {
    return await _authProvider.updateProfile(
      formData: formData,
    );
  }
}
