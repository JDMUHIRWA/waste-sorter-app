import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class FirebaseStorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload scan image to Firebase Storage and return the download URL
  static Future<String> uploadScanImage(String userId, String imagePath) async {
    try {
      final file = File(imagePath);
      
      // Create a unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(imagePath);
      final fileName = 'scan_$timestamp$extension';
      
      // Create reference to the file location
      final ref = _storage.ref().child('scans/$userId/$fileName');
      
      // Upload the file
      final uploadTask = ref.putFile(file);
      
      // Wait for upload to complete
      final snapshot = await uploadTask;
      
      // Get the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Upload profile picture and return the download URL
  static Future<String> uploadProfilePicture(String userId, String imagePath) async {
    try {
      final file = File(imagePath);
      
      // Create reference for profile picture
      final ref = _storage.ref().child('profiles/$userId/profile_picture.jpg');
      
      // Upload the file
      final uploadTask = ref.putFile(file);
      
      // Wait for upload to complete
      final snapshot = await uploadTask;
      
      // Get the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  /// Delete a file from Firebase Storage
  static Future<void> deleteFile(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } catch (e) {
      // File might not exist, which is fine
      print('Error deleting file: $e');
    }
  }

  /// Get file size limit info
  static const int maxFileSizeBytes = 10 * 1024 * 1024; // 10MB
  
  static bool isFileSizeValid(String filePath) {
    final file = File(filePath);
    return file.lengthSync() <= maxFileSizeBytes;
  }
}
