import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/measurement_log_model.dart';

class MeasurementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'measurement_logs';

  // Add measurement log
  Future<void> addMeasurementLog(MeasurementLog log) async {
    try {
      await _firestore.collection(_collection).doc(log.id).set(log.toJson());
    } catch (e) {
      throw Exception('Failed to save measurement: $e');
    }
  }

  // Get measurements for user
  Stream<List<MeasurementLog>> getMeasurementsStream(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => MeasurementLog.fromJson(doc.data()))
        .toList());
  }

  // Get measurements by date range
  Future<List<MeasurementLog>> getMeasurementsByDateRange(
      String userId,
      DateTime startDate,
      DateTime endDate,
      ) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => MeasurementLog.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch measurements: $e');
    }
  }

  // Update measurement log
  Future<void> updateMeasurementLog(MeasurementLog log) async {
    try {
      await _firestore.collection(_collection).doc(log.id).update(log.toJson());
    } catch (e) {
      throw Exception('Failed to update measurement: $e');
    }
  }

  // Delete measurement log
  Future<void> deleteMeasurementLog(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete measurement: $e');
    }
  }

  // Get latest measurement
  Future<MeasurementLog?> getLatestMeasurement(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return MeasurementLog.fromJson(snapshot.docs.first.data());
    } catch (e) {
      return null;
    }
  }
}