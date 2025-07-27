import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/scan_models.dart';
import 'firebase_storage_service.dart';

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
  static Future<String> _uploadImageTemporarily(String imagePath) async {
    try {
      // Try to use Firebase Storage for production
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        return await FirebaseStorageService.uploadScanImage(
            currentUser.uid, imagePath);
      }
    } catch (e) {
      print('Failed to upload to Firebase Storage: $e');
    }

    // Fallback: use local file path for demo
    return 'file://$imagePath';
  }

  /// Classify waste using the RapidAPI service
  static Future<WasteClassificationResult> classifyWaste(
      String imageUrl) async {
    print(
        '🔍 [CLASSIFICATION] Starting waste classification for image: $imageUrl');

    try {
      // Check if we have a valid API key
      if (_rapidApiKey == 'YOUR_RAPID_API_KEY') {
        print(
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

      print('🚀 [CLASSIFICATION] Making API request to: $_baseUrl/predict');
      print('📋 [CLASSIFICATION] Request headers: $headers');
      print('📋 [CLASSIFICATION] Request body: $body');

      // Make API request
      final response = await http.post(
        Uri.parse('$_baseUrl/predict'),
        headers: headers,
        body: body,
      );

      print('📥 [CLASSIFICATION] API response status: ${response.statusCode}');
      print('📥 [CLASSIFICATION] API response headers: ${response.headers}');
      print('📥 [CLASSIFICATION] Raw API response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print(
            '✅ [CLASSIFICATION] Successfully parsed JSON response: $jsonResponse');
        print(
            '🔧 [CLASSIFICATION] Calling _parseApiResponse with: $jsonResponse');

        final result = _parseApiResponse(jsonResponse);
        print('🎯 [CLASSIFICATION] Final parsed result:');
        print('   - Detected Items: ${result.detectedItems}');
        print('   - Categories: ${result.categories}');
        print('   - Bin Color: ${result.binColor}');
        print('   - Confidence: ${result.confidence}');
        print('   - Instructions: ${result.instructions}');
        print('   - Recommended Action: ${result.recommendedAction}');

        return result;
      } else {
        print(
            '❌ [CLASSIFICATION] API request failed with status: ${response.statusCode}');
        print('❌ [CLASSIFICATION] Error response body: ${response.body}');
        print('❌ [CLASSIFICATION] Error response headers: ${response.headers}');
        throw Exception(
            'API request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 [CLASSIFICATION] Classification error: $e');
      print('💥 [CLASSIFICATION] Error type: ${e.runtimeType}');
      if (e is Exception) {
        print('💥 [CLASSIFICATION] Exception details: ${e.toString()}');
      }
      // Fallback to mock classification for demo
      print('🔄 [CLASSIFICATION] Falling back to mock classification');
      return _getMockClassification();
    }
  }

  /// Parse the API response into our classification result
  static WasteClassificationResult _parseApiResponse(dynamic response) {
    print('🔧 [PARSE] Starting to parse API response...');
    print('🔧 [PARSE] Response type: ${response.runtimeType}');
    print('🔧 [PARSE] Response content: $response');

    // Handle the actual API response format which is a direct array
    List<dynamic> predictions;

    if (response is List) {
      print('✅ [PARSE] Response is a List with ${response.length} items');
      predictions = response;
    } else if (response is Map && response.containsKey('predictions')) {
      print('✅ [PARSE] Response is a Map with predictions key');
      predictions = response['predictions'] as List<dynamic>? ?? [];
    } else {
      print('⚠️ [PARSE] Response format not recognized, using empty list');
      predictions = [];
    }

    print('🔧 [PARSE] Processing ${predictions.length} predictions...');

    List<String> detectedItems = [];
    List<String> categories = [];
    double maxConfidence = 0.0;
    String primaryCategory = 'general';

    for (int i = 0; i < predictions.length; i++) {
      final prediction = predictions[i];
      print('🔧 [PARSE] Processing prediction $i: $prediction');

      final className = prediction['class'] as String? ?? '';
      final confidence = (prediction['confidence'] as num?)?.toDouble() ?? 0.0;

      print(
          '🔧 [PARSE] Extracted - Class: "$className", Confidence: $confidence');

      if (className.isNotEmpty) {
        // Use the class name directly as the detected item
        final formattedName = _formatClassName(className);
        detectedItems.add(formattedName);
        print('✅ [PARSE] Added detected item: "$formattedName"');

        // The class name is already a category
        if (!categories.contains(className)) {
          categories.add(className);
          print('✅ [PARSE] Added category: "$className"');
        }

        // Track highest confidence prediction
        if (confidence > maxConfidence) {
          maxConfidence = confidence;
          primaryCategory = className;
          print(
              '🎯 [PARSE] New highest confidence: $confidence for category: "$primaryCategory"');
        }
      } else {
        print('⚠️ [PARSE] Skipping empty class name for prediction $i');
      }
    }

    print('📊 [PARSE] Summary after processing all predictions:');
    print('   - Detected Items: $detectedItems');
    print('   - Categories: $categories');
    print('   - Max Confidence: $maxConfidence');
    print('   - Primary Category: "$primaryCategory"');

    // Fallback if no items detected
    if (detectedItems.isEmpty) {
      print('⚠️ [PARSE] No items detected, using fallback');
      detectedItems = ['Unknown item'];
      categories = ['general'];
      primaryCategory = 'general';
    }

    final binColor = _categoryToBinColor[primaryCategory] ?? 'Grey';
    final instructions = _categoryInstructions[primaryCategory] ??
        ['Dispose according to local guidelines'];

    print('🎯 [PARSE] Final result mapping:');
    print('   - Primary Category: "$primaryCategory" → Bin Color: "$binColor"');
    print('   - Instructions count: ${instructions.length}');

    final result = WasteClassificationResult(
      detectedItems: detectedItems,
      categories: categories,
      binColor: binColor,
      instructions: instructions,
      confidence: maxConfidence,
      recommendedAction: _getRecommendedAction(primaryCategory),
    );

    print('✅ [PARSE] Successfully created WasteClassificationResult');
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
    print('🎭 [MOCK] Using mock classification for testing');

    // Simulate the API response format with multiple detections
    final mockApiResponse = [
      {"class": "plastic", "confidence": 0.8},
      {"class": "metal", "confidence": 0.7},
      {"class": "cardboard", "confidence": 0.6},
      {"class": "paper", "confidence": 0.5}
    ];

    print('🎭 [MOCK] Mock API response: $mockApiResponse');

    // Use the same parsing logic as the real API
    final result = _parseApiResponse(mockApiResponse);
    print('🎭 [MOCK] Mock classification complete');
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
