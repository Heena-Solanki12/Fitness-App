import 'package:get/get.dart';
import '../views/exercises/exercise_library_view.dart';
import '../views/progress/body_measurements_view.dart';
import '../views/onboarding_view.dart';
import '../views/login_view.dart';
import '../views/signup_view.dart';
import '../views/dashboard_view.dart';
import '../views/profile_view.dart';
import '../views/splash_view.dart';
import '../views/workouts/workout_library_view.dart';
import '../views/workouts/workout_detail_view.dart';
import '../views/workouts/active_workout_view.dart';
import '../views/workouts/workout_history_view.dart';
import '../views/progress/progress_tracking_view.dart';

class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signup = '/signup';
  static const dashboard = '/dashboard';
  static const profile = '/profile';
  static const workoutLibrary = '/workout-library';
  static const workoutDetail = '/workout-detail';
  static const activeWorkout = '/active-workout';
  static const workoutHistory = '/workout-history';
  static const progressTracking = '/progress-tracking';
  static const exerciseLibrary = '/exercise-library';
  static const bodyMeasurements = '/body-measurements';

  static final pages = [
    GetPage(name: splash, page: () => SplashView()),
    GetPage(name: onboarding, page: () => OnboardingView()),
    GetPage(name: login, page: () => LoginView()),
    GetPage(name: signup, page: () => SignupView()),
    GetPage(name: dashboard, page: () => DashboardView()),
    GetPage(name: profile, page: () => ProfileView()),
    GetPage(name: workoutLibrary, page: () => WorkoutLibraryView()),
    GetPage(name: workoutDetail, page: () => WorkoutDetailView()),
    GetPage(name: activeWorkout, page: () => ActiveWorkoutView()),
    GetPage(name: workoutHistory, page: () => WorkoutHistoryView()),
    GetPage(name: progressTracking, page: () => ProgressTrackingView()),
    GetPage(name: exerciseLibrary, page: () => ExerciseLibraryView()),
    GetPage(name: bodyMeasurements, page: () => BodyMeasurementsView()),
  ];
}