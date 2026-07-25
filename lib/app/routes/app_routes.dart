part of 'app_pages.dart';

/// Named route constants. Reference these instead of raw strings.
abstract class Routes {
  Routes._();

  static const onboarding = _Paths.onboarding;
  static const login = _Paths.login;
  static const register = _Paths.register;
  static const home = _Paths.home;
}

abstract class _Paths {
  _Paths._();

  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
}
