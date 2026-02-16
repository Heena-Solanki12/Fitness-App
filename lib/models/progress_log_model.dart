import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressLog {
  final String id;
  final String userId;
  final DateTime date;
  final double? weight;
  final double? bodyFat;
  final Map<String, double>? measurements;
  final Map<String, String>? photos;
  final String? notes;

  ProgressLog({
    required this.id,
    required this.userId,
    required this.date,
    this.weight,
    this.bodyFat,
    this.measurements,
    this.photos,
    this.notes,
  });

  factory ProgressLog.fromJson(Map<String, dynamic> json) {
    return ProgressLog(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      date: (json['date'] as Timestamp).toDate(),
      weight: json['weight']?.toDouble(),
      bodyFat: json['bodyFat']?.toDouble(),
      measurements: json['measurements'] != null
          ? Map<String, double>.from(json['measurements'])
          : null,
      photos: json['photos'] != null
          ? Map<String, String>.from(json['photos'])
          : null,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'weight': weight,
      'bodyFat': bodyFat,
      'measurements': measurements,
      'photos': photos,
      'notes': notes,
    };
  }
}