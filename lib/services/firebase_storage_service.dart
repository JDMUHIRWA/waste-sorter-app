import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'logging_service.dart';

class FirebaseStorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Initialize Firebase Storage and check if it's properly configured
  static Future<void> _ensureStorageInitialized() async {
    try {
      // Try to get a reference to test if storage is working
      final testRef = _storage.ref().child('test');
      // This will throw an error if storage is not properly configured
      try {
        await testRef.getMetadata();
      } catch (e) {
        // If it's a not-found error, that's actually fine for a test reference
        if (e.toString().contains('object-not-found')) {
          return; // This is expected for a non-existent test file
        }
        rethrow; // Re-throw other errors
      }
    } catch (e) {
      throw Exception('Firebase Storage not properly configured: $e');
    }
  }

  /// Upload scan image to Firebase Storage and return the download URL
  static Future<String> uploadScanImage(String userId, String imagePath) async {
    try {
      // Ensure Firebase Storage is initialized
      await _ensureStorageInitialized();

      final file = File(imagePath);

      // Verify the file exists and is readable
      if (!await file.exists()) {
        throw Exception('Image file does not exist at path: $imagePath');
      }

      final fileSize = await file.length();
      if (fileSize == 0) {
        throw Exception('Image file is empty');
      }

      // Create a unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(imagePath);
      final fileName = 'scan_$timestamp$extension';

      // Create reference to the file location
      final ref = _storage.ref().child('scans/$userId/$fileName');

      // Set metadata for better file management
      final metadata = SettableMetadata(
        contentType: _getContentType(extension),
        customMetadata: {
          'userId': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
          'originalFileName': path.basename(imagePath),
        },
      );

      // Upload the file with metadata
      final uploadTask = ref.putFile(file, metadata);

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      // Provide more specific error information
      if (e.toString().contains('storage/unauthorized')) {
        throw Exception(
            'Failed to upload image: Unauthorized access to Firebase Storage. Check your Firebase Storage rules.');
      } else if (e.toString().contains('storage/retry-limit-exceeded')) {
        throw Exception(
            'Failed to upload image: Upload timeout. Please check your internet connection and try again.');
      } else if (e.toString().contains('storage/invalid-format')) {
        throw Exception(
            'Failed to upload image: Invalid image format. Please select a valid image file.');
      } else {
        throw Exception('Failed to upload image: $e');
      }
    }
  }

  /// Get content type based on file extension
  static String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      default:
        return 'image/jpeg'; // Default fallback
    }
  }

  /// Upload profile picture and return the download URL
  static Future<String> uploadProfilePicture(
      String userId, String imagePath) async {
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
      LoggingService.error('Error deleting file: $e');
    }
  }

  /// Get file size limit info
  static const int maxFileSizeBytes = 10 * 1024 * 1024; // 10MB

  static bool isFileSizeValid(String filePath) {
    final file = File(filePath);
    return file.lengthSync() <= maxFileSizeBytes;
  }
}
