import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/engagement_analytics_providers.dart';
import '../widgets/analytics_section_header.dart';
import '../widgets/date_range_filter.dart';
import 'employee_risk_list_screen.dart';
import 'manager_support_list_screen.dart';

/// Main engagement analytics screen with overview and navigation
class EngagementAnalyticsScreen extends ConsumerWidget {
  const EngagementAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(companyEngagementSummaryProvider);
    final insightsAsync = ref.watch(engagementInsightsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('مشارکت و خطر'),
        actions: [
          const DateRangeFilter(),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'بروزرسانی',
            onPressed: () {
              ref.invalidate(engagementAnalyticsProvider);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(engagementAnalyticsProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overview Cards
              summaryAsync.when(
                data: (summary) => _buildOverviewCards(context, summary),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stack) => Center(
                  child: Text('خطا: $error'),
                ),
              ),
              const SizedBox(height: 24),

              // Smart Insights
              const AnalyticsSectionHeader(
                title: 'هشدارها و پیشنهادات هوشمند',
                icon: Icons.lightbulb_outline,
              ),
              const SizedBox(height: 12),
              insightsAsync.when(
                data: (insights) => _buildInsightsSection(context, insights),
                loading: () => const LinearProgressIndicator(),
                error: (error, stack) => Text('خطا: $error'),
              ),
              const SizedBox(height: 24),

              // Quick Access Buttons
              _buildQuickAccessButtons(context),
              const SizedBox(height: 24),

              // Recent At-Risk Employees Preview
              const AnalyticsSectionHeader(
                title: 'کارمندان در معرض خطر',
                icon: Icons.warning_amber_rounded,
              ),
              const SizedBox(height: 12),
              _buildAtRiskPreview(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCards(BuildContext context, summary) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context: context,
                title: 'میانگین مشارکت',
                value: summary.averageEngagementScore.toStringAsFixed(1),
                subtitle: 'از 100',
                icon: Icons.trending_up,
                color: _getEngagementColor(summary.averageEngagementScore),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                context: context,
                title: 'خطر ترک',
                value: summary.averageDropOffRisk.toStringAsFixed(1),
                subtitle: 'از 100',
                icon: Icons.warning,
                color: _getRiskColor(summary.averageDropOffRisk),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context: context,
                title: 'کارمندان فعال',
                value: '${summary.activeEmployees}',
                subtitle: 'از ${summary.totalEmployees}',
                icon: Icons.people,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                context: context,
                title: 'خطر بالا',
                value: '${summary.highRiskEmployees}',
                subtitle: 'کارمند',
                icon: Icons.error_outline,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsSection(BuildContext context, insights) {
    if (insights.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('هیچ هشداری در حال حاضر وجود ندارد'),
        ),
      );
    }

    return Column(
      children: insights.take(3).map<Widget>((insight) {
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              _getInsightIcon(insight.type),
              color: _getInsightColor(insight.type),
            ),
            title: Text(
              insight.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(insight.description),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickAccessButtons(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EmployeeRiskListScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.people_outline),
                label: const Text('لیست کارمندان'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ManagerSupportListScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.supervisor_account),
                label: const Text('رتبه‌بندی مدیران'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAtRiskPreview(BuildContext context, WidgetRef ref) {
    final atRiskAsync = ref.watch(atRiskEmployeesProvider);

    return atRiskAsync.when(
      data: (employees) {
        if (employees.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('هیچ کارمند در معرض خطری یافت نشد'),
            ),
          );
        }

        return Card(
          child: Column(
            children: [
              ...employees.take(5).map((employee) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getRiskColor(employee.dropOffRiskScore),
                    child: Text(
                      employee.userName.substring(0, 1),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(employee.userName),
                  subtitle: Text(
                    'خطر: ${employee.dropOffRiskScore.toStringAsFixed(0)} - ${employee.riskLevel.displayName}',
                  ),
                  trailing: Text(
                    '${employee.daysInactive} روز غیرفعال',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                );
              }).toList(),
              if (employees.length > 5)
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EmployeeRiskListScreen(),
                      ),
                    );
                  },
                  child: Text('مشاهده همه (${employees.length})'),
                ),
            ],
          ),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (error, stack) => Text('خطا: $error'),
    );
  }

  Color _getEngagementColor(double score) {
    if (score >= 70) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  Color _getRiskColor(double score) {
    if (score < 40) return Colors.green;
    if (score < 70) return Colors.orange;
    return Colors.red;
  }

  IconData _getInsightIcon(type) {
    switch (type.toString()) {
      case 'InsightType.positive':
        return Icons.thumb_up;
      case 'InsightType.warning':
        return Icons.warning;
      case 'InsightType.trend':
        return Icons.trending_up;
      default:
        return Icons.info;
    }
  }

  Color _getInsightColor(type) {
    switch (type.toString()) {
      case 'InsightType.positive':
        return Colors.green;
      case 'InsightType.warning':
        return Colors.orange;
      case 'InsightType.trend':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
