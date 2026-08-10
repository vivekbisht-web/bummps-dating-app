part of 'app_pages.dart';

/// Named route constants. Reference these instead of raw strings.
abstract class Routes {
  Routes._();

  static const onboarding = _Paths.onboarding;
  static const signIn = _Paths.signIn;
  static const login = _Paths.login;
  static const register = _Paths.register;
  static const profileSetup = _Paths.profileSetup;
  static const home = _Paths.home;
  static const chatDetail = _Paths.chatDetail;
  static const likedHistory = _Paths.likedHistory;
  static const plans = _Paths.plans;
  static const helpSupport = _Paths.helpSupport;
}

abstract class _Paths {
  _Paths._();

  static const onboarding = '/onboarding';
  static const signIn = '/sign-in';
  static const login = '/login';
  static const register = '/register';
  static const profileSetup = '/profile-setup';
  static const home = '/home';
  static const chatDetail = '/chat-detail';
  static const likedHistory = '/liked-history';
  static const plans = '/plans';
  static const helpSupport = '/help-support';
}
