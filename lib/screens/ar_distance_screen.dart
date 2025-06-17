// File: lib/screens/ar_distance_screen.dart

import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin_updated/ar_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import '../services/ar_measure_service.dart';
import '../widgets/control_panel.dart';
import '../widgets/reticle_overlay.dart';

class ARDistanceScreen extends StatefulWidget {
  @override
  _ARDistanceScreenState createState() => _ARDistanceScreenState();
}

class _ARDistanceScreenState extends State<ARDistanceScreen> {
  late ARMeasureService _measureService;

  @override
  void initState() {
    super.initState();
    _measureService = ARMeasureService(onUpdate: () => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ARView(
            onARViewCreated: _measureService.onARViewCreated,
          ),
          const ReticleOverlay(),
          if (_measureService.distance != null)
            Positioned(
              top: 50,
              left: 20,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Text(
                  "Distance: ${_measureService.getFormattedDistance()}",
                  style: TextStyle(color: Colors.deepPurple, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ControlPanel(service: _measureService),
          ),
        ],
      ),
    );
  }
}
