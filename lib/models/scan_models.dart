import 'package:cloud_firestore/cloud_firestore.dart';

class ScanResult {
  final String scanId;
  final String userId;
  final String imageUrl;
  final List<DetectedItem> detectedItems;
  final String city;
  final DateTime timestamp;
  final String scanSessionId; // Group multiple items from same scan

  ScanResult({
    required this.scanId,
    required this.userId,
    required this.imageUrl,
    required this.detectedItems,
    required this.city,
    required this.timestamp,
    required this.scanSessionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'scanId': scanId,
      'userId': userId,
      'imageUrl': imageUrl,
      'detectedItems': detectedItems.map((item) => item.toJson()).toList(),
      'city': city,
      'timestamp': Timestamp.fromDate(timestamp),
      'scanSessionId': scanSessionId,
    };
  }

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      scanId: json['scanId'] as String,
      userId: json['userId'] as String,
      imageUrl: json['imageUrl'] as String,
      detectedItems: (json['detectedItems'] as List)
          .map((item) => DetectedItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      city: json['city'] as String,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      scanSessionId: json['scanSessionId'] as String,
    );
  }
}

class DetectedItem {
  final String itemName;
  final String category;
  final double confidence;
  final String binColor;
  final List<String> instructions;

  DetectedItem({
    required this.itemName,
    required this.category,
    required this.confidence,
    required this.binColor,
    required this.instructions,
  });

  Map<String, dynamic> toJson() {
    return {
      'itemName': itemName,
      'category': category,
      'confidence': confidence,
      'binColor': binColor,
      'instructions': instructions,
    };
  }

  factory DetectedItem.fromJson(Map<String, dynamic> json) {
    return DetectedItem(
      itemName: json['itemName'] as String,
      category: json['category'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      binColor: json['binColor'] as String,
      instructions: List<String>.from(json['instructions'] as List),
    );
  }
}

class WasteClassificationResponse {
  final bool success;
  final List<WasteItem> items;
  final String? error;

  WasteClassificationResponse({
    required this.success,
    required this.items,
    this.error,
  });

  factory WasteClassificationResponse.fromJson(Map<String, dynamic> json) {
    if (json['success'] == false) {
      return WasteClassificationResponse(
        success: false,
        items: [],
        error: json['error'] ?? 'Unknown error occurred',
      );
    }

    // Handle the API response format
    final predictions = json['predictions'] as List? ?? [];
    final items = predictions.map((item) => WasteItem.fromJson(item)).toList();

    return WasteClassificationResponse(
      success: true,
      items: items,
    );
  }
}

class WasteItem {
  final String className;
  final double confidence;

  WasteItem({
    required this.className,
    required this.confidence,
  });

  factory WasteItem.fromJson(Map<String, dynamic> json) {
    return WasteItem(
      className: json['class'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }
}

class BinRule {
  final String plastic;
  final String organic;
  final String paper;
  final String eWaste;
  final String hazardous;
  final String metal;
  final String glass;

  BinRule({
    required this.plastic,
    required this.organic,
    required this.paper,
    required this.eWaste,
    required this.hazardous,
    required this.metal,
    required this.glass,
  });

  Map<String, dynamic> toJson() {
    return {
      'plastic': plastic,
      'organic': organic,
      'paper': paper,
      'e-waste': eWaste,
      'hazardous': hazardous,
      'metal': metal,
      'glass': glass,
    };
  }

  factory BinRule.fromJson(Map<String, dynamic> json) {
    return BinRule(
      plastic: json['plastic'] as String,
      organic: json['organic'] as String,
      paper: json['paper'] as String,
      eWaste: json['e-waste'] as String,
      hazardous: json['hazardous'] as String,
      metal: json['metal'] as String,
      glass: json['glass'] as String,
    );
  }

  String getBinColor(String category) {
    switch (category.toLowerCase()) {
      case 'plastic':
        return plastic;
      case 'organic':
      case 'food':
      case 'compostable':
        return organic;
      case 'paper':
      case 'cardboard':
        return paper;
      case 'e-waste':
      case 'electronic':
        return eWaste;
      case 'hazardous':
      case 'battery':
        return hazardous;
      case 'metal':
      case 'can':
        return metal;
      case 'glass':
      case 'bottle':
        return glass;
      default:
        return 'Gray'; // Default bin for unknown items
    }
  }
}

class UserPoints {
  final String userId;
  final int totalPoints;
  final int streakCount;
  final DateTime lastScanDate;
  final Map<String, int> categoryPoints;

  UserPoints({
    required this.userId,
    required this.totalPoints,
    required this.streakCount,
    required this.lastScanDate,
    required this.categoryPoints,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'totalPoints': totalPoints,
      'streakCount': streakCount,
      'lastScanDate': Timestamp.fromDate(lastScanDate),
      'categoryPoints': categoryPoints,
    };
  }

  factory UserPoints.fromJson(Map<String, dynamic> json) {
    return UserPoints(
      userId: json['userId'] as String,
      totalPoints: json['totalPoints'] as int,
      streakCount: json['streakCount'] as int,
      lastScanDate: (json['lastScanDate'] as Timestamp).toDate(),
      categoryPoints: Map<String, int>.from(json['categoryPoints'] as Map),
    );
  }
}
