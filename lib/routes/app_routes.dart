import 'package:get/get.dart';
import '../views/splash_view.dart';
import '../views/onboarding_view.dart';
import '../views/login_view.dart';
import '../views/signup_view.dart';
import '../views/dashboard_view.dart';

class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signup = '/signup';
  static const dashboard = '/dashboard';

  static final pages = [
    GetPage(name: splash, page: () => SplashView()),
    GetPage(name: onboarding, page: () => OnboardingView()),
    GetPage(name: login, page: () => LoginView()),
    GetPage(name: signup, page: () => SignupView()),
    GetPage(name: dashboard, page: () => DashboardView()),
  ];
}
