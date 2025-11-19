import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../domain/conversation_analytics_providers.dart';
import '../widgets/stats_card.dart';
import '../widgets/line_chart_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/analytics_section_header.dart';
import '../../../../core/models/conversation_analytics.dart';
import '../../../../core/models/analytics_data.dart';

class ConversationAnalyticsScreen extends ConsumerWidget {
  const ConversationAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(conversationAnalyticsProvider);

    return analyticsAsync.when(
      data: (analytics) {
        if (analytics.totalMessagesSent == 0 && analytics.totalCalls == 0) {
          return EmptyStateWidget(
            message: 'هیچ فعالیت ارتباطی در این بازه زمانی وجود ندارد',
            subtitle: 'بازه زمانی دیگری را انتخاب کنید',
            icon: Icons.message,
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummarySection(context, analytics),
              const SizedBox(height: 24),
              _buildMessagingTrendChart(context, analytics),
              const SizedBox(height: 24),
              _buildTopContactsSection(context, analytics),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => EmptyStateWidget(
        message: 'خطا در بارگذاری داده‌ها',
        subtitle: error.toString(),
        icon: Icons.error_outline,
        onRetry: () {
          ref.invalidate(conversationAnalyticsProvider);
        },
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, ConversationAnalytics analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AnalyticsSectionHeader(
          title: 'خلاصه فعالیت‌های ارتباطی',
          subtitle: 'آمار کلی پیام‌ها و تماس‌ها',
          icon: Icons.summarize,
        ),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            StatsCard(
              title: 'پیام‌های مستقیم',
              value: analytics.directMessagesSent.toString(),
              icon: Icons.person,
              color: Colors.blue,
            ),
            StatsCard(
              title: 'پیام‌های گروهی',
              value: analytics.groupMessagesSent.toString(),
              icon: Icons.group,
              color: Colors.green,
            ),
            StatsCard(
              title: 'کل پیام‌ها',
              value: analytics.totalMessagesSent.toString(),
              icon: Icons.message,
              color: Colors.purple,
            ),
            StatsCard(
              title: 'تماس‌های صوتی',
              value: analytics.audioCalls.toString(),
              icon: Icons.phone,
              color: Colors.orange,
            ),
            StatsCard(
              title: 'ویدئو کنفرانس',
              value: analytics.videoConferences.toString(),
              icon: Icons.videocam,
              color: Colors.red,
            ),
            StatsCard(
              title: 'گفتگوهای فعال',
              value: analytics.activeConversations.toString(),
              icon: Icons.chat_bubble,
              color: Colors.teal,
            ),
            StatsCard(
              title: 'پیام‌های خوانده نشده',
              value: analytics.unreadConversations.toString(),
              icon: Icons.mark_chat_unread,
              color: Colors.amber,
            ),
            StatsCard(
              title: 'میانگین زمان پاسخ',
              value: _formatResponseTime(analytics.averageResponseTimeMinutes),
              icon: Icons.timer,
              color: Colors.indigo,
              subtitle: 'دقیقه',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMessagingTrendChart(BuildContext context, ConversationAnalytics analytics) {
    if (analytics.messagingTrend.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AnalyticsSectionHeader(
          title: 'روند ارسال پیام',
          subtitle: 'نمودار پیام‌های ارسالی در طول زمان',
          icon: Icons.show_chart,
        ),
        LineChartWidget(
          data: analytics.messagingTrend
              .map((point) => TimeSeriesData(
                    date: point.date,
                    value: point.value,
                  ))
              .toList(),
          title: 'تعداد پیام‌های روزانه',
          lineColor: Colors.blue,
          gradientStartColor: Colors.blue,
          gradientEndColor: Colors.blue.withOpacity(0.1),
        ),
      ],
    );
  }

  Widget _buildTopContactsSection(BuildContext context, ConversationAnalytics analytics) {
    if (analytics.topContacts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AnalyticsSectionHeader(
          title: 'مخاطبین برتر',
          subtitle: 'پرمکاتبه‌ترین افراد و گروه‌ها',
          icon: Icons.stars,
        ),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: analytics.topContacts.length > 10 ? 10 : analytics.topContacts.length,
            separatorBuilder: (context, index) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final contact = analytics.topContacts[index];
              return _buildContactItem(context, contact, index + 1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem(BuildContext context, TopContact contact, int rank) {
    final jalaliDate = Jalali.fromDateTime(contact.lastMessageAt);
    final dateString = '${jalaliDate.year}/${jalaliDate.month}/${jalaliDate.day}';

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getRankColor(rank),
                _getRankColor(rank).withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              '$rank',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      contact.contactName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (contact.isGroup)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.group, size: 10, color: Colors.blue),
                          SizedBox(width: 2),
                          Text(
                            'گروه',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.message, size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${contact.messageCount} پیام',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'آخرین: $dateString',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getRankColor(rank).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            contact.messageCount.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _getRankColor(rank),
            ),
          ),
        ),
      ],
    );
  }

  String _formatResponseTime(double minutes) {
    if (minutes < 1) {
      return '< ۱';
    }
    if (minutes < 60) {
      return minutes.toStringAsFixed(0);
    }
    final hours = minutes / 60;
    return '${hours.toStringAsFixed(1)}h';
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.brown[400]!;
      default:
        return Colors.blue;
    }
  }
}
