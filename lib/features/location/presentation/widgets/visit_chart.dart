import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

/// Bar chart widget displaying 7-day visit data.
///
/// Uses [fl_chart] [BarChart] with [AppColors.primary900] bars
/// and Bahasa Indonesia axis labels. Expects exactly 7 [visits] entries
/// with corresponding [dayLabels].
class VisitChart extends StatelessWidget {
  /// Daily visit counts (7 entries, index 0 = oldest day).
  final List<double> visits;

  /// Short day labels (e.g. 'Sen', 'Sel', 'Rab', ...).
  final List<String> dayLabels;

  /// Creates a [VisitChart].
  const VisitChart({super.key, required this.visits, required this.dayLabels});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _computeMaxY(),
          minY: 0,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${dayLabels[groupIndex]}\n${rod.toY.toInt()} tamu',
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: _computeMaxY() > 0
                    ? (_computeMaxY() / 4).ceilToDouble().clamp(
                        1,
                        double.infinity,
                      )
                    : 1,
                getTitlesWidget: (value, meta) {
                  if (value == meta.max || value % 1 != 0) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= dayLabels.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Text(
                      dayLabels[idx],
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _computeMaxY() > 0
                ? (_computeMaxY() / 4).ceilToDouble().clamp(1, double.infinity)
                : 1,
            getDrawingHorizontalLine: (value) =>
                const FlLine(color: AppColors.border, strokeWidth: 0.5),
          ),
          barGroups: List.generate(visits.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: visits[i],
                  color: AppColors.primary900,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            );
          }),
        ),
        duration: const Duration(milliseconds: 300),
      ),
    );
  }

  double _computeMaxY() {
    if (visits.isEmpty) return 10;
    final maxVal = visits.reduce((a, b) => a > b ? a : b);
    // Round up to nearest multiple of 5, min 5.
    if (maxVal <= 0) return 5;
    return ((maxVal / 5).ceil() * 5).toDouble();
  }
}
