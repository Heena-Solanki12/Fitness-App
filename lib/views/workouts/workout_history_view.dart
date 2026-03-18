// lib/views/workouts/workout_history_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/theme_controller.dart';
import '../../controllers/workout_history_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../models/workout_log_model.dart';

class WorkoutHistoryView extends StatelessWidget {
  const WorkoutHistoryView({super.key});
  WorkoutHistoryController get controller => Get.put(WorkoutHistoryController());

  @override
  Widget build(BuildContext context) {
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
          child: SafeArea(
            child: Column(
              children: [
                _appBar(isDark),
                _statsCards(isDark),
                _filterChips(isDark),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
                    if (controller.filteredLogs.isEmpty) return _emptyState(isDark);
                    return _historyList(isDark);
                  }),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _appBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.03), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          IconButton(icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : AppColors.textDark, size: 20), onPressed: () => Get.back()),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Workout History', style: TextStyle(color: isDark ? Colors.white : AppColors.textDark, fontSize: 20, fontWeight: FontWeight.bold)),
              Obx(() => Text('${controller.totalWorkouts} workouts completed', style: const TextStyle(color: AppColors.textGrey, fontSize: 12))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statsCards(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(child: Obx(() => _statCard(Icons.fitness_center, '${controller.totalWorkouts}', 'Workouts', [const Color(0xFF4E54C8), const Color(0xFF8F94FB)], isDark))),
          const SizedBox(width: 12),
          Expanded(child: Obx(() => _statCard(Icons.local_fire_department, '${controller.totalCalories}', 'Calories', [const Color(0xFFFF6B9D), const Color(0xFFFF8E53)], isDark))),
          const SizedBox(width: 12),
          Expanded(child: Obx(() => _statCard(Icons.timer, '${controller.totalMinutes}', 'Minutes', [const Color(0xFF00B894), const Color(0xFF00A896)], isDark))),
        ],
      ),
    );
  }

  Widget _statCard(IconData icon, String value, String label, List<Color> colors, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(gradient: LinearGradient(colors: colors), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
        ],
      ),
    );
  }

  Widget _filterChips(bool isDark) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: ['All', 'Week', 'Month', 'Year'].map((f) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Obx(() => _chip(f, controller.selectedFilter.value == f, () => controller.filterByPeriod(f), isDark)),
        )).toList(),
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected ? const LinearGradient(colors: [AppColors.primary, AppColors.gradientEnd]) : null,
          color: selected ? null : (isDark ? AppColors.cardDark : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? Colors.transparent : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2))),
        ),
        child: Text(label, style: TextStyle(color: selected ? Colors.white : (isDark ? Colors.white70 : AppColors.textDark), fontWeight: selected ? FontWeight.w600 : FontWeight.w500)),
      ),
    );
  }

  Widget _historyList(bool isDark) {
    return Obx(() => ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: controller.filteredLogs.length,
      itemBuilder: (context, index) => _historyCard(controller.filteredLogs[index], isDark),
    ));
  }

  Widget _historyCard(WorkoutLog log, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 15, offset: const Offset(0, 5))],
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
                    Text(log.workoutName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
                    const SizedBox(height: 4),
                    Text(DateFormat('EEEE, MMM d, yyyy').format(log.date), style: const TextStyle(fontSize: 13, color: AppColors.textGrey)),
                  ],
                ),
              ),
              _moodIcon(log.mood),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _statItem(Icons.timer, log.formattedDuration, isDark)),
              Expanded(child: _statItem(Icons.local_fire_department, '${log.caloriesBurned} cal', isDark)),
              Expanded(child: _statItem(Icons.signal_cellular_alt, log.difficulty.capitalizeFirst!, isDark)),
            ],
          ),
          if (log.notes != null && log.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.note, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(log.notes!, style: TextStyle(fontSize: 13, color: isDark ? Colors.white : AppColors.textDark))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : AppColors.textDark, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _moodIcon(String mood) {
    final map = {
      'great': [Icons.sentiment_very_satisfied, const Color(0xFF00B894)],
      'good': [Icons.sentiment_satisfied, const Color(0xFF00B894)],
      'okay': [Icons.sentiment_neutral, const Color(0xFFFDCB6E)],
      'bad': [Icons.sentiment_dissatisfied, const Color(0xFFFF7675)],
    };
    final entry = map[mood] ?? [Icons.sentiment_satisfied, const Color(0xFF00B894)];
    final color = entry[1] as Color;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
      child: Icon(entry[0] as IconData, color: color, size: 24),
    );
  }

  Widget _emptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: AppColors.textGrey.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('No workout history yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
          const SizedBox(height: 8),
          const Text('Complete your first workout to see it here', style: TextStyle(fontSize: 14, color: AppColors.textGrey)),
        ],
      ),
    );
  }
}
