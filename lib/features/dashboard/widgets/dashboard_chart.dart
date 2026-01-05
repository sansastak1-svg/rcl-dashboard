import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:rcl_dashboard/core/constants/app_colors.dart';
import 'package:rcl_dashboard/features/dashboard/models/dashboard_models.dart';

class DailyRentalsChart extends StatelessWidget {
  final List<DailyRental> data;

  const DailyRentalsChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 25,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < data.length) {
                    return Text(
                      data[value.toInt()].date,
                      style: Theme.of(context).textTheme.labelSmall,
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}',
                    style: Theme.of(context).textTheme.labelSmall,
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: true, drawHorizontalLine: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(
            data.length,
            (index) => BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: data[index].count.toDouble(),
                  color: AppColors.primaryBlue,
                  width: 16,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RevenueChart extends StatelessWidget {
  final List<RevenueData> data;

  const RevenueChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxYValue = data.isEmpty ? 100000 : data.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
    final maxY = (maxYValue as num).toDouble();

    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, drawHorizontalLine: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < data.length) {
                    return Text(
                      data[value.toInt()].month,
                      style: Theme.of(context).textTheme.labelSmall,
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '\$${(value / 1000).toStringAsFixed(0)}k',
                    style: Theme.of(context).textTheme.labelSmall,
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          maxY: maxY,
          minY: 0,
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                data.length,
                (index) => FlSpot(index.toDouble(), data[index].amount),
              ),
              isCurved: true,
              color: AppColors.primaryGreen,
              barWidth: 3,
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primaryGreen.withOpacity(0.2),
              ),
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }
}
