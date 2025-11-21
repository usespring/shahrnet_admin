import 'package:flutter/material.dart';

/// Widget that displays sentiment distribution with horizontal bars
class SentimentDistributionWidget extends StatelessWidget {
  final Map<String, int> distribution;
  final String title;

  const SentimentDistributionWidget({
    super.key,
    required this.distribution,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final total = distribution.values.fold<int>(0, (sum, value) => sum + value);

    if (total == 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Text(
              'داده‌ای برای نمایش وجود ندارد',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(),
            ...distribution.entries.map((entry) {
              final percentage = (entry.value / total * 100);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${entry.value} (${percentage.toStringAsFixed(0)}%)',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        minHeight: 12,
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getColorForLabel(entry.key),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Color _getColorForLabel(String label) {
    if (label.contains('منفی')) {
      return label.contains('بسیار') ? Colors.red : Colors.orange;
    } else if (label.contains('مثبت')) {
      return label.contains('بسیار') ? Colors.green : Colors.lightGreen;
    } else if (label.contains('خنثی')) {
      return Colors.grey;
    } else if (label.contains('بد')) {
      return label.contains('بسیار') ? Colors.red : Colors.orange;
    } else if (label.contains('خوب')) {
      return label.contains('بسیار') ? Colors.green : Colors.lightGreen;
    }
    return Colors.blue;
  }
}
