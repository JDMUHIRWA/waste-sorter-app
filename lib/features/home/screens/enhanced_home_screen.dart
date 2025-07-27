import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/app_providers.dart';
import '../../../models/enhanced_user_model.dart';
import '../../../models/scan_models.dart';

class EnhancedHomeScreen extends ConsumerWidget {
  const EnhancedHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final userStatsAsync = ref.watch(userStatsProvider);
    final streakStatusAsync = ref.watch(streakStatusProvider);
    final recentScansAsync = ref.watch(recentScansProvider);
    final ecoTipsAsync = ref.watch(ecoTipsProvider);

    return Scaffold(
      body: SafeArea(
        child: userAsync.when(
          data: (user) => user != null 
              ? _buildHomeContent(context, ref, user, userStatsAsync, streakStatusAsync, recentScansAsync, ecoTipsAsync)
              : _buildSignInPrompt(context),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error: $error'),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeContent(
    BuildContext context,
    WidgetRef ref,
    EnhancedUserModel user,
    AsyncValue<Map<String, dynamic>> userStatsAsync,
    AsyncValue<Map<String, dynamic>> streakStatusAsync,
    AsyncValue<List<ScanResultModel>> recentScansAsync,
    AsyncValue<List<TipModel>> ecoTipsAsync,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(userStatsProvider);
        ref.invalidate(streakStatusProvider);
        ref.invalidate(recentScansProvider);
        ref.invalidate(ecoTipsProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context, user),
            const SizedBox(height: 24),

            // Quick stats cards
            userStatsAsync.when(
              data: (stats) => _buildQuickStats(context, stats, streakStatusAsync),
              loading: () => _buildStatsLoading(),
              error: (error, stack) => _buildStatsError(),
            ),
            const SizedBox(height: 24),

            // Quick action button
            _buildQuickScanButton(context),
            const SizedBox(height: 24),

            // Recent scans
            recentScansAsync.when(
              data: (scans) => _buildRecentScans(context, scans),
              loading: () => _buildRecentScansLoading(),
              error: (error, stack) => _buildRecentScansError(),
            ),
            const SizedBox(height: 24),

            // Eco tip of the day
            ecoTipsAsync.when(
              data: (tips) => tips.isNotEmpty ? _buildEcoTip(context, tips.first) : const SizedBox(),
              loading: () => _buildEcoTipLoading(),
              error: (error, stack) => const SizedBox(),
            ),
            const SizedBox(height: 24),

            // Navigation cards
            _buildNavigationCards(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, EnhancedUserModel user) {
    final timeOfDay = DateTime.now().hour;
    String greeting;
    if (timeOfDay < 12) {
      greeting = 'Good morning';
    } else if (timeOfDay < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting,',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                user.name ?? 'Eco Warrior',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (user.location != null)
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      user.location!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          ),
          child: user.profilePicture != null
              ? ClipOval(
                  child: Image.network(
                    user.profilePicture!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(context),
                  ),
                )
              : _buildDefaultAvatar(context),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar(BuildContext context) {
    return Icon(
      Icons.person,
      size: 30,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildQuickStats(
    BuildContext context,
    Map<String, dynamic> stats,
    AsyncValue<Map<String, dynamic>> streakStatusAsync,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            title: 'Total Points',
            value: stats['totalPoints']?.toString() ?? '0',
            icon: Icons.stars,
            color: Colors.amber,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: streakStatusAsync.when(
            data: (streakData) => _buildStatCard(
              context,
              title: 'Current Streak',
              value: '${streakData['current']} days',
              icon: Icons.local_fire_department,
              color: streakData['isActive'] ? Colors.orange : Colors.grey,
            ),
            loading: () => _buildStatCard(
              context,
              title: 'Current Streak',
              value: '...',
              icon: Icons.local_fire_department,
              color: Colors.grey,
            ),
            error: (error, stack) => _buildStatCard(
              context,
              title: 'Current Streak',
              value: '0 days',
              icon: Icons.local_fire_department,
              color: Colors.grey,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            title: 'Total Scans',
            value: stats['totalScans']?.toString() ?? '0',
            icon: Icons.camera_alt,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickScanButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/scan'),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Ready to scan?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to identify waste and earn points',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentScans(BuildContext context, List<ScanResultModel> scans) {
    if (scans.isEmpty) {
      return _buildEmptyRecentScans(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Scans',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/progress'),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...scans.take(3).map((scan) => _buildRecentScanItem(context, scan)),
      ],
    );
  }

  Widget _buildRecentScanItem(BuildContext context, ScanResultModel scan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getBinColor(scan.binColor).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.delete,
              color: _getBinColor(scan.binColor),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scan.detectedItems.isNotEmpty ? scan.detectedItems.first : 'Unknown item',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${scan.binColor} bin • ${scan.pointsEarned} points',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatTimeAgo(scan.timestamp),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRecentScans(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.camera_alt_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'No scans yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Start scanning to see your activity here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEcoTip(BuildContext context, TipModel tip) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.eco, color: Colors.green[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'Eco Tip',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            tip.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tip.content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationCards(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Explore',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildNavCard(
                context,
                title: 'Leaderboard',
                subtitle: 'See your rank',
                icon: Icons.leaderboard,
                onTap: () => context.push('/leaderboard'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildNavCard(
                context,
                title: 'Progress',
                subtitle: 'Track your impact',
                icon: Icons.trending_up,
                onTap: () => context.push('/progress'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNavCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInPrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_circle_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to WasteSorter',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to start scanning and earning points',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.push('/signin'),
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  // Loading states
  Widget _buildStatsLoading() {
    return Row(
      children: [
        Expanded(child: _buildStatCardSkeleton()),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCardSkeleton()),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCardSkeleton()),
      ],
    );
  }

  Widget _buildStatCardSkeleton() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildStatsError() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text('Failed to load stats'),
    );
  }

  Widget _buildRecentScansLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Scans',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(3, (index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
        )),
      ],
    );
  }

  Widget _buildRecentScansError() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text('Failed to load recent scans'),
    );
  }

  Widget _buildEcoTipLoading() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  // Helper methods
  Color _getBinColor(String binColor) {
    switch (binColor.toLowerCase()) {
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.orange;
      case 'red':
        return Colors.red;
      case 'black':
        return Colors.black87;
      default:
        return Colors.grey;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
