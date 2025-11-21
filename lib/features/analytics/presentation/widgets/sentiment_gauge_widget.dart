import 'package:flutter/material.dart';
import 'package:shahrnet_admin/core/models/sentiment_analytics.dart';

/// Widget that displays sentiment level with a horizontal gauge
class SentimentGaugeWidget extends StatelessWidget {
  final double score; // -1 to 1
  final SentimentLevel level;

  const SentimentGaugeWidget({
    super.key,
    required this.score,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'میانگین احساسات متنی',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 220;
                  final infoColumn = Column(
                    crossAxisAlignment: isCompact
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        level.displayName,
                        textAlign: isCompact ? TextAlign.center : TextAlign.start,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'نمره: ${_formatScore(score)}',
                        textAlign: isCompact ? TextAlign.center : TextAlign.start,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.grey,
                                ),
                      ),
                    ],
                  );

                  if (isCompact) {
                    return Column(
                      children: [
                        Text(
                          level.emoji,
                          style: const TextStyle(fontSize: 64),
                        ),
                        const SizedBox(height: 16),
                        infoColumn,
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        level.emoji,
                        style: const TextStyle(fontSize: 64),
                      ),
                      const SizedBox(width: 24),
                      Expanded(child: infoColumn),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            // Horizontal sentiment gauge
            _buildHorizontalGauge(context),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final labels = [
                    Text(
                      'منفی 😢',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'مثبت 😄',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ];

                  if (constraints.maxWidth < 140) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        labels[0],
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: labels[1],
                        ),
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: labels,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalGauge(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Colors.red,
            Colors.orange,
            Colors.amber,
            Colors.lightGreen,
            Colors.green,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Indicator
          Align(
            alignment: Alignment((score + 1) / 2 * 2 - 1, 0),
            child: Container(
              width: 8,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatScore(double score) {
    if (score >= 0) {
      return '+${(score * 100).toStringAsFixed(0)}';
    } else {
      return '${(score * 100).toStringAsFixed(0)}';
    }
  }
}
