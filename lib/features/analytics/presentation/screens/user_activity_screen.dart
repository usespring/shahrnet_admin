import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../../../core/models/user_activity.dart';
import '../../domain/analytics_providers.dart';

class UserActivityScreen extends ConsumerStatefulWidget {
  const UserActivityScreen({super.key});

  @override
  ConsumerState<UserActivityScreen> createState() => _UserActivityScreenState();
}

class _UserActivityScreenState extends ConsumerState<UserActivityScreen> {
  ActivityType? _selectedActivityType;
  String? _selectedSection;

  @override
  Widget build(BuildContext context) {
    final userStatsAsync = ref.watch(userStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('جزئیات فعالیت کاربران'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: userStatsAsync.when(
        data: (userStats) {
          final sortedUsers = userStats.toList()
            ..sort((a, b) => b.totalActivity.compareTo(a.totalActivity));

          return Column(
            children: [
              _buildFilterChips(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedUsers.length,
                  itemBuilder: (context, index) {
                    return _buildUserCard(sortedUsers[index]);
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('خطا در بارگذاری: $error'),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          if (_selectedActivityType != null)
            FilterChip(
              label: Text(_getActivityTypeName(_selectedActivityType!)),
              selected: true,
              onSelected: (_) {
                setState(() {
                  _selectedActivityType = null;
                });
              },
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                setState(() {
                  _selectedActivityType = null;
                });
              },
            ),
          if (_selectedSection != null)
            FilterChip(
              label: Text(_selectedSection!),
              selected: true,
              onSelected: (_) {
                setState(() {
                  _selectedSection = null;
                });
              },
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                setState(() {
                  _selectedSection = null;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserStats user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(
            user.userName.substring(0, 1),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        title: Text(
          user.userName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'کل فعالیت‌ها: ${user.totalActivity}',
              style: const TextStyle(fontSize: 12),
            ),
            if (user.lastActiveAt != null) ...[
              const SizedBox(height: 2),
              Text(
                'آخرین فعالیت: ${_formatDate(user.lastActiveAt!)}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildActivityRow(
                  'پست‌ها',
                  user.totalPosts,
                  Icons.article,
                  Colors.blue,
                ),
                const SizedBox(height: 8),
                _buildActivityRow(
                  'لایک‌ها',
                  user.totalLikes,
                  Icons.favorite,
                  Colors.red,
                ),
                const SizedBox(height: 8),
                _buildActivityRow(
                  'نظرات',
                  user.totalComments,
                  Icons.comment,
                  Colors.green,
                ),
                const SizedBox(height: 8),
                _buildActivityRow(
                  'بازدیدها',
                  user.totalPostViews,
                  Icons.visibility,
                  Colors.orange,
                ),
                const SizedBox(height: 8),
                _buildActivityRow(
                  'نظرسنجی‌ها',
                  user.totalSurveys,
                  Icons.poll,
                  Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityRow(
    String label,
    int count,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final shamsiDate = Jalali.fromDateTime(date);
    return '${shamsiDate.year}/${shamsiDate.month}/${shamsiDate.day}';
  }

  String _getActivityTypeName(ActivityType type) {
    switch (type) {
      case ActivityType.postComposed:
        return 'نوشتن پست';
      case ActivityType.postLiked:
        return 'پسندیدن';
      case ActivityType.postCommented:
        return 'نظر دادن';
      case ActivityType.postVisited:
        return 'بازدید';
      case ActivityType.surveyParticipated:
        return 'نظرسنجی';
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('فیلتر فعالیت‌ها'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('نوع فعالیت:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ActivityType.values.map((type) {
                  return ChoiceChip(
                    label: Text(_getActivityTypeName(type)),
                    selected: _selectedActivityType == type,
                    onSelected: (selected) {
                      setState(() {
                        _selectedActivityType = selected ? type : null;
                      });
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedActivityType = null;
                  _selectedSection = null;
                });
                Navigator.pop(context);
              },
              child: const Text('پاک کردن فیلترها'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('بستن'),
            ),
          ],
        );
      },
    );
  }
}
