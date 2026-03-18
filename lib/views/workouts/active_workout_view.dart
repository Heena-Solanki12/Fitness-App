// lib/views/workouts/active_workout_view.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../controllers/workout_history_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../models/workout_log_model.dart';
import '../../models/workout_model.dart';
import '../../models/workout_exercise.dart';

// ── Controller ────────────────────────────────────────────────────────────────
class ActiveWorkoutController extends GetxController {
  final Workout workout;
  ActiveWorkoutController(this.workout);

  final RxInt currentExerciseIndex = 0.obs;
  final RxInt currentSet = 1.obs;
  final RxInt elapsedSeconds = 0.obs;
  final RxBool isResting = false.obs;
  final RxInt restTimeRemaining = 0.obs;
  final RxBool isPaused = false.obs;

  Timer? _workoutTimer;
  Timer? _restTimer;

  @override
  void onInit() {
    super.onInit();
    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isPaused.value && !isResting.value) elapsedSeconds.value++;
    });
  }

  @override
  void onClose() {
    _workoutTimer?.cancel();
    _restTimer?.cancel();
    super.onClose();
  }

  void togglePause() => isPaused.value = !isPaused.value;

  void completeSet() {
    final exercise = workout.exercises[currentExerciseIndex.value];
    if (currentSet.value < exercise.sets) {
      currentSet.value++;
      _startRest(exercise.restTime);
    } else if (currentExerciseIndex.value < workout.exercises.length - 1) {
      currentExerciseIndex.value++;
      currentSet.value = 1;
    } else {
      _finishWorkout();
    }
  }

  void skipRest() {
    _restTimer?.cancel();
    isResting.value = false;
    restTimeRemaining.value = 0;
  }

  void _startRest(int seconds) {
    isResting.value = true;
    restTimeRemaining.value = seconds;
    _restTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (restTimeRemaining.value > 0) {
        restTimeRemaining.value--;
      } else {
        t.cancel();
        isResting.value = false;
      }
    });
  }

  void previousExercise() {
    if (currentExerciseIndex.value > 0) {
      currentExerciseIndex.value--;
      currentSet.value = 1;
      skipRest();
    }
  }

  void nextExercise() {
    if (currentExerciseIndex.value < workout.exercises.length - 1) {
      currentExerciseIndex.value++;
      currentSet.value = 1;
      skipRest();
    }
  }

  void _finishWorkout() {
    _workoutTimer?.cancel();
    _restTimer?.cancel();
    final log = WorkoutLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: Get.find<AuthController>().firebaseUser.value!.uid,
      workoutId: workout.id,
      workoutName: workout.name,
      date: DateTime.now(),
      duration: elapsedSeconds.value,
      caloriesBurned: workout.caloriesBurned,
      exercises: [],
      mood: 'good',
      difficulty: 'moderate',
    );
    try { Get.find<WorkoutHistoryController>().saveWorkoutLog(log); } catch (_) {}
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [const Icon(Icons.celebration, color: AppColors.primary, size: 28), const SizedBox(width: 12), const Text('Workout Complete!')]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Great job! You\'ve completed ${workout.name}', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(children: [const Icon(Icons.timer, color: AppColors.primary), const SizedBox(height: 4), Text(_fmt(elapsedSeconds.value), style: const TextStyle(fontWeight: FontWeight.bold)), const Text('Time', style: TextStyle(fontSize: 12))]),
                  Column(children: [const Icon(Icons.local_fire_department, color: Color(0xFFFF6B9D)), const SizedBox(height: 4), Text('${workout.caloriesBurned}', style: const TextStyle(fontWeight: FontWeight.bold)), const Text('Calories', style: TextStyle(fontSize: 12))]),
                ],
              ),
            ),
          ],
        ),
        actions: [TextButton(onPressed: () { Get.back(); Get.back(); Get.back(); }, child: const Text('Done'))],
      ),
      barrierDismissible: false,
    );
  }

  String _fmt(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  String get formattedTime => _fmt(elapsedSeconds.value);
  String get formattedRestTime => _fmt(restTimeRemaining.value);
  WorkoutExercise get currentExercise => workout.exercises[currentExerciseIndex.value];
  double get progress => (currentExerciseIndex.value + 1) / workout.exercises.length;
}

// ── View ──────────────────────────────────────────────────────────────────────
class ActiveWorkoutView extends StatelessWidget {
  const ActiveWorkoutView({super.key});

  @override
  Widget build(BuildContext context) {
    final Workout workout = Get.arguments as Workout;
    final ctrl = Get.put(ActiveWorkoutController(workout));
    return Obx(() {
      final isDark = ThemeController.to.isDark.value;
      return WillPopScope(
        onWillPop: () async => (await _exitDialog() ?? false),
        child: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark ? [AppColors.backgroundDark, const Color(0xFF1C2128)] : [AppColors.backgroundLight, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _appBar(ctrl, isDark),
                  _progressBar(ctrl, isDark),
                  Expanded(child: Obx(() => ctrl.isResting.value ? _restScreen(ctrl, isDark) : _exerciseScreen(ctrl, isDark))),
                  _bottomControls(ctrl, isDark),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _appBar(ActiveWorkoutController ctrl, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.close, color: isDark ? Colors.white : AppColors.textDark),
            onPressed: () async { if (await _exitDialog() == true) Get.back(); },
          ),
          Column(children: [
            Text(ctrl.workout.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
            const SizedBox(height: 4),
            Obx(() => Text(ctrl.formattedTime, style: const TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w600))),
          ]),
          Obx(() => IconButton(
            icon: Icon(ctrl.isPaused.value ? Icons.play_arrow : Icons.pause, color: AppColors.primary),
            onPressed: ctrl.togglePause,
          )),
        ],
      ),
    );
  }

  Widget _progressBar(ActiveWorkoutController ctrl, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => Text('Exercise ${ctrl.currentExerciseIndex.value + 1} of ${ctrl.workout.exercises.length}', style: const TextStyle(fontSize: 13, color: AppColors.textGrey, fontWeight: FontWeight.w500))),
              Obx(() => Text('${(ctrl.progress * 100).toInt()}%', style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600))),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() => ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: ctrl.progress,
              minHeight: 8,
              backgroundColor: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          )),
        ],
      ),
    );
  }

  Widget _exerciseScreen(ActiveWorkoutController ctrl, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            height: 200, width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.2), AppColors.secondary.withOpacity(0.2)]),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.fitness_center, size: 80, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          Obx(() => Text(ctrl.currentExercise.name, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark), textAlign: TextAlign.center)),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 15, offset: const Offset(0, 5))],
            ),
            child: Column(
              children: [
                Obx(() => Text('Set ${ctrl.currentSet.value} of ${ctrl.currentExercise.sets}', style: const TextStyle(fontSize: 16, color: AppColors.textGrey, fontWeight: FontWeight.w500))),
                const SizedBox(height: 16),
                Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _metric(Icons.repeat, '${ctrl.currentExercise.reps}', 'Reps', isDark),
                    if (ctrl.currentExercise.weight != null) _metric(Icons.fitness_center, '${ctrl.currentExercise.weight}', 'kg', isDark),
                    _metric(Icons.timer, '${ctrl.currentExercise.restTime}', 'Rest (s)', isDark),
                  ],
                )),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Obx(() {
            final notes = ctrl.currentExercise.notes;
            if (notes == null || notes.isEmpty) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(notes, style: TextStyle(fontSize: 14, color: isDark ? Colors.white : AppColors.textDark))),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _restScreen(ActiveWorkoutController ctrl, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200, height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [AppColors.secondary, AppColors.accent]),
              boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 10))],
            ),
            child: Center(child: Obx(() => Text(ctrl.formattedRestTime, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)))),
          ),
          const SizedBox(height: 32),
          Text('Rest Time', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
          const SizedBox(height: 16),
          const Text('Get ready for the next set!', style: TextStyle(fontSize: 16, color: AppColors.textGrey)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: ctrl.skipRest,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
            child: const Text('Skip Rest', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _metric(IconData icon, String value, String label, bool isDark) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
      ],
    );
  }

  Widget _bottomControls(ActiveWorkoutController ctrl, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.03), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Obx(() => Expanded(
                child: OutlinedButton(
                  onPressed: ctrl.currentExerciseIndex.value > 0 ? ctrl.previousExercise : null,
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.arrow_back, size: 20), SizedBox(width: 8), Text('Previous')]),
                ),
              )),
              const SizedBox(width: 12),
              Obx(() => Expanded(
                child: OutlinedButton(
                  onPressed: ctrl.currentExerciseIndex.value < ctrl.workout.exercises.length - 1 ? ctrl.nextExercise : null,
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Next'), SizedBox(width: 8), Icon(Icons.arrow_forward, size: 20)]),
                ),
              )),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() => ctrl.isResting.value ? const SizedBox.shrink() : SizedBox(
            width: double.infinity,
            height: 56,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.gradientEnd]),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: ElevatedButton(
                onPressed: ctrl.completeSet,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                child: Obx(() => Text(
                  ctrl.currentSet.value < ctrl.currentExercise.sets ? 'Complete Set'
                      : ctrl.currentExerciseIndex.value < ctrl.workout.exercises.length - 1 ? 'Next Exercise'
                      : 'Finish Workout',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                )),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Future<bool?> _exitDialog() => Get.dialog<bool>(
    AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Exit Workout?'),
      content: const Text('Are you sure you want to exit? Your progress will be lost.'),
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
        TextButton(onPressed: () => Get.back(result: true), style: TextButton.styleFrom(foregroundColor: AppColors.error), child: const Text('Exit')),
      ],
    ),
  );
}
