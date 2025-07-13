// lib/models/scan_history_entry.dart
class ScanHistoryEntry {
  final String id;
  final String imagePath;
  final int pointsEarned;
  final DateTime scannedAt;

  ScanHistoryEntry({
    required this.id,
    required this.imagePath,
    required this.pointsEarned,
    required this.scannedAt,
  });

  factory ScanHistoryEntry.fromJson(Map<String, dynamic> json) =>
      ScanHistoryEntry(
        id: json['id'],
        imagePath: json['imagePath'],
        pointsEarned: json['pointsEarned'],
        scannedAt: DateTime.parse(json['scannedAt']),
      );
}
