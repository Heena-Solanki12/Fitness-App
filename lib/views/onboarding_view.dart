import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../controllers/auth_controller.dart';

class OnboardingView extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Spacer(),
                // Animated illustration
                Container(
                  padding: EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.2),
                        AppColors.secondary.withOpacity(0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.show_chart,
                    size: 100,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "Track Your Fitness Journey",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  "Workouts, progress & goals\nall in one place",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 20),
                // Feature cards
                _buildFeatureRow(
                  Icons.fitness_center,
                  "Personalized Workouts",
                  isDark,
                ),
                SizedBox(height: 16),
                _buildFeatureRow(
                  Icons.track_changes,
                  "Track Your Progress",
                  isDark,
                ),
                SizedBox(height: 16),
                _buildFeatureRow(
                  Icons.emoji_events,
                  "Achieve Your Goals",
                  isDark,
                ),
                Spacer(),
                // Get Started Button
                Container(
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
                    onPressed: () async {
                      // Mark onboarding as seen
                      await authController.markOnboardingAsSeen();
                      // Navigate to login
                      Get.offAllNamed(AppRoutes.login);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      "Get Started",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}