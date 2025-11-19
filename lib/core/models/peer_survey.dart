// Peer Survey Data Models
//
// This file contains data models for the peer survey feature where employees
// rate their managers, colleagues, and report their own emotional status.

import 'sentiment_analytics.dart';

/// Main peer survey response
class PeerSurveyResponse {
  final String id;
  final String respondentId;
  final String respondentName;
  final DateTime submittedAt;
  final DateTime? lastUpdatedAt;
  final ManagerRating? managerRating;
  final List<ColleagueRating> colleagueRatings;
  final SelfMoodReport? selfMoodReport;

  PeerSurveyResponse({
    required this.id,
    required this.respondentId,
    required this.respondentName,
    required this.submittedAt,
    this.lastUpdatedAt,
    this.managerRating,
    required this.colleagueRatings,
    this.selfMoodReport,
  });

  factory PeerSurveyResponse.fromJson(Map<String, dynamic> json) {
    return PeerSurveyResponse(
      id: json['id'] as String,
      respondentId: json['respondentId'] as String,
      respondentName: json['respondentName'] as String,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      lastUpdatedAt: json['lastUpdatedAt'] != null
          ? DateTime.parse(json['lastUpdatedAt'] as String)
          : null,
      managerRating: json['managerRating'] != null
          ? ManagerRating.fromJson(
              json['managerRating'] as Map<String, dynamic>)
          : null,
      colleagueRatings: (json['colleagueRatings'] as List<dynamic>)
          .map((e) => ColleagueRating.fromJson(e as Map<String, dynamic>))
          .toList(),
      selfMoodReport: json['selfMoodReport'] != null
          ? SelfMoodReport.fromJson(
              json['selfMoodReport'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'respondentId': respondentId,
      'respondentName': respondentName,
      'submittedAt': submittedAt.toIso8601String(),
      'lastUpdatedAt': lastUpdatedAt?.toIso8601String(),
      'managerRating': managerRating?.toJson(),
      'colleagueRatings': colleagueRatings.map((e) => e.toJson()).toList(),
      'selfMoodReport': selfMoodReport?.toJson(),
    };
  }
}

/// Manager rating from employee
class ManagerRating {
  final String managerId;
  final String managerName;
  final double supportivenessRating; // 1-5
  final double communicationRating; // 1-5
  final double fairnessRating; // 1-5
  final double leadershipRating; // 1-5
  final String? comment;

  ManagerRating({
    required this.managerId,
    required this.managerName,
    required this.supportivenessRating,
    required this.communicationRating,
    required this.fairnessRating,
    required this.leadershipRating,
    this.comment,
  });

  double get averageRating =>
      (supportivenessRating +
          communicationRating +
          fairnessRating +
          leadershipRating) /
      4;

  factory ManagerRating.fromJson(Map<String, dynamic> json) {
    return ManagerRating(
      managerId: json['managerId'] as String,
      managerName: json['managerName'] as String,
      supportivenessRating: (json['supportivenessRating'] as num).toDouble(),
      communicationRating: (json['communicationRating'] as num).toDouble(),
      fairnessRating: (json['fairnessRating'] as num).toDouble(),
      leadershipRating: (json['leadershipRating'] as num).toDouble(),
      comment: json['comment'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'managerId': managerId,
      'managerName': managerName,
      'supportivenessRating': supportivenessRating,
      'communicationRating': communicationRating,
      'fairnessRating': fairnessRating,
      'leadershipRating': leadershipRating,
      'comment': comment,
    };
  }
}

/// Colleague rating from peer
class ColleagueRating {
  final String colleagueId;
  final String colleagueName;
  final double collaborationRating; // 1-5
  final double helpfulnessRating; // 1-5
  final double teamSpiritRating; // 1-5
  final String? comment;

  ColleagueRating({
    required this.colleagueId,
    required this.colleagueName,
    required this.collaborationRating,
    required this.helpfulnessRating,
    required this.teamSpiritRating,
    this.comment,
  });

  double get averageRating =>
      (collaborationRating + helpfulnessRating + teamSpiritRating) / 3;

  factory ColleagueRating.fromJson(Map<String, dynamic> json) {
    return ColleagueRating(
      colleagueId: json['colleagueId'] as String,
      colleagueName: json['colleagueName'] as String,
      collaborationRating: (json['collaborationRating'] as num).toDouble(),
      helpfulnessRating: (json['helpfulnessRating'] as num).toDouble(),
      teamSpiritRating: (json['teamSpiritRating'] as num).toDouble(),
      comment: json['comment'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'colleagueId': colleagueId,
      'colleagueName': colleagueName,
      'collaborationRating': collaborationRating,
      'helpfulnessRating': helpfulnessRating,
      'teamSpiritRating': teamSpiritRating,
      'comment': comment,
    };
  }
}

/// Self-reported mood
class SelfMoodReport {
  final MoodLevel mood;
  final String? comment;
  final DateTime reportedAt;

  SelfMoodReport({
    required this.mood,
    this.comment,
    required this.reportedAt,
  });

  factory SelfMoodReport.fromJson(Map<String, dynamic> json) {
    return SelfMoodReport(
      mood: MoodLevel.fromString(json['mood'] as String),
      comment: json['comment'] as String?,
      reportedAt: DateTime.parse(json['reportedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mood': mood.toString(),
      'comment': comment,
      'reportedAt': reportedAt.toIso8601String(),
    };
  }
}

/// Survey target (person to rate)
class SurveyTarget {
  final String userId;
  final String userName;
  final String? avatarUrl;
  final SurveyTargetType targetType;
  final bool hasBeenRated;
  final DateTime? lastRatedAt;

  SurveyTarget({
    required this.userId,
    required this.userName,
    this.avatarUrl,
    required this.targetType,
    required this.hasBeenRated,
    this.lastRatedAt,
  });

  factory SurveyTarget.fromJson(Map<String, dynamic> json) {
    return SurveyTarget(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      targetType: SurveyTargetType.fromString(json['targetType'] as String),
      hasBeenRated: json['hasBeenRated'] as bool,
      lastRatedAt: json['lastRatedAt'] != null
          ? DateTime.parse(json['lastRatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'avatarUrl': avatarUrl,
      'targetType': targetType.toString(),
      'hasBeenRated': hasBeenRated,
      'lastRatedAt': lastRatedAt?.toIso8601String(),
    };
  }
}

/// Survey target type
enum SurveyTargetType {
  manager,
  colleague;

  String get displayName {
    switch (this) {
      case SurveyTargetType.manager:
        return 'مدیر';
      case SurveyTargetType.colleague:
        return 'همکار';
    }
  }

  static SurveyTargetType fromString(String value) {
    return SurveyTargetType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SurveyTargetType.colleague,
    );
  }
}

/// Survey submission request
class SurveySubmissionRequest {
  final String respondentId;
  final ManagerRating? managerRating;
  final List<ColleagueRating> colleagueRatings;
  final SelfMoodReport? selfMoodReport;

  SurveySubmissionRequest({
    required this.respondentId,
    this.managerRating,
    required this.colleagueRatings,
    this.selfMoodReport,
  });

  Map<String, dynamic> toJson() {
    return {
      'respondentId': respondentId,
      'managerRating': managerRating?.toJson(),
      'colleagueRatings': colleagueRatings.map((e) => e.toJson()).toList(),
      'selfMoodReport': selfMoodReport?.toJson(),
    };
  }
}

/// Survey statistics
class SurveyStatistics {
  final int totalResponses;
  final int totalManagerRatings;
  final int totalColleagueRatings;
  final int totalMoodReports;
  final double averageManagerRating;
  final double averageColleagueRating;
  final Map<MoodLevel, int> moodDistribution;
  final DateTime periodStart;
  final DateTime periodEnd;

  SurveyStatistics({
    required this.totalResponses,
    required this.totalManagerRatings,
    required this.totalColleagueRatings,
    required this.totalMoodReports,
    required this.averageManagerRating,
    required this.averageColleagueRating,
    required this.moodDistribution,
    required this.periodStart,
    required this.periodEnd,
  });

  factory SurveyStatistics.fromJson(Map<String, dynamic> json) {
    return SurveyStatistics(
      totalResponses: json['totalResponses'] as int,
      totalManagerRatings: json['totalManagerRatings'] as int,
      totalColleagueRatings: json['totalColleagueRatings'] as int,
      totalMoodReports: json['totalMoodReports'] as int,
      averageManagerRating: (json['averageManagerRating'] as num).toDouble(),
      averageColleagueRating:
          (json['averageColleagueRating'] as num).toDouble(),
      moodDistribution: (json['moodDistribution'] as Map<String, dynamic>)
          .map((key, value) =>
              MapEntry(MoodLevel.fromString(key), value as int)),
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalResponses': totalResponses,
      'totalManagerRatings': totalManagerRatings,
      'totalColleagueRatings': totalColleagueRatings,
      'totalMoodReports': totalMoodReports,
      'averageManagerRating': averageManagerRating,
      'averageColleagueRating': averageColleagueRating,
      'moodDistribution':
          moodDistribution.map((key, value) => MapEntry(key.toString(), value)),
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
    };
  }
}
