import 'dart:math';
import 'package:shahrnet_admin/core/models/sentiment_analytics.dart';

/// Mock data generator for Sentiment Analytics
class MockSentimentAnalytics {
  static final Random _random = Random(42); // Seeded for reproducibility

  /// Generate mock sentiment analytics data for a date range
  static SentimentAnalytics generateSentimentAnalytics({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final daysDifference = endDate.difference(startDate).inDays;

    return SentimentAnalytics(
      periodStart: startDate,
      periodEnd: endDate,
      activityBasedEmotion: _generateActivityBasedEmotion(
        startDate: startDate,
        endDate: endDate,
        daysDifference: daysDifference,
      ),
      textBasedSentiment: _generateTextBasedSentiment(
        startDate: startDate,
        endDate: endDate,
        daysDifference: daysDifference,
      ),
      selfReportedMood: _generateSelfReportedMood(
        startDate: startDate,
        endDate: endDate,
        daysDifference: daysDifference,
      ),
      insights: _generateInsights(daysDifference),
    );
  }

  /// Generate activity-based emotion data
  static ActivityBasedEmotion _generateActivityBasedEmotion({
    required DateTime startDate,
    required DateTime endDate,
    required int daysDifference,
  }) {
    final postsCreated = _random.nextInt(20) + 5;
    final commentsWritten = _random.nextInt(50) + 10;
    final likesGiven = _random.nextInt(100) + 20;
    final pollsParticipated = _random.nextInt(10) + 1;
    final coursesCompleted = _random.nextInt(5) + 1;
    final messagesSent = _random.nextInt(150) + 30;
    final callsMade = _random.nextInt(15) + 2;
    final daysActive = (daysDifference * (0.5 + _random.nextDouble() * 0.4))
        .round()
        .clamp(1, daysDifference);

    // Calculate engagement score (0-100)
    final totalActivity = postsCreated +
        commentsWritten +
        likesGiven +
        pollsParticipated +
        coursesCompleted +
        messagesSent +
        callsMade;
    final engagementScore = (totalActivity / daysDifference * 2)
        .clamp(0, 100)
        .toDouble();

    // Determine emotional status based on engagement score
    final emotionalStatus = _getEmotionalStatusFromScore(engagementScore);

    // Generate activity trend
    final activityTrend = _generateActivityTrend(startDate, endDate);

    // Activity breakdown
    final activityBreakdown = {
      'پست‌ها': postsCreated,
      'نظرات': commentsWritten,
      'لایک‌ها': likesGiven,
      'نظرسنجی‌ها': pollsParticipated,
      'دوره‌ها': coursesCompleted,
      'پیام‌ها': messagesSent,
      'تماس‌ها': callsMade,
    };

    return ActivityBasedEmotion(
      postsCreated: postsCreated,
      commentsWritten: commentsWritten,
      likesGiven: likesGiven,
      pollsParticipated: pollsParticipated,
      coursesCompleted: coursesCompleted,
      messagesSent: messagesSent,
      callsMade: callsMade,
      daysActive: daysActive,
      engagementScore: engagementScore,
      emotionalStatus: emotionalStatus,
      activityTrend: activityTrend,
      activityBreakdown: activityBreakdown,
    );
  }

  /// Generate text-based sentiment data
  static TextBasedSentiment _generateTextBasedSentiment({
    required DateTime startDate,
    required DateTime endDate,
    required int daysDifference,
  }) {
    final totalAnalyzed = _random.nextInt(100) + 30;
    final positiveCount = (totalAnalyzed * (0.4 + _random.nextDouble() * 0.3)).round();
    final negativeCount = (totalAnalyzed * (0.1 + _random.nextDouble() * 0.2)).round();
    final neutralCount = totalAnalyzed - positiveCount - negativeCount;

    // Calculate average sentiment score (-1 to 1)
    final averageSentimentScore =
        ((positiveCount - negativeCount) / totalAnalyzed) * 0.8;
    final averageSentimentLevel =
        SentimentLevel.fromScore(averageSentimentScore);

    // Generate sentiment trend
    final sentimentTrend = _generateSentimentTrend(startDate, endDate);

    // Generate most positive/negative content
    final mostPositiveContent = _generateAnalyzedContent(
      contentType: 'post',
      isPositive: true,
      date: startDate.add(Duration(days: _random.nextInt(daysDifference))),
    );

    final mostNegativeContent = _generateAnalyzedContent(
      contentType: 'comment',
      isPositive: false,
      date: startDate.add(Duration(days: _random.nextInt(daysDifference))),
    );

    // Generate dominant phrases
    final dominantPhrases = _generateDominantPhrases();

    // Sentiment distribution
    final sentimentDistribution = {
      'بسیار منفی': (negativeCount * 0.3).round(),
      'منفی': (negativeCount * 0.7).round(),
      'خنثی': neutralCount,
      'مثبت': (positiveCount * 0.6).round(),
      'بسیار مثبت': (positiveCount * 0.4).round(),
    };

    return TextBasedSentiment(
      averageSentimentScore: averageSentimentScore,
      averageSentimentLevel: averageSentimentLevel,
      sentimentTrend: sentimentTrend,
      positiveCount: positiveCount,
      neutralCount: neutralCount,
      negativeCount: negativeCount,
      mostPositiveContent: mostPositiveContent,
      mostNegativeContent: mostNegativeContent,
      dominantPhrases: dominantPhrases,
      sentimentDistribution: sentimentDistribution,
    );
  }

  /// Generate self-reported mood data
  static SelfReportedMood _generateSelfReportedMood({
    required DateTime startDate,
    required DateTime endDate,
    required int daysDifference,
  }) {
    // Generate mood entries (user reports mood on some days, not all)
    final entries = <MoodEntry>[];
    final reportingRate = 0.6; // 60% of days have mood reports
    final moodCounts = <MoodLevel, int>{};

    for (int i = 0; i < daysDifference; i++) {
      if (_random.nextDouble() < reportingRate) {
        final mood = _randomMoodLevel();
        moodCounts[mood] = (moodCounts[mood] ?? 0) + 1;

        entries.add(MoodEntry(
          id: 'mood_${i + 1}',
          date: startDate.add(Duration(days: i)),
          mood: mood,
          comment: _random.nextDouble() < 0.4
              ? _getMoodComment(mood)
              : null,
        ));
      }
    }

    // Sort entries by date
    entries.sort((a, b) => a.date.compareTo(b.date));

    final totalEntries = entries.length;

    // Calculate average mood
    final averageMoodValue = totalEntries > 0
        ? entries.map((e) => e.mood.numericValue).reduce((a, b) => a + b) /
            totalEntries
        : 3.0;
    final averageMood =
        MoodLevel.fromNumericValue(averageMoodValue.round());

    // Find most common mood
    MoodLevel? mostCommonMood;
    int maxCount = 0;
    moodCounts.forEach((mood, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommonMood = mood;
      }
    });

    // Generate mood trend
    final moodTrend = entries
        .map((e) => TimeSeriesPoint(
              date: e.date,
              value: e.mood.numericValue.toDouble(),
              label: e.mood.emoji,
            ))
        .toList();

    // Find best and worst mood days
    MoodEntry? bestMoodDay;
    MoodEntry? worstMoodDay;
    for (final entry in entries) {
      if (bestMoodDay == null ||
          entry.mood.numericValue > bestMoodDay.mood.numericValue) {
        bestMoodDay = entry;
      }
      if (worstMoodDay == null ||
          entry.mood.numericValue < worstMoodDay.mood.numericValue) {
        worstMoodDay = entry;
      }
    }

    // Mood distribution
    final moodDistribution = {
      'بسیار بد': moodCounts[MoodLevel.veryBad] ?? 0,
      'بد': moodCounts[MoodLevel.bad] ?? 0,
      'خنثی': moodCounts[MoodLevel.neutral] ?? 0,
      'خوب': moodCounts[MoodLevel.good] ?? 0,
      'بسیار خوب': moodCounts[MoodLevel.veryGood] ?? 0,
    };

    // Activity correlation
    final activityCorrelation = _generateMoodActivityCorrelation();

    return SelfReportedMood(
      entries: entries,
      averageMood: averageMood,
      mostCommonMood: mostCommonMood,
      moodTrend: moodTrend,
      bestMoodDay: bestMoodDay,
      worstMoodDay: worstMoodDay,
      totalEntries: totalEntries,
      moodDistribution: moodDistribution,
      activityCorrelation: activityCorrelation,
    );
  }

  /// Generate activity trend over time
  static List<TimeSeriesPoint> _generateActivityTrend(
    DateTime startDate,
    DateTime endDate,
  ) {
    final points = <TimeSeriesPoint>[];
    final daysDifference = endDate.difference(startDate).inDays;
    final samplingInterval = daysDifference > 30 ? 7 : 1; // Weekly or daily

    for (int i = 0; i <= daysDifference; i += samplingInterval) {
      final date = startDate.add(Duration(days: i));
      final baseValue = 15.0;
      final variance = _random.nextDouble() * 20 - 5;
      final trend = (i / daysDifference) * 10; // Slight upward trend

      points.add(TimeSeriesPoint(
        date: date,
        value: (baseValue + variance + trend).clamp(0, 50),
      ));
    }

    return points;
  }

  /// Generate sentiment trend over time
  static List<TimeSeriesPoint> _generateSentimentTrend(
    DateTime startDate,
    DateTime endDate,
  ) {
    final points = <TimeSeriesPoint>[];
    final daysDifference = endDate.difference(startDate).inDays;
    final samplingInterval = daysDifference > 30 ? 7 : 1;

    for (int i = 0; i <= daysDifference; i += samplingInterval) {
      final date = startDate.add(Duration(days: i));
      final baseValue = 0.3; // Slightly positive baseline
      final variance = _random.nextDouble() * 0.6 - 0.3;

      points.add(TimeSeriesPoint(
        date: date,
        value: (baseValue + variance).clamp(-1.0, 1.0),
      ));
    }

    return points;
  }

  /// Generate analyzed content sample
  static AnalyzedContent _generateAnalyzedContent({
    required String contentType,
    required bool isPositive,
    required DateTime date,
  }) {
    final positiveTexts = [
      'امروز روز فوق‌العاده‌ای بود! یاد گرفتم چیزهای جدید خیلی جالبی.',
      'خیلی خوشحالم که به این جامعه پیوستم. همه خیلی مهربان هستند.',
      'این دوره عالی بود! مطالب خیلی کاربردی و مفید.',
      'تجربه فوق‌العاده‌ای داشتم. ممنون از همه دوستان.',
    ];

    final negativeTexts = [
      'امروز روز سختی بود. انگار هیچ چیز درست پیش نرفت.',
      'متأسفانه نتونستم مطالب رو به خوبی درک کنم.',
      'کمی ناامید شدم از پیشرفتم.',
      'امروز حوصله‌ام سر رفت و نتونستم تمرکز کنم.',
    ];

    final text = isPositive
        ? positiveTexts[_random.nextInt(positiveTexts.length)]
        : negativeTexts[_random.nextInt(negativeTexts.length)];

    final sentimentScore = isPositive
        ? 0.6 + _random.nextDouble() * 0.4
        : -0.6 - _random.nextDouble() * 0.4;

    return AnalyzedContent(
      id: 'content_${_random.nextInt(10000)}',
      contentType: contentType,
      text: text,
      sentimentScore: sentimentScore,
      sentimentLevel: SentimentLevel.fromScore(sentimentScore),
      createdAt: date,
    );
  }

  /// Generate dominant emotional phrases
  static List<EmotionalPhrase> _generateDominantPhrases() {
    final phrases = [
      EmotionalPhrase(
        phrase: 'عالی',
        frequency: 45,
        sentiment: SentimentLevel.veryPositive,
      ),
      EmotionalPhrase(
        phrase: 'ممنون',
        frequency: 38,
        sentiment: SentimentLevel.positive,
      ),
      EmotionalPhrase(
        phrase: 'خوب',
        frequency: 32,
        sentiment: SentimentLevel.positive,
      ),
      EmotionalPhrase(
        phrase: 'جالب',
        frequency: 28,
        sentiment: SentimentLevel.positive,
      ),
      EmotionalPhrase(
        phrase: 'سخت',
        frequency: 12,
        sentiment: SentimentLevel.negative,
      ),
    ];

    return phrases;
  }

  /// Generate mood-activity correlation
  static MoodActivityCorrelation _generateMoodActivityCorrelation() {
    final correlationScore = 0.4 + _random.nextDouble() * 0.4; // 0.4 to 0.8

    final averageEngagementByMood = {
      MoodLevel.veryBad: 5.0 + _random.nextDouble() * 5,
      MoodLevel.bad: 10.0 + _random.nextDouble() * 10,
      MoodLevel.neutral: 20.0 + _random.nextDouble() * 10,
      MoodLevel.good: 35.0 + _random.nextDouble() * 15,
      MoodLevel.veryGood: 55.0 + _random.nextDouble() * 20,
    };

    final bestMood = averageEngagementByMood.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    final bestEngagement = averageEngagementByMood[bestMood]!;
    final increasePercentage = ((bestEngagement / 50) * 100).round();

    final description =
        'در روزهایی که کاربر ${bestMood.emoji} (${bestMood.displayName}) را انتخاب می‌کند، میزان فعالیت تا $increasePercentage% افزایش می‌یابد.';

    return MoodActivityCorrelation(
      description: description,
      correlationScore: correlationScore,
      averageEngagementByMood: averageEngagementByMood,
    );
  }

  /// Generate smart insights
  static List<SmartInsight> _generateInsights(int daysDifference) {
    final insights = <SmartInsight>[];
    final now = DateTime.now();

    final insightTemplates = [
      {
        'title': 'بهبود روحیه در آخر هفته',
        'description':
            'احساسات شما در آخر هفته‌ها مثبت‌تر است. تعداد پست‌های مثبت در آخر هفته‌ها ۳۵٪ بیشتر از روزهای هفته است.',
        'type': InsightType.positive,
      },
      {
        'title': 'ارتباط قوی بین یادگیری و حالت روحی',
        'description':
            'وقتی در فعالیت‌های یادگیری شرکت می‌کنید، حالت روحی شما به طور قابل توجهی بهتر می‌شود. این هفته، بعد از هر دوره، احساسات مثبت شما ۴۲٪ افزایش یافت.',
        'type': InsightType.trend,
      },
      {
        'title': 'افزایش نظرات مثبت',
        'description':
            'این هفته نظرات مثبت شما نسبت به هفته گذشته ۲۸٪ افزایش یافته است. عالی پیش می‌روید!',
        'type': InsightType.positive,
      },
      {
        'title': 'بهبود میانگین روحیه',
        'description':
            'میانگین حالت روحی شما نسبت به ماه گذشته بهبود یافته است. از ${MoodLevel.neutral.emoji} به ${MoodLevel.good.emoji} رسیده‌اید.',
        'type': InsightType.positive,
      },
    ];

    // Add 2-4 random insights
    final insightCount = 2 + _random.nextInt(3);
    final shuffledTemplates = List.from(insightTemplates)..shuffle(_random);

    for (int i = 0; i < insightCount && i < shuffledTemplates.length; i++) {
      final template = shuffledTemplates[i];
      insights.add(SmartInsight(
        id: 'insight_$i',
        title: template['title'] as String,
        description: template['description'] as String,
        type: template['type'] as InsightType,
        generatedAt: now.subtract(Duration(hours: _random.nextInt(24))),
      ));
    }

    return insights;
  }

  /// Get emotional status from engagement score
  static EmotionalStatus _getEmotionalStatusFromScore(double score) {
    if (score < 20) return EmotionalStatus.veryLow;
    if (score < 40) return EmotionalStatus.low;
    if (score < 60) return EmotionalStatus.medium;
    if (score < 80) return EmotionalStatus.high;
    return EmotionalStatus.veryHigh;
  }

  /// Get random mood level with realistic distribution
  static MoodLevel _randomMoodLevel() {
    final value = _random.nextDouble();
    if (value < 0.05) return MoodLevel.veryBad;
    if (value < 0.20) return MoodLevel.bad;
    if (value < 0.45) return MoodLevel.neutral;
    if (value < 0.75) return MoodLevel.good;
    return MoodLevel.veryGood;
  }

  /// Get sample comment for mood
  static String _getMoodComment(MoodLevel mood) {
    final comments = {
      MoodLevel.veryBad: [
        'امروز روز سختی بود',
        'خیلی خسته و ناامید هستم',
        'احساس می‌کنم هیچ چیز درست پیش نمی‌رود',
      ],
      MoodLevel.bad: [
        'روز خوبی نبود',
        'کمی ناراحتم',
        'انرژی کمی دارم',
      ],
      MoodLevel.neutral: [
        'روز معمولی',
        'نه خوب نه بد',
        'حالت عادی',
      ],
      MoodLevel.good: [
        'روز خوبی بود',
        'احساس خوبی دارم',
        'کارها خوب پیش رفت',
      ],
      MoodLevel.veryGood: [
        'روز فوق‌العاده‌ای بود!',
        'خیلی شاد و پرانرژی هستم',
        'همه چیز عالی پیش رفت',
      ],
    };

    final moodComments = comments[mood]!;
    return moodComments[_random.nextInt(moodComments.length)];
  }
}
