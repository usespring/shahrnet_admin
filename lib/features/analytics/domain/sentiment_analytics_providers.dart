import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shahrnet_admin/core/models/sentiment_analytics.dart';
import 'package:shahrnet_admin/features/analytics/data/mock_sentiment_analytics.dart';
import 'package:shahrnet_admin/features/analytics/domain/analytics_providers.dart';

/// Provider for sentiment analytics data
/// Automatically disposes when no longer needed
final sentimentAnalyticsProvider =
    FutureProvider.autoDispose<SentimentAnalytics>((ref) async {
  // Watch date range to automatically refresh when it changes
  final dateRange = ref.watch(dateRangeProvider);

  // Simulate network delay
  await Future.delayed(const Duration(milliseconds: 500));

  // Generate mock sentiment analytics data
  return MockSentimentAnalytics.generateSentimentAnalytics(
    startDate: dateRange.startDate,
    endDate: dateRange.endDate,
  );
});

/// Provider for activity-based emotion data only
final activityBasedEmotionProvider =
    FutureProvider.autoDispose<ActivityBasedEmotion>((ref) async {
  final analytics = await ref.watch(sentimentAnalyticsProvider.future);
  return analytics.activityBasedEmotion;
});

/// Provider for text-based sentiment data only
final textBasedSentimentProvider =
    FutureProvider.autoDispose<TextBasedSentiment>((ref) async {
  final analytics = await ref.watch(sentimentAnalyticsProvider.future);
  return analytics.textBasedSentiment;
});

/// Provider for self-reported mood data only
final selfReportedMoodProvider =
    FutureProvider.autoDispose<SelfReportedMood>((ref) async {
  final analytics = await ref.watch(sentimentAnalyticsProvider.future);
  return analytics.selfReportedMood;
});

/// Provider for smart insights
final sentimentInsightsProvider =
    FutureProvider.autoDispose<List<SmartInsight>>((ref) async {
  final analytics = await ref.watch(sentimentAnalyticsProvider.future);
  return analytics.insights;
});
