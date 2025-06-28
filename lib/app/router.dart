import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/splash/screens/splash_screen.dart';
import '../features/auth/screens/welcome_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/auth/screens/signin_screen.dart';
import '../features/auth/screens/create_profile_screen.dart';
import '../features/location/screens/set_location_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/scan/screens/scan_screen.dart';
import '../features/scan/screens/disposal_instructions_screen.dart';
import '../features/scan/screens/confirmation_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/signin',
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: '/create-profile',
      builder: (context, state) => const CreateProfileScreen(),
    ),
    GoRoute(
      path: '/set-location',
      builder: (context, state) => const SetLocationScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    // Placeholder routes for future screens
    GoRoute(
      path: '/scan',
      builder: (context, state) => const ScanScreen(),
    ),
    GoRoute(
      path: '/disposal-instructions',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final imagePath = extra?['imagePath'] as String?;
        if (imagePath == null) {
          return const Scaffold(
            body: Center(child: Text('Image path not provided')),
          );
        }
        return DisposalInstructionsScreen(imagePath: imagePath);
      },
    ),
    GoRoute(
      path: '/confirmation',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final category = extra?['category'] as String? ?? 'Unknown';
        final points = extra?['points'] as int? ?? 0;
        return ConfirmationScreen(
          category: category,
          points: points,
        );
      },
    ),
    GoRoute(
      path: '/leaderboard',
      builder: (context, state) => const LeaderboardScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: const Center(
        child: Text('Leaderboard Screen - Coming Soon'),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(
        child: Text('Settings Screen - Coming Soon'),
      ),
    );
  }
}
