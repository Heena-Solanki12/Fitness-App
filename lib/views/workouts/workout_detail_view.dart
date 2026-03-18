// lib/views/workouts/workout_detail_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/theme_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../models/workout_model.dart';

class WorkoutDetailView extends StatelessWidget {
  const WorkoutDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final Workout workout = Get.arguments as Workout;
    return Obx(() {
      final isDark = ThemeController.to.isDark.value;
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark ? [AppColors.backgroundDark, const Color(0xFF1C2128)] : [AppColors.backgroundLight, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              _buildHeader(workout, isDark),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStats(workout, isDark),
                      const SizedBox(height: 24),
                      _buildDescription(workout, isDark),
                      const SizedBox(height: 24),
                      _buildExercisesList(workout, isDark),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: _buildStartButton(workout),
      );
    });
  }

  Widget _buildHeader(Workout workout, bool isDark) {
    return Stack(
      children: [
        SizedBox(
          height: 300,
          width: double.infinity,
          child: workout.imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: workout.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: AppColors.primary.withOpacity(0.1), child: const Center(child: CircularProgressIndicator())),
                  errorWidget: (_, __, ___) => Container(color: AppColors.primary.withOpacity(0.1), child: const Icon(Icons.fitness_center, size: 60, color: AppColors.primary)),
                )
              : Container(color: AppColors.primary.withOpacity(0.1), child: const Icon(Icons.fitness_center, size: 60, color: AppColors.primary)),
        ),
        Container(
          height: 300,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
            ),
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
                      child: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), onPressed: () => Get.back()),
                    ),
                    Container(
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
                      child: IconButton(icon: const Icon(Icons.favorite_border, color: Colors.white), onPressed: () {}),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 140),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: _categoryColor(workout.category).withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
                      child: Text(workout.category, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 12),
                    Text(workout.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ...List.generate(3, (i) => Icon(Icons.circle, size: 8,
                          color: i < _difficultyLevel(workout.difficulty) ? _difficultyColor(workout.difficulty) : Colors.white.withOpacity(0.3))),
                        const SizedBox(width: 8),
                        Text(workout.difficulty, style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStats(Workout workout, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(Icons.timer, '${workout.duration}', 'Minutes', const Color(0xFF4E54C8), isDark),
          Container(width: 1, height: 40, color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2)),
          _statItem(Icons.local_fire_department, '${workout.caloriesBurned}', 'Calories', const Color(0xFFFF6B9D), isDark),
          Container(width: 1, height: 40, color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2)),
          _statItem(Icons.fitness_center, '${workout.exercises.length}', 'Exercises', const Color(0xFF00B894), isDark),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String value, String label, Color color, bool isDark) {
    return Column(
      children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
      ],
    );
  }

  Widget _buildDescription(Workout workout, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
        const SizedBox(height: 12),
        Text(workout.description, style: const TextStyle(fontSize: 14, height: 1.6, color: AppColors.textGrey)),
        if (workout.tags.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: workout.tags.map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
              child: Text(tag, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500)),
            )).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildExercisesList(Workout workout, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Exercises (${workout.exercises.length})', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
        const SizedBox(height: 16),
        ...workout.exercises.asMap().entries.map((e) => _exerciseTile(e.key + 1, e.value, isDark)),
      ],
    );
  }

  Widget _exerciseTile(int index, dynamic exercise, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, AppColors.gradientEnd]), borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text('$index', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.textDark)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text('${exercise.sets} sets', style: const TextStyle(fontSize: 13, color: AppColors.textGrey)),
                    const SizedBox(width: 12),
                    const Text('×', style: TextStyle(fontSize: 13, color: AppColors.textGrey)),
                    const SizedBox(width: 12),
                    Text('${exercise.reps} reps', style: const TextStyle(fontSize: 13, color: AppColors.textGrey)),
                    if (exercise.weight != null) ...[
                      const SizedBox(width: 12),
                      Text('• ${exercise.weight} kg', style: const TextStyle(fontSize: 13, color: AppColors.textGrey)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
        ],
      ),
    );
  }

  Widget _buildStartButton(Workout workout) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.gradientEnd]),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: ElevatedButton(
        onPressed: () => Get.toNamed('/active-workout', arguments: workout),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_circle_filled, size: 28, color: Colors.white),
            SizedBox(width: 12),
            Text('Start Workout', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'Strength': return const Color(0xFF4E54C8);
      case 'Cardio': return const Color(0xFFFF6B9D);
      case 'Flexibility': return const Color(0xFF7C4DFF);
      default: return AppColors.primary;
    }
  }

  int _difficultyLevel(String d) {
    switch (d) {
      case 'Beginner': return 1;
      case 'Intermediate': return 2;
      case 'Advanced': return 3;
      default: return 1;
    }
  }

  Color _difficultyColor(String d) {
    switch (d) {
      case 'Beginner': return const Color(0xFF00B894);
      case 'Intermediate': return const Color(0xFFFDCB6E);
      case 'Advanced': return const Color(0xFFFF7675);
      default: return AppColors.primary;
    }
  }
}
