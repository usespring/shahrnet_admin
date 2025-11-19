class LearnAnalytics {
  final int completedCourses;
  final int inProgressCourses;
  final double averageScore;
  final double completionRate;
  final int totalLearningTimeMinutes;
  final List<CompletedCourse> recentlyCompletedCourses;
  final List<TimeSeriesPoint> completionTrend;
  final DateTime periodStart;
  final DateTime periodEnd;

  const LearnAnalytics({
    required this.completedCourses,
    required this.inProgressCourses,
    required this.averageScore,
    required this.completionRate,
    required this.totalLearningTimeMinutes,
    required this.recentlyCompletedCourses,
    required this.completionTrend,
    required this.periodStart,
    required this.periodEnd,
  });

  int get totalStartedCourses => completedCourses + inProgressCourses;

  String get formattedLearningTime {
    final hours = totalLearningTimeMinutes ~/ 60;
    final minutes = totalLearningTimeMinutes % 60;
    if (hours > 0) {
      return '$hours ساعت و $minutes دقیقه';
    }
    return '$minutes دقیقه';
  }

  factory LearnAnalytics.fromJson(Map<String, dynamic> json) {
    return LearnAnalytics(
      completedCourses: json['completedCourses'] as int,
      inProgressCourses: json['inProgressCourses'] as int,
      averageScore: (json['averageScore'] as num).toDouble(),
      completionRate: (json['completionRate'] as num).toDouble(),
      totalLearningTimeMinutes: json['totalLearningTimeMinutes'] as int,
      recentlyCompletedCourses: (json['recentlyCompletedCourses'] as List)
          .map((e) => CompletedCourse.fromJson(e as Map<String, dynamic>))
          .toList(),
      completionTrend: (json['completionTrend'] as List)
          .map((e) => TimeSeriesPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completedCourses': completedCourses,
      'inProgressCourses': inProgressCourses,
      'averageScore': averageScore,
      'completionRate': completionRate,
      'totalLearningTimeMinutes': totalLearningTimeMinutes,
      'recentlyCompletedCourses':
          recentlyCompletedCourses.map((e) => e.toJson()).toList(),
      'completionTrend': completionTrend.map((e) => e.toJson()).toList(),
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
    };
  }
}

class CompletedCourse {
  final String courseId;
  final String courseTitle;
  final DateTime completionDate;
  final double score;
  final int durationMinutes;
  final String? instructor;

  const CompletedCourse({
    required this.courseId,
    required this.courseTitle,
    required this.completionDate,
    required this.score,
    required this.durationMinutes,
    this.instructor,
  });

  factory CompletedCourse.fromJson(Map<String, dynamic> json) {
    return CompletedCourse(
      courseId: json['courseId'] as String,
      courseTitle: json['courseTitle'] as String,
      completionDate: DateTime.parse(json['completionDate'] as String),
      score: (json['score'] as num).toDouble(),
      durationMinutes: json['durationMinutes'] as int,
      instructor: json['instructor'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'courseTitle': courseTitle,
      'completionDate': completionDate.toIso8601String(),
      'score': score,
      'durationMinutes': durationMinutes,
      'instructor': instructor,
    };
  }
}

class TimeSeriesPoint {
  final DateTime date;
  final double value;

  const TimeSeriesPoint({
    required this.date,
    required this.value,
  });

  factory TimeSeriesPoint.fromJson(Map<String, dynamic> json) {
    return TimeSeriesPoint(
      date: DateTime.parse(json['date'] as String),
      value: (json['value'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'value': value,
    };
  }
}
