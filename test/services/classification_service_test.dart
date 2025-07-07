import 'package:flutter_test/flutter_test.dart';
import 'package:waste_sorter_app/services/classification_service.dart';
import 'package:waste_sorter_app/models/classification_result.dart';

void main() {
  group('Classification Service Tests', () {
    late MockClassificationService service;

    setUp(() {
      service = MockClassificationService();
    });

    test('should classify image successfully', () async {
      const imagePath = '/mock/path/test_image.jpg';

      final result = await service.classifyImage(imagePath);

      expect(result, isA<ClassificationResult>());
      expect(result.category, isNotEmpty);
      expect(result.confidence, greaterThan(0.0));
      expect(result.confidence, lessThanOrEqualTo(1.0));
      expect(result.itemType, isNotEmpty);
      expect(result.instructions, isNotEmpty);
    });

    test('should provide environmental impact data', () async {
      const imagePath = '/mock/path/test_image.jpg';

      final result = await service.classifyImage(imagePath);

      expect(result.environmentalImpact, isNotNull);
      expect(result.environmentalImpact.co2Saved, isNotEmpty);
      expect(result.environmentalImpact.energySaved, isNotEmpty);
      expect(result.environmentalImpact.description, isNotEmpty);
    });

    test('should check service availability', () async {
      final isAvailable = await service.isServiceAvailable();
      expect(isAvailable, isTrue); // Mock service should be available
    });

    test('should provide supported formats', () {
      final formats = service.getSupportedFormats();
      expect(formats, isNotEmpty);
      expect(formats, contains('jpg'));
    });
  });

  group('Environmental Impact Tests', () {
    test('EnvironmentalImpact should serialize correctly', () {
      const impact = EnvironmentalImpact(
        co2Saved: '0.5 kg',
        energySaved: '2.3 kWh',
        description: 'By recycling this item, you helped save energy.',
      );

      final json = impact.toJson();
      final deserialized = EnvironmentalImpact.fromJson(json);

      expect(deserialized.co2Saved, impact.co2Saved);
      expect(deserialized.energySaved, impact.energySaved);
      expect(deserialized.description, impact.description);
    });
  });
}
