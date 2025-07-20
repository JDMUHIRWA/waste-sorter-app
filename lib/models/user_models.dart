class UserModel {
  final String uid;
  final String email;
  final String? name;
  final String? role;
  final String? location;
  final int streakCount;
  final int totalPoints;
  final String? profilePicture;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.email,
    this.name,
    this.role,
    this.location,
    this.streakCount = 0,
    this.totalPoints = 0,
    this.profilePicture,
    this.createdAt,
  });

  // Convert Dart object to Firestore map
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
      'createdAt': createdAt?.millisecondsSinceEpoch,
    };
  }

  // Create Dart object from Firestore map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      role: json['role'] as String?,
      location: json['location'] as String?,
      streakCount: json['streakCount'] as int? ?? 0,
      totalPoints: json['totalPoints'] as int? ?? 0,
      profilePicture: json['profilePicture'] as String?,
      createdAt: json['createdAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
          : null,
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? role,
    String? location,
    int? streakCount,
    int? totalPoints,
    String? profilePicture,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      location: location ?? this.location,
      streakCount: streakCount ?? this.streakCount,
      totalPoints: totalPoints ?? this.totalPoints,
      profilePicture: profilePicture ?? this.profilePicture,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
