import 'package:flutter/foundation.dart';

/// Centralized logging service for the waste sorter app
class LoggingService {
  static void debug(String message) {
    if (kDebugMode) {
      print('🐛 [DEBUG] $message');
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      print('ℹ️ [INFO] $message');
    }
  }

  static void warning(String message) {
    if (kDebugMode) {
      print('⚠️ [WARNING] $message');
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('❌ [ERROR] $message');
      if (error != null) {
        print('Error details: $error');
      }
      if (stackTrace != null) {
        print('Stack trace: $stackTrace');
      }
    }
  }

  // Location specific logging
  static void locationInfo(String message) {
    if (kDebugMode) {
      print('📍 [LOCATION] $message');
    }
  }

  static void locationError(String message, [dynamic error]) {
    if (kDebugMode) {
      print('📍❌ [LOCATION] $message');
      if (error != null) {
        print('Error details: $error');
      }
    }
  }

  // Camera specific logging
  static void cameraInfo(String message) {
    if (kDebugMode) {
      print('📸 [CAMERA] $message');
    }
  }

  static void cameraError(String message, [dynamic error]) {
    if (kDebugMode) {
      print('📸❌ [CAMERA] $message');
      if (error != null) {
        print('Error details: $error');
      }
    }
  }
}
