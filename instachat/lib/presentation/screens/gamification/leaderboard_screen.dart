import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/theme_constants.dart';
import '../../../data/models/user_model.dart';
import '../../providers/gamification_provider.dart';
import '../../providers/auth_provider.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimeframe = 'all_time';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leaderboardAsync = ref.watch(leaderboardProvider);
    final currentUser = ref.read(authNotifierProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Time'),
            Tab(text: 'Monthly'),
            Tab(text: 'Weekly'),
          ],
          onTap: (index) {
            setState(() {
              _selectedTimeframe = ['all_time', 'monthly', 'weekly'][index];
            });
          },
        ),
        actions: [
          IconButton(
            onPressed: () => _showLeaderboardInfo(context),
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: leaderboardAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Failed to load leaderboard',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(leaderboardProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (leaderboard) => _buildLeaderboardContent(context, leaderboard, currentUser),
        ),
      ),
    );
  }

  Widget _buildLeaderboardContent(
    BuildContext context,
    List<Map<String, dynamic>> leaderboard,
    UserModel? currentUser,
  ) {
    if (leaderboard.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.leaderboard_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No data available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for leaderboard updates!',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Find current user's rank
    final currentUserRank = leaderboard.indexWhere(
      (entry) => entry['user_id'] == currentUser?.id,
    );

    return Column(
      children: [
        // Current user rank highlight (if in top 10 or current user)
        if (currentUserRank >= 0 && currentUserRank < 10)
          _buildCurrentUserHighlight(leaderboard[currentUserRank], currentUserRank + 1)
        else if (currentUserRank >= 10)
          _buildCurrentUserRankCard(leaderboard[currentUserRank], currentUserRank + 1),

        // Top 3 podium
        if (leaderboard.length >= 3)
          _buildTopThreePodium(context, leaderboard.sublist(0, 3)),

        // Rest of leaderboard
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            itemCount: leaderboard.length > 3 ? leaderboard.length - 3 : 0,
            itemBuilder: (context, index) {
              final actualIndex = index + 3;
              final entry = leaderboard[actualIndex];
              final isCurrentUser = entry['user_id'] == currentUser?.id;

              return _buildLeaderboardEntry(
                context,
                entry,
                actualIndex + 1,
                isCurrentUser,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentUserHighlight(Map<String, dynamic> userData, int rank) {
    return Container(
      margin: const EdgeInsets.all(AppSizes.paddingMedium),
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: Text(
              '#$rank',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userData['username'] ?? 'You',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${userData['points'] ?? 0} points',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.emoji_events,
            color: Colors.white,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentUserRankCard(Map<String, dynamic> userData, int rank) {
    return Container(
      margin: const EdgeInsets.all(AppSizes.paddingMedium),
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey.shade300,
            child: Text(
              '$rank',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userData['username'] ?? 'You',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${userData['points'] ?? 0} points',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // Scroll to user's position (placeholder)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Scroll to your position')),
              );
            },
            icon: const Icon(Icons.my_location),
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildTopThreePodium(BuildContext context, List<Map<String, dynamic>> topThree) {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(vertical: AppSizes.paddingMedium),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place
          if (topThree.length >= 2)
            _buildPodiumPosition(
              context,
              topThree[1],
              2,
              height: 140,
              color: Colors.grey.shade300,
            ),

          // 1st place
          if (topThree.isNotEmpty)
            _buildPodiumPosition(
              context,
              topThree[0],
              1,
              height: 180,
              color: Colors.amber.shade400,
              isWinner: true,
            ),

          // 3rd place
          if (topThree.length >= 3)
            _buildPodiumPosition(
              context,
              topThree[2],
              3,
              height: 120,
              color: Colors.orange.shade300,
            ),
        ],
      ),
    );
  }

  Widget _buildPodiumPosition(
    BuildContext context,
    Map<String, dynamic> userData,
    int position, {
    required double height,
    required Color color,
    bool isWinner = false,
  }) {
    return Container(
      width: 80,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: color,
            child: Text(
              userData['username']?.substring(0, 1).toUpperCase() ?? '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Name
          Text(
            userData['username'] ?? 'Unknown',
            style: TextStyle(
              fontSize: 12,
              fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          // Points
          Text(
            '${userData['points'] ?? 0}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),

          const SizedBox(height: 8),

          // Podium base
          Container(
            height: height,
            width: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                '$position',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardEntry(
    BuildContext context,
    Map<String, dynamic> entry,
    int rank,
    bool isCurrentUser,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
        border: Border.all(
          color: isCurrentUser ? Colors.blue.shade200 : Colors.grey.shade200,
        ),
        boxShadow: isCurrentUser
            ? [
                BoxShadow(
                  color: Colors.blue.shade100,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getRankColor(rank),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          const SizedBox(width: AppSizes.paddingMedium),

          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey.shade300,
            child: Text(
              entry['username']?.substring(0, 1).toUpperCase() ?? '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: AppSizes.paddingMedium),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry['username'] ?? 'Unknown User',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                    color: isCurrentUser ? Colors.blue.shade700 : Colors.black,
                  ),
                ),
                Text(
                  '${entry['points'] ?? 0} points',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Trophy icon for top ranks
          if (rank <= 3)
            Icon(
              Icons.emoji_events,
              color: _getRankColor(rank),
              size: 24,
            ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber.shade600;
      case 2:
        return Colors.grey.shade500;
      case 3:
        return Colors.orange.shade600;
      default:
        return Colors.blue.shade500;
    }
  }

  void _showLeaderboardInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leaderboard'),
        content: const Text(
          'Compete with other users and climb the ranks!\n\n'
          '• Earn points by posting, commenting, and engaging with content\n'
          '• Complete daily challenges for bonus points\n'
          '• Maintain streaks for extra rewards\n\n'
          'The leaderboard updates regularly. Keep engaging to stay on top!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
