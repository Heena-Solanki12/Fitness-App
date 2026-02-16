class WorkoutExercise {
  final String exerciseId;
  final String name;
  final int sets;
  final int reps;
  final double? weight;
  final int? duration; // in seconds
  final int restTime; // in seconds
  final String? notes;
  bool isCompleted;

  WorkoutExercise({
    required this.exerciseId,
    required this.name,
    required this.sets,
    required this.reps,
    this.weight,
    this.duration,
    this.restTime = 60,
    this.notes,
    this.isCompleted = false,
  });

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      exerciseId: json['exerciseId'] ?? '',
      name: json['name'] ?? '',
      sets: json['sets'] ?? 3,
      reps: json['reps'] ?? 10,
      weight: json['weight']?.toDouble(),
      duration: json['duration'],
      restTime: json['restTime'] ?? 60,
      notes: json['notes'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'name': name,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'duration': duration,
      'restTime': restTime,
      'notes': notes,
      'isCompleted': isCompleted,
    };
  }

  WorkoutExercise copyWith({
    String? exerciseId,
    String? name,
    int? sets,
    int? reps,
    double? weight,
    int? duration,
    int? restTime,
    String? notes,
    bool? isCompleted,
  }) {
    return WorkoutExercise(
      exerciseId: exerciseId ?? this.exerciseId,
      name: name ?? this.name,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      duration: duration ?? this.duration,
      restTime: restTime ?? this.restTime,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}