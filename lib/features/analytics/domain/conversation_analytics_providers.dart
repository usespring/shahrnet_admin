import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/conversation_analytics.dart';
import '../data/mock_conversation_analytics.dart';
import 'analytics_providers.dart';

final conversationAnalyticsProvider =
    FutureProvider.autoDispose<ConversationAnalytics>((ref) async {
  final dateRange = ref.watch(dateRangeProvider);

  // Simulate API delay
  await Future.delayed(const Duration(milliseconds: 500));

  return MockConversationAnalytics.generateAnalytics(
    startDate: dateRange.startDate,
    endDate: dateRange.endDate,
  );
});
