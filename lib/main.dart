import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Firebase initialized successfully - real backend is ready
  } catch (e) {
    // Firebase not ready yet - using mock services for frontend testing
    // This is expected during development before backend integration
  }

  runApp(
    const ProviderScope(
      child: WasteSorterApp(),
    ),
  );
}
