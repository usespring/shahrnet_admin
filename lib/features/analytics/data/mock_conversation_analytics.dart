import 'dart:math';
import '../../../core/models/conversation_analytics.dart';

class MockConversationAnalytics {
  static final _random = Random(42);

  static const List<String> _contactNames = [
    'محمد رضایی',
    'فاطمه احمدی',
    'علی کریمی',
    'زهرا محمدی',
    'حسین موسوی',
    'مریم حسینی',
    'رضا احمدپور',
    'سارا جعفری',
    'مهدی نوری',
    'نرگس امینی',
    'امیر حسینی',
    'الهام کاظمی',
  ];

  static const List<String> _groupNames = [
    'تیم توسعه محصول',
    'گروه بازاریابی و فروش',
    'واحد منابع انسانی',
    'تیم پشتیبانی مشتریان',
    'گروه مدیریت پروژه',
    'تیم طراحی و گرافیک',
    'واحد مالی و حسابداری',
    'گروه تحقیق و توسعه',
  ];

  static ConversationAnalytics generateAnalytics({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final daysDiff = endDate.difference(startDate).inDays;

    // Generate random counts
    final directMessagesSent = 50 + _random.nextInt(200);
    final groupMessagesSent = 30 + _random.nextInt(100);
    final audioCalls = 5 + _random.nextInt(15);
    final videoConferences = 2 + _random.nextInt(8);
    final activeConversations = 8 + _random.nextInt(15);
    final unreadConversations = _random.nextInt(10);
    final averageResponseTimeMinutes = 5.0 + _random.nextDouble() * 55;

    // Generate messaging trend
    final messagingTrend = _generateMessagingTrend(startDate, endDate);

    // Generate top contacts
    final topContacts = _generateTopContacts(10, startDate, endDate);

    return ConversationAnalytics(
      directMessagesSent: directMessagesSent,
      groupMessagesSent: groupMessagesSent,
      audioCalls: audioCalls,
      videoConferences: videoConferences,
      activeConversations: activeConversations,
      unreadConversations: unreadConversations,
      averageResponseTimeMinutes: averageResponseTimeMinutes,
      topContacts: topContacts,
      messagingTrend: messagingTrend,
      periodStart: startDate,
      periodEnd: endDate,
    );
  }

  static List<TimeSeriesPoint> _generateMessagingTrend(
    DateTime startDate,
    DateTime endDate,
  ) {
    final points = <TimeSeriesPoint>[];
    var currentDate = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    while (currentDate.isBefore(end) || currentDate.isAtSameMomentAs(end)) {
      // Generate random message count with weekday/weekend variation
      final isWeekend = currentDate.weekday == DateTime.saturday ||
                        currentDate.weekday == DateTime.sunday;
      final baseValue = isWeekend ? 5.0 : 15.0;
      final variance = _random.nextDouble() * (isWeekend ? 5.0 : 15.0);

      points.add(TimeSeriesPoint(
        date: currentDate,
        value: baseValue + variance,
      ));

      currentDate = currentDate.add(const Duration(days: 1));
    }

    return points;
  }

  static List<TopContact> _generateTopContacts(
    int count,
    DateTime startDate,
    DateTime endDate,
  ) {
    final contacts = <TopContact>[];
    final usedNames = <String>{};

    // Mix of individuals and groups
    for (var i = 0; i < count; i++) {
      final isGroup = i < 3 ? true : _random.nextBool();
      String name;

      if (isGroup) {
        do {
          name = _groupNames[_random.nextInt(_groupNames.length)];
        } while (usedNames.contains(name) && usedNames.length < _groupNames.length);
      } else {
        do {
          name = _contactNames[_random.nextInt(_contactNames.length)];
        } while (usedNames.contains(name) && usedNames.length < _contactNames.length);
      }
      usedNames.add(name);

      final daysAgo = _random.nextInt(endDate.difference(startDate).inDays);
      final lastMessageAt = endDate.subtract(Duration(days: daysAgo));

      // Groups typically have more messages
      final baseMessageCount = isGroup ? 50 : 20;
      final messageCount = baseMessageCount + _random.nextInt(isGroup ? 100 : 50);

      contacts.add(TopContact(
        contactId: 'contact_${i + 1}',
        contactName: name,
        avatarUrl: null,
        messageCount: messageCount,
        isGroup: isGroup,
        lastMessageAt: lastMessageAt,
      ));
    }

    // Sort by message count (descending)
    contacts.sort((a, b) => b.messageCount.compareTo(a.messageCount));

    return contacts;
  }
}
