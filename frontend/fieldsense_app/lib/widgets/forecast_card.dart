// forecast_card.dart
// Farmer-friendly forecast display.

import 'package:flutter/material.dart';
import '../models/field_intelligence.dart';

class ForecastCard extends StatelessWidget {
  final ForecastAnalysis forecast;

  const ForecastCard({super.key, required this.forecast});

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
              Text('UPCOMING RAIN', style: Theme.of(context).textTheme.titleSmall),
              _RiskLabel(risk: forecast.rainRiskLevel),
            ],
          ),
          const SizedBox(height: 20),

          // Hero stat
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                forecast.forecast7Day.toStringAsFixed(2),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w200,
                  letterSpacing: -2,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 10, left: 4),
                child: Text('inches', style: TextStyle(color: Color(0xFF78909C), fontSize: 14, fontWeight: FontWeight.w300)),
              ),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text('next 7 days', style: TextStyle(color: Color(0xFF546E7A), fontSize: 13)),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: Color(0xFF1E2D3D), height: 1),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${forecast.forecast3Day.toStringAsFixed(2)}"',
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 3),
                    const Text('Next 3 days', style: TextStyle(color: Color(0xFF546E7A), fontSize: 11)),
                  ],
                ),
              ),
              Container(width: 1, height: 28, color: const Color(0xFF1E2D3D)),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${forecast.heavyRainDays.length}',
                      style: TextStyle(
                        color: forecast.heavyRainDays.isNotEmpty ? const Color(0xFFD4A843) : const Color(0xFF5BA05E),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text('Heavy rain days', style: TextStyle(color: Color(0xFF546E7A), fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),

          // Dry window - most useful for farmers
          if (forecast.dryWindow.available) ...[
            const SizedBox(height: 16),
            const Divider(color: Color(0xFF1E2D3D), height: 1),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.wb_sunny_outlined, size: 14, color: Color(0xFF5BA05E)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Good working window: ${forecast.dryWindow.startDate} – ${forecast.dryWindow.endDate} (${forecast.dryWindow.durationDays} days)',
                    style: const TextStyle(color: Color(0xFF5BA05E), fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],

          // Daily strip
          if (forecast.dailyForecast.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: Color(0xFF1E2D3D), height: 1),
            const SizedBox(height: 16),
            _DailyStrip(days: forecast.dailyForecast.take(7).toList()),
          ],
        ],
      ),
    );
  }
}

class _RiskLabel extends StatelessWidget {
  final String risk;
  const _RiskLabel({required this.risk});

  Color _color() {
    switch (risk.toLowerCase()) {
      case 'high': return const Color(0xFFE05C5C);
      case 'moderate': return const Color(0xFFD4A843);
      case 'low': return const Color(0xFF5BA05E);
      default: return const Color(0xFF78909C);
    }
  }

  String _label() {
    switch (risk.toLowerCase()) {
      case 'high': return 'Heavy rain coming';
      case 'moderate': return 'Some rain expected';
      case 'low': return 'Light rain possible';
      default: return 'Dry ahead';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(_label(), style: TextStyle(color: _color(), fontSize: 12, fontWeight: FontWeight.w600));
  }
}

class _DailyStrip extends StatelessWidget {
  final List<DailyForecast> days;
  const _DailyStrip({required this.days});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((day) {
        final dateShort = day.date.length >= 10 ? day.date.substring(5) : day.date;
        final hasRain = day.precipProbability > 30;
        return Expanded(
          child: Column(
            children: [
              Text(
                '${day.precipProbability}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: hasRain ? const Color(0xFF4A90D9) : const Color(0xFF546E7A),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hasRain ? const Color(0xFF4A90D9) : const Color(0xFF1E2D3D),
                ),
              ),
              const SizedBox(height: 4),
              Text(dateShort, style: const TextStyle(fontSize: 10, color: Color(0xFF546E7A))),
            ],
          ),
        );
      }).toList(),
    );
  }
}