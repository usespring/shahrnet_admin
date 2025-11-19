import 'dart:math';
import 'package:shahrnet_admin/core/models/peer_survey.dart';
import 'package:shahrnet_admin/core/models/sentiment_analytics.dart';

/// Mock data generator for Peer Survey
class MockPeerSurvey {
  static final Random _random = Random(42);

  static final List<String> _firstNames = [
    'علی',
    'محمد',
    'حسین',
    'رضا',
    'سارا',
    'فاطمه',
    'زهرا',
    'مریم',
    'مهدی',
    'امیر',
    'سمیرا',
    'نرگس',
    'پوریا',
    'نیما',
    'مینا',
    'شیدا',
    'آرش',
    'سینا',
    'الهام',
    'نیلوفر'
  ];

  static final List<String> _lastNames = [
    'احمدی',
    'محمدی',
    'حسینی',
    'رضایی',
    'کریمی',
    'موسوی',
    'جعفری',
    'صادقی',
    'نوری',
    'اکبری',
    'قاسمی',
    'فرهادی',
    'رحمانی',
    'امینی',
    'خسروی',
    'سلیمانی',
    'پورحسن',
    'محمودی',
    'علیزاده',
    'مرادی'
  ];

  /// Generate survey targets for a user
  static List<SurveyTarget> generateSurveyTargets({
    required String currentUserId,
    int colleagueCount = 10,
  }) {
    final targets = <SurveyTarget>[];

    // Add manager
    final managerId = 'manager_1';
    final managerName = '${_firstNames[0]} ${_lastNames[0]}';
    targets.add(SurveyTarget(
      userId: managerId,
      userName: managerName,
      targetType: SurveyTargetType.manager,
      hasBeenRated: _random.nextBool(),
      lastRatedAt: _random.nextBool()
          ? DateTime.now().subtract(Duration(days: _random.nextInt(30)))
          : null,
    ));

    // Add colleagues
    for (int i = 0; i < colleagueCount; i++) {
      final colleagueId = 'user_${i + 2}';
      final colleagueName = '${_firstNames[(i + 1) % _firstNames.length]} ${_lastNames[(i + 1) % _lastNames.length]}';

      targets.add(SurveyTarget(
        userId: colleagueId,
        userName: colleagueName,
        targetType: SurveyTargetType.colleague,
        hasBeenRated: _random.nextBool(),
        lastRatedAt: _random.nextBool()
            ? DateTime.now().subtract(Duration(days: _random.nextInt(30)))
            : null,
      ));
    }

    return targets;
  }

  /// Generate peer survey responses
  static List<PeerSurveyResponse> generateSurveyResponses({
    required int count,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final responses = <PeerSurveyResponse>[];

    for (int i = 0; i < count; i++) {
      final respondentId = 'user_${i + 1}';
      final respondentName = '${_firstNames[i % _firstNames.length]} ${_lastNames[i % _lastNames.length]}';

      // Random submission date within range
      final daysDifference = endDate.difference(startDate).inDays;
      final randomDays = _random.nextInt(daysDifference + 1);
      final submittedAt = startDate.add(Duration(days: randomDays));

      // 70% have manager ratings
      final managerRating = _random.nextDouble() < 0.7
          ? _generateManagerRating()
          : null;

      // Generate colleague ratings (2-5 colleagues)
      final colleagueCount = 2 + _random.nextInt(4);
      final colleagueRatings = List.generate(
        colleagueCount,
        (index) => _generateColleagueRating(index),
      );

      // 80% have mood reports
      final selfMoodReport = _random.nextDouble() < 0.8
          ? _generateSelfMoodReport(submittedAt)
          : null;

      responses.add(PeerSurveyResponse(
        id: 'response_$i',
        respondentId: respondentId,
        respondentName: respondentName,
        submittedAt: submittedAt,
        lastUpdatedAt: _random.nextBool()
            ? submittedAt.add(Duration(days: _random.nextInt(7)))
            : null,
        managerRating: managerRating,
        colleagueRatings: colleagueRatings,
        selfMoodReport: selfMoodReport,
      ));
    }

    return responses;
  }

  /// Generate a manager rating
  static ManagerRating _generateManagerRating() {
    final managerId = 'manager_1';
    final managerName = '${_firstNames[0]} ${_lastNames[0]}';

    // Generate ratings with some correlation
    final baseRating = 2.0 + _random.nextDouble() * 2.5; // 2.0-4.5

    return ManagerRating(
      managerId: managerId,
      managerName: managerName,
      supportivenessRating:
          (baseRating + (_random.nextDouble() - 0.5)).clamp(1.0, 5.0),
      communicationRating:
          (baseRating + (_random.nextDouble() - 0.5)).clamp(1.0, 5.0),
      fairnessRating:
          (baseRating + (_random.nextDouble() - 0.5)).clamp(1.0, 5.0),
      leadershipRating:
          (baseRating + (_random.nextDouble() - 0.5)).clamp(1.0, 5.0),
      comment: _random.nextDouble() < 0.3 ? _generateManagerComment() : null,
    );
  }

  /// Generate a colleague rating
  static ColleagueRating _generateColleagueRating(int index) {
    final colleagueId = 'user_${index + 10}';
    final colleagueName = '${_firstNames[index % _firstNames.length]} ${_lastNames[index % _lastNames.length]}';

    final baseRating = 2.5 + _random.nextDouble() * 2.0; // 2.5-4.5

    return ColleagueRating(
      colleagueId: colleagueId,
      colleagueName: colleagueName,
      collaborationRating:
          (baseRating + (_random.nextDouble() - 0.5)).clamp(1.0, 5.0),
      helpfulnessRating:
          (baseRating + (_random.nextDouble() - 0.5)).clamp(1.0, 5.0),
      teamSpiritRating:
          (baseRating + (_random.nextDouble() - 0.5)).clamp(1.0, 5.0),
      comment: _random.nextDouble() < 0.2 ? _generateColleagueComment() : null,
    );
  }

  /// Generate a self mood report
  static SelfMoodReport _generateSelfMoodReport(DateTime submittedAt) {
    final moodValue = 1 + _random.nextInt(5); // 1-5
    final mood = MoodLevel.fromNumericValue(moodValue);

    return SelfMoodReport(
      mood: mood,
      comment: _random.nextDouble() < 0.4 ? _generateMoodComment(mood) : null,
      reportedAt: submittedAt,
    );
  }

  /// Generate manager comment
  static String _generateManagerComment() {
    final comments = [
      'مدیر بسیار خوبی است و همیشه پشتیبان تیم است',
      'ارتباطات شفاف و موثر دارد',
      'به نظرات تیم گوش می‌دهد',
      'رهبری قوی و الهام‌بخش',
      'نیاز به بهبود در ارتباطات',
      'کمتر به نظرات تیم توجه می‌کند',
      'باید پشتیبانی بیشتری از تیم داشته باشد',
      'در کل عملکرد خوبی دارد',
      'می‌تواند در برخی زمینه‌ها بهتر شود',
    ];

    return comments[_random.nextInt(comments.length)];
  }

  /// Generate colleague comment
  static String _generateColleagueComment() {
    final comments = [
      'همکار بسیار خوب و کمک‌کننده',
      'همیشه آماده همکاری است',
      'روحیه تیمی خوبی دارد',
      'می‌تواند بیشتر در تیم مشارکت کند',
      'همکار خوبی است',
      'نیاز به ارتباط بیشتر با تیم دارد',
    ];

    return comments[_random.nextInt(comments.length)];
  }

  /// Generate mood comment
  static String _generateMoodComment(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.veryGood:
        return 'امروز روز بسیار خوبی بود';
      case MoodLevel.good:
        return 'همه چیز خوب پیش می‌رود';
      case MoodLevel.neutral:
        return 'روز معمولی';
      case MoodLevel.bad:
        return 'کمی خسته و تحت فشار';
      case MoodLevel.veryBad:
        return 'روز سختی بود';
    }
  }

  /// Generate survey statistics
  static SurveyStatistics generateSurveyStatistics({
    required List<PeerSurveyResponse> responses,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final totalResponses = responses.length;

    // Count ratings
    final totalManagerRatings =
        responses.where((r) => r.managerRating != null).length;
    final totalColleagueRatings =
        responses.fold<int>(0, (sum, r) => sum + r.colleagueRatings.length);
    final totalMoodReports =
        responses.where((r) => r.selfMoodReport != null).length;

    // Calculate averages
    final managerRatings = responses
        .where((r) => r.managerRating != null)
        .map((r) => r.managerRating!.averageRating);
    final averageManagerRating = managerRatings.isNotEmpty
        ? managerRatings.reduce((a, b) => a + b) / managerRatings.length
        : 0.0;

    final colleagueRatings = responses
        .expand((r) => r.colleagueRatings)
        .map((r) => r.averageRating);
    final averageColleagueRating = colleagueRatings.isNotEmpty
        ? colleagueRatings.reduce((a, b) => a + b) / colleagueRatings.length
        : 0.0;

    // Mood distribution
    final moodDistribution = <MoodLevel, int>{};
    for (final response in responses) {
      if (response.selfMoodReport != null) {
        final mood = response.selfMoodReport!.mood;
        moodDistribution[mood] = (moodDistribution[mood] ?? 0) + 1;
      }
    }

    return SurveyStatistics(
      totalResponses: totalResponses,
      totalManagerRatings: totalManagerRatings,
      totalColleagueRatings: totalColleagueRatings,
      totalMoodReports: totalMoodReports,
      averageManagerRating: averageManagerRating,
      averageColleagueRating: averageColleagueRating,
      moodDistribution: moodDistribution,
      periodStart: startDate,
      periodEnd: endDate,
    );
  }
}
