import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../models/exercise_model.dart';
import '../../services/exercise_service.dart';

class ExerciseLibraryView extends StatelessWidget {
  final ExerciseLibraryController controller =
  Get.put(ExerciseLibraryController());

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
              _buildCategoryFilter(isDark),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (controller.filteredExercises.isEmpty) {
                    return _buildEmptyState(isDark);
                  }

                  return _buildExerciseList(isDark);
                }),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/custom-workout-builder'),
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
                "Exercise Library",
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Obx(() => Text(
                "${controller.filteredExercises.length} exercises",
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 12,
                ),
              )),
            ],
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
            hintText: "Search exercises...",
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

  Widget _buildCategoryFilter(bool isDark) {
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
            'Chest',
            controller.selectedCategory.value == 'Chest',
                () => controller.setCategory('Chest'),
            isDark,
          )),
          SizedBox(width: 8),
          Obx(() => _buildFilterChip(
            'Back',
            controller.selectedCategory.value == 'Back',
                () => controller.setCategory('Back'),
            isDark,
          )),
          SizedBox(width: 8),
          Obx(() => _buildFilterChip(
            'Legs',
            controller.selectedCategory.value == 'Legs',
                () => controller.setCategory('Legs'),
            isDark,
          )),
          SizedBox(width: 8),
          Obx(() => _buildFilterChip(
            'Shoulders',
            controller.selectedCategory.value == 'Shoulders',
                () => controller.setCategory('Shoulders'),
            isDark,
          )),
          SizedBox(width: 8),
          Obx(() => _buildFilterChip(
            'Arms',
            controller.selectedCategory.value == 'Arms',
                () => controller.setCategory('Arms'),
            isDark,
          )),
          SizedBox(width: 8),
          Obx(() => _buildFilterChip(
            'Core',
            controller.selectedCategory.value == 'Core',
                () => controller.setCategory('Core'),
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

  Widget _buildExerciseList(bool isDark) {
    return Obx(() => ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: controller.filteredExercises.length,
      itemBuilder: (context, index) {
        final exercise = controller.filteredExercises[index];
        return _buildExerciseCard(exercise, isDark);
      },
    ));
  }

  Widget _buildExerciseCard(Exercise exercise, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showExerciseDetail(exercise, isDark),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.gradientEnd],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getIconForCategory(exercise.category),
                    color: Colors.white,
                    size: 28,
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        exercise.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textGrey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children: exercise.primaryMuscles.take(3).map((muscle) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              muscle,
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(exercise.difficulty)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        exercise.difficulty,
                        style: TextStyle(
                          fontSize: 10,
                          color: _getDifficultyColor(exercise.difficulty),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.textGrey,
                    ),
                  ],
                ),
              ],
            ),
          ),
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
            "No exercises found",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Try adjusting your search or filters",
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }

  void _showExerciseDetail(Exercise exercise, bool isDark) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    exercise.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textDark,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              exercise.description,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textGrey,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                _buildDetailChip(
                    "Category", exercise.category, AppColors.primary, isDark),
                SizedBox(width: 8),
                _buildDetailChip("Difficulty", exercise.difficulty,
                    _getDifficultyColor(exercise.difficulty), isDark),
              ],
            ),
            SizedBox(height: 16),
            Text(
              "Primary Muscles",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: exercise.primaryMuscles
                  .map((muscle) => Chip(
                label: Text(muscle),
                backgroundColor: AppColors.primary.withOpacity(0.1),
                labelStyle: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ))
                  .toList(),
            ),
            SizedBox(height: 16),
            Text(
              "Equipment Needed",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: exercise.equipment
                  .map((eq) => Chip(
                label: Text(eq),
                backgroundColor: Color(0xFF00B894).withOpacity(0.1),
                labelStyle: TextStyle(
                  color: Color(0xFF00B894),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ))
                  .toList(),
            ),
            SizedBox(height: 16),
            Text(
              "Instructions",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: exercise.instructions.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              "${index + 1}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            exercise.instructions[index],
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white : AppColors.textDark,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailChip(
      String label, String value, Color color, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textGrey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Strength':
        return Icons.fitness_center;
      case 'Cardio':
        return Icons.directions_run;
      case 'Flexibility':
        return Icons.self_improvement;
      default:
        return Icons.fitness_center;
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

// lib/controllers/exercise_library_controller.dart
class ExerciseLibraryController extends GetxController {
  final RxList<Exercise> exercises = <Exercise>[].obs;
  final RxList<Exercise> filteredExercises = <Exercise>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedCategory = 'All'.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadExercises();
  }

  void loadExercises() {
    isLoading.value = true;
    // Load from Firebase or use initial data
    exercises.value = ExerciseService.getInitialExercises();
    filteredExercises.value = exercises;
    isLoading.value = false;
  }

  void setCategory(String category) {
    selectedCategory.value = category;
    filterExercises();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    filterExercises();
  }

  void filterExercises() {
    var filtered = exercises.where((exercise) {
      bool matchesCategory = selectedCategory.value == 'All' ||
          exercise.primaryMuscles.any((muscle) =>
              muscle.toLowerCase().contains(selectedCategory.value.toLowerCase()));

      bool matchesSearch = searchQuery.value.isEmpty ||
          exercise.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          exercise.description
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();

    filteredExercises.value = filtered;
  }
}