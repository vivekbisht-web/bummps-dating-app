class AppConstants {
  AppConstants._();

  static const String baseUrl = 'http://148.66.153.121:5000/api/';   //baseUrl updated
  static const String razorpayKey = 'rzp_test_TE9gEROWqFsafm'; // Razorpay Key ID (Override if backend doesn't send key in payload)

  // Auth Endpoints
  static const String login = 'auth/login';
  static const String register = 'auth/register';
  static const String profile = 'auth/profile';
  static const String helpSupport = 'auth/help-support';

  // Matches Endpoints
  static const String feed = 'matches/feed';
  static const String matches = 'matches/my-matches';
  static const String like = 'matches/like';
  static const String pass = 'matches/pass';
  static const String rewind = 'matches/rewind';
  static const String filter = 'matches/filter';
  static const String searchLikes = 'matches/search-likes';
  static const String whoLikedMe = 'matches/who-liked-me';
  static const String whoLikedMeFilter = 'matches/who-liked-me/filter';
  static const String superLike = 'swipes/super-like';
  static const String boost = 'matches/boost';

  // Plans Endpoints
  static const String allPlans = 'plans/allplans';
  static const String subscribe = 'plans/subscribe';
  static const String subscribeVerify = 'plans/subscribe/verify';
  static const String mySubscription = 'plans/subscription';

  // Wallet Endpoints
  static const String walletCreateOrder = 'plans/wallet/create-order';
  static const String walletVerify = 'plans/wallet/verify';
  static const String walletBalance = 'plans/wallet';

  // Circle Endpoints
  static const String circleDashboard = 'circle/dashboard';
  static const String circleEvents = 'circle/events';
  static const String circleDiscussions = 'circle/discussions';
  static const String circleConnect = 'circle/connect';

}
