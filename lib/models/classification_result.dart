import 'package:flutter/foundation.dart';

/// Represents the result of waste classification from AI analysis
@immutable
class ClassificationResult {
  const ClassificationResult({
    required this.category,
    required this.confidence,
    required this.itemType,
    required this.material,
    required this.instructions,
    required this.environmentalImpact,
    this.alternativeUses = const [],
    this.processingTimeMs,
  });

  /// Main waste category (Recyclable, Compostable, Landfill, Hazardous)
  final String category;

  /// AI confidence score (0.0 - 1.0)
  final double confidence;

  /// Specific item type (e.g., "Plastic Bottle", "Aluminum Can")
  final String itemType;

  /// Material composition
  final String material;

  /// Step-by-step disposal instructions
  final List<String> instructions;

  /// Environmental impact data
  final EnvironmentalImpact environmentalImpact;

  /// Alternative reuse suggestions
  final List<String> alternativeUses;

  /// Time taken for AI processing (for analytics)
  final int? processingTimeMs;

  /// Convert to JSON for API communication
  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'confidence': confidence,
      'itemType': itemType,
      'material': material,
      'instructions': instructions,
      'environmentalImpact': environmentalImpact.toJson(),
      'alternativeUses': alternativeUses,
      'processingTimeMs': processingTimeMs,
    };
  }

  /// Create from JSON response
  factory ClassificationResult.fromJson(Map<String, dynamic> json) {
    return ClassificationResult(
      category: json['category'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      itemType: json['itemType'] as String,
      material: json['material'] as String,
      instructions: List<String>.from(json['instructions'] as List),
      environmentalImpact: EnvironmentalImpact.fromJson(
        json['environmentalImpact'] as Map<String, dynamic>,
      ),
      alternativeUses:
          List<String>.from(json['alternativeUses'] as List? ?? []),
      processingTimeMs: json['processingTimeMs'] as int?,
    );
  }

  @override
  String toString() {
    return 'ClassificationResult(category: $category, confidence: $confidence, itemType: $itemType)';
  }
}

/// Environmental impact data for the classified item
@immutable
class EnvironmentalImpact {
  const EnvironmentalImpact({
    required this.co2Saved,
    required this.energySaved,
    required this.description,
  });

  /// CO2 emissions saved (e.g., "0.2 kg")
  final String co2Saved;

  /// Energy saved (e.g., "1.5 kWh")
  final String energySaved;

  /// Human-readable impact description
  final String description;

  Map<String, dynamic> toJson() {
    return {
      'co2Saved': co2Saved,
      'energySaved': energySaved,
      'description': description,
    };
  }

  factory EnvironmentalImpact.fromJson(Map<String, dynamic> json) {
    return EnvironmentalImpact(
      co2Saved: json['co2Saved'] as String,
      energySaved: json['energySaved'] as String,
      description: json['description'] as String,
    );
  }
}
