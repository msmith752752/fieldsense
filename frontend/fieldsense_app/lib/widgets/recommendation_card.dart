// recommendation_card.dart
// Shows the primary operational recommendation and alerts.

import 'package:flutter/material.dart';
import '../models/field_intelligence.dart';

class RecommendationCard extends StatelessWidget {
  final RecommendationSummary recommendation;

  const RecommendationCard({super.key, required this.recommendation});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Primary recommendation
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2E1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2E7D32), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.agriculture,
                      color: Color(0xFF66BB6A), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Field Intelligence',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: const Color(0xFF66BB6A),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                recommendation.primaryRecommendation,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      height: 1.5,
                    ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Readiness row
        Row(
          children: [
            Expanded(
              child: _StatusTile(
                label: 'Planting',
                value: recommendation.plantingReadiness,
                icon: Icons.grass,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatusTile(
                label: 'Harvest Window',
                value: recommendation.harvestWindowRisk,
                icon: Icons.wb_sunny_outlined,
              ),
            ),
          ],
        ),

        // Alerts
        if (recommendation.alerts.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...recommendation.alerts.map((alert) => _AlertTile(alert: alert)),
        ],
      ],
    );
  }
}

class _StatusTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatusTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  Color _getColor(String value) {
    final v = value.toLowerCase();
    if (v.contains('favorable') || v.contains('low risk')) {
      return const Color(0xFF66BB6A);
    } else if (v.contains('moderate') || v.contains('monitor')) {
      return const Color(0xFFFFA726);
    } else if (v.contains('not ready') ||
        v.contains('high') ||
        v.contains('marginal')) {
      return const Color(0xFFEF5350);
    }
    return const Color(0xFF90A4AE);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: const Color(0xFF8E8E93)),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF8E8E93),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _getColor(value),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final OperationalAlert alert;

  const _AlertTile({required this.alert});

  Color _getColor(String level) {
    switch (level.toLowerCase()) {
      case 'warning':
        return const Color(0xFFEF5350);
      case 'watch':
        return const Color(0xFFFFA726);
      case 'opportunity':
        return const Color(0xFF66BB6A);
      default:
        return const Color(0xFF42A5F5);
    }
  }

  IconData _getIcon(String level) {
    switch (level.toLowerCase()) {
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'watch':
        return Icons.visibility_outlined;
      case 'opportunity':
        return Icons.check_circle_outline;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(alert.level);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_getIcon(alert.level), size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              alert.message,
              style: TextStyle(
                fontSize: 13,
                color: color,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
