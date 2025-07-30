// lib/models/scan_history_entry.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ScanHistoryEntry {
  final String id;
  final DateTime scannedAt;
  final int pointsEarned;
  final List<String> detectedItems;
  final String binColor;
  final List<String> categories;

  ScanHistoryEntry({
    required this.id,
    required this.scannedAt,
    required this.pointsEarned,
    required this.detectedItems,
    required this.binColor,
    required this.categories,
  });

  factory ScanHistoryEntry.fromJson(Map<String, dynamic> json) {
    // Handle timestamp conversion safely
    DateTime scannedAt;
    final timestampValue = json['scannedAt'];
    if (timestampValue is Timestamp) {
      scannedAt = timestampValue.toDate();
    } else if (timestampValue is String) {
      scannedAt = DateTime.parse(timestampValue);
    } else if (timestampValue is int) {
      scannedAt = DateTime.fromMillisecondsSinceEpoch(timestampValue);
    } else {
      scannedAt = DateTime.now(); // Fallback
    }

    return ScanHistoryEntry(
      id: json['id'] as String? ?? '',
      scannedAt: scannedAt,
      pointsEarned: json['pointsEarned'] as int? ?? 0,
      detectedItems: List<String>.from(json['detectedItems'] ?? []),
      binColor: json['binColor'] as String? ?? 'General',
      categories: List<String>.from(json['categories'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'scannedAt': Timestamp.fromDate(scannedAt),
        'pointsEarned': pointsEarned,
        'detectedItems': detectedItems,
        'binColor': binColor,
        'categories': categories,
      };
}