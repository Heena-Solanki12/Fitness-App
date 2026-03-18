// lib/controllers/workout_controller.dart
import 'package:get/get.dart';
import '../models/workout_model.dart';
import '../models/workout_exercise.dart';
import '../services/goal_recommendation_service.dart';
import '../controllers/auth_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<Workout> workouts = <Workout>[].obs;
  final RxList<Workout> filteredWorkouts = <Workout>[].obs;
  final RxList<Workout> recommendedWorkouts = <Workout>[].obs;
  final Rx<Workout?> todaysWorkout = Rx<Workout?>(null);
  final RxBool isLoading = false.obs;
  final RxString selectedCategory = 'All'.obs;
  final RxString selectedDifficulty = 'All'.obs;
  final RxString searchQuery = ''.obs;

  final RxString userGoal = 'Stay Fit'.obs;
  final RxString userLevel = 'Beginner'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserGoal();
    loadSampleWorkouts();
  }

  Future<void> _loadUserGoal() async {
    try {
      final authController = Get.find<AuthController>();
      final userId = authController.firebaseUser.value?.uid;
      if (userId == null) return;
      final doc = await _firestore.collection('users').doc(userId).get();
      final data = doc.data();
      if (data != null) {
        userGoal.value = data['goal'] ?? 'Stay Fit';
        userLevel.value = data['level'] ?? 'Beginner';
        _updateRecommendations();
      }
    } catch (e) {}
  }

  void loadSampleWorkouts() {
    isLoading.value = true;
    workouts.value = _buildWorkoutList();
    filteredWorkouts.value = workouts;
    _updateRecommendations();
    isLoading.value = false;
  }

  void _updateRecommendations() {
    if (workouts.isEmpty) return;
    recommendedWorkouts.value = GoalRecommendationService.getRecommendedWorkouts(
      goal: userGoal.value,
      level: userLevel.value,
      allWorkouts: workouts,
      limit: 4,
    );
    todaysWorkout.value = GoalRecommendationService.getTodaysWorkout(
      goal: userGoal.value,
      level: userLevel.value,
      allWorkouts: workouts,
      completedThisWeek: 0,
    );
  }

  void updateGoalAndLevel(String goal, String level) {
    userGoal.value = goal;
    userLevel.value = level;
    _updateRecommendations();
  }

  void filterWorkouts() {
    var filtered = workouts.where((w) {
      bool cat = selectedCategory.value == 'All' || w.category == selectedCategory.value;
      bool diff = selectedDifficulty.value == 'All' || w.difficulty == selectedDifficulty.value;
      bool search = searchQuery.value.isEmpty ||
          w.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          w.description.toLowerCase().contains(searchQuery.value.toLowerCase());
      return cat && diff && search;
    }).toList();
    filteredWorkouts.value = filtered;
  }

  void setCategory(String c) { selectedCategory.value = c; filterWorkouts(); }
  void setDifficulty(String d) { selectedDifficulty.value = d; filterWorkouts(); }
  void setSearchQuery(String q) { searchQuery.value = q; filterWorkouts(); }
  void resetFilters() {
    selectedCategory.value = 'All';
    selectedDifficulty.value = 'All';
    searchQuery.value = '';
    filteredWorkouts.value = workouts;
  }

  Workout? getWorkoutById(String id) {
    try { return workouts.firstWhere((w) => w.id == id); } catch (e) { return null; }
  }

  List<Workout> _buildWorkoutList() {
    return [
      Workout(id:'1',name:'Full Body Strength',description:'A complete full body workout targeting all major muscle groups',category:'Strength',difficulty:'Intermediate',duration:45,caloriesBurned:350,imageUrl:'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400',tags:['Full Body','Strength','Muscle Building'],exercises:[WorkoutExercise(exerciseId:'ex1',name:'Barbell Squat',sets:4,reps:10,weight:60,restTime:90,notes:'Keep your back straight'),WorkoutExercise(exerciseId:'ex2',name:'Bench Press',sets:4,reps:10,weight:50,restTime:90),WorkoutExercise(exerciseId:'ex3',name:'Deadlift',sets:3,reps:8,weight:80,restTime:120),WorkoutExercise(exerciseId:'ex4',name:'Pull-ups',sets:3,reps:12,restTime:60),WorkoutExercise(exerciseId:'ex5',name:'Overhead Press',sets:3,reps:10,weight:30,restTime:60)]),
      Workout(id:'2',name:'HIIT Cardio Blast',description:'High intensity interval training for maximum calorie burn',category:'Cardio',difficulty:'Advanced',duration:30,caloriesBurned:400,imageUrl:'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=400',tags:['HIIT','Cardio','Fat Burning'],exercises:[WorkoutExercise(exerciseId:'ex6',name:'Burpees',sets:4,reps:15,duration:45,restTime:30),WorkoutExercise(exerciseId:'ex7',name:'Jump Squats',sets:4,reps:20,duration:45,restTime:30),WorkoutExercise(exerciseId:'ex8',name:'Mountain Climbers',sets:4,reps:30,duration:45,restTime:30),WorkoutExercise(exerciseId:'ex9',name:'High Knees',sets:4,reps:40,duration:45,restTime:30)]),
      Workout(id:'3',name:'Upper Body Power',description:'Build strength in your chest, back, and arms',category:'Strength',difficulty:'Intermediate',duration:40,caloriesBurned:300,imageUrl:'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=400',tags:['Upper Body','Strength','Muscle Building'],exercises:[WorkoutExercise(exerciseId:'ex10',name:'Dumbbell Chest Press',sets:4,reps:12,weight:20,restTime:60),WorkoutExercise(exerciseId:'ex11',name:'Lat Pulldown',sets:4,reps:12,weight:40,restTime:60),WorkoutExercise(exerciseId:'ex12',name:'Bicep Curls',sets:3,reps:15,weight:12,restTime:45),WorkoutExercise(exerciseId:'ex13',name:'Tricep Dips',sets:3,reps:12,restTime:45)]),
      Workout(id:'4',name:'Lower Body Blast',description:'Strengthen and tone your legs and glutes',category:'Strength',difficulty:'Beginner',duration:35,caloriesBurned:280,imageUrl:'https://images.unsplash.com/photo-1434682881908-b43d0467b798?w=400',tags:['Lower Body','Legs','Glutes'],exercises:[WorkoutExercise(exerciseId:'ex14',name:'Goblet Squat',sets:4,reps:15,weight:16,restTime:60),WorkoutExercise(exerciseId:'ex15',name:'Lunges',sets:3,reps:12,restTime:45),WorkoutExercise(exerciseId:'ex16',name:'Romanian Deadlift',sets:3,reps:12,weight:30,restTime:60),WorkoutExercise(exerciseId:'ex17',name:'Leg Press',sets:4,reps:15,weight:80,restTime:60)]),
      Workout(id:'5',name:'Morning Yoga Flow',description:'Gentle yoga sequence to start your day with energy',category:'Flexibility',difficulty:'Beginner',duration:20,caloriesBurned:100,imageUrl:'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400',tags:['Yoga','Flexibility','Mobility'],exercises:[WorkoutExercise(exerciseId:'ex18',name:'Sun Salutation',sets:3,reps:5,duration:300,restTime:30),WorkoutExercise(exerciseId:'ex19',name:'Downward Dog',sets:1,reps:1,duration:60,restTime:15),WorkoutExercise(exerciseId:'ex20',name:'Warrior Pose',sets:2,reps:1,duration:45,restTime:20),WorkoutExercise(exerciseId:'ex21',name:'Child Pose',sets:1,reps:1,duration:60,restTime:0)]),
      Workout(id:'6',name:'Core Crusher',description:'Intense core workout for a strong midsection',category:'Strength',difficulty:'Intermediate',duration:25,caloriesBurned:200,imageUrl:'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',tags:['Core','Abs','Strength'],exercises:[WorkoutExercise(exerciseId:'ex22',name:'Plank',sets:3,reps:1,duration:60,restTime:30),WorkoutExercise(exerciseId:'ex23',name:'Russian Twists',sets:3,reps:30,weight:8,restTime:30),WorkoutExercise(exerciseId:'ex24',name:'Bicycle Crunches',sets:3,reps:25,restTime:30),WorkoutExercise(exerciseId:'ex25',name:'Leg Raises',sets:3,reps:15,restTime:45)]),
      Workout(id:'7',name:'Fat Burn Circuit',description:'Non-stop circuit training to maximize fat burning',category:'Cardio',difficulty:'Beginner',duration:30,caloriesBurned:320,imageUrl:'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=400',tags:['Cardio','Fat Burning','Full Body','HIIT'],exercises:[WorkoutExercise(exerciseId:'ex26',name:'Jumping Jacks',sets:3,reps:30,duration:45,restTime:15),WorkoutExercise(exerciseId:'ex27',name:'Squat Jumps',sets:3,reps:15,duration:45,restTime:20),WorkoutExercise(exerciseId:'ex28',name:'Push-ups',sets:3,reps:12,restTime:30),WorkoutExercise(exerciseId:'ex29',name:'Plank Hold',sets:3,reps:1,duration:30,restTime:20)]),
      Workout(id:'8',name:'Beginner Strength',description:'Perfect introduction to strength training for beginners',category:'Strength',difficulty:'Beginner',duration:30,caloriesBurned:220,imageUrl:'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400',tags:['Strength','Full Body','Muscle Building'],exercises:[WorkoutExercise(exerciseId:'ex30',name:'Bodyweight Squat',sets:3,reps:15,restTime:60),WorkoutExercise(exerciseId:'ex31',name:'Push-ups',sets:3,reps:10,restTime:60),WorkoutExercise(exerciseId:'ex32',name:'Dumbbell Row',sets:3,reps:12,weight:10,restTime:60),WorkoutExercise(exerciseId:'ex33',name:'Glute Bridge',sets:3,reps:15,restTime:45)]),
      Workout(id:'9',name:'Flexibility & Mobility',description:'Improve your flexibility and joint health',category:'Flexibility',difficulty:'Beginner',duration:25,caloriesBurned:80,imageUrl:'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400',tags:['Flexibility','Mobility','Stretching'],exercises:[WorkoutExercise(exerciseId:'ex34',name:'Hip Flexor Stretch',sets:2,reps:1,duration:60,restTime:15),WorkoutExercise(exerciseId:'ex35',name:'Hamstring Stretch',sets:2,reps:1,duration:45,restTime:10),WorkoutExercise(exerciseId:'ex36',name:'Shoulder Rolls',sets:2,reps:10,restTime:10),WorkoutExercise(exerciseId:'ex37',name:'Spinal Twist',sets:2,reps:1,duration:30,restTime:10)]),
    ];
  }
}
