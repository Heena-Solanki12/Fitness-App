import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/exercise_model.dart';

class ExerciseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'exercises';

  // Get all exercises stream
  Stream<List<Exercise>> getExercisesStream() {
    return _firestore
        .collection(_collection)
        .orderBy('name')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Exercise.fromJson(doc.data())).toList());
  }

  // Get exercises by category
  Stream<List<Exercise>> getExercisesByCategory(String category) {
    return _firestore
        .collection(_collection)
        .where('category', isEqualTo: category)
        .orderBy('name')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Exercise.fromJson(doc.data())).toList());
  }

  // Get exercises by muscle group
  Future<List<Exercise>> getExercisesByMuscle(String muscle) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('primaryMuscles', arrayContains: muscle)
          .get();

      return snapshot.docs.map((doc) => Exercise.fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to fetch exercises: $e');
    }
  }

  // Search exercises
  Future<List<Exercise>> searchExercises(String query) async {
    try {
      final snapshot = await _firestore.collection(_collection).get();

      return snapshot.docs
          .map((doc) => Exercise.fromJson(doc.data()))
          .where((exercise) =>
      exercise.name.toLowerCase().contains(query.toLowerCase()) ||
          exercise.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      throw Exception('Failed to search exercises: $e');
    }
  }

  // Add exercise (admin function)
  Future<void> addExercise(Exercise exercise) async {
    try {
      await _firestore.collection(_collection).doc(exercise.id).set(exercise.toJson());
    } catch (e) {
      throw Exception('Failed to add exercise: $e');
    }
  }

  // Bulk add exercises (for initial setup)
  Future<void> bulkAddExercises(List<Exercise> exercises) async {
    try {
      final batch = _firestore.batch();

      for (var exercise in exercises) {
        final docRef = _firestore.collection(_collection).doc(exercise.id);
        batch.set(docRef, exercise.toJson());
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to bulk add exercises: $e');
    }
  }

  // Get initial exercises data
  static List<Exercise> getInitialExercises() {
    return [
      // Chest Exercises
      Exercise(
        id: 'ex_chest_1',
        name: 'Barbell Bench Press',
        description: 'Classic compound chest exercise',
        instructions: [
          'Lie flat on bench with feet on floor',
          'Grip bar slightly wider than shoulder width',
          'Lower bar to mid-chest',
          'Press up until arms are fully extended',
        ],
        category: 'Strength',
        primaryMuscles: ['Chest', 'Triceps', 'Shoulders'],
        equipment: ['Barbell', 'Bench'],
        difficulty: 'Intermediate',
      ),
      Exercise(
        id: 'ex_chest_2',
        name: 'Dumbbell Chest Press',
        description: 'Great for chest development with dumbbells',
        instructions: [
          'Lie on bench with dumbbells at chest level',
          'Press dumbbells up and together',
          'Lower with control to starting position',
        ],
        category: 'Strength',
        primaryMuscles: ['Chest', 'Triceps'],
        equipment: ['Dumbbells', 'Bench'],
        difficulty: 'Beginner',
      ),
      Exercise(
        id: 'ex_chest_3',
        name: 'Push-ups',
        description: 'Bodyweight chest and core exercise',
        instructions: [
          'Start in plank position',
          'Lower body until chest nearly touches floor',
          'Push back up to starting position',
        ],
        category: 'Strength',
        primaryMuscles: ['Chest', 'Triceps', 'Core'],
        equipment: ['Bodyweight'],
        difficulty: 'Beginner',
      ),

      // Back Exercises
      Exercise(
        id: 'ex_back_1',
        name: 'Pull-ups',
        description: 'Compound back and biceps exercise',
        instructions: [
          'Hang from bar with palms facing away',
          'Pull yourself up until chin over bar',
          'Lower with control',
        ],
        category: 'Strength',
        primaryMuscles: ['Lats', 'Biceps'],
        equipment: ['Pull-up Bar'],
        difficulty: 'Intermediate',
      ),
      Exercise(
        id: 'ex_back_2',
        name: 'Barbell Row',
        description: 'Build a strong back with rows',
        instructions: [
          'Bend at hips with bar hanging',
          'Pull bar to lower chest',
          'Lower with control',
        ],
        category: 'Strength',
        primaryMuscles: ['Lats', 'Biceps', 'Lower Back'],
        equipment: ['Barbell'],
        difficulty: 'Intermediate',
      ),
      Exercise(
        id: 'ex_back_3',
        name: 'Lat Pulldown',
        description: 'Machine exercise for back width',
        instructions: [
          'Sit at machine with thighs secured',
          'Pull bar down to upper chest',
          'Return to starting position with control',
        ],
        category: 'Strength',
        primaryMuscles: ['Lats', 'Biceps'],
        equipment: ['Cable Machine'],
        difficulty: 'Beginner',
      ),

      // Leg Exercises
      Exercise(
        id: 'ex_legs_1',
        name: 'Barbell Squat',
        description: 'King of leg exercises',
        instructions: [
          'Bar on upper back, feet shoulder-width',
          'Squat down until thighs parallel to floor',
          'Drive through heels to stand',
        ],
        category: 'Strength',
        primaryMuscles: ['Quads', 'Glutes', 'Hamstrings'],
        equipment: ['Barbell', 'Squat Rack'],
        difficulty: 'Intermediate',
      ),
      Exercise(
        id: 'ex_legs_2',
        name: 'Lunges',
        description: 'Unilateral leg exercise',
        instructions: [
          'Step forward with one leg',
          'Lower until both knees at 90 degrees',
          'Push back to starting position',
        ],
        category: 'Strength',
        primaryMuscles: ['Quads', 'Glutes'],
        equipment: ['Bodyweight', 'Dumbbells'],
        difficulty: 'Beginner',
      ),
      Exercise(
        id: 'ex_legs_3',
        name: 'Deadlift',
        description: 'Total body power exercise',
        instructions: [
          'Stand with bar over mid-foot',
          'Bend down and grip bar',
          'Lift by extending hips and knees',
          'Lower with control',
        ],
        category: 'Strength',
        primaryMuscles: ['Hamstrings', 'Glutes', 'Lower Back'],
        equipment: ['Barbell'],
        difficulty: 'Advanced',
      ),

      // Shoulder Exercises
      Exercise(
        id: 'ex_shoulders_1',
        name: 'Overhead Press',
        description: 'Build strong shoulders',
        instructions: [
          'Stand with bar at shoulder level',
          'Press overhead until arms extended',
          'Lower with control',
        ],
        category: 'Strength',
        primaryMuscles: ['Shoulders', 'Triceps'],
        equipment: ['Barbell'],
        difficulty: 'Intermediate',
      ),
      Exercise(
        id: 'ex_shoulders_2',
        name: 'Lateral Raises',
        description: 'Isolation for side delts',
        instructions: [
          'Stand with dumbbells at sides',
          'Raise arms out to sides until parallel to floor',
          'Lower with control',
        ],
        category: 'Strength',
        primaryMuscles: ['Shoulders'],
        equipment: ['Dumbbells'],
        difficulty: 'Beginner',
      ),

      // Arms Exercises
      Exercise(
        id: 'ex_arms_1',
        name: 'Barbell Bicep Curl',
        description: 'Classic bicep builder',
        instructions: [
          'Stand with bar at thigh level',
          'Curl bar up to shoulders',
          'Lower with control',
        ],
        category: 'Strength',
        primaryMuscles: ['Biceps'],
        equipment: ['Barbell'],
        difficulty: 'Beginner',
      ),
      Exercise(
        id: 'ex_arms_2',
        name: 'Tricep Dips',
        description: 'Bodyweight tricep exercise',
        instructions: [
          'Support yourself on parallel bars',
          'Lower body by bending elbows',
          'Push back up to starting position',
        ],
        category: 'Strength',
        primaryMuscles: ['Triceps', 'Chest'],
        equipment: ['Dip Bars'],
        difficulty: 'Intermediate',
      ),

      // Core Exercises
      Exercise(
        id: 'ex_core_1',
        name: 'Plank',
        description: 'Core stability exercise',
        instructions: [
          'Start in forearm plank position',
          'Keep body straight from head to heels',
          'Hold position',
        ],
        category: 'Strength',
        primaryMuscles: ['Core', 'Abs'],
        equipment: ['Bodyweight'],
        difficulty: 'Beginner',
      ),
      Exercise(
        id: 'ex_core_2',
        name: 'Bicycle Crunches',
        description: 'Dynamic ab exercise',
        instructions: [
          'Lie on back with hands behind head',
          'Bring opposite elbow to opposite knee',
          'Alternate sides in cycling motion',
        ],
        category: 'Strength',
        primaryMuscles: ['Abs', 'Obliques'],
        equipment: ['Bodyweight'],
        difficulty: 'Beginner',
      ),
      Exercise(
        id: 'ex_core_3',
        name: 'Russian Twists',
        description: 'Oblique focused exercise',
        instructions: [
          'Sit on floor with knees bent',
          'Lean back slightly',
          'Rotate torso side to side',
        ],
        category: 'Strength',
        primaryMuscles: ['Obliques', 'Abs'],
        equipment: ['Bodyweight', 'Medicine Ball'],
        difficulty: 'Beginner',
      ),

      // Cardio Exercises
      Exercise(
        id: 'ex_cardio_1',
        name: 'Burpees',
        description: 'Full body cardio exercise',
        instructions: [
          'Start standing',
          'Drop to plank position',
          'Do a push-up',
          'Jump feet to hands',
          'Jump up with arms overhead',
        ],
        category: 'Cardio',
        primaryMuscles: ['Full Body'],
        equipment: ['Bodyweight'],
        difficulty: 'Intermediate',
      ),
      Exercise(
        id: 'ex_cardio_2',
        name: 'Mountain Climbers',
        description: 'High intensity cardio',
        instructions: [
          'Start in plank position',
          'Bring one knee to chest',
          'Quickly switch legs',
          'Continue alternating',
        ],
        category: 'Cardio',
        primaryMuscles: ['Core', 'Legs'],
        equipment: ['Bodyweight'],
        difficulty: 'Beginner',
      ),
      Exercise(
        id: 'ex_cardio_3',
        name: 'Jump Squats',
        description: 'Explosive leg power',
        instructions: [
          'Stand in squat position',
          'Squat down',
          'Explode up jumping',
          'Land softly and repeat',
        ],
        category: 'Cardio',
        primaryMuscles: ['Quads', 'Glutes'],
        equipment: ['Bodyweight'],
        difficulty: 'Intermediate',
      ),

      // Flexibility Exercises
      Exercise(
        id: 'ex_flex_1',
        name: 'Downward Dog',
        description: 'Yoga pose for flexibility',
        instructions: [
          'Start on hands and knees',
          'Lift hips up and back',
          'Form inverted V shape',
          'Hold position',
        ],
        category: 'Flexibility',
        primaryMuscles: ['Full Body'],
        equipment: ['Yoga Mat'],
        difficulty: 'Beginner',
      ),
      Exercise(
        id: 'ex_flex_2',
        name: 'Child Pose',
        description: 'Resting yoga pose',
        instructions: [
          'Start on hands and knees',
          'Sit back on heels',
          'Extend arms forward',
          'Relax and breathe',
        ],
        category: 'Flexibility',
        primaryMuscles: ['Back', 'Hips'],
        equipment: ['Yoga Mat'],
        difficulty: 'Beginner',
      ),
    ];
  }
}