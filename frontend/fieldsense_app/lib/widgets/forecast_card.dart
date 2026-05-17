// forecast_card.dart
// Displays upcoming forecast, rain risk, and dry windows.

import 'package:flutter/material.dart';
import '../models/field_intelligence.dart';

class ForecastCard extends StatelessWidget {
  final ForecastAnalysis forecast;

  const ForecastCard({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.cloud_outlined,
                      color: Color(0xFF9575CD), size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Forecast',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              _RainRiskBadge(risk: forecast.rainRiskLevel),
            ],
          ),
          const SizedBox(height: 16),

          // Forecast totals
          Row(
            children: [
              Expanded(
                child: _ForecastStat(
                  label: '3-Day',
                  value: '${forecast.forecast3Day.toStringAsFixed(2)}"',
                  sublabel: 'expected',
                ),
              ),
              Expanded(
                child: _ForecastStat(
                  label: '7-Day',
                  value: '${forecast.forecast7Day.toStringAsFixed(2)}"',
                  sublabel: 'expected',
                ),
              ),
              Expanded(
                child: _ForecastStat(
                  label: 'Heavy Rain',
                  value: '${forecast.heavyRainDays.length}',
                  sublabel: 'days at risk',
                  valueColor: forecast.heavyRainDays.isNotEmpty
                      ? const Color(0xFFFFA726)
                      : const Color(0xFF66BB6A),
                ),
              ),
            ],
          ),

          // Dry window
          if (forecast.dryWindow.available) ...[
            const SizedBox(height: 12),
            const Divider(color: Color(0xFF2C2C2E), height: 1),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF66BB6A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: const Color(0xFF66BB6A).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.wb_sunny_outlined,
                      color: Color(0xFF66BB6A), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Dry window: ${forecast.dryWindow.startDate} – ${forecast.dryWindow.endDate} (${forecast.dryWindow.durationDays}d)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF66BB6A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Daily forecast mini bars
          if (forecast.dailyForecast.isNotEmpty) ...[
            const SizedBox(height: 16),
            _DailyForecastRow(days: forecast.dailyForecast.take(7).toList()),
          ],
        ],
      ),
    );
  }
}

class _ForecastStat extends StatelessWidget {
  final String label;
  final String value;
  final String sublabel;
  final Color? valueColor;

  const _ForecastStat({
    required this.label,
    required this.value,
    required this.sublabel,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: valueColor ?? const Color(0xFF9575CD),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Text(
          sublabel,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF8E8E93),
          ),
        ),
      ],
    );
  }
}

class _RainRiskBadge extends StatelessWidget {
  final String risk;

  const _RainRiskBadge({required this.risk});

  Color _getColor() {
    switch (risk.toLowerCase()) {
      case 'high':
        return const Color(0xFFEF5350);
      case 'moderate':
        return const Color(0xFFFFA726);
      case 'low':
        return const Color(0xFF66BB6A);
      default:
        return const Color(0xFF8E8E93);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$risk Rain Risk',
        style: TextStyle(
            fontSize: 11, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _DailyForecastRow extends StatelessWidget {
  final List<DailyForecast> days;

  const _DailyForecastRow({required this.days});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((day) {
        final dateShort = day.date.substring(5); // MM-DD
        final hasRain = day.precipInches > 0.1;
        return Expanded(
          child: Column(
            children: [
              Icon(
                hasRain ? Icons.grain : Icons.wb_sunny_outlined,
                size: 14,
                color: hasRain
                    ? const Color(0xFF42A5F5)
                    : const Color(0xFF8E8E93),
              ),
              const SizedBox(height: 2),
              Text(
                '${day.precipProbability}%',
                style: TextStyle(
                  fontSize: 10,
                  color: hasRain
                      ? const Color(0xFF42A5F5)
                      : const Color(0xFF8E8E93),
                ),
              ),
              Text(
                dateShort,
                style: const TextStyle(
                  fontSize: 9,
                  color: Color(0xFF636366),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
