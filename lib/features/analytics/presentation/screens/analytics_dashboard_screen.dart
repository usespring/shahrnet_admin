import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/analytics_providers.dart';
import '../widgets/stats_card.dart';
import '../widgets/line_chart_widget.dart';
import '../widgets/pie_chart_widget.dart';
import '../widgets/bar_chart_widget.dart';
import '../widgets/top_users_list.dart';

class AnalyticsDashboardScreen extends ConsumerWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateRange = ref.watch(dateRangeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('داشبورد تحلیلی'),
        actions: [
          _buildDateRangeSelector(context, ref),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(analyticsSummaryProvider);
          ref.invalidate(timeSeriesDataProvider);
          ref.invalidate(activityDistributionProvider);
          ref.invalidate(sectionActivityProvider);
          ref.invalidate(topActiveUsersProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // خلاصه آمار
              _buildSummarySection(ref),

              const SizedBox(height: 24),

              // نمودار خطی - فعالیت در طول زمان
              _buildTimeSeriesChart(ref),

              const SizedBox(height: 24),

              // نمودارهای دایره‌ای و میله‌ای
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildActivityDistributionChart(ref),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSectionActivityChart(ref),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // لیست کاربران فعال
              _buildTopUsersSection(ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector(BuildContext context, WidgetRef ref) {
    final dateRange = ref.watch(dateRangeProvider);

    return PopupMenuButton<DateRangeType>(
      icon: const Icon(Icons.date_range),
      onSelected: (DateRangeType type) {
        switch (type) {
          case DateRangeType.last7Days:
            ref.read(dateRangeProvider.notifier).setLast7Days();
            break;
          case DateRangeType.last30Days:
            ref.read(dateRangeProvider.notifier).setLast30Days();
            break;
          case DateRangeType.last90Days:
            ref.read(dateRangeProvider.notifier).setLast90Days();
            break;
          case DateRangeType.custom:
            // TODO: Implement custom date range picker
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: DateRangeType.last7Days,
          child: Text(
            '۷ روز گذشته',
            style: TextStyle(
              fontWeight: dateRange.type == DateRangeType.last7Days
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
        PopupMenuItem(
          value: DateRangeType.last30Days,
          child: Text(
            '۳۰ روز گذشته',
            style: TextStyle(
              fontWeight: dateRange.type == DateRangeType.last30Days
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
        PopupMenuItem(
          value: DateRangeType.last90Days,
          child: Text(
            '۹۰ روز گذشته',
            style: TextStyle(
              fontWeight: dateRange.type == DateRangeType.last90Days
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection(WidgetRef ref) {
    final summaryAsync = ref.watch(analyticsSummaryProvider);

    return summaryAsync.when(
      data: (summary) {
        return GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            StatsCard(
              title: 'کل کاربران',
              value: summary.totalUsers.toString(),
              icon: Icons.people,
              color: Colors.blue,
            ),
            StatsCard(
              title: 'کاربران فعال',
              value: summary.activeUsers.toString(),
              icon: Icons.person_outline,
              color: Colors.green,
              subtitle:
                  '${((summary.activeUsers / summary.totalUsers) * 100).toStringAsFixed(1)}% از کل',
            ),
            StatsCard(
              title: 'کل فعالیت‌ها',
              value: summary.totalActivities.toString(),
              icon: Icons.trending_up,
              color: Colors.orange,
            ),
            StatsCard(
              title: 'میانگین فعالیت',
              value: summary.averageActivitiesPerUser.toStringAsFixed(1),
              icon: Icons.bar_chart,
              color: Colors.purple,
              subtitle: 'به ازای هر کاربر',
            ),
          ],
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Center(
        child: Text('خطا در بارگذاری: $error'),
      ),
    );
  }

  Widget _buildTimeSeriesChart(WidgetRef ref) {
    final timeSeriesAsync = ref.watch(timeSeriesDataProvider);

    return timeSeriesAsync.when(
      data: (data) {
        return LineChartWidget(
          data: data,
          title: 'روند فعالیت کاربران',
          lineColor: Colors.blue,
          gradientStartColor: Colors.blue,
          gradientEndColor: Colors.blue.withOpacity(0.1),
        );
      },
      loading: () => const Card(
        child: SizedBox(
          height: 300,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => Card(
        child: SizedBox(
          height: 300,
          child: Center(child: Text('خطا در بارگذاری: $error')),
        ),
      ),
    );
  }

  Widget _buildActivityDistributionChart(WidgetRef ref) {
    final distributionAsync = ref.watch(activityDistributionProvider);

    return distributionAsync.when(
      data: (data) {
        return PieChartWidget(
          data: data,
          title: 'توزیع انواع فعالیت',
        );
      },
      loading: () => const Card(
        child: SizedBox(
          height: 300,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => Card(
        child: SizedBox(
          height: 300,
          child: Center(child: Text('خطا: $error')),
        ),
      ),
    );
  }

  Widget _buildSectionActivityChart(WidgetRef ref) {
    final sectionAsync = ref.watch(sectionActivityProvider);

    return sectionAsync.when(
      data: (data) {
        return BarChartWidget(
          data: data,
          title: 'فعالیت در بخش‌های مختلف',
          barColor: Colors.green,
        );
      },
      loading: () => const Card(
        child: SizedBox(
          height: 300,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => Card(
        child: SizedBox(
          height: 300,
          child: Center(child: Text('خطا: $error')),
        ),
      ),
    );
  }

  Widget _buildTopUsersSection(WidgetRef ref) {
    final topUsersAsync = ref.watch(topActiveUsersProvider);

    return topUsersAsync.when(
      data: (users) {
        return TopUsersList(
          users: users,
          title: 'کاربران برتر',
        );
      },
      loading: () => const Card(
        child: SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => Card(
        child: SizedBox(
          height: 200,
          child: Center(child: Text('خطا: $error')),
        ),
      ),
    );
  }
}
