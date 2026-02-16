import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/progress_log_model.dart';
import '../controllers/auth_controller.dart';

class ProgressController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<ProgressLog> progressLogs = <ProgressLog>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedMetric = 'Weight'.obs;
  final RxDouble currentWeight = 0.0.obs;
  final RxDouble targetWeight = 0.0.obs;
  final RxDouble weightChange = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadProgressLogs();
  }

  Future<void> loadProgressLogs() async {
    try {
      isLoading.value = true;
      print('📊 Loading progress logs...');

      // Get auth controller
      final authController = Get.find<AuthController>();
      final userId = authController.currentUser?.uid;

      if (userId == null) {
        print('⚠️ No user logged in for progress');
        isLoading.value = false;
        // Generate sample data for demo
        progressLogs.value = _generateSampleProgressLogs('demo_user');
        calculateWeightStats();
        return;
      }

      print('👤 Loading progress for user: $userId');

      // Try to load from Firestore
      final snapshot = await _firestore
          .collection('progress_logs')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .limit(50)
          .get()
          .timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );

      if (snapshot.docs.isEmpty) {
        print('📭 No progress logs found, using sample data');
        progressLogs.value = _generateSampleProgressLogs(userId);
      } else {
        print('✅ Found ${snapshot.docs.length} progress logs');
        progressLogs.value = snapshot.docs
            .map((doc) => ProgressLog.fromJson(doc.data()))
            .toList();
      }

      calculateWeightStats();
      isLoading.value = false;

    } catch (e) {
      print('⚠️ Error loading progress (using sample data): $e');

      // Use sample data on error
      final authController = Get.find<AuthController>();
      final userId = authController.currentUser?.uid ?? 'demo_user';
      progressLogs.value = _generateSampleProgressLogs(userId);
      calculateWeightStats();

      isLoading.value = false;

      // Don't show error snackbar, just log it
      print('💡 Using sample data for demo purposes');
    }
  }

  Future<void> addProgressLog(ProgressLog log) async {
    try {
      final authController = Get.find<AuthController>();
      final userId = authController.currentUser?.uid;

      if (userId == null) {
        print('❌ No user logged in');
        Get.snackbar('Error', 'Please login to save progress');
        return;
      }

      await _firestore
          .collection('progress_logs')
          .doc(log.id)
          .set(log.toJson());

      // Reload logs
      await loadProgressLogs();

      Get.snackbar(
        'Success',
        'Progress logged successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('❌ Error saving progress: $e');
      Get.snackbar('Error', 'Failed to save progress');
    }
  }

  void calculateWeightStats() {
    if (progressLogs.isEmpty) {
      currentWeight.value = 75.0;
      targetWeight.value = 70.0;
      weightChange.value = -0.5;
      return;
    }

    // Get most recent weight
    final recentLogs = progressLogs.where((log) => log.weight != null).toList();
    if (recentLogs.isEmpty) {
      currentWeight.value = 75.0;
      return;
    }

    currentWeight.value = recentLogs.first.weight!;

    // Calculate weight change (last 30 days)
    final thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));
    final oldLogs = recentLogs
        .where((log) => log.date.isBefore(thirtyDaysAgo))
        .toList();

    if (oldLogs.isNotEmpty) {
      final oldWeight = oldLogs.last.weight!;
      weightChange.value = currentWeight.value - oldWeight;
    }
  }

  void setMetric(String metric) {
    selectedMetric.value = metric;
  }

  List<ProgressLog> get weightLogs =>
      progressLogs.where((log) => log.weight != null).toList();

  List<ProgressLog> get measurementLogs =>
      progressLogs.where((log) => log.measurements != null).toList();

  List<ProgressLog> get photoLogs =>
      progressLogs.where((log) => log.photos != null).toList();

  // Generate sample progress logs
  List<ProgressLog> _generateSampleProgressLogs(String userId) {
    final now = DateTime.now();
    final List<ProgressLog> logs = [];

    // Generate weight logs for the past 60 days
    for (int i = 0; i < 15; i++) {
      final date = now.subtract(Duration(days: i * 4));
      final weight = 75.0 - (i * 0.5) + (i % 2 == 0 ? 0.2 : -0.2);

      logs.add(ProgressLog(
        id: 'progress_$i',
        userId: userId,
        date: date,
        weight: weight,
        bodyFat: 18.0 - (i * 0.3),
        notes: i == 0 ? 'Feeling great!' : null,
      ));
    }

    logs.sort((a, b) => b.date.compareTo(a.date));
    return logs;
  }

  // Get data for charts
  List<Map<String, dynamic>> getWeightChartData() {
    return weightLogs.reversed.map((log) {
      return {
        'date': log.date,
        'weight': log.weight,
      };
    }).toList();
  }

  Map<String, List<double>> getMeasurementChartData() {
    final data = <String, List<double>>{};
    final measurements = ['chest', 'waist', 'hips', 'bicepLeft', 'thighLeft'];

    for (var measurement in measurements) {
      data[measurement] = measurementLogs.reversed
          .where((log) =>
      log.measurements != null &&
          log.measurements!.containsKey(measurement))
          .map((log) => log.measurements![measurement]!)
          .toList();
    }

    return data;
  }
}