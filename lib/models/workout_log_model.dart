// lib/models/workout_log_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutLog {
  final String id;
  final String userId;
  final String workoutId;
  final String workoutName;
  final DateTime date;
  final int duration; // in seconds
  final int caloriesBurned;
  final List<ExerciseLog> exercises;
  final String? notes;
  final String mood; // great, good, okay, bad
  final String difficulty; // easy, moderate, hard

  WorkoutLog({
    required this.id,
    required this.userId,
    required this.workoutId,
    required this.workoutName,
    required this.date,
    required this.duration,
    required this.caloriesBurned,
    required this.exercises,
    this.notes,
    this.mood = 'good',
    this.difficulty = 'moderate',
  });

  factory WorkoutLog.fromJson(Map<String, dynamic> json) {
    return WorkoutLog(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      workoutId: json['workoutId'] ?? '',
      workoutName: json['workoutName'] ?? '',
      date: (json['date'] as Timestamp).toDate(),
      duration: json['duration'] ?? 0,
      caloriesBurned: json['caloriesBurned'] ?? 0,
      exercises: (json['exercises'] as List<dynamic>?)
          ?.map((e) => ExerciseLog.fromJson(e))
          .toList() ??
          [],
      notes: json['notes'],
      mood: json['mood'] ?? 'good',
      difficulty: json['difficulty'] ?? 'moderate',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'workoutId': workoutId,
      'workoutName': workoutName,
      'date': Timestamp.fromDate(date),
      'duration': duration,
      'caloriesBurned': caloriesBurned,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'notes': notes,
      'mood': mood,
      'difficulty': difficulty,
    };
  }

  String get formattedDuration {
    int minutes = duration ~/ 60;
    int seconds = duration % 60;
    return '${minutes}m ${seconds}s';
  }
}

class ExerciseLog {
  final String exerciseId;
  final String name;
  final List<SetLog> sets;

  ExerciseLog({
    required this.exerciseId,
    required this.name,
    required this.sets,
  });

  factory ExerciseLog.fromJson(Map<String, dynamic> json) {
    return ExerciseLog(
      exerciseId: json['exerciseId'] ?? '',
      name: json['name'] ?? '',
      sets: (json['sets'] as List<dynamic>?)
          ?.map((e) => SetLog.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'name': name,
      'sets': sets.map((e) => e.toJson()).toList(),
    };
  }
}

class SetLog {
  final int setNumber;
  final int reps;
  final double? weight;
  final bool completed;

  SetLog({
    required this.setNumber,
    required this.reps,
    this.weight,
    this.completed = true,
  });

  factory SetLog.fromJson(Map<String, dynamic> json) {
    return SetLog(
      setNumber: json['setNumber'] ?? 1,
      reps: json['reps'] ?? 0,
      weight: json['weight']?.toDouble(),
      completed: json['completed'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'setNumber': setNumber,
      'reps': reps,
      'weight': weight,
      'completed': completed,
    };
  }
}