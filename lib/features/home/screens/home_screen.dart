import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/authentication/provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _tipOfTheWeek = [
    {
      'title': 'What Belongs in the Blue Bin',
      'description': 'Quick guide on recyclable items',
      'image': 'assets/images/blue_bin.png',
    },
    {
      'title': 'What Belongs in the Blue Bin',
      'description': 'Quick guide on recyclable items',
      'image': 'assets/images/blue_bin.png',
    },
  ];

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        // Home - already here
        break;
      case 1:
        context.go('/leaderboard');
        break;
      case 2:
        // Progress/Stats
        context.go('/progress');
        break;
      case 3:
        context.go('/settings');
        break;
    }
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = _currentIndex == index;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);

    // Shorten labels on very small screens
    String displayLabel = label;
    if (mediaQuery.size.width < 380) {
      switch (label) {
        case 'Leaderboard':
          displayLabel = 'Rank';
          break;
        case 'Progress':
          displayLabel = 'Stats';
          break;
        case 'Settings':
          displayLabel = 'More';
          break;
      }
    }

    return Expanded(
      child: InkWell(
        onTap: () => _onBottomNavTap(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 65), // Add height constraint
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2), // Reduced padding
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                color: isActive
                    ? colorScheme.primary
                    : theme.bottomNavigationBarTheme.unselectedItemColor ??
                        colorScheme.onSurface.withValues(alpha: 0.6),
                size: 22, // Slightly reduced from 24 to 22
              ),
              const SizedBox(height: 2), // Reduced from 4 to 2
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    displayLabel,
                    style: TextStyle(
                      fontSize: 10, // Reduced from 11 to 10
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive
                          ? colorScheme.primary
                          : theme.bottomNavigationBarTheme
                                  .unselectedItemColor ??
                              colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return currentUserAsync.when(
      data: (currentUser) {
        final userName = currentUser?.name ?? 'User';

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with user greeting - Updated to match Figma
                  Row(
                    children: [
                      // User Avatar
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius:
                              BorderRadius.circular(AppRadius.circular),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      // Greeting - Updated to match Figma exactly
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good Morning, $userName',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.color,
                              ),
                            ),
                            Text(
                              'Ready to save our planet?',
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // Tips of the Week Section
                  Text(
                    'Tip of the Week',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Tips List
                  Expanded(
                    child: ListView.builder(
                      itemCount: _tipOfTheWeek.length,
                      itemBuilder: (context, index) {
                        final tip = _tipOfTheWeek[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: Card(
                            elevation: 0,
                            color: Theme.of(context).cardTheme.color,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              side: BorderSide(
                                color: Theme.of(context).dividerColor,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Row(
                                children: [
                                  // Tip Image Placeholder
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.md),
                                    ),
                                    child: Icon(
                                      Icons.recycling,
                                      color: colorScheme.primary,
                                      size: 30,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  // Tip Content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tip['title'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.color,
                                          ),
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        Text(
                                          tip['description'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.color,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Floating Action Button for Scan - Updated to match Figma
          floatingActionButton: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: () => context.go('/scan'),
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Scan Item',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          // Bottom Navigation with BottomAppBar for better FAB integration
          bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 6.0,
            height: 65, // Reduced from 70 to 65
            elevation: 8,
            child: Container(
              height: 65, // Reduced from 70 to 65
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0), // Added vertical padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Home
                  _buildNavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    label: 'Home',
                    index: 0,
                  ),
                  // Leaderboard
                  _buildNavItem(
                    icon: Icons.leaderboard_outlined,
                    activeIcon: Icons.leaderboard,
                    label: 'Leaderboard',
                    index: 1,
                  ),
                  // Spacer for FAB
                  const SizedBox(width: 40), // Reduced from 50 to 40
                  // Progress
                  _buildNavItem(
                    icon: Icons.trending_up_outlined,
                    activeIcon: Icons.trending_up,
                    label: 'Progress',
                    index: 2,
                  ),
                  // Settings
                  _buildNavItem(
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings,
                    label: 'Settings',
                    index: 3,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),
    );
  }
}
