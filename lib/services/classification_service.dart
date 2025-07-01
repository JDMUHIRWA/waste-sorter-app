import '../models/classification_result.dart';

/// Abstract service for AI image classification
/// This interface allows us to swap between mock and real implementations
abstract class ClassificationService {
  /// Classify a waste item from an image
  ///
  /// [imagePath] - Local path to the captured image
  /// Returns [ClassificationResult] with category, confidence, and instructions
  /// Throws [ClassificationException] if processing fails
  Future<ClassificationResult> classifyImage(String imagePath);

  /// Check if the service is available and ready
  Future<bool> isServiceAvailable();

  /// Get supported image formats
  List<String> getSupportedFormats();
}

/// Exception thrown during classification
class ClassificationException implements Exception {
  const ClassificationException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ClassificationException: $message';
}

/// Mock implementation for development/testing
class MockClassificationService implements ClassificationService {
  @override
  Future<ClassificationResult> classifyImage(String imagePath) async {
    // Simulate processing time
    await Future.delayed(const Duration(seconds: 3));

    // Mock different results based on timestamp for variety
    final now = DateTime.now();
    final mockResults = [
      ClassificationResult(
        category: 'Recyclable',
        confidence: 0.92,
        itemType: 'Plastic Bottle',
        material: 'PET Plastic',
        instructions: const ['Remove Cap', 'Rinse Item', 'Place in Blue Bin'],
        environmentalImpact: const EnvironmentalImpact(
          co2Saved: '0.2 kg',
          energySaved: '1.5 kWh',
          description:
              'Recycling this bottle saves energy equivalent to running a 60W bulb for 25 hours!',
        ),
        alternativeUses: const [
          'Plant pot for small herbs',
          'Storage container for small items',
          'Bird feeder (with modifications)',
        ],
        processingTimeMs: 2800,
      ),
      ClassificationResult(
        category: 'Compostable',
        confidence: 0.88,
        itemType: 'Apple Core',
        material: 'Organic Waste',
        instructions: const [
          'Remove Any Stickers',
          'Place in Compost Bin',
          'Cover with Brown Material'
        ],
        environmentalImpact: const EnvironmentalImpact(
          co2Saved: '0.1 kg',
          energySaved: '0.5 kWh',
          description:
              'Composting creates nutrient-rich soil and reduces methane emissions!',
        ),
        alternativeUses: const [
          'Compost for garden',
          'Worm food for vermicomposting',
        ],
        processingTimeMs: 2200,
      ),
      ClassificationResult(
        category: 'Hazardous',
        confidence: 0.95,
        itemType: 'Battery',
        material: 'Lithium Ion',
        instructions: const [
          'Do NOT Put in Regular Trash',
          'Take to Electronics Store',
          'Find Battery Recycling Center'
        ],
        environmentalImpact: const EnvironmentalImpact(
          co2Saved: '2.1 kg',
          energySaved: '8.3 kWh',
          description:
              'Proper battery disposal prevents toxic chemicals from entering soil and water!',
        ),
        alternativeUses: const [],
        processingTimeMs: 3100,
      ),
    ];

    // Return different result based on time for demo variety
    return mockResults[now.second % mockResults.length];
  }

  @override
  Future<bool> isServiceAvailable() async {
    return true;
  }

  @override
  List<String> getSupportedFormats() {
    return ['jpg', 'jpeg', 'png', 'heic'];
  }
}
