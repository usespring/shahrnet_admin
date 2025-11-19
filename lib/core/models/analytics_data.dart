class TimeSeriesData {
  final DateTime date;
  final double value;

  const TimeSeriesData({
    required this.date,
    required this.value,
  });

  factory TimeSeriesData.fromJson(Map<String, dynamic> json) {
    return TimeSeriesData(
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

class ActivityDistribution {
  final String activityType;
  final int count;
  final double percentage;

  const ActivityDistribution({
    required this.activityType,
    required this.count,
    required this.percentage,
  });

  factory ActivityDistribution.fromJson(Map<String, dynamic> json) {
    return ActivityDistribution(
      activityType: json['activityType'] as String,
      count: json['count'] as int,
      percentage: (json['percentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activityType': activityType,
      'count': count,
      'percentage': percentage,
    };
  }
}

class SectionActivityData {
  final String section;
  final int activityCount;
  final double percentage;

  const SectionActivityData({
    required this.section,
    required this.activityCount,
    required this.percentage,
  });

  factory SectionActivityData.fromJson(Map<String, dynamic> json) {
    return SectionActivityData(
      section: json['section'] as String,
      activityCount: json['activityCount'] as int,
      percentage: (json['percentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'section': section,
      'activityCount': activityCount,
      'percentage': percentage,
    };
  }
}

class AnalyticsSummary {
  final int totalUsers;
  final int activeUsers;
  final int totalActivities;
  final double averageActivitiesPerUser;
  final DateTime periodStart;
  final DateTime periodEnd;

  const AnalyticsSummary({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalActivities,
    required this.averageActivitiesPerUser,
    required this.periodStart,
    required this.periodEnd,
  });

  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummary(
      totalUsers: json['totalUsers'] as int,
      activeUsers: json['activeUsers'] as int,
      totalActivities: json['totalActivities'] as int,
      averageActivitiesPerUser:
          (json['averageActivitiesPerUser'] as num).toDouble(),
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalUsers': totalUsers,
      'activeUsers': activeUsers,
      'totalActivities': totalActivities,
      'averageActivitiesPerUser': averageActivitiesPerUser,
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
    };
  }
}
