import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/scan_models.dart';
import 'firebase_storage_service.dart';

class WasteClassificationService {
  static const String _baseUrl = 'https://reciclapi-garbage-detection.p.rapidapi.com';
  static const String _rapidApiKey = 'YOUR_RAPID_API_KEY'; // Replace with your actual API key
  static const String _rapidApiHost = 'reciclapi-garbage-detection.p.rapidapi.com';

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
      final storageService = FirebaseStorageService();
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        return await FirebaseStorageService.uploadScanImage(currentUser.uid, imagePath);
      }
    } catch (e) {
      print('Failed to upload to Firebase Storage: $e');
    }
    
    // Fallback: use local file path for demo
    return 'file://$imagePath';
  }

  /// Classify waste using the RapidAPI service
  static Future<WasteClassificationResult> classifyWaste(String imagePath) async {
    print('Starting waste classification for image: $imagePath');
    
    try {
      // For now, always use mock classification since we don't have a real API key
      // In production, uncomment the API call below
      
      // Upload image and get public URL
      // final imageUrl = await _uploadImageTemporarily(imagePath);
      // 
      // // Prepare request to RapidAPI
      // final headers = {
      //   'Content-Type': 'application/json',
      //   'x-rapidapi-host': _rapidApiHost,
      //   'x-rapidapi-key': _rapidApiKey,
      // };
      //
      // final body = json.encode({
      //   'image': imageUrl,
      // });
      //
      // // Make API request
      // final response = await http.post(
      //   Uri.parse('$_baseUrl/predict'),
      //   headers: headers,
      //   body: body,
      // );
      //
      // if (response.statusCode == 200) {
      //   final jsonResponse = json.decode(response.body);
      //   return _parseApiResponse(jsonResponse);
      // } else {
      //   throw Exception('API request failed with status: ${response.statusCode}');
      // }
      
      // For demo purposes, return mock classification
      print('Using mock classification for demo');
      return _getMockClassification();
      
    } catch (e) {
      print('Classification error: $e');
      // Fallback to mock classification for demo
      return _getMockClassification();
    }
  }

  /// Parse the API response into our classification result
  static WasteClassificationResult _parseApiResponse(Map<String, dynamic> response) {
    // Parse the API response structure - adjust based on actual API response format
    final predictions = response['predictions'] as List<dynamic>? ?? [];
    
    List<String> detectedItems = [];
    List<String> categories = [];
    double maxConfidence = 0.0;
    String primaryCategory = 'general';

    for (var prediction in predictions) {
      final item = prediction['label'] as String? ?? '';
      final confidence = (prediction['confidence'] as num?)?.toDouble() ?? 0.0;
      
      if (item.isNotEmpty) {
        detectedItems.add(item);
        
        // Map item to category
        String category = _mapItemToCategory(item);
        if (!categories.contains(category)) {
          categories.add(category);
        }
        
        // Track highest confidence prediction
        if (confidence > maxConfidence) {
          maxConfidence = confidence;
          primaryCategory = category;
        }
      }
    }

    // Fallback if no items detected
    if (detectedItems.isEmpty) {
      detectedItems = ['Unknown item'];
      categories = ['general'];
      primaryCategory = 'general';
    }

    final binColor = _categoryToBinColor[primaryCategory] ?? 'Grey';
    final instructions = _categoryInstructions[primaryCategory] ?? ['Dispose according to local guidelines'];

    return WasteClassificationResult(
      detectedItems: detectedItems,
      categories: categories,
      binColor: binColor,
      instructions: instructions,
      confidence: maxConfidence,
      recommendedAction: _getRecommendedAction(primaryCategory),
    );
  }

  /// Map detected item name to waste category
  static String _mapItemToCategory(String item) {
    final itemLower = item.toLowerCase();
    
    if (itemLower.contains('bottle') || itemLower.contains('plastic') || itemLower.contains('container')) {
      return 'plastic';
    } else if (itemLower.contains('paper') || itemLower.contains('document') || itemLower.contains('newspaper')) {
      return 'paper';
    } else if (itemLower.contains('food') || itemLower.contains('organic') || itemLower.contains('fruit') || itemLower.contains('vegetable')) {
      return 'organic';
    } else if (itemLower.contains('can') || itemLower.contains('metal') || itemLower.contains('aluminum')) {
      return 'metal';
    } else if (itemLower.contains('glass') || itemLower.contains('jar')) {
      return 'glass';
    } else if (itemLower.contains('cardboard') || itemLower.contains('box')) {
      return 'cardboard';
    } else if (itemLower.contains('electronic') || itemLower.contains('phone') || itemLower.contains('computer')) {
      return 'electronics';
    } else if (itemLower.contains('battery')) {
      return 'battery';
    } else if (itemLower.contains('chemical') || itemLower.contains('paint') || itemLower.contains('hazardous')) {
      return 'hazardous';
    }
    
    return 'general';
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
    // Return a mock result for testing
    return WasteClassificationResult(
      detectedItems: ['Plastic Bottle'],
      categories: ['plastic'],
      binColor: 'Blue',
      instructions: [
        'Remove cap and lid',
        'Rinse thoroughly',
        'Check recycling number',
        'Place in blue recycling bin'
      ],
      confidence: 0.85,
      recommendedAction: 'Clean and recycle in blue bin',
    );
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
