// moisture_card.dart
// Displays field moisture state, drought risk, and irrigation signal.

import 'package:flutter/material.dart';
import '../models/field_intelligence.dart';

class MoistureCard extends StatelessWidget {
  final MoistureAnalysis moisture;

  const MoistureCard({super.key, required this.moisture});

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
            children: [
              const Icon(Icons.yard_outlined,
                  color: Color(0xFF66BB6A), size: 18),
              const SizedBox(width: 6),
              Text(
                'Field Moisture',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MoistureStat(
                  label: 'State',
                  value: moisture.moistureState,
                  color: _getMoistureColor(moisture.moistureState),
                ),
              ),
              Expanded(
                child: _MoistureStat(
                  label: 'Trend',
                  value: moisture.moistureTrend,
                  color: _getTrendColor(moisture.moistureTrend),
                ),
              ),
              Expanded(
                child: _MoistureStat(
                  label: 'Drought',
                  value: moisture.droughtRisk,
                  color: _getDroughtColor(moisture.droughtRisk),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFF2C2C2E), height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.water_outlined,
                      size: 14, color: Color(0xFF8E8E93)),
                  const SizedBox(width: 4),
                  const Text(
                    'Irrigation Signal',
                    style: TextStyle(
                        fontSize: 12, color: Color(0xFF8E8E93)),
                  ),
                ],
              ),
              _IrrigationBadge(signal: moisture.irrigationSignal),
            ],
          ),
          if (moisture.fieldDryDays > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 13, color: Color(0xFF8E8E93)),
                const SizedBox(width: 4),
                Text(
                  '${moisture.fieldDryDays} days without meaningful rain',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF8E8E93)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getMoistureColor(String state) {
    switch (state.toLowerCase()) {
      case 'saturated':
        return const Color(0xFFEF5350);
      case 'wet':
        return const Color(0xFF42A5F5);
      case 'adequate':
        return const Color(0xFF66BB6A);
      case 'drying':
        return const Color(0xFFFFA726);
      case 'dry':
        return const Color(0xFFFF7043);
      default:
        return const Color(0xFF8E8E93);
    }
  }

  Color _getTrendColor(String trend) {
    switch (trend.toLowerCase()) {
      case 'increasing':
        return const Color(0xFF42A5F5);
      case 'decreasing':
        return const Color(0xFFFFA726);
      default:
        return const Color(0xFF66BB6A);
    }
  }

  Color _getDroughtColor(String risk) {
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
}

class _MoistureStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MoistureStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF8E8E93),
          ),
        ),
      ],
    );
  }
}

class _IrrigationBadge extends StatelessWidget {
  final String signal;

  const _IrrigationBadge({required this.signal});

  Color _getColor() {
    switch (signal.toLowerCase()) {
      case 'likely needed':
        return const Color(0xFFEF5350);
      case 'consider irrigating':
        return const Color(0xFFFFA726);
      case 'not recommended':
        return const Color(0xFF42A5F5);
      default:
        return const Color(0xFF8E8E93);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return Text(
      signal,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}
