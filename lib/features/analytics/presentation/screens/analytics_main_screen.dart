import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/date_range_filter.dart';
import 'timeline_analytics_screen.dart';
import 'learn_analytics_screen.dart';
import 'conversation_analytics_screen.dart';
import 'sentiment_analytics_screen.dart';
import 'engagement_analytics_screen.dart';
import '../../domain/timeline_analytics_providers.dart';
import '../../domain/learn_analytics_providers.dart';
import '../../domain/conversation_analytics_providers.dart';
import '../../domain/sentiment_analytics_providers.dart';
import '../../domain/engagement_analytics_providers.dart';

class AnalyticsMainScreen extends ConsumerStatefulWidget {
  const AnalyticsMainScreen({super.key});

  @override
  ConsumerState<AnalyticsMainScreen> createState() => _AnalyticsMainScreenState();
}

class _AnalyticsMainScreenState extends ConsumerState<AnalyticsMainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تحلیل و بررسی'),
        actions: [
          const DateRangeFilter(),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _refreshCurrentTab();
            },
            tooltip: 'بروزرسانی',
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(
              icon: Icon(Icons.timeline),
              text: 'تایم‌لاین',
            ),
            Tab(
              icon: Icon(Icons.school),
              text: 'آموزش',
            ),
            Tab(
              icon: Icon(Icons.message),
              text: 'گفتگوها',
            ),
            Tab(
              icon: Icon(Icons.psychology),
              text: 'احساسات',
            ),
            Tab(
              icon: Icon(Icons.people_alt),
              text: 'مشارکت و خطر',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          TimelineAnalyticsScreen(),
          LearnAnalyticsScreen(),
          ConversationAnalyticsScreen(),
          SentimentAnalyticsScreen(),
          EngagementAnalyticsScreen(),
        ],
      ),
    );
  }

  void _refreshCurrentTab() {
    final currentIndex = _tabController.index;
    switch (currentIndex) {
      case 0:
        ref.invalidate(timelineAnalyticsProvider);
        break;
      case 1:
        ref.invalidate(learnAnalyticsProvider);
        break;
      case 2:
        ref.invalidate(conversationAnalyticsProvider);
        break;
      case 3:
        ref.invalidate(sentimentAnalyticsProvider);
        break;
      case 4:
        ref.invalidate(engagementAnalyticsProvider);
        break;
    }
  }
}
