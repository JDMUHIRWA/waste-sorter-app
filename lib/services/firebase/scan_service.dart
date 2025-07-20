import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/scan_models.dart';
import '../api/waste_classification_service.dart';

class ScanService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Upload image to Firebase Storage and get public URL
  static Future<String?> uploadImage(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final fileName = 'scan_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('scans/${user.uid}/$fileName');
      
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      
      if (snapshot.state == TaskState.success) {
        return await ref.getDownloadURL();
      }
      return null;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  /// Get bin rules for a specific city
  static Future<BinRule> getBinRules(String city) async {
    try {
      final cityDoc = await _firestore
          .collection('rules')
          .doc(city.toLowerCase())
          .get();

      if (cityDoc.exists) {
        return BinRule.fromJson(cityDoc.data()!);
      } else {
        // Return default Kigali rules if city not found
        return await _getDefaultKigaliRules();
      }
    } catch (e) {
      print('Error fetching bin rules: $e');
      return await _getDefaultKigaliRules();
    }
  }

  /// Get default bin rules for Kigali
  static Future<BinRule> _getDefaultKigaliRules() async {
    try {
      // Try to create default rules if they don't exist
      final defaultRules = BinRule(
        plastic: 'Blue',
        organic: 'Green',
        paper: 'Yellow',
        eWaste: 'Red',
        hazardous: 'Black',
        metal: 'Blue',
        glass: 'Blue',
      );

      await _firestore
          .collection('rules')
          .doc('kigali')
          .set(defaultRules.toJson());

      return defaultRules;
    } catch (e) {
      print('Error creating default rules: $e');
      return BinRule(
        plastic: 'Blue',
        organic: 'Green',
        paper: 'Yellow',
        eWaste: 'Red',
        hazardous: 'Black',
        metal: 'Blue',
        glass: 'Blue',
      );
    }
  }

  /// Process scan: upload image, classify, and store results
  static Future<ScanProcessResult> processScan({
    required File imageFile,
    required String city,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return ScanProcessResult.error('User not authenticated');
      }

      // Step 1: Upload image to Firebase Storage
      final imageUrl = await uploadImage(imageFile);
      if (imageUrl == null) {
        return ScanProcessResult.error('Failed to upload image');
      }

      // Step 2: Classify waste using external API
      final classificationResponse = await WasteClassificationService.classifyWaste(imageUrl);
      if (!classificationResponse.success) {
        return ScanProcessResult.error(classificationResponse.error ?? 'Classification failed');
      }

      // Step 3: Get bin rules for the city
      final binRules = await getBinRules(city);

      // Step 4: Process detected items and group by bin color
      final scanSessionId = _generateScanSessionId();
      final Map<String, List<DetectedItem>> itemsByBin = {};
      
      for (final wasteItem in classificationResponse.items) {
        final category = WasteClassificationService.mapItemToCategory(wasteItem.className);
        final binColor = binRules.getBinColor(category);
        final instructions = WasteClassificationService.getDisposalInstructions(category, binColor);
        
        final detectedItem = DetectedItem(
          itemName: wasteItem.className,
          category: category,
          confidence: wasteItem.confidence,
          binColor: binColor,
          instructions: instructions,
        );

        if (!itemsByBin.containsKey(binColor)) {
          itemsByBin[binColor] = [];
        }
        itemsByBin[binColor]!.add(detectedItem);
      }

      // Step 5: Create scan results for each bin color
      final List<ScanResult> scanResults = [];
      for (final entry in itemsByBin.entries) {
        final binColor = entry.key;
        final items = entry.value;
        
        final scanResult = ScanResult(
          scanId: _generateScanId(),
          userId: user.uid,
          imageUrl: imageUrl,
          detectedItems: items,
          city: city,
          timestamp: DateTime.now(),
          scanSessionId: scanSessionId,
        );

        scanResults.add(scanResult);
      }

      // Step 6: Store scan results in Firestore
      final batch = _firestore.batch();
      for (final scanResult in scanResults) {
        final docRef = _firestore.collection('scans').doc(scanResult.scanId);
        batch.set(docRef, scanResult.toJson());
      }
      await batch.commit();

      // Step 7: Update user points
      final pointsAwarded = await _updateUserPoints(user.uid, scanResults.length);

      // Step 8: Update leaderboard
      await updateLeaderboard(user.uid);

      return ScanProcessResult.success(
        scanResults: scanResults,
        pointsAwarded: pointsAwarded,
      );

    } catch (e) {
      print('Error processing scan: $e');
      return ScanProcessResult.error('Failed to process scan: $e');
    }
  }

  /// Update user points and streak
  static Future<int> _updateUserPoints(String userId, int scanCount) async {
    try {
      final userDoc = _firestore.collection('users').doc(userId);
      
      return await _firestore.runTransaction<int>((transaction) async {
        final userSnapshot = await transaction.get(userDoc);
        final userData = userSnapshot.data() ?? {};
        
        final currentPoints = userData['totalPoints'] as int? ?? 0;
        final currentStreak = userData['streakCount'] as int? ?? 0;
        final lastScanDate = userData['lastScanDate'] as Timestamp?;
        
        // Calculate points (5 points per scan)
        final pointsToAdd = scanCount * 5;
        final newTotalPoints = currentPoints + pointsToAdd;
        
        // Calculate streak
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        int newStreak = currentStreak;
        
        if (lastScanDate != null) {
          final lastScan = lastScanDate.toDate();
          final lastScanDay = DateTime(lastScan.year, lastScan.month, lastScan.day);
          final daysDifference = today.difference(lastScanDay).inDays;
          
          if (daysDifference == 1) {
            // Consecutive day
            newStreak++;
          } else if (daysDifference > 1) {
            // Streak broken
            newStreak = 1;
          }
          // Same day = no streak change
        } else {
          // First scan
          newStreak = 1;
        }
        
        // Update user document
        transaction.update(userDoc, {
          'totalPoints': newTotalPoints,
          'streakCount': newStreak,
          'lastScanDate': Timestamp.fromDate(now),
        });
        
        return pointsToAdd;
      });
    } catch (e) {
      print('Error updating user points: $e');
      return 0;
    }
  }

  /// Get user's scan history
  static Future<List<ScanResult>> getUserScanHistory(String userId, {int limit = 50}) async {
    try {
      final query = await _firestore
          .collection('scans')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return query.docs
          .map((doc) => ScanResult.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching scan history: $e');
      return [];
    }
  }

  /// Get scans by session ID (all items from same scan)
  static Future<List<ScanResult>> getScanSession(String scanSessionId) async {
    try {
      final query = await _firestore
          .collection('scans')
          .where('scanSessionId', isEqualTo: scanSessionId)
          .orderBy('timestamp', descending: false)
          .get();

      return query.docs
          .map((doc) => ScanResult.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching scan session: $e');
      return [];
    }
  }

  /// Generate unique scan ID
  static String _generateScanId() {
    return 'scan_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  /// Generate unique scan session ID
  static String _generateScanSessionId() {
    return 'session_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Update leaderboard (call this after successful scan)
  static Future<void> updateLeaderboard(String userId) async {
    try {
      final user = await _firestore.collection('users').doc(userId).get();
      if (!user.exists) return;

      final userData = user.data()!;
      final totalPoints = userData['totalPoints'] as int? ?? 0;
      final name = userData['name'] as String? ?? 'Anonymous';

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final dailyDocId = 'daily-${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      // Update daily leaderboard
      await _firestore.collection('leaderboard').doc(dailyDocId).set({
        'topUsers': FieldValue.arrayUnion([
          {
            'name': name,
            'points': totalPoints,
            'userID': userId,
          }
        ]),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

    } catch (e) {
      print('Error updating leaderboard: $e');
    }
  }
}

class ScanProcessResult {
  final bool success;
  final List<ScanResult>? scanResults;
  final int pointsAwarded;
  final String? error;

  ScanProcessResult._({
    required this.success,
    this.scanResults,
    this.pointsAwarded = 0,
    this.error,
  });

  factory ScanProcessResult.success({
    required List<ScanResult> scanResults,
    required int pointsAwarded,
  }) {
    return ScanProcessResult._(
      success: true,
      scanResults: scanResults,
      pointsAwarded: pointsAwarded,
    );
  }

  factory ScanProcessResult.error(String error) {
    return ScanProcessResult._(
      success: false,
      error: error,
    );
  }
}
