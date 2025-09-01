abstract class Routes {
  Routes._();
  static const home = _Paths.home;
  static const auth = _Paths.auth;

  static const onboarding = _Paths.onboarding;
  static const editor = _Paths.editor;

  static const bottomNavbarView = _Paths.bottomNavbarView;
  static const categoryTemplates = _Paths.categoryTemplates;
}

abstract class _Paths {
  _Paths._();
  static const bottomNavbarView = '/';

  static const onboarding = '/onboarding';

  static const home = '/home';
  static const auth = "/auth";
  static const editor = "/editor";
  static const String categoryTemplates = '/category-templates';
}
