class Exercise {
  final String id;
  final String name;
  final String description;
  final List<String> instructions;
  final String category;
  final List<String> primaryMuscles;
  final List<String> equipment;
  final String difficulty;
  final String? imageUrl;
  final String? videoUrl;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.instructions,
    required this.category,
    required this.primaryMuscles,
    required this.equipment,
    required this.difficulty,
    this.imageUrl,
    this.videoUrl,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      instructions: List<String>.from(json['instructions'] ?? []),
      category: json['category'] ?? '',
      primaryMuscles: List<String>.from(json['primaryMuscles'] ?? []),
      equipment: List<String>.from(json['equipment'] ?? []),
      difficulty: json['difficulty'] ?? 'beginner',
      imageUrl: json['imageUrl'],
      videoUrl: json['videoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'instructions': instructions,
      'category': category,
      'primaryMuscles': primaryMuscles,
      'equipment': equipment,
      'difficulty': difficulty,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
    };
  }
}