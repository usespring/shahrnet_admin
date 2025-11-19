import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/engagement_analytics_providers.dart';

/// Screen showing list of managers ranked by support quality
class ManagerSupportListScreen extends ConsumerWidget {
  const ManagerSupportListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final managersAsync = ref.watch(managerSupportProfilesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('رتبه‌بندی مدیران'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(managerSupportProfilesProvider);
            },
          ),
        ],
      ),
      body: managersAsync.when(
        data: (managers) {
          if (managers.isEmpty) {
            return const Center(child: Text('هیچ مدیری یافت نشد'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: managers.length,
            itemBuilder: (context, index) {
              final manager = managers[index];
              return _buildManagerCard(context, manager, index + 1);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('خطا: $error')),
      ),
    );
  }

  Widget _buildManagerCard(context, manager, int rank) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Rank badge
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getRankColor(rank),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$rank',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        manager.managerName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'تیم: ${manager.teamMetrics.teamSize} نفر',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Supportiveness score
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getSupportivenessColor(
                            manager.supportivenessScore)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        manager.supportivenessScore.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color:
                              _getSupportivenessColor(manager.supportivenessScore),
                        ),
                      ),
                      Text(
                        'امتیاز',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Ratings
            Row(
              children: [
                Expanded(
                  child: _buildRatingMetric(
                    'ارتباطات',
                    manager.ratings.communicationScore,
                  ),
                ),
                Expanded(
                  child: _buildRatingMetric(
                    'پشتیبانی',
                    manager.ratings.supportivenessScore,
                  ),
                ),
                Expanded(
                  child: _buildRatingMetric(
                    'انصاف',
                    manager.ratings.fairnessScore,
                  ),
                ),
                Expanded(
                  child: _buildRatingMetric(
                    'رهبری',
                    manager.ratings.leadershipScore,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Team metrics
            Row(
              children: [
                Expanded(
                  child: _buildTeamMetric(
                    'مشارکت تیم',
                    manager.teamMetrics.averageTeamEngagement.toStringAsFixed(0),
                    Icons.trending_up,
                    _getSupportivenessColor(
                        manager.teamMetrics.averageTeamEngagement),
                  ),
                ),
                Expanded(
                  child: _buildTeamMetric(
                    'فعال',
                    '${manager.teamMetrics.activeMembers}/${manager.teamMetrics.teamSize}',
                    Icons.people,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildTeamMetric(
                    'خطر بالا',
                    '${manager.teamMetrics.highRiskMembers}',
                    Icons.warning,
                    Colors.red,
                  ),
                ),
              ],
            ),

            // Strengths and improvements
            if (manager.strengths.isNotEmpty || manager.improvementAreas.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              if (manager.strengths.isNotEmpty) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle,
                        size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: manager.strengths
                            .map<Widget>((s) => Chip(
                                  label: Text(s),
                                  backgroundColor: Colors.green[50],
                                  labelStyle: const TextStyle(fontSize: 11),
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ],
              if (manager.improvementAreas.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline,
                        size: 16, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: manager.improvementAreas
                            .map<Widget>((s) => Chip(
                                  label: Text(s),
                                  backgroundColor: Colors.orange[50],
                                  labelStyle: const TextStyle(fontSize: 11),
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ],

            // Recent feedback count
            if (manager.recentFeedback.isNotEmpty) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () {
                  _showFeedbackDialog(context, manager);
                },
                icon: const Icon(Icons.comment, size: 16),
                label: Text(
                  'مشاهده ${manager.recentFeedback.length} بازخورد',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRatingMetric(String label, double rating) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return Icon(
              index < rating ? Icons.star : Icons.star_border,
              size: 14,
              color: Colors.amber,
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTeamMetric(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showFeedbackDialog(BuildContext context, manager) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('بازخوردها - ${manager.managerName}'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: manager.recentFeedback.length,
            itemBuilder: (context, index) {
              final feedback = manager.recentFeedback[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feedback.employeeName ?? 'ناشناس',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (feedback.comment != null)
                        Text(
                          feedback.comment!,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        'میانگین: ${(feedback.ratings.values.reduce((a, b) => a + b) / feedback.ratings.length).toStringAsFixed(1)} ⭐',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('بستن'),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return Colors.grey;
    if (rank == 3) return Colors.brown;
    return Colors.blue;
  }

  Color _getSupportivenessColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}
