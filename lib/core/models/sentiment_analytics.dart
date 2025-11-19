// Sentiment Analytics Data Models
//
// This file contains data models for the Sentiment Analytics feature which tracks
// user emotional status through three sources:
// 1. Activity-based emotional status
// 2. Text-based sentiment analysis
// 3. Self-reported emotional status

/// Main sentiment analytics model containing all three analysis types
class SentimentAnalytics {
  final DateTime periodStart;
  final DateTime periodEnd;
  final ActivityBasedEmotion activityBasedEmotion;
  final TextBasedSentiment textBasedSentiment;
  final SelfReportedMood selfReportedMood;
  final List<SmartInsight> insights;

  SentimentAnalytics({
    required this.periodStart,
    required this.periodEnd,
    required this.activityBasedEmotion,
    required this.textBasedSentiment,
    required this.selfReportedMood,
    required this.insights,
  });

  factory SentimentAnalytics.fromJson(Map<String, dynamic> json) {
    return SentimentAnalytics(
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      activityBasedEmotion: ActivityBasedEmotion.fromJson(
          json['activityBasedEmotion'] as Map<String, dynamic>),
      textBasedSentiment: TextBasedSentiment.fromJson(
          json['textBasedSentiment'] as Map<String, dynamic>),
      selfReportedMood: SelfReportedMood.fromJson(
          json['selfReportedMood'] as Map<String, dynamic>),
      insights: (json['insights'] as List<dynamic>)
          .map((e) => SmartInsight.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
      'activityBasedEmotion': activityBasedEmotion.toJson(),
      'textBasedSentiment': textBasedSentiment.toJson(),
      'selfReportedMood': selfReportedMood.toJson(),
      'insights': insights.map((e) => e.toJson()).toList(),
    };
  }
}

/// Activity-based emotional status tracking
class ActivityBasedEmotion {
  final int postsCreated;
  final int commentsWritten;
  final int likesGiven;
  final int pollsParticipated;
  final int coursesCompleted;
  final int messagesSent;
  final int callsMade;
  final int daysActive;
  final double engagementScore; // 0-100 calculated index
  final EmotionalStatus emotionalStatus;
  final List<TimeSeriesPoint> activityTrend;
  final Map<String, int> activityBreakdown;

  ActivityBasedEmotion({
    required this.postsCreated,
    required this.commentsWritten,
    required this.likesGiven,
    required this.pollsParticipated,
    required this.coursesCompleted,
    required this.messagesSent,
    required this.callsMade,
    required this.daysActive,
    required this.engagementScore,
    required this.emotionalStatus,
    required this.activityTrend,
    required this.activityBreakdown,
  });

  int get totalActivities =>
      postsCreated +
      commentsWritten +
      likesGiven +
      pollsParticipated +
      coursesCompleted +
      messagesSent +
      callsMade;

  factory ActivityBasedEmotion.fromJson(Map<String, dynamic> json) {
    return ActivityBasedEmotion(
      postsCreated: json['postsCreated'] as int,
      commentsWritten: json['commentsWritten'] as int,
      likesGiven: json['likesGiven'] as int,
      pollsParticipated: json['pollsParticipated'] as int,
      coursesCompleted: json['coursesCompleted'] as int,
      messagesSent: json['messagesSent'] as int,
      callsMade: json['callsMade'] as int,
      daysActive: json['daysActive'] as int,
      engagementScore: (json['engagementScore'] as num).toDouble(),
      emotionalStatus:
          EmotionalStatus.fromString(json['emotionalStatus'] as String),
      activityTrend: (json['activityTrend'] as List<dynamic>)
          .map((e) => TimeSeriesPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      activityBreakdown: Map<String, int>.from(json['activityBreakdown']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postsCreated': postsCreated,
      'commentsWritten': commentsWritten,
      'likesGiven': likesGiven,
      'pollsParticipated': pollsParticipated,
      'coursesCompleted': coursesCompleted,
      'messagesSent': messagesSent,
      'callsMade': callsMade,
      'daysActive': daysActive,
      'engagementScore': engagementScore,
      'emotionalStatus': emotionalStatus.toString(),
      'activityTrend': activityTrend.map((e) => e.toJson()).toList(),
      'activityBreakdown': activityBreakdown,
    };
  }
}

/// Emotional status levels based on activity
enum EmotionalStatus {
  veryLow,
  low,
  medium,
  high,
  veryHigh;

  String get displayName {
    switch (this) {
      case EmotionalStatus.veryLow:
        return 'بسیار پایین (غیرفعال)';
      case EmotionalStatus.low:
        return 'پایین';
      case EmotionalStatus.medium:
        return 'متوسط';
      case EmotionalStatus.high:
        return 'بالا';
      case EmotionalStatus.veryHigh:
        return 'بسیار بالا (بسیار فعال)';
    }
  }

  String get emoji {
    switch (this) {
      case EmotionalStatus.veryLow:
        return '😴';
      case EmotionalStatus.low:
        return '😐';
      case EmotionalStatus.medium:
        return '🙂';
      case EmotionalStatus.high:
        return '😊';
      case EmotionalStatus.veryHigh:
        return '🤩';
    }
  }

  static EmotionalStatus fromString(String value) {
    return EmotionalStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EmotionalStatus.medium,
    );
  }
}

/// Text-based sentiment analysis
class TextBasedSentiment {
  final double averageSentimentScore; // -1 to 1 (negative to positive)
  final SentimentLevel averageSentimentLevel;
  final List<TimeSeriesPoint> sentimentTrend;
  final int positiveCount;
  final int neutralCount;
  final int negativeCount;
  final AnalyzedContent? mostPositiveContent;
  final AnalyzedContent? mostNegativeContent;
  final List<EmotionalPhrase> dominantPhrases;
  final Map<String, int> sentimentDistribution;

  TextBasedSentiment({
    required this.averageSentimentScore,
    required this.averageSentimentLevel,
    required this.sentimentTrend,
    required this.positiveCount,
    required this.neutralCount,
    required this.negativeCount,
    required this.mostPositiveContent,
    required this.mostNegativeContent,
    required this.dominantPhrases,
    required this.sentimentDistribution,
  });

  int get totalAnalyzed => positiveCount + neutralCount + negativeCount;

  double get positiveRatio =>
      totalAnalyzed > 0 ? positiveCount / totalAnalyzed : 0;

  double get negativeRatio =>
      totalAnalyzed > 0 ? negativeCount / totalAnalyzed : 0;

  factory TextBasedSentiment.fromJson(Map<String, dynamic> json) {
    return TextBasedSentiment(
      averageSentimentScore: (json['averageSentimentScore'] as num).toDouble(),
      averageSentimentLevel:
          SentimentLevel.fromString(json['averageSentimentLevel'] as String),
      sentimentTrend: (json['sentimentTrend'] as List<dynamic>)
          .map((e) => TimeSeriesPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      positiveCount: json['positiveCount'] as int,
      neutralCount: json['neutralCount'] as int,
      negativeCount: json['negativeCount'] as int,
      mostPositiveContent: json['mostPositiveContent'] != null
          ? AnalyzedContent.fromJson(
              json['mostPositiveContent'] as Map<String, dynamic>)
          : null,
      mostNegativeContent: json['mostNegativeContent'] != null
          ? AnalyzedContent.fromJson(
              json['mostNegativeContent'] as Map<String, dynamic>)
          : null,
      dominantPhrases: (json['dominantPhrases'] as List<dynamic>)
          .map((e) => EmotionalPhrase.fromJson(e as Map<String, dynamic>))
          .toList(),
      sentimentDistribution:
          Map<String, int>.from(json['sentimentDistribution']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'averageSentimentScore': averageSentimentScore,
      'averageSentimentLevel': averageSentimentLevel.toString(),
      'sentimentTrend': sentimentTrend.map((e) => e.toJson()).toList(),
      'positiveCount': positiveCount,
      'neutralCount': neutralCount,
      'negativeCount': negativeCount,
      'mostPositiveContent': mostPositiveContent?.toJson(),
      'mostNegativeContent': mostNegativeContent?.toJson(),
      'dominantPhrases': dominantPhrases.map((e) => e.toJson()).toList(),
      'sentimentDistribution': sentimentDistribution,
    };
  }
}

/// Sentiment levels for text analysis
enum SentimentLevel {
  veryNegative,
  negative,
  neutral,
  positive,
  veryPositive;

  String get displayName {
    switch (this) {
      case SentimentLevel.veryNegative:
        return 'بسیار منفی';
      case SentimentLevel.negative:
        return 'منفی';
      case SentimentLevel.neutral:
        return 'خنثی';
      case SentimentLevel.positive:
        return 'مثبت';
      case SentimentLevel.veryPositive:
        return 'بسیار مثبت';
    }
  }

  String get emoji {
    switch (this) {
      case SentimentLevel.veryNegative:
        return '😢';
      case SentimentLevel.negative:
        return '😕';
      case SentimentLevel.neutral:
        return '😐';
      case SentimentLevel.positive:
        return '😊';
      case SentimentLevel.veryPositive:
        return '😄';
    }
  }

  static SentimentLevel fromString(String value) {
    return SentimentLevel.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SentimentLevel.neutral,
    );
  }

  static SentimentLevel fromScore(double score) {
    if (score <= -0.6) return SentimentLevel.veryNegative;
    if (score <= -0.2) return SentimentLevel.negative;
    if (score <= 0.2) return SentimentLevel.neutral;
    if (score <= 0.6) return SentimentLevel.positive;
    return SentimentLevel.veryPositive;
  }
}

/// Analyzed content item (post, comment, message)
class AnalyzedContent {
  final String id;
  final String contentType; // 'post', 'comment', 'message'
  final String text;
  final double sentimentScore;
  final SentimentLevel sentimentLevel;
  final DateTime createdAt;

  AnalyzedContent({
    required this.id,
    required this.contentType,
    required this.text,
    required this.sentimentScore,
    required this.sentimentLevel,
    required this.createdAt,
  });

  factory AnalyzedContent.fromJson(Map<String, dynamic> json) {
    return AnalyzedContent(
      id: json['id'] as String,
      contentType: json['contentType'] as String,
      text: json['text'] as String,
      sentimentScore: (json['sentimentScore'] as num).toDouble(),
      sentimentLevel:
          SentimentLevel.fromString(json['sentimentLevel'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contentType': contentType,
      'text': text,
      'sentimentScore': sentimentScore,
      'sentimentLevel': sentimentLevel.toString(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// Dominant emotional phrase in text analysis
class EmotionalPhrase {
  final String phrase;
  final int frequency;
  final SentimentLevel sentiment;

  EmotionalPhrase({
    required this.phrase,
    required this.frequency,
    required this.sentiment,
  });

  factory EmotionalPhrase.fromJson(Map<String, dynamic> json) {
    return EmotionalPhrase(
      phrase: json['phrase'] as String,
      frequency: json['frequency'] as int,
      sentiment: SentimentLevel.fromString(json['sentiment'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phrase': phrase,
      'frequency': frequency,
      'sentiment': sentiment.toString(),
    };
  }
}

/// Self-reported mood tracking
class SelfReportedMood {
  final List<MoodEntry> entries;
  final MoodLevel? averageMood;
  final MoodLevel? mostCommonMood;
  final List<TimeSeriesPoint> moodTrend;
  final MoodEntry? bestMoodDay;
  final MoodEntry? worstMoodDay;
  final int totalEntries;
  final Map<String, int> moodDistribution;
  final MoodActivityCorrelation? activityCorrelation;

  SelfReportedMood({
    required this.entries,
    required this.averageMood,
    required this.mostCommonMood,
    required this.moodTrend,
    required this.bestMoodDay,
    required this.worstMoodDay,
    required this.totalEntries,
    required this.moodDistribution,
    required this.activityCorrelation,
  });

  factory SelfReportedMood.fromJson(Map<String, dynamic> json) {
    return SelfReportedMood(
      entries: (json['entries'] as List<dynamic>)
          .map((e) => MoodEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      averageMood: json['averageMood'] != null
          ? MoodLevel.fromString(json['averageMood'] as String)
          : null,
      mostCommonMood: json['mostCommonMood'] != null
          ? MoodLevel.fromString(json['mostCommonMood'] as String)
          : null,
      moodTrend: (json['moodTrend'] as List<dynamic>)
          .map((e) => TimeSeriesPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      bestMoodDay: json['bestMoodDay'] != null
          ? MoodEntry.fromJson(json['bestMoodDay'] as Map<String, dynamic>)
          : null,
      worstMoodDay: json['worstMoodDay'] != null
          ? MoodEntry.fromJson(json['worstMoodDay'] as Map<String, dynamic>)
          : null,
      totalEntries: json['totalEntries'] as int,
      moodDistribution: Map<String, int>.from(json['moodDistribution']),
      activityCorrelation: json['activityCorrelation'] != null
          ? MoodActivityCorrelation.fromJson(
              json['activityCorrelation'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entries': entries.map((e) => e.toJson()).toList(),
      'averageMood': averageMood?.toString(),
      'mostCommonMood': mostCommonMood?.toString(),
      'moodTrend': moodTrend.map((e) => e.toJson()).toList(),
      'bestMoodDay': bestMoodDay?.toJson(),
      'worstMoodDay': worstMoodDay?.toJson(),
      'totalEntries': totalEntries,
      'moodDistribution': moodDistribution,
      'activityCorrelation': activityCorrelation?.toJson(),
    };
  }
}

/// Individual mood entry
class MoodEntry {
  final String id;
  final DateTime date;
  final MoodLevel mood;
  final String? comment;

  MoodEntry({
    required this.id,
    required this.date,
    required this.mood,
    this.comment,
  });

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      mood: MoodLevel.fromString(json['mood'] as String),
      comment: json['comment'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'mood': mood.toString(),
      'comment': comment,
    };
  }
}

/// Mood levels for self-reporting
enum MoodLevel {
  veryBad,
  bad,
  neutral,
  good,
  veryGood;

  String get displayName {
    switch (this) {
      case MoodLevel.veryBad:
        return 'بسیار بد';
      case MoodLevel.bad:
        return 'بد';
      case MoodLevel.neutral:
        return 'خنثی';
      case MoodLevel.good:
        return 'خوب';
      case MoodLevel.veryGood:
        return 'بسیار خوب';
    }
  }

  String get emoji {
    switch (this) {
      case MoodLevel.veryBad:
        return '😞';
      case MoodLevel.bad:
        return '🙁';
      case MoodLevel.neutral:
        return '😐';
      case MoodLevel.good:
        return '🙂';
      case MoodLevel.veryGood:
        return '😄';
    }
  }

  int get numericValue {
    switch (this) {
      case MoodLevel.veryBad:
        return 1;
      case MoodLevel.bad:
        return 2;
      case MoodLevel.neutral:
        return 3;
      case MoodLevel.good:
        return 4;
      case MoodLevel.veryGood:
        return 5;
    }
  }

  static MoodLevel fromString(String value) {
    return MoodLevel.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MoodLevel.neutral,
    );
  }

  static MoodLevel fromNumericValue(int value) {
    return MoodLevel.values.firstWhere(
      (e) => e.numericValue == value,
      orElse: () => MoodLevel.neutral,
    );
  }
}

/// Correlation between mood and activity
class MoodActivityCorrelation {
  final String description;
  final double correlationScore; // -1 to 1
  final Map<MoodLevel, double> averageEngagementByMood;

  MoodActivityCorrelation({
    required this.description,
    required this.correlationScore,
    required this.averageEngagementByMood,
  });

  factory MoodActivityCorrelation.fromJson(Map<String, dynamic> json) {
    return MoodActivityCorrelation(
      description: json['description'] as String,
      correlationScore: (json['correlationScore'] as num).toDouble(),
      averageEngagementByMood: (json['averageEngagementByMood']
              as Map<String, dynamic>)
          .map((key, value) =>
              MapEntry(MoodLevel.fromString(key), (value as num).toDouble())),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'correlationScore': correlationScore,
      'averageEngagementByMood': averageEngagementByMood
          .map((key, value) => MapEntry(key.toString(), value)),
    };
  }
}

/// Smart insight generated from sentiment data
class SmartInsight {
  final String id;
  final String title;
  final String description;
  final InsightType type;
  final DateTime generatedAt;

  SmartInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.generatedAt,
  });

  factory SmartInsight.fromJson(Map<String, dynamic> json) {
    return SmartInsight(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: InsightType.fromString(json['type'] as String),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString(),
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
}

/// Types of insights
enum InsightType {
  positive,
  neutral,
  warning,
  trend;

  static InsightType fromString(String value) {
    return InsightType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => InsightType.neutral,
    );
  }
}

/// Time series point for trend charts
class TimeSeriesPoint {
  final DateTime date;
  final double value;
  final String? label;

  TimeSeriesPoint({
    required this.date,
    required this.value,
    this.label,
  });

  factory TimeSeriesPoint.fromJson(Map<String, dynamic> json) {
    return TimeSeriesPoint(
      date: DateTime.parse(json['date'] as String),
      value: (json['value'] as num).toDouble(),
      label: json['label'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'value': value,
      'label': label,
    };
  }
}
