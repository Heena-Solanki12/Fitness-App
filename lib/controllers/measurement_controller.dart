import 'package:get/get.dart';
import '../services/measurement_service.dart';
import '../models/measurement_log_model.dart';
import '../controllers/auth_controller.dart';
import 'dart:async';

class MeasurementController extends GetxController {
  final MeasurementService _service = MeasurementService();
  final AuthController _authController = Get.find<AuthController>();

  final RxList<MeasurementLog> measurements = <MeasurementLog>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<MeasurementLog?> latestMeasurement = Rx<MeasurementLog?>(null);

  StreamSubscription? _measurementSubscription;

  // Current measurements for comparison
  final RxMap<String, double> currentMeasurements = <String, double>{}.obs;
  final RxMap<String, double> changeFromLast = <String, double>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadMeasurements();
  }

  @override
  void onClose() {
    _measurementSubscription?.cancel();
    super.onClose();
  }

  void loadMeasurements() {
    final userId = _authController.firebaseUser.value?.uid;
    if (userId == null) return;

    isLoading.value = true;

    _measurementSubscription = _service
        .getMeasurementsStream(userId)
        .listen((logs) {
      measurements.value = logs;
      if (logs.isNotEmpty) {
        latestMeasurement.value = logs.first;
        currentMeasurements.value = logs.first.measurementsMap;
        _calculateChanges(logs);
      }
      isLoading.value = false;
    }, onError: (error) {
      Get.snackbar('Error', 'Failed to load measurements: $error');
      isLoading.value = false;
    });
  }

  void _calculateChanges(List<MeasurementLog> logs) {
    if (logs.length < 2) {
      changeFromLast.clear();
      return;
    }

    final latest = logs[0].measurementsMap;
    final previous = logs[1].measurementsMap;

    changeFromLast.clear();
    latest.forEach((key, value) {
      if (previous.containsKey(key)) {
        changeFromLast[key] = value - previous[key]!;
      }
    });
  }

  Future<void> addMeasurement(MeasurementLog log) async {
    try {
      isLoading.value = true;
      await _service.addMeasurementLog(log);

      Get.snackbar(
        'Success',
        'Measurements saved successfully!',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save measurements: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateMeasurement(MeasurementLog log) async {
    try {
      isLoading.value = true;
      await _service.updateMeasurementLog(log);

      Get.snackbar(
        'Success',
        'Measurements updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update measurements: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteMeasurement(String id) async {
    try {
      await _service.deleteMeasurementLog(id);

      Get.snackbar(
        'Success',
        'Measurement deleted',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete measurement: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Get data for specific measurement chart
  List<Map<String, dynamic>> getChartData(String measurementType) {
    return measurements.reversed.where((log) {
      switch (measurementType) {
        case 'Chest':
          return log.chest != null;
        case 'Waist':
          return log.waist != null;
        case 'Hips':
          return log.hips != null;
        case 'Bicep':
          return log.bicepLeft != null || log.bicepRight != null;
        case 'Thigh':
          return log.thighLeft != null || log.thighRight != null;
        default:
          return false;
      }
    }).map((log) {
      double value = 0;
      switch (measurementType) {
        case 'Chest':
          value = log.chest!;
          break;
        case 'Waist':
          value = log.waist!;
          break;
        case 'Hips':
          value = log.hips!;
          break;
        case 'Bicep':
          value = ((log.bicepLeft ?? 0) + (log.bicepRight ?? 0)) / 2;
          break;
        case 'Thigh':
          value = ((log.thighLeft ?? 0) + (log.thighRight ?? 0)) / 2;
          break;
      }
      return {
        'date': log.date,
        'value': value,
      };
    }).toList();
  }

  // Get comparison data
  Map<String, Map<String, dynamic>> getComparisonData() {
    if (measurements.length < 2) return {};

    final latest = measurements.first;
    final previous = measurements[1];

    return {
      'Chest': {
        'current': latest.chest ?? 0,
        'previous': previous.chest ?? 0,
        'change': (latest.chest ?? 0) - (previous.chest ?? 0),
      },
      'Waist': {
        'current': latest.waist ?? 0,
        'previous': previous.waist ?? 0,
        'change': (latest.waist ?? 0) - (previous.waist ?? 0),
      },
      'Hips': {
        'current': latest.hips ?? 0,
        'previous': previous.hips ?? 0,
        'change': (latest.hips ?? 0) - (previous.hips ?? 0),
      },
    };
  }
}