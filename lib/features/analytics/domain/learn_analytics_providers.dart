import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/learn_analytics.dart';
import '../data/mock_learn_analytics.dart';
import 'analytics_providers.dart';

final learnAnalyticsProvider =
    FutureProvider.autoDispose<LearnAnalytics>((ref) async {
  final dateRange = ref.watch(dateRangeProvider);

  // Simulate API delay
  await Future.delayed(const Duration(milliseconds: 500));

  return MockLearnAnalytics.generateAnalytics(
    startDate: dateRange.startDate,
    endDate: dateRange.endDate,
  );
});
