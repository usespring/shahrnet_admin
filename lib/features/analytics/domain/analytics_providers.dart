import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user_activity.dart';
import '../../../core/models/analytics_data.dart';
import 'analytics_service.dart';

// Service provider
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

// Date range state
enum DateRangeType { last7Days, last30Days, last90Days, custom }

class DateRangeState {
  final DateRangeType type;
  final DateTime startDate;
  final DateTime endDate;

  DateRangeState({
    required this.type,
    required this.startDate,
    required this.endDate,
  });

  factory DateRangeState.last7Days() {
    final now = DateTime.now();
    return DateRangeState(
      type: DateRangeType.last7Days,
      startDate: now.subtract(const Duration(days: 7)),
      endDate: now,
    );
  }

  factory DateRangeState.last30Days() {
    final now = DateTime.now();
    return DateRangeState(
      type: DateRangeType.last30Days,
      startDate: now.subtract(const Duration(days: 30)),
      endDate: now,
    );
  }

  factory DateRangeState.last90Days() {
    final now = DateTime.now();
    return DateRangeState(
      type: DateRangeType.last90Days,
      startDate: now.subtract(const Duration(days: 90)),
      endDate: now,
    );
  }
}

// Date range notifier
class DateRangeNotifier extends StateNotifier<DateRangeState> {
  DateRangeNotifier() : super(DateRangeState.last30Days());

  void setLast7Days() {
    state = DateRangeState.last7Days();
  }

  void setLast30Days() {
    state = DateRangeState.last30Days();
  }

  void setLast90Days() {
    state = DateRangeState.last90Days();
  }

  void setCustomRange(DateTime start, DateTime end) {
    state = DateRangeState(
      type: DateRangeType.custom,
      startDate: start,
      endDate: end,
    );
  }
}

final dateRangeProvider =
    StateNotifierProvider<DateRangeNotifier, DateRangeState>((ref) {
  return DateRangeNotifier();
});

// Analytics summary provider
final analyticsSummaryProvider =
    FutureProvider.autoDispose<AnalyticsSummary>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  return service.getAnalyticsSummary();
});

// User activities provider
final userActivitiesProvider =
    FutureProvider.autoDispose<List<UserActivity>>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  final dateRange = ref.watch(dateRangeProvider);

  return service.getUserActivities(
    startDate: dateRange.startDate,
    endDate: dateRange.endDate,
  );
});

// Time series data provider
final timeSeriesDataProvider =
    FutureProvider.autoDispose<List<TimeSeriesData>>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  final dateRange = ref.watch(dateRangeProvider);

  return service.getTimeSeriesData(
    startDate: dateRange.startDate,
    endDate: dateRange.endDate,
  );
});

// Activity distribution provider
final activityDistributionProvider =
    FutureProvider.autoDispose<List<ActivityDistribution>>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  final dateRange = ref.watch(dateRangeProvider);

  return service.getActivityDistribution(
    startDate: dateRange.startDate,
    endDate: dateRange.endDate,
  );
});

// Section activity provider
final sectionActivityProvider =
    FutureProvider.autoDispose<List<SectionActivityData>>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  final dateRange = ref.watch(dateRangeProvider);

  return service.getSectionActivity(
    startDate: dateRange.startDate,
    endDate: dateRange.endDate,
  );
});

// Top active users provider
final topActiveUsersProvider =
    FutureProvider.autoDispose<List<UserStats>>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  return service.getTopActiveUsers(limit: 10);
});

// User stats provider
final userStatsProvider = FutureProvider.autoDispose<List<UserStats>>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  return service.getUserStats();
});

// User activity trends provider (per user)
final userActivityTrendsProvider = FutureProvider.autoDispose
    .family<Map<String, List<TimeSeriesData>>, String>((ref, userId) async {
  final service = ref.watch(analyticsServiceProvider);
  final dateRange = ref.watch(dateRangeProvider);

  return service.getUserActivityTrends(
    userId: userId,
    startDate: dateRange.startDate,
    endDate: dateRange.endDate,
  );
});
