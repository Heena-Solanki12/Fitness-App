import 'package:cloud_firestore/cloud_firestore.dart';

class MeasurementLog {
  final String id;
  final String userId;
  final DateTime date;
  final double? chest;
  final double? waist;
  final double? hips;
  final double? bicepLeft;
  final double? bicepRight;
  final double? thighLeft;
  final double? thighRight;
  final double? calfLeft;
  final double? calfRight;
  final double? neck;
  final double? shoulders;
  final double? forearmLeft;
  final double? forearmRight;
  final String? notes;

  MeasurementLog({
    required this.id,
    required this.userId,
    required this.date,
    this.chest,
    this.waist,
    this.hips,
    this.bicepLeft,
    this.bicepRight,
    this.thighLeft,
    this.thighRight,
    this.calfLeft,
    this.calfRight,
    this.neck,
    this.shoulders,
    this.forearmLeft,
    this.forearmRight,
    this.notes,
  });
  factory MeasurementLog.fromJson(Map<String, dynamic> json) {
    return MeasurementLog(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      date: (json['date'] as Timestamp).toDate(),
      chest: json['chest']?.toDouble(),
      waist: json['waist']?.toDouble(),
      hips: json['hips']?.toDouble(),
      bicepLeft: json['bicepLeft']?.toDouble(),
      bicepRight: json['bicepRight']?.toDouble(),
      thighLeft: json['thighLeft']?.toDouble(),
      thighRight: json['thighRight']?.toDouble(),
      calfLeft: json['calfLeft']?.toDouble(),
      calfRight: json['calfRight']?.toDouble(),
      neck: json['neck']?.toDouble(),
      shoulders: json['shoulders']?.toDouble(),
      forearmLeft: json['forearmLeft']?.toDouble(),
      forearmRight: json['forearmRight']?.toDouble(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'chest': chest,
      'waist': waist,
      'hips': hips,
      'bicepLeft': bicepLeft,
      'bicepRight': bicepRight,
      'thighLeft': thighLeft,
      'thighRight': thighRight,
      'calfLeft': calfLeft,
      'calfRight': calfRight,
      'neck': neck,
      'shoulders': shoulders,
      'forearmLeft': forearmLeft,
      'forearmRight': forearmRight,
      'notes': notes,
    };
  }

  // Check if has any measurements
  bool get hasMeasurements =>
      chest != null ||
          waist != null ||
          hips != null ||
          bicepLeft != null ||
          bicepRight != null ||
          thighLeft != null ||
          thighRight != null ||
          calfLeft != null ||
          calfRight != null ||
          neck != null ||
          shoulders != null ||
          forearmLeft != null ||
          forearmRight != null;

  // Get all measurements as map
  Map<String, double> get measurementsMap {
    final map = <String, double>{};
    if (chest != null) map['Chest'] = chest!;
    if (waist != null) map['Waist'] = waist!;
    if (hips != null) map['Hips'] = hips!;
    if (bicepLeft != null) map['Left Bicep'] = bicepLeft!;
    if (bicepRight != null) map['Right Bicep'] = bicepRight!;
    if (thighLeft != null) map['Left Thigh'] = thighLeft!;
    if (thighRight != null) map['Right Thigh'] = thighRight!;
    if (calfLeft != null) map['Left Calf'] = calfLeft!;
    if (calfRight != null) map['Right Calf'] = calfRight!;
    if (neck != null) map['Neck'] = neck!;
    if (shoulders != null) map['Shoulders'] = shoulders!;
    if (forearmLeft != null) map['Left Forearm'] = forearmLeft!;
    if (forearmRight != null) map['Right Forearm'] = forearmRight!;
    return map;
  }
}