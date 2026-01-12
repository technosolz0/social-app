import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/theme_constants.dart';
import '../../providers/gamification_provider.dart';

class PointsScreen extends ConsumerWidget {
  const PointsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamificationAsync = ref.watch(gamificationProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Points & Level'),
        actions: [
          IconButton(
            onPressed: () => _showPointsInfo(context),
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: gamificationAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Failed to load points data',
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
                  onPressed: () => ref.invalidate(gamificationProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (gamification) => _buildPointsContent(context, gamification),
        ),
      ),
    );
  }

  Widget _buildPointsContent(
    BuildContext context,
    GamificationState gamification,
  ) {
    final currentLevel = gamification.currentLevel;
    final totalPoints = gamification.totalPoints;
    final pointsForCurrentLevel =
        totalPoints % 250; // Assuming 250 points per level
    final pointsNeededForNextLevel = 250 - pointsForCurrentLevel;
    final progressPercentage = pointsForCurrentLevel / 250;

    return ListView(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      children: [
        // Level and Points Overview
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade400, Colors.purple.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
          ),
          child: Column(
            children: [
              // Level Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingLarge,
                  vertical: AppSizes.paddingMedium,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Level $currentLevel',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.paddingLarge),

              // Total Points
              Text(
                '$totalPoints',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                'Total Points',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: AppSizes.paddingLarge),

              // Progress to next level
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress to Level ${currentLevel + 1}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '$pointsForCurrentLevel / 250',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  LinearProgressIndicator(
                    value: progressPercentage,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '$pointsNeededForNextLevel points to next level',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSizes.paddingLarge),

        // Current Streak
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Row(
            children: [
              Icon(
                Icons.local_fire_department,
                color: Colors.orange.shade600,
                size: 32,
              ),
              const SizedBox(width: AppSizes.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${gamification.currentStreak} Day Streak',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                      ),
                    ),
                    Text(
                      'Keep it up! Daily activity maintains your streak.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSizes.paddingLarge),

        // Points Breakdown
        const Text(
          'How to Earn Points',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: AppSizes.paddingMedium),

        _buildPointsCategory(
          icon: Icons.post_add,
          title: 'Posting Content',
          points: '+10-50',
          description: 'Create posts, stories, and reels',
          color: Colors.blue,
        ),

        _buildPointsCategory(
          icon: Icons.favorite,
          title: 'Engagement',
          points: '+1-5',
          description: 'Like, comment, and share content',
          color: Colors.red,
        ),

        _buildPointsCategory(
          icon: Icons.people,
          title: 'Social Activity',
          points: '+5-20',
          description: 'Follow users, join groups, make friends',
          color: Colors.green,
        ),

        _buildPointsCategory(
          icon: Icons.emoji_events,
          title: 'Achievements',
          points: '+25-100',
          description: 'Complete challenges and earn badges',
          color: Colors.purple,
        ),

        _buildPointsCategory(
          icon: Icons.local_fire_department,
          title: 'Streaks',
          points: '+5-50',
          description: 'Maintain daily activity streaks',
          color: Colors.orange,
        ),

        const SizedBox(height: AppSizes.paddingLarge),

        // Level Benefits
        const Text(
          'Level Benefits',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: AppSizes.paddingMedium),

        _buildLevelBenefit(
          level: currentLevel,
          benefit: 'Current Level',
          description: 'You\'re enjoying all current features',
          isCurrent: true,
        ),

        _buildLevelBenefit(
          level: currentLevel + 1,
          benefit: 'Enhanced Visibility',
          description: 'Your posts get higher priority in feeds',
          isCurrent: false,
        ),

        _buildLevelBenefit(
          level: currentLevel + 2,
          benefit: 'Premium Badges',
          description: 'Unlock exclusive badge designs',
          isCurrent: false,
        ),

        _buildLevelBenefit(
          level: currentLevel + 5,
          benefit: 'Early Access',
          description: 'Get early access to new features',
          isCurrent: false,
        ),

        const SizedBox(height: AppSizes.paddingLarge),

        // Quick Actions
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: AppSizes.paddingMedium),

        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                context,
                icon: Icons.flag,
                label: 'View Quests',
                onTap: () => context.push('/quests'),
              ),
            ),
            const SizedBox(width: AppSizes.paddingMedium),
            Expanded(
              child: _buildQuickActionButton(
                context,
                icon: Icons.emoji_events,
                label: 'View Badges',
                onTap: () => context.push('/badges'),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSizes.paddingMedium),

        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                context,
                icon: Icons.leaderboard,
                label: 'Leaderboard',
                onTap: () => context.push('/leaderboard'),
              ),
            ),
            const SizedBox(width: AppSizes.paddingMedium),
            Expanded(
              child: _buildQuickActionButton(
                context,
                icon: Icons.share,
                label: 'Share Progress',
                onTap: () => _shareProgress(context, gamification),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPointsCategory({
    required IconData icon,
    required String title,
    required String points,
    required String description,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),

          const SizedBox(width: AppSizes.paddingMedium),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        points,
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelBenefit({
    required int level,
    required String benefit,
    required String description,
    required bool isCurrent,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: isCurrent ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
        border: Border.all(
          color: isCurrent ? Colors.blue.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCurrent ? Colors.blue.shade100 : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$level',
              style: TextStyle(
                color: isCurrent ? Colors.blue.shade700 : Colors.grey.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(width: AppSizes.paddingMedium),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  benefit,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                    color: isCurrent ? Colors.blue.shade700 : Colors.black,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          if (isCurrent)
            Icon(Icons.check_circle, color: Colors.blue.shade600, size: 20),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMedium),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _shareProgress(BuildContext context, gamification) async {
    final shareText =
        '''
🎉 Check out my progress on Social App!

🏆 Level: ${gamification.currentLevel}
⭐ Total Points: ${gamification.totalPoints}
🔥 Current Streak: ${gamification.currentStreak} days

Join me and start earning points too! Download Social App now.
#SocialApp #Gamification #LevelUp
    '''
            .trim();

    try {
      await Share.share(shareText, subject: 'My Social App Progress');
    } catch (e) {
      // Fallback to snackbar if sharing fails
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPointsInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Points & Levels'),
        content: const Text(
          'Earn points by engaging with the community!\n\n'
          '• Every 250 points = 1 level\n'
          '• Higher levels unlock special features\n'
          '• Maintain daily streaks for bonus points\n'
          '• Complete challenges for extra rewards\n\n'
          'Keep engaging to level up and unlock new abilities!',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
