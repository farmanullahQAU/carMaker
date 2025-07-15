abstract class Routes {
  Routes._();
  static const home = _Paths.home;
  static const signin = _Paths.signin;

  static const onboarding = _Paths.onboarding;
  static const editor = _Paths.editor;

  static const bottomNavbarView = _Paths.bottomNavbarView;
}

abstract class _Paths {
  _Paths._();
  static const bottomNavbarView = '/';

  static const onboarding = '/onboarding';

  static const home = '/home';
  static const signin = "/signin";
  static const editor = "/editor";
}
