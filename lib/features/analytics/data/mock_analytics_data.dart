import 'dart:math';
import '../../../core/models/user_activity.dart';
import '../../../core/models/analytics_data.dart';

class MockAnalyticsData {
  static final _random = Random(42);

  // لیست نام‌های ایرانی
  static const List<String> _iranianNames = [
    'محمد رضایی',
    'فاطمه احمدی',
    'علی کریمی',
    'زهرا محمدی',
    'حسین موسوی',
    'مریم حسینی',
    'رضا احمدپور',
    'سارا جعفری',
    'مهدی نوری',
    'نرگس امینی',
    'امیر حسینی',
    'الهام کاظمی',
    'مصطفی اکبری',
    'شیدا رحیمی',
    'پویا محمودی',
    'نازنین صادقی',
    'سعید یوسفی',
    'پریسا باقری',
    'جواد عباسی',
    'مینا زارعی',
    'حمید مرادی',
    'لیلا فتحی',
    'کاوه رستمی',
    'ساناز ملکی',
    'بهزاد قاسمی',
  ];

  // بخش‌های مختلف اپلیکیشن
  static const List<String> _appSections = [
    'تایم‌لاین',
    'آموزش',
    'پیام‌ها',
  ];

  // عنوان‌های نمونه برای پست‌ها
  static const List<String> _postTitles = [
    'اطلاعیه مهم سازمانی',
    'دستاورد تیم فروش',
    'گزارش پروژه جدید',
    'جلسه هفتگی',
    'پیشنهاد بهبود فرآیند',
    'موفقیت تیم توسعه',
    'رویداد سالانه شرکت',
    'به‌روزرسانی سیستم',
    'برنامه آموزشی',
    'گزارش عملکرد ماهانه',
  ];

  // عنوان‌های نمونه برای نظرسنجی‌ها
  static const List<String> _surveyTitles = [
    'نظرسنجی رضایت کارکنان',
    'بررسی محیط کاری',
    'ارزیابی سیستم جدید',
    'نظرسنجی برنامه آموزشی',
    'پیشنهادات بهبود فرآیند',
    'نظرسنجی مزایای کارکنان',
  ];

  /// تولید فعالیت‌های کاربران برای 30 روز گذشته
  static List<UserActivity> generateUserActivities({int count = 1000}) {
    final activities = <UserActivity>[];
    final now = DateTime.now();

    for (var i = 0; i < count; i++) {
      final daysAgo = _random.nextInt(30);
      final hoursAgo = _random.nextInt(24);
      final minutesAgo = _random.nextInt(60);

      final timestamp = now.subtract(
        Duration(days: daysAgo, hours: hoursAgo, minutes: minutesAgo),
      );

      final activityType = ActivityType.values[
          _random.nextInt(ActivityType.values.length)];

      final section = _appSections[_random.nextInt(_appSections.length)];
      final userName = _iranianNames[_random.nextInt(_iranianNames.length)];
      final userId = 'user_${_iranianNames.indexOf(userName) + 1}';

      String? targetTitle;
      if (activityType == ActivityType.surveyParticipated) {
        targetTitle = _surveyTitles[_random.nextInt(_surveyTitles.length)];
      } else {
        targetTitle = _postTitles[_random.nextInt(_postTitles.length)];
      }

      activities.add(
        UserActivity(
          userId: userId,
          userName: userName,
          type: activityType,
          timestamp: timestamp,
          targetId: 'target_$i',
          targetTitle: targetTitle,
          section: section,
          metadata: {
            'platform': 'android',
            'appVersion': '1.0.0',
          },
        ),
      );
    }

    return activities;
  }

  /// محاسبه آمار کاربران بر اساس فعالیت‌ها
  static List<UserStats> calculateUserStats(List<UserActivity> activities) {
    final userStatsMap = <String, Map<String, dynamic>>{};

    for (final activity in activities) {
      userStatsMap.putIfAbsent(
        activity.userId,
        () => {
          'userId': activity.userId,
          'userName': activity.userName,
          'totalPosts': 0,
          'totalLikes': 0,
          'totalComments': 0,
          'totalPostViews': 0,
          'totalSurveys': 0,
          'totalDirectMessages': 0,
          'totalGroupMessages': 0,
          'totalAudioCalls': 0,
          'totalVideoConferences': 0,
          'totalCoursesCompleted': 0,
          'totalCoursesInProgress': 0,
          'averageCourseScore': 0.0,
          'lastActiveAt': activity.timestamp,
        },
      );

      final stats = userStatsMap[activity.userId]!;

      switch (activity.type) {
        case ActivityType.postComposed:
          stats['totalPosts'] = (stats['totalPosts'] as int) + 1;
          break;
        case ActivityType.postLiked:
          stats['totalLikes'] = (stats['totalLikes'] as int) + 1;
          break;
        case ActivityType.postCommented:
          stats['totalComments'] = (stats['totalComments'] as int) + 1;
          break;
        case ActivityType.postVisited:
          stats['totalPostViews'] = (stats['totalPostViews'] as int) + 1;
          break;
        case ActivityType.surveyParticipated:
          stats['totalSurveys'] = (stats['totalSurveys'] as int) + 1;
          break;
      }

      final lastActive = stats['lastActiveAt'] as DateTime;
      if (activity.timestamp.isAfter(lastActive)) {
        stats['lastActiveAt'] = activity.timestamp;
      }
    }

    // Add random conversation and learning data for each user
    for (final stats in userStatsMap.values) {
      // Conversation activities
      stats['totalDirectMessages'] = 20 + _random.nextInt(80);
      stats['totalGroupMessages'] = 10 + _random.nextInt(40);
      stats['totalAudioCalls'] = _random.nextInt(15);
      stats['totalVideoConferences'] = _random.nextInt(10);

      // Learning activities
      stats['totalCoursesCompleted'] = _random.nextInt(8);
      stats['totalCoursesInProgress'] = _random.nextInt(4);
      stats['averageCourseScore'] = 60.0 + _random.nextDouble() * 35;
    }

    return userStatsMap.values
        .map((data) => UserStats(
              userId: data['userId'] as String,
              userName: data['userName'] as String,
              totalPosts: data['totalPosts'] as int,
              totalLikes: data['totalLikes'] as int,
              totalComments: data['totalComments'] as int,
              totalPostViews: data['totalPostViews'] as int,
              totalSurveys: data['totalSurveys'] as int,
              totalDirectMessages: data['totalDirectMessages'] as int,
              totalGroupMessages: data['totalGroupMessages'] as int,
              totalAudioCalls: data['totalAudioCalls'] as int,
              totalVideoConferences: data['totalVideoConferences'] as int,
              totalCoursesCompleted: data['totalCoursesCompleted'] as int,
              totalCoursesInProgress: data['totalCoursesInProgress'] as int,
              averageCourseScore: data['averageCourseScore'] as double,
              lastActiveAt: data['lastActiveAt'] as DateTime,
            ))
        .toList();
  }

  /// تولید داده‌های سری زمانی برای نمودار خطی
  static List<TimeSeriesData> generateTimeSeriesData({
    required DateTime startDate,
    required DateTime endDate,
    required List<UserActivity> activities,
  }) {
    final dataPoints = <DateTime, double>{};

    // Initialize all days with 0
    var currentDate = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    while (currentDate.isBefore(end) || currentDate.isAtSameMomentAs(end)) {
      dataPoints[currentDate] = 0;
      currentDate = currentDate.add(const Duration(days: 1));
    }

    // Count activities per day
    for (final activity in activities) {
      final date = DateTime(
        activity.timestamp.year,
        activity.timestamp.month,
        activity.timestamp.day,
      );

      if (dataPoints.containsKey(date)) {
        dataPoints[date] = dataPoints[date]! + 1;
      }
    }

    return dataPoints.entries
        .map((entry) => TimeSeriesData(date: entry.key, value: entry.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// محاسبه توزیع فعالیت‌ها
  static List<ActivityDistribution> calculateActivityDistribution(
    List<UserActivity> activities,
  ) {
    final counts = <ActivityType, int>{};
    final total = activities.length;

    for (final activity in activities) {
      counts[activity.type] = (counts[activity.type] ?? 0) + 1;
    }

    return counts.entries
        .map((entry) => ActivityDistribution(
              activityType: _getActivityTypePersianName(entry.key),
              count: entry.value,
              percentage: (entry.value / total) * 100,
            ))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));
  }

  /// محاسبه فعالیت در بخش‌های مختلف
  static List<SectionActivityData> calculateSectionActivity(
    List<UserActivity> activities,
  ) {
    final counts = <String, int>{};
    final total = activities.length;

    for (final activity in activities) {
      if (activity.section != null) {
        counts[activity.section!] = (counts[activity.section!] ?? 0) + 1;
      }
    }

    return counts.entries
        .map((entry) => SectionActivityData(
              section: entry.key,
              activityCount: entry.value,
              percentage: (entry.value / total) * 100,
            ))
        .toList()
      ..sort((a, b) => b.activityCount.compareTo(a.activityCount));
  }

  /// محاسبه خلاصه آمار
  static AnalyticsSummary calculateSummary(
    List<UserActivity> activities,
    List<UserStats> userStats,
  ) {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    final activeUserIds = activities
        .where((a) => a.timestamp.isAfter(thirtyDaysAgo))
        .map((a) => a.userId)
        .toSet();

    return AnalyticsSummary(
      totalUsers: userStats.length,
      activeUsers: activeUserIds.length,
      totalActivities: activities.length,
      averageActivitiesPerUser:
          userStats.isEmpty ? 0 : activities.length / userStats.length,
      periodStart: thirtyDaysAgo,
      periodEnd: now,
    );
  }

  static String _getActivityTypePersianName(ActivityType type) {
    switch (type) {
      case ActivityType.postComposed:
        return 'نوشتن پست';
      case ActivityType.postLiked:
        return 'پسندیدن';
      case ActivityType.postCommented:
        return 'نظر دادن';
      case ActivityType.postVisited:
        return 'بازدید پست';
      case ActivityType.surveyParticipated:
        return 'شرکت در نظرسنجی';
    }
  }
}
