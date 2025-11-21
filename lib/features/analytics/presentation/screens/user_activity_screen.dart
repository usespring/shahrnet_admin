import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../../../core/models/user_activity.dart';
import '../../domain/analytics_providers.dart';
import '../widgets/activity_trend_chart.dart';

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
            _getInitial(user.userName),
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
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                _buildCompactStat('${user.totalActivity}', 'کل فعالیت‌ها'),
                if (user.totalMessages > 0)
                  _buildCompactStat('${user.totalMessages}', 'پیام'),
                if (user.totalCourses > 0)
                  _buildCompactStat('${user.totalCourses}', 'دوره'),
                if (user.totalCalls > 0)
                  _buildCompactStat('${user.totalCalls}', 'تماس'),
              ],
            ),
            if (user.lastActiveAt != null) ...[
              const SizedBox(height: 4),
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
          _buildUserDetailWithTrends(user),
        ],
      ),
    );
  }

  Widget _buildUserDetailWithTrends(UserStats user) {
    final trendsAsync = ref.watch(userActivityTrendsProvider(user.userId));

    return trendsAsync.when(
      data: (trends) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline Activities Section
              Text(
                'فعالیت‌های تایم‌لاین',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              _buildActivityRow(
                'پست‌ها',
                user.totalPosts,
                Icons.article,
                Colors.blue,
              ),
              const SizedBox(height: 8),
              if (trends['timeline_posts'] != null)
                ActivityTrendChart(
                  title: 'روند نوشتن پست در طول زمان',
                  data: trends['timeline_posts']!,
                  color: Colors.blue,
                  icon: Icons.article,
                ),
              const SizedBox(height: 8),
              _buildActivityRow(
                'لایک‌ها',
                user.totalLikes,
                Icons.favorite,
                Colors.red,
              ),
              const SizedBox(height: 8),
              if (trends['timeline_likes'] != null)
                ActivityTrendChart(
                  title: 'روند پسندیدن پست‌ها در طول زمان',
                  data: trends['timeline_likes']!,
                  color: Colors.red,
                  icon: Icons.favorite,
                ),
              const SizedBox(height: 8),
              _buildActivityRow(
                'نظرات',
                user.totalComments,
                Icons.comment,
                Colors.green,
              ),
              const SizedBox(height: 8),
              if (trends['timeline_comments'] != null)
                ActivityTrendChart(
                  title: 'روند نظر دادن در طول زمان',
                  data: trends['timeline_comments']!,
                  color: Colors.green,
                  icon: Icons.comment,
                ),
              const SizedBox(height: 8),
              _buildActivityRow(
                'بازدیدها',
                user.totalPostViews,
                Icons.visibility,
                Colors.orange,
              ),
              const SizedBox(height: 8),
              if (trends['timeline_views'] != null)
                ActivityTrendChart(
                  title: 'روند بازدید پست‌ها در طول زمان',
                  data: trends['timeline_views']!,
                  color: Colors.orange,
                  icon: Icons.visibility,
                ),
              const SizedBox(height: 8),
              _buildActivityRow(
                'نظرسنجی‌ها',
                user.totalSurveys,
                Icons.poll,
                Colors.purple,
              ),
              const SizedBox(height: 8),
              if (trends['timeline_surveys'] != null)
                ActivityTrendChart(
                  title: 'روند شرکت در نظرسنجی در طول زمان',
                  data: trends['timeline_surveys']!,
                  color: Colors.purple,
                  icon: Icons.poll,
                ),

              const Divider(height: 32),

              // Conversation Activities Section
              Text(
                'فعالیت‌های گفتگو',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              _buildActivityRow(
                'پیام‌های مستقیم',
                user.totalDirectMessages ?? 0,
                Icons.person,
                Colors.blue,
              ),
              const SizedBox(height: 8),
              if (trends['conversation_direct'] != null)
                ActivityTrendChart(
                  title: 'روند پیام‌های مستقیم در طول زمان',
                  data: trends['conversation_direct']!,
                  color: Colors.blue,
                  icon: Icons.person,
                ),
              const SizedBox(height: 8),
              _buildActivityRow(
                'پیام‌های گروهی',
                user.totalGroupMessages ?? 0,
                Icons.group,
                Colors.green,
              ),
              const SizedBox(height: 8),
              if (trends['conversation_group'] != null)
                ActivityTrendChart(
                  title: 'روند پیام‌های گروهی در طول زمان',
                  data: trends['conversation_group']!,
                  color: Colors.green,
                  icon: Icons.group,
                ),
              const SizedBox(height: 8),
              _buildActivityRow(
                'تماس‌های صوتی',
                user.totalAudioCalls ?? 0,
                Icons.phone,
                Colors.orange,
              ),
              const SizedBox(height: 8),
              if (trends['conversation_audio'] != null)
                ActivityTrendChart(
                  title: 'روند تماس‌های صوتی در طول زمان',
                  data: trends['conversation_audio']!,
                  color: Colors.orange,
                  icon: Icons.phone,
                ),
              const SizedBox(height: 8),
              _buildActivityRow(
                'ویدئو کنفرانس',
                user.totalVideoConferences ?? 0,
                Icons.videocam,
                Colors.red,
              ),
              const SizedBox(height: 8),
              if (trends['conversation_video'] != null)
                ActivityTrendChart(
                  title: 'روند ویدئو کنفرانس در طول زمان',
                  data: trends['conversation_video']!,
                  color: Colors.red,
                  icon: Icons.videocam,
                ),

              const Divider(height: 32),

              // Learning Activities Section
              Text(
                'فعالیت‌های آموزشی',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              _buildActivityRow(
                'دوره‌های تکمیل شده',
                user.totalCoursesCompleted ?? 0,
                Icons.check_circle,
                Colors.green,
              ),
              const SizedBox(height: 8),
              if (trends['learning_completed'] != null)
                ActivityTrendChart(
                  title: 'روند تکمیل دوره‌ها در طول زمان',
                  data: trends['learning_completed']!,
                  color: Colors.green,
                  icon: Icons.check_circle,
                ),
              const SizedBox(height: 8),
              _buildActivityRow(
                'دوره‌های در حال اجرا',
                user.totalCoursesInProgress ?? 0,
                Icons.play_circle,
                Colors.blue,
              ),
              const SizedBox(height: 8),
              if (trends['learning_inprogress'] != null)
                ActivityTrendChart(
                  title: 'روند دوره‌های در حال اجرا در طول زمان',
                  data: trends['learning_inprogress']!,
                  color: Colors.blue,
                  icon: Icons.play_circle,
                ),
              const SizedBox(height: 8),
              _buildScoreRow(
                'میانگین نمره',
                user.averageCourseScore ?? 0.0,
                Icons.grade,
                _getScoreColor(user.averageCourseScore ?? 0.0),
              ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('خطا در بارگذاری نمودارها: $error'),
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

  Widget _buildScoreRow(
    String label,
    double score,
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
            '${score.toStringAsFixed(1)}/۱۰۰',
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

  String _getInitial(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return '?';
    }
    return trimmed.substring(0, 1);
  }

  Color _getScoreColor(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 75) return Colors.blue;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  Widget _buildCompactStat(String value, String label) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 12),
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          TextSpan(
            text: ' $label',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
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
