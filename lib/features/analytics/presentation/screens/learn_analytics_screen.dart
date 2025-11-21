import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../domain/learn_analytics_providers.dart';
import '../widgets/stats_card.dart';
import '../widgets/line_chart_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/analytics_section_header.dart';
import '../../../../core/models/learn_analytics.dart';
import '../../../../core/models/analytics_data.dart';

class LearnAnalyticsScreen extends ConsumerWidget {
  const LearnAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(learnAnalyticsProvider);

    return analyticsAsync.when(
      data: (analytics) {
        if (analytics.totalStartedCourses == 0) {
          return EmptyStateWidget(
            message: 'هیچ فعالیت آموزشی در این بازه زمانی وجود ندارد',
            subtitle: 'بازه زمانی دیگری را انتخاب کنید',
            icon: Icons.school,
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummarySection(context, analytics),
              const SizedBox(height: 24),
              _buildCompletionTrendChart(context, analytics),
              const SizedBox(height: 24),
              _buildRecentlyCompletedCourses(context, analytics),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => EmptyStateWidget(
        message: 'خطا در بارگذاری داده‌ها',
        subtitle: error.toString(),
        icon: Icons.error_outline,
        onRetry: () {
          ref.invalidate(learnAnalyticsProvider);
        },
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, LearnAnalytics analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AnalyticsSectionHeader(
          title: 'خلاصه فعالیت‌های آموزشی',
          subtitle: 'آمار کلی پیشرفت یادگیری',
          icon: Icons.summarize,
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            int crossAxisCount = 4;
            double childAspectRatio = 1.5;

            if (width < 768) {
              crossAxisCount = 3;
              childAspectRatio = width < 480 ? 1.2 : 1.4;
            }

            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: childAspectRatio,
              children: [
                StatsCard(
                  title: 'دوره‌های تکمیل شده',
                  value: analytics.completedCourses.toString(),
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
                StatsCard(
                  title: 'دوره‌های در حال اجرا',
                  value: analytics.inProgressCourses.toString(),
                  icon: Icons.play_circle,
                  color: Colors.blue,
                ),
                StatsCard(
                  title: 'میانگین نمره',
                  value: analytics.averageScore.toStringAsFixed(1),
                  icon: Icons.grade,
                  color: Colors.amber,
                  subtitle: 'از ۱۰۰',
                ),
                StatsCard(
                  title: 'نرخ تکمیل',
                  value: '${analytics.completionRate.toStringAsFixed(1)}%',
                  icon: Icons.trending_up,
                  color: Colors.purple,
                  subtitle: 'دوره‌های شروع شده',
                ),
                StatsCard(
                  title: 'زمان یادگیری',
                  value: '${(analytics.totalLearningTimeMinutes / 60).toStringAsFixed(1)}',
                  icon: Icons.timer,
                  color: Colors.orange,
                  subtitle: 'ساعت',
                ),
                StatsCard(
                  title: 'کل دوره‌ها',
                  value: analytics.totalStartedCourses.toString(),
                  icon: Icons.library_books,
                  color: Colors.teal,
                  subtitle: 'شروع شده',
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildCompletionTrendChart(BuildContext context, LearnAnalytics analytics) {
    if (analytics.completionTrend.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AnalyticsSectionHeader(
          title: 'روند تکمیل دوره‌ها',
          subtitle: 'نمودار تکمیل دوره‌ها در طول زمان',
          icon: Icons.show_chart,
        ),
        LineChartWidget(
          data: analytics.completionTrend
              .map((point) => TimeSeriesData(
                    date: point.date,
                    value: point.value,
                  ))
              .toList(),
          title: 'تعداد دوره‌های تکمیل شده',
          lineColor: Colors.green,
          gradientStartColor: Colors.green,
          gradientEndColor: Colors.green.withOpacity(0.1),
        ),
      ],
    );
  }

  Widget _buildRecentlyCompletedCourses(BuildContext context, LearnAnalytics analytics) {
    if (analytics.recentlyCompletedCourses.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AnalyticsSectionHeader(
          title: 'دوره‌های تکمیل شده اخیر',
          subtitle: 'آخرین دوره‌هایی که با موفقیت پایان یافته‌اند',
          icon: Icons.history_edu,
        ),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: analytics.recentlyCompletedCourses.length > 10
                ? 10
                : analytics.recentlyCompletedCourses.length,
            separatorBuilder: (context, index) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final course = analytics.recentlyCompletedCourses[index];
              return _buildCourseItem(context, course);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCourseItem(BuildContext context, CompletedCourse course) {
    final jalaliDate = Jalali.fromDateTime(course.completionDate);
    final dateString = '${jalaliDate.year}/${jalaliDate.month}/${jalaliDate.day}';

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getScoreColor(course.score).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              course.score.toStringAsFixed(0),
              style: TextStyle(
                color: _getScoreColor(course.score),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course.courseTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    dateString,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  if (course.instructor != null) ...[
                    const SizedBox(width: 12),
                    Icon(Icons.person, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        course.instructor!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getScoreColor(course.score).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.grade,
                    size: 14,
                    color: _getScoreColor(course.score),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${course.score.toStringAsFixed(0)}/۱۰۰',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getScoreColor(course.score),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${course.durationMinutes} دقیقه',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 75) return Colors.blue;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}
