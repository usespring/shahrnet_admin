import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/timeline_analytics_providers.dart';
import '../widgets/stats_card.dart';
import '../widgets/line_chart_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/analytics_section_header.dart';
import '../../../../core/models/timeline_analytics.dart';
import '../../../../core/models/analytics_data.dart';

class TimelineAnalyticsScreen extends ConsumerWidget {
  const TimelineAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(timelineAnalyticsProvider);

    return analyticsAsync.when(
      data: (analytics) {
        if (analytics.totalEngagements == 0) {
          return EmptyStateWidget(
            message: 'هیچ فعالیتی در این بازه زمانی وجود ندارد',
            subtitle: 'بازه زمانی دیگری را انتخاب کنید',
            icon: Icons.timeline,
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummarySection(context, analytics),
              const SizedBox(height: 24),
              _buildEngagementTrendChart(context, analytics),
              const SizedBox(height: 24),
              _buildTopPostsSection(context, analytics),
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
          ref.invalidate(timelineAnalyticsProvider);
        },
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, TimelineAnalytics analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AnalyticsSectionHeader(
          title: 'خلاصه فعالیت‌ها',
          subtitle: 'آمار کلی فعالیت‌های تایم‌لاین',
          icon: Icons.summarize,
        ),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            StatsCard(
              title: 'پست‌های منتشر شده',
              value: analytics.postsComposed.toString(),
              icon: Icons.post_add,
              color: Colors.blue,
            ),
            StatsCard(
              title: 'لایک‌ها',
              value: analytics.likesGiven.toString(),
              icon: Icons.thumb_up,
              color: Colors.pink,
            ),
            StatsCard(
              title: 'نظرات',
              value: analytics.commentsWritten.toString(),
              icon: Icons.comment,
              color: Colors.orange,
            ),
            StatsCard(
              title: 'بازدیدها',
              value: analytics.postVisits.toString(),
              icon: Icons.visibility,
              color: Colors.green,
            ),
            StatsCard(
              title: 'اشتراک‌گذاری‌ها',
              value: analytics.shares.toString(),
              icon: Icons.share,
              color: Colors.purple,
            ),
            StatsCard(
              title: 'شرکت در نظرسنجی',
              value: analytics.pollParticipations.toString(),
              icon: Icons.poll,
              color: Colors.teal,
            ),
            StatsCard(
              title: 'گزارشات',
              value: analytics.reportsSubmitted.toString(),
              icon: Icons.report,
              color: Colors.red,
            ),
            StatsCard(
              title: 'نرخ تعامل',
              value: '${analytics.engagementRate.toStringAsFixed(1)}%',
              icon: Icons.trending_up,
              color: Colors.indigo,
              subtitle: 'به ازای هر بازدید',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEngagementTrendChart(BuildContext context, TimelineAnalytics analytics) {
    if (analytics.engagementTrend.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AnalyticsSectionHeader(
          title: 'روند تعامل',
          subtitle: 'نمودار فعالیت‌های تایم‌لاین در طول زمان',
          icon: Icons.show_chart,
        ),
        LineChartWidget(
          data: analytics.engagementTrend
              .map((point) => TimeSeriesData(
                    date: point.date,
                    value: point.value,
                  ))
              .toList(),
          title: 'تعداد تعاملات روزانه',
          lineColor: Colors.blue,
          gradientStartColor: Colors.blue,
          gradientEndColor: Colors.blue.withOpacity(0.1),
        ),
      ],
    );
  }

  Widget _buildTopPostsSection(BuildContext context, TimelineAnalytics analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AnalyticsSectionHeader(
          title: 'پست‌های برتر',
          subtitle: 'پرطرفدارترین پست‌ها در این بازه زمانی',
          icon: Icons.star,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildTopPostsList(
                context,
                'پربازدیدترین',
                analytics.topPostsByViews,
                Icons.visibility,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTopPostsList(
                context,
                'پرلایک‌ترین',
                analytics.topPostsByLikes,
                Icons.thumb_up,
                Colors.pink,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTopPostsList(
                context,
                'پرنظرترین',
                analytics.topPostsByComments,
                Icons.comment,
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopPostsList(
    BuildContext context,
    String title,
    List<TopPost> posts,
    IconData icon,
    Color color,
  ) {
    if (posts.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color.withOpacity(0.5)),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'داده‌ای موجود نیست',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: posts.length > 3 ? 3 : posts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final post = posts[index];
                return _buildTopPostItem(context, post, index + 1, color);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPostItem(
    BuildContext context,
    TopPost post,
    int rank,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              '$rank',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.visibility, size: 12, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    post.viewsCount.toString(),
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.thumb_up, size: 12, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    post.likesCount.toString(),
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.comment, size: 12, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    post.commentsCount.toString(),
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
