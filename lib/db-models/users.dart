class UserModel {
  final String uid;
  final String email;
  final String? name;

  UserModel({
    required this.uid,
    required this.email,
    this.name,
  });

  // Convert Dart object to Firestore map
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
    };
  }

  // Create Dart object from Firestore map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
    );
  }
}
