// File: lib/widgets/control_panel.dart

import 'package:flutter/material.dart';
import '../services/ar_measure_service.dart';

class ControlPanel extends StatelessWidget {
  final ARMeasureService service;

  const ControlPanel({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withOpacity(0.95),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton.icon(
                onPressed: service.setPointFromCamera,
                icon: const Icon(Icons.center_focus_strong),
                label: const Text("Camera Point"),
              ),
              ElevatedButton.icon(
                onPressed: service.reset,
                icon: const Icon(Icons.refresh),
                label: const Text("Reset"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _unitButton("m", UnitSystem.meters),
              _unitButton("cm", UnitSystem.centimeters),
              _unitButton("in", UnitSystem.inches),
            ],
          ),
        ],
      ),
    );
  }

  Widget _unitButton(String label, UnitSystem unit) {
    final isSelected = service.currentUnit == unit;
    return ElevatedButton(
      onPressed: () => service.switchUnitSystem(unit),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.deepPurpleAccent : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.black,
      ),
      child: Text(label),
    );
  }
}
