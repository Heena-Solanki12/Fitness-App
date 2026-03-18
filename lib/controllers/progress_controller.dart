// lib/controllers/progress_controller.dart
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/progress_log_model.dart';
import '../models/measurement_log_model.dart';
import '../controllers/auth_controller.dart';

class ProgressController extends GetxController {
  final _db = FirebaseFirestore.instance;

  final RxList<ProgressLog> progressLogs = <ProgressLog>[].obs;
  final RxList<MeasurementLog> measurementLogs = <MeasurementLog>[].obs;
  final RxList<Map<String, dynamic>> progressPhotos = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedMetric = 'Weight'.obs;
  final RxDouble currentWeight = 0.0.obs;
  final RxDouble weightChange = 0.0.obs;
  final Rx<MeasurementLog?> latestMeasurementLog = Rx<MeasurementLog?>(null);
  final RxMap<String, double> measurementChange = <String, double>{}.obs;

  @override
  void onInit() { super.onInit(); _load(); }

  Future<void> _load() async {
    isLoading.value = true;
    try {
      final uid = Get.find<AuthController>().firebaseUser.value?.uid;
      if (uid == null) { _loadSamples('demo'); isLoading.value = false; return; }
      await Future.wait([_loadWeight(uid), _loadMeasurements(uid), _loadPhotos(uid)]);
    } catch (e) {
      _loadSamples('demo');
    }
    isLoading.value = false;
  }

  Future<void> _loadWeight(String uid) async {
    try {
      final snap = await _db.collection('progress_logs').where('userId', isEqualTo: uid).orderBy('date', descending: true).limit(50).get();
      progressLogs.value = snap.docs.isEmpty ? _sampleWeightLogs(uid) : snap.docs.map((d) => ProgressLog.fromJson(d.data())).toList();
    } catch (_) { progressLogs.value = _sampleWeightLogs(uid); }
    _calcWeightStats();
  }

  Future<void> _loadMeasurements(String uid) async {
    try {
      final snap = await _db.collection('measurement_logs').where('userId', isEqualTo: uid).orderBy('date', descending: true).limit(30).get();
      measurementLogs.value = snap.docs.map((d) => MeasurementLog.fromJson(d.data())).toList();
      if (measurementLogs.isNotEmpty) {
        latestMeasurementLog.value = measurementLogs.first;
        if (measurementLogs.length >= 2) {
          final a = measurementLogs[0].measurementsMap, b = measurementLogs[1].measurementsMap;
          measurementChange.clear();
          a.forEach((k, v) { if (b.containsKey(k)) measurementChange[k] = v - b[k]!; });
        }
      }
    } catch (_) {}
  }

  Future<void> _loadPhotos(String uid) async {
    try {
      final snap = await _db.collection('progress_photos').where('userId', isEqualTo: uid).orderBy('date', descending: true).get();
      progressPhotos.value = snap.docs.map((d) => d.data()).toList();
    } catch (_) {}
  }

  void _loadSamples(String uid) {
    progressLogs.value = _sampleWeightLogs(uid);
    _calcWeightStats();
  }

  void _calcWeightStats() {
    final logs = weightLogs;
    if (logs.isEmpty) { currentWeight.value = 75.0; return; }
    currentWeight.value = logs.first.weight!;
    final old = logs.where((l) => l.date.isBefore(DateTime.now().subtract(const Duration(days: 30)))).toList();
    weightChange.value = old.isNotEmpty ? currentWeight.value - old.last.weight! : 0;
  }

  Future<void> addProgressLog(ProgressLog log) async {
    try { await _db.collection('progress_logs').doc(log.id).set(log.toJson()); } catch (_) {}
    progressLogs.insert(0, log);
    _calcWeightStats();
  }

  Future<void> addProgressPhoto(Map<String, dynamic> data) async {
    try {
      final uid = Get.find<AuthController>().firebaseUser.value?.uid ?? 'demo';
      final doc = {...data, 'userId': uid};
      await _db.collection('progress_photos').doc(data['id'] as String).set(doc);
    } catch (_) {}
    progressPhotos.insert(0, data);
  }

  void setMetric(String m) => selectedMetric.value = m;

  List<ProgressLog> get weightLogs => progressLogs.where((l) => l.weight != null).toList();

  List<Map<String, dynamic>> getWeightChartData() =>
    weightLogs.reversed.map((l) => {'date': l.date, 'weight': l.weight}).toList();

  List<Map<String, dynamic>> getMeasurementChartData(String type) {
    bool hasValue(dynamic l) {
      if (type == 'Chest') return l.chest != null;
      if (type == 'Waist') return l.waist != null;
      if (type == 'Hips') return l.hips != null;
      if (type == 'Bicep') return l.bicepLeft != null;
      if (type == 'Thigh') return l.thighLeft != null;
      return false;
    }
    double getValue(dynamic l) {
      if (type == 'Chest') return l.chest as double;
      if (type == 'Waist') return l.waist as double;
      if (type == 'Hips') return l.hips as double;
      if (type == 'Bicep') return l.bicepLeft as double;
      if (type == 'Thigh') return l.thighLeft as double;
      return 0;
    }
    return measurementLogs.reversed
      .where((l) => hasValue(l))
      .map((l) => {'date': l.date, 'value': getValue(l)})
      .toList();
  }

  List<ProgressLog> _sampleWeightLogs(String uid) {
    final now = DateTime.now();
    return List.generate(15, (i) {
      final date = now.subtract(Duration(days: i * 4));
      return ProgressLog(id: 'sample_$i', userId: uid, date: date, weight: 75.0 - (i * 0.4) + (i % 2 == 0 ? 0.2 : -0.1), notes: i == 0 ? 'Feeling great!' : null);
    })..sort((a, b) => b.date.compareTo(a.date));
  }
}
