// Drop-Off & Engagement Analytics Data Models
//
// This file contains data models for the Drop-Off & Engagement Analysis feature
// which evaluates employee risk, engagement, and manager support quality.

import 'sentiment_analytics.dart';

/// Main engagement analytics model containing all analysis types
class EngagementAnalytics {
  final DateTime periodStart;
  final DateTime periodEnd;
  final List<EmployeeRiskProfile> employeeRiskProfiles;
  final CompanyEngagementSummary companyEngagementSummary;
  final List<ManagerSupportProfile> managerSupportProfiles;
  final List<SmartInsight> insights;

  EngagementAnalytics({
    required this.periodStart,
    required this.periodEnd,
    required this.employeeRiskProfiles,
    required this.companyEngagementSummary,
    required this.managerSupportProfiles,
    required this.insights,
  });

  factory EngagementAnalytics.fromJson(Map<String, dynamic> json) {
    return EngagementAnalytics(
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      employeeRiskProfiles: (json['employeeRiskProfiles'] as List<dynamic>)
          .map((e) => EmployeeRiskProfile.fromJson(e as Map<String, dynamic>))
          .toList(),
      companyEngagementSummary: CompanyEngagementSummary.fromJson(
          json['companyEngagementSummary'] as Map<String, dynamic>),
      managerSupportProfiles: (json['managerSupportProfiles'] as List<dynamic>)
          .map((e) => ManagerSupportProfile.fromJson(e as Map<String, dynamic>))
          .toList(),
      insights: (json['insights'] as List<dynamic>)
          .map((e) => SmartInsight.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
      'employeeRiskProfiles':
          employeeRiskProfiles.map((e) => e.toJson()).toList(),
      'companyEngagementSummary': companyEngagementSummary.toJson(),
      'managerSupportProfiles':
          managerSupportProfiles.map((e) => e.toJson()).toList(),
      'insights': insights.map((e) => e.toJson()).toList(),
    };
  }
}

/// Employee risk profile with drop-off risk score
class EmployeeRiskProfile {
  final String userId;
  final String userName;
  final String? avatarUrl;
  final String? managerId;
  final String? managerName;
  final double dropOffRiskScore; // 0-100
  final RiskLevel riskLevel;
  final double engagementScore; // 0-100
  final EngagementLevel engagementLevel;
  final ActivityDeclineSignals activityDeclineSignals;
  final BehavioralSignals behavioralSignals;
  final SurveySignals? surveySignals;
  final List<TimeSeriesPoint> riskTrend;
  final List<TimeSeriesPoint> engagementTrend;
  final DateTime lastActiveAt;
  final int daysInactive;

  EmployeeRiskProfile({
    required this.userId,
    required this.userName,
    this.avatarUrl,
    this.managerId,
    this.managerName,
    required this.dropOffRiskScore,
    required this.riskLevel,
    required this.engagementScore,
    required this.engagementLevel,
    required this.activityDeclineSignals,
    required this.behavioralSignals,
    this.surveySignals,
    required this.riskTrend,
    required this.engagementTrend,
    required this.lastActiveAt,
    required this.daysInactive,
  });

  factory EmployeeRiskProfile.fromJson(Map<String, dynamic> json) {
    return EmployeeRiskProfile(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      managerId: json['managerId'] as String?,
      managerName: json['managerName'] as String?,
      dropOffRiskScore: (json['dropOffRiskScore'] as num).toDouble(),
      riskLevel: RiskLevel.fromString(json['riskLevel'] as String),
      engagementScore: (json['engagementScore'] as num).toDouble(),
      engagementLevel:
          EngagementLevel.fromString(json['engagementLevel'] as String),
      activityDeclineSignals: ActivityDeclineSignals.fromJson(
          json['activityDeclineSignals'] as Map<String, dynamic>),
      behavioralSignals: BehavioralSignals.fromJson(
          json['behavioralSignals'] as Map<String, dynamic>),
      surveySignals: json['surveySignals'] != null
          ? SurveySignals.fromJson(
              json['surveySignals'] as Map<String, dynamic>)
          : null,
      riskTrend: (json['riskTrend'] as List<dynamic>)
          .map((e) => TimeSeriesPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      engagementTrend: (json['engagementTrend'] as List<dynamic>)
          .map((e) => TimeSeriesPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastActiveAt: DateTime.parse(json['lastActiveAt'] as String),
      daysInactive: json['daysInactive'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'avatarUrl': avatarUrl,
      'managerId': managerId,
      'managerName': managerName,
      'dropOffRiskScore': dropOffRiskScore,
      'riskLevel': riskLevel.toString(),
      'engagementScore': engagementScore,
      'engagementLevel': engagementLevel.toString(),
      'activityDeclineSignals': activityDeclineSignals.toJson(),
      'behavioralSignals': behavioralSignals.toJson(),
      'surveySignals': surveySignals?.toJson(),
      'riskTrend': riskTrend.map((e) => e.toJson()).toList(),
      'engagementTrend': engagementTrend.map((e) => e.toJson()).toList(),
      'lastActiveAt': lastActiveAt.toIso8601String(),
      'daysInactive': daysInactive,
    };
  }
}

/// Risk levels for drop-off risk
enum RiskLevel {
  low,
  medium,
  high;

  String get displayName {
    switch (this) {
      case RiskLevel.low:
        return 'کم';
      case RiskLevel.medium:
        return 'متوسط';
      case RiskLevel.high:
        return 'بالا';
    }
  }

  String get emoji {
    switch (this) {
      case RiskLevel.low:
        return '🟢';
      case RiskLevel.medium:
        return '🟠';
      case RiskLevel.high:
        return '🔴';
    }
  }

  static RiskLevel fromString(String value) {
    return RiskLevel.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RiskLevel.medium,
    );
  }

  static RiskLevel fromScore(double score) {
    if (score < 40) return RiskLevel.low;
    if (score < 70) return RiskLevel.medium;
    return RiskLevel.high;
  }
}

/// Engagement levels
enum EngagementLevel {
  veryLow,
  low,
  medium,
  high,
  veryHigh;

  String get displayName {
    switch (this) {
      case EngagementLevel.veryLow:
        return 'بسیار پایین';
      case EngagementLevel.low:
        return 'پایین';
      case EngagementLevel.medium:
        return 'متوسط';
      case EngagementLevel.high:
        return 'بالا';
      case EngagementLevel.veryHigh:
        return 'بسیار بالا';
    }
  }

  String get emoji {
    switch (this) {
      case EngagementLevel.veryLow:
        return '😴';
      case EngagementLevel.low:
        return '😐';
      case EngagementLevel.medium:
        return '🙂';
      case EngagementLevel.high:
        return '😊';
      case EngagementLevel.veryHigh:
        return '🤩';
    }
  }

  static EngagementLevel fromString(String value) {
    return EngagementLevel.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EngagementLevel.medium,
    );
  }

  static EngagementLevel fromScore(double score) {
    if (score < 20) return EngagementLevel.veryLow;
    if (score < 40) return EngagementLevel.low;
    if (score < 60) return EngagementLevel.medium;
    if (score < 80) return EngagementLevel.high;
    return EngagementLevel.veryHigh;
  }
}

/// Activity decline signals
class ActivityDeclineSignals {
  final double timelineActivityChange; // percentage change
  final double learningActivityChange;
  final double conversationActivityChange;
  final double loginFrequencyChange;
  final int currentWeekLogins;
  final int previousWeekLogins;
  final bool hasSignificantDecline;

  ActivityDeclineSignals({
    required this.timelineActivityChange,
    required this.learningActivityChange,
    required this.conversationActivityChange,
    required this.loginFrequencyChange,
    required this.currentWeekLogins,
    required this.previousWeekLogins,
    required this.hasSignificantDecline,
  });

  factory ActivityDeclineSignals.fromJson(Map<String, dynamic> json) {
    return ActivityDeclineSignals(
      timelineActivityChange:
          (json['timelineActivityChange'] as num).toDouble(),
      learningActivityChange:
          (json['learningActivityChange'] as num).toDouble(),
      conversationActivityChange:
          (json['conversationActivityChange'] as num).toDouble(),
      loginFrequencyChange: (json['loginFrequencyChange'] as num).toDouble(),
      currentWeekLogins: json['currentWeekLogins'] as int,
      previousWeekLogins: json['previousWeekLogins'] as int,
      hasSignificantDecline: json['hasSignificantDecline'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timelineActivityChange': timelineActivityChange,
      'learningActivityChange': learningActivityChange,
      'conversationActivityChange': conversationActivityChange,
      'loginFrequencyChange': loginFrequencyChange,
      'currentWeekLogins': currentWeekLogins,
      'previousWeekLogins': previousWeekLogins,
      'hasSignificantDecline': hasSignificantDecline,
    };
  }
}

/// Behavioral and sentiment signals
class BehavioralSignals {
  final double averageSentimentScore; // -1 to 1
  final SentimentLevel sentimentLevel;
  final bool hasIncreasedNegativity;
  final int consecutiveInactiveWeeks;
  final double participationRate; // 0-100
  final MoodLevel? averageMoodLevel;
  final bool moodTrendingDown;

  BehavioralSignals({
    required this.averageSentimentScore,
    required this.sentimentLevel,
    required this.hasIncreasedNegativity,
    required this.consecutiveInactiveWeeks,
    required this.participationRate,
    this.averageMoodLevel,
    required this.moodTrendingDown,
  });

  factory BehavioralSignals.fromJson(Map<String, dynamic> json) {
    return BehavioralSignals(
      averageSentimentScore: (json['averageSentimentScore'] as num).toDouble(),
      sentimentLevel:
          SentimentLevel.fromString(json['sentimentLevel'] as String),
      hasIncreasedNegativity: json['hasIncreasedNegativity'] as bool,
      consecutiveInactiveWeeks: json['consecutiveInactiveWeeks'] as int,
      participationRate: (json['participationRate'] as num).toDouble(),
      averageMoodLevel: json['averageMoodLevel'] != null
          ? MoodLevel.fromString(json['averageMoodLevel'] as String)
          : null,
      moodTrendingDown: json['moodTrendingDown'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'averageSentimentScore': averageSentimentScore,
      'sentimentLevel': sentimentLevel.toString(),
      'hasIncreasedNegativity': hasIncreasedNegativity,
      'consecutiveInactiveWeeks': consecutiveInactiveWeeks,
      'participationRate': participationRate,
      'averageMoodLevel': averageMoodLevel?.toString(),
      'moodTrendingDown': moodTrendingDown,
    };
  }
}

/// Survey-based signals
class SurveySignals {
  final double? managerSupportRating; // 1-5
  final double? peerCollaborationRating; // 1-5
  final double? jobSatisfactionRating; // 1-5
  final bool hasLowRatings;
  final List<String> concerns;

  SurveySignals({
    this.managerSupportRating,
    this.peerCollaborationRating,
    this.jobSatisfactionRating,
    required this.hasLowRatings,
    required this.concerns,
  });

  factory SurveySignals.fromJson(Map<String, dynamic> json) {
    return SurveySignals(
      managerSupportRating:
          (json['managerSupportRating'] as num?)?.toDouble(),
      peerCollaborationRating:
          (json['peerCollaborationRating'] as num?)?.toDouble(),
      jobSatisfactionRating:
          (json['jobSatisfactionRating'] as num?)?.toDouble(),
      hasLowRatings: json['hasLowRatings'] as bool,
      concerns: (json['concerns'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'managerSupportRating': managerSupportRating,
      'peerCollaborationRating': peerCollaborationRating,
      'jobSatisfactionRating': jobSatisfactionRating,
      'hasLowRatings': hasLowRatings,
      'concerns': concerns,
    };
  }
}

/// Company-wide engagement summary
class CompanyEngagementSummary {
  final int totalEmployees;
  final int activeEmployees;
  final int highRiskEmployees;
  final int mediumRiskEmployees;
  final int lowRiskEmployees;
  final double averageEngagementScore;
  final double averageDropOffRisk;
  final List<TimeSeriesPoint> engagementTrend;
  final List<TimeSeriesPoint> riskTrend;
  final Map<String, int> engagementDistribution;
  final Map<String, int> riskDistribution;
  final List<EmployeeRiskProfile> topEngagedEmployees;
  final List<EmployeeRiskProfile> atRiskEmployees;
  final EngagementHeatmap engagementHeatmap;

  CompanyEngagementSummary({
    required this.totalEmployees,
    required this.activeEmployees,
    required this.highRiskEmployees,
    required this.mediumRiskEmployees,
    required this.lowRiskEmployees,
    required this.averageEngagementScore,
    required this.averageDropOffRisk,
    required this.engagementTrend,
    required this.riskTrend,
    required this.engagementDistribution,
    required this.riskDistribution,
    required this.topEngagedEmployees,
    required this.atRiskEmployees,
    required this.engagementHeatmap,
  });

  factory CompanyEngagementSummary.fromJson(Map<String, dynamic> json) {
    return CompanyEngagementSummary(
      totalEmployees: json['totalEmployees'] as int,
      activeEmployees: json['activeEmployees'] as int,
      highRiskEmployees: json['highRiskEmployees'] as int,
      mediumRiskEmployees: json['mediumRiskEmployees'] as int,
      lowRiskEmployees: json['lowRiskEmployees'] as int,
      averageEngagementScore:
          (json['averageEngagementScore'] as num).toDouble(),
      averageDropOffRisk: (json['averageDropOffRisk'] as num).toDouble(),
      engagementTrend: (json['engagementTrend'] as List<dynamic>)
          .map((e) => TimeSeriesPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      riskTrend: (json['riskTrend'] as List<dynamic>)
          .map((e) => TimeSeriesPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      engagementDistribution:
          Map<String, int>.from(json['engagementDistribution']),
      riskDistribution: Map<String, int>.from(json['riskDistribution']),
      topEngagedEmployees: (json['topEngagedEmployees'] as List<dynamic>)
          .map((e) => EmployeeRiskProfile.fromJson(e as Map<String, dynamic>))
          .toList(),
      atRiskEmployees: (json['atRiskEmployees'] as List<dynamic>)
          .map((e) => EmployeeRiskProfile.fromJson(e as Map<String, dynamic>))
          .toList(),
      engagementHeatmap: EngagementHeatmap.fromJson(
          json['engagementHeatmap'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalEmployees': totalEmployees,
      'activeEmployees': activeEmployees,
      'highRiskEmployees': highRiskEmployees,
      'mediumRiskEmployees': mediumRiskEmployees,
      'lowRiskEmployees': lowRiskEmployees,
      'averageEngagementScore': averageEngagementScore,
      'averageDropOffRisk': averageDropOffRisk,
      'engagementTrend': engagementTrend.map((e) => e.toJson()).toList(),
      'riskTrend': riskTrend.map((e) => e.toJson()).toList(),
      'engagementDistribution': engagementDistribution,
      'riskDistribution': riskDistribution,
      'topEngagedEmployees':
          topEngagedEmployees.map((e) => e.toJson()).toList(),
      'atRiskEmployees': atRiskEmployees.map((e) => e.toJson()).toList(),
      'engagementHeatmap': engagementHeatmap.toJson(),
    };
  }
}

/// Engagement heatmap data
class EngagementHeatmap {
  final List<HeatmapDay> days;
  final int totalActiveDays;
  final int totalDays;

  EngagementHeatmap({
    required this.days,
    required this.totalActiveDays,
    required this.totalDays,
  });

  factory EngagementHeatmap.fromJson(Map<String, dynamic> json) {
    return EngagementHeatmap(
      days: (json['days'] as List<dynamic>)
          .map((e) => HeatmapDay.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalActiveDays: json['totalActiveDays'] as int,
      totalDays: json['totalDays'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'days': days.map((e) => e.toJson()).toList(),
      'totalActiveDays': totalActiveDays,
      'totalDays': totalDays,
    };
  }
}

/// Single day in heatmap
class HeatmapDay {
  final DateTime date;
  final int activeUsers;
  final double engagementScore;

  HeatmapDay({
    required this.date,
    required this.activeUsers,
    required this.engagementScore,
  });

  factory HeatmapDay.fromJson(Map<String, dynamic> json) {
    return HeatmapDay(
      date: DateTime.parse(json['date'] as String),
      activeUsers: json['activeUsers'] as int,
      engagementScore: (json['engagementScore'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'activeUsers': activeUsers,
      'engagementScore': engagementScore,
    };
  }
}

/// Manager support profile
class ManagerSupportProfile {
  final String managerId;
  final String managerName;
  final String? avatarUrl;
  final double supportivenessScore; // 0-100
  final ManagerRatings ratings;
  final TeamMetrics teamMetrics;
  final List<String> strengths;
  final List<String> improvementAreas;
  final List<ManagerFeedback> recentFeedback;

  ManagerSupportProfile({
    required this.managerId,
    required this.managerName,
    this.avatarUrl,
    required this.supportivenessScore,
    required this.ratings,
    required this.teamMetrics,
    required this.strengths,
    required this.improvementAreas,
    required this.recentFeedback,
  });

  factory ManagerSupportProfile.fromJson(Map<String, dynamic> json) {
    return ManagerSupportProfile(
      managerId: json['managerId'] as String,
      managerName: json['managerName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      supportivenessScore: (json['supportivenessScore'] as num).toDouble(),
      ratings: ManagerRatings.fromJson(json['ratings'] as Map<String, dynamic>),
      teamMetrics:
          TeamMetrics.fromJson(json['teamMetrics'] as Map<String, dynamic>),
      strengths: (json['strengths'] as List<dynamic>).cast<String>(),
      improvementAreas:
          (json['improvementAreas'] as List<dynamic>).cast<String>(),
      recentFeedback: (json['recentFeedback'] as List<dynamic>)
          .map((e) => ManagerFeedback.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'managerId': managerId,
      'managerName': managerName,
      'avatarUrl': avatarUrl,
      'supportivenessScore': supportivenessScore,
      'ratings': ratings.toJson(),
      'teamMetrics': teamMetrics.toJson(),
      'strengths': strengths,
      'improvementAreas': improvementAreas,
      'recentFeedback': recentFeedback.map((e) => e.toJson()).toList(),
    };
  }
}

/// Manager ratings from surveys
class ManagerRatings {
  final double communicationScore; // 1-5
  final double supportivenessScore; // 1-5
  final double fairnessScore; // 1-5
  final double leadershipScore; // 1-5
  final int totalRatings;

  ManagerRatings({
    required this.communicationScore,
    required this.supportivenessScore,
    required this.fairnessScore,
    required this.leadershipScore,
    required this.totalRatings,
  });

  double get averageScore =>
      (communicationScore +
          supportivenessScore +
          fairnessScore +
          leadershipScore) /
      4;

  factory ManagerRatings.fromJson(Map<String, dynamic> json) {
    return ManagerRatings(
      communicationScore: (json['communicationScore'] as num).toDouble(),
      supportivenessScore: (json['supportivenessScore'] as num).toDouble(),
      fairnessScore: (json['fairnessScore'] as num).toDouble(),
      leadershipScore: (json['leadershipScore'] as num).toDouble(),
      totalRatings: json['totalRatings'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'communicationScore': communicationScore,
      'supportivenessScore': supportivenessScore,
      'fairnessScore': fairnessScore,
      'leadershipScore': leadershipScore,
      'totalRatings': totalRatings,
    };
  }
}

/// Team metrics for a manager
class TeamMetrics {
  final int teamSize;
  final double averageTeamEngagement;
  final double averageTeamMood;
  final int highRiskMembers;
  final int activeMembers;
  final List<TimeSeriesPoint> teamEngagementTrend;
  final List<TimeSeriesPoint> teamMoodTrend;

  TeamMetrics({
    required this.teamSize,
    required this.averageTeamEngagement,
    required this.averageTeamMood,
    required this.highRiskMembers,
    required this.activeMembers,
    required this.teamEngagementTrend,
    required this.teamMoodTrend,
  });

  factory TeamMetrics.fromJson(Map<String, dynamic> json) {
    return TeamMetrics(
      teamSize: json['teamSize'] as int,
      averageTeamEngagement: (json['averageTeamEngagement'] as num).toDouble(),
      averageTeamMood: (json['averageTeamMood'] as num).toDouble(),
      highRiskMembers: json['highRiskMembers'] as int,
      activeMembers: json['activeMembers'] as int,
      teamEngagementTrend: (json['teamEngagementTrend'] as List<dynamic>)
          .map((e) => TimeSeriesPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      teamMoodTrend: (json['teamMoodTrend'] as List<dynamic>)
          .map((e) => TimeSeriesPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teamSize': teamSize,
      'averageTeamEngagement': averageTeamEngagement,
      'averageTeamMood': averageTeamMood,
      'highRiskMembers': highRiskMembers,
      'activeMembers': activeMembers,
      'teamEngagementTrend':
          teamEngagementTrend.map((e) => e.toJson()).toList(),
      'teamMoodTrend': teamMoodTrend.map((e) => e.toJson()).toList(),
    };
  }
}

/// Manager feedback from employees
class ManagerFeedback {
  final String id;
  final String employeeId;
  final String? employeeName; // Anonymous option
  final String? comment;
  final Map<String, double> ratings;
  final DateTime submittedAt;

  ManagerFeedback({
    required this.id,
    required this.employeeId,
    this.employeeName,
    this.comment,
    required this.ratings,
    required this.submittedAt,
  });

  factory ManagerFeedback.fromJson(Map<String, dynamic> json) {
    return ManagerFeedback(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      employeeName: json['employeeName'] as String?,
      comment: json['comment'] as String?,
      ratings: Map<String, double>.from(json['ratings']),
      submittedAt: DateTime.parse(json['submittedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'comment': comment,
      'ratings': ratings,
      'submittedAt': submittedAt.toIso8601String(),
    };
  }
}
