// lib/views/progress/progress_tracking_view.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../../controllers/theme_controller.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/progress_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../models/progress_log_model.dart';

class ProgressTrackingView extends StatelessWidget {
  final bool showBackButton;
  const ProgressTrackingView({super.key, this.showBackButton = true});
  ProgressController get ctrl => Get.put(ProgressController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = ThemeController.to.isDark.value;
      return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(
          colors: isDark ? [AppColors.backgroundDark, const Color(0xFF1C2128)] : [AppColors.backgroundLight, Colors.white],
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
        )),
        child: SafeArea(child: Column(children: [
          _appBar(isDark),
          _tabBar(isDark),
          Expanded(child: Obx(() {
            if (ctrl.isLoading.value) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            return _body(isDark, ctrl.selectedMetric.value, context);
          })),
        ])),
      ),
      floatingActionButton: Obx(() => FloatingActionButton.extended(
        onPressed: () {
          if (ctrl.selectedMetric.value == 'Weight') _showLogWeight(context, isDark);
          else if (ctrl.selectedMetric.value == 'Body') Get.toNamed('/body-measurements');
          else _showLogPhoto(context, isDark);
        },
        icon: Icon(ctrl.selectedMetric.value == 'Weight' ? Icons.monitor_weight_outlined : ctrl.selectedMetric.value == 'Body' ? Icons.straighten : Icons.add_a_photo),
        label: Text(ctrl.selectedMetric.value == 'Weight' ? 'Log Weight' : ctrl.selectedMetric.value == 'Body' ? 'Log Measurements' : 'Add Photo'),
        backgroundColor: AppColors.primary,
      )),
    );
    });
  }

  Widget _appBar(bool isDark) => Container(
    padding: const EdgeInsets.fromLTRB(8, 12, 20, 12),
    decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white,
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))]),
    child: Row(children: [
      if (showBackButton) IconButton(icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : AppColors.textDark, size: 20), onPressed: () => Get.back()) else const SizedBox(width: 16),
      Text('Progress Tracking', style: TextStyle(color: isDark ? Colors.white : AppColors.textDark, fontSize: 20, fontWeight: FontWeight.bold)),
    ]),
  );

  Widget _tabBar(bool isDark) => Container(
    margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white, borderRadius: BorderRadius.circular(16)),
    child: Row(children: [
      _tab('Weight', Icons.monitor_weight_outlined, isDark),
      _tab('Body', Icons.straighten, isDark),
      _tab('Photos', Icons.photo_camera_outlined, isDark),
    ]),
  );

  Widget _tab(String label, IconData icon, bool isDark) => Expanded(
    child: Obx(() {
      final sel = ctrl.selectedMetric.value == label;
      return GestureDetector(
        onTap: () => ctrl.setMetric(label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: sel ? const LinearGradient(colors: [AppColors.primary, AppColors.gradientEnd]) : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 15, color: sel ? Colors.white : (isDark ? Colors.white54 : AppColors.textGrey)),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: sel ? FontWeight.w700 : FontWeight.w500, color: sel ? Colors.white : (isDark ? Colors.white54 : AppColors.textGrey))),
          ]),
        ),
      );
    }),
  );

  Widget _body(bool isDark, String tab, BuildContext context) {
    switch (tab) {
      case 'Weight': return _weightTab(isDark);
      case 'Body':   return _bodyTab(isDark);
      default:       return _photosTab(isDark, context);
    }
  }

  // ── WEIGHT TAB ───────────────────────────────────────────────────────────────
  Widget _weightTab(bool isDark) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
    children: [_weightHero(isDark), const SizedBox(height: 20), _weightChart(isDark), const SizedBox(height: 20), _weightHistory(isDark)],
  );

  Widget _weightHero(bool isDark) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [AppColors.primary, AppColors.gradientEnd]),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 10))],
    ),
    child: Column(children: [
      const Text('Current Weight', style: TextStyle(color: Colors.white70, fontSize: 14)),
      const SizedBox(height: 8),
      Obx(() => Text('${ctrl.currentWeight.value.toStringAsFixed(1)} kg', style: const TextStyle(color: Colors.white, fontSize: 52, fontWeight: FontWeight.bold))),
      const SizedBox(height: 20),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Obx(() {
          final c = ctrl.weightChange.value;
          return _heroStat(c < 0 ? Icons.arrow_downward : Icons.arrow_upward, '${c.abs().toStringAsFixed(1)} kg', '30 days',
              c < 0 ? const Color(0xFF00B894) : const Color(0xFFFF7675));
        }),
        Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
        _heroStat(Icons.flag_outlined, '70.0 kg', 'Goal', Colors.white),
        Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
        Obx(() {
          final bmi = ctrl.currentWeight.value > 0 ? ctrl.currentWeight.value / (1.75 * 1.75) : 0.0;
          return _heroStat(Icons.calculate_outlined, bmi.toStringAsFixed(1), 'BMI', Colors.white);
        }),
      ]),
    ]),
  );

  Widget _heroStat(IconData icon, String value, String label, Color iconColor) => Column(children: [
    Icon(icon, color: iconColor, size: 22),
    const SizedBox(height: 6),
    Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
    const SizedBox(height: 2),
    Text(label, style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11)),
  ]);

  Widget _weightChart(bool isDark) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white, borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 15, offset: const Offset(0, 5))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Weight Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
        Obx(() {
          final logs = ctrl.weightLogs;
          if (logs.length < 2) return const SizedBox.shrink();
          final diff = logs.first.weight! - logs.last.weight!;
          return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: (diff < 0 ? const Color(0xFF00B894) : const Color(0xFFFF7675)).withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
            child: Text('${diff < 0 ? '−' : '+'}${diff.abs().toStringAsFixed(1)} kg total',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: diff < 0 ? const Color(0xFF00B894) : const Color(0xFFFF7675))));
        }),
      ]),
      const SizedBox(height: 20),
      SizedBox(height: 200, child: Obx(() {
        final data = ctrl.getWeightChartData();
        if (data.isEmpty) return Center(child: Text('No data yet. Tap + to log.', style: TextStyle(color: AppColors.textGrey)));
        final wts = data.map((d) => d['weight'] as double).toList();
        final minW = wts.reduce((a, b) => a < b ? a : b) - 1;
        final maxW = wts.reduce((a, b) => a > b ? a : b) + 1;
        return LineChart(LineChartData(
          minY: minW, maxY: maxW,
          gridData: FlGridData(show: true, drawVerticalLine: false,
            getDrawingHorizontalLine: (v) => FlLine(color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.withOpacity(0.15), strokeWidth: 1)),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, interval: (data.length / 4).ceilToDouble(),
              getTitlesWidget: (v, m) {
                final i = v.toInt();
                if (i < 0 || i >= data.length) return const Text('');
                return Padding(padding: const EdgeInsets.only(top: 6), child: Text(DateFormat('M/d').format(data[i]['date'] as DateTime), style: TextStyle(color: AppColors.textGrey, fontSize: 10)));
              })),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 38,
              getTitlesWidget: (v, m) => Text(v.toStringAsFixed(0), style: TextStyle(color: AppColors.textGrey, fontSize: 11)))),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [LineChartBarData(
            spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value['weight'] as double)).toList(),
            isCurved: true, curveSmoothness: 0.35,
            gradient: const LinearGradient(colors: [AppColors.primary, AppColors.gradientEnd]),
            barWidth: 3, isStrokeCapRound: true,
            dotData: FlDotData(show: true, getDotPainter: (s, p, b, i) => FlDotCirclePainter(radius: 4, color: Colors.white, strokeWidth: 2.5, strokeColor: AppColors.primary)),
            belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.25), Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          )],
        ));
      })),
    ]),
  );

  Widget _weightHistory(bool isDark) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white, borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 15, offset: const Offset(0, 5))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
      const SizedBox(height: 16),
      Obx(() {
        final logs = ctrl.weightLogs;
        if (logs.isEmpty) return Padding(padding: const EdgeInsets.all(16), child: Center(child: Text('No entries yet. Tap + to log.', style: TextStyle(color: AppColors.textGrey))));
        return Column(children: logs.take(10).toList().asMap().entries.map((e) {
          final log = e.value;
          final prev = e.key + 1 < logs.length ? logs[e.key + 1].weight : null;
          final diff = prev != null ? log.weight! - prev : null;
          return Container(
            margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: isDark ? AppColors.backgroundDark : const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Center(child: Icon(Icons.monitor_weight_outlined, color: AppColors.primary, size: 20))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(DateFormat('EEEE, MMM d').format(log.date), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.textDark)),
                if (log.notes != null && log.notes!.isNotEmpty) ...[const SizedBox(height: 2), Text(log.notes!, style: const TextStyle(fontSize: 11, color: AppColors.textGrey), maxLines: 1, overflow: TextOverflow.ellipsis)],
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('${log.weight!.toStringAsFixed(1)} kg', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.primary)),
                if (diff != null) Text('${diff > 0 ? '+' : ''}${diff.toStringAsFixed(1)}', style: TextStyle(fontSize: 11, color: diff < 0 ? const Color(0xFF00B894) : const Color(0xFFFF7675), fontWeight: FontWeight.w600)),
              ]),
            ]),
          );
        }).toList());
      }),
    ]),
  );

  // ── BODY TAB ─────────────────────────────────────────────────────────────────
  Widget _bodyTab(bool isDark) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
    children: [_bodyHero(isDark), const SizedBox(height: 20), _bodyGrid(isDark), const SizedBox(height: 20), _bodyHistory(isDark)],
  );

  Widget _bodyHero(bool isDark) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFF7C4DFF), Color(0xFF5563DE)]),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [BoxShadow(color: const Color(0xFF7C4DFF).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
    ),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Body Measurements', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        const Text('Track your body changes', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Obx(() => Text('${ctrl.measurementLogs.length} sessions logged', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13))),
      ])),
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
        child: const Icon(Icons.straighten, color: Colors.white, size: 30)),
    ]),
  );

  Widget _bodyGrid(bool isDark) {
    final parts = [
      {'key': 'Chest', 'label': 'Chest', 'icon': Icons.accessibility_new},
      {'key': 'Waist', 'label': 'Waist', 'icon': Icons.accessibility},
      {'key': 'Hips', 'label': 'Hips', 'icon': Icons.airline_seat_legroom_normal},
      {'key': 'Left Bicep', 'label': 'Bicep', 'icon': Icons.fitness_center},
      {'key': 'Left Thigh', 'label': 'Thigh', 'icon': Icons.directions_walk},
      {'key': 'Shoulders', 'label': 'Shoulders', 'icon': Icons.person},
    ];
    return Obx(() {
      final latest = ctrl.latestMeasurementLog.value;
      if (latest == null) return Container(
        padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Center(child: Column(children: [
          Icon(Icons.straighten, size: 48, color: AppColors.textGrey.withOpacity(0.4)), const SizedBox(height: 12),
          Text('No measurements logged yet', style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
          const SizedBox(height: 16),
          ElevatedButton.icon(onPressed: () => Get.toNamed('/body-measurements'),
            icon: const Icon(Icons.add), label: const Text('Log First Session'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C4DFF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)))),
        ])),
      );
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white, borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 15, offset: const Offset(0, 5))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Latest Measurements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
            Text(DateFormat('MMM d').format(latest.date), style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
          ]),
          const SizedBox(height: 16),
          GridView.count(crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.0,
            children: parts.map((p) {
              final val = latest.measurementsMap[p['key'] as String];
              final change = ctrl.measurementChange.value[p['key'] as String];
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: isDark ? AppColors.backgroundDark : const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(14)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(p['icon'] as IconData, color: const Color(0xFF7C4DFF), size: 20),
                  const SizedBox(height: 5),
                  Text(val != null ? val.toStringAsFixed(1) : '–', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
                  Text(p['label'] as String, style: const TextStyle(fontSize: 9, color: AppColors.textGrey), textAlign: TextAlign.center),
                  if (change != null && change != 0) Text('${change > 0 ? '+' : ''}${change.toStringAsFixed(1)}',
                    style: TextStyle(fontSize: 9, color: change < 0 ? const Color(0xFF00B894) : const Color(0xFFFF7675), fontWeight: FontWeight.w600)),
                ]),
              );
            }).toList()),
        ]),
      );
    });
  }

  Widget _bodyHistory(bool isDark) => Obx(() {
    final logs = ctrl.measurementLogs.take(5).toList();
    if (logs.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 15, offset: const Offset(0, 5))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Session History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
          TextButton(onPressed: () => Get.toNamed('/body-measurements'), child: const Text('View All', style: TextStyle(color: AppColors.primary))),
        ]),
        ...logs.map((log) => Container(
          margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: isDark ? AppColors.backgroundDark : const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF7C4DFF).withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
              child: const Center(child: Icon(Icons.straighten, color: Color(0xFF7C4DFF), size: 20))),
            const SizedBox(width: 12),
            Expanded(child: Text(DateFormat('EEE, MMM d yyyy').format(log.date), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.textDark))),
            Text('${log.measurementsMap.length} metrics', style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
          ]),
        )),
      ]),
    );
  });

  // ── PHOTOS TAB ───────────────────────────────────────────────────────────────
  Widget _photosTab(bool isDark, BuildContext context) => Obx(() {
    final photos = ctrl.progressPhotos;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        _photosHero(isDark, photos.length),
        const SizedBox(height: 20),
        if (photos.isEmpty) _photosEmpty(isDark, context)
        else ...[_photosGrid(isDark, photos, context), const SizedBox(height: 20), if (photos.length >= 2) _comparison(isDark, photos)],
      ],
    );
  });

  Widget _photosHero(bool isDark, int count) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFFFF6B9D), Color(0xFFFF8E53)]),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [BoxShadow(color: const Color(0xFFFF6B9D).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
    ),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Progress Photos', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        const Text('See your visual progress', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text('$count photos saved', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
      ])),
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
        child: const Icon(Icons.photo_camera_outlined, color: Colors.white, size: 30)),
    ]),
  );

  Widget _photosEmpty(bool isDark, BuildContext context) => Container(
    padding: const EdgeInsets.all(36),
    decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white, borderRadius: BorderRadius.circular(24)),
    child: Column(children: [
      Icon(Icons.add_photo_alternate_outlined, size: 72, color: AppColors.textGrey.withOpacity(0.3)),
      const SizedBox(height: 16),
      Text('No photos yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
      const SizedBox(height: 8),
      const Text('Take progress photos to visualize\nyour transformation over time', style: TextStyle(fontSize: 14, color: AppColors.textGrey), textAlign: TextAlign.center),
      const SizedBox(height: 24),
      ElevatedButton.icon(
        onPressed: () => _showLogPhoto(context, isDark),
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Add First Photo'),
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B9D), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14)),
      ),
    ]),
  );

  Widget _photosGrid(bool isDark, List<Map<String, dynamic>> photos, BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white, borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 15, offset: const Offset(0, 5))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('My Photos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
      const SizedBox(height: 16),
      GridView.builder(
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.85),
        itemCount: photos.length,
        itemBuilder: (_, i) {
          final p = photos[i];
          final path = p['localPath'] as String?;
          return GestureDetector(
            onTap: () => _showPhotoDetail(p, isDark),
            child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Stack(fit: StackFit.expand, children: [
              path != null && File(path).existsSync()
                ? Image.file(File(path), fit: BoxFit.cover)
                : Container(color: const Color(0xFFFF6B9D).withOpacity(0.1), child: const Center(child: Icon(Icons.image, color: Color(0xFFFF6B9D), size: 32))),
              Positioned(bottom: 0, left: 0, right: 0,
                child: Container(padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, Colors.black.withOpacity(0.6)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                  child: Text(DateFormat('MMM d').format(p['date'] as DateTime), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)))),
            ])),
          );
        },
      ),
    ]),
  );

  Widget _comparison(bool isDark, List<Map<String, dynamic>> photos) {
    final first = photos.last, latest = photos.first;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 15, offset: const Offset(0, 5))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Before & After', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _compPhoto(first, 'Before', isDark)),
          const SizedBox(width: 12),
          Expanded(child: _compPhoto(latest, 'After', isDark)),
        ]),
      ]),
    );
  }

  Widget _compPhoto(Map<String, dynamic> p, String label, bool isDark) {
    final path = p['localPath'] as String?;
    return Column(children: [
      ClipRRect(borderRadius: BorderRadius.circular(14), child: AspectRatio(aspectRatio: 0.75,
        child: path != null && File(path).existsSync()
          ? Image.file(File(path), fit: BoxFit.cover)
          : Container(color: const Color(0xFFFF6B9D).withOpacity(0.1), child: const Center(child: Icon(Icons.image, color: Color(0xFFFF6B9D), size: 40))))),
      const SizedBox(height: 8),
      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(color: label == 'Before' ? Colors.grey.withOpacity(0.15) : AppColors.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: label == 'Before' ? AppColors.textGrey : AppColors.primary))),
      const SizedBox(height: 4),
      Text(DateFormat('MMM d, yyyy').format(p['date'] as DateTime), style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
    ]);
  }

  void _showPhotoDetail(Map<String, dynamic> p, bool isDark) {
    Get.bottomSheet(Container(
      height: Get.height * 0.7,
      decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(children: [
        Container(margin: const EdgeInsets.only(top: 12), width: 44, height: 5, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(3))),
        const SizedBox(height: 16),
        Text(DateFormat('EEEE, MMMM d yyyy').format(p['date'] as DateTime), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : AppColors.textDark)),
        const SizedBox(height: 16),
        Expanded(child: Padding(padding: const EdgeInsets.all(16),
          child: ClipRRect(borderRadius: BorderRadius.circular(16),
            child: (p['localPath'] != null && File(p['localPath'] as String).existsSync())
              ? Image.file(File(p['localPath'] as String), fit: BoxFit.contain)
              : Container(color: const Color(0xFFFF6B9D).withOpacity(0.1), child: const Center(child: Icon(Icons.image, size: 80, color: Color(0xFFFF6B9D))))))),
        if (p['notes'] != null) Padding(padding: const EdgeInsets.all(16), child: Text(p['notes'] as String, style: const TextStyle(color: AppColors.textGrey, fontSize: 13), textAlign: TextAlign.center)),
        const SizedBox(height: 16),
      ]),
    ), isScrollControlled: true);
  }

  // ── Dialogs ──────────────────────────────────────────────────────────────────
  void _showLogWeight(BuildContext context, bool isDark) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => _LogWeightSheet(isDark: isDark, onSave: (log) => ctrl.addProgressLog(log)));
  }

  void _showLogPhoto(BuildContext context, bool isDark) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => _LogPhotoSheet(isDark: isDark, onSave: (d) => ctrl.addProgressPhoto(d)));
  }
}

// ── Log Weight Sheet ──────────────────────────────────────────────────────────
class _LogWeightSheet extends StatefulWidget {
  final bool isDark;
  final Function(ProgressLog) onSave;
  const _LogWeightSheet({required this.isDark, required this.onSave});
  @override State<_LogWeightSheet> createState() => _LogWeightSheetState();
}

class _LogWeightSheetState extends State<_LogWeightSheet> {
  final _wCtrl = TextEditingController();
  final _nCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override void dispose() { _wCtrl.dispose(); _nCtrl.dispose(); super.dispose(); }

  void _save() async {
    final w = double.tryParse(_wCtrl.text.trim());
    if (w == null || w <= 0 || w > 500) {
      Get.snackbar('Error', 'Enter a valid weight (kg)', backgroundColor: AppColors.error.withOpacity(0.1), colorText: AppColors.error, snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
      return;
    }
    setState(() => _saving = true);
    final uid = Get.find<AuthController>().firebaseUser.value?.uid ?? 'demo';
    final log = ProgressLog(id: DateTime.now().millisecondsSinceEpoch.toString(), userId: uid, date: _date, weight: w, notes: _nCtrl.text.trim().isEmpty ? null : _nCtrl.text.trim());
    await widget.onSave(log);
    if (mounted) Navigator.of(context).pop();
    Get.snackbar('Logged! ✓', '${w.toStringAsFixed(1)} kg saved', backgroundColor: AppColors.primary.withOpacity(0.12), colorText: AppColors.primary, snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16), borderRadius: 12);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return Container(
      decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
      padding: EdgeInsets.fromLTRB(24, 14, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 44, height: 5, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(3)))),
        const SizedBox(height: 18),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Log Weight', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
          IconButton(icon: Icon(Icons.close, color: AppColors.textGrey), onPressed: () => Navigator.of(context).pop()),
        ]),
        const SizedBox(height: 24),
        Text('Weight (kg) *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : AppColors.textGrey)),
        const SizedBox(height: 8),
        Container(decoration: BoxDecoration(color: isDark ? AppColors.backgroundDark : const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(16)),
          child: TextField(controller: _wCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(color: isDark ? Colors.white : AppColors.textDark, fontSize: 24, fontWeight: FontWeight.bold),
            decoration: InputDecoration(hintText: '70.0', hintStyle: const TextStyle(color: AppColors.textGrey),
              prefixIcon: const Icon(Icons.monitor_weight_outlined, color: AppColors.primary), suffixText: 'kg',
              suffixStyle: const TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.w600),
              border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16)))),
        const SizedBox(height: 16),
        Text('Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : AppColors.textGrey)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final p = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime.now());
            if (p != null) setState(() => _date = p);
          },
          child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: isDark ? AppColors.backgroundDark : const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              const Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 20), const SizedBox(width: 12),
              Text(DateFormat('EEEE, MMM d, yyyy').format(_date), style: TextStyle(color: isDark ? Colors.white : AppColors.textDark, fontWeight: FontWeight.w600)),
              const Spacer(), const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textGrey),
            ])),
        ),
        const SizedBox(height: 16),
        Text('Notes (optional)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : AppColors.textGrey)),
        const SizedBox(height: 8),
        Container(decoration: BoxDecoration(color: isDark ? AppColors.backgroundDark : const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(16)),
          child: TextField(controller: _nCtrl, maxLines: 3, style: TextStyle(color: isDark ? Colors.white : AppColors.textDark),
            decoration: InputDecoration(hintText: 'How are you feeling today?', hintStyle: const TextStyle(color: AppColors.textGrey),
              prefixIcon: const Icon(Icons.notes, color: AppColors.primary), border: InputBorder.none, contentPadding: const EdgeInsets.all(16)))),
        const SizedBox(height: 28),
        SizedBox(width: double.infinity, height: 54,
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: LinearGradient(colors: _saving ? [Colors.grey, Colors.grey] : [AppColors.primary, AppColors.gradientEnd]), borderRadius: BorderRadius.circular(18),
              boxShadow: _saving ? [] : [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))]),
            child: ElevatedButton(onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
              child: _saving ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5) : const Text('Save Entry', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white))))),
      ])),
    );
  }
}

// ── Log Photo Sheet (real image_picker) ──────────────────────────────────────
class _LogPhotoSheet extends StatefulWidget {
  final bool isDark;
  final Function(Map<String, dynamic>) onSave;
  const _LogPhotoSheet({required this.isDark, required this.onSave});
  @override State<_LogPhotoSheet> createState() => _LogPhotoSheetState();
}

class _LogPhotoSheetState extends State<_LogPhotoSheet> {
  File? _img;
  final _nCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  bool _saving = false;
  final _picker = ImagePicker();

  @override void dispose() { _nCtrl.dispose(); super.dispose(); }

  Future<void> _pick(ImageSource src) async {
    try {
      final x = await _picker.pickImage(source: src, maxWidth: 1200, maxHeight: 1600, imageQuality: 85);
      if (x != null) setState(() => _img = File(x.path));
    } catch (e) {
      Get.snackbar('Error', 'Could not access photos: $e', snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.error.withOpacity(0.1), colorText: AppColors.error, margin: const EdgeInsets.all(16));
    }
  }

  void _showPicker() {
    showModalBottomSheet(context: context, builder: (_) => Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: widget.isDark ? AppColors.cardDark : Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(
          leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFFF6B9D).withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.camera_alt, color: Color(0xFFFF6B9D))),
          title: Text('Take Photo', style: TextStyle(color: widget.isDark ? Colors.white : AppColors.textDark, fontWeight: FontWeight.w600)),
          onTap: () { Navigator.pop(context); _pick(ImageSource.camera); },
        ),
        ListTile(
          leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.photo_library, color: AppColors.primary)),
          title: Text('Choose from Gallery', style: TextStyle(color: widget.isDark ? Colors.white : AppColors.textDark, fontWeight: FontWeight.w600)),
          onTap: () { Navigator.pop(context); _pick(ImageSource.gallery); },
        ),
      ]),
    ));
  }

  void _save() async {
    if (_img == null) {
      Get.snackbar('Select a photo', 'Please choose a photo first', backgroundColor: AppColors.error.withOpacity(0.1), colorText: AppColors.error, snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
      return;
    }
    setState(() => _saving = true);
    await widget.onSave({'date': _date, 'localPath': _img!.path, 'notes': _nCtrl.text.trim().isEmpty ? null : _nCtrl.text.trim(), 'id': DateTime.now().millisecondsSinceEpoch.toString()});
    if (mounted) Navigator.of(context).pop();
    Get.snackbar('Photo saved! 📸', 'Progress photo added', backgroundColor: const Color(0xFFFF6B9D).withOpacity(0.12), colorText: const Color(0xFFFF6B9D), snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return Container(
      decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
      padding: EdgeInsets.fromLTRB(24, 14, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 44, height: 5, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(3)))),
        const SizedBox(height: 18),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Add Progress Photo', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
          IconButton(icon: Icon(Icons.close, color: AppColors.textGrey), onPressed: () => Navigator.of(context).pop()),
        ]),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: _showPicker,
          child: Container(height: 220,
            decoration: BoxDecoration(
              color: isDark ? AppColors.backgroundDark : const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _img != null ? const Color(0xFFFF6B9D) : Colors.grey.withOpacity(0.2), width: _img != null ? 2 : 1)),
            child: _img != null
              ? ClipRRect(borderRadius: BorderRadius.circular(19), child: Image.file(_img!, fit: BoxFit.cover, width: double.infinity))
              : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.add_photo_alternate_outlined, size: 56, color: AppColors.textGrey.withOpacity(0.4)),
                  const SizedBox(height: 12),
                  Text('Tap to add photo', style: TextStyle(fontSize: 15, color: AppColors.textGrey, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text('Camera or Gallery', style: TextStyle(fontSize: 12, color: AppColors.textGrey.withOpacity(0.6))),
                ]),
          ),
        ),
        const SizedBox(height: 16),
        Text('Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : AppColors.textGrey)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final p = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime.now());
            if (p != null) setState(() => _date = p);
          },
          child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: isDark ? AppColors.backgroundDark : const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              const Icon(Icons.calendar_today_outlined, color: Color(0xFFFF6B9D), size: 20), const SizedBox(width: 12),
              Text(DateFormat('EEEE, MMM d, yyyy').format(_date), style: TextStyle(color: isDark ? Colors.white : AppColors.textDark, fontWeight: FontWeight.w600)),
              const Spacer(), const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textGrey),
            ])),
        ),
        const SizedBox(height: 16),
        Text('Notes (optional)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : AppColors.textGrey)),
        const SizedBox(height: 8),
        Container(decoration: BoxDecoration(color: isDark ? AppColors.backgroundDark : const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(16)),
          child: TextField(controller: _nCtrl, maxLines: 2, style: TextStyle(color: isDark ? Colors.white : AppColors.textDark),
            decoration: InputDecoration(hintText: 'Any notes about this photo?', hintStyle: const TextStyle(color: AppColors.textGrey),
              prefixIcon: const Icon(Icons.notes, color: Color(0xFFFF6B9D)), border: InputBorder.none, contentPadding: const EdgeInsets.all(16)))),
        const SizedBox(height: 28),
        SizedBox(width: double.infinity, height: 54,
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: LinearGradient(colors: _saving ? [Colors.grey, Colors.grey] : [const Color(0xFFFF6B9D), const Color(0xFFFF8E53)]), borderRadius: BorderRadius.circular(18),
              boxShadow: _saving ? [] : [BoxShadow(color: const Color(0xFFFF6B9D).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))]),
            child: ElevatedButton(onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
              child: _saving ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5) : const Text('Save Photo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white))))),
      ])),
    );
  }
}
