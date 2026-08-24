// rainfall_card.dart
// Clean Dark Sky inspired rainfall history display.

import 'package:flutter/material.dart';
import '../models/field_intelligence.dart';

class RainfallCard extends StatelessWidget {
  final RainfallAnalysis rainfall;

  const RainfallCard({super.key, required this.rainfall});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2535),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('RAINFALL', style: Theme.of(context).textTheme.titleSmall),
              _TrendLabel(trend: rainfall.trend),
            ],
          ),
          const SizedBox(height: 20),

          // Big 7-day number - Dark Sky style hero stat
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                rainfall.last7Day.toStringAsFixed(2),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w200,
                  letterSpacing: -2,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 10, left: 4),
                child: Text(
                  'in',
                  style: TextStyle(
                    color: Color(0xFF78909C),
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'past 7 days',
                  style: TextStyle(
                    color: Color(0xFF546E7A),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: Color(0xFF1E2D3D), height: 1),
          const SizedBox(height: 16),

          // Secondary stats row
          Row(
            children: [
              _SmallStat(label: '24h', value: '${rainfall.last1Day.toStringAsFixed(2)}"'),
              _Divider(),
              _SmallStat(label: '3 day', value: '${rainfall.last3Day.toStringAsFixed(2)}"'),
              _Divider(),
              _SmallStat(label: '14 day', value: '${rainfall.last14Day.toStringAsFixed(2)}"'),
              _Divider(),
              _SmallStat(
                label: 'Since rain',
                value: '${rainfall.daysSinceRain}d',
                valueColor: rainfall.daysSinceRain >= 7
                    ? const Color(0xFFD4A843)
                    : const Color(0xFF4A90D9),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: Color(0xFF1E2D3D), height: 1),
          const SizedBox(height: 14),

          // Saturation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Saturation Risk',
                style: TextStyle(color: Color(0xFF78909C), fontSize: 13),
              ),
              _SaturationLabel(risk: rainfall.saturationRisk),
            ],
          ),

          // Mini bar chart
          if (rainfall.dailyHistory.isNotEmpty) ...[
            const SizedBox(height: 16),
            _MiniBarChart(history: rainfall.dailyHistory),
          ],
        ],
      ),
    );
  }
}

class _SmallStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SmallStat({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(color: Color(0xFF546E7A), fontSize: 11)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 28, color: const Color(0xFF1E2D3D));
  }
}

class _TrendLabel extends StatelessWidget {
  final String trend;

  const _TrendLabel({required this.trend});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    switch (trend.toLowerCase()) {
      case 'increasing':
        color = const Color(0xFF4A90D9);
        icon = Icons.trending_up_rounded;
        break;
      case 'decreasing':
        color = const Color(0xFF5BA05E);
        icon = Icons.trending_down_rounded;
        break;
      default:
        color = const Color(0xFF78909C);
        icon = Icons.trending_flat_rounded;
    }
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(trend, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _SaturationLabel extends StatelessWidget {
  final String risk;

  const _SaturationLabel({required this.risk});

  Color _color() {
    switch (risk.toLowerCase()) {
      case 'high': return const Color(0xFFE05C5C);
      case 'moderate': return const Color(0xFFD4A843);
      case 'low': return const Color(0xFF5BA05E);
      default: return const Color(0xFF78909C);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      risk,
      style: TextStyle(color: _color(), fontSize: 13, fontWeight: FontWeight.w600),
    );
  }
}

class _MiniBarChart extends StatelessWidget {
  final List<DailyRainfall> history;

  const _MiniBarChart({required this.history});

  @override
  Widget build(BuildContext context) {
    final recent = history.length > 10 ? history.sublist(history.length - 10) : history;
    final maxVal = recent.map((e) => e.inches).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 36,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: recent.map((day) {
          final ratio = maxVal > 0 ? day.inches / maxVal : 0.0;
          final barHeight = 4 + (ratio * 32);
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: day.inches > 0
                          ? const Color(0xFF4A90D9).withOpacity(0.6 + ratio * 0.4)
                          : const Color(0xFF1E2D3D),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
