import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/workout_history_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../models/workout_log_model.dart';
import '../../models/workout_model.dart';
import '../../models/workout_exercise.dart';

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
    startWorkoutTimer();
  }

  @override
  void onClose() {
    _workoutTimer?.cancel();
    _restTimer?.cancel();
    super.onClose();
  }

  void startWorkoutTimer() {
    _workoutTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!isPaused.value && !isResting.value) {
        elapsedSeconds.value++;
      }
    });
  }

  void togglePause() {
    isPaused.value = !isPaused.value;
  }

  void completeSet() {
    final exercise = workout.exercises[currentExerciseIndex.value];

    if (currentSet.value < exercise.sets) {
      // Start rest timer
      currentSet.value++;
      startRestTimer(exercise.restTime);
    } else {
      // Move to next exercise
      if (currentExerciseIndex.value < workout.exercises.length - 1) {
        currentExerciseIndex.value++;
        currentSet.value = 1;
      } else {
        // Workout complete
        completeWorkout();
      }
    }
  }

  void skipRest() {
    _restTimer?.cancel();
    isResting.value = false;
    restTimeRemaining.value = 0;
  }

  void startRestTimer(int seconds) {
    isResting.value = true;
    restTimeRemaining.value = seconds;

    _restTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (restTimeRemaining.value > 0) {
        restTimeRemaining.value--;
      } else {
        timer.cancel();
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

  void completeWorkout() {
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
      exercises: [], // Can add detailed exercise logs here
      mood: 'good',
      difficulty: 'moderate',
    );

    // Save to history controller
    final historyController = Get.find<WorkoutHistoryController>();
    historyController.saveWorkoutLog(log);

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.celebration, color: AppColors.primary, size: 28),
            SizedBox(width: 12),
            Text("Workout Complete!"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Great job! You've completed ${workout.name}",
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Icon(Icons.timer, color: AppColors.primary),
                      SizedBox(height: 4),
                      Text(
                        _formatTime(elapsedSeconds.value),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text("Time", style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(Icons.local_fire_department, color: Color(0xFFFF6B9D)),
                      SizedBox(height: 4),
                      Text(
                        "${workout.caloriesBurned}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text("Calories", style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.back();
              Get.back();
            },
            child: Text("Done"),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String get formattedTime => _formatTime(elapsedSeconds.value);
  String get formattedRestTime => _formatTime(restTimeRemaining.value);

  WorkoutExercise get currentExercise =>
      workout.exercises[currentExerciseIndex.value];

  double get progress =>
      (currentExerciseIndex.value + 1) / workout.exercises.length;
}

class ActiveWorkoutView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Workout workout = Get.arguments as Workout;
    final controller = Get.put(ActiveWorkoutController(workout));
    final isDark = Get.isDarkMode;

    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await _showExitDialog();
        return shouldExit ?? false;
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [AppColors.backgroundDark, Color(0xFF1C2128)]
                  : [AppColors.backgroundLight, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildAppBar(controller, isDark),
                _buildProgressBar(controller, isDark),
                Expanded(
                  child: Obx(() {
                    if (controller.isResting.value) {
                      return _buildRestScreen(controller, isDark);
                    }
                    return _buildExerciseScreen(controller, isDark);
                  }),
                ),
                _buildBottomControls(controller, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(ActiveWorkoutController controller, bool isDark) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.close, color: isDark ? Colors.white : AppColors.textDark),
            onPressed: () async {
              final shouldExit = await _showExitDialog();
              if (shouldExit == true) {
                Get.back();
              }
            },
          ),
          Column(
            children: [
              Text(
                controller.workout.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              ),
              SizedBox(height: 4),
              Obx(() => Text(
                controller.formattedTime,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              )),
            ],
          ),
          Obx(() => IconButton(
            icon: Icon(
              controller.isPaused.value ? Icons.play_arrow : Icons.pause,
              color: AppColors.primary,
            ),
            onPressed: () => controller.togglePause(),
          )),
        ],
      ),
    );
  }

  Widget _buildProgressBar(ActiveWorkoutController controller, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => Text(
                "Exercise ${controller.currentExerciseIndex.value + 1} of ${controller.workout.exercises.length}",
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textGrey,
                  fontWeight: FontWeight.w500,
                ),
              )),
              Obx(() => Text(
                "${(controller.progress * 100).toInt()}%",
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              )),
            ],
          ),
          SizedBox(height: 8),
          Obx(() => ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: controller.progress,
              minHeight: 8,
              backgroundColor: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildExerciseScreen(ActiveWorkoutController controller, bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(height: 20),
          // Exercise Image Placeholder
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.2),
                  AppColors.secondary.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.fitness_center,
              size: 80,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 24),
          // Exercise Name
          Obx(() => Text(
            controller.currentExercise.name,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          )),
          SizedBox(height: 32),
          // Set Info
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.2)
                      : Colors.black.withOpacity(0.04),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Obx(() => Text(
                  "Set ${controller.currentSet.value} of ${controller.currentExercise.sets}",
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                )),
                SizedBox(height: 16),
                Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMetric(
                      Icons.repeat,
                      "${controller.currentExercise.reps}",
                      "Reps",
                      isDark,
                    ),
                    if (controller.currentExercise.weight != null)
                      _buildMetric(
                        Icons.fitness_center,
                        "${controller.currentExercise.weight}",
                        "kg",
                        isDark,
                      ),
                    _buildMetric(
                      Icons.timer,
                      "${controller.currentExercise.restTime}",
                      "Rest (s)",
                      isDark,
                    ),
                  ],
                )),
              ],
            ),
          ),
          SizedBox(height: 24),
          // Notes
          Obx(() {
            if (controller.currentExercise.notes != null &&
                controller.currentExercise.notes!.isNotEmpty) {
              return Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        controller.currentExercise.notes!,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white : AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildRestScreen(ActiveWorkoutController controller, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.secondary, AppColors.accent],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withOpacity(0.3),
                  blurRadius: 30,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Obx(() => Text(
                controller.formattedRestTime,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )),
            ),
          ),
          SizedBox(height: 32),
          Text(
            "Rest Time",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          SizedBox(height: 16),
          Text(
            "Get ready for the next set!",
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textGrey,
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => controller.skipRest(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              "Skip Rest",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(IconData icon, String value, String label, bool isDark) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textDark,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls(ActiveWorkoutController controller, bool isDark) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Navigation Buttons
          Row(
            children: [
              Obx(() => Expanded(
                child: OutlinedButton(
                  onPressed: controller.currentExerciseIndex.value > 0
                      ? () => controller.previousExercise()
                      : null,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back, size: 20),
                      SizedBox(width: 8),
                      Text("Previous"),
                    ],
                  ),
                ),
              )),
              SizedBox(width: 12),
              Obx(() => Expanded(
                child: OutlinedButton(
                  onPressed: controller.currentExerciseIndex.value <
                      controller.workout.exercises.length - 1
                      ? () => controller.nextExercise()
                      : null,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Next"),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              )),
            ],
          ),
          SizedBox(height: 12),
          // Complete Set Button
          Obx(() => !controller.isResting.value
              ? Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.gradientEnd],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => controller.completeSet(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                controller.currentSet.value <
                    controller.currentExercise.sets
                    ? "Complete Set"
                    : controller.currentExerciseIndex.value <
                    controller.workout.exercises.length - 1
                    ? "Next Exercise"
                    : "Finish Workout",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          )
              : SizedBox.shrink()),
        ],
      ),
    );
  }

  Future<bool?> _showExitDialog() {
    return Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Exit Workout?"),
        content: Text(
          "Are you sure you want to exit? Your progress will be lost.",
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: Text("Exit"),
          ),
        ],
      ),
    );
  }
}