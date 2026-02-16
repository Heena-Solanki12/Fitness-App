import 'package:fitness_app/models/workout_exercise.dart';

class Workout {
  final String id;
  final String name;
  final String description;
  final String category;
  final String difficulty;
  final int duration; // in minutes
  final int caloriesBurned;
  final List<WorkoutExercise> exercises;
  final bool isCustom;
  final String? imageUrl;
  final List<String> tags;

  Workout({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.duration,
    required this.caloriesBurned,
    required this.exercises,
    this.isCustom = false,
    this.imageUrl,
    this.tags = const [],
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      difficulty: json['difficulty'] ?? 'beginner',
      duration: json['duration'] ?? 30,
      caloriesBurned: json['caloriesBurned'] ?? 200,
      exercises: (json['exercises'] as List<dynamic>?)
          ?.map((e) => WorkoutExercise.fromJson(e))
          .toList() ??
          [],
      isCustom: json['isCustom'] ?? false,
      imageUrl: json['imageUrl'],
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'difficulty': difficulty,
      'duration': duration,
      'caloriesBurned': caloriesBurned,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'isCustom': isCustom,
      'imageUrl': imageUrl,
      'tags': tags,
    };
  }
}