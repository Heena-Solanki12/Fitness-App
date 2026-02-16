import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/measurement_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../models/measurement_log_model.dart';

class BodyMeasurementsView extends StatelessWidget {
  final MeasurementController controller = Get.put(MeasurementController());

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
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value &&
                      controller.measurements.isEmpty) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (controller.measurements.isEmpty) {
                    return _buildEmptyState(isDark);
                  }

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildLatestMeasurements(isDark),
                        SizedBox(height: 24),
                        _buildMeasurementCharts(isDark),
                        SizedBox(height: 24),
                        _buildHistory(isDark),
                        SizedBox(height: 80),
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
        onPressed: () => _showAddMeasurementDialog(isDark),
        icon: Icon(Icons.add),
        label: Text("Add Measurements"),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Body Measurements",
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Obx(() => Text(
                "${controller.measurements.length} entries",
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 12,
                ),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLatestMeasurements(bool isDark) {
    return Obx(() {
      if (controller.latestMeasurement.value == null) {
        return SizedBox.shrink();
      }

      final latest = controller.latestMeasurement.value!;

      return Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00B894), Color(0xFF00A896)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF00B894).withOpacity(0.3),
              blurRadius: 20,
              offset: Offset(0, 10),
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
                  "Latest Measurements",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat('MMM d, yyyy').format(latest.date),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildMeasurementGrid(latest, isDark),
          ],
        ),
      );
    });
  }

  Widget _buildMeasurementGrid(MeasurementLog log, bool isDark) {
    final measurements = [
      if (log.chest != null)
        {'label': 'Chest', 'value': log.chest!, 'icon': Icons.accessibility},
      if (log.waist != null)
        {'label': 'Waist', 'value': log.waist!, 'icon': Icons.straighten},
      if (log.hips != null)
        {'label': 'Hips', 'value': log.hips!, 'icon': Icons.accessibility},
      if (log.bicepLeft != null)
        {
          'label': 'L Bicep',
          'value': log.bicepLeft!,
          'icon': Icons.fitness_center
        },
      if (log.bicepRight != null)
        {
          'label': 'R Bicep',
          'value': log.bicepRight!,
          'icon': Icons.fitness_center
        },
      if (log.thighLeft != null)
        {'label': 'L Thigh', 'value': log.thighLeft!, 'icon': Icons.height},
      if (log.thighRight != null)
        {'label': 'R Thigh', 'value': log.thighRight!, 'icon': Icons.height},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: measurements.map((m) {
        final change = controller.changeFromLast[m['label']];
        return Container(
          width: (Get.width - 84) / 2,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(m['icon'] as IconData,
                  color: Colors.white.withOpacity(0.9), size: 20),
              SizedBox(height: 8),
              Text(
                "${(m['value'] as double).toStringAsFixed(1)} cm",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    m['label'] as String,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                  if (change != null) ...[
                    SizedBox(width: 4),
                    Icon(
                      change >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                      color: change >= 0
                          ? Colors.red.withOpacity(0.8)
                          : Colors.green.withOpacity(0.8),
                      size: 12,
                    ),
                    Text(
                      "${change.abs().toStringAsFixed(1)}",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMeasurementCharts(bool isDark) {
    final chartTypes = ['Chest', 'Waist', 'Hips'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Trends",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textDark,
          ),
        ),
        SizedBox(height: 16),
        ...chartTypes.map((type) => _buildChart(type, isDark)),
      ],
    );
  }

  Widget _buildChart(String measurementType, bool isDark) {
    return Obx(() {
      final data = controller.getChartData(measurementType);

      if (data.isEmpty) return SizedBox.shrink();

      return Container(
        margin: EdgeInsets.only(bottom: 16),
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
              "$measurementType Progress",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 2,
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
                        e.value['value'] as double,
                      ))
                          .toList(),
                      isCurved: true,
                      color: _getColorForMeasurement(measurementType),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: _getColorForMeasurement(measurementType),
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: _getColorForMeasurement(measurementType)
                            .withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Color _getColorForMeasurement(String type) {
    switch (type) {
      case 'Chest':
        return Color(0xFF4E54C8);
      case 'Waist':
        return Color(0xFFFF6B9D);
      case 'Hips':
        return Color(0xFF00B894);
      default:
        return AppColors.primary;
    }
  }

  Widget _buildHistory(bool isDark) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "History",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textDark,
          ),
        ),
        SizedBox(height: 16),
        ...controller.measurements.map((log) => _buildHistoryCard(log, isDark)),
      ],
    ));
  }

  Widget _buildHistoryCard(MeasurementLog log, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 3),
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
                DateFormat('EEEE, MMM d, yyyy').format(log.date),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                onPressed: () => _confirmDelete(log.id),
              ),
            ],
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: log.measurementsMap.entries.map((entry) {
              return Text(
                "${entry.key}: ${entry.value.toStringAsFixed(1)} cm",
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textGrey,
                ),
              );
            }).toList(),
          ),
          if (log.notes != null && log.notes!.isNotEmpty) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.note, size: 16, color: AppColors.primary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      log.notes!,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white : AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.straighten,
            size: 80,
            color: AppColors.textGrey.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            "No measurements yet",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Add your first measurement\nto start tracking progress",
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String id) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Delete Measurement?"),
        content: Text("This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteMeasurement(id);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _showAddMeasurementDialog(bool isDark) {
    final chestController = TextEditingController();
    final waistController = TextEditingController();
    final hipsController = TextEditingController();
    final bicepLeftController = TextEditingController();
    final bicepRightController = TextEditingController();
    final thighLeftController = TextEditingController();
    final thighRightController = TextEditingController();
    final notesController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: EdgeInsets.all(24),
          constraints: BoxConstraints(maxHeight: Get.height * 0.8),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Add Measurements",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                ),
                SizedBox(height: 24),
                _buildMeasurementField("Chest (cm)", chestController, Icons.accessibility),
                SizedBox(height: 16),
                _buildMeasurementField("Waist (cm)", waistController, Icons.straighten),
                SizedBox(height: 16),
                _buildMeasurementField("Hips (cm)", hipsController, Icons.accessibility),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildMeasurementField(
                          "Left Bicep", bicepLeftController, Icons.fitness_center),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildMeasurementField(
                          "Right Bicep", bicepRightController, Icons.fitness_center),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildMeasurementField(
                          "Left Thigh", thighLeftController, Icons.height),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildMeasurementField(
                          "Right Thigh", thighRightController, Icons.height),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                _buildMeasurementField("Notes", notesController, Icons.note,
                    maxLines: 3),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text("Cancel"),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _saveMeasurement(
                          chestController,
                          waistController,
                          hipsController,
                          bicepLeftController,
                          bicepRightController,
                          thighLeftController,
                          thighRightController,
                          notesController,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text("Save"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMeasurementField(
      String label, TextEditingController controller, IconData icon,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType:
      maxLines == 1 ? TextInputType.number : TextInputType.multiline,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  void _saveMeasurement(
      TextEditingController chest,
      TextEditingController waist,
      TextEditingController hips,
      TextEditingController bicepLeft,
      TextEditingController bicepRight,
      TextEditingController thighLeft,
      TextEditingController thighRight,
      TextEditingController notes,
      ) {
    final userId = Get.find<AuthController>().firebaseUser.value?.uid;
    if (userId == null) return;

    final log = MeasurementLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      date: DateTime.now(),
      chest: chest.text.isNotEmpty ? double.tryParse(chest.text) : null,
      waist: waist.text.isNotEmpty ? double.tryParse(waist.text) : null,
      hips: hips.text.isNotEmpty ? double.tryParse(hips.text) : null,
      bicepLeft:
      bicepLeft.text.isNotEmpty ? double.tryParse(bicepLeft.text) : null,
      bicepRight:
      bicepRight.text.isNotEmpty ? double.tryParse(bicepRight.text) : null,
      thighLeft:
      thighLeft.text.isNotEmpty ? double.tryParse(thighLeft.text) : null,
      thighRight:
      thighRight.text.isNotEmpty ? double.tryParse(thighRight.text) : null,
      notes: notes.text.isNotEmpty ? notes.text : null,
    );

    if (!log.hasMeasurements) {
      Get.snackbar(
        'Error',
        'Please enter at least one measurement',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.back();
    controller.addMeasurement(log);
  }
}