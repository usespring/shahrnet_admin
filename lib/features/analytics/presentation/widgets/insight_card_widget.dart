import 'package:flutter/material.dart';
import 'package:shahrnet_admin/core/models/sentiment_analytics.dart';

/// Widget that displays a smart insight card
class InsightCardWidget extends StatelessWidget {
  final SmartInsight insight;

  const InsightCardWidget({
    super.key,
    required this.insight,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border(
            right: BorderSide(
              color: _getColorForType(insight.type),
              width: 4,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getColorForType(insight.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconForType(insight.type),
                  color: _getColorForType(insight.type),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      insight.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorForType(InsightType type) {
    switch (type) {
      case InsightType.positive:
        return Colors.green;
      case InsightType.neutral:
        return Colors.blue;
      case InsightType.warning:
        return Colors.orange;
      case InsightType.trend:
        return Colors.purple;
    }
  }

  IconData _getIconForType(InsightType type) {
    switch (type) {
      case InsightType.positive:
        return Icons.celebration;
      case InsightType.neutral:
        return Icons.info_outline;
      case InsightType.warning:
        return Icons.warning_amber;
      case InsightType.trend:
        return Icons.trending_up;
    }
  }
}
