// lib/views/progress/body_measurements_view.dart
import 'package:flutter/material.dart';
import '../../controllers/theme_controller.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/progress_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../models/measurement_log_model.dart';

class BodyMeasurementsView extends StatelessWidget {
  const BodyMeasurementsView({super.key});
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
          Expanded(child: Obx(() {
            if (ctrl.isLoading.value && ctrl.measurementLogs.isEmpty)
              return const Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF)));
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              children: [
                if (ctrl.measurementLogs.isEmpty) _emptyState(isDark, context)
                else ...[
                  _summaryCard(isDark),
                  const SizedBox(height: 20),
                  _allMeasurementsCard(isDark),
                  const SizedBox(height: 20),
                  _trendCharts(isDark),
                  const SizedBox(height: 20),
                  _historyList(isDark),
                ],
              ],
            );
          })),
        ])),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
          builder: (_) => _LogMeasurementsSheet(isDark: isDark, onSave: (log) => _saveMeasurement(log))),
        icon: const Icon(Icons.add), label: const Text('Log Measurements'),
        backgroundColor: const Color(0xFF7C4DFF),
      ),
    );
    });
  }

  Future<void> _saveMeasurement(MeasurementLog log) async {
    try {
      final uid = Get.find<AuthController>().firebaseUser.value?.uid ?? 'demo';
      final fullLog = MeasurementLog(id: log.id, userId: uid, date: log.date,
        chest: log.chest, waist: log.waist, hips: log.hips,
        bicepLeft: log.bicepLeft, bicepRight: log.bicepRight,
        shoulders: log.shoulders, neck: log.neck,
        thighLeft: log.thighLeft, thighRight: log.thighRight,
        calfLeft: log.calfLeft, calfRight: log.calfRight,
        forearmLeft: log.forearmLeft, forearmRight: log.forearmRight,
        notes: log.notes);
      ctrl.measurementLogs.insert(0, fullLog);
      ctrl.latestMeasurementLog.value = fullLog;
      if (ctrl.measurementLogs.length >= 2) {
        final a = ctrl.measurementLogs[0].measurementsMap;
        final b = ctrl.measurementLogs[1].measurementsMap;
        ctrl.measurementChange.clear();
        a.forEach((k, v) { if (b.containsKey(k)) ctrl.measurementChange[k] = v - b[k]!; });
      }
    } catch (_) {}
  }

  Widget _appBar(bool isDark) => Container(
    padding: const EdgeInsets.fromLTRB(8, 12, 20, 12),
    decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white,
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))]),
    child: Row(children: [
      IconButton(icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : AppColors.textDark, size: 20), onPressed: () => Get.back()),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Body Measurements', style: TextStyle(color: isDark ? Colors.white : AppColors.textDark, fontSize: 20, fontWeight: FontWeight.bold)),
        Obx(() => Text('${ctrl.measurementLogs.length} sessions logged', style: const TextStyle(color: AppColors.textGrey, fontSize: 12))),
      ]),
    ]),
  );

  Widget _emptyState(bool isDark, BuildContext context) => Container(
    padding: const EdgeInsets.all(36),
    decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white, borderRadius: BorderRadius.circular(24)),
    child: Column(children: [
      Icon(Icons.straighten, size: 72, color: const Color(0xFF7C4DFF).withOpacity(0.4)), const SizedBox(height: 16),
      Text('No Measurements Yet', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
      const SizedBox(height: 8),
      const Text('Track your body measurements\nto monitor your progress', style: TextStyle(fontSize: 14, color: AppColors.textGrey), textAlign: TextAlign.center),
      const SizedBox(height: 24),
      ElevatedButton.icon(
        onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
          builder: (_) => _LogMeasurementsSheet(isDark: isDark, onSave: (log) => _saveMeasurement(log))),
        icon: const Icon(Icons.add), label: const Text('Log First Session'),
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C4DFF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14))),
    ]),
  );

  Widget _summaryCard(bool isDark) {
    final parts = [
      {'key': 'Chest', 'icon': Icons.accessibility_new, 'color': const Color(0xFF4E54C8)},
      {'key': 'Waist', 'icon': Icons.accessibility, 'color': const Color(0xFFFF6B9D)},
      {'key': 'Hips', 'icon': Icons.airline_seat_legroom_normal, 'color': const Color(0xFFFF8C00)},
      {'key': 'Left Bicep', 'icon': Icons.fitness_center, 'color': const Color(0xFF00B894)},
      {'key': 'Left Thigh', 'icon': Icons.directions_walk, 'color': const Color(0xFF7C4DFF)},
      {'key': 'Shoulders', 'icon': Icons.person, 'color': const Color(0xFF00CEC9)},
    ];
    return Obx(() {
      final latest = ctrl.latestMeasurementLog.value;
      if (latest == null) return const SizedBox.shrink();
      final map = latest.measurementsMap;
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white, borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 15, offset: const Offset(0, 5))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Latest Session', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFF7C4DFF).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(DateFormat('MMM d, yyyy').format(latest.date), style: const TextStyle(fontSize: 12, color: Color(0xFF7C4DFF), fontWeight: FontWeight.w600))),
          ]),
          const SizedBox(height: 16),
          GridView.count(crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.0,
            children: parts.map((p) {
              final val = map[p['key'] as String];
              final change = ctrl.measurementChange.value[p['key'] as String];
              final c = p['color'] as Color;
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: c.withOpacity(0.07), borderRadius: BorderRadius.circular(14), border: Border.all(color: c.withOpacity(0.15))),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(p['icon'] as IconData, color: c, size: 18),
                  const SizedBox(height: 4),
                  Text(val != null ? val.toStringAsFixed(1) : '–', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
                  Text(p['key'] as String, style: const TextStyle(fontSize: 8, color: AppColors.textGrey), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (change != null && change != 0)
                    Text('${change > 0 ? '+' : ''}${change.toStringAsFixed(1)}',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: change < 0 ? const Color(0xFF00B894) : const Color(0xFFFF7675))),
                ]),
              );
            }).toList()),
        ]),
      );
    });
  }

  Widget _allMeasurementsCard(bool isDark) {
    final allParts = [
      {'key': 'Chest', 'icon': Icons.accessibility_new}, {'key': 'Waist', 'icon': Icons.accessibility},
      {'key': 'Hips', 'icon': Icons.airline_seat_legroom_normal}, {'key': 'Shoulders', 'icon': Icons.person},
      {'key': 'Neck', 'icon': Icons.face}, {'key': 'Left Bicep', 'icon': Icons.fitness_center},
      {'key': 'Right Bicep', 'icon': Icons.fitness_center}, {'key': 'Left Forearm', 'icon': Icons.fitness_center},
      {'key': 'Right Forearm', 'icon': Icons.fitness_center}, {'key': 'Left Thigh', 'icon': Icons.directions_walk},
      {'key': 'Right Thigh', 'icon': Icons.directions_walk}, {'key': 'Left Calf', 'icon': Icons.directions_run},
      {'key': 'Right Calf', 'icon': Icons.directions_run},
    ];
    return Obx(() {
      final latest = ctrl.latestMeasurementLog.value;
      if (latest == null) return const SizedBox.shrink();
      final map = latest.measurementsMap;
      final tracked = allParts.where((p) => map[p['key'] as String] != null).toList();
      if (tracked.isEmpty) return const SizedBox.shrink();
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white, borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 15, offset: const Offset(0, 5))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('All Measurements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
          const SizedBox(height: 16),
          ...tracked.map((p) {
            final val = map[p['key'] as String]!;
            final change = ctrl.measurementChange.value[p['key'] as String];
            return Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [
              Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFF7C4DFF).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(p['icon'] as IconData, color: const Color(0xFF7C4DFF), size: 17)),
              const SizedBox(width: 12),
              Expanded(child: Text(p['key'] as String, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? Colors.white70 : AppColors.textGrey))),
              Row(children: [
                Text('${val.toStringAsFixed(1)} cm', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
                if (change != null && change != 0) ...[
                  const SizedBox(width: 8),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(color: (change < 0 ? const Color(0xFF00B894) : const Color(0xFFFF7675)).withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                    child: Text('${change > 0 ? '+' : ''}${change.toStringAsFixed(1)}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: change < 0 ? const Color(0xFF00B894) : const Color(0xFFFF7675)))),
                ],
              ]),
            ]));
          }),
        ]),
      );
    });
  }

  Widget _trendCharts(bool isDark) {
    final metrics = ['Chest', 'Waist', 'Hips'];
    return Obx(() {
      if (ctrl.measurementLogs.length < 2) return const SizedBox.shrink();
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white, borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 15, offset: const Offset(0, 5))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Trends', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
          const SizedBox(height: 16),
          ...metrics.map((m) {
            final data = ctrl.getMeasurementChartData(m);
            if (data.length < 2) return const SizedBox.shrink();
            final vals = data.map((d) => d['value'] as double).toList();
            final minV = vals.reduce((a, b) => a < b ? a : b) - 1;
            final maxV = vals.reduce((a, b) => a > b ? a : b) + 1;
            final diff = vals.last - vals.first;
            return Padding(padding: const EdgeInsets.only(bottom: 24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(m, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
                Row(children: [
                  Text('${vals.last.toStringAsFixed(1)} cm ', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF7C4DFF))),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(color: (diff <= 0 ? const Color(0xFF00B894) : const Color(0xFFFF7675)).withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                    child: Text('${diff > 0 ? '+' : ''}${diff.toStringAsFixed(1)}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: diff <= 0 ? const Color(0xFF00B894) : const Color(0xFFFF7675)))),
                ]),
              ]),
              const SizedBox(height: 10),
              SizedBox(height: 90, child: LineChart(LineChartData(
                minY: minV, maxY: maxV,
                gridData: FlGridData(show: true, drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) => FlLine(color: isDark ? Colors.white.withOpacity(0.07) : Colors.grey.withOpacity(0.12), strokeWidth: 1)),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22, interval: (data.length / 3).ceilToDouble(),
                    getTitlesWidget: (v, _) {
                      final i = v.toInt();
                      if (i < 0 || i >= data.length) return const Text('');
                      return Text(DateFormat('M/d').format(data[i]['date'] as DateTime), style: const TextStyle(color: AppColors.textGrey, fontSize: 9));
                    })),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 34,
                    getTitlesWidget: (v, _) => Text(v.toStringAsFixed(0), style: const TextStyle(color: AppColors.textGrey, fontSize: 9)))),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [LineChartBarData(
                  spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value['value'] as double)).toList(),
                  isCurved: true,
                  gradient: const LinearGradient(colors: [Color(0xFF7C4DFF), Color(0xFF5563DE)]),
                  barWidth: 2.5, isStrokeCapRound: true,
                  dotData: FlDotData(show: data.length <= 8, getDotPainter: (s, p, b, i) => FlDotCirclePainter(radius: 3, color: Colors.white, strokeWidth: 2, strokeColor: const Color(0xFF7C4DFF))),
                  belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [const Color(0xFF7C4DFF).withOpacity(0.2), Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                )],
              ))),
            ]));
          }),
        ]),
      );
    });
  }

  Widget _historyList(bool isDark) => Obx(() {
    if (ctrl.measurementLogs.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 15, offset: const Offset(0, 5))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('All Sessions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
        const SizedBox(height: 16),
        ...ctrl.measurementLogs.map((log) {
          final map = log.measurementsMap;
          return ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(DateFormat('EEE, MMM d yyyy').format(log.date), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.textDark)),
            subtitle: Text('${map.length} measurements', style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
            leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF7C4DFF).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: const Center(child: Icon(Icons.straighten, color: Color(0xFF7C4DFF), size: 20))),
            children: [
              Padding(padding: const EdgeInsets.only(left: 52, bottom: 12),
                child: Wrap(spacing: 8, runSpacing: 8, children: map.entries.map((e) =>
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: const Color(0xFF7C4DFF).withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
                    child: Text('${e.key}: ${e.value.toStringAsFixed(1)} cm', style: const TextStyle(fontSize: 12, color: Color(0xFF7C4DFF), fontWeight: FontWeight.w500)))).toList())),
              if (log.notes != null) Padding(padding: const EdgeInsets.only(left: 52, bottom: 12, right: 16),
                child: Text(log.notes!, style: const TextStyle(fontSize: 12, color: AppColors.textGrey, fontStyle: FontStyle.italic))),
            ],
          );
        }),
      ]),
    );
  });
}

// ── Log Measurements Sheet ───────────────────────────────────────────────────
class _LogMeasurementsSheet extends StatefulWidget {
  final bool isDark;
  final Function(MeasurementLog) onSave;
  const _LogMeasurementsSheet({required this.isDark, required this.onSave});
  @override State<_LogMeasurementsSheet> createState() => _LogMeasurementsSheetState();
}

class _LogMeasurementsSheetState extends State<_LogMeasurementsSheet> {
  final Map<String, TextEditingController> _ctrls = {};
  final _notesCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  bool _saving = false;

  final _fields = [
    {'key': 'chest', 'label': 'Chest', 'icon': Icons.accessibility_new},
    {'key': 'waist', 'label': 'Waist', 'icon': Icons.accessibility},
    {'key': 'hips', 'label': 'Hips', 'icon': Icons.airline_seat_legroom_normal},
    {'key': 'shoulders', 'label': 'Shoulders', 'icon': Icons.person},
    {'key': 'neck', 'label': 'Neck', 'icon': Icons.face},
    {'key': 'bicepLeft', 'label': 'L. Bicep', 'icon': Icons.fitness_center},
    {'key': 'bicepRight', 'label': 'R. Bicep', 'icon': Icons.fitness_center},
    {'key': 'forearmLeft', 'label': 'L. Forearm', 'icon': Icons.fitness_center},
    {'key': 'forearmRight', 'label': 'R. Forearm', 'icon': Icons.fitness_center},
    {'key': 'thighLeft', 'label': 'L. Thigh', 'icon': Icons.directions_walk},
    {'key': 'thighRight', 'label': 'R. Thigh', 'icon': Icons.directions_walk},
    {'key': 'calfLeft', 'label': 'L. Calf', 'icon': Icons.directions_run},
    {'key': 'calfRight', 'label': 'R. Calf', 'icon': Icons.directions_run},
  ];

  @override
  void initState() {
    super.initState();
    for (final f in _fields) _ctrls[f['key'] as String] = TextEditingController();
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) c.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  double? _val(String key) => double.tryParse(_ctrls[key]!.text.trim());

  void _save() async {
    final hasAny = _fields.any((f) => _val(f['key'] as String) != null);
    if (!hasAny) {
      Get.snackbar('No data', 'Enter at least one measurement', backgroundColor: AppColors.error.withOpacity(0.1), colorText: AppColors.error, snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
      return;
    }
    setState(() => _saving = true);
    final uid = Get.find<AuthController>().firebaseUser.value?.uid ?? 'demo';
    final log = MeasurementLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(), userId: uid, date: _date,
      chest: _val('chest'), waist: _val('waist'), hips: _val('hips'),
      shoulders: _val('shoulders'), neck: _val('neck'),
      bicepLeft: _val('bicepLeft'), bicepRight: _val('bicepRight'),
      forearmLeft: _val('forearmLeft'), forearmRight: _val('forearmRight'),
      thighLeft: _val('thighLeft'), thighRight: _val('thighRight'),
      calfLeft: _val('calfLeft'), calfRight: _val('calfRight'),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    await widget.onSave(log);
    if (mounted) Navigator.of(context).pop();
    Get.snackbar('Saved! ✓', 'Measurements logged successfully',
      backgroundColor: const Color(0xFF7C4DFF).withOpacity(0.12), colorText: const Color(0xFF7C4DFF),
      snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16), borderRadius: 12);
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
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Log Measurements', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
            const Text('Fill in the measurements you have', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
          ]),
          IconButton(icon: const Icon(Icons.close, color: AppColors.textGrey), onPressed: () => Navigator.of(context).pop()),
        ]),
        const SizedBox(height: 20),
        Text('Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : AppColors.textGrey)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final p = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime.now());
            if (p != null) setState(() => _date = p);
          },
          child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: isDark ? AppColors.backgroundDark : const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              const Icon(Icons.calendar_today_outlined, color: Color(0xFF7C4DFF), size: 18), const SizedBox(width: 10),
              Text(DateFormat('EEE, MMMM d, yyyy').format(_date), style: TextStyle(color: isDark ? Colors.white : AppColors.textDark, fontWeight: FontWeight.w600, fontSize: 14)),
              const Spacer(), const Icon(Icons.arrow_forward_ios, size: 13, color: AppColors.textGrey),
            ])),
        ),
        const SizedBox(height: 20),
        Text('Measurements (cm)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : AppColors.textGrey)),
        const SizedBox(height: 12),
        // Fixed grid: use ListView instead of GridView to avoid overflow
        ...List.generate((_fields.length / 2).ceil(), (row) {
          final left = _fields[row * 2];
          final rightIndex = row * 2 + 1;
          final right = rightIndex < _fields.length ? _fields[rightIndex] : null;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              Expanded(child: _inputTile(left['key'] as String, left['label'] as String, left['icon'] as IconData, isDark)),
              const SizedBox(width: 10),
              Expanded(child: right != null
                ? _inputTile(right['key'] as String, right['label'] as String, right['icon'] as IconData, isDark)
                : const SizedBox.shrink()),
            ]),
          );
        }),
        const SizedBox(height: 12),
        Text('Notes (optional)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : AppColors.textGrey)),
        const SizedBox(height: 8),
        Container(decoration: BoxDecoration(color: isDark ? AppColors.backgroundDark : const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(14)),
          child: TextField(controller: _notesCtrl, maxLines: 2, style: TextStyle(color: isDark ? Colors.white : AppColors.textDark),
            decoration: InputDecoration(hintText: 'Any notes…', hintStyle: const TextStyle(color: AppColors.textGrey),
              prefixIcon: const Icon(Icons.notes, color: Color(0xFF7C4DFF)), border: InputBorder.none, contentPadding: const EdgeInsets.all(14)))),
        const SizedBox(height: 28),
        SizedBox(width: double.infinity, height: 54,
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: LinearGradient(colors: _saving ? [Colors.grey, Colors.grey] : [const Color(0xFF7C4DFF), const Color(0xFF5563DE)]), borderRadius: BorderRadius.circular(18),
              boxShadow: _saving ? [] : [const BoxShadow(color: Color(0x447C4DFF), blurRadius: 12, offset: Offset(0, 6))]),
            child: ElevatedButton(onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
              child: _saving ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                : const Text('Save Measurements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white))))),
      ])),
    );
  }

  Widget _inputTile(String key, String label, IconData icon, bool isDark) => Container(
    height: 52,
    decoration: BoxDecoration(color: isDark ? AppColors.backgroundDark : const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(12)),
    child: Row(children: [
      const SizedBox(width: 10),
      Icon(icon, color: const Color(0xFF7C4DFF), size: 16),
      const SizedBox(width: 6),
      Expanded(child: TextField(
        controller: _ctrls[key],
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: TextInputAction.next,
        style: TextStyle(color: isDark ? Colors.white : AppColors.textDark, fontSize: 14),
        decoration: InputDecoration(
          hintText: label, hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 12),
          border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 14)),
      )),
      Padding(padding: const EdgeInsets.only(right: 8), child: Text('cm', style: const TextStyle(color: AppColors.textGrey, fontSize: 10))),
    ]),
  );
}
