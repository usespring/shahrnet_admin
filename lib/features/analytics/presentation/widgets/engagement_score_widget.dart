import 'package:flutter/material.dart';
import 'package:shahrnet_admin/core/models/sentiment_analytics.dart';
import 'dart:math' as math;

/// Widget that displays an engagement score with a circular gauge
class EngagementScoreWidget extends StatelessWidget {
  final double score; // 0-100
  final EmotionalStatus status;

  const EngagementScoreWidget({
    super.key,
    required this.score,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'نمره فعالیت',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              width: 200,
              child: CustomPaint(
                painter: _CircularGaugePainter(
                  score: score,
                  color: _getColorForStatus(status),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        status.emoji,
                        style: const TextStyle(fontSize: 48),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        score.toStringAsFixed(0),
                        style:
                            Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        'از ۱۰۰',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              status.displayName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _getColorForStatus(status),
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForStatus(EmotionalStatus status) {
    switch (status) {
      case EmotionalStatus.veryLow:
        return Colors.red;
      case EmotionalStatus.low:
        return Colors.orange;
      case EmotionalStatus.medium:
        return Colors.amber;
      case EmotionalStatus.high:
        return Colors.lightGreen;
      case EmotionalStatus.veryHigh:
        return Colors.green;
    }
  }
}

/// Custom painter for circular gauge
class _CircularGaugePainter extends CustomPainter {
  final double score;
  final Color color;

  _CircularGaugePainter({
    required this.score,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final strokeWidth = 20.0;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, backgroundPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          color.withOpacity(0.5),
          color,
        ],
        startAngle: 0,
        endAngle: math.pi * 2 * (score / 100),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * (score / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularGaugePainter oldDelegate) {
    return oldDelegate.score != score || oldDelegate.color != color;
  }
}
