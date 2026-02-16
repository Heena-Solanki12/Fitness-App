// lib/views/dashboard_view.dart - FIXED VERSION
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/auth_controller.dart';
import '../core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class DashboardView extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final RxBool isDarkMode = Get.isDarkMode.obs;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = isDarkMode.value;
      final userId = authController.firebaseUser.value?.uid;

      if (userId == null) {
        return Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      return Scaffold(
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>?;
            final userName = userData?['email']?.split('@')[0] ?? 'User';
            final goal = userData?['goal'] ?? 'Get Fit';

            return Container(
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
                    _buildAppBar(isDark, userName),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildWelcomeSection(isDark, userName, goal),
                            SizedBox(height: 24),
                            _buildQuickStats(isDark),
                            SizedBox(height: 24),
                            _buildTodayActivity(isDark),
                            SizedBox(height: 24),
                            _buildRecentWorkouts(isDark),
                            SizedBox(height: 24),
                            _buildQuickActions(isDark),
                            SizedBox(height: 24),
                            _buildMotivationalQuote(isDark),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildAppBar(bool isDark, String userName) {
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
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.gradientEnd],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.fitness_center,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "FitFlow",
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.textDark,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        DateFormat('MMM d').format(DateTime.now()),
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    color: isDark ? Colors.white : AppColors.textDark,
                    size: 20,
                  ),
                ),
                onPressed: () {},
              ),
              SizedBox(width: 4),
              GestureDetector(
                onTap: () => Get.toNamed('/profile'),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.secondary, AppColors.accent],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      userName[0].toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(bool isDark, String userName, String goal) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.gradientEnd],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome Back! 👋",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      userName,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.flag, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      goal,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWelcomeMetric("75%", "Progress", Icons.trending_up),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.3),
                ),
                _buildWelcomeMetric("5", "Workouts", Icons.fitness_center),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.3),
                ),
                _buildWelcomeMetric("12", "Streak", Icons.local_fire_department),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeMetric(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickStatCard(
            "Calories",
            "1,847",
            "2,500 goal",
            Icons.local_fire_department,
            [Color(0xFFFF6B9D), Color(0xFFFF8E53)],
            0.74,
            isDark,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildQuickStatCard(
            "Water",
            "1.5L",
            "2.5L goal",
            Icons.water_drop,
            [Color(0xFF00D4AA), Color(0xFF00A896)],
            0.60,
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatCard(String title, String value, String goal,
      IconData icon, List<Color> colors, double progress, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16),
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
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          SizedBox(height: 4),
          Text(
            goal,
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 11,
            ),
          ),
          SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(colors[0]),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayActivity(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Activity",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                "See All",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            _buildStatCard(
              "Steps",
              "10,234",
              "15K goal",
              Icons.directions_walk,
              [Color(0xFF4E54C8), Color(0xFF8F94FB)],
              0.68,
              isDark,
            ),
            _buildStatCard(
              "Sleep",
              "7.5",
              "8 hrs",
              Icons.bedtime,
              [Color(0xFF7C4DFF), Color(0xFF9575CD)],
              0.94,
              isDark,
            ),
            _buildStatCard(
              "Active",
              "45",
              "60 min",
              Icons.timer,
              [Color(0xFFFF6B9D), Color(0xFFFF8E53)],
              0.75,
              isDark,
            ),
            _buildStatCard(
              "Heart",
              "72",
              "bpm",
              Icons.favorite,
              [Color(0xFFFF5252), Color(0xFFFF8A80)],
              1.0,
              isDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle,
      IconData icon, List<Color> colors, double progress, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: colors[0].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "${(progress * 100).toInt()}%",
                  style: TextStyle(
                    color: colors[0],
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentWorkouts(bool isDark) {
    final recentWorkouts = [
      {
        "name": "Upper Body",
        "duration": "45 min",
        "calories": "320 kcal",
        "time": "2 hrs ago",
        "icon": Icons.fitness_center,
        "color": AppColors.primary,
      },
      {
        "name": "Yoga",
        "duration": "30 min",
        "calories": "150 kcal",
        "time": "Yesterday",
        "icon": Icons.self_improvement,
        "color": Color(0xFF7C4DFF),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Recent Workouts",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
            ),
            TextButton(
              onPressed: () => Get.toNamed('/workout-history'),
              child: Text(
                "View All",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        ...recentWorkouts.map((workout) => _buildWorkoutCard(workout, isDark)),
      ],
    );
  }

  Widget _buildWorkoutCard(Map<String, dynamic> workout, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(14),
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
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (workout["color"] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              workout["icon"] as IconData,
              color: workout["color"] as Color,
              size: 24,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout["name"] as String,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.timer, size: 13, color: AppColors.textGrey),
                    SizedBox(width: 4),
                    Text(
                      workout["duration"] as String,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textGrey,
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.local_fire_department,
                        size: 13, color: AppColors.textGrey),
                    SizedBox(width: 4),
                    Text(
                      workout["calories"] as String,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            workout["time"] as String,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Actions",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textDark,
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                "Workout",
                Icons.play_circle_filled,
                [AppColors.primary, AppColors.gradientEnd],
                isDark,
                onTap: () => Get.toNamed('/workout-library'),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                "Exercises",
                Icons.fitness_center,
                [Color(0xFF4E54C8), Color(0xFF8F94FB)],
                isDark,
                onTap: () => Get.toNamed('/exercise-library'),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                "Progress",
                Icons.show_chart,
                [Color(0xFF7C4DFF), Color(0xFF9575CD)],
                isDark,
                onTap: () => Get.toNamed('/progress-tracking'),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                "Measures",
                Icons.straighten,
                [Color(0xFF00B894), Color(0xFF00A896)],
                isDark,
                onTap: () => Get.toNamed('/body-measurements'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
      String text, IconData icon, List<Color> colors, bool isDark,
      {VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () {},
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Column(
              children: [
                Icon(icon, color: Colors.white, size: 26),
                SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMotivationalQuote(bool isDark) {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7C4DFF), Color(0xFF9575CD)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF7C4DFF).withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.format_quote,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Stay consistent!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Every workout counts",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}