import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:harmoni/models/emotion.dart';
import 'package:harmoni/services/emotion_store.dart';
import 'package:harmoni/theme.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class MoodChart extends StatefulWidget {
  const MoodChart({super.key});

  @override
  State<MoodChart> createState() => _MoodChartState();
}

class _MoodChartState extends State<MoodChart> {
  final DateFormat _dateFormat = DateFormat('MMM d');
  int? _touchedIndex;
  final List<String> _displayedDates = [];

  @override
  Widget build(BuildContext context) {
    return Consumer<EmotionStore>(
      builder: (context, emotionStore, child) {
        if (emotionStore.emotions.isEmpty) {
          return const Center(child: Text('No emotion data available'));
        }

        // Sort emotions by date
        final List<Emotion> sortedEmotions = [...emotionStore.emotions]
          ..sort((Emotion a, Emotion b) => a.date.compareTo(b.date));

        // Generate spots for chart
        final spots = sortedEmotions.asMap().entries.map((entry) {
          return FlSpot(
            entry.key.toDouble(),
            _getEmotionValue(entry.value.name),
          );
        }).toList();

        // Calculate which dates to display (avoid clutter)
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.offWhite),
          ),
          child: Column(
            children: [
              Text(
                'Mood History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: (spots.length - 1).toDouble(),
                    minY: 0,
                    maxY: 5,
                    lineTouchData: _buildLineTouchData(sortedEmotions),
                    titlesData: _buildTitlesData(sortedEmotions),
                    gridData: _buildGridData(),
                    borderData: _buildBorderData(),
                    lineBarsData: [_buildLineBarData(spots)],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  LineTouchData _buildLineTouchData(List<Emotion> emotions) {
    return LineTouchData(
      touchCallback: (event, response) {
        if (response?.lineBarSpots != null && event is FlTapUpEvent) {
          setState(() => _touchedIndex = response?.lineBarSpots?.first.spotIndex);
        }
      },
      getTouchedSpotIndicator: (barData, indices) => indices.map((index) {
        return TouchedSpotIndicatorData(
          FlLine(color: Colors.grey, strokeWidth: 1),
          FlDotData(
            getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
              radius: 6,
              color: Theme.of(context).primaryColor,
              strokeWidth: 2,
              strokeColor: Colors.white,
            ),
          ),
        );
      }).toList(),
      touchTooltipData: LineTouchTooltipData(
        getTooltipItems: (spots) => spots.map((spot) {
          final emotion = emotions[spot.x.toInt()];
          return LineTooltipItem(
            '${emotion.name}\n${_dateFormat.format(emotion.date)}',
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          );
        }).toList(),
      ),
    );
  }

  FlTitlesData _buildTitlesData(List<Emotion> emotions) {
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 24,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= emotions.length) return const SizedBox();

            final dateStr = _dateFormat.format(emotions[index].date);

            // Only show if in displayed dates list
            if (!_displayedDates.contains(dateStr)) return const SizedBox();

            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                dateStr,
                style: const TextStyle(fontSize: 10),
              ),
            );
          },
        ),
      ),
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  FlGridData _buildGridData() {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: 1,
      getDrawingHorizontalLine: (value) => FlLine(
        color: AppColors.offWhite.withOpacity(0.3),
        strokeWidth: 1,
      ),
    );
  }

  FlBorderData _buildBorderData() {
    return FlBorderData(
      show: true,
      border: Border.all(
        color: AppColors.offWhite.withOpacity(0.5),
        width: 1,
      ),
    );
  }

  LineChartBarData _buildLineBarData(List<FlSpot> spots) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.3,
      color: Theme.of(context).primaryColor,
      barWidth: 3,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
          radius: index == _touchedIndex ? 5 : 4,
          color: index == _touchedIndex
              ? Theme.of(context).primaryColor
              : Theme.of(context).primaryColor.withOpacity(0.8),
          strokeWidth: index == _touchedIndex ? 2 : 1,
          strokeColor: Colors.white,
        ),
      ),
    );
  }

  double _getEmotionValue(String emotionName) {
    switch (emotionName.toLowerCase()) {
      case 'joy': return 3.0;
      case 'love': return 4.0;
      case 'surprise': return 5.0;
      case 'sadness': return 2.0;
      case 'anger': return 1.0;
      case 'fear': return 0.0;
      default: return 2.5;
    }
  }
}