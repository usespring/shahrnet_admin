import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/engagement_analytics_providers.dart';

/// Detailed view of an employee's risk profile
class EmployeeDetailScreen extends ConsumerWidget {
  final String employeeId;

  const EmployeeDetailScreen({
    super.key,
    required this.employeeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeeAsync = ref.watch(employeeByIdProvider(employeeId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('جزئیات کارمند'),
      ),
      body: employeeAsync.when(
        data: (employee) {
          if (employee == null) {
            return const Center(child: Text('کارمند یافت نشد'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor:
                              _getRiskColor(employee.dropOffRiskScore),
                          child: Text(
                            employee.userName.substring(0, 1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                employee.userName,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'مدیر: ${employee.managerName ?? 'ندارد'}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'آخرین فعالیت: ${employee.daysInactive} روز پیش',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Scores
                Row(
                  children: [
                    Expanded(
                      child: _buildScoreCard(
                        context,
                        'خطر ترک',
                        employee.dropOffRiskScore,
                        employee.riskLevel.displayName,
                        _getRiskColor(employee.dropOffRiskScore),
                        Icons.warning_amber_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildScoreCard(
                        context,
                        'مشارکت',
                        employee.engagementScore,
                        employee.engagementLevel.displayName,
                        _getEngagementColor(employee.engagementScore),
                        Icons.trending_up,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Activity Decline Signals
                _buildSectionHeader('سیگنال‌های کاهش فعالیت'),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildSignalRow(
                          'تایم‌لاین',
                          employee.activityDeclineSignals.timelineActivityChange,
                        ),
                        _buildSignalRow(
                          'یادگیری',
                          employee.activityDeclineSignals.learningActivityChange,
                        ),
                        _buildSignalRow(
                          'گفتگو',
                          employee
                              .activityDeclineSignals.conversationActivityChange,
                        ),
                        _buildSignalRow(
                          'ورود به سیستم',
                          employee.activityDeclineSignals.loginFrequencyChange,
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ورود این هفته',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Text(
                              '${employee.activityDeclineSignals.currentWeekLogins} بار',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ورود هفته قبل',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Text(
                              '${employee.activityDeclineSignals.previousWeekLogins} بار',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Behavioral Signals
                _buildSectionHeader('سیگنال‌های رفتاری'),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          'احساسات',
                          '${employee.behavioralSignals.sentimentLevel.displayName} (${(employee.behavioralSignals.averageSentimentScore * 100).toStringAsFixed(0)}%)',
                          employee.behavioralSignals.sentimentLevel.emoji,
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'میزان مشارکت',
                          '${employee.behavioralSignals.participationRate.toStringAsFixed(0)}%',
                          null,
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'هفته‌های غیرفعال متوالی',
                          '${employee.behavioralSignals.consecutiveInactiveWeeks}',
                          null,
                        ),
                        if (employee.behavioralSignals.averageMoodLevel != null)
                          ...[
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              'خلق و خو',
                              employee
                                  .behavioralSignals.averageMoodLevel!.displayName,
                              employee.behavioralSignals.averageMoodLevel!.emoji,
                            ),
                          ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Survey Signals (if available)
                if (employee.surveySignals != null) ...[
                  _buildSectionHeader('نظرسنجی‌ها'),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          if (employee.surveySignals!.managerSupportRating !=
                              null)
                            _buildRatingRow(
                              'پشتیبانی مدیر',
                              employee.surveySignals!.managerSupportRating!,
                            ),
                          if (employee
                                  .surveySignals!.peerCollaborationRating !=
                              null)
                            _buildRatingRow(
                              'همکاری با همکاران',
                              employee.surveySignals!.peerCollaborationRating!,
                            ),
                          if (employee.surveySignals!.jobSatisfactionRating !=
                              null)
                            _buildRatingRow(
                              'رضایت شغلی',
                              employee.surveySignals!.jobSatisfactionRating!,
                            ),
                          if (employee.surveySignals!.concerns.isNotEmpty) ...[
                            const Divider(),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'نگرانی‌ها:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...employee.surveySignals!.concerns
                                .map((concern) => Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.circle,
                                              size: 6, color: Colors.red),
                                          const SizedBox(width: 8),
                                          Text(concern),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('خطا: $error')),
      ),
    );
  }

  Widget _buildScoreCard(
    BuildContext context,
    String title,
    double score,
    String level,
    Color color,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              score.toStringAsFixed(0),
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              level,
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSignalRow(String label, double change) {
    final isNegative = change < 0;
    final color = isNegative ? Colors.red : Colors.green;
    final icon = isNegative ? Icons.arrow_downward : Icons.arrow_upward;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                '${change.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, String? emoji) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600])),
        Row(
          children: [
            if (emoji != null) ...[
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
            ],
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingRow(String label, double rating) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: [
              ...List.generate(5, (index) {
                return Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  size: 16,
                  color: Colors.amber,
                );
              }),
              const SizedBox(width: 8),
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRiskColor(double score) {
    if (score < 40) return Colors.green;
    if (score < 70) return Colors.orange;
    return Colors.red;
  }

  Color _getEngagementColor(double score) {
    if (score >= 70) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }
}
