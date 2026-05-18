// moisture_card.dart
// Clean Dark Sky inspired moisture display.

import 'package:flutter/material.dart';
import '../models/field_intelligence.dart';

class MoistureCard extends StatelessWidget {
  final MoistureAnalysis moisture;

  const MoistureCard({super.key, required this.moisture});

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
          Text('FIELD MOISTURE', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 20),

          // Hero moisture state
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                moisture.moistureState,
                style: TextStyle(
                  color: _getMoistureColor(moisture.moistureState),
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '· ${moisture.moistureTrend}',
                style: const TextStyle(
                  color: Color(0xFF546E7A),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: Color(0xFF1E2D3D), height: 1),
          const SizedBox(height: 14),

          // Stats row
          Row(
            children: [
              _MoistureStat(
                label: 'Drought Risk',
                value: moisture.droughtRisk,
                valueColor: _getDroughtColor(moisture.droughtRisk),
              ),
              Container(width: 1, height: 28, color: const Color(0xFF1E2D3D)),
              _MoistureStat(
                label: 'Days Dry',
                value: '${moisture.fieldDryDays}',
                valueColor: moisture.fieldDryDays >= 7
                    ? const Color(0xFFD4A843)
                    : Colors.white,
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: Color(0xFF1E2D3D), height: 1),
          const SizedBox(height: 14),

          // Irrigation signal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Irrigation Signal',
                style: TextStyle(color: Color(0xFF78909C), fontSize: 13),
              ),
              Text(
                moisture.irrigationSignal,
                style: TextStyle(
                  color: _getIrrigationColor(moisture.irrigationSignal),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getMoistureColor(String state) {
    switch (state.toLowerCase()) {
      case 'saturated': return const Color(0xFFE05C5C);
      case 'wet': return const Color(0xFF4A90D9);
      case 'adequate': return const Color(0xFF5BA05E);
      case 'drying': return const Color(0xFFD4A843);
      case 'dry': return const Color(0xFFE07B3C);
      default: return const Color(0xFF78909C);
    }
  }

  Color _getDroughtColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'high': return const Color(0xFFE05C5C);
      case 'moderate': return const Color(0xFFD4A843);
      case 'low': return const Color(0xFF5BA05E);
      default: return const Color(0xFF78909C);
    }
  }

  Color _getIrrigationColor(String signal) {
    switch (signal.toLowerCase()) {
      case 'likely needed': return const Color(0xFFE05C5C);
      case 'consider irrigating': return const Color(0xFFD4A843);
      case 'not recommended': return const Color(0xFF4A90D9);
      default: return const Color(0xFF78909C);
    }
  }
}

class _MoistureStat extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _MoistureStat({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: valueColor,
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
