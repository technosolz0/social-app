import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/theme_constants.dart';
import '../../../data/models/gamification_model.dart';
import '../../providers/gamification_provider.dart';

class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamificationAsync = ref.watch(gamificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Badges'),
        actions: [
          IconButton(
            onPressed: () => _showBadgeInfo(context),
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
                  'Failed to load badges',
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
          data: (gamification) => _buildBadgesContent(context, gamification),
        ),
      ),
    );
  }

  Widget _buildBadgesContent(BuildContext context, GamificationModel gamification) {
    if (gamification.badges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No badges earned yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete challenges to earn your first badge!',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/quests'),
              icon: const Icon(Icons.flag),
              label: const Text('View Challenges'),
            ),
          ],
        ),
      );
    }

    // Group badges by rarity
    final badgesByRarity = <String, List<BadgeModel>>{};
    for (final badge in gamification.badges) {
      badgesByRarity[badge.rarity] = (badgesByRarity[badge.rarity] ?? [])..add(badge);
    }

    return ListView(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      children: [
        // Stats header
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber.shade400, Colors.orange.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.emoji_events,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: AppSizes.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${gamification.badges.length} Badges Earned',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Keep completing challenges!',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSizes.paddingLarge),

        // Badges by rarity
        ..._buildRaritySections(badgesByRarity),
      ],
    );
  }

  List<Widget> _buildRaritySections(Map<String, List<BadgeModel>> badgesByRarity) {
    final rarities = ['legendary', 'epic', 'rare', 'common'];
    final widgets = <Widget>[];

    for (final rarity in rarities) {
      final badges = badgesByRarity[rarity];
      if (badges == null || badges.isEmpty) continue;

      widgets.addAll([
        _buildRarityHeader(rarity, badges.length),
        const SizedBox(height: AppSizes.paddingMedium),
        _buildBadgeGrid(badges),
        const SizedBox(height: AppSizes.paddingLarge),
      ]);
    }

    return widgets;
  }

  Widget _buildRarityHeader(String rarity, int count) {
    final rarityColor = _getRarityColor(rarity);
    final rarityIcon = _getRarityIcon(rarity);

    return Row(
      children: [
        Icon(rarityIcon, color: rarityColor, size: 24),
        const SizedBox(width: AppSizes.paddingSmall),
        Text(
          '${rarity.toUpperCase()} (${count})',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: rarityColor,
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeGrid(List<BadgeModel> badges) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSizes.paddingMedium,
        mainAxisSpacing: AppSizes.paddingMedium,
        childAspectRatio: 0.8,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        return _buildBadgeCard(context, badge);
      },
    );
  }

  Widget _buildBadgeCard(BuildContext context, BadgeModel badge) {
    final rarityColor = _getRarityColor(badge.rarity);

    return GestureDetector(
      onTap: () => _showBadgeDetails(context, badge),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
          border: Border.all(color: rarityColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Badge icon/image
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: rarityColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: rarityColor, width: 2),
              ),
              child: Icon(
                _getBadgeIcon(badge.name),
                color: rarityColor,
                size: 24,
              ),
            ),

            const SizedBox(height: AppSizes.paddingSmall),

            // Badge name
            Text(
              badge.name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            // Earned date
            Text(
              _formatDate(badge.earnedAt),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'legendary':
        return Colors.purple.shade600;
      case 'epic':
        return Colors.blue.shade600;
      case 'rare':
        return Colors.green.shade600;
      case 'common':
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getRarityIcon(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'legendary':
        return Icons.star;
      case 'epic':
        return Icons.diamond;
      case 'rare':
        return Icons.shield;
      case 'common':
      default:
        return Icons.circle;
    }
  }

  IconData _getBadgeIcon(String badgeName) {
    final name = badgeName.toLowerCase();
    if (name.contains('first') || name.contains('welcome')) {
      return Icons.celebration;
    } else if (name.contains('post') || name.contains('share')) {
      return Icons.post_add;
    } else if (name.contains('like') || name.contains('heart')) {
      return Icons.favorite;
    } else if (name.contains('comment')) {
      return Icons.comment;
    } else if (name.contains('friend') || name.contains('follow')) {
      return Icons.people;
    } else if (name.contains('streak') || name.contains('daily')) {
      return Icons.local_fire_department;
    } else if (name.contains('level') || name.contains('points')) {
      return Icons.trending_up;
    } else {
      return Icons.emoji_events;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else {
      return '${(difference.inDays / 365).floor()}y ago';
    }
  }

  void _showBadgeDetails(BuildContext context, BadgeModel badge) {
    final rarityColor = _getRarityColor(badge.rarity);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: rarityColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: rarityColor, width: 3),
              ),
              child: Icon(
                _getBadgeIcon(badge.name),
                color: rarityColor,
                size: 40,
              ),
            ),

            const SizedBox(height: AppSizes.paddingMedium),

            // Badge name
            Text(
              badge.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Rarity badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingSmall,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: rarityColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge.rarity.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: AppSizes.paddingMedium),

            // Earned date
            Text(
              'Earned on ${_formatDateLong(badge.earnedAt)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),

            const SizedBox(height: AppSizes.paddingMedium),

            // Description (placeholder for now)
            Text(
              _getBadgeDescription(badge.name),
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDateLong(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _getBadgeDescription(String badgeName) {
    final name = badgeName.toLowerCase();

    if (name.contains('first') || name.contains('welcome')) {
      return 'Welcome to the community! You\'ve taken your first step.';
    } else if (name.contains('post') || name.contains('share')) {
      return 'You\'re sharing your thoughts with the world!';
    } else if (name.contains('like') || name.contains('heart')) {
      return 'Your content is resonating with others.';
    } else if (name.contains('comment')) {
      return 'You\'re engaging in meaningful conversations.';
    } else if (name.contains('friend') || name.contains('follow')) {
      return 'You\'re building connections in the community.';
    } else if (name.contains('streak') || name.contains('daily')) {
      return 'Consistency is key, and you\'re mastering it!';
    } else if (name.contains('level') || name.contains('points')) {
      return 'Your dedication is paying off!';
    } else {
      return 'Achievement unlocked! Keep up the great work.';
    }
  }

  void _showBadgeInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Badges'),
        content: const Text(
          'Badges are earned by completing challenges and reaching milestones. '
          'They showcase your achievements and dedication to the community.\n\n'
          'Badges have different rarities:\n'
          '• Common: Everyday achievements\n'
          '• Rare: Notable accomplishments\n'
          '• Epic: Significant milestones\n'
          '• Legendary: Extraordinary achievements',
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
