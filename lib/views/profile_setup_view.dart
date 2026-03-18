// lib/views/profile_setup_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/theme_controller.dart';
import '../core/theme/app_colors.dart';

class ProfileSetupView extends StatelessWidget {
  ProfileSetupView({super.key});

  final AuthController auth = Get.find<AuthController>();
  final RxString goal = 'Lose Weight'.obs;
  final TextEditingController heightCtrl = TextEditingController();
  final TextEditingController weightCtrl = TextEditingController();
  final RxString level = 'Beginner'.obs;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = ThemeController.to.isDark.value;
      return Scaffold(
        appBar: AppBar(title: const Text('Set Up Profile'), centerTitle: true),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [AppColors.backgroundDark, const Color(0xFF1C2128)]
                  : [AppColors.backgroundLight, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.1), AppColors.secondary.withOpacity(0.1)]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline, size: 40, color: AppColors.primary),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tell us about you', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
                            const SizedBox(height: 4),
                            const Text('This helps us personalize your journey', style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _sectionCard(isDark, icon: Icons.flag_outlined, title: 'Your Goal', child: _goalChips(isDark)),
                const SizedBox(height: 20),
                _sectionCard(
                  isDark,
                  icon: Icons.straighten_outlined,
                  title: 'Body Metrics',
                  child: Row(
                    children: [
                      Expanded(child: _metricInput(heightCtrl, 'Height', 'cm', Icons.height, isDark)),
                      const SizedBox(width: 12),
                      Expanded(child: _metricInput(weightCtrl, 'Weight', 'kg', Icons.monitor_weight_outlined, isDark)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _sectionCard(isDark, icon: Icons.trending_up, title: 'Fitness Level', child: _levelChips(isDark)),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.primary, AppColors.gradientEnd]),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        await auth.completeProfile(goal: goal.value, height: heightCtrl.text, weight: weightCtrl.text, level: level.value);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('Continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _sectionCard(bool isDark, {required IconData icon, required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.03), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.textDark)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _goalChips(bool isDark) {
    final goals = [
      {'name': 'Lose Weight', 'icon': Icons.trending_down},
      {'name': 'Gain Muscle', 'icon': Icons.fitness_center},
      {'name': 'Stay Fit', 'icon': Icons.favorite},
    ];
    return Obx(() => Wrap(
      spacing: 12,
      runSpacing: 12,
      children: goals.map((g) {
        final sel = goal.value == g['name'];
        return InkWell(
          onTap: () => goal.value = g['name'] as String,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: sel ? const LinearGradient(colors: [AppColors.primary, AppColors.gradientEnd]) : null,
              color: sel ? null : (isDark ? AppColors.backgroundDark : AppColors.cardLight),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: sel ? Colors.transparent : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2))),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(g['icon'] as IconData, size: 18, color: sel ? Colors.white : (isDark ? Colors.white70 : AppColors.textDark)),
                const SizedBox(width: 8),
                Text(g['name'] as String, style: TextStyle(color: sel ? Colors.white : (isDark ? Colors.white70 : AppColors.textDark), fontWeight: sel ? FontWeight.w600 : FontWeight.w500)),
              ],
            ),
          ),
        );
      }).toList(),
    ));
  }

  Widget _levelChips(bool isDark) {
    final levels = ['Beginner', 'Intermediate', 'Advanced'];
    return Obx(() => Wrap(
      spacing: 12,
      runSpacing: 12,
      children: levels.map((l) {
        final sel = level.value == l;
        return InkWell(
          onTap: () => level.value = l,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: sel ? const LinearGradient(colors: [AppColors.secondary, AppColors.accent]) : null,
              color: sel ? null : (isDark ? AppColors.backgroundDark : AppColors.cardLight),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: sel ? Colors.transparent : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2))),
            ),
            child: Text(l, style: TextStyle(color: sel ? Colors.white : (isDark ? Colors.white70 : AppColors.textDark), fontWeight: sel ? FontWeight.w600 : FontWeight.w500)),
          ),
        );
      }).toList(),
    ));
  }

  Widget _metricInput(TextEditingController ctrl, String label, String unit, IconData icon, bool isDark) {
    return Container(
      decoration: BoxDecoration(color: isDark ? AppColors.backgroundDark : AppColors.cardLight, borderRadius: BorderRadius.circular(16)),
      child: TextField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: TextStyle(color: isDark ? Colors.white : AppColors.textDark, fontSize: 16, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          suffixText: unit,
          suffixStyle: const TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.w500),
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
