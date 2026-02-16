import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../models/workout_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class WorkoutDetailView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Workout workout = Get.arguments as Workout;
    final isDark = Get.isDarkMode;

    return Scaffold(
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
        child: Column(
          children: [
            _buildHeader(workout, isDark),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStats(workout, isDark),
                    SizedBox(height: 24),
                    _buildDescription(workout, isDark),
                    SizedBox(height: 24),
                    _buildExercisesList(workout, isDark),
                    SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildStartButton(workout, isDark),
    );
  }

  Widget _buildHeader(Workout workout, bool isDark) {
    return Stack(
      children: [
        // Background Image
        Container(
          height: 300,
          width: double.infinity,
          child: workout.imageUrl != null
              ? CachedNetworkImage(
            imageUrl: workout.imageUrl!,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: AppColors.primary.withOpacity(0.1),
              child: Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              color: AppColors.primary.withOpacity(0.1),
              child: Icon(Icons.fitness_center,
                  size: 60, color: AppColors.primary),
            ),
          )
              : Container(
            color: AppColors.primary.withOpacity(0.1),
            child: Icon(Icons.fitness_center,
                size: 60, color: AppColors.primary),
          ),
        ),
        // Gradient Overlay
        Container(
          height: 300,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
        ),
        // Content
        SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios_new,
                            color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.favorite_border, color: Colors.white),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 140),
              // Title and Tags
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(workout.category)
                            .withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        workout.category,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      workout.name,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        ...List.generate(
                          3,
                              (index) => Icon(
                            Icons.circle,
                            size: 8,
                            color:
                            index < _getDifficultyLevel(workout.difficulty)
                                ? _getDifficultyColor(workout.difficulty)
                                : Colors.white.withOpacity(0.3),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          workout.difficulty,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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
      padding: EdgeInsets.all(20),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            Icons.timer,
            "${workout.duration}",
            "Minutes",
            Color(0xFF4E54C8),
            isDark,
          ),
          Container(
            width: 1,
            height: 40,
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.grey.withOpacity(0.2),
          ),
          _buildStatItem(
            Icons.local_fire_department,
            "${workout.caloriesBurned}",
            "Calories",
            Color(0xFFFF6B9D),
            isDark,
          ),
          Container(
            width: 1,
            height: 40,
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.grey.withOpacity(0.2),
          ),
          _buildStatItem(
            Icons.fitness_center,
            "${workout.exercises.length}",
            "Exercises",
            Color(0xFF00B894),
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      IconData icon, String value, String label, Color color, bool isDark) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
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

  Widget _buildDescription(Workout workout, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "About",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textDark,
          ),
        ),
        SizedBox(height: 12),
        Text(
          workout.description,
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: AppColors.textGrey,
          ),
        ),
        if (workout.tags.isNotEmpty) ...[
          SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: workout.tags
                .map((tag) => Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildExercisesList(Workout workout, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Exercises (${workout.exercises.length})",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textDark,
          ),
        ),
        SizedBox(height: 16),
        ...workout.exercises.asMap().entries.map((entry) {
          int index = entry.key;
          var exercise = entry.value;
          return _buildExerciseTile(index + 1, exercise, isDark);
        }).toList(),
      ],
    );
  }

  Widget _buildExerciseTile(int index, exercise, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.gradientEnd],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                "$index",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      "${exercise.sets} sets",
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textGrey,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      "×",
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textGrey,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      "${exercise.reps} reps",
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textGrey,
                      ),
                    ),
                    if (exercise.weight != null) ...[
                      SizedBox(width: 12),
                      Text(
                        "• ${exercise.weight} kg",
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.info_outline,
            color: AppColors.primary,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton(Workout workout, bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
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
        onPressed: () => Get.toNamed('/active-workout', arguments: workout),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_circle_filled, size: 28),
            SizedBox(width: 12),
            Text(
              "Start Workout",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Strength':
        return Color(0xFF4E54C8);
      case 'Cardio':
        return Color(0xFFFF6B9D);
      case 'Flexibility':
        return Color(0xFF7C4DFF);
      default:
        return AppColors.primary;
    }
  }

  int _getDifficultyLevel(String difficulty) {
    switch (difficulty) {
      case 'Beginner':
        return 1;
      case 'Intermediate':
        return 2;
      case 'Advanced':
        return 3;
      default:
        return 1;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Beginner':
        return Color(0xFF00B894);
      case 'Intermediate':
        return Color(0xFDCB6E);
      case 'Advanced':
        return Color(0xFFFF7675);
      default:
        return AppColors.primary;
    }
  }
}