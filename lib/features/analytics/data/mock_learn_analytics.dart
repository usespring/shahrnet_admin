import 'dart:math';
import '../../../core/models/learn_analytics.dart';

class MockLearnAnalytics {
  static final _random = Random(42);

  static const List<String> _courseTitles = [
    'مبانی مدیریت پروژه با Agile',
    'آموزش جامع React و Next.js',
    'مهارت‌های ارتباطی موثر در محیط کار',
    'مدیریت زمان و افزایش بهره‌وری',
    'اصول طراحی رابط کاربری (UI/UX)',
    'آموزش پایتون برای علم داده',
    'مدیریت تیم و رهبری سازمانی',
    'امنیت سایبری برای مبتدیان',
    'بازاریابی دیجیتال و شبکه‌های اجتماعی',
    'تحلیل داده با Excel پیشرفته',
    'آموزش کامل Git و GitHub',
    'استراتژی‌های فروش حرفه‌ای',
    'مدیریت منابع انسانی نوین',
    'طراحی و توسعه API با Node.js',
    'مدیریت مالی برای غیرمالی‌ها',
  ];

  static const List<String> _instructors = [
    'دکتر احمد رضایی',
    'مهندس سارا کریمی',
    'دکتر محمد حسینی',
    'مهندس فاطمه نوری',
    'دکتر علی موسوی',
    'مهندس مریم احمدی',
    'دکتر حسین یوسفی',
    'مهندس نرگس رحیمی',
  ];

  static LearnAnalytics generateAnalytics({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final daysDiff = endDate.difference(startDate).inDays;

    // Generate random counts
    final completedCourses = 2 + _random.nextInt(8);
    final inProgressCourses = 1 + _random.nextInt(4);
    final averageScore = 65.0 + _random.nextDouble() * 30;
    final completionRate = (completedCourses / (completedCourses + inProgressCourses)) * 100;
    final totalLearningTimeMinutes = completedCourses * (60 + _random.nextInt(120));

    // Generate completion trend
    final completionTrend = _generateCompletionTrend(startDate, endDate, completedCourses);

    // Generate recently completed courses
    final recentlyCompletedCourses = _generateCompletedCourses(
      completedCourses > 10 ? 10 : completedCourses,
      startDate,
      endDate,
    );

    return LearnAnalytics(
      completedCourses: completedCourses,
      inProgressCourses: inProgressCourses,
      averageScore: averageScore,
      completionRate: completionRate,
      totalLearningTimeMinutes: totalLearningTimeMinutes,
      recentlyCompletedCourses: recentlyCompletedCourses,
      completionTrend: completionTrend,
      periodStart: startDate,
      periodEnd: endDate,
    );
  }

  static List<TimeSeriesPoint> _generateCompletionTrend(
    DateTime startDate,
    DateTime endDate,
    int totalCompletions,
  ) {
    final points = <TimeSeriesPoint>[];
    var currentDate = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    // Distribute completions across the date range
    final daysDiff = endDate.difference(startDate).inDays;
    var cumulativeCompletions = 0.0;

    while (currentDate.isBefore(end) || currentDate.isAtSameMomentAs(end)) {
      // Randomly add completions
      if (_random.nextDouble() < 0.15 && cumulativeCompletions < totalCompletions) {
        cumulativeCompletions += 1.0;
      }

      points.add(TimeSeriesPoint(
        date: currentDate,
        value: cumulativeCompletions,
      ));

      currentDate = currentDate.add(const Duration(days: 1));
    }

    return points;
  }

  static List<CompletedCourse> _generateCompletedCourses(
    int count,
    DateTime startDate,
    DateTime endDate,
  ) {
    final courses = <CompletedCourse>[];
    final usedTitles = <String>{};

    for (var i = 0; i < count; i++) {
      // Find a unique title
      String title;
      do {
        title = _courseTitles[_random.nextInt(_courseTitles.length)];
      } while (usedTitles.contains(title) && usedTitles.length < _courseTitles.length);
      usedTitles.add(title);

      final daysAgo = _random.nextInt(endDate.difference(startDate).inDays);
      final completionDate = endDate.subtract(Duration(days: daysAgo));

      final score = 50.0 + _random.nextDouble() * 50;
      final durationMinutes = 60 + _random.nextInt(240);
      final instructor = _instructors[_random.nextInt(_instructors.length)];

      courses.add(CompletedCourse(
        courseId: 'course_${i + 1}',
        courseTitle: title,
        completionDate: completionDate,
        score: score,
        durationMinutes: durationMinutes,
        instructor: instructor,
      ));
    }

    // Sort by completion date (most recent first)
    courses.sort((a, b) => b.completionDate.compareTo(a.completionDate));

    return courses;
  }
}
