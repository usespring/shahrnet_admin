class TimelineAnalytics {
  final int likesGiven;
  final int commentsWritten;
  final int postsComposed;
  final int postVisits;
  final int shares;
  final int pollParticipations;
  final int reportsSubmitted;
  final double engagementRate;
  final List<TopPost> topPostsByLikes;
  final List<TopPost> topPostsByComments;
  final List<TopPost> topPostsByViews;
  final List<TimeSeriesPoint> engagementTrend;
  final DateTime periodStart;
  final DateTime periodEnd;

  const TimelineAnalytics({
    required this.likesGiven,
    required this.commentsWritten,
    required this.postsComposed,
    required this.postVisits,
    required this.shares,
    required this.pollParticipations,
    required this.reportsSubmitted,
    required this.engagementRate,
    required this.topPostsByLikes,
    required this.topPostsByComments,
    required this.topPostsByViews,
    required this.engagementTrend,
    required this.periodStart,
    required this.periodEnd,
  });

  int get totalEngagements =>
      likesGiven + commentsWritten + postVisits + shares + pollParticipations;

  factory TimelineAnalytics.fromJson(Map<String, dynamic> json) {
    return TimelineAnalytics(
      likesGiven: json['likesGiven'] as int,
      commentsWritten: json['commentsWritten'] as int,
      postsComposed: json['postsComposed'] as int,
      postVisits: json['postVisits'] as int,
      shares: json['shares'] as int,
      pollParticipations: json['pollParticipations'] as int,
      reportsSubmitted: json['reportsSubmitted'] as int,
      engagementRate: (json['engagementRate'] as num).toDouble(),
      topPostsByLikes: (json['topPostsByLikes'] as List)
          .map((e) => TopPost.fromJson(e as Map<String, dynamic>))
          .toList(),
      topPostsByComments: (json['topPostsByComments'] as List)
          .map((e) => TopPost.fromJson(e as Map<String, dynamic>))
          .toList(),
      topPostsByViews: (json['topPostsByViews'] as List)
          .map((e) => TopPost.fromJson(e as Map<String, dynamic>))
          .toList(),
      engagementTrend: (json['engagementTrend'] as List)
          .map((e) => TimeSeriesPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'likesGiven': likesGiven,
      'commentsWritten': commentsWritten,
      'postsComposed': postsComposed,
      'postVisits': postVisits,
      'shares': shares,
      'pollParticipations': pollParticipations,
      'reportsSubmitted': reportsSubmitted,
      'engagementRate': engagementRate,
      'topPostsByLikes': topPostsByLikes.map((e) => e.toJson()).toList(),
      'topPostsByComments': topPostsByComments.map((e) => e.toJson()).toList(),
      'topPostsByViews': topPostsByViews.map((e) => e.toJson()).toList(),
      'engagementTrend': engagementTrend.map((e) => e.toJson()).toList(),
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
    };
  }
}

class TopPost {
  final String postId;
  final String title;
  final String? author;
  final int likesCount;
  final int commentsCount;
  final int viewsCount;
  final DateTime publishedAt;

  const TopPost({
    required this.postId,
    required this.title,
    this.author,
    required this.likesCount,
    required this.commentsCount,
    required this.viewsCount,
    required this.publishedAt,
  });

  factory TopPost.fromJson(Map<String, dynamic> json) {
    return TopPost(
      postId: json['postId'] as String,
      title: json['title'] as String,
      author: json['author'] as String?,
      likesCount: json['likesCount'] as int,
      commentsCount: json['commentsCount'] as int,
      viewsCount: json['viewsCount'] as int,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'title': title,
      'author': author,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'viewsCount': viewsCount,
      'publishedAt': publishedAt.toIso8601String(),
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
