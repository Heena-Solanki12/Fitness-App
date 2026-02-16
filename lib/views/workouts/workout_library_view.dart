import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/workout_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../models/workout_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class WorkoutLibraryView extends StatelessWidget {
  final WorkoutController controller = Get.put(WorkoutController());

  @override
  Widget build(BuildContext context) {
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
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(isDark),
              _buildSearchBar(isDark),
              _buildFilterChips(isDark),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (controller.filteredWorkouts.isEmpty) {
                    return _buildEmptyState(isDark);
                  }

                  return _buildWorkoutGrid(isDark);
                }),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.snackbar(
            "Coming Soon",
            "Create custom workout feature is under development!",
            backgroundColor: AppColors.primary.withOpacity(0.1),
            colorText: AppColors.primary,
            snackPosition: SnackPosition.BOTTOM,
            margin: EdgeInsets.all(16),
            borderRadius: 12,
          );
        },
        icon: Icon(Icons.add),
        label: Text("Create Workout"),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: isDark ? Colors.white : AppColors.textDark,
                  size: 20,
                ),
                onPressed: () => Get.back(),
              ),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Workout Library",
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textDark,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Obx(() => Text(
                    "${controller.filteredWorkouts.length} workouts",
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 12,
                    ),
                  )),
                ],
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: AppColors.primary,
            ),
            onPressed: () => _showFilterSheet(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.2)
                  : Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          onChanged: (value) => controller.setSearchQuery(value),
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.textDark,
          ),
          decoration: InputDecoration(
            hintText: "Search workouts...",
            hintStyle: TextStyle(color: AppColors.textGrey),
            prefixIcon: Icon(Icons.search, color: AppColors.primary),
            suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                ? IconButton(
              icon: Icon(Icons.clear, color: AppColors.textGrey),
              onPressed: () => controller.setSearchQuery(''),
            )
                : SizedBox.shrink()),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    return Container(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20),
        children: [
          Obx(() => _buildFilterChip(
            'All',
            controller.selectedCategory.value == 'All',
                () => controller.setCategory('All'),
            isDark,
          )),
          SizedBox(width: 8),
          Obx(() => _buildFilterChip(
            'Strength',
            controller.selectedCategory.value == 'Strength',
                () => controller.setCategory('Strength'),
            isDark,
          )),
          SizedBox(width: 8),
          Obx(() => _buildFilterChip(
            'Cardio',
            controller.selectedCategory.value == 'Cardio',
                () => controller.setCategory('Cardio'),
            isDark,
          )),
          SizedBox(width: 8),
          Obx(() => _buildFilterChip(
            'Flexibility',
            controller.selectedCategory.value == 'Flexibility',
                () => controller.setCategory('Flexibility'),
            isDark,
          )),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
      String label, bool isSelected, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
            colors: [AppColors.primary, AppColors.gradientEnd],
          )
              : null,
          color: isSelected
              ? null
              : isDark
              ? AppColors.cardDark
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.grey.withOpacity(0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : isDark
                ? Colors.white70
                : AppColors.textDark,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutGrid(bool isDark) {
    return Obx(() => GridView.builder(
      padding: EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: controller.filteredWorkouts.length,
      itemBuilder: (context, index) {
        final workout = controller.filteredWorkouts[index];
        return _buildWorkoutCard(workout, isDark);
      },
    ));
  }

  Widget _buildWorkoutCard(Workout workout, bool isDark) {
    return GestureDetector(
      onTap: () => Get.toNamed('/workout-detail', arguments: workout),
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Container(
                height: 120,
                width: double.infinity,
                color: AppColors.primary.withOpacity(0.1),
                child: workout.imageUrl != null
                    ? CachedNetworkImage(
                  imageUrl: workout.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: Icon(Icons.fitness_center,
                        size: 40, color: AppColors.primary),
                  ),
                )
                    : Center(
                  child: Icon(Icons.fitness_center,
                      size: 40, color: AppColors.primary),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Category badge
                    Container(
                      padding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(workout.category)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        workout.category,
                        style: TextStyle(
                          color: _getCategoryColor(workout.category),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    // Workout name
                    Text(
                      workout.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 10),
                    // Stats
                    Row(
                      children: [
                        Icon(Icons.timer, size: 14, color: AppColors.textGrey),
                        SizedBox(width: 4),
                        Text(
                          '${workout.duration} min',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textGrey,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.local_fire_department,
                            size: 14, color: AppColors.textGrey),
                        SizedBox(width: 4),
                        Text(
                          '${workout.caloriesBurned} cal',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    // Difficulty
                    Row(
                      children: [
                        ...List.generate(
                          3,
                              (index) => Icon(
                            Icons.circle,
                            size: 6,
                            color: index < _getDifficultyLevel(workout.difficulty)
                                ? _getDifficultyColor(workout.difficulty)
                                : Colors.grey.withOpacity(0.3),
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          workout.difficulty,
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: AppColors.textGrey.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            "No workouts found",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Try adjusting your filters",
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textGrey,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => controller.resetFilters(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text("Reset Filters"),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Filter Workouts",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Get.isDarkMode ? Colors.white : AppColors.textDark,
              ),
            ),
            SizedBox(height: 24),
            Text(
              "Difficulty",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Get.isDarkMode ? Colors.white : AppColors.textDark,
              ),
            ),
            SizedBox(height: 12),
            Obx(() => Wrap(
              spacing: 8,
              children: ['All', 'Beginner', 'Intermediate', 'Advanced']
                  .map((difficulty) => ChoiceChip(
                label: Text(difficulty),
                selected: controller.selectedDifficulty.value ==
                    difficulty,
                onSelected: (selected) {
                  controller.setDifficulty(difficulty);
                },
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color:
                  controller.selectedDifficulty.value == difficulty
                      ? Colors.white
                      : AppColors.textGrey,
                ),
              ))
                  .toList(),
            )),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      controller.resetFilters();
                      Get.back();
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text("Reset"),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text("Apply"),
                  ),
                ),
              ],
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
        return Color(0xFFFDCB6E);
      case 'Advanced':
        return Color(0xFFFF7675);
      default:
        return AppColors.primary;
    }
  }
}