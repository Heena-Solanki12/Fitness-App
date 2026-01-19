// lib/views/profile_setup_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/theme/app_colors.dart';
import '../controllers/auth_controller.dart';

class ProfileSetupView extends StatelessWidget {
  ProfileSetupView({super.key});

  final AuthController auth = Get.find<AuthController>();
  final RxString goal = "Lose Weight".obs;
  final TextEditingController height = TextEditingController();
  final TextEditingController weight = TextEditingController();
  final RxString level = "Beginner".obs;

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Set Up Profile"),
        centerTitle: true,
      ),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.secondary.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 40,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Tell us about you",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.textDark,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "This helps us personalize your journey",
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // Your Goal Section
              _buildSectionCard(
                isDark,
                icon: Icons.flag_outlined,
                title: "Your Goal",
                child: _buildGoalChips(isDark),
              ),

              SizedBox(height: 20),

              // Body Metrics Section
              _buildSectionCard(
                isDark,
                icon: Icons.straighten_outlined,
                title: "Body Metrics",
                child: Row(
                  children: [
                    Expanded(
                      child: _buildMetricInput(
                        height,
                        "Height",
                        "cm",
                        Icons.height,
                        isDark,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricInput(
                        weight,
                        "Weight",
                        "kg",
                        Icons.monitor_weight_outlined,
                        isDark,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Fitness Level Section
              _buildSectionCard(
                isDark,
                icon: Icons.trending_up,
                title: "Fitness Level",
                child: _buildLevelChips(isDark),
              ),

              SizedBox(height: 40),

              // Continue Button
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () async {
                    await auth.completeProfile(
                      goal: goal.value,
                      height: height.text,
                      weight: weight.text,
                      level: level.value,
                    );
                  },
                  child: Text(
                    "Continue",
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
    );
  }

  Widget _buildSectionCard(bool isDark,
      {required IconData icon, required String title, required Widget child}) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildGoalChips(bool isDark) {
    final goals = [
      {"name": "Lose Weight", "icon": Icons.trending_down},
      {"name": "Gain Muscle", "icon": Icons.fitness_center},
      {"name": "Stay Fit", "icon": Icons.favorite},
    ];

    return Obx(() => Wrap(
      spacing: 12,
      runSpacing: 12,
      children: goals.map((g) {
        final isSelected = goal.value == g["name"];
        return InkWell(
          onTap: () => goal.value = g["name"] as String,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                colors: [AppColors.primary, AppColors.gradientEnd],
              )
                  : null,
              color: isSelected
                  ? null
                  : isDark
                  ? AppColors.backgroundDark
                  : AppColors.cardLight,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  g["icon"] as IconData,
                  size: 18,
                  color: isSelected
                      ? Colors.white
                      : isDark
                      ? Colors.white70
                      : AppColors.textDark,
                ),
                SizedBox(width: 8),
                Text(
                  g["name"] as String,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : isDark
                        ? Colors.white70
                        : AppColors.textDark,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    ));
  }

  Widget _buildLevelChips(bool isDark) {
    final levels = ["Beginner", "Intermediate", "Advanced"];

    return Obx(() => Wrap(
      spacing: 12,
      runSpacing: 12,
      children: levels.map((l) {
        final isSelected = level.value == l;
        return InkWell(
          onTap: () => level.value = l,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                colors: [AppColors.secondary, AppColors.accent],
              )
                  : null,
              color: isSelected
                  ? null
                  : isDark
                  ? AppColors.backgroundDark
                  : AppColors.cardLight,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.2),
              ),
            ),
            child: Text(
              l,
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
      }).toList(),
    ));
  }

  Widget _buildMetricInput(TextEditingController controller, String label,
      String unit, IconData icon, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: TextStyle(
          color: isDark ? Colors.white : AppColors.textDark,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          labelText: label,
          suffixText: unit,
          suffixStyle: TextStyle(
            color: AppColors.textGrey,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}