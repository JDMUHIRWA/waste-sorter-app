import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'router.dart';

class WasteSorterApp extends StatelessWidget {
  const WasteSorterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'WasteSorter',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}