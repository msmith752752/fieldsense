// recommendation_card.dart
// Redesigned with daily verdict as the hero element.

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
        // Daily Verdict — hero card, most prominent element
        _DailyVerdictCard(
          verdict: recommendation.dailyVerdict,
          growthStage: recommendation.growthStage,
        ),

        const SizedBox(height: 10),

        // Full field summary
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
              Text('FIELD SUMMARY', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 10),
              Text(
                recommendation.primaryRecommendation,
                style: const TextStyle(
                  color: Color(0xFFCFD8DC),
                  fontSize: 14,
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
            Expanded(child: _StatusCard(label: 'PLANTING', value: recommendation.plantingReadiness)),
            const SizedBox(width: 8),
            Expanded(child: _StatusCard(label: 'HARVEST WINDOW', value: recommendation.harvestWindowRisk)),
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

class _DailyVerdictCard extends StatelessWidget {
  final String verdict;
  final String? growthStage;

  const _DailyVerdictCard({required this.verdict, this.growthStage});

  Color _getVerdictColor(String verdict) {
    final v = verdict.toLowerCase();
    if (v.contains('stay out') || v.contains('saturated') || v.contains('irrigate now') || v.contains('hold off')) {
      return const Color(0xFFE05C5C);
    } else if (v.contains('monitor') || v.contains('irrigation recommended') || v.contains('high water')) {
      return const Color(0xFFD4A843);
    } else if (v.contains('favorable') || v.contains('good day') || v.contains('good operational')) {
      return const Color(0xFF5BA05E);
    } else if (v.contains('window opening') || v.contains('plan field')) {
      return const Color(0xFF4A90D9);
    }
    return const Color(0xFF78909C);
  }

  IconData _getVerdictIcon(String verdict) {
    final v = verdict.toLowerCase();
    if (v.contains('stay out') || v.contains('saturated') || v.contains('hold off')) {
      return Icons.warning_amber_rounded;
    } else if (v.contains('irrigate') || v.contains('irrigation')) {
      return Icons.water_drop_outlined;
    } else if (v.contains('favorable') || v.contains('good day')) {
      return Icons.check_circle_outline;
    } else if (v.contains('window') || v.contains('plan field')) {
      return Icons.calendar_today_outlined;
    }
    return Icons.info_outline;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getVerdictColor(verdict);
    final icon = _getVerdictIcon(verdict);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2535),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text('TODAY', style: Theme.of(context).textTheme.titleSmall),
              if (growthStage != null) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1923),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    growthStage!,
                    style: const TextStyle(
                      color: Color(0xFF546E7A),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            verdict,
            style: TextStyle(
              color: color,
              fontSize: 16,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatusCard({required this.label, required this.value});

  Color _getColor(String value) {
    final v = value.toLowerCase();
    if (v.contains('favorable') || v.contains('low risk')) return const Color(0xFF5BA05E);
    if (v.contains('moderate') || v.contains('monitor')) return const Color(0xFFD4A843);
    if (v.contains('not ready') || v.contains('high') || v.contains('marginal')) return const Color(0xFFE05C5C);
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
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _getColor(value)),
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
      case 'warning': return const Color(0xFFE05C5C);
      case 'watch': return const Color(0xFFD4A843);
      case 'opportunity': return const Color(0xFF5BA05E);
      default: return const Color(0xFF4A90D9);
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
      child: Text(
        alert.message,
        style: const TextStyle(fontSize: 13, color: Color(0xFFCFD8DC), height: 1.4),
      ),
    );
  }
}
