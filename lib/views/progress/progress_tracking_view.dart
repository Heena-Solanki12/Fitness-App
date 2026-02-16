// lib/views/progress/progress_tracking_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../controllers/progress_controller.dart';
import '../../core/theme/app_colors.dart';

class ProgressTrackingView extends StatelessWidget {
  final ProgressController controller = Get.put(ProgressController());

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
              _buildTabs(isDark),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return Center(child: CircularProgressIndicator());
                  }

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        if (controller.selectedMetric.value == 'Weight')
                          _buildWeightSection(isDark)
                        else if (controller.selectedMetric.value ==
                            'Measurements')
                          _buildMeasurementsSection(isDark)
                        else
                          _buildPhotosSection(isDark),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProgressDialog(isDark),
        icon: Icon(Icons.add),
        label: Text("Log Progress"),
        backgroundColor: AppColors.primary,
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
          Text(
            "Progress Tracking",
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.textDark,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(bool isDark) {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => _buildTab(
              'Weight',
              Icons.monitor_weight_outlined,
              controller.selectedMetric.value == 'Weight',
                  () => controller.setMetric('Weight'),
              isDark,
            )),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Obx(() => _buildTab(
              'Body',
              Icons.straighten,
              controller.selectedMetric.value == 'Measurements',
                  () => controller.setMetric('Measurements'),
              isDark,
            )),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Obx(() => _buildTab(
              'Photos',
              Icons.photo_camera,
              controller.selectedMetric.value == 'Photos',
                  () => controller.setMetric('Photos'),
              isDark,
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, IconData icon, bool isSelected,
      VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.grey.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : isDark
                  ? Colors.white70
                  : AppColors.textDark,
              size: 20,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : isDark
                    ? Colors.white70
                    : AppColors.textDark,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightSection(bool isDark) {
    return Column(
      children: [
        _buildWeightStats(isDark),
        SizedBox(height: 24),
        _buildWeightChart(isDark),
        SizedBox(height: 24),
        _buildRecentEntries(isDark),
      ],
    );
  }

  Widget _buildWeightStats(bool isDark) {
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
          Text(
            "Current Weight",
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          SizedBox(height: 8),
          Obx(() => Text(
            "${controller.currentWeight.value.toStringAsFixed(1)} kg",
            style: TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          )),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Obx(() => _buildWeightStatItem(
                controller.weightChange.value >= 0
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                "${controller.weightChange.value.abs().toStringAsFixed(1)} kg",
                "30 days",
                controller.weightChange.value >= 0
                    ? Color(0xFFFF7675)
                    : Color(0xFF00B894),
              )),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildWeightStatItem(
                Icons.flag,
                "70.0 kg",
                "Goal",
                Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeightStatItem(
      IconData icon, String value, String label, Color iconColor) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 24),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildWeightChart(bool isDark) {
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
            "Weight Trend",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Obx(() {
              final data = controller.getWeightChartData();
              if (data.isEmpty) {
                return Center(
                  child: Text(
                    "No weight data yet",
                    style: TextStyle(color: AppColors.textGrey),
                  ),
                );
              }

              return LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= data.length) return Text('');
                          final date = data[value.toInt()]['date'] as DateTime;
                          return Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat('M/d').format(date),
                              style: TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(0),
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data
                          .asMap()
                          .entries
                          .map((e) => FlSpot(
                        e.key.toDouble(),
                        e.value['weight'] as double,
                      ))
                          .toList(),
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.gradientEnd],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: AppColors.primary,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.3),
                            AppColors.primary.withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentEntries(bool isDark) {
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
            "Recent Entries",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          SizedBox(height: 16),
          Obx(() {
            final logs = controller.weightLogs.take(5).toList();
            return Column(
              children: logs
                  .map((log) => Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.backgroundDark
                      : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('MMM d, yyyy').format(log.date),
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? Colors.white
                                : AppColors.textDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (log.notes != null) ...[
                          SizedBox(height: 4),
                          Text(
                            log.notes!,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      "${log.weight!.toStringAsFixed(1)} kg",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ))
                  .toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMeasurementsSection(bool isDark) {
    // Replace the "Coming Soon" with navigation:
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.straighten, size: 80, color: AppColors.primary),
          SizedBox(height: 16),
          Text(
            "Body Measurements",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed('/body-measurements'),
            icon: Icon(Icons.trending_up),
            label: Text("Track Measurements"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosSection(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_camera,
            size: 80,
            color: AppColors.textGrey.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            "Progress Photos",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Take photos to track visual changes",
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textGrey,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          Text(
            "Coming Soon!",
            style: TextStyle(
              fontSize: 16,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddProgressDialog(bool isDark) {
    Get.snackbar(
      "Coming Soon",
      "Add progress entry feature is under development!",
      backgroundColor: AppColors.primary.withOpacity(0.1),
      colorText: AppColors.primary,
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}