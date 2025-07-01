import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data for leaderboard
  final List<LeaderboardUser> weeklyRankings = [
    LeaderboardUser(rank: 1, name: "Alex Chen", points: 2450, avatar: "🌟"),
    LeaderboardUser(rank: 2, name: "Sarah Johnson", points: 2320, avatar: "🏆"),
    LeaderboardUser(rank: 3, name: "Mike Wilson", points: 2180, avatar: "⭐"),
    LeaderboardUser(rank: 4, name: "Emma Davis", points: 1950, avatar: "🌍"),
    LeaderboardUser(
        rank: 5, name: "You", points: 1820, avatar: "👤", isCurrentUser: true),
    LeaderboardUser(rank: 6, name: "James Brown", points: 1750, avatar: "♻️"),
    LeaderboardUser(rank: 7, name: "Lisa Garcia", points: 1680, avatar: "🌱"),
    LeaderboardUser(rank: 8, name: "David Lee", points: 1590, avatar: "🌿"),
  ];

  final List<LeaderboardUser> monthlyRankings = [
    LeaderboardUser(rank: 1, name: "Sarah Johnson", points: 8950, avatar: "🏆"),
    LeaderboardUser(rank: 2, name: "Alex Chen", points: 8720, avatar: "🌟"),
    LeaderboardUser(
        rank: 3, name: "You", points: 7640, avatar: "👤", isCurrentUser: true),
    LeaderboardUser(rank: 4, name: "Emma Davis", points: 7320, avatar: "🌍"),
    LeaderboardUser(rank: 5, name: "Mike Wilson", points: 6890, avatar: "⭐"),
    LeaderboardUser(rank: 6, name: "James Brown", points: 6450, avatar: "♻️"),
    LeaderboardUser(rank: 7, name: "Lisa Garcia", points: 6120, avatar: "🌱"),
    LeaderboardUser(rank: 8, name: "David Lee", points: 5780, avatar: "🌿"),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Leaderboard',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 16,
          ),
          tabs: const [
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLeaderboardList(weeklyRankings),
          _buildLeaderboardList(monthlyRankings),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList(List<LeaderboardUser> users) {
    return Column(
      children: [
        // Top 3 podium
        Container(
          height: 180, // Reduced height to prevent overflow
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: _buildPodium(users.take(3).toList()),
        ),

        // Rest of the rankings
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: users.length - 3,
            itemBuilder: (context, index) {
              final user = users[index + 3];
              return _buildLeaderboardItem(user);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPodium(List<LeaderboardUser> topThree) {
    if (topThree.length < 3) return const SizedBox();

    return SizedBox(
      height: 160, // Reduced height to fit better
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place
          _buildPodiumItem(topThree[1], 70, AppColors.success),
          // 1st place
          _buildPodiumItem(topThree[0], 90, AppColors.primary),
          // 3rd place
          _buildPodiumItem(topThree[2], 50, AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(LeaderboardUser user, double height, Color color) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Center(
              child: Text(
                user.avatar,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          Text(
            '${user.points}',
            style: TextStyle(
              fontSize: 7,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: 50,
            height: height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Center(
              child: Text(
                '#${user.rank}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(LeaderboardUser user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: user.isCurrentUser
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: user.isCurrentUser
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: user.isCurrentUser
                  ? AppColors.primary
                  : AppColors.textSecondary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#${user.rank}',
                style: TextStyle(
                  color: user.isCurrentUser
                      ? Colors.white
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user.avatar,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Name and points
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: user.isCurrentUser
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${user.points} points',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Badge for current user
          if (user.isCurrentUser)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'You',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class LeaderboardUser {
  final int rank;
  final String name;
  final int points;
  final String avatar;
  final bool isCurrentUser;

  LeaderboardUser({
    required this.rank,
    required this.name,
    required this.points,
    required this.avatar,
    this.isCurrentUser = false,
  });
}
