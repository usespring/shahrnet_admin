import 'package:flutter/material.dart';
import 'package:shahrnet_admin/core/models/sentiment_analytics.dart';
import 'package:shamsi_date/shamsi_date.dart';

/// Widget that displays mood entries in a timeline format
class MoodTimelineWidget extends StatelessWidget {
  final List<MoodEntry> entries;
  final int maxEntries;

  const MoodTimelineWidget({
    super.key,
    required this.entries,
    this.maxEntries = 10,
  });

  @override
  Widget build(BuildContext context) {
    final displayEntries = entries.take(maxEntries).toList();

    if (displayEntries.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              children: [
                const Icon(
                  Icons.mood,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'هیچ گزارش روحیه‌ای ثبت نشده',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
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
              child: Row(
                children: [
                  const Icon(Icons.timeline, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    'تاریخچه گزارش‌های روحیه',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            const Divider(),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayEntries.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final entry = displayEntries[index];
                return _buildMoodEntryTile(context, entry);
              },
            ),
            if (entries.length > maxEntries)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Center(
                  child: Text(
                    'و ${entries.length - maxEntries} گزارش دیگر...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodEntryTile(BuildContext context, MoodEntry entry) {
    final jalaliDate = Jalali.fromDateTime(entry.date);
    final dateStr = '${jalaliDate.year}/${jalaliDate.month}/${jalaliDate.day}';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getMoodColor(entry.mood).withOpacity(0.2),
        child: Text(
          entry.mood.emoji,
          style: const TextStyle(fontSize: 24),
        ),
      ),
      title: Row(
        children: [
          Text(
            entry.mood.displayName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _getMoodColor(entry.mood).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              dateStr,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
      subtitle: entry.comment != null
          ? Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                entry.comment!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          : null,
    );
  }

  Color _getMoodColor(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.veryBad:
        return Colors.red;
      case MoodLevel.bad:
        return Colors.orange;
      case MoodLevel.neutral:
        return Colors.grey;
      case MoodLevel.good:
        return Colors.lightGreen;
      case MoodLevel.veryGood:
        return Colors.green;
    }
  }
}
