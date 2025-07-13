import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import 'router.dart';
import '../services/settings-preferences/provider.dart';

class WasteSorterApp extends ConsumerWidget {
  const WasteSorterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsNotifierProvider);
    return settingsAsync.when(
      data: (settings) => MaterialApp.router(
        title: 'WasteSorter',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
      loading: () => MaterialApp(
        title: 'WasteSorter',
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        debugShowCheckedModeBanner: false,
      ),
      error: (error, stack) => MaterialApp(
        title: 'WasteSorter',
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Center(
            child: Text('Error loading app: $error'),
          ),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
