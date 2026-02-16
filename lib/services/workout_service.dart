import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout_model.dart';

class WorkoutService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'workouts';

  // Get all workouts stream
  Stream<List<Workout>> getWorkoutsStream() {
    return _firestore
        .collection(_collection)
        .where('isCustom', isEqualTo: false) // Public workouts
        .orderBy('name')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Workout.fromJson(doc.data())).toList());
  }

  // Get user's custom workouts
  Stream<List<Workout>> getUserWorkoutsStream(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('isCustom', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Workout.fromJson(doc.data())).toList());
  }

  // Add custom workout
  Future<void> addWorkout(Workout workout) async {
    try {
      await _firestore.collection(_collection).doc(workout.id).set(workout.toJson());
    } catch (e) {
      throw Exception('Failed to save workout: $e');
    }
  }

  // Update workout
  Future<void> updateWorkout(Workout workout) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(workout.id)
          .update(workout.toJson());
    } catch (e) {
      throw Exception('Failed to update workout: $e');
    }
  }

  // Delete workout
  Future<void> deleteWorkout(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete workout: $e');
    }
  }

  // Get workout by ID
  Future<Workout?> getWorkoutById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();

      if (!doc.exists) return null;

      return Workout.fromJson(doc.data()!);
    } catch (e) {
      return null;
    }
  }

  // Search workouts
  Future<List<Workout>> searchWorkouts(String query, String? userId) async {
    try {
      // Get all workouts (public + user's custom)
      final publicSnapshot =
      await _firestore.collection(_collection).where('isCustom', isEqualTo: false).get();

      List<Workout> workouts =
      publicSnapshot.docs.map((doc) => Workout.fromJson(doc.data())).toList();

      if (userId != null) {
        final customSnapshot = await _firestore
            .collection(_collection)
            .where('userId', isEqualTo: userId)
            .where('isCustom', isEqualTo: true)
            .get();

        workouts.addAll(customSnapshot.docs
            .map((doc) => Workout.fromJson(doc.data()))
            .toList());
      }

      // Filter by query
      return workouts
          .where((workout) =>
      workout.name.toLowerCase().contains(query.toLowerCase()) ||
          workout.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      throw Exception('Failed to search workouts: $e');
    }
  }
}