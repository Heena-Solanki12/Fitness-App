import '../services/exercise_service.dart';

class FirebaseInit {
  static Future<void> initializeExercises() async {
    final service = ExerciseService();
    final exercises = ExerciseService.getInitialExercises();

    try {
      await service.bulkAddExercises(exercises);
      print('✅ Exercises initialized successfully!');
    } catch (e) {
      print('❌ Error initializing exercises: $e');
    }
  }
}