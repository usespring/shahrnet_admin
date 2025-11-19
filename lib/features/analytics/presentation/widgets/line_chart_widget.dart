import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../../../core/models/analytics_data.dart';

class LineChartWidget extends StatelessWidget {
  final List<TimeSeriesData> data;
  final String title;
  final Color lineColor;
  final Color gradientStartColor;
  final Color gradientEndColor;

  const LineChartWidget({
    super.key,
    required this.data,
    required this.title,
    this.lineColor = Colors.blue,
    this.gradientStartColor = Colors.blue,
    this.gradientEndColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('داده‌ای موجود نیست'));
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 1,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          return bottomTitleWidgets(value, meta);
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: leftTitleWidgets,
                        reservedSize: 42,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  minX: 0,
                  maxX: (data.length - 1).toDouble(),
                  minY: 0,
                  maxY: _getMaxY(),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _getSpots(),
                      isCurved: true,
                      color: lineColor,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: data.length <= 15,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: lineColor,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            gradientStartColor.withOpacity(0.3),
                            gradientEndColor.withOpacity(0.1),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) =>
                          Colors.blueGrey.withOpacity(0.8),
                      tooltipRoundedRadius: 8,
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          final flSpot = barSpot;
                          final date = data[flSpot.x.toInt()].date;
                          final shamsiDate = Jalali.fromDateTime(date);
                          final dateStr =
                              '${shamsiDate.year}/${shamsiDate.month}/${shamsiDate.day}';

                          return LineTooltipItem(
                            '$dateStr\n${flSpot.y.toInt()} فعالیت',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _getSpots() {
    return List.generate(
      data.length,
      (index) => FlSpot(index.toDouble(), data[index].value),
    );
  }

  double _getMaxY() {
    if (data.isEmpty) return 10;
    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    return (maxValue * 1.2).ceilToDouble();
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );

    final index = value.toInt();
    if (index < 0 || index >= data.length) {
      return const Text('');
    }

    // نمایش برچسب فقط برای چند نقطه
    final showInterval = data.length > 15 ? data.length ~/ 5 : data.length ~/ 3;
    if (showInterval == 0 || index % showInterval != 0) {
      return const Text('');
    }

    final date = data[index].date;
    final shamsiDate = Jalali.fromDateTime(date);

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        '${shamsiDate.month}/${shamsiDate.day}',
        style: style,
      ),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );

    return Text(
      value.toInt().toString(),
      style: style,
      textAlign: TextAlign.left,
    );
  }
}
