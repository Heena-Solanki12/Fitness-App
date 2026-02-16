import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/auth_controller.dart';
import '../core/theme/app_colors.dart';

class ProfileView extends StatelessWidget {
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
            final email = userData?['email'] ?? '';
            final goal = userData?['goal'] ?? 'Get Fit';
            final weight = userData?['weight'] ?? '0';
            final height = userData?['height'] ?? '0';
            final level = userData?['level'] ?? 'Beginner';

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
                    _buildAppBar(isDark),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildProfileHeader(isDark, userName, email),
                            SizedBox(height: 24),
                            _buildStatsCards(isDark, weight, height),
                            SizedBox(height: 24),
                            _buildInfoSection(isDark, goal, level, weight, height),
                            SizedBox(height: 24),
                            _buildAchievementsSection(isDark),
                            SizedBox(height: 24),
                            _buildSettingsSection(isDark),
                            SizedBox(height: 24),
                            _buildLogoutButton(isDark),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
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
              Text(
                "Profile",
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              Icons.edit,
              color: AppColors.primary,
              size: 24,
            ),
            onPressed: () {
              Get.snackbar(
                "Edit Profile",
                "Edit functionality coming soon!",
                backgroundColor: AppColors.primary.withOpacity(0.1),
                colorText: AppColors.primary,
                snackPosition: SnackPosition.BOTTOM,
                margin: EdgeInsets.all(16),
                borderRadius: 12,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark, String userName, String email) {
    return Container(
      padding: EdgeInsets.all(24),
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
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    userName[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.secondary, AppColors.accent],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            userName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            email,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildProfileStat("12", "Day Streak", Icons.local_fire_department),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildProfileStat("45", "Workouts", Icons.fitness_center),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildProfileStat("8", "Badges", Icons.emoji_events),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards(bool isDark, String weight, String height) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            "Weight",
            "$weight kg",
            Icons.monitor_weight_outlined,
            [Color(0xFFFF6B9D), Color(0xFFFF8E53)],
            isDark,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            "Height",
            "$height cm",
            Icons.height,
            [Color(0xFF4E54C8), Color(0xFF8F94FB)],
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon,
      List<Color> colors, bool isDark) {
    return Container(
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
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
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
    );
  }

  Widget _buildInfoSection(
      bool isDark, String goal, String level, String weight, String height) {
    return Container(
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
          Text(
            "Personal Information",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          SizedBox(height: 20),
          _buildInfoRow(Icons.flag, "Goal", goal, isDark),
          SizedBox(height: 16),
          _buildInfoRow(Icons.trending_up, "Fitness Level", level, isDark),
          SizedBox(height: 16),
          _buildInfoRow(Icons.fitness_center, "BMI", _calculateBMI(weight, height), isDark),
        ],
      ),
    );
  }

  String _calculateBMI(String weight, String height) {
    try {
      double w = double.parse(weight);
      double h = double.parse(height) / 100; // convert cm to m
      double bmi = w / (h * h);
      return bmi.toStringAsFixed(1);
    } catch (e) {
      return "N/A";
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsSection(bool isDark) {
    final achievements = [
      {
        "icon": Icons.local_fire_department,
        "title": "7 Day Streak",
        "color": Color(0xFFFF6B9D),
        "unlocked": true,
      },
      {
        "icon": Icons.fitness_center,
        "title": "25 Workouts",
        "color": Color(0xFF4E54C8),
        "unlocked": true,
      },
      {
        "icon": Icons.emoji_events,
        "title": "First Goal",
        "color": Color(0xFFFFD700),
        "unlocked": true,
      },
      {
        "icon": Icons.trending_up,
        "title": "50 Workouts",
        "color": Color(0xFF7C4DFF),
        "unlocked": false,
      },
    ];

    return Container(
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
              Text(
                "Achievements",
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
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: achievements.map((achievement) {
              final unlocked = achievement["unlocked"] as bool;
              return Container(
                width: 70,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: unlocked
                            ? (achievement["color"] as Color).withOpacity(0.1)
                            : isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.grey.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        achievement["icon"] as IconData,
                        color: unlocked
                            ? achievement["color"] as Color
                            : Colors.grey,
                        size: 28,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      achievement["title"] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: unlocked
                            ? (isDark ? Colors.white : AppColors.textDark)
                            : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(bool isDark) {
    return Container(
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
          Text(
            "Settings",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          SizedBox(height: 16),
          _buildSettingItem(
            Icons.notifications_outlined,
            "Notifications",
            "Manage your notifications",
            isDark,
                () {},
          ),
          Divider(height: 32),
          _buildSettingItem(
            Icons.privacy_tip_outlined,
            "Privacy",
            "Manage your privacy settings",
            isDark,
                () {},
          ),
          Divider(height: 32),
          Obx(() => _buildSettingToggle(
            Icons.dark_mode,
            "Dark Mode",
            "Toggle dark mode",
            isDark,
            isDarkMode.value,
                (value) {
              Get.changeThemeMode(
                value ? ThemeMode.dark : ThemeMode.light,
              );
              isDarkMode.value = value;
            },
          )),
          Divider(height: 32),
          _buildSettingItem(
            Icons.help_outline,
            "Help & Support",
            "Get help with the app",
            isDark,
                () {},
          ),
          Divider(height: 32),
          _buildSettingItem(
            Icons.info_outline,
            "About",
            "App version and info",
            isDark,
                () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, String subtitle,
      bool isDark, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.textGrey,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingToggle(IconData icon, String title, String subtitle,
      bool isDark, bool value, Function(bool) onChanged) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildLogoutButton(bool isDark) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.error, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.dialog(
              AlertDialog(
                backgroundColor: isDark ? AppColors.cardDark : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Text(
                  "Logout",
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text(
                  "Are you sure you want to logout?",
                  style: TextStyle(
                    color: AppColors.textGrey,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: AppColors.textGrey),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.back();
                      authController.logout();
                    },
                    child: Text(
                      "Logout",
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout, color: AppColors.error),
                SizedBox(width: 12),
                Text(
                  "Logout",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}