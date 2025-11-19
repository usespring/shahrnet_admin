import '../../../core/models/user_activity.dart';
import '../../../core/models/analytics_data.dart';
import '../data/mock_analytics_data.dart';

class AnalyticsService {
  // Simulated cache
  List<UserActivity>? _cachedActivities;
  List<UserStats>? _cachedUserStats;

  /// دریافت تمام فعالیت‌ها
  Future<List<UserActivity>> getUserActivities({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    _cachedActivities ??= MockAnalyticsData.generateUserActivities(count: 2000);

    var activities = _cachedActivities!;

    if (startDate != null) {
      activities = activities
          .where((a) => a.timestamp.isAfter(startDate))
          .toList();
    }

    if (endDate != null) {
      activities = activities
          .where((a) => a.timestamp.isBefore(endDate))
          .toList();
    }

    return activities;
  }

  /// دریافت آمار کاربران
  Future<List<UserStats>> getUserStats() async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (_cachedUserStats == null) {
      final activities = await getUserActivities();
      _cachedUserStats = MockAnalyticsData.calculateUserStats(activities);
    }

    return _cachedUserStats!;
  }

  /// دریافت داده‌های سری زمانی
  Future<List<TimeSeriesData>> getTimeSeriesData({
    required DateTime startDate,
    required DateTime endDate,
    ActivityType? filterByType,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    var activities = await getUserActivities(
      startDate: startDate,
      endDate: endDate,
    );

    if (filterByType != null) {
      activities = activities.where((a) => a.type == filterByType).toList();
    }

    return MockAnalyticsData.generateTimeSeriesData(
      startDate: startDate,
      endDate: endDate,
      activities: activities,
    );
  }

  /// دریافت توزیع فعالیت‌ها
  Future<List<ActivityDistribution>> getActivityDistribution({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final activities = await getUserActivities(
      startDate: startDate,
      endDate: endDate,
    );

    return MockAnalyticsData.calculateActivityDistribution(activities);
  }

  /// دریافت فعالیت در بخش‌های مختلف
  Future<List<SectionActivityData>> getSectionActivity({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final activities = await getUserActivities(
      startDate: startDate,
      endDate: endDate,
    );

    return MockAnalyticsData.calculateSectionActivity(activities);
  }

  /// دریافت خلاصه آمار
  Future<AnalyticsSummary> getAnalyticsSummary() async {
    await Future.delayed(const Duration(milliseconds: 400));

    final activities = await getUserActivities();
    final userStats = await getUserStats();

    return MockAnalyticsData.calculateSummary(activities, userStats);
  }

  /// دریافت فعال‌ترین کاربران
  Future<List<UserStats>> getTopActiveUsers({int limit = 10}) async {
    final userStats = await getUserStats();

    return (userStats..sort((a, b) => b.totalActivity.compareTo(a.totalActivity)))
        .take(limit)
        .toList();
  }

  /// پاک کردن کش
  void clearCache() {
    _cachedActivities = null;
    _cachedUserStats = null;
  }
}
