// lib/views/main_shell.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';
import '../core/theme/app_colors.dart';
import 'dashboard_view.dart';
import 'workouts/workout_library_view.dart';
import 'progress/progress_tracking_view.dart';
import 'exercises/exercise_library_view.dart';
import 'profile_view.dart';

// ── Shell controller ─────────────────────────────────────────────────────────
class ShellController extends GetxController {
  static ShellController get to => Get.find();
  final tabIndex = 0.obs;
  void goTo(int i) => tabIndex.value = i;
}

// ── Main shell ───────────────────────────────────────────────────────────────
class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final shell = Get.put(ShellController());

    return Obx(() {
      final isDark = ThemeController.to.isDark.value;
      final idx = shell.tabIndex.value;

      return Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: IndexedStack(
          index: idx,
          children: const [
            _DashboardTab(),
            _WorkoutsTab(),
            _ProgressTab(),
            _ExercisesTab(),
            _ProfileTab(),
          ],
        ),
        bottomNavigationBar: _BottomNav(currentIndex: idx, isDark: isDark),
      );
    });
  }
}

// ── Bottom nav ───────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final bool isDark;
  const _BottomNav({required this.currentIndex, required this.isDark});

  static const _items = [
    _NavItem(Icons.home_rounded,           Icons.home_outlined,             'Home'),
    _NavItem(Icons.fitness_center_rounded, Icons.fitness_center_outlined,   'Workouts'),
    _NavItem(Icons.show_chart_rounded,     Icons.show_chart_outlined,       'Progress'),
    _NavItem(Icons.sports_gymnastics,      Icons.sports_gymnastics_outlined, 'Exercises'),
    _NavItem(Icons.person_rounded,         Icons.person_outline,            'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? AppColors.cardDark : Colors.white;
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: _items.asMap().entries.map((e) {
              final i = e.key;
              final item = e.value;
              final sel = currentIndex == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => ShellController.to.goTo(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: sel ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(
                          sel ? item.filledIcon : item.outlinedIcon,
                          color: sel ? AppColors.primary : (isDark ? Colors.white54 : AppColors.textGrey),
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 1),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                          color: sel ? AppColors.primary : (isDark ? Colors.white54 : AppColors.textGrey),
                        ),
                        child: Text(item.label),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData filledIcon;
  final IconData outlinedIcon;
  final String label;
  const _NavItem(this.filledIcon, this.outlinedIcon, this.label);
}

// ── Tab wrappers ─────────────────────────────────────────────────────────────
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();
  @override Widget build(BuildContext _) => const DashboardView(showBackButton: false);
}
class _WorkoutsTab extends StatelessWidget {
  const _WorkoutsTab();
  @override Widget build(BuildContext _) => const WorkoutLibraryView(showBackButton: false);
}
class _ProgressTab extends StatelessWidget {
  const _ProgressTab();
  @override Widget build(BuildContext _) => const ProgressTrackingView(showBackButton: false);
}
class _ExercisesTab extends StatelessWidget {
  const _ExercisesTab();
  @override Widget build(BuildContext _) => const ExerciseLibraryView(showBackButton: false);
}
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();
  @override Widget build(BuildContext _) => const ProfileView(showBackButton: false);
}
