import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shahrnet_admin/core/models/sentiment_analytics.dart';
import 'package:shahrnet_admin/core/models/analytics_data.dart';
import 'package:shahrnet_admin/features/analytics/domain/sentiment_analytics_providers.dart';
import 'package:shahrnet_admin/features/analytics/presentation/widgets/analytics_section_header.dart';
import 'package:shahrnet_admin/features/analytics/presentation/widgets/empty_state_widget.dart';
import 'package:shahrnet_admin/features/analytics/presentation/widgets/engagement_score_widget.dart';
import 'package:shahrnet_admin/features/analytics/presentation/widgets/sentiment_gauge_widget.dart';
import 'package:shahrnet_admin/features/analytics/presentation/widgets/mood_timeline_widget.dart';
import 'package:shahrnet_admin/features/analytics/presentation/widgets/insight_card_widget.dart';
import 'package:shahrnet_admin/features/analytics/presentation/widgets/sentiment_distribution_widget.dart';
import 'package:shahrnet_admin/features/analytics/presentation/widgets/line_chart_widget.dart';
import 'package:shahrnet_admin/features/analytics/presentation/widgets/stats_card.dart';

/// Sentiment Analytics Screen
///
/// Displays user emotional status based on three sources:
/// 1. Activity-based emotional status
/// 2. Text-based sentiment analysis
/// 3. Self-reported emotional status
class SentimentAnalyticsScreen extends ConsumerWidget {
  const SentimentAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sentimentAnalyticsAsync = ref.watch(sentimentAnalyticsProvider);

    return sentimentAnalyticsAsync.when(
      data: (analytics) => _buildContent(context, analytics),
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => EmptyStateWidget(
        message: 'خطا در بارگذاری تحلیل احساسات',
        subtitle: error.toString(),
        icon: Icons.psychology,
        onRetry: () => ref.invalidate(sentimentAnalyticsProvider),
      ),
    );
  }

  Widget _buildContent(BuildContext context, SentimentAnalytics analytics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Activity-Based Emotion Score
          const AnalyticsSectionHeader(
            icon: Icons.local_fire_department,
            title: 'وضعیت احساسی بر اساس فعالیت',
            subtitle: 'تحلیل احساسات بر اساس میزان مشارکت و فعالیت',
          ),
          const SizedBox(height: 16),
          _buildActivityBasedSection(context, analytics.activityBasedEmotion),
          const SizedBox(height: 32),

          // Section 2: Text-Based Sentiment Analysis
          const AnalyticsSectionHeader(
            icon: Icons.text_fields,
            title: 'تحلیل احساسات متنی',
            subtitle: 'تحلیل احساسات از محتوای نوشته‌شده',
          ),
          const SizedBox(height: 16),
          _buildTextSentimentSection(context, analytics.textBasedSentiment),
          const SizedBox(height: 32),

          // Section 3: Self-Reported Mood
          const AnalyticsSectionHeader(
            icon: Icons.mood,
            title: 'گزارش روحیه شخصی',
            subtitle: 'وضعیت احساسی ثبت‌شده توسط کاربر',
          ),
          const SizedBox(height: 16),
          _buildSelfReportedMoodSection(context, analytics.selfReportedMood),
          const SizedBox(height: 32),

          // Section 4: Insights & Smart Suggestions
          const AnalyticsSectionHeader(
            icon: Icons.lightbulb,
            title: 'بینش‌ها و پیشنهادهای هوشمند',
            subtitle: 'تحلیل‌های هوشمند از داده‌های احساسی',
          ),
          const SizedBox(height: 16),
          _buildInsightsSection(context, analytics.insights),
        ],
      ),
    );
  }

  /// Section 1: Activity-Based Emotion
  Widget _buildActivityBasedSection(
    BuildContext context,
    ActivityBasedEmotion emotion,
  ) {
    return Column(
      children: [
        // Engagement score and stats cards
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: EngagementScoreWidget(
                score: emotion.engagementScore,
                status: emotion.emotionalStatus,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          title: 'کل فعالیت‌ها',
                          value: emotion.totalActivities.toString(),
                          icon: Icons.bar_chart,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatsCard(
                          title: 'روزهای فعال',
                          value: emotion.daysActive.toString(),
                          icon: Icons.calendar_today,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          title: 'پست‌ها',
                          value: emotion.postsCreated.toString(),
                          icon: Icons.post_add,
                          color: Colors.purple,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatsCard(
                          title: 'نظرات',
                          value: emotion.commentsWritten.toString(),
                          icon: Icons.comment,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Activity breakdown
        Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'توزیع فعالیت‌ها',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      ...emotion.activityBreakdown.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(entry.key),
                              Text(
                                entry.value.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Activity trend chart
        LineChartWidget(
          title: 'روند فعالیت',
          data: _convertToTimeSeriesData(emotion.activityTrend),
        ),
      ],
    );
  }

  /// Section 2: Text-Based Sentiment
  Widget _buildTextSentimentSection(
    BuildContext context,
    TextBasedSentiment sentiment,
  ) {
    return Column(
      children: [
        // Sentiment gauge and stats
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: SentimentGaugeWidget(
                score: sentiment.averageSentimentScore,
                level: sentiment.averageSentimentLevel,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          title: 'محتوای تحلیل‌شده',
                          value: sentiment.totalAnalyzed.toString(),
                          icon: Icons.analytics,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatsCard(
                          title: 'نسبت مثبت',
                          value:
                              '${(sentiment.positiveRatio * 100).toStringAsFixed(0)}%',
                          icon: Icons.thumb_up,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          title: 'مثبت',
                          value: sentiment.positiveCount.toString(),
                          icon: Icons.sentiment_satisfied,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatsCard(
                          title: 'منفی',
                          value: sentiment.negativeCount.toString(),
                          icon: Icons.sentiment_dissatisfied,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Sentiment distribution
        SentimentDistributionWidget(
          distribution: sentiment.sentimentDistribution,
          title: 'توزیع احساسات',
        ),
        const SizedBox(height: 16),
        // Sentiment trend
        LineChartWidget(
          title: 'روند احساسات',
          data: _convertToTimeSeriesData(sentiment.sentimentTrend),
        ),
        const SizedBox(height: 16),
        // Most positive/negative content
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (sentiment.mostPositiveContent != null)
              Expanded(
                child: _buildContentCard(
                  context,
                  'مثبت‌ترین محتوا',
                  sentiment.mostPositiveContent!,
                  Colors.green,
                ),
              ),
            if (sentiment.mostPositiveContent != null &&
                sentiment.mostNegativeContent != null)
              const SizedBox(width: 16),
            if (sentiment.mostNegativeContent != null)
              Expanded(
                child: _buildContentCard(
                  context,
                  'منفی‌ترین محتوا',
                  sentiment.mostNegativeContent!,
                  Colors.red,
                ),
              ),
          ],
        ),
      ],
    );
  }

  /// Section 3: Self-Reported Mood
  Widget _buildSelfReportedMoodSection(
    BuildContext context,
    SelfReportedMood mood,
  ) {
    return Column(
      children: [
        // Mood stats
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: 'کل گزارش‌ها',
                value: mood.totalEntries.toString(),
                icon: Icons.note_add,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatsCard(
                title: 'میانگین روحیه',
                value: mood.averageMood?.emoji ?? '—',
                subtitle: mood.averageMood?.displayName,
                icon: Icons.mood,
                color: Colors.purple,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatsCard(
                title: 'رایج‌ترین روحیه',
                value: mood.mostCommonMood?.emoji ?? '—',
                subtitle: mood.mostCommonMood?.displayName,
                icon: Icons.trending_up,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Mood distribution
        SentimentDistributionWidget(
          distribution: mood.moodDistribution,
          title: 'توزیع روحیه',
        ),
        const SizedBox(height: 16),
        // Mood trend
        if (mood.moodTrend.isNotEmpty)
          LineChartWidget(
            title: 'روند روحیه روزانه',
            data: _convertToTimeSeriesData(mood.moodTrend),
          ),
        const SizedBox(height: 16),
        // Best/Worst mood days
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (mood.bestMoodDay != null)
              Expanded(
                child: _buildMoodDayCard(
                  context,
                  'بهترین روز',
                  mood.bestMoodDay!,
                  Colors.green,
                ),
              ),
            if (mood.bestMoodDay != null && mood.worstMoodDay != null)
              const SizedBox(width: 16),
            if (mood.worstMoodDay != null)
              Expanded(
                child: _buildMoodDayCard(
                  context,
                  'بدترین روز',
                  mood.worstMoodDay!,
                  Colors.red,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        // Activity correlation
        if (mood.activityCorrelation != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.insights, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'همبستگی روحیه و فعالیت',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    mood.activityCorrelation!.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'میانگین فعالیت بر اساس روحیه:',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ...mood.activityCorrelation!.averageEngagementByMood.entries
                      .map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Text(
                            entry.key.emoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          Text(entry.key.displayName),
                          const Spacer(),
                          Text(
                            entry.value.toStringAsFixed(0),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        // Mood timeline
        MoodTimelineWidget(entries: mood.entries),
      ],
    );
  }

  /// Section 4: Insights
  Widget _buildInsightsSection(
    BuildContext context,
    List<SmartInsight> insights,
  ) {
    if (insights.isEmpty) {
      return const EmptyStateWidget(
        message: 'هیچ بینشی در دسترس نیست',
        subtitle: 'با افزایش فعالیت، بینش‌های بیشتری تولید می‌شود',
        icon: Icons.lightbulb_outline,
      );
    }

    return Column(
      children: insights.map((insight) {
        return InsightCardWidget(insight: insight);
      }).toList(),
    );
  }

  /// Build content card for most positive/negative
  Widget _buildContentCard(
    BuildContext context,
    String title,
    AnalyzedContent content,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.format_quote, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                content.text,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  content.sentimentLevel.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  content.sentimentLevel.displayName,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    content.contentType,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build mood day card
  Widget _buildMoodDayCard(
    BuildContext context,
    String title,
    MoodEntry entry,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  entry.mood.emoji,
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.mood.displayName,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      if (entry.comment != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          entry.comment!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Helper function to convert TimeSeriesPoint to TimeSeriesData
  List<TimeSeriesData> _convertToTimeSeriesData(List<TimeSeriesPoint> points) {
    return points.map((point) => TimeSeriesData(
      date: point.date,
      value: point.value,
    )).toList();
  }
}
