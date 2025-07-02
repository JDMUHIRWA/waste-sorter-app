// import 'package:cloud_firestore/cloud_firestore.dart';

// class UserModel {
//   final String uid;
//   final String email;
//   final String? displayName;
//   final DateTime createdAt;

//   UserModel({
//     required this.uid,
//     required this.email,
//     this.displayName,
//     required this.createdAt,
//   });

//   factory UserModel.fromMap(Map<String, dynamic> data) {
//     return UserModel(
//       uid: data['uid'],
//       email: data['email'],
//       displayName: data['displayName'],
//       createdAt: (data['createdAt'] as Timestamp).toDate(),
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'uid': uid,
//       'email': email,
//       'displayName': displayName,
//       'createdAt': Timestamp.fromDate(createdAt),
//     };
//   }
// }
