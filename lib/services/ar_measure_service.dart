// File: lib/services/ar_measure_service.dart

import 'package:ar_flutter_plugin_updated/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin_updated/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_updated/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_updated/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_updated/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_updated/models/ar_anchor.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:flutter/material.dart';

enum UnitSystem { meters, centimeters, inches }

class ARMeasureService {
  final VoidCallback onUpdate;
  ARSessionManager? sessionManager;
  ARObjectManager? objectManager;
  ARAnchorManager? anchorManager;

  Vector3? _firstPoint;
  Vector3? _secondPoint;
  double? distance;
  UnitSystem _unitSystem = UnitSystem.meters;

  ARMeasureService({required this.onUpdate});

  void onARViewCreated(ARSessionManager sessionManager, ARObjectManager objectManager, ARAnchorManager anchorManager, ARLocationManager locationManager) {
    this.sessionManager = sessionManager;
    this.objectManager = objectManager;
    this.anchorManager = anchorManager;

    sessionManager.onInitialize(showFeaturePoints: true, showPlanes: true, showWorldOrigin: true);
    objectManager.onInitialize();

    sessionManager.onPlaneOrPointTap = (hits) {
      if (hits.isNotEmpty) {
        final hitTransform = hits.first.worldTransform;
        final point = hitTransform.getTranslation();
        _markPoint(point);
      }
    };
  }

  void _markPoint(Vector3 point) async {
    final anchor = ARPlaneAnchor(transformation: Matrix4.translation(point));
    await anchorManager?.addAnchor(anchor);
    if (_firstPoint == null) {
      _firstPoint = point;
    } else if (_secondPoint == null) {
      _secondPoint = point;
      distance = (_firstPoint! - _secondPoint!).length;
    } else {
      _firstPoint = point;
      _secondPoint = null;
      distance = null;
    }
    onUpdate();
  }

  String getFormattedDistance() {
    if (distance == null) return "--";
    switch (_unitSystem) {
      case UnitSystem.centimeters:
        return "${(distance! * 100).toStringAsFixed(1)} cm";
      case UnitSystem.inches:
        return "${(distance! * 39.3701).toStringAsFixed(1)} in";
      case UnitSystem.meters:
      default:
        return "${distance!.toStringAsFixed(2)} m";
    }
  }

  void reset() {
    _firstPoint = null;
    _secondPoint = null;
    distance = null;
    onUpdate();
  }

  void setPointFromCamera() async {
    final pose = await sessionManager?.getCameraPose();
    if (pose != null) {
      final point = Vector3(pose.storage[12], pose.storage[13], pose.storage[14]);
      _markPoint(point);
    }
  }

  void switchUnitSystem(UnitSystem unit) {
    _unitSystem = unit;
    onUpdate();
  }

  UnitSystem get currentUnit => _unitSystem;
}
