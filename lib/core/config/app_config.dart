// Configuration file for API keys and environment variables
// Make sure to add this file to .gitignore to keep your keys secure

class AppConfig {
  // Replace with your actual RapidAPI key
  static const String rapidApiKey = 'YOUR_RAPID_API_KEY_HERE';
  
  // Firebase project configuration (already set up in firebase_options.dart)
  static const String firebaseProjectId = 'waste-sorter-7f046';
  
  // Default user location
  static const String defaultLocation = 'Kigali';
  
  // Points system configuration
  static const int pointsPerItem = 5;
  
  // API endpoints
  static const String wasteClassificationUrl = 'https://reciclapi-garbage-detection.p.rapidapi.com/predict';
  
  // Firestore collection names
  static const String usersCollection = 'users';
  static const String scansCollection = 'scans';
  static const String rulesCollection = 'rules';
  static const String leaderboardCollection = 'leaderboard';
  static const String badgesCollection = 'badges';
  static const String tipsCollection = 'tips';
}
