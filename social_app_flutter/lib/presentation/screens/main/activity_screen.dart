import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/constants/theme_constants.dart';
import '../../providers/activity_tracker_provider.dart';

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(activityTrackerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Activity',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showActivityMenu(context);
            },
          ),
        ],
      ),
      body: activities.isEmpty
          ? _buildEmptyState()
          : _buildActivityList(activities),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: AppSizes.paddingLarge),
          Text(
            'No activity yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          Text(
            'Your activity will appear here',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList(List<dynamic> activities) {
    // Group activities by date
    final groupedActivities = _groupActivitiesByDate(activities);

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      itemCount: groupedActivities.length,
      itemBuilder: (context, index) {
        final entry = groupedActivities.entries.elementAt(index);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateHeader(entry.key),
            ...entry.value.map((activity) => _buildActivityItem(activity)),
            if (index < groupedActivities.length - 1)
              const SizedBox(height: AppSizes.paddingLarge),
          ],
        );
      },
    );
  }

  Map<String, List<dynamic>> _groupActivitiesByDate(List<dynamic> activities) {
    final grouped = <String, List<dynamic>>{};

    for (final activity in activities) {
      final date = _formatActivityDate(activity.timestamp);
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(activity);
    }

    return grouped;
  }

  String _formatActivityDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  Widget _buildDateHeader(String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMedium),
      child: Text(
        date,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildActivityItem(dynamic activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          _buildActivityIcon(activity.activityType),
          const SizedBox(width: AppSizes.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getActivityText(activity),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeago.format(activity.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (_hasAction(activity.activityType))
            IconButton(
              icon: const Icon(Icons.chevron_right, size: 20),
              onPressed: () {
                // TODO: Navigate to related content
              },
            ),
        ],
      ),
    );
  }

  Widget _buildActivityIcon(String activityType) {
    IconData icon;
    Color color;

    switch (activityType) {
      case 'post_view':
        icon = Icons.visibility;
        color = Colors.blue;
        break;
      case 'post_like':
        icon = Icons.favorite;
        color = Colors.red;
        break;
      case 'story_view':
        icon = Icons.camera_alt;
        color = Colors.purple;
        break;
      case 'profile_view':
        icon = Icons.person;
        color = Colors.green;
        break;
      case 'search':
        icon = Icons.search;
        color = Colors.orange;
        break;
      case 'message_sent':
        icon = Icons.message;
        color = Colors.teal;
        break;
      case 'login':
        icon = Icons.login;
        color = Colors.indigo;
        break;
      case 'video_watch':
        icon = Icons.play_circle;
        color = Colors.pink;
        break;
      case 'follow':
        icon = Icons.person_add;
        color = Colors.cyan;
        break;
      case 'comment':
        icon = Icons.comment;
        color = Colors.amber;
        break;
      case 'share':
        icon = Icons.share;
        color = Colors.brown;
        break;
      default:
        icon = Icons.notifications;
        color = Colors.grey;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
      ),
      child: Icon(
        icon,
        color: color,
        size: 20,
      ),
    );
  }

  String _getActivityText(dynamic activity) {
    switch (activity.activityType) {
      case 'post_view':
        return 'You viewed a post';
      case 'post_like':
        return 'You liked a post';
      case 'story_view':
        return 'You viewed a story';
      case 'profile_view':
        return 'You viewed a profile';
      case 'search':
        return 'You searched for "${activity.metadata?['query'] ?? 'something'}"';
      case 'message_sent':
        return 'You sent a message';
      case 'login':
        return 'You logged in';
      case 'video_watch':
        return 'You watched a video';
      case 'follow':
        return 'You followed someone';
      case 'comment':
        return 'You commented on a post';
      case 'share':
        return 'You shared a post';
      default:
        return 'Activity: ${activity.activityType}';
    }
  }

  bool _hasAction(String activityType) {
    // Some activities might have actions (like viewing the related post)
    return ['post_view', 'post_like', 'story_view', 'profile_view', 'comment', 'share'].contains(activityType);
  }

  void _showActivityMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.clear_all),
            title: const Text('Clear all activity'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Clear all activities
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Activity settings'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
    );
  }
}
