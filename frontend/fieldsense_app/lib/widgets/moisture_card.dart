// moisture_card.dart
// Farmer-friendly moisture display.

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
          Text('SOIL CONDITIONS', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 20),

          // Hero moisture state - plain English
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _friendlyState(moisture.moistureState),
                style: TextStyle(
                  color: _getMoistureColor(moisture.moistureState),
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '· ${_friendlyTrend(moisture.moistureTrend)}',
                style: const TextStyle(color: Color(0xFF546E7A), fontSize: 15, fontWeight: FontWeight.w400),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: Color(0xFF1E2D3D), height: 1),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      _friendlyDrought(moisture.droughtRisk),
                      style: TextStyle(
                        color: _getDroughtColor(moisture.droughtRisk),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text('Drought risk', style: TextStyle(color: Color(0xFF546E7A), fontSize: 11)),
                  ],
                ),
              ),
              Container(width: 1, height: 28, color: const Color(0xFF1E2D3D)),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${moisture.fieldDryDays} days',
                      style: TextStyle(
                        color: moisture.fieldDryDays >= 7 ? const Color(0xFFD4A843) : Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text('Without rain', style: TextStyle(color: Color(0xFF546E7A), fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: Color(0xFF1E2D3D), height: 1),
          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Should I irrigate?', style: TextStyle(color: Color(0xFF78909C), fontSize: 13)),
              Text(
                _friendlyIrrigation(moisture.irrigationSignal),
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

  String _friendlyState(String state) {
    switch (state.toLowerCase()) {
      case 'saturated': return 'Too Wet';
      case 'wet': return 'Wet';
      case 'adequate': return 'Good';
      case 'drying': return 'Drying Out';
      case 'dry': return 'Too Dry';
      default: return state;
    }
  }

  String _friendlyTrend(String trend) {
    switch (trend.toLowerCase()) {
      case 'increasing': return 'getting wetter';
      case 'decreasing': return 'drying out';
      default: return 'holding steady';
    }
  }

  String _friendlyDrought(String risk) {
    switch (risk.toLowerCase()) {
      case 'high': return 'High';
      case 'moderate': return 'Moderate';
      case 'low': return 'Low';
      default: return 'None';
    }
  }

  String _friendlyIrrigation(String signal) {
    switch (signal.toLowerCase()) {
      case 'likely needed': return 'Yes — irrigate now';
      case 'consider irrigating': return 'Maybe — monitor closely';
      case 'not recommended': return 'No — soil is wet';
      default: return 'Keep an eye on it';
    }
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