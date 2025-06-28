import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Enable Firebase when configuration is ready
  // try {
  //   await Firebase.initializeApp();
  //   print('Firebase initialized successfully');
  // } catch (e) {
  //   print('Firebase initialization failed: $e');
  // }

  runApp(
    const ProviderScope(
      child: WasteSorterApp(),
    ),
  );
}
