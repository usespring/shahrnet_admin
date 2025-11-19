class ConversationAnalytics {
  final int directMessagesSent;
  final int groupMessagesSent;
  final int audioCalls;
  final int videoConferences;
  final int activeConversations;
  final int unreadConversations;
  final double averageResponseTimeMinutes;
  final List<TopContact> topContacts;
  final List<TimeSeriesPoint> messagingTrend;
  final DateTime periodStart;
  final DateTime periodEnd;

  const ConversationAnalytics({
    required this.directMessagesSent,
    required this.groupMessagesSent,
    required this.audioCalls,
    required this.videoConferences,
    required this.activeConversations,
    required this.unreadConversations,
    required this.averageResponseTimeMinutes,
    required this.topContacts,
    required this.messagingTrend,
    required this.periodStart,
    required this.periodEnd,
  });

  int get totalMessagesSent => directMessagesSent + groupMessagesSent;
  int get totalCalls => audioCalls + videoConferences;

  String get formattedResponseTime {
    if (averageResponseTimeMinutes < 1) {
      return 'کمتر از یک دقیقه';
    }
    final hours = averageResponseTimeMinutes ~/ 60;
    final minutes = averageResponseTimeMinutes % 60;
    if (hours > 0) {
      return '$hours ساعت و ${minutes.toInt()} دقیقه';
    }
    return '${minutes.toInt()} دقیقه';
  }

  factory ConversationAnalytics.fromJson(Map<String, dynamic> json) {
    return ConversationAnalytics(
      directMessagesSent: json['directMessagesSent'] as int,
      groupMessagesSent: json['groupMessagesSent'] as int,
      audioCalls: json['audioCalls'] as int,
      videoConferences: json['videoConferences'] as int,
      activeConversations: json['activeConversations'] as int,
      unreadConversations: json['unreadConversations'] as int,
      averageResponseTimeMinutes:
          (json['averageResponseTimeMinutes'] as num).toDouble(),
      topContacts: (json['topContacts'] as List)
          .map((e) => TopContact.fromJson(e as Map<String, dynamic>))
          .toList(),
      messagingTrend: (json['messagingTrend'] as List)
          .map((e) => TimeSeriesPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'directMessagesSent': directMessagesSent,
      'groupMessagesSent': groupMessagesSent,
      'audioCalls': audioCalls,
      'videoConferences': videoConferences,
      'activeConversations': activeConversations,
      'unreadConversations': unreadConversations,
      'averageResponseTimeMinutes': averageResponseTimeMinutes,
      'topContacts': topContacts.map((e) => e.toJson()).toList(),
      'messagingTrend': messagingTrend.map((e) => e.toJson()).toList(),
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
    };
  }
}

class TopContact {
  final String contactId;
  final String contactName;
  final String? avatarUrl;
  final int messageCount;
  final bool isGroup;
  final DateTime lastMessageAt;

  const TopContact({
    required this.contactId,
    required this.contactName,
    this.avatarUrl,
    required this.messageCount,
    required this.isGroup,
    required this.lastMessageAt,
  });

  factory TopContact.fromJson(Map<String, dynamic> json) {
    return TopContact(
      contactId: json['contactId'] as String,
      contactName: json['contactName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      messageCount: json['messageCount'] as int,
      isGroup: json['isGroup'] as bool,
      lastMessageAt: DateTime.parse(json['lastMessageAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contactId': contactId,
      'contactName': contactName,
      'avatarUrl': avatarUrl,
      'messageCount': messageCount,
      'isGroup': isGroup,
      'lastMessageAt': lastMessageAt.toIso8601String(),
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
