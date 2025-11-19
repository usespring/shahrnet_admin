import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/analytics_providers.dart';

class DateRangeFilter extends ConsumerWidget {
  const DateRangeFilter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateRange = ref.watch(dateRangeProvider);

    return PopupMenuButton<DateRangeType>(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.date_range, size: 20),
          const SizedBox(width: 4),
          Text(
            _getDateRangeLabel(dateRange.type),
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
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
            _showCustomDatePicker(context, ref);
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: DateRangeType.last7Days,
          child: Row(
            children: [
              Icon(
                Icons.check,
                size: 18,
                color: dateRange.type == DateRangeType.last7Days
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
              ),
              const SizedBox(width: 8),
              Text(
                '۷ روز گذشته',
                style: TextStyle(
                  fontWeight: dateRange.type == DateRangeType.last7Days
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: DateRangeType.last30Days,
          child: Row(
            children: [
              Icon(
                Icons.check,
                size: 18,
                color: dateRange.type == DateRangeType.last30Days
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
              ),
              const SizedBox(width: 8),
              Text(
                '۳۰ روز گذشته',
                style: TextStyle(
                  fontWeight: dateRange.type == DateRangeType.last30Days
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: DateRangeType.last90Days,
          child: Row(
            children: [
              Icon(
                Icons.check,
                size: 18,
                color: dateRange.type == DateRangeType.last90Days
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
              ),
              const SizedBox(width: 8),
              Text(
                '۹۰ روز گذشته',
                style: TextStyle(
                  fontWeight: dateRange.type == DateRangeType.last90Days
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: DateRangeType.custom,
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 18),
              SizedBox(width: 8),
              Text('بازه سفارشی...'),
            ],
          ),
        ),
      ],
    );
  }

  String _getDateRangeLabel(DateRangeType type) {
    switch (type) {
      case DateRangeType.last7Days:
        return '۷ روز';
      case DateRangeType.last30Days:
        return '۳۰ روز';
      case DateRangeType.last90Days:
        return '۹۰ روز';
      case DateRangeType.custom:
        return 'سفارشی';
    }
  }

  Future<void> _showCustomDatePicker(BuildContext context, WidgetRef ref) async {
    final dateRange = ref.read(dateRangeProvider);

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: dateRange.startDate,
        end: dateRange.endDate,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context),
          child: child!,
        );
      },
    );

    if (picked != null) {
      ref.read(dateRangeProvider.notifier).setCustomRange(
            picked.start,
            picked.end,
          );
    }
  }
}
