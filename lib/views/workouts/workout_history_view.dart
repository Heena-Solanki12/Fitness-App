// lib/views/workouts/workout_history_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/workout_history_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../models/workout_log_model.dart';

class WorkoutHistoryView extends StatelessWidget {
  final WorkoutHistoryController controller = Get.put(WorkoutHistoryController());

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
              _buildStatsCards(isDark),
              _buildFilterChips(isDark),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (controller.filteredLogs.isEmpty) {
                    return _buildEmptyState(isDark);
                  }

                  return _buildHistoryList(isDark);
                }),
              ),
            ],
          ),
        ),
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
                "Workout History",
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Obx(() => Text(
                "${controller.totalWorkouts} workouts completed",
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

  Widget _buildStatsCards(bool isDark) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => _buildStatCard(
              Icons.fitness_center,
              "${controller.totalWorkouts}",
              "Workouts",
              [Color(0xFF4E54C8), Color(0xFF8F94FB)],
              isDark,
            )),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Obx(() => _buildStatCard(
              Icons.local_fire_department,
              "${controller.totalCalories}",
              "Calories",
              [Color(0xFFFF6B9D), Color(0xFFFF8E53)],
              isDark,
            )),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Obx(() => _buildStatCard(
              Icons.timer,
              "${controller.totalMinutes}",
              "Minutes",
              [Color(0xFF00B894), Color(0xFF00A896)],
              isDark,
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label,
      List<Color> colors, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textGrey,
            ),
          ),
        ],
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
            controller.selectedFilter.value == 'All',
                () => controller.filterByPeriod('All'),
            isDark,
          )),
          SizedBox(width: 8),
          Obx(() => _buildFilterChip(
            'Week',
            controller.selectedFilter.value == 'Week',
                () => controller.filterByPeriod('Week'),
            isDark,
          )),
          SizedBox(width: 8),
          Obx(() => _buildFilterChip(
            'Month',
            controller.selectedFilter.value == 'Month',
                () => controller.filterByPeriod('Month'),
            isDark,
          )),
          SizedBox(width: 8),
          Obx(() => _buildFilterChip(
            'Year',
            controller.selectedFilter.value == 'Year',
                () => controller.filterByPeriod('Year'),
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

  Widget _buildHistoryList(bool isDark) {
    return Obx(() => ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: controller.filteredLogs.length,
      itemBuilder: (context, index) {
        final log = controller.filteredLogs[index];
        return _buildHistoryCard(log, isDark);
      },
    ));
  }

  Widget _buildHistoryCard(WorkoutLog log, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.workoutName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE, MMM d, yyyy').format(log.date),
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              _buildMoodIcon(log.mood),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  Icons.timer,
                  log.formattedDuration,
                  isDark,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  Icons.local_fire_department,
                  "${log.caloriesBurned} cal",
                  isDark,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  Icons.signal_cellular_alt,
                  log.difficulty.capitalizeFirst!,
                  isDark,
                ),
              ),
            ],
          ),
          if (log.notes != null && log.notes!.isNotEmpty) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.note, size: 16, color: AppColors.primary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      log.notes!,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white : AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white70 : AppColors.textDark,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMoodIcon(String mood) {
    IconData icon;
    Color color;

    switch (mood) {
      case 'great':
        icon = Icons.sentiment_very_satisfied;
        color = Color(0xFF00B894);
        break;
      case 'good':
        icon = Icons.sentiment_satisfied;
        color = Color(0xFF00B894);
        break;
      case 'okay':
        icon = Icons.sentiment_neutral;
        color = Color(0xFFFDCB6E);
        break;
      case 'bad':
        icon = Icons.sentiment_dissatisfied;
        color = Color(0xFFFF7675);
        break;
      default:
        icon = Icons.sentiment_satisfied;
        color = Color(0xFF00B894);
    }

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: AppColors.textGrey.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            "No workout history yet",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Complete your first workout to see it here",
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }
}