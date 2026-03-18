// lib/routes/app_routes.dart
import 'package:get/get.dart';
import '../views/main_shell.dart';
import '../views/exercises/exercise_library_view.dart';
import '../views/progress/body_measurements_view.dart';
import '../views/onboarding_view.dart';
import '../views/login_view.dart';
import '../views/signup_view.dart';
import '../views/splash_view.dart';
import '../views/profile_setup_view.dart';
import '../views/workouts/workout_detail_view.dart';
import '../views/workouts/active_workout_view.dart';
import '../views/workouts/workout_history_view.dart';

class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signup = '/signup';
  static const profileSetup = '/profile-setup';
  static const home = '/home'; // MainShell
  // Legacy redirects kept so Get.toNamed still works from deep pages
  static const dashboard = '/home';
  static const workoutDetail = '/workout-detail';
  static const activeWorkout = '/active-workout';
  static const workoutHistory = '/workout-history';
  static const bodyMeasurements = '/body-measurements';

  static final pages = [
    GetPage(name: splash, page: () => const SplashView()),
    GetPage(name: onboarding, page: () => OnboardingView()),
    GetPage(name: login, page: () => LoginView()),
    GetPage(name: signup, page: () => SignupView()),
    GetPage(name: profileSetup, page: () => ProfileSetupView()),
    GetPage(name: home, page: () => const MainShell()),
    GetPage(name: workoutDetail, page: () => WorkoutDetailView()),
    GetPage(name: activeWorkout, page: () => ActiveWorkoutView()),
    GetPage(name: workoutHistory, page: () => WorkoutHistoryView()),
    GetPage(name: bodyMeasurements, page: () => BodyMeasurementsView()),
  ];
}
