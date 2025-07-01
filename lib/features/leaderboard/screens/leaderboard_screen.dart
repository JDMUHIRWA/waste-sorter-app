import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
        title: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = MediaQuery.of(context).size.width;
            return Text(
              'Leaderboard',
              style: TextStyle(
                fontSize: screenWidth < 400 ? 20 : 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            );
          },
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: true,
        leading: IconButton(
          onPressed: () {
            print('DEBUG: Back button pressed');
            context.go('/home');
          },
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                margin: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth * 0.05,
                ),
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: constraints.maxWidth < 400 ? 14 : 16,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: constraints.maxWidth < 400 ? 14 : 16,
                  ),
                  tabs: const [
                    Tab(text: 'Weekly'),
                    Tab(text: 'Monthly'),
                  ],
                ),
              );
            },
          ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive heights based on screen size
        final screenHeight = MediaQuery.of(context).size.height;
        final podiumHeight = screenHeight * 0.25; // 25% of screen height
        
        return Column(
          children: [
            // Top 3 podium with responsive height
            Container(
              height: podiumHeight.clamp(180.0, 250.0), // Min 180, Max 250
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth * 0.05, // 5% of screen width
                vertical: 16,
              ),
              child: _buildPodium(users.take(3).toList()),
            ),

            // Rest of the rankings
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: ListView.builder(
                  padding: EdgeInsets.all(constraints.maxWidth * 0.05),
                  itemCount: users.length - 3,
                  itemBuilder: (context, index) {
                    final user = users[index + 3];
                    return _buildLeaderboardItem(user);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPodium(List<LeaderboardUser> topThree) {
    if (topThree.length < 3) return const SizedBox();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive sizes
        final isSmallScreen = constraints.maxWidth < 400;
        final avatarSize = isSmallScreen ? 40.0 : 50.0;
        final nameSize = isSmallScreen ? 10.0 : 12.0;
        final pointsSize = isSmallScreen ? 8.0 : 10.0;
        final rankSize = isSmallScreen ? 12.0 : 16.0;
        
        // Calculate podium heights as percentages of available height
        final maxPodiumHeight = constraints.maxHeight * 0.4; // 40% of container
        final firstHeight = maxPodiumHeight;
        final secondHeight = maxPodiumHeight * 0.8;
        final thirdHeight = maxPodiumHeight * 0.6;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 2nd place
            Expanded(
              child: _buildPodiumItem(
                topThree[1], 
                secondHeight, 
                const Color(0xFF6B9B7A),
                avatarSize,
                nameSize,
                pointsSize,
                rankSize,
              ),
            ),
            const SizedBox(width: 8),
            // 1st place
            Expanded(
              child: _buildPodiumItem(
                topThree[0], 
                firstHeight, 
                AppColors.primary,
                avatarSize,
                nameSize,
                pointsSize,
                rankSize,
              ),
            ),
            const SizedBox(width: 8),
            // 3rd place
            Expanded(
              child: _buildPodiumItem(
                topThree[2], 
                thirdHeight, 
                AppColors.textSecondary,
                avatarSize,
                nameSize,
                pointsSize,
                rankSize,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPodiumItem(
    LeaderboardUser user, 
    double height, 
    Color color,
    double avatarSize,
    double nameSize,
    double pointsSize,
    double rankSize,
  ) {
    return GestureDetector(
      onTap: () {
        print('Tapped on ${user.name}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tapped on ${user.name} - ${user.points} points'),
            duration: const Duration(seconds: 1),
            backgroundColor: AppColors.primary,
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Avatar
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Center(
              child: Text(
                user.avatar,
                style: TextStyle(fontSize: avatarSize * 0.4),
              ),
            ),
          ),
          SizedBox(height: avatarSize * 0.16),

          // Name - with overflow protection
          Flexible(
            child: Text(
              user.name,
              style: TextStyle(
                fontSize: nameSize,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: avatarSize * 0.08),

          // Points
          Text(
            '${user.points}',
            style: TextStyle(
              fontSize: pointsSize,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: avatarSize * 0.16),

          // Podium
          Container(
            height: height,
            decoration: BoxDecoration(
              color: color,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Center(
              child: Text(
                '#${user.rank}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: rankSize,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(LeaderboardUser user) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 400;
        final rankSize = isSmallScreen ? 35.0 : 40.0;
        final avatarSize = isSmallScreen ? 45.0 : 50.0;
        final nameSize = isSmallScreen ? 14.0 : 16.0;
        final pointsSize = isSmallScreen ? 12.0 : 14.0;
        final spacing = isSmallScreen ? 12.0 : 16.0;
        
        return GestureDetector(
          onTap: () {
            print('Tapped on leaderboard item: ${user.name}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    '${user.name} is ranked #${user.rank} with ${user.points} points'),
                duration: const Duration(seconds: 1),
                backgroundColor: user.isCurrentUser
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(spacing),
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
                  width: rankSize,
                  height: rankSize,
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
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: spacing),

                // Avatar
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      user.avatar,
                      style: TextStyle(fontSize: avatarSize * 0.4),
                    ),
                  ),
                ),
                SizedBox(width: spacing),

                // Name and points
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: TextStyle(
                          fontSize: nameSize,
                          fontWeight: FontWeight.bold,
                          color: user.isCurrentUser
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${user.points} points',
                        style: TextStyle(
                          fontSize: pointsSize,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Badge for current user
                if (user.isCurrentUser)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 6 : 8, 
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'You',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 10 : 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
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
