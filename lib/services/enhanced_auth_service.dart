import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/enhanced_user_model.dart';
import '../services/scan_service.dart';

class EnhancedAuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  
  FirebaseFirestore get firestore => _firestore;
  User? get currentUser => _auth.currentUser;

  /// Create new account and save enhanced user profile to Firestore
  Future<EnhancedUserModel> signUpWithEmail({
    required String email,
    required String password,
    String? name,
    String? role,
    String? location,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        final userModel = EnhancedUserModel(
          uid: user.uid,
          email: user.email!,
          name: name,
          role: role ?? 'student',
          location: location,
          streakCount: 0,
          totalPoints: 0,
          createdAt: DateTime.now(),
        );
        
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toJson());

        // Initialize default data if this is the first user
        await ScanService.initializeDefaultData();
        
        return userModel;
      } else {
        throw Exception('Failed to create user');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception('Sign up failed: ${e.message}');
    }
  }

  /// Get current enhanced user
  Future<EnhancedUserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    return EnhancedUserModel.fromJson(doc.data()!);
  }

  /// Sign in with email and password
  Future<EnhancedUserModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;

      return EnhancedUserModel.fromJson(doc.data()!);
    } on FirebaseAuthException catch (e) {
      throw Exception('Sign in failed: ${e.message}');
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    String? name,
    String? role,
    String? location,
    String? profilePicture,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (role != null) updates['role'] = role;
    if (location != null) updates['location'] = location;
    if (profilePicture != null) updates['profilePicture'] = profilePicture;

    if (updates.isNotEmpty) {
      await _firestore.collection('users').doc(user.uid).update(updates);
    }
  }

  /// Complete user profile setup (used after initial signup)
  Future<void> completeProfile({
    required String name,
    required String role,
    required String location,
    String? profilePicture,
  }) async {
    await updateUserProfile(
      name: name,
      role: role,
      location: location,
      profilePicture: profilePicture,
    );
  }

  /// Get user statistics
  Future<Map<String, dynamic>> getUserStats() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Get user data
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = EnhancedUserModel.fromJson(userDoc.data()!);

    // Get scan count
    final scansQuery = await _firestore
        .collection('scans')
        .where('userId', isEqualTo: user.uid)
        .get();
    
    final totalScans = scansQuery.docs.length;

    // Get this week's scans
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartTimestamp = Timestamp.fromDate(DateTime(weekStart.year, weekStart.month, weekStart.day));
    
    final weeklyScansQuery = await _firestore
        .collection('scans')
        .where('userId', isEqualTo: user.uid)
        .where('timestamp', isGreaterThanOrEqualTo: weekStartTimestamp)
        .get();

    int weeklyPoints = 0;
    for (var doc in weeklyScansQuery.docs) {
      weeklyPoints += (doc.data()['pointsEarned'] as int? ?? 0);
    }

    // Get this month's scans
    final monthStart = DateTime(now.year, now.month, 1);
    final monthStartTimestamp = Timestamp.fromDate(monthStart);
    
    final monthlyScansQuery = await _firestore
        .collection('scans')
        .where('userId', isEqualTo: user.uid)
        .where('timestamp', isGreaterThanOrEqualTo: monthStartTimestamp)
        .get();

    int monthlyPoints = 0;
    Map<String, int> categoryCounts = {};
    
    for (var doc in monthlyScansQuery.docs) {
      monthlyPoints += (doc.data()['pointsEarned'] as int? ?? 0);
      
      final categories = List<String>.from(doc.data()['categories'] ?? []);
      for (var category in categories) {
        categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
      }
    }

    return {
      'totalPoints': userData.totalPoints,
      'currentStreak': userData.streakCount,
      'totalScans': totalScans,
      'weeklyPoints': weeklyPoints,
      'monthlyPoints': monthlyPoints,
      'categoryCounts': categoryCounts,
    };
  }

  /// Get user rankings
  Future<Map<String, int?>> getUserRankings() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final weeklyRank = await ScanService.getUserRank(user.uid, 'weekly');
    final dailyRank = await ScanService.getUserRank(user.uid, 'daily');

    // Get overall rank (simplified - in production, you'd want a more efficient approach)
    final allUsersQuery = await _firestore
        .collection('users')
        .orderBy('totalPoints', descending: true)
        .get();

    int? overallRank;
    for (int i = 0; i < allUsersQuery.docs.length; i++) {
      if (allUsersQuery.docs[i].id == user.uid) {
        overallRank = i + 1;
        break;
      }
    }

    return {
      'dailyRank': dailyRank,
      'weeklyRank': weeklyRank,
      'overallRank': overallRank,
    };
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Check if user profile is complete
  Future<bool> isProfileComplete() async {
    final user = await getCurrentUser();
    if (user == null) return false;
    
    return user.name != null && 
           user.role != null && 
           user.location != null;
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception('Password reset failed: ${e.message}');
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Delete user data from Firestore
      await _firestore.collection('users').doc(user.uid).delete();
      
      // Delete user scans
      final scansQuery = await _firestore
          .collection('scans')
          .where('userId', isEqualTo: user.uid)
          .get();
      
      for (var doc in scansQuery.docs) {
        await doc.reference.delete();
      }

      // Delete user badges
      await _firestore.collection('badges').doc(user.uid).delete();

      // Delete Firebase Auth account
      await user.delete();
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  /// Stream user data changes
  Stream<EnhancedUserModel?> get userStream {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return await getCurrentUser();
    });
  }
}
