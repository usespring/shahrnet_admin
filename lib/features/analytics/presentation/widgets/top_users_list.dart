import 'package:flutter/material.dart';
import '../../../../core/models/user_activity.dart';

class TopUsersList extends StatelessWidget {
  final List<UserStats> users;
  final String title;

  const TopUsersList({
    super.key,
    required this.users,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const Center(child: Text('داده‌ای موجود نیست'));
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: users.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final user = users[index];
                final rank = index + 1;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: _buildRankBadge(rank),
                  title: Text(
                    user.userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    'کل فعالیت‌ها: ${user.totalActivity}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildActivityBadge(
                        'پست: ${user.totalPosts}',
                        Colors.blue,
                      ),
                      const SizedBox(height: 4),
                      _buildActivityBadge(
                        'لایک: ${user.totalLikes}',
                        Colors.red,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    Color badgeColor;
    IconData? medalIcon;

    if (rank == 1) {
      badgeColor = Colors.amber;
      medalIcon = Icons.emoji_events;
    } else if (rank == 2) {
      badgeColor = Colors.grey;
      medalIcon = Icons.emoji_events;
    } else if (rank == 3) {
      badgeColor = Colors.brown;
      medalIcon = Icons.emoji_events;
    } else {
      badgeColor = Colors.blue;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: medalIcon != null
            ? Icon(medalIcon, color: badgeColor, size: 20)
            : Text(
                '$rank',
                style: TextStyle(
                  color: badgeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }

  Widget _buildActivityBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
