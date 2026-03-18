// lib/views/dashboard_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/auth_controller.dart';
import '../controllers/theme_controller.dart';
import 'main_shell.dart';
import '../controllers/workout_controller.dart';
import '../controllers/workout_history_controller.dart';
import '../core/theme/app_colors.dart';
import '../services/goal_recommendation_service.dart';
import '../models/workout_model.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DashboardView extends StatelessWidget {
  final bool showBackButton;
  const DashboardView({super.key, this.showBackButton = true});

  // Use find+put with tag to avoid duplicate instance per getter call
  WorkoutController get _wc => Get.find<WorkoutController>();
  WorkoutHistoryController get _hc => Get.find<WorkoutHistoryController>();
  AuthController get _ac => Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    // Ensure controllers are registered (idempotent)
    if (!Get.isRegistered<WorkoutController>()) Get.put(WorkoutController());
    if (!Get.isRegistered<WorkoutHistoryController>()) Get.put(WorkoutHistoryController());

    return Obx(() {
      final isDark = ThemeController.to.isDark.value;
      final userId = _ac.firebaseUser.value?.uid;
      if (userId == null) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return Scaffold(
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
          builder: (ctx, snap) {
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            final ud = snap.data!.data() as Map<String, dynamic>?;
            final userName = ud?['displayName'] ?? (ud?['email'] as String?)?.split('@')[0] ?? 'User';
            final goal = (ud?['goal'] as String?) ?? 'Stay Fit';
            final level = (ud?['level'] as String?) ?? 'Beginner';
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _wc.updateGoalAndLevel(goal, level);
            });
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark ? [AppColors.backgroundDark, const Color(0xFF1C2128)] : [AppColors.backgroundLight, Colors.white],
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(child: Column(children: [
                _appBar(isDark, userName),
                Expanded(child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _welcome(isDark, userName, goal),
                    const SizedBox(height: 24),
                    _todayCard(isDark, goal),
                    const SizedBox(height: 24),
                    _quickStats(isDark),
                    const SizedBox(height: 24),
                    _activityGrid(isDark),
                    const SizedBox(height: 24),
                    _recommended(isDark, goal),
                    const SizedBox(height: 24),
                    _quickActions(isDark),
                    const SizedBox(height: 24),
                    _quote(isDark, goal, (ud?['streak'] as int?) ?? 0),
                    const SizedBox(height: 20),
                  ]),
                )),
              ])),
            );
          },
        ),
      );
    });
  }

  // ── App bar ─────────────────────────────────────────────────────────────────
  Widget _appBar(bool isDark, String userName) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    decoration: BoxDecoration(
      color: isDark ? AppColors.cardDark : Colors.white,
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.03), blurRadius: 10, offset: const Offset(0, 2))],
    ),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, AppColors.gradientEnd]), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.fitness_center, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('FitFlow', style: TextStyle(color: isDark ? Colors.white : AppColors.textDark, fontSize: 17, fontWeight: FontWeight.bold)),
          Text(DateFormat('EEE, MMM d').format(DateTime.now()), style: const TextStyle(color: AppColors.textGrey, fontSize: 11)),
        ]),
      ]),
      Row(children: [
        Container(
          decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.withOpacity(0.09), borderRadius: BorderRadius.circular(10)),
          child: IconButton(icon: Icon(Icons.notifications_outlined, color: isDark ? Colors.white : AppColors.textDark, size: 20), onPressed: () {}, padding: const EdgeInsets.all(8)),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _nav(4),
          child: Container(width: 36, height: 36,
            decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.secondary, AppColors.accent]), shape: BoxShape.circle),
            child: Center(child: Text(_initials(userName), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)))),
        ),
      ]),
    ]),
  );

  // ── Welcome card ─────────────────────────────────────────────────────────────
  Widget _welcome(bool isDark, String userName, String goal) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.gradientEnd]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Welcome Back! 👋', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 3),
            Text(userName, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 15, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.flag, color: Colors.white, size: 13),
              const SizedBox(width: 4),
              Text(goal, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
            ]),
          ),
        ]),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
          child: Obx(() => Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _metric(_hc.currentStreak.value.toString(), 'Streak 🔥'),
            Container(width: 1, height: 36, color: Colors.white.withOpacity(0.3)),
            _metric(_hc.totalWorkouts.value.toString(), 'Workouts'),
            Container(width: 1, height: 36, color: Colors.white.withOpacity(0.3)),
            _metric('${_hc.totalCalories.value}', 'Cal Burned'),
          ])),
        ),
      ]),
    );
  }

  Widget _metric(String value, String label) => Column(children: [
    Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
    const SizedBox(height: 2),
    Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10)),
  ]);

  // ── Today's workout card ──────────────────────────────────────────────────────
  Widget _todayCard(bool isDark, String goal) {
    final cfg = GoalRecommendationService.getGoalConfig(goal);
    final goalColor = Color(cfg['color'] as int);
    final tip = cfg['tip'] as String;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: goalColor.withOpacity(isDark ? 0.12 : 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: goalColor.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: goalColor.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.auto_awesome, color: goalColor, size: 18)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Today's Recommendation", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
            Text('Based on: $goal', style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
          ])),
        ]),
        const SizedBox(height: 14),
        Obx(() {
          final w = _wc.todaysWorkout.value;
          if (w == null) {
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Icon(Icons.check_circle, color: AppColors.success, size: 22),
                const SizedBox(width: 10),
                Expanded(child: Text("You've hit your weekly target! Great work! 🎉", style: TextStyle(color: isDark ? Colors.white : AppColors.textDark, fontWeight: FontWeight.w600, fontSize: 13))),
              ]),
            );
          }
          return GestureDetector(
            onTap: () => Get.toNamed('/workout-detail', arguments: w),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: goalColor.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: w.imageUrl != null
                    ? CachedNetworkImage(imageUrl: w.imageUrl!, width: 68, height: 68, fit: BoxFit.cover,
                        placeholder: (c, u) => Container(width: 68, height: 68, color: goalColor.withOpacity(0.15), child: Icon(Icons.fitness_center, color: goalColor)),
                        errorWidget: (c, u, e) => Container(width: 68, height: 68, color: goalColor.withOpacity(0.15), child: Icon(Icons.fitness_center, color: goalColor)))
                    : Container(width: 68, height: 68, color: goalColor.withOpacity(0.15), child: Icon(Icons.fitness_center, color: goalColor)),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(w.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.timer, size: 12, color: AppColors.textGrey),
                    const SizedBox(width: 3),
                    Text('${w.duration} min', style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
                    const SizedBox(width: 10),
                    const Icon(Icons.local_fire_department, size: 12, color: AppColors.textGrey),
                    const SizedBox(width: 3),
                    Text('${w.caloriesBurned} cal', style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
                  ]),
                  const SizedBox(height: 7),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: goalColor, borderRadius: BorderRadius.circular(20)),
                    child: const Text('Start Workout →', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ])),
              ]),
            ),
          );
        }),
        const SizedBox(height: 10),
        Row(children: [
          Icon(Icons.lightbulb_outline, color: goalColor, size: 13),
          const SizedBox(width: 5),
          Expanded(child: Text(tip, style: const TextStyle(fontSize: 11, color: AppColors.textGrey))),
        ]),
      ]),
    );
  }

  // ── Quick stats ───────────────────────────────────────────────────────────────
  Widget _quickStats(bool isDark) => Obx(() => Row(children: [
    Expanded(child: _statCard('Calories', '${_hc.totalCalories.value}', 'Total burned',
        Icons.local_fire_department, [const Color(0xFFFF6B9D), const Color(0xFFFF8E53)],
        (_hc.totalCalories.value / 3000.0).clamp(0.0, 1.0), isDark)),
    const SizedBox(width: 14),
    Expanded(child: _statCard('Workouts', '${_hc.totalWorkouts.value}', 'Total done',
        Icons.fitness_center, [const Color(0xFF00D4AA), const Color(0xFF00A896)],
        (_hc.totalWorkouts.value / 50.0).clamp(0.0, 1.0), isDark)),
  ]));

  Widget _statCard(String title, String value, String sub, IconData icon, List<Color> colors, double prog, bool isDark) =>
    Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.18 : 0.04), blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(gradient: LinearGradient(colors: colors), borderRadius: BorderRadius.circular(11)), child: Icon(icon, color: Colors.white, size: 20)),
        const SizedBox(height: 10),
        Text(title, style: const TextStyle(color: AppColors.textGrey, fontSize: 11, fontWeight: FontWeight.w500)),
        const SizedBox(height: 3),
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
        const SizedBox(height: 2),
        Text(sub, style: const TextStyle(color: AppColors.textGrey, fontSize: 10)),
        const SizedBox(height: 10),
        ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(
          value: prog, minHeight: 5,
          backgroundColor: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.15),
          valueColor: AlwaysStoppedAnimation(colors[0]),
        )),
      ]),
    );

  // ── Activity grid ─────────────────────────────────────────────────────────────
  Widget _activityGrid(bool isDark) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text("Today's Activity", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
      TextButton(onPressed: () {}, child: const Text('See All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13))),
    ]),
    const SizedBox(height: 10),
    GridView.count(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 1.15,
      children: [
        _actCard('Steps', '10,234', '15K goal', Icons.directions_walk, [const Color(0xFF4E54C8), const Color(0xFF8F94FB)], 0.68, isDark),
        _actCard('Sleep', '7.5 hrs', '8 hrs goal', Icons.bedtime, [const Color(0xFF7C4DFF), const Color(0xFF9575CD)], 0.94, isDark),
        _actCard('Active', '45 min', '60 min', Icons.timer, [const Color(0xFFFF6B9D), const Color(0xFFFF8E53)], 0.75, isDark),
        _actCard('Heart', '72 bpm', 'Resting', Icons.favorite, [const Color(0xFFFF5252), const Color(0xFFFF8A80)], 0.8, isDark),
      ],
    ),
  ]);

  Widget _actCard(String title, String value, String sub, IconData icon, List<Color> colors, double prog, bool isDark) =>
    Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white, borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.18 : 0.04), blurRadius: 12, offset: const Offset(0, 3))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(gradient: LinearGradient(colors: colors), borderRadius: BorderRadius.circular(9)), child: Icon(icon, color: Colors.white, size: 18)),
          Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2), decoration: BoxDecoration(color: colors[0].withOpacity(0.1), borderRadius: BorderRadius.circular(7)),
            child: Text('${(prog * 100).toInt()}%', style: TextStyle(color: colors[0], fontSize: 9, fontWeight: FontWeight.bold))),
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: AppColors.textGrey, fontSize: 11, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
          Text(sub, style: const TextStyle(fontSize: 10, color: AppColors.textGrey)),
        ]),
      ]),
    );

  // ── Recommended workouts ──────────────────────────────────────────────────────
  Widget _recommended(bool isDark, String goal) {
    final cfg = GoalRecommendationService.getGoalConfig(goal);
    final goalColor = Color(cfg['color'] as int);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Recommended for You', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
          Text('Based on: $goal', style: TextStyle(fontSize: 11, color: goalColor, fontWeight: FontWeight.w500)),
        ]),
        TextButton(onPressed: () => Get.toNamed('/workout-library'), child: const Text('View All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13))),
      ]),
      const SizedBox(height: 10),
      Obx(() {
        final list = _wc.recommendedWorkouts;
        if (list.isEmpty) return const Center(child: CircularProgressIndicator());
        return SizedBox(
          height: 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: list.length,
            itemBuilder: (_, i) => _recCard(list[i], isDark, goalColor),
          ),
        );
      }),
    ]);
  }

  Widget _recCard(Workout w, bool isDark, Color accent) => GestureDetector(
    onTap: () => Get.toNamed('/workout-detail', arguments: w),
    child: Container(
      width: 155, margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white, borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.18 : 0.04), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18)),
          child: w.imageUrl != null
            ? CachedNetworkImage(imageUrl: w.imageUrl!, height: 95, width: double.infinity, fit: BoxFit.cover,
                placeholder: (c, u) => Container(height: 95, color: accent.withOpacity(0.15), child: Icon(Icons.fitness_center, color: accent, size: 28)),
                errorWidget: (c, u, e) => Container(height: 95, color: accent.withOpacity(0.15), child: Icon(Icons.fitness_center, color: accent, size: 28)))
            : Container(height: 95, color: accent.withOpacity(0.15), child: Icon(Icons.fitness_center, color: accent, size: 28)),
        ),
        Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(w.name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 5),
          Row(children: [
            const Icon(Icons.timer, size: 10, color: AppColors.textGrey), const SizedBox(width: 2),
            Text('${w.duration}m', style: const TextStyle(fontSize: 10, color: AppColors.textGrey)),
            const SizedBox(width: 6),
            const Icon(Icons.local_fire_department, size: 10, color: AppColors.textGrey), const SizedBox(width: 2),
            Text('${w.caloriesBurned}', style: const TextStyle(fontSize: 10, color: AppColors.textGrey)),
          ]),
        ])),
      ]),
    ),
  );

  // ── Quick actions ─────────────────────────────────────────────────────────────
  Widget _quickActions(bool isDark) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('Quick Actions', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
    const SizedBox(height: 10),
    Row(children: [
      Expanded(child: _actionBtn('Workouts', Icons.play_circle_filled, [AppColors.primary, AppColors.gradientEnd], () => _nav(1))),
      const SizedBox(width: 12),
      Expanded(child: _actionBtn('Exercises', Icons.fitness_center, [const Color(0xFF4E54C8), const Color(0xFF8F94FB)], () => _nav(3))),
    ]),
    const SizedBox(height: 12),
    Row(children: [
      Expanded(child: _actionBtn('Progress', Icons.show_chart, [const Color(0xFF7C4DFF), const Color(0xFF9575CD)], () => _nav(2))),
      const SizedBox(width: 12),
      Expanded(child: _actionBtn('Measures', Icons.straighten, [const Color(0xFF00B894), const Color(0xFF00A896)], () => Get.toNamed('/body-measurements'))),
    ]),
  ]);

  Widget _actionBtn(String label, IconData icon, List<Color> colors, VoidCallback onTap) =>
    Container(
      decoration: BoxDecoration(gradient: LinearGradient(colors: colors), borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: colors[0].withOpacity(0.28), blurRadius: 12, offset: const Offset(0, 6))]),
      child: Material(color: Colors.transparent,
        child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16),
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14), child: Column(children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 7),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ])))),
    );

  // ── Motivational quote ────────────────────────────────────────────────────────
  Widget _quote(bool isDark, String goal, int streak) {
    final msg = GoalRecommendationService.getMotivationalMessage(goal, streak);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF7C4DFF), Color(0xFF9575CD)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF7C4DFF).withOpacity(0.28), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.format_quote, color: Colors.white, size: 22)),
        const SizedBox(width: 12),
        Expanded(child: Text(msg, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600))),
      ]),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────
  String _initials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return (parts[0][0] + parts[1][0]).toUpperCase();
    return name[0].toUpperCase();
  }

  void _nav(int tab) {
    try { Get.find<ShellController>().tabIndex.value = tab; } catch (_) {}
  }
}
