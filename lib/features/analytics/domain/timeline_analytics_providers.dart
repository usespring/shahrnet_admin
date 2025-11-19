import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/timeline_analytics.dart';
import '../data/mock_timeline_analytics.dart';
import 'analytics_providers.dart';

final timelineAnalyticsProvider =
    FutureProvider.autoDispose<TimelineAnalytics>((ref) async {
  final dateRange = ref.watch(dateRangeProvider);

  // Simulate API delay
  await Future.delayed(const Duration(milliseconds: 500));

  return MockTimelineAnalytics.generateAnalytics(
    startDate: dateRange.startDate,
    endDate: dateRange.endDate,
  );
});
