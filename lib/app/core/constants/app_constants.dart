class AppConstants {
  AppConstants._();

  static const String baseUrl = 'https://datingapp-oz22.onrender.com/api/';

  // Auth Endpoints
  static const String login = 'auth/login';
  static const String register = 'auth/register';
  static const String profile = 'auth/profile';

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

  // Plans Endpoints
  static const String allPlans = 'plans/allplans';
  static const String subscribe = 'plans/subscribe';
  static const String mySubscription = 'plans/my-subscription';
}
