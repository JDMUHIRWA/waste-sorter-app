import 'package:cloud_firestore/cloud_firestore.dart';

class ScanResultModel {
  final String scanId;
  final String userId;
  final String imageUrl;
  final List<String> detectedItems;
  final List<String> categories;
  final String binColor;
  final List<String> instructions;
  final String city;
  final DateTime timestamp;
  final int pointsEarned;
  final double? confidence;

  ScanResultModel({
    required this.scanId,
    required this.userId,
    required this.imageUrl,
    required this.detectedItems,
    required this.categories,
    required this.binColor,
    required this.instructions,
    required this.city,
    required this.timestamp,
    required this.pointsEarned,
    this.confidence,
  });

  Map<String, dynamic> toJson() {
    return {
      'scanId': scanId,
      'userId': userId,
      'imageUrl': imageUrl,
      'detectedItems': detectedItems,
      'categories': categories,
      'binColor': binColor,
      'instructions': instructions,
      'city': city,
      'timestamp': Timestamp.fromDate(timestamp),
      'pointsEarned': pointsEarned,
      'confidence': confidence,
    };
  }

  factory ScanResultModel.fromJson(Map<String, dynamic> json) {
    // Handle timestamp conversion - support both Timestamp and int (milliseconds)
    DateTime timestamp;
    final timestampValue = json['timestamp'];
    if (timestampValue is Timestamp) {
      timestamp = timestampValue.toDate();
    } else if (timestampValue is int) {
      timestamp = DateTime.fromMillisecondsSinceEpoch(timestampValue);
    } else if (timestampValue is String) {
      timestamp = DateTime.parse(timestampValue);
    } else {
      timestamp = DateTime.now(); // Fallback
    }

    return ScanResultModel(
      scanId: json['scanId'] as String,
      userId: json['userId'] as String,
      imageUrl: json['imageUrl'] as String,
      detectedItems: List<String>.from(json['detectedItems'] ?? []),
      categories: List<String>.from(json['categories'] ?? []),
      binColor: json['binColor'] as String,
      instructions: List<String>.from(json['instructions'] ?? []),
      city: json['city'] as String,
      timestamp: timestamp,
      pointsEarned: json['pointsEarned'] as int,
      confidence: json['confidence'] as double?,
    );
  }
}

class WasteClassificationResult {
  final List<String> detectedItems;
  final List<String> categories;
  final String binColor;
  final List<String> instructions;
  final double confidence;
  final String recommendedAction;

  WasteClassificationResult({
    required this.detectedItems,
    required this.categories,
    required this.binColor,
    required this.instructions,
    required this.confidence,
    required this.recommendedAction,
  });

  factory WasteClassificationResult.fromJson(Map<String, dynamic> json) {
    return WasteClassificationResult(
      detectedItems: List<String>.from(json['detectedItems'] ?? []),
      categories: List<String>.from(json['categories'] ?? []),
      binColor: json['binColor'] as String? ?? 'General',
      instructions: List<String>.from(json['instructions'] ?? []),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      recommendedAction:
          json['recommendedAction'] as String? ?? 'Dispose properly',
    );
  }
}

class LeaderboardEntry {
  final String userId;
  final String name;
  final int points;
  final int rank;
  final String? profilePicture;

  LeaderboardEntry({
    required this.userId,
    required this.name,
    required this.points,
    required this.rank,
    this.profilePicture,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['userId'] as String,
      name: json['name'] as String,
      points: json['points'] as int,
      rank: json['rank'] as int,
      profilePicture: json['profilePicture'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'points': points,
      'rank': rank,
      'profilePicture': profilePicture,
    };
  }
}

class BadgeModel {
  final String badgeId;
  final String name;
  final String description;
  final String iconUrl;
  final DateTime earnedAt;

  BadgeModel({
    required this.badgeId,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.earnedAt,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    // Handle timestamp conversion - support both Timestamp and int (milliseconds)
    DateTime earnedAt;
    final timestampValue = json['earnedAt'];
    if (timestampValue is Timestamp) {
      earnedAt = timestampValue.toDate();
    } else if (timestampValue is int) {
      earnedAt = DateTime.fromMillisecondsSinceEpoch(timestampValue);
    } else if (timestampValue is String) {
      earnedAt = DateTime.parse(timestampValue);
    } else {
      earnedAt = DateTime.now(); // Fallback
    }

    return BadgeModel(
      badgeId: json['badgeId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconUrl: json['iconUrl'] as String,
      earnedAt: earnedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'badgeId': badgeId,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'earnedAt': Timestamp.fromDate(earnedAt),
    };
  }
}

class TipModel {
  final String tipId;
  final String title;
  final String content;
  final String? imageUrl;
  final DateTime postedAt;

  TipModel({
    required this.tipId,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.postedAt,
  });

  factory TipModel.fromJson(Map<String, dynamic> json) {
    // Handle timestamp conversion - support both Timestamp and int (milliseconds)
    DateTime postedAt;
    final timestampValue = json['postedAt'];
    if (timestampValue is Timestamp) {
      postedAt = timestampValue.toDate();
    } else if (timestampValue is int) {
      postedAt = DateTime.fromMillisecondsSinceEpoch(timestampValue);
    } else if (timestampValue is String) {
      postedAt = DateTime.parse(timestampValue);
    } else {
      postedAt = DateTime.now(); // Fallback
    }

    return TipModel(
      tipId: json['tipId'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      postedAt: postedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tipId': tipId,
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'postedAt': Timestamp.fromDate(postedAt),
    };
  }
}
