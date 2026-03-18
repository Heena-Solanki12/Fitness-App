// lib/controllers/workout_history_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout_log_model.dart';
import '../controllers/auth_controller.dart';

class WorkoutHistoryController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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
      final uid = Get.find<AuthController>().currentUser?.uid;
      if (uid == null) {
        workoutLogs.value = _sampleLogs('demo');
        calculateStats();
        isLoading.value = false;
        return;
      }
      final snap = await _db
          .collection('workout_logs')
          .where('userId', isEqualTo: uid)
          .orderBy('date', descending: true)
          .limit(50)
          .get()
          .timeout(const Duration(seconds: 10));
      workoutLogs.value = snap.docs.isEmpty
          ? _sampleLogs(uid)
          : snap.docs.map((d) => WorkoutLog.fromJson(d.data())).toList();
      calculateStats();
      isLoading.value = false;
    } catch (_) {
      final uid = Get.find<AuthController>().currentUser?.uid ?? 'demo';
      workoutLogs.value = _sampleLogs(uid);
      calculateStats();
      isLoading.value = false;
    }
  }

  Future<void> saveWorkoutLog(WorkoutLog log) async {
    try {
      final uid = Get.find<AuthController>().currentUser?.uid;
      if (uid == null) return;
      await _db.collection('workout_logs').doc(log.id).set(log.toJson());
      await loadWorkoutHistory();
      // Update profile stats so Profile page shows real-time data
      await _db.collection('users').doc(uid).set({
        'totalWorkouts': totalWorkouts.value,
        'streak': currentStreak.value,
        'lastWorkoutDate': Timestamp.fromDate(DateTime.now()),
      }, SetOptions(merge: true));
      Get.snackbar(
        'Great work! 💪', 'Workout saved successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF00D4AA).withOpacity(0.12),
        colorText: const Color(0xFF00D4AA),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (_) {
      Get.snackbar('Error', 'Failed to save workout',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void calculateStats() {
    totalWorkouts.value = workoutLogs.length;
    totalCalories.value = workoutLogs.fold(0, (s, l) => s + l.caloriesBurned);
    totalMinutes.value = workoutLogs.fold(0, (s, l) => s + (l.duration ~/ 60));
    currentStreak.value = _calcStreak();
  }

  int _calcStreak() {
    if (workoutLogs.isEmpty) return 0;
    int streak = 0;
    DateTime cursor = DateTime.now();
    for (final log in workoutLogs) {
      final diff = cursor.difference(log.date).inDays;
      if (diff == streak) { streak++; cursor = log.date; }
      else if (diff > streak) break;
    }
    return streak;
  }

  void filterByPeriod(String p) => selectedFilter.value = p;

  List<WorkoutLog> get filteredLogs {
    final now = DateTime.now();
    switch (selectedFilter.value) {
      case 'Week':  return workoutLogs.where((l) => now.difference(l.date).inDays <= 7).toList();
      case 'Month': return workoutLogs.where((l) => now.difference(l.date).inDays <= 30).toList();
      case 'Year':  return workoutLogs.where((l) => now.difference(l.date).inDays <= 365).toList();
      default:      return workoutLogs;
    }
  }

  List<WorkoutLog> _sampleLogs(String uid) {
    final now = DateTime.now();
    return [
      WorkoutLog(id: '1', userId: uid, workoutId: '1', workoutName: 'Full Body Strength', date: now.subtract(const Duration(days: 0)), duration: 2700, caloriesBurned: 350, exercises: [], mood: 'great', difficulty: 'moderate', notes: 'Felt strong today!'),
      WorkoutLog(id: '2', userId: uid, workoutId: '2', workoutName: 'HIIT Cardio Blast', date: now.subtract(const Duration(days: 1)), duration: 1800, caloriesBurned: 400, exercises: [], mood: 'good', difficulty: 'hard'),
      WorkoutLog(id: '3', userId: uid, workoutId: '3', workoutName: 'Upper Body Power', date: now.subtract(const Duration(days: 2)), duration: 2400, caloriesBurned: 300, exercises: [], mood: 'good', difficulty: 'moderate'),
      WorkoutLog(id: '4', userId: uid, workoutId: '5', workoutName: 'Morning Yoga Flow', date: now.subtract(const Duration(days: 3)), duration: 1200, caloriesBurned: 100, exercises: [], mood: 'great', difficulty: 'easy'),
      WorkoutLog(id: '5', userId: uid, workoutId: '6', workoutName: 'Core Crusher', date: now.subtract(const Duration(days: 4)), duration: 1500, caloriesBurned: 200, exercises: [], mood: 'okay', difficulty: 'hard'),
      WorkoutLog(id: '6', userId: uid, workoutId: '4', workoutName: 'Lower Body Blast', date: now.subtract(const Duration(days: 7)), duration: 2100, caloriesBurned: 280, exercises: [], mood: 'good', difficulty: 'moderate'),
      WorkoutLog(id: '7', userId: uid, workoutId: '1', workoutName: 'Full Body Strength', date: now.subtract(const Duration(days: 8)), duration: 2700, caloriesBurned: 350, exercises: [], mood: 'great', difficulty: 'moderate'),
      WorkoutLog(id: '8', userId: uid, workoutId: '2', workoutName: 'HIIT Cardio Blast', date: now.subtract(const Duration(days: 9)), duration: 1800, caloriesBurned: 400, exercises: [], mood: 'good', difficulty: 'hard'),
    ];
  }
}
