import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/theme_constants.dart';
import '../../providers/gamification_provider.dart';

class QuestsScreen extends ConsumerStatefulWidget {
  const QuestsScreen({super.key});

  @override
  ConsumerState<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends ConsumerState<QuestsScreen> {
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final questsAsync = ref.watch(questsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Challenges & Quests'),
        actions: [
          IconButton(
            onPressed: () => _showQuestsInfo(context),
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Category Filter
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryChip('All', 'all'),
                    const SizedBox(width: 8),
                    _buildCategoryChip('Daily', 'daily'),
                    const SizedBox(width: 8),
                    _buildCategoryChip('Weekly', 'weekly'),
                    const SizedBox(width: 8),
                    _buildCategoryChip('Social', 'social'),
                    const SizedBox(width: 8),
                    _buildCategoryChip('Creative', 'creative'),
                    const SizedBox(width: 8),
                    _buildCategoryChip('Achievement', 'achievement'),
                  ],
                ),
              ),
            ),

            // Quests List
            Expanded(
              child: questsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load quests',
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
                        onPressed: () => ref.invalidate(questsProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (quests) => _buildQuestsContent(context, quests),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, String category) {
    final isSelected = _selectedCategory == category;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = category;
        });
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: Colors.blue.shade100,
      checkmarkColor: Colors.blue.shade700,
    );
  }

  Widget _buildQuestsContent(
    BuildContext context,
    List<Map<String, dynamic>> quests,
  ) {
    // Filter quests by category
    final filteredQuests = _selectedCategory == 'all'
        ? quests
        : quests
              .where((quest) => quest['category'] == _selectedCategory)
              .toList();

    if (filteredQuests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flag_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No quests available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new challenges!',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      itemCount: filteredQuests.length,
      itemBuilder: (context, index) {
        final quest = filteredQuests[index];
        return _buildQuestCard(context, quest);
      },
    );
  }

  Widget _buildQuestCard(BuildContext context, Map<String, dynamic> quest) {
    final isCompleted = quest['completed'] == true;
    final progress = quest['progress'] ?? 0;
    final target = quest['target'] ?? 1;
    final progressPercentage = target > 0 ? progress / target : 0.0;
    final points = quest['points'] ?? 0;
    final category = quest['category'] ?? 'general';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
        border: Border.all(
          color: isCompleted ? Colors.green.shade200 : Colors.grey.shade200,
        ),
        boxShadow: isCompleted
            ? [
                BoxShadow(
                  color: Colors.green.shade100,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green.shade100 : Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSizes.borderRadiusMedium - 1),
              ),
            ),
            child: Row(
              children: [
                // Quest Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(category).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getCategoryIcon(category),
                    color: _getCategoryColor(category),
                    size: 20,
                  ),
                ),

                const SizedBox(width: AppSizes.paddingMedium),

                // Quest Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quest['title'] ?? 'Quest',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isCompleted
                              ? Colors.green.shade800
                              : Colors.black,
                        ),
                      ),
                      Text(
                        _getCategoryName(category),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                // Points Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber.shade700, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '$points',
                        style: TextStyle(
                          color: Colors.amber.shade800,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                Text(
                  quest['description'] ??
                      'Complete this challenge to earn points!',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),

                const SizedBox(height: AppSizes.paddingMedium),

                // Progress Bar (if not completed)
                if (!isCompleted) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        '$progress / $target',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  LinearProgressIndicator(
                    value: progressPercentage,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getCategoryColor(category),
                    ),
                  ),

                  const SizedBox(height: AppSizes.paddingSmall),

                  Text(
                    '${(progressPercentage * 100).round()}% complete',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ] else ...[
                  // Completed Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green.shade700,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Completed!',
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: AppSizes.paddingMedium),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isCompleted
                        ? null
                        : () => _claimQuestReward(context, quest),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCompleted
                          ? Colors.green.shade100
                          : _getCategoryColor(category),
                      foregroundColor: isCompleted
                          ? Colors.green.shade800
                          : Colors.white,
                      disabledBackgroundColor: Colors.green.shade100,
                      disabledForegroundColor: Colors.green.shade800,
                    ),
                    child: Text(isCompleted ? 'Completed' : 'Claim Reward'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'daily':
        return Colors.blue.shade600;
      case 'weekly':
        return Colors.purple.shade600;
      case 'social':
        return Colors.green.shade600;
      case 'creative':
        return Colors.orange.shade600;
      case 'achievement':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'daily':
        return Icons.today;
      case 'weekly':
        return Icons.calendar_view_week;
      case 'social':
        return Icons.people;
      case 'creative':
        return Icons.brush;
      case 'achievement':
        return Icons.emoji_events;
      default:
        return Icons.flag;
    }
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'daily':
        return 'Daily Challenge';
      case 'weekly':
        return 'Weekly Challenge';
      case 'social':
        return 'Social Quest';
      case 'creative':
        return 'Creative Task';
      case 'achievement':
        return 'Achievement';
      default:
        return 'Quest';
    }
  }

  void _claimQuestReward(BuildContext context, Map<String, dynamic> quest) {
    final points = quest['points'] ?? 0;

    // In a real app, this would call an API to claim the reward
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.celebration, color: Colors.amber.shade600, size: 48),

            const SizedBox(height: AppSizes.paddingMedium),

            Text(
              'Quest Completed!',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              'You earned $points points!',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSizes.paddingMedium),

            // Points animation would go here
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                shape: BoxShape.circle,
              ),
              child: Text(
                '+$points',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade800,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );

    // Update local state
    ref
        .read(gamificationProvider.notifier)
        .awardPoints('quest_completed', points);
  }

  void _showQuestsInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Challenges & Quests'),
        content: const Text(
          'Complete challenges to earn points and unlock achievements!\n\n'
          '• Daily challenges reset every day\n'
          '• Weekly challenges reset every Monday\n'
          '• Social quests help you connect with others\n'
          '• Creative tasks encourage self-expression\n'
          '• Achievements are special milestones\n\n'
          'Stay active and keep completing quests to level up!',
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
