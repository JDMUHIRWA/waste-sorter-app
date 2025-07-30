import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:waste_sorter_app/services/logging_service.dart';
import '../models/scan_models.dart';
class WasteClassificationService {
  static const String _baseUrl =
      'https://reciclapi-garbage-detection.p.rapidapi.com';
  // Never push the API key since our repository is public.
  static const String _rapidApiKey =
      'YOUR_RAPID_API_KEY'; // Replace with your actual API key
  static const String _rapidApiHost =
      'reciclapi-garbage-detection.p.rapidapi.com';

  // Map API response to our local bin color rules
  static const Map<String, String> _categoryToBinColor = {
    'plastic': 'Blue',
    'paper': 'Yellow',
    'organic': 'Green',
    'metal': 'Blue',
    'glass': 'Blue',
    'cardboard': 'Yellow',
    'electronics': 'Red',
    'battery': 'Red',
    'hazardous': 'Black',
    'general': 'Grey',
  };

  static const Map<String, List<String>> _categoryInstructions = {
    'plastic': [
      'Remove all caps and lids',
      'Rinse container thoroughly',
      'Check recycling number on bottom',
      'Place in blue recycling bin'
    ],
    'paper': [
      'Remove any plastic components',
      'Ensure paper is clean and dry',
      'Place in yellow recycling bin'
    ],
    'organic': [
      'Remove any non-organic materials',
      'Place in green compost bin',
      'Avoid meat and dairy if home composting'
    ],
    'metal': [
      'Rinse thoroughly',
      'Remove labels if possible',
      'Place in blue recycling bin'
    ],
    'glass': [
      'Rinse thoroughly',
      'Remove caps and lids',
      'Place in blue recycling bin',
      'Handle carefully to avoid breakage'
    ],
    'electronics': [
      'Take to electronic recycling center',
      'Do not place in regular bins',
      'Remove batteries if possible',
      'Data should be wiped from devices'
    ],
    'battery': [
      'Take to battery recycling point',
      'Never dispose in regular waste',
      'Tape terminals for safety',
      'Check local collection points'
    ],
    'hazardous': [
      'Take to hazardous waste facility',
      'Do not dispose in regular bins',
      'Keep in original container',
      'Follow local disposal guidelines'
    ],
  };

  /// Upload image to Firebase Storage and get public URL
  // static Future<String> _uploadImageTemporarily(String imagePath) async {
  //   try {
  //     // Try to use Firebase Storage for production
  //     final currentUser = FirebaseAuth.instance.currentUser;
  //     if (currentUser != null) {
  //       return await FirebaseStorageService.uploadScanImage(
  //           currentUser.uid, imagePath);
  //     }
  //   } catch (e) {
  //       LoggingService.error('Failed to upload to Firebase Storage: $e');
  //   }

  //   // Fallback: use local file path for demo
  //   return 'file://$imagePath';
  // }

  /// Classify waste using the RapidAPI service
  static Future<WasteClassificationResult> classifyWaste(
      String imageUrl) async {
      LoggingService.error(
        '🔍 [CLASSIFICATION] Starting waste classification for image: $imageUrl');

    try {
      // Check if we have a valid API key
      if (_rapidApiKey == 'YOUR_RAPID_API_KEY') {
          LoggingService.error(
            '⚠️ [CLASSIFICATION] Using mock classification - API key not configured');
        return _getMockClassification();
      }

      // Prepare request to RapidAPI
      final headers = {
        'Content-Type': 'application/json',
        'x-rapidapi-host': _rapidApiHost,
        'x-rapidapi-key': _rapidApiKey,
      };

      final body = json.encode({
        'image': imageUrl,
      });

        LoggingService.error('🚀 [CLASSIFICATION] Making API request to: $_baseUrl/predict');
        LoggingService.error('📋 [CLASSIFICATION] Request headers: $headers');
        LoggingService.error('📋 [CLASSIFICATION] Request body: $body');

      // Make API request
      final response = await http.post(
        Uri.parse('$_baseUrl/predict'),
        headers: headers,
        body: body,
      );

        LoggingService.error('📥 [CLASSIFICATION] API response status: ${response.statusCode}');
        LoggingService.error('📥 [CLASSIFICATION] API response headers: ${response.headers}');
        LoggingService.error('📥 [CLASSIFICATION] Raw API response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
          LoggingService.error(
            '✅ [CLASSIFICATION] Successfully parsed JSON response: $jsonResponse');
          LoggingService.error(
            '🔧 [CLASSIFICATION] Calling _parseApiResponse with: $jsonResponse');

        final result = _parseApiResponse(jsonResponse);
          LoggingService.error('🎯 [CLASSIFICATION] Final parsed result:');
          LoggingService.error('   - Detected Items: ${result.detectedItems}');
          LoggingService.error('   - Categories: ${result.categories}');
          LoggingService.error('   - Bin Color: ${result.binColor}');
          LoggingService.error('   - Confidence: ${result.confidence}');
          LoggingService.error('   - Instructions: ${result.instructions}');
          LoggingService.error('   - Recommended Action: ${result.recommendedAction}');

        return result;
      } else {
          LoggingService.error(
            '❌ [CLASSIFICATION] API request failed with status: ${response.statusCode}');
          LoggingService.error('❌ [CLASSIFICATION] Error response body: ${response.body}');
          LoggingService.error('❌ [CLASSIFICATION] Error response headers: ${response.headers}');
        throw Exception(
            'API request failed with status: ${response.statusCode}');
      }
    } catch (e) {
        LoggingService.error('💥 [CLASSIFICATION] Classification error: $e');
        LoggingService.error('💥 [CLASSIFICATION] Error type: ${e.runtimeType}');
      if (e is Exception) {
          LoggingService.error('💥 [CLASSIFICATION] Exception details: ${e.toString()}');
      }
      // Fallback to mock classification for demo
        LoggingService.error('🔄 [CLASSIFICATION] Falling back to mock classification');
      return _getMockClassification();
    }
  }

  /// Parse the API response into our classification result
  static WasteClassificationResult _parseApiResponse(dynamic response) {
      LoggingService.error('🔧 [PARSE] Starting to parse API response...');
      LoggingService.error('🔧 [PARSE] Response type: ${response.runtimeType}');
      LoggingService.error('🔧 [PARSE] Response content: $response');

    // Handle the actual API response format which is a direct array
    List<dynamic> predictions;

    if (response is List) {
        LoggingService.error('✅ [PARSE] Response is a List with ${response.length} items');
      predictions = response;
    } else if (response is Map && response.containsKey('predictions')) {
        LoggingService.error('✅ [PARSE] Response is a Map with predictions key');
      predictions = response['predictions'] as List<dynamic>? ?? [];
    } else {
        LoggingService.error('⚠️ [PARSE] Response format not recognized, using empty list');
      predictions = [];
    }

      LoggingService.error('🔧 [PARSE] Processing ${predictions.length} predictions...');

    List<String> detectedItems = [];
    List<String> categories = [];
    double maxConfidence = 0.0;
    String primaryCategory = 'general';

    for (int i = 0; i < predictions.length; i++) {
      final prediction = predictions[i];
        LoggingService.error('🔧 [PARSE] Processing prediction $i: $prediction');

      final className = prediction['class'] as String? ?? '';
      final confidence = (prediction['confidence'] as num?)?.toDouble() ?? 0.0;

        LoggingService.error(
          '🔧 [PARSE] Extracted - Class: "$className", Confidence: $confidence');

      if (className.isNotEmpty) {
        // Use the class name directly as the detected item
        final formattedName = _formatClassName(className);
        detectedItems.add(formattedName);
          LoggingService.error('✅ [PARSE] Added detected item: "$formattedName"');

        // The class name is already a category
        if (!categories.contains(className)) {
          categories.add(className);
            LoggingService.error('✅ [PARSE] Added category: "$className"');
        }

        // Track highest confidence prediction
        if (confidence > maxConfidence) {
          maxConfidence = confidence;
          primaryCategory = className;
            LoggingService.error(
              '🎯 [PARSE] New highest confidence: $confidence for category: "$primaryCategory"');
        }
      } else {
          LoggingService.error('⚠️ [PARSE] Skipping empty class name for prediction $i');
      }
    }

      LoggingService.error('📊 [PARSE] Summary after processing all predictions:');
      LoggingService.error('   - Detected Items: $detectedItems');
      LoggingService.error('   - Categories: $categories');
      LoggingService.error('   - Max Confidence: $maxConfidence');
      LoggingService.error('   - Primary Category: "$primaryCategory"');

    // Fallback if no items detected
    if (detectedItems.isEmpty) {
        LoggingService.error('⚠️ [PARSE] No items detected, using fallback');
      detectedItems = ['Unknown item'];
      categories = ['general'];
      primaryCategory = 'general';
    }

    final binColor = _categoryToBinColor[primaryCategory] ?? 'Grey';
    final instructions = _categoryInstructions[primaryCategory] ??
        ['Dispose according to local guidelines'];

      LoggingService.error('🎯 [PARSE] Final result mapping:');
      LoggingService.error('   - Primary Category: "$primaryCategory" → Bin Color: "$binColor"');
      LoggingService.error('   - Instructions count: ${instructions.length}');

    final result = WasteClassificationResult(
      detectedItems: detectedItems,
      categories: categories,
      binColor: binColor,
      instructions: instructions,
      confidence: maxConfidence,
      recommendedAction: _getRecommendedAction(primaryCategory),
    );

      LoggingService.error('✅ [PARSE] Successfully created WasteClassificationResult');
    return result;
  }

  /// Format class name for display
  static String _formatClassName(String className) {
    switch (className.toLowerCase()) {
      case 'plastic':
        return 'Plastic Item';
      case 'metal':
        return 'Metal Item';
      case 'cardboard':
        return 'Cardboard';
      case 'paper':
        return 'Paper';
      case 'glass':
        return 'Glass Item';
      case 'organic':
        return 'Organic Waste';
      case 'electronics':
        return 'Electronic Device';
      case 'battery':
        return 'Battery';
      case 'hazardous':
        return 'Hazardous Material';
      default:
        return className.substring(0, 1).toUpperCase() + className.substring(1);
    }
  }

  /// Get recommended action based on category
  static String _getRecommendedAction(String category) {
    switch (category) {
      case 'plastic':
        return 'Clean and recycle in blue bin';
      case 'paper':
        return 'Recycle in yellow bin';
      case 'organic':
        return 'Compost in green bin';
      case 'metal':
        return 'Recycle in blue bin';
      case 'glass':
        return 'Recycle in blue bin';
      case 'electronics':
        return 'Take to e-waste collection point';
      case 'battery':
        return 'Take to battery recycling point';
      case 'hazardous':
        return 'Take to hazardous waste facility';
      default:
        return 'Dispose in general waste bin';
    }
  }

  /// Mock classification for testing/demo purposes
  static WasteClassificationResult _getMockClassification() {
      LoggingService.error('🎭 [MOCK] Using mock classification for testing');

    // Simulate the API response format with multiple detections
    final mockApiResponse = [
      {"class": "plastic", "confidence": 0.8},
      {"class": "metal", "confidence": 0.7},
      {"class": "cardboard", "confidence": 0.6},
      {"class": "paper", "confidence": 0.5}
    ];

      LoggingService.error('🎭 [MOCK] Mock API response: $mockApiResponse');

    // Use the same parsing logic as the real API
    final result = _parseApiResponse(mockApiResponse);
      LoggingService.error('🎭 [MOCK] Mock classification complete');
    return result;
  }

  /// Calculate points based on classification result
  static int calculatePoints(WasteClassificationResult classification) {
    // Base points for scanning
    int points = 5;

    // Bonus points based on category
    for (String category in classification.categories) {
      switch (category) {
        case 'plastic':
        case 'paper':
        case 'metal':
        case 'glass':
          points += 3; // Recyclable items get bonus
          break;
        case 'organic':
          points += 4; // Composting gets higher bonus
          break;
        case 'electronics':
        case 'battery':
        case 'hazardous':
          points += 10; // Proper disposal of dangerous items gets high bonus
          break;
      }
    }

    // Confidence bonus
    if (classification.confidence > 0.8) {
      points += 2;
    }

    return points;
  }
}
