import 'dart:math';
import '../../../core/models/timeline_analytics.dart';

class MockTimelineAnalytics {
  static final _random = Random(42);

  static const List<String> _postTitles = [
    'اطلاعیه مهم سازمانی برای همه کارکنان',
    'دستاورد فوق‌العاده تیم فروش در سه‌ماهه اول',
    'گزارش پیشرفت پروژه توسعه محصول جدید',
    'دعوت به جلسه هفتگی تیم مدیریت',
    'پیشنهاد بهبود فرآیند تولید و کاهش هزینه‌ها',
    'موفقیت تیم توسعه در رفع باگ‌های کریتیکال',
    'برنامه رویداد سالانه شرکت و جشن پایان سال',
    'به‌روزرسانی سیستم مدیریت منابع انسانی',
    'معرفی برنامه آموزشی جدید مهارت‌های نرم',
    'گزارش عملکرد ماهانه و اهداف آتی',
    'پروژه جدید: توسعه اپلیکیشن موبایل',
    'دستورالعمل‌های ایمنی در محیط کار',
    'نتایج نظرسنجی رضایت کارکنان',
    'معرفی اعضای جدید تیم بازاریابی',
    'راهنمای استفاده از سیستم جدید CRM',
  ];

  static const List<String> _authors = [
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
  ];

  static TimelineAnalytics generateAnalytics({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final daysDiff = endDate.difference(startDate).inDays;

    // Generate random counts
    final likesGiven = 50 + _random.nextInt(150);
    final commentsWritten = 30 + _random.nextInt(80);
    final postsComposed = 5 + _random.nextInt(15);
    final postVisits = 100 + _random.nextInt(300);
    final shares = 10 + _random.nextInt(30);
    final pollParticipations = 3 + _random.nextInt(10);
    final reportsSubmitted = _random.nextInt(5);

    final totalEngagements = likesGiven + commentsWritten + postVisits + shares + pollParticipations;
    final engagementRate = postVisits > 0 ? (totalEngagements / postVisits) * 100 : 0.0;

    // Generate engagement trend
    final engagementTrend = _generateEngagementTrend(startDate, endDate);

    // Generate top posts
    final topPostsByLikes = _generateTopPosts(3, 'likes', startDate, endDate);
    final topPostsByComments = _generateTopPosts(3, 'comments', startDate, endDate);
    final topPostsByViews = _generateTopPosts(3, 'views', startDate, endDate);

    return TimelineAnalytics(
      likesGiven: likesGiven,
      commentsWritten: commentsWritten,
      postsComposed: postsComposed,
      postVisits: postVisits,
      shares: shares,
      pollParticipations: pollParticipations,
      reportsSubmitted: reportsSubmitted,
      engagementRate: engagementRate,
      topPostsByLikes: topPostsByLikes,
      topPostsByComments: topPostsByComments,
      topPostsByViews: topPostsByViews,
      engagementTrend: engagementTrend,
      periodStart: startDate,
      periodEnd: endDate,
    );
  }

  static List<TimeSeriesPoint> _generateEngagementTrend(
    DateTime startDate,
    DateTime endDate,
  ) {
    final points = <TimeSeriesPoint>[];
    var currentDate = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    while (currentDate.isBefore(end) || currentDate.isAtSameMomentAs(end)) {
      // Generate random engagement with some trend
      final baseValue = 20.0 + _random.nextDouble() * 30;
      final trendValue = baseValue + (currentDate.difference(startDate).inDays * 0.5);

      points.add(TimeSeriesPoint(
        date: currentDate,
        value: trendValue,
      ));

      currentDate = currentDate.add(const Duration(days: 1));
    }

    return points;
  }

  static List<TopPost> _generateTopPosts(
    int count,
    String sortBy,
    DateTime startDate,
    DateTime endDate,
  ) {
    final posts = <TopPost>[];

    for (var i = 0; i < count; i++) {
      final daysAgo = _random.nextInt(endDate.difference(startDate).inDays);
      final publishedAt = endDate.subtract(Duration(days: daysAgo));

      final likesCount = 10 + _random.nextInt(90);
      final commentsCount = 5 + _random.nextInt(45);
      final viewsCount = 50 + _random.nextInt(450);

      posts.add(TopPost(
        postId: 'post_${i + 1}',
        title: _postTitles[_random.nextInt(_postTitles.length)],
        author: _authors[_random.nextInt(_authors.length)],
        likesCount: likesCount,
        commentsCount: commentsCount,
        viewsCount: viewsCount,
        publishedAt: publishedAt,
      ));
    }

    // Sort based on criteria
    switch (sortBy) {
      case 'likes':
        posts.sort((a, b) => b.likesCount.compareTo(a.likesCount));
        break;
      case 'comments':
        posts.sort((a, b) => b.commentsCount.compareTo(a.commentsCount));
        break;
      case 'views':
        posts.sort((a, b) => b.viewsCount.compareTo(a.viewsCount));
        break;
    }

    return posts;
  }
}
