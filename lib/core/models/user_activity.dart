enum ActivityType {
  postComposed,
  postLiked,
  postCommented,
  postVisited,
  surveyParticipated,
}

class UserActivity {
  final String userId;
  final String userName;
  final ActivityType type;
  final DateTime timestamp;
  final String? targetId; // ID of the post, survey, etc.
  final String? targetTitle; // Title of the post, survey, etc.
  final String? section; // Which section of app (timeline, learning, etc.)
  final Map<String, dynamic>? metadata;

  const UserActivity({
    required this.userId,
    required this.userName,
    required this.type,
    required this.timestamp,
    this.targetId,
    this.targetTitle,
    this.section,
    this.metadata,
  });

  factory UserActivity.fromJson(Map<String, dynamic> json) {
    return UserActivity(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      type: ActivityType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      targetId: json['targetId'] as String?,
      targetTitle: json['targetTitle'] as String?,
      section: json['section'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'targetId': targetId,
      'targetTitle': targetTitle,
      'section': section,
      'metadata': metadata,
    };
  }
}

class UserStats {
  final String userId;
  final String userName;
  final String? avatarUrl;
  final int totalPosts;
  final int totalLikes;
  final int totalComments;
  final int totalPostViews;
  final int totalSurveys;
  final int? totalDirectMessages;
  final int? totalGroupMessages;
  final int? totalAudioCalls;
  final int? totalVideoConferences;
  final int? totalCoursesCompleted;
  final int? totalCoursesInProgress;
  final double? averageCourseScore;
  final DateTime? lastActiveAt;

  const UserStats({
    required this.userId,
    required this.userName,
    this.avatarUrl,
    required this.totalPosts,
    required this.totalLikes,
    required this.totalComments,
    required this.totalPostViews,
    required this.totalSurveys,
    this.totalDirectMessages,
    this.totalGroupMessages,
    this.totalAudioCalls,
    this.totalVideoConferences,
    this.totalCoursesCompleted,
    this.totalCoursesInProgress,
    this.averageCourseScore,
    this.lastActiveAt,
  });

  int get totalActivity =>
      totalPosts + totalLikes + totalComments + totalPostViews + totalSurveys +
      (totalDirectMessages ?? 0) + (totalGroupMessages ?? 0) +
      (totalAudioCalls ?? 0) + (totalVideoConferences ?? 0) +
      (totalCoursesCompleted ?? 0) + (totalCoursesInProgress ?? 0);

  int get totalMessages => (totalDirectMessages ?? 0) + (totalGroupMessages ?? 0);
  int get totalCalls => (totalAudioCalls ?? 0) + (totalVideoConferences ?? 0);
  int get totalCourses => (totalCoursesCompleted ?? 0) + (totalCoursesInProgress ?? 0);

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      totalPosts: json['totalPosts'] as int,
      totalLikes: json['totalLikes'] as int,
      totalComments: json['totalComments'] as int,
      totalPostViews: json['totalPostViews'] as int,
      totalSurveys: json['totalSurveys'] as int,
      totalDirectMessages: (json['totalDirectMessages'] as int?) ?? 0,
      totalGroupMessages: (json['totalGroupMessages'] as int?) ?? 0,
      totalAudioCalls: (json['totalAudioCalls'] as int?) ?? 0,
      totalVideoConferences: (json['totalVideoConferences'] as int?) ?? 0,
      totalCoursesCompleted: (json['totalCoursesCompleted'] as int?) ?? 0,
      totalCoursesInProgress: (json['totalCoursesInProgress'] as int?) ?? 0,
      averageCourseScore: (json['averageCourseScore'] as num?)?.toDouble() ?? 0.0,
      lastActiveAt: json['lastActiveAt'] != null
          ? DateTime.parse(json['lastActiveAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'avatarUrl': avatarUrl,
      'totalPosts': totalPosts,
      'totalLikes': totalLikes,
      'totalComments': totalComments,
      'totalPostViews': totalPostViews,
      'totalSurveys': totalSurveys,
      'totalDirectMessages': totalDirectMessages,
      'totalGroupMessages': totalGroupMessages,
      'totalAudioCalls': totalAudioCalls,
      'totalVideoConferences': totalVideoConferences,
      'totalCoursesCompleted': totalCoursesCompleted,
      'totalCoursesInProgress': totalCoursesInProgress,
      'averageCourseScore': averageCourseScore,
      'lastActiveAt': lastActiveAt?.toIso8601String(),
    };
  }
}
