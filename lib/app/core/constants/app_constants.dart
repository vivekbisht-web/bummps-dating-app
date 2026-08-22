class AppConstants {
  AppConstants._();

  static const String baseUrl = 'https://datingapp-oz22.onrender.com/api/';

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
  static const String mySubscription = 'plans/subscription';

  // Circle Endpoints
  static const String circleDashboard = 'circle/dashboard';
  static const String circleEvents = 'circle/events';
  static const String circleDiscussions = 'circle/discussions';
  static const String circleConnect = 'circle/connect';

}
