import 'package:cloud_firestore/cloud_firestore.dart';

class EnhancedUserModel {
  final String uid;
  final String email;
  final String? name;
  final String? role;
  final String? location;
  final int streakCount;
  final int totalPoints;
  final String? profilePicture;
  final DateTime createdAt;
  final DateTime? lastScanDate;

  EnhancedUserModel({
    required this.uid,
    required this.email,
    this.name,
    this.role,
    this.location,
    this.streakCount = 0,
    this.totalPoints = 0,
    this.profilePicture,
    required this.createdAt,
    this.lastScanDate,
  });

  // Convert to Firestore map
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'location': location,
      'streakCount': streakCount,
      'totalPoints': totalPoints,
      'profilePicture': profilePicture,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastScanDate':
          lastScanDate != null ? Timestamp.fromDate(lastScanDate!) : null,
    };
  }

  // Create from Firestore map
  factory EnhancedUserModel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert timestamp values
    DateTime? convertTimestamp(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return EnhancedUserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      role: json['role'] as String?,
      location: json['location'] as String?,
      streakCount: json['streakCount'] as int? ?? 0,
      totalPoints: json['totalPoints'] as int? ?? 0,
      profilePicture: json['profilePicture'] as String?,
      createdAt: convertTimestamp(json['createdAt']) ?? DateTime.now(),
      lastScanDate: convertTimestamp(json['lastScanDate']),
    );
  }

  // Create a copy with updated fields
  EnhancedUserModel copyWith({
    String? name,
    String? role,
    String? location,
    int? streakCount,
    int? totalPoints,
    String? profilePicture,
    DateTime? lastScanDate,
  }) {
    return EnhancedUserModel(
      uid: uid,
      email: email,
      name: name ?? this.name,
      role: role ?? this.role,
      location: location ?? this.location,
      streakCount: streakCount ?? this.streakCount,
      totalPoints: totalPoints ?? this.totalPoints,
      profilePicture: profilePicture ?? this.profilePicture,
      createdAt: createdAt,
      lastScanDate: lastScanDate ?? this.lastScanDate,
    );
  }
}
