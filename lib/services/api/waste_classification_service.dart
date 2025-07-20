import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../models/scan_models.dart';
import '../../core/config/app_config.dart';

class WasteClassificationService {
  static const String _baseUrl = 'https://reciclapi-garbage-detection.p.rapidapi.com';
  static const String _apiKey = AppConfig.rapidApiKey;
  
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'x-rapidapi-host': 'reciclapi-garbage-detection.p.rapidapi.com',
    'x-rapidapi-key': _apiKey,
  };

  /// Classify waste items from an image URL
  static Future<WasteClassificationResponse> classifyWaste(String imageUrl) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/predict'),
        headers: _headers,
        body: jsonEncode({
          'image': imageUrl,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return WasteClassificationResponse.fromJson(data);
      } else {
        return WasteClassificationResponse(
          success: false,
          items: [],
          error: 'API request failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      return WasteClassificationResponse(
        success: false,
        items: [],
        error: 'Network error: $e',
      );
    }
  }

  /// Map waste item classes to categories
  static String mapItemToCategory(String className) {
    final classLower = className.toLowerCase();
    
    // Plastic items
    if (classLower.contains('plastic') || 
        classLower.contains('bottle') || 
        classLower.contains('container') ||
        classLower.contains('bag')) {
      return 'plastic';
    }
    
    // Organic/Food waste
    if (classLower.contains('food') || 
        classLower.contains('organic') || 
        classLower.contains('fruit') ||
        classLower.contains('vegetable') ||
        classLower.contains('compost')) {
      return 'organic';
    }
    
    // Paper items
    if (classLower.contains('paper') || 
        classLower.contains('cardboard') || 
        classLower.contains('newspaper') ||
        classLower.contains('magazine')) {
      return 'paper';
    }
    
    // Metal items
    if (classLower.contains('metal') || 
        classLower.contains('can') || 
        classLower.contains('aluminum') ||
        classLower.contains('steel')) {
      return 'metal';
    }
    
    // Glass items
    if (classLower.contains('glass') || 
        classLower.contains('jar')) {
      return 'glass';
    }
    
    // Electronic waste
    if (classLower.contains('electronic') || 
        classLower.contains('battery') || 
        classLower.contains('phone') ||
        classLower.contains('computer') ||
        classLower.contains('cable')) {
      return 'e-waste';
    }
    
    // Hazardous waste
    if (classLower.contains('hazardous') || 
        classLower.contains('chemical') || 
        classLower.contains('paint') ||
        classLower.contains('oil')) {
      return 'hazardous';
    }
    
    // Default to plastic for unknown items (most common recyclable)
    return 'plastic';
  }

  /// Generate disposal instructions based on category
  static List<String> getDisposalInstructions(String category, String binColor) {
    switch (category.toLowerCase()) {
      case 'plastic':
        return [
          'Remove any caps or lids',
          'Rinse the item clean',
          'Check for recycling symbols',
          'Place in $binColor bin',
        ];
      case 'organic':
        return [
          'Remove any packaging',
          'Cut into smaller pieces if large',
          'Place in $binColor bin',
          'Ensure no plastic contamination',
        ];
      case 'paper':
        return [
          'Remove any plastic coatings',
          'Flatten the item',
          'Keep dry and clean',
          'Place in $binColor bin',
        ];
      case 'metal':
        return [
          'Rinse clean of food residue',
          'Remove any labels if possible',
          'Check if aluminum or steel',
          'Place in $binColor bin',
        ];
      case 'glass':
        return [
          'Rinse clean',
          'Remove any metal lids',
          'Handle carefully',
          'Place in $binColor bin',
        ];
      case 'e-waste':
        return [
          'Remove batteries if possible',
          'Do not place in regular bins',
          'Take to designated $binColor collection point',
          'Ensure data is wiped from devices',
        ];
      case 'hazardous':
        return [
          'Do not place in regular bins',
          'Take to special $binColor collection facility',
          'Keep in original container if possible',
          'Follow local hazardous waste guidelines',
        ];
      default:
        return [
          'Check local disposal guidelines',
          'Place in $binColor bin',
          'Ensure item is clean',
        ];
    }
  }
}
