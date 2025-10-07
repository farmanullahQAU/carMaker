abstract class Routes {
  Routes._();

  static const splash = _Paths.splash;

  static const home = _Paths.home;
  static const auth = _Paths.auth;

  static const onboarding = _Paths.onboarding;
  static const editor = _Paths.editor;

  static const categoryTemplates = _Paths.categoryTemplates;
  static const accountDeletion = _Paths.accountDeletion;
  static const webLanding = _Paths.webLanding;
}

abstract class _Paths {
  _Paths._();
  static const splash = '/';

  static const onboarding = '/onboarding';
  static const accountDeletion = '/delete-account';
  static const webLanding = '/homes';

  static const home = '/home';
  static const auth = "/auth";
  static const editor = "/editor";
  static const String categoryTemplates = '/category-templates';
}
