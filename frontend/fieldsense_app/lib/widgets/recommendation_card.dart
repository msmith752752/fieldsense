// recommendation_card.dart
// Clean, Dark Sky inspired recommendation display.

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
        // Primary recommendation - clean card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2535),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FIELD SUMMARY',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 10),
              Text(
                recommendation.primaryRecommendation,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.6,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Status row
        Row(
          children: [
            Expanded(
              child: _StatusCard(
                label: 'PLANTING',
                value: recommendation.plantingReadiness,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatusCard(
                label: 'HARVEST WINDOW',
                value: recommendation.harvestWindowRisk,
              ),
            ),
          ],
        ),

        // Alerts
        if (recommendation.alerts.isNotEmpty) ...[
          const SizedBox(height: 10),
          ...recommendation.alerts.map((alert) => _AlertRow(alert: alert)),
        ],
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatusCard({required this.label, required this.value});

  Color _getColor(String value) {
    final v = value.toLowerCase();
    if (v.contains('favorable') || v.contains('low risk')) {
      return const Color(0xFF5BA05E);
    } else if (v.contains('moderate') || v.contains('monitor')) {
      return const Color(0xFFD4A843);
    } else if (v.contains('not ready') || v.contains('high') || v.contains('marginal')) {
      return const Color(0xFFE05C5C);
    }
    return const Color(0xFF4A90D9);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2535),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _getColor(value),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  final OperationalAlert alert;

  const _AlertRow({required this.alert});

  Color _getColor(String level) {
    switch (level.toLowerCase()) {
      case 'warning':
        return const Color(0xFFE05C5C);
      case 'watch':
        return const Color(0xFFD4A843);
      case 'opportunity':
        return const Color(0xFF5BA05E);
      default:
        return const Color(0xFF4A90D9);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(alert.level);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2535),
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              alert.message,
              style: TextStyle(
                fontSize: 13,
                color: const Color(0xFFCFD8DC),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
