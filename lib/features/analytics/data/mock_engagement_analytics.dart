import 'dart:math';
import 'package:shahrnet_admin/core/models/engagement_analytics.dart';
import 'package:shahrnet_admin/core/models/sentiment_analytics.dart';

/// Mock data generator for Engagement Analytics
class MockEngagementAnalytics {
  static final Random _random = Random(42); // Seeded for reproducibility

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

  /// Generate mock engagement analytics data for a date range
  static EngagementAnalytics generateEngagementAnalytics({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final daysDifference = endDate.difference(startDate).inDays;
    final totalEmployees = 50 + _random.nextInt(50); // 50-100 employees

    // Generate employee risk profiles
    final employeeRiskProfiles = _generateEmployeeRiskProfiles(
      count: totalEmployees,
      startDate: startDate,
      endDate: endDate,
      daysDifference: daysDifference,
    );

    // Generate manager profiles (managers are subset of employees)
    final managerCount = (totalEmployees * 0.15).ceil(); // ~15% are managers
    final managerProfiles = _generateManagerSupportProfiles(
      count: managerCount,
      employees: employeeRiskProfiles,
      startDate: startDate,
      endDate: endDate,
      daysDifference: daysDifference,
    );

    // Generate company engagement summary
    final companyEngagementSummary = _generateCompanyEngagementSummary(
      employeeRiskProfiles: employeeRiskProfiles,
      startDate: startDate,
      endDate: endDate,
      daysDifference: daysDifference,
    );

    // Generate insights
    final insights = _generateInsights(
      employeeRiskProfiles: employeeRiskProfiles,
      managerProfiles: managerProfiles,
      companyEngagementSummary: companyEngagementSummary,
      daysDifference: daysDifference,
    );

    return EngagementAnalytics(
      periodStart: startDate,
      periodEnd: endDate,
      employeeRiskProfiles: employeeRiskProfiles,
      companyEngagementSummary: companyEngagementSummary,
      managerSupportProfiles: managerProfiles,
      insights: insights,
    );
  }

  /// Generate employee risk profiles
  static List<EmployeeRiskProfile> _generateEmployeeRiskProfiles({
    required int count,
    required DateTime startDate,
    required DateTime endDate,
    required int daysDifference,
  }) {
    final profiles = <EmployeeRiskProfile>[];

    for (int i = 0; i < count; i++) {
      final userId = 'user_${i + 1}';
      final userName = '${_firstNames[_random.nextInt(_firstNames.length)]} ${_lastNames[_random.nextInt(_lastNames.length)]}';

      // Generate varied risk scores with realistic distribution
      // Most employees should have low-medium risk
      final riskDistribution = _random.nextDouble();
      final dropOffRiskScore = riskDistribution < 0.7
          ? _random.nextDouble() * 40 // 70% low risk (0-40)
          : riskDistribution < 0.9
              ? 40 + _random.nextDouble() * 30 // 20% medium risk (40-70)
              : 70 + _random.nextDouble() * 30; // 10% high risk (70-100)

      final riskLevel = RiskLevel.fromScore(dropOffRiskScore);

      // Engagement score is inversely related to risk (but with some variance)
      final baseEngagement = 100 - dropOffRiskScore;
      final engagementScore =
          (baseEngagement + (_random.nextDouble() * 20 - 10)).clamp(0.0, 100.0);
      final engagementLevel = EngagementLevel.fromScore(engagementScore);

      // Activity decline signals
      final activityDeclineSignals = _generateActivityDeclineSignals(
        riskScore: dropOffRiskScore,
      );

      // Behavioral signals
      final behavioralSignals = _generateBehavioralSignals(
        riskScore: dropOffRiskScore,
      );

      // Survey signals (70% of employees have survey data)
      final surveySignals = _random.nextDouble() < 0.7
          ? _generateSurveySignals(riskScore: dropOffRiskScore)
          : null;

      // Risk and engagement trends
      final riskTrend = _generateRiskTrend(
        startDate: startDate,
        endDate: endDate,
        currentScore: dropOffRiskScore,
      );

      final engagementTrend = _generateEngagementTrend(
        startDate: startDate,
        endDate: endDate,
        currentScore: engagementScore,
      );

      // Last active and days inactive
      final daysInactive = riskLevel == RiskLevel.high
          ? _random.nextInt(10) + 3 // 3-13 days
          : riskLevel == RiskLevel.medium
              ? _random.nextInt(5) + 1 // 1-6 days
              : _random.nextInt(2); // 0-2 days

      final lastActiveAt = DateTime.now().subtract(Duration(days: daysInactive));

      profiles.add(EmployeeRiskProfile(
        userId: userId,
        userName: userName,
        avatarUrl: null,
        managerId: null, // Will be assigned later
        managerName: null,
        dropOffRiskScore: dropOffRiskScore,
        riskLevel: riskLevel,
        engagementScore: engagementScore,
        engagementLevel: engagementLevel,
        activityDeclineSignals: activityDeclineSignals,
        behavioralSignals: behavioralSignals,
        surveySignals: surveySignals,
        riskTrend: riskTrend,
        engagementTrend: engagementTrend,
        lastActiveAt: lastActiveAt,
        daysInactive: daysInactive,
      ));
    }

    return profiles;
  }

  /// Generate activity decline signals
  static ActivityDeclineSignals _generateActivityDeclineSignals({
    required double riskScore,
  }) {
    // Higher risk = more activity decline
    final declineBase = (riskScore / 100) * -50; // Up to -50% decline

    final timelineActivityChange =
        declineBase + (_random.nextDouble() * 20 - 10);
    final learningActivityChange =
        declineBase + (_random.nextDouble() * 20 - 10);
    final conversationActivityChange =
        declineBase + (_random.nextDouble() * 20 - 10);
    final loginFrequencyChange = declineBase + (_random.nextDouble() * 20 - 10);

    final previousWeekLogins = 5 + _random.nextInt(10); // 5-15
    final currentWeekLogins = riskScore > 60
        ? (previousWeekLogins * 0.3).round() // Significant drop
        : (previousWeekLogins * 0.8).round(); // Minor drop

    final hasSignificantDecline = timelineActivityChange < -20 ||
        learningActivityChange < -20 ||
        conversationActivityChange < -20;

    return ActivityDeclineSignals(
      timelineActivityChange: timelineActivityChange,
      learningActivityChange: learningActivityChange,
      conversationActivityChange: conversationActivityChange,
      loginFrequencyChange: loginFrequencyChange,
      currentWeekLogins: currentWeekLogins,
      previousWeekLogins: previousWeekLogins,
      hasSignificantDecline: hasSignificantDecline,
    );
  }

  /// Generate behavioral signals
  static BehavioralSignals _generateBehavioralSignals({
    required double riskScore,
  }) {
    // Higher risk = more negative sentiment
    final sentimentBase = 0.5 - (riskScore / 100); // -0.5 to 0.5
    final averageSentimentScore =
        (sentimentBase + (_random.nextDouble() * 0.4 - 0.2)).clamp(-1.0, 1.0);
    final sentimentLevel = SentimentLevel.fromScore(averageSentimentScore);

    final hasIncreasedNegativity = averageSentimentScore < -0.2;
    final consecutiveInactiveWeeks = riskScore > 70
        ? _random.nextInt(3) + 1 // 1-3 weeks
        : 0;

    final participationRate = (100 - riskScore + (_random.nextDouble() * 20 - 10))
        .clamp(0.0, 100.0);

    // Mood level (if available)
    final hasMoodData = _random.nextDouble() < 0.6;
    final averageMoodLevel = hasMoodData
        ? MoodLevel.fromNumericValue(
            (3 + (averageSentimentScore * 2)).round().clamp(1, 5))
        : null;

    final moodTrendingDown = hasMoodData && averageMoodLevel != null
        ? averageMoodLevel.numericValue < 3
        : false;

    return BehavioralSignals(
      averageSentimentScore: averageSentimentScore,
      sentimentLevel: sentimentLevel,
      hasIncreasedNegativity: hasIncreasedNegativity,
      consecutiveInactiveWeeks: consecutiveInactiveWeeks,
      participationRate: participationRate,
      averageMoodLevel: averageMoodLevel,
      moodTrendingDown: moodTrendingDown,
    );
  }

  /// Generate survey signals
  static SurveySignals _generateSurveySignals({
    required double riskScore,
  }) {
    // Higher risk = lower ratings
    final ratingBase = 3.5 - (riskScore / 100) * 2; // 1.5 to 3.5

    final managerSupportRating =
        (ratingBase + _random.nextDouble() * 1.5).clamp(1.0, 5.0);
    final peerCollaborationRating =
        (ratingBase + _random.nextDouble() * 1.5).clamp(1.0, 5.0);
    final jobSatisfactionRating =
        (ratingBase + _random.nextDouble() * 1.5).clamp(1.0, 5.0);

    final hasLowRatings = managerSupportRating < 2.5 ||
        peerCollaborationRating < 2.5 ||
        jobSatisfactionRating < 2.5;

    final concerns = <String>[];
    if (managerSupportRating < 2.5) concerns.add('پشتیبانی مدیر');
    if (peerCollaborationRating < 2.5) concerns.add('همکاری تیمی');
    if (jobSatisfactionRating < 2.5) concerns.add('رضایت شغلی');

    return SurveySignals(
      managerSupportRating: managerSupportRating,
      peerCollaborationRating: peerCollaborationRating,
      jobSatisfactionRating: jobSatisfactionRating,
      hasLowRatings: hasLowRatings,
      concerns: concerns,
    );
  }

  /// Generate risk trend over time
  static List<TimeSeriesPoint> _generateRiskTrend({
    required DateTime startDate,
    required DateTime endDate,
    required double currentScore,
  }) {
    final daysDifference = endDate.difference(startDate).inDays;
    final points = <TimeSeriesPoint>[];

    // Sample every few days
    final sampleInterval = (daysDifference / 10).ceil().clamp(1, 7);

    // Start from a lower risk and trend upward
    double previousScore = currentScore - 15 - _random.nextDouble() * 10;

    for (int i = 0; i <= daysDifference; i += sampleInterval) {
      final date = startDate.add(Duration(days: i));
      final progress = i / daysDifference;

      // Gradually increase risk toward current score
      final targetScore = previousScore + (currentScore - previousScore) * 0.3;
      final value = (targetScore + (_random.nextDouble() * 5 - 2.5)).clamp(0.0, 100.0);

      points.add(TimeSeriesPoint(date: date, value: value));
      previousScore = value;
    }

    // Ensure last point matches current score
    points.add(TimeSeriesPoint(date: endDate, value: currentScore));

    return points;
  }

  /// Generate engagement trend over time
  static List<TimeSeriesPoint> _generateEngagementTrend({
    required DateTime startDate,
    required DateTime endDate,
    required double currentScore,
  }) {
    final daysDifference = endDate.difference(startDate).inDays;
    final points = <TimeSeriesPoint>[];

    final sampleInterval = (daysDifference / 10).ceil().clamp(1, 7);

    // Start from a higher engagement and trend downward
    double previousScore = currentScore + 15 + _random.nextDouble() * 10;

    for (int i = 0; i <= daysDifference; i += sampleInterval) {
      final date = startDate.add(Duration(days: i));
      final progress = i / daysDifference;

      final targetScore = previousScore - (previousScore - currentScore) * 0.3;
      final value = (targetScore + (_random.nextDouble() * 5 - 2.5)).clamp(0.0, 100.0);

      points.add(TimeSeriesPoint(date: date, value: value));
      previousScore = value;
    }

    points.add(TimeSeriesPoint(date: endDate, value: currentScore));

    return points;
  }

  /// Generate company engagement summary
  static CompanyEngagementSummary _generateCompanyEngagementSummary({
    required List<EmployeeRiskProfile> employeeRiskProfiles,
    required DateTime startDate,
    required DateTime endDate,
    required int daysDifference,
  }) {
    final totalEmployees = employeeRiskProfiles.length;
    final activeEmployees = employeeRiskProfiles
        .where((e) => e.daysInactive <= 7)
        .length;

    // Count by risk level
    final highRiskEmployees =
        employeeRiskProfiles.where((e) => e.riskLevel == RiskLevel.high).length;
    final mediumRiskEmployees = employeeRiskProfiles
        .where((e) => e.riskLevel == RiskLevel.medium)
        .length;
    final lowRiskEmployees =
        employeeRiskProfiles.where((e) => e.riskLevel == RiskLevel.low).length;

    // Calculate averages
    final averageEngagementScore = employeeRiskProfiles
            .map((e) => e.engagementScore)
            .reduce((a, b) => a + b) /
        totalEmployees;
    final averageDropOffRisk = employeeRiskProfiles
            .map((e) => e.dropOffRiskScore)
            .reduce((a, b) => a + b) /
        totalEmployees;

    // Company-wide trends
    final engagementTrend = _generateCompanyTrend(
      startDate: startDate,
      endDate: endDate,
      currentValue: averageEngagementScore,
      trending: 'down',
    );

    final riskTrend = _generateCompanyTrend(
      startDate: startDate,
      endDate: endDate,
      currentValue: averageDropOffRisk,
      trending: 'up',
    );

    // Distributions
    final engagementDistribution = <String, int>{};
    for (final profile in employeeRiskProfiles) {
      final level = profile.engagementLevel.displayName;
      engagementDistribution[level] = (engagementDistribution[level] ?? 0) + 1;
    }

    final riskDistribution = <String, int>{
      'بالا': highRiskEmployees,
      'متوسط': mediumRiskEmployees,
      'کم': lowRiskEmployees,
    };

    // Top engaged employees
    final sortedByEngagement = List<EmployeeRiskProfile>.from(employeeRiskProfiles)
      ..sort((a, b) => b.engagementScore.compareTo(a.engagementScore));
    final topEngagedEmployees = sortedByEngagement.take(10).toList();

    // At-risk employees
    final atRiskEmployees = employeeRiskProfiles
        .where((e) =>
            e.riskLevel == RiskLevel.high || e.riskLevel == RiskLevel.medium)
        .toList()
      ..sort((a, b) => b.dropOffRiskScore.compareTo(a.dropOffRiskScore));

    // Engagement heatmap
    final engagementHeatmap = _generateEngagementHeatmap(
      startDate: startDate,
      endDate: endDate,
      totalEmployees: totalEmployees,
    );

    return CompanyEngagementSummary(
      totalEmployees: totalEmployees,
      activeEmployees: activeEmployees,
      highRiskEmployees: highRiskEmployees,
      mediumRiskEmployees: mediumRiskEmployees,
      lowRiskEmployees: lowRiskEmployees,
      averageEngagementScore: averageEngagementScore,
      averageDropOffRisk: averageDropOffRisk,
      engagementTrend: engagementTrend,
      riskTrend: riskTrend,
      engagementDistribution: engagementDistribution,
      riskDistribution: riskDistribution,
      topEngagedEmployees: topEngagedEmployees,
      atRiskEmployees: atRiskEmployees.take(20).toList(),
      engagementHeatmap: engagementHeatmap,
    );
  }

  /// Generate company-wide trend
  static List<TimeSeriesPoint> _generateCompanyTrend({
    required DateTime startDate,
    required DateTime endDate,
    required double currentValue,
    required String trending,
  }) {
    final daysDifference = endDate.difference(startDate).inDays;
    final points = <TimeSeriesPoint>[];
    final sampleInterval = (daysDifference / 15).ceil().clamp(1, 7);

    double previousValue = trending == 'up'
        ? currentValue - 10 - _random.nextDouble() * 5
        : currentValue + 10 + _random.nextDouble() * 5;

    for (int i = 0; i <= daysDifference; i += sampleInterval) {
      final date = startDate.add(Duration(days: i));
      final progress = i / daysDifference;

      final targetValue = previousValue + (currentValue - previousValue) * 0.2;
      final value = (targetValue + (_random.nextDouble() * 3 - 1.5)).clamp(0.0, 100.0);

      points.add(TimeSeriesPoint(date: date, value: value));
      previousValue = value;
    }

    points.add(TimeSeriesPoint(date: endDate, value: currentValue));

    return points;
  }

  /// Generate engagement heatmap
  static EngagementHeatmap _generateEngagementHeatmap({
    required DateTime startDate,
    required DateTime endDate,
    required int totalEmployees,
  }) {
    final daysDifference = endDate.difference(startDate).inDays;
    final days = <HeatmapDay>[];
    int totalActiveDays = 0;

    for (int i = 0; i <= daysDifference; i++) {
      final date = startDate.add(Duration(days: i));

      // Weekend has lower activity
      final isWeekend = date.weekday == DateTime.friday || date.weekday == DateTime.saturday;
      final baseActive = isWeekend
          ? (totalEmployees * 0.2).round()
          : (totalEmployees * 0.7).round();

      final activeUsers = baseActive + _random.nextInt(10) - 5;
      final engagementScore = (activeUsers / totalEmployees * 100)
          .clamp(0.0, 100.0);

      if (activeUsers > 0) totalActiveDays++;

      days.add(HeatmapDay(
        date: date,
        activeUsers: activeUsers,
        engagementScore: engagementScore,
      ));
    }

    return EngagementHeatmap(
      days: days,
      totalActiveDays: totalActiveDays,
      totalDays: daysDifference + 1,
    );
  }

  /// Generate manager support profiles
  static List<ManagerSupportProfile> _generateManagerSupportProfiles({
    required int count,
    required List<EmployeeRiskProfile> employees,
    required DateTime startDate,
    required DateTime endDate,
    required int daysDifference,
  }) {
    final profiles = <ManagerSupportProfile>[];
    final managersPerTeam = (employees.length / count).ceil();

    for (int i = 0; i < count; i++) {
      final managerId = 'manager_${i + 1}';
      final managerName = '${_firstNames[_random.nextInt(_firstNames.length)]} ${_lastNames[_random.nextInt(_lastNames.length)]}';

      // Assign team members to this manager
      final startRaw = i * managersPerTeam;
      final teamStartIndex =
          startRaw > employees.length ? employees.length : startRaw;
      final rawEndIndex = (i + 1) * managersPerTeam;
      final cappedEnd =
          rawEndIndex > employees.length ? employees.length : rawEndIndex;
      final teamEndIndex =
          cappedEnd < teamStartIndex ? teamStartIndex : cappedEnd;
      final teamMembers = teamStartIndex >= employees.length
          ? <EmployeeRiskProfile>[]
          : employees.sublist(teamStartIndex, teamEndIndex);

      // Calculate manager supportiveness score
      final baseScore = 50 + _random.nextDouble() * 40; // 50-90
      final supportivenessScore = baseScore;

      // Manager ratings
      final ratings = ManagerRatings(
        communicationScore: (2.5 + _random.nextDouble() * 2.5).clamp(1.0, 5.0),
        supportivenessScore: (2.5 + _random.nextDouble() * 2.5).clamp(1.0, 5.0),
        fairnessScore: (2.5 + _random.nextDouble() * 2.5).clamp(1.0, 5.0),
        leadershipScore: (2.5 + _random.nextDouble() * 2.5).clamp(1.0, 5.0),
        totalRatings: teamMembers.length,
      );

      // Team metrics
      final teamMetrics = _generateTeamMetrics(
        teamMembers: teamMembers,
        startDate: startDate,
        endDate: endDate,
      );

      // Strengths and improvement areas
      final strengths = <String>[];
      final improvementAreas = <String>[];

      if (ratings.communicationScore >= 4.0) {
        strengths.add('ارتباطات قوی');
      } else if (ratings.communicationScore < 3.0) {
        improvementAreas.add('بهبود ارتباطات');
      }

      if (ratings.supportivenessScore >= 4.0) {
        strengths.add('پشتیبانی عالی از تیم');
      } else if (ratings.supportivenessScore < 3.0) {
        improvementAreas.add('افزایش پشتیبانی تیم');
      }

      if (teamMetrics.averageTeamEngagement >= 70) {
        strengths.add('تیم پرانرژی');
      } else if (teamMetrics.averageTeamEngagement < 50) {
        improvementAreas.add('بهبود انگیزش تیم');
      }

      // Recent feedback
      final recentFeedback = _generateManagerFeedback(
        managerId: managerId,
        teamMembers: teamMembers,
      );

      profiles.add(ManagerSupportProfile(
        managerId: managerId,
        managerName: managerName,
        supportivenessScore: supportivenessScore,
        ratings: ratings,
        teamMetrics: teamMetrics,
        strengths: strengths,
        improvementAreas: improvementAreas,
        recentFeedback: recentFeedback,
      ));
    }

    return profiles;
  }

  /// Generate team metrics
  static TeamMetrics _generateTeamMetrics({
    required List<EmployeeRiskProfile> teamMembers,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final teamSize = teamMembers.length;

    if (teamSize == 0) {
      return TeamMetrics(
        teamSize: 0,
        averageTeamEngagement: 0,
        averageTeamMood: 0,
        highRiskMembers: 0,
        activeMembers: 0,
        teamEngagementTrend: [],
        teamMoodTrend: [],
      );
    }

    final averageTeamEngagement = teamMembers
            .map((e) => e.engagementScore)
            .reduce((a, b) => a + b) /
        teamSize;

    final moodValues = teamMembers
        .where((e) => e.behavioralSignals.averageMoodLevel != null)
        .map((e) => e.behavioralSignals.averageMoodLevel!.numericValue.toDouble());

    final averageTeamMood = moodValues.isNotEmpty
        ? moodValues.reduce((a, b) => a + b) / moodValues.length
        : 3.0;

    final highRiskMembers =
        teamMembers.where((e) => e.riskLevel == RiskLevel.high).length;
    final activeMembers =
        teamMembers.where((e) => e.daysInactive <= 7).length;

    // Team trends
    final teamEngagementTrend = _generateCompanyTrend(
      startDate: startDate,
      endDate: endDate,
      currentValue: averageTeamEngagement,
      trending: 'stable',
    );

    final teamMoodTrend = _generateCompanyTrend(
      startDate: startDate,
      endDate: endDate,
      currentValue: averageTeamMood * 20, // Scale to 0-100
      trending: 'stable',
    );

    return TeamMetrics(
      teamSize: teamSize,
      averageTeamEngagement: averageTeamEngagement,
      averageTeamMood: averageTeamMood,
      highRiskMembers: highRiskMembers,
      activeMembers: activeMembers,
      teamEngagementTrend: teamEngagementTrend,
      teamMoodTrend: teamMoodTrend,
    );
  }

  /// Generate manager feedback
  static List<ManagerFeedback> _generateManagerFeedback({
    required String managerId,
    required List<EmployeeRiskProfile> teamMembers,
  }) {
    final feedbacks = <ManagerFeedback>[];
    final feedbackCount = (teamMembers.length * 0.6).ceil().clamp(1, 10);

    for (int i = 0; i < feedbackCount; i++) {
      if (i >= teamMembers.length) break;

      final employee = teamMembers[i];
      final isAnonymous = _random.nextDouble() < 0.3;

      final ratings = {
        'communication': (2.0 + _random.nextDouble() * 3.0).clamp(1.0, 5.0),
        'supportiveness': (2.0 + _random.nextDouble() * 3.0).clamp(1.0, 5.0),
        'fairness': (2.0 + _random.nextDouble() * 3.0).clamp(1.0, 5.0),
        'leadership': (2.0 + _random.nextDouble() * 3.0).clamp(1.0, 5.0),
      };

      final hasComment = _random.nextDouble() < 0.4;
      final comment = hasComment
          ? _generateFeedbackComment(ratings)
          : null;

      feedbacks.add(ManagerFeedback(
        id: 'feedback_${managerId}_$i',
        employeeId: employee.userId,
        employeeName: isAnonymous ? null : employee.userName,
        comment: comment,
        ratings: ratings,
        submittedAt: DateTime.now().subtract(Duration(days: _random.nextInt(30))),
      ));
    }

    return feedbacks;
  }

  /// Generate feedback comment
  static String _generateFeedbackComment(Map<String, double> ratings) {
    final avgRating = ratings.values.reduce((a, b) => a + b) / ratings.length;

    final positiveComments = [
      'مدیر بسیار خوبی است و همیشه پشتیبان تیم است',
      'ارتباطات شفاف و موثر دارد',
      'به نظرات تیم گوش می‌دهد',
      'رهبری قوی و الهام‌بخش',
    ];

    final neutralComments = [
      'در کل عملکرد خوبی دارد',
      'می‌تواند در برخی زمینه‌ها بهتر شود',
      'نیاز به ارتباطات بیشتر با تیم',
    ];

    final negativeComments = [
      'نیاز به بهبود در ارتباطات',
      'کمتر به نظرات تیم توجه می‌کند',
      'باید پشتیبانی بیشتری از تیم داشته باشد',
    ];

    if (avgRating >= 4.0) {
      return positiveComments[_random.nextInt(positiveComments.length)];
    } else if (avgRating >= 3.0) {
      return neutralComments[_random.nextInt(neutralComments.length)];
    } else {
      return negativeComments[_random.nextInt(negativeComments.length)];
    }
  }

  /// Generate smart insights
  static List<SmartInsight> _generateInsights({
    required List<EmployeeRiskProfile> employeeRiskProfiles,
    required List<ManagerSupportProfile> managerProfiles,
    required CompanyEngagementSummary companyEngagementSummary,
    required int daysDifference,
  }) {
    final insights = <SmartInsight>[];

    // Risk-related insights
    if (companyEngagementSummary.highRiskEmployees > 0) {
      insights.add(SmartInsight(
        id: 'insight_high_risk',
        title: 'کارمندان در معرض خطر',
        description:
            '${companyEngagementSummary.highRiskEmployees} کارمند در معرض خطر ترک سازمان هستند. توجه فوری مورد نیاز است.',
        type: InsightType.warning,
        generatedAt: DateTime.now(),
      ));
    }

    // Engagement trends
    final engagementChange = companyEngagementSummary.engagementTrend.length >= 2
        ? companyEngagementSummary.engagementTrend.last.value -
            companyEngagementSummary.engagementTrend.first.value
        : 0;

    if (engagementChange < -10) {
      insights.add(SmartInsight(
        id: 'insight_engagement_drop',
        title: 'کاهش میزان مشارکت',
        description:
            'میزان مشارکت کارمندان ${engagementChange.abs().toStringAsFixed(1)}% کاهش یافته است.',
        type: InsightType.warning,
        generatedAt: DateTime.now(),
      ));
    } else if (engagementChange > 10) {
      insights.add(SmartInsight(
        id: 'insight_engagement_increase',
        title: 'افزایش میزان مشارکت',
        description:
            'میزان مشارکت کارمندان ${engagementChange.toStringAsFixed(1)}% افزایش یافته است!',
        type: InsightType.positive,
        generatedAt: DateTime.now(),
      ));
    }

    // Manager performance
    final topManager = managerProfiles.isNotEmpty
        ? managerProfiles.reduce((a, b) =>
            a.supportivenessScore > b.supportivenessScore ? a : b)
        : null;

    if (topManager != null && topManager.supportivenessScore >= 80) {
      insights.add(SmartInsight(
        id: 'insight_top_manager',
        title: 'مدیر برتر',
        description:
            '${topManager.managerName} با امتیاز ${topManager.supportivenessScore.toStringAsFixed(0)} بهترین عملکرد را دارد.',
        type: InsightType.positive,
        generatedAt: DateTime.now(),
      ));
    }

    // Activity correlation
    final courseCompletedEmployees = employeeRiskProfiles
        .where((e) => e.engagementScore > 60)
        .length;
    if (courseCompletedEmployees > employeeRiskProfiles.length * 0.5) {
      insights.add(SmartInsight(
        id: 'insight_learning_correlation',
        title: 'تاثیر یادگیری',
        description:
            'کارمندانی که در دوره‌های آموزشی شرکت می‌کنند، میزان مشارکت بالاتری دارند.',
        type: InsightType.trend,
        generatedAt: DateTime.now(),
      ));
    }

    return insights;
  }
}
