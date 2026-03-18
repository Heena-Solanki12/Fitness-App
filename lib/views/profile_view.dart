// lib/views/profile_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/auth_controller.dart';
import '../controllers/theme_controller.dart';
import '../controllers/workout_history_controller.dart';
import '../core/theme/app_colors.dart';
import '../controllers/workout_controller.dart';
import '../services/goal_recommendation_service.dart';

class ProfileView extends StatelessWidget {
  final bool showBackButton;
  const ProfileView({super.key, this.showBackButton = true});
  AuthController get _ac => Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = ThemeController.to.isDark.value;
      final uid = _ac.firebaseUser.value?.uid;
      if (uid == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
      return Scaffold(
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
          builder: (ctx, snap) {
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            final ud = snap.data!.data() as Map<String, dynamic>?;
            final name    = ud?['displayName'] ?? (ud?['email'] as String?)?.split('@')[0] ?? 'User';
            final email   = (ud?['email'] as String?) ?? '';
            final goal    = (ud?['goal'] as String?) ?? 'Stay Fit';
            final weight  = ud?['weight']?.toString() ?? '0';
            final height  = ud?['height']?.toString() ?? '0';
            final level   = (ud?['level'] as String?) ?? 'Beginner';
            // Real-time: prefer Firestore counts; fall back to live controller counts
            final hc = Get.isRegistered<WorkoutHistoryController>() ? Get.find<WorkoutHistoryController>() : null;
            final totalWorkouts = (ud?['totalWorkouts'] as int?) ?? (hc?.totalWorkouts.value ?? 0);
            final streak        = (ud?['streak'] as int?) ?? (hc?.currentStreak.value ?? 0);
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark ? [AppColors.backgroundDark, const Color(0xFF1C2128)] : [AppColors.backgroundLight, Colors.white],
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(child: Column(children: [
                _appBar(context, isDark, uid, ud),
                Expanded(child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(children: [
                    _header(isDark, name, email, goal, totalWorkouts, streak),
                    const SizedBox(height: 20),
                    _goalBanner(isDark, goal, level),
                    const SizedBox(height: 20),
                    _statsCards(isDark, weight, height),
                    const SizedBox(height: 20),
                    _infoSection(isDark, goal, level, weight, height),
                    const SizedBox(height: 20),
                    _weeklyPlan(isDark, goal, level),
                    const SizedBox(height: 20),
                    _achievements(isDark, totalWorkouts, streak),
                    const SizedBox(height: 20),
                    _settings(isDark),
                    const SizedBox(height: 20),
                    _logoutBtn(isDark),
                    const SizedBox(height: 30),
                  ]),
                )),
              ])),
            );
          },
        ),
      );
    });
  }

  Widget _appBar(BuildContext ctx, bool isDark, String uid, Map<String, dynamic>? ud) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white,
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.03), blurRadius: 10, offset: const Offset(0, 2))]),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(children: [
        if (showBackButton) IconButton(icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : AppColors.textDark, size: 20), onPressed: () => Get.back()) else const SizedBox(width: 8),
        const SizedBox(width: 4),
        Text('Profile', style: TextStyle(color: isDark ? Colors.white : AppColors.textDark, fontSize: 20, fontWeight: FontWeight.bold)),
      ]),
      GestureDetector(
        onTap: () => showModalBottomSheet(context: ctx, isScrollControlled: true, backgroundColor: Colors.transparent,
          builder: (_) => _EditSheet(uid: uid, ud: ud, isDark: isDark)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, AppColors.gradientEnd]), borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.edit, color: Colors.white, size: 15),
            SizedBox(width: 5),
            Text('Edit', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    ]),
  );

  Widget _header(bool isDark, String name, String email, String goal, int workouts, int streak) {
    final cfg = GoalRecommendationService.getGoalConfig(goal);
    final goalColor = Color(cfg['color'] as int);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.gradientEnd]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(children: [
        Stack(children: [
          Container(width: 96, height: 96, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
            child: Center(child: Text(_initials(name), style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: AppColors.primary)))),
          Positioned(bottom: 0, right: 0, child: Container(padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: goalColor, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2.5)),
            child: const Icon(Icons.fitness_center, color: Colors.white, size: 13))),
        ]),
        const SizedBox(height: 14),
        Text(name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(email, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
        const SizedBox(height: 18),
        // Live stats row — uses WorkoutHistoryController reactively
        Obx(() {
          final hc = Get.isRegistered<WorkoutHistoryController>() ? Get.find<WorkoutHistoryController>() : null;
          final liveWorkouts = hc?.totalWorkouts.value ?? workouts;
          final liveStreak   = hc?.currentStreak.value ?? streak;
          return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _profileStat(liveStreak.toString(), 'Day Streak', Icons.local_fire_department),
            Container(width: 1, height: 36, color: Colors.white.withOpacity(0.3)),
            _profileStat(liveWorkouts.toString(), 'Workouts', Icons.fitness_center),
            Container(width: 1, height: 36, color: Colors.white.withOpacity(0.3)),
            _profileStat(_badges(liveWorkouts, liveStreak).toString(), 'Badges', Icons.emoji_events),
          ]);
        }),
      ]),
    );
  }

  Widget _profileStat(String v, String lbl, IconData icon) => Column(children: [
    Icon(icon, color: Colors.white, size: 22),
    const SizedBox(height: 6),
    Text(v, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
    const SizedBox(height: 3),
    Text(lbl, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11)),
  ]);

  String _initials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name[0].toUpperCase();
  }

  int _badges(int workouts, int streak) {
    int c = 0;
    if (workouts >= 1) c++; if (workouts >= 10) c++; if (workouts >= 25) c++; if (workouts >= 50) c++;
    if (streak >= 7) c++; if (streak >= 30) c++;
    return c;
  }

  Widget _goalBanner(bool isDark, String goal, String level) {
    final cfg = GoalRecommendationService.getGoalConfig(goal);
    final c = Color(cfg['color'] as int);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: c.withOpacity(isDark ? 0.14 : 0.08), borderRadius: BorderRadius.circular(20), border: Border.all(color: c.withOpacity(0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.flag, color: c, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Goal: $goal', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
            Text(cfg['message'] as String, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(20)),
            child: Text(level, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
        ]),
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.05) : Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Row(children: [Icon(Icons.lightbulb_outline, color: c, size: 15), const SizedBox(width: 8), Expanded(child: Text(cfg['tip'] as String, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)))])),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Weekly target:',
              style: TextStyle(fontSize: 12, color: AppColors.textGrey),
            ),
            const SizedBox(width: 10),

            Expanded(
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 4,
                children: List.generate(7, (i) => Container(
                  width: 20,
                  height: 7,
                  decoration: BoxDecoration(
                    color: i < (cfg['weeklyWorkouts'] as int)
                        ? c
                        : (isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                )),
              ),
            ),
          ],
        )
      ]),
    );
  }

  Widget _statsCards(bool isDark, String weight, String height) => Row(children: [
    Expanded(child: _statCard('Weight', '$weight kg', Icons.monitor_weight_outlined, [const Color(0xFFFF6B9D), const Color(0xFFFF8E53)], isDark)),
    const SizedBox(width: 14),
    Expanded(child: _statCard('Height', '$height cm', Icons.height, [const Color(0xFF4E54C8), const Color(0xFF8F94FB)], isDark)),
  ]);

  Widget _statCard(String title, String value, IconData icon, List<Color> colors, bool isDark) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white, borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 14, offset: const Offset(0, 4))]),
    child: Column(children: [
      Container(padding: const EdgeInsets.all(11), decoration: BoxDecoration(gradient: LinearGradient(colors: colors), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: Colors.white, size: 26)),
      const SizedBox(height: 10),
      Text(title, style: const TextStyle(color: AppColors.textGrey, fontSize: 12, fontWeight: FontWeight.w500)),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
    ]),
  );

  Widget _infoSection(bool isDark, String goal, String level, String weight, String height) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white, borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 14, offset: const Offset(0, 4))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Personal Information', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
      const SizedBox(height: 18),
      _infoRow(Icons.flag, 'Goal', goal, isDark),
      const SizedBox(height: 14),
      _infoRow(Icons.trending_up, 'Fitness Level', level, isDark),
      const SizedBox(height: 14),
      _infoRow(Icons.calculate_outlined, 'BMI', _calcBMI(weight, height), isDark),
    ]),
  );

  String _calcBMI(String w, String h) {
    try {
      final ww = double.parse(w); final hh = double.parse(h) / 100;
      if (hh <= 0) return 'N/A';
      final bmi = ww / (hh * hh);
      final cat = bmi < 18.5 ? ' (Underweight)' : bmi < 25 ? ' (Normal)' : bmi < 30 ? ' (Overweight)' : ' (Obese)';
      return '${bmi.toStringAsFixed(1)}$cat';
    } catch (_) { return 'N/A'; }
  }

  Widget _infoRow(IconData icon, String label, String value, bool isDark) => Row(children: [
    Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppColors.primary, size: 18)),
    const SizedBox(width: 14),
    Expanded(child: Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 14, fontWeight: FontWeight.w500))),
    Flexible(child: Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.textDark), textAlign: TextAlign.end)),
  ]);

  Widget _weeklyPlan(bool isDark, String goal, String level) {
    final plan = GoalRecommendationService.getWeeklyPlan(goal, level);
    final today = DateTime.now().weekday;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 14, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Your Weekly Plan', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
        const SizedBox(height: 3),
        Text('Personalized for: $goal', style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500)),
        const SizedBox(height: 14),
        ...plan.asMap().entries.map((e) {
          final i = e.key; final day = e.value;
          final isToday = (i + 1) == today; final isActive = day['active'] as bool;
          return Container(
            margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: isToday ? AppColors.primary.withOpacity(0.1) : (isDark ? AppColors.backgroundDark : AppColors.backgroundLight),
              borderRadius: BorderRadius.circular(12),
              border: isToday ? Border.all(color: AppColors.primary.withOpacity(0.4)) : null,
            ),
            child: Row(children: [
              Container(width: 34, height: 34,
                decoration: BoxDecoration(
                  color: isToday ? AppColors.primary : (isActive ? AppColors.primary.withOpacity(0.12) : Colors.grey.withOpacity(0.1)),
                  borderRadius: BorderRadius.circular(9)),
                child: Center(child: Text(day['day'] as String, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isToday ? Colors.white : (isActive ? AppColors.primary : AppColors.textGrey))))),
              const SizedBox(width: 11),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(day['type'] as String, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.textDark)),
                Text(day['focus'] as String, style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
              ])),
              if (isToday)
                Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
                  child: const Text('Today', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)))
              else Icon(isActive ? Icons.fitness_center : Icons.hotel, size: 15, color: isActive ? AppColors.primary.withOpacity(0.5) : AppColors.textGrey),
            ]),
          );
        }),
      ]),
    );
  }

  Widget _achievements(bool isDark, int workouts, int streak) {
    final list = [
      {'icon': Icons.star, 'title': 'First Workout', 'color': const Color(0xFF00D4AA), 'unlocked': workouts >= 1},
      {'icon': Icons.local_fire_department, 'title': '7 Day Streak', 'color': const Color(0xFFFF6B9D), 'unlocked': streak >= 7},
      {'icon': Icons.fitness_center, 'title': '10 Workouts', 'color': const Color(0xFF4E54C8), 'unlocked': workouts >= 10},
      {'icon': Icons.emoji_events, 'title': '25 Workouts', 'color': const Color(0xFFFFD700), 'unlocked': workouts >= 25},
      {'icon': Icons.local_fire_department, 'title': '30 Day Streak', 'color': const Color(0xFFFF8C00), 'unlocked': streak >= 30},
      {'icon': Icons.trending_up, 'title': '50 Workouts', 'color': const Color(0xFF7C4DFF), 'unlocked': workouts >= 50},
    ];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 14, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Achievements', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
          Text('${list.where((a) => a['unlocked'] == true).length}/${list.length}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 14),
        Wrap(spacing: 14, runSpacing: 14, children: list.map((a) {
          final ok = a['unlocked'] as bool;
          final c = a['color'] as Color;
          return SizedBox(width: 68, child: Column(children: [
            Container(padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: ok ? c.withOpacity(0.14) : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1)),
                shape: BoxShape.circle,
                border: ok ? Border.all(color: c.withOpacity(0.3), width: 2) : null,
              ),
              child: Icon(a['icon'] as IconData, color: ok ? c : Colors.grey, size: 22)),
            const SizedBox(height: 6),
            Text(a['title'] as String, textAlign: TextAlign.center, style: TextStyle(fontSize: 9, color: ok ? (isDark ? Colors.white : AppColors.textDark) : Colors.grey, fontWeight: FontWeight.w500)),
          ]));
        }).toList()),
      ]),
    );
  }

  // ── Complete Settings section ─────────────────────────────────────────────────
  Widget _settings(bool isDark) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white, borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 14, offset: const Offset(0, 4))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Settings', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
      const SizedBox(height: 16),
      // Dark mode toggle
      Obx(() => _settingToggle(
        icon: Icons.dark_mode,
        title: 'Dark Mode',
        subtitle: 'Switch between light and dark',
        value: ThemeController.to.isDark.value,
        isDark: isDark,
        onChanged: (v) => ThemeController.to.setDark(v),
      )),
      _divider(isDark),
      // Notifications (functional UI)
      _settingTile(
        icon: Icons.notifications_outlined,
        title: 'Notifications',
        subtitle: 'Workout reminders & tips',
        isDark: isDark,
        onTap: () => _notifDialog(isDark),
      ),
      _divider(isDark),
      // Units
      _settingTile(
        icon: Icons.straighten_outlined,
        title: 'Units',
        subtitle: 'Metric (kg, cm)',
        isDark: isDark,
        onTap: () => Get.snackbar('Coming Soon', 'Unit switching will be available soon',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.primary.withOpacity(0.1), colorText: AppColors.primary, margin: const EdgeInsets.all(16)),
      ),
      _divider(isDark),
      // Privacy
      _settingTile(
        icon: Icons.privacy_tip_outlined,
        title: 'Privacy',
        subtitle: 'Data & account settings',
        isDark: isDark,
        onTap: () => _privacyDialog(isDark),
      ),
      _divider(isDark),
      // Help & Support
      _settingTile(
        icon: Icons.help_outline_rounded,
        title: 'Help & Support',
        subtitle: 'FAQs and contact',
        isDark: isDark,
        onTap: () => _helpDialog(isDark),
      ),
      _divider(isDark),
      // App version
      Row(children: [
        Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.info_outline, color: AppColors.primary, size: 18)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('About FitFlow', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.textDark)),
          const Text('Version 1.0.0', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
        ])),
        const Text('🏋️', style: TextStyle(fontSize: 20)),
      ]),
    ]),
  );

  Widget _divider(bool isDark) => Divider(height: 28, color: isDark ? Colors.white.withOpacity(0.07) : Colors.grey.withOpacity(0.12));

  Widget _settingTile({required IconData icon, required String title, required String subtitle, required bool isDark, required VoidCallback onTap}) =>
    InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Row(children: [
      Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppColors.primary, size: 18)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.textDark)),
        const SizedBox(height: 2),
        Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
      ])),
      const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textGrey),
    ]));

  Widget _settingToggle({required IconData icon, required String title, required String subtitle, required bool value, required bool isDark, required Function(bool) onChanged}) =>
    Row(children: [
      Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppColors.primary, size: 18)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.textDark)),
        const SizedBox(height: 2),
        Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
      ])),
      Switch(value: value, onChanged: onChanged, activeColor: AppColors.primary),
    ]);

  void _notifDialog(bool isDark) {
    final reminders = {'Workout Reminder': true.obs, 'Weekly Summary': true.obs, 'Streak Alert': false.obs};
    Get.dialog(AlertDialog(
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Notifications', style: TextStyle(color: isDark ? Colors.white : AppColors.textDark, fontWeight: FontWeight.bold)),
      content: Column(mainAxisSize: MainAxisSize.min, children: reminders.entries.map((e) =>
        Obx(() => SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(e.key, style: TextStyle(color: isDark ? Colors.white : AppColors.textDark, fontSize: 14)),
          value: e.value.value,
          onChanged: (v) => e.value.value = v,
          activeColor: AppColors.primary,
        ))
      ).toList()),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Close', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600))),
      ],
    ));
  }

  void _privacyDialog(bool isDark) {
    Get.dialog(AlertDialog(
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Privacy & Data', style: TextStyle(color: isDark ? Colors.white : AppColors.textDark, fontWeight: FontWeight.bold)),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        _privacyItem(Icons.lock_outline, 'Your data is stored securely in Firebase', isDark),
        const SizedBox(height: 12),
        _privacyItem(Icons.sync_outlined, 'Data syncs across your devices', isDark),
        const SizedBox(height: 12),
        _privacyItem(Icons.delete_outline, 'You can delete your account at any time', isDark),
      ]),
      actions: [
        TextButton(onPressed: () { Get.back(); _deleteAccountDialog(isDark); },
          child: const Text('Delete Account', style: TextStyle(color: AppColors.error))),
        TextButton(onPressed: () => Get.back(), child: const Text('Close', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600))),
      ],
    ));
  }

  Widget _privacyItem(IconData icon, String text, bool isDark) => Row(children: [
    Icon(icon, size: 16, color: AppColors.primary),
    const SizedBox(width: 10),
    Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : AppColors.textGrey))),
  ]);

  void _deleteAccountDialog(bool isDark) {
    Get.dialog(AlertDialog(
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Delete Account?', style: TextStyle(color: isDark ? Colors.white : AppColors.textDark, fontWeight: FontWeight.bold)),
      content: Text('This will permanently delete all your data. This cannot be undone.', style: TextStyle(color: AppColors.textGrey)),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel', style: TextStyle(color: AppColors.textGrey))),
        TextButton(onPressed: () {
          Get.back();
          Get.snackbar('Feature Coming', 'Account deletion will be available in a future update', snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
        }, child: const Text('Delete', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold))),
      ],
    ));
  }

  void _helpDialog(bool isDark) {
    Get.dialog(AlertDialog(
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Help & Support', style: TextStyle(color: isDark ? Colors.white : AppColors.textDark, fontWeight: FontWeight.bold)),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        _helpItem('📖', 'Log workouts from the Workouts tab', isDark),
        const SizedBox(height: 10),
        _helpItem('📏', 'Track body measurements in the Progress tab', isDark),
        const SizedBox(height: 10),
        _helpItem('📸', 'Add progress photos via Progress → Photos', isDark),
        const SizedBox(height: 10),
        _helpItem('🎯', 'Update your goal in Edit Profile', isDark),
        const SizedBox(height: 10),
        _helpItem('📧', 'Contact: support@fitflow.app', isDark),
      ]),
      actions: [TextButton(onPressed: () => Get.back(), child: const Text('Got it', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)))],
    ));
  }

  Widget _helpItem(String emoji, String text, bool isDark) => Row(children: [
    Text(emoji, style: const TextStyle(fontSize: 16)),
    const SizedBox(width: 10),
    Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : AppColors.textGrey))),
  ]);

  Widget _logoutBtn(bool isDark) => Container(
    width: double.infinity, height: 54,
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.error, width: 2)),
    child: Material(color: Colors.transparent,
      child: InkWell(
        onTap: () => Get.dialog(AlertDialog(
          backgroundColor: isDark ? AppColors.cardDark : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Logout', style: TextStyle(color: isDark ? Colors.white : AppColors.textDark, fontWeight: FontWeight.bold)),
          content: Text('Are you sure you want to logout?', style: TextStyle(color: AppColors.textGrey)),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Cancel', style: TextStyle(color: AppColors.textGrey))),
            TextButton(onPressed: () { Get.back(); Get.find<AuthController>().logout(); },
              child: const Text('Logout', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold))),
          ],
        )),
        borderRadius: BorderRadius.circular(18),
        child: Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.logout, color: AppColors.error),
          const SizedBox(width: 10),
          const Text('Logout', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.error)),
        ])),
      )),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// Edit Profile Sheet
// ═══════════════════════════════════════════════════════════════════════════════
class _EditSheet extends StatefulWidget {
  final String uid;
  final Map<String, dynamic>? ud;
  final bool isDark;
  const _EditSheet({required this.uid, required this.ud, required this.isDark});
  @override State<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends State<_EditSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _heightCtrl;
  late String _goal;
  late String _level;
  bool _saving = false;

  final _goals = [
    {'name': 'Lose Weight', 'icon': Icons.trending_down, 'color': const Color(0xFFFF6B9D)},
    {'name': 'Gain Muscle', 'icon': Icons.fitness_center, 'color': const Color(0xFF4E54C8)},
    {'name': 'Stay Fit',    'icon': Icons.favorite,       'color': const Color(0xFF00D4AA)},
  ];
  final _levels = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  void initState() {
    super.initState();
    final d = widget.ud;
    _nameCtrl   = TextEditingController(text: d?['displayName'] ?? (d?['email'] as String?)?.split('@')[0] ?? '');
    _weightCtrl = TextEditingController(text: d?['weight'] != null ? d!['weight'].toString() : '');
    _heightCtrl = TextEditingController(text: d?['height'] != null ? d!['height'].toString() : '');
    _goal  = (d?['goal'] as String?)  ?? 'Stay Fit';
    _level = (d?['level'] as String?) ?? 'Beginner';
  }

  @override
  void dispose() { _nameCtrl.dispose(); _weightCtrl.dispose(); _heightCtrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) { Get.snackbar('Missing name', 'Please enter your display name', backgroundColor: AppColors.error.withOpacity(0.1), colorText: AppColors.error, snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16)); return; }
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.uid).update({
        'displayName': name,
        'weight': double.tryParse(_weightCtrl.text.trim()) ?? 0,
        'height': double.tryParse(_heightCtrl.text.trim()) ?? 0,
        'goal': _goal, 'level': _level,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      try { Get.find<WorkoutController>().updateGoalAndLevel(_goal, _level); } catch (_) {}
      if (mounted) Navigator.of(context).pop();
      Get.snackbar('Saved ✓', 'Profile updated!', backgroundColor: AppColors.primary.withOpacity(0.12), colorText: AppColors.primary, snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16), borderRadius: 12);
    } catch (e) {
      Get.snackbar('Error', 'Could not save: $e', backgroundColor: AppColors.error.withOpacity(0.1), colorText: AppColors.error, snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext ctx) {
    final isDark = widget.isDark;
    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      return Container(
        decoration: BoxDecoration(color: dark ? AppColors.cardDark : Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
        padding: EdgeInsets.fromLTRB(24, 14, 24, MediaQuery.of(ctx).viewInsets.bottom + 32),
        child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 44, height: 5, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(3)))),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Edit Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: dark ? Colors.white : AppColors.textDark)),
              const Text('Update your info & goal', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
            ]),
            IconButton(icon: const Icon(Icons.close, color: AppColors.textGrey), onPressed: () => Navigator.of(ctx).pop()),
          ]),
          const SizedBox(height: 24),
          _lbl('Display Name', dark), const SizedBox(height: 8),
          _field(_nameCtrl, 'Your full name', Icons.person_outline, dark),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_lbl('Weight (kg)', dark), const SizedBox(height: 8), _field(_weightCtrl, 'e.g. 70', Icons.monitor_weight_outlined, dark, dec: true)])),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_lbl('Height (cm)', dark), const SizedBox(height: 8), _field(_heightCtrl, 'e.g. 175', Icons.height, dark, dec: true)])),
          ]),
          const SizedBox(height: 24),
          _lbl('Your Goal', dark), const SizedBox(height: 12),
          ..._goals.map((g) {
            final sel = _goal == g['name'];
            final c = g['color'] as Color;
            return GestureDetector(
              onTap: () => setState(() => _goal = g['name'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: sel ? c.withOpacity(0.11) : (dark ? AppColors.backgroundDark : const Color(0xFFF5F7FA)), borderRadius: BorderRadius.circular(16), border: Border.all(color: sel ? c : Colors.transparent, width: 2)),
                child: Row(children: [
                  Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: c.withOpacity(0.14), borderRadius: BorderRadius.circular(9)), child: Icon(g['icon'] as IconData, color: c, size: 18)),
                  const SizedBox(width: 11),
                  Expanded(child: Text(g['name'] as String, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: dark ? Colors.white : AppColors.textDark))),
                  if (sel) Icon(Icons.check_circle, color: c, size: 20),
                ]),
              ),
            );
          }),
          const SizedBox(height: 18),
          _lbl('Fitness Level', dark), const SizedBox(height: 10),
          Row(children: _levels.map((l) {
            final sel = _level == l;
            return Expanded(child: GestureDetector(
              onTap: () => setState(() => _level = l),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                margin: EdgeInsets.only(right: l != _levels.last ? 8 : 0), padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: sel ? const LinearGradient(colors: [AppColors.primary, AppColors.gradientEnd]) : null,
                  color: sel ? null : (dark ? AppColors.backgroundDark : const Color(0xFFF5F7FA)),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: sel ? [BoxShadow(color: AppColors.primary.withOpacity(0.28), blurRadius: 8, offset: const Offset(0, 4))] : [],
                ),
                child: Center(child: Text(l, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: sel ? Colors.white : AppColors.textGrey))),
              ),
            ));
          }).toList()),
          const SizedBox(height: 32),
          SizedBox(width: double.infinity, height: 54,
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: LinearGradient(colors: _saving ? [Colors.grey, Colors.grey] : [AppColors.primary, AppColors.gradientEnd]), borderRadius: BorderRadius.circular(18),
                boxShadow: _saving ? [] : [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))]),
              child: ElevatedButton(onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                child: _saving ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                  : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.check_circle_outline, color: Colors.white, size: 18), SizedBox(width: 8),
                      Text('Save Changes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                    ])))),
        ])),
      );
    });
  }

  Widget _lbl(String t, bool dark) => Text(t, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: dark ? Colors.white70 : AppColors.textGrey));
  Widget _field(TextEditingController ctrl, String hint, IconData icon, bool dark, {bool dec = false}) => Container(
    decoration: BoxDecoration(color: dark ? AppColors.backgroundDark : const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(14), border: Border.all(color: dark ? Colors.white.withOpacity(0.06) : Colors.transparent)),
    child: TextField(controller: ctrl, keyboardType: dec ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      textInputAction: TextInputAction.next,
      style: TextStyle(fontSize: 14, color: dark ? Colors.white : AppColors.textDark),
      decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 19), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14))));
}
