// rainfall_card.dart
// Displays rainfall history and accumulation data.

import 'package:flutter/material.dart';
import '../models/field_intelligence.dart';

class RainfallCard extends StatelessWidget {
  final RainfallAnalysis rainfall;

  const RainfallCard({super.key, required this.rainfall});

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
                  const Icon(Icons.water_drop_outlined,
                      color: Color(0xFF42A5F5), size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Rainfall History',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              _TrendBadge(trend: rainfall.trend),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _RainfallStat(
                  label: '24h', value: rainfall.last1Day, color: const Color(0xFF42A5F5)),
              _RainfallStat(
                  label: '3d', value: rainfall.last3Day, color: const Color(0xFF42A5F5)),
              _RainfallStat(
                  label: '7d', value: rainfall.last7Day, color: const Color(0xFF1E88E5)),
              _RainfallStat(
                  label: '14d', value: rainfall.last14Day, color: const Color(0xFF1565C0)),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFF2C2C2E), height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoChip(
                icon: Icons.calendar_today_outlined,
                label:
                    '${rainfall.daysSinceRain}d since rain',
              ),
              _SaturationBadge(risk: rainfall.saturationRisk),
            ],
          ),
        ],
      ),
    );
  }
}

class _RainfallStat extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _RainfallStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '${value.toStringAsFixed(2)}"',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
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
      ),
    );
  }
}

class _TrendBadge extends StatelessWidget {
  final String trend;

  const _TrendBadge({required this.trend});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (trend.toLowerCase()) {
      case 'increasing':
        color = const Color(0xFF42A5F5);
        icon = Icons.trending_up;
        break;
      case 'decreasing':
        color = const Color(0xFF66BB6A);
        icon = Icons.trending_down;
        break;
      default:
        color = const Color(0xFF8E8E93);
        icon = Icons.trending_flat;
    }

    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 3),
        Text(
          trend,
          style: TextStyle(fontSize: 12, color: color),
        ),
      ],
    );
  }
}

class _SaturationBadge extends StatelessWidget {
  final String risk;

  const _SaturationBadge({required this.risk});

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
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        '$risk Saturation',
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: const Color(0xFF8E8E93)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
        ),
      ],
    );
  }
}
