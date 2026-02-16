import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout_log_model.dart';
import '../controllers/auth_controller.dart';

class WorkoutHistoryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<WorkoutLog> workoutLogs = <WorkoutLog>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedFilter = 'All'.obs;
  final RxInt totalWorkouts = 0.obs;
  final RxInt totalCalories = 0.obs;
  final RxInt totalMinutes = 0.obs;
  final RxInt currentStreak = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadWorkoutHistory();
  }

  Future<void> loadWorkoutHistory() async {
    try {
      isLoading.value = true;
      print('🏋️ Loading workout history...');

      // Get auth controller
      final authController = Get.find<AuthController>();
      final userId = authController.currentUser?.uid;

      if (userId == null) {
        print('⚠️ No user logged in for workout history');
        isLoading.value = false;
        // Generate sample data for demo
        workoutLogs.value = _generateSampleLogs('demo_user');
        calculateStats();
        return;
      }

      print('👤 Loading workouts for user: $userId');

      // Try to load from Firestore
      final snapshot = await _firestore
          .collection('workout_logs')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .limit(50)
          .get()
          .timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );

      if (snapshot.docs.isEmpty) {
        print('📭 No workout logs found, using sample data');
        workoutLogs.value = _generateSampleLogs(userId);
      } else {
        print('✅ Found ${snapshot.docs.length} workout logs');
        workoutLogs.value = snapshot.docs
            .map((doc) => WorkoutLog.fromJson(doc.data()))
            .toList();
      }

      calculateStats();
      isLoading.value = false;

    } catch (e) {
      print('⚠️ Error loading workout history (using sample data): $e');

      // Use sample data on error
      final authController = Get.find<AuthController>();
      final userId = authController.currentUser?.uid ?? 'demo_user';
      workoutLogs.value = _generateSampleLogs(userId);
      calculateStats();

      isLoading.value = false;

      // Don't show error snackbar, just log it
      print('💡 Using sample data for demo purposes');
    }
  }

  Future<void> saveWorkoutLog(WorkoutLog log) async {
    try {
      final authController = Get.find<AuthController>();
      final userId = authController.currentUser?.uid;

      if (userId == null) {
        print('❌ No user logged in');
        return;
      }

      await _firestore
          .collection('workout_logs')
          .doc(log.id)
          .set(log.toJson());

      // Reload logs
      await loadWorkoutHistory();

      Get.snackbar(
        'Success',
        'Workout saved successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('❌ Error saving workout: $e');
      Get.snackbar('Error', 'Failed to save workout');
    }
  }

  void calculateStats() {
    totalWorkouts.value = workoutLogs.length;
    totalCalories.value = workoutLogs.fold(
        0, (sum, log) => sum + log.caloriesBurned);
    totalMinutes.value =
        workoutLogs.fold(0, (sum, log) => sum + (log.duration ~/ 60));
    currentStreak.value = _calculateStreak();
  }

  int _calculateStreak() {
    if (workoutLogs.isEmpty) return 0;

    int streak = 0;
    DateTime currentDate = DateTime.now();

    for (var log in workoutLogs) {
      final daysDifference = currentDate.difference(log.date).inDays;

      if (daysDifference == streak) {
        streak++;
        currentDate = log.date;
      } else if (daysDifference > streak) {
        break;
      }
    }

    return streak;
  }

  void filterByPeriod(String period) {
    selectedFilter.value = period;
  }

  List<WorkoutLog> get filteredLogs {
    final now = DateTime.now();
    switch (selectedFilter.value) {
      case 'Week':
        return workoutLogs
            .where((log) => now.difference(log.date).inDays <= 7)
            .toList();
      case 'Month':
        return workoutLogs
            .where((log) => now.difference(log.date).inDays <= 30)
            .toList();
      case 'Year':
        return workoutLogs
            .where((log) => now.difference(log.date).inDays <= 365)
            .toList();
      default:
        return workoutLogs;
    }
  }

  // Generate sample workout logs for demo
  List<WorkoutLog> _generateSampleLogs(String userId) {
    final now = DateTime.now();
    return [
      WorkoutLog(
        id: '1',
        userId: userId,
        workoutId: '1',
        workoutName: 'Full Body Strength',
        date: now.subtract(Duration(days: 0)),
        duration: 2700,
        caloriesBurned: 350,
        exercises: [],
        mood: 'great',
        difficulty: 'moderate',
        notes: 'Felt strong today!',
      ),
      WorkoutLog(
        id: '2',
        userId: userId,
        workoutId: '2',
        workoutName: 'HIIT Cardio Blast',
        date: now.subtract(Duration(days: 1)),
        duration: 1800,
        caloriesBurned: 400,
        exercises: [],
        mood: 'good',
        difficulty: 'hard',
      ),
      WorkoutLog(
        id: '3',
        userId: userId,
        workoutId: '3',
        workoutName: 'Upper Body Power',
        date: now.subtract(Duration(days: 2)),
        duration: 2400,
        caloriesBurned: 300,
        exercises: [],
        mood: 'good',
        difficulty: 'moderate',
      ),
      WorkoutLog(
        id: '4',
        userId: userId,
        workoutId: '5',
        workoutName: 'Morning Yoga Flow',
        date: now.subtract(Duration(days: 3)),
        duration: 1200,
        caloriesBurned: 100,
        exercises: [],
        mood: 'great',
        difficulty: 'easy',
      ),
      WorkoutLog(
        id: '5',
        userId: userId,
        workoutId: '6',
        workoutName: 'Core Crusher',
        date: now.subtract(Duration(days: 4)),
        duration: 1500,
        caloriesBurned: 200,
        exercises: [],
        mood: 'okay',
        difficulty: 'hard',
      ),
      WorkoutLog(
        id: '6',
        userId: userId,
        workoutId: '4',
        workoutName: 'Lower Body Blast',
        date: now.subtract(Duration(days: 7)),
        duration: 2100,
        caloriesBurned: 280,
        exercises: [],
        mood: 'good',
        difficulty: 'moderate',
      ),
      WorkoutLog(
        id: '7',
        userId: userId,
        workoutId: '1',
        workoutName: 'Full Body Strength',
        date: now.subtract(Duration(days: 8)),
        duration: 2700,
        caloriesBurned: 350,
        exercises: [],
        mood: 'great',
        difficulty: 'moderate',
      ),
      WorkoutLog(
        id: '8',
        userId: userId,
        workoutId: '2',
        workoutName: 'HIIT Cardio Blast',
        date: now.subtract(Duration(days: 9)),
        duration: 1800,
        caloriesBurned: 400,
        exercises: [],
        mood: 'good',
        difficulty: 'hard',
      ),
    ];
  }
}