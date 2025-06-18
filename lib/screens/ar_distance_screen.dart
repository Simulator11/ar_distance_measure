import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin_updated/ar_flutter_plugin.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../services/ar_measure_service.dart';
import '../widgets/control_panel.dart';
import '../widgets/reticle_overlay.dart';
import 'gallery_screen.dart';

class ARDistanceScreen extends StatefulWidget {
  @override
  _ARDistanceScreenState createState() => _ARDistanceScreenState();
}

class _ARDistanceScreenState extends State<ARDistanceScreen> {
  late ARMeasureService _measureService;
  late FlutterTts _tts;
  bool _ttsEnabled = true;
  final ScreenshotController _screenshotController = ScreenshotController();
  double? _lastSpokenDistance;

  @override
  void initState() {
    super.initState();
    _measureService = ARMeasureService(onUpdate: _handleUpdate);
    _tts = FlutterTts();
    _initializeTts();
  }

  void _handleUpdate() {
    setState(() {
      if (_measureService.distance != null &&
          _measureService.distance != _lastSpokenDistance) {
        _lastSpokenDistance = _measureService.distance;
        _speakDistance();
      }
    });
  }

  Future<void> _initializeTts() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
  }

  void _speakDistance() {
    if (_ttsEnabled && _measureService.distance != null) {
      _tts.speak("Distance is ${_measureService.getFormattedDistance()}");
    }
  }

  Future<void> _saveScreenshot() async {
    try {
      final Uint8List? imageBytes = await _screenshotController.capture();
      if (imageBytes == null) return;

      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Save to app's documents directory for in-app gallery
      final directory = await getApplicationDocumentsDirectory();
      final appImagePath = '${directory.path}/ar_distance_$timestamp.png';
      await File(appImagePath).writeAsBytes(imageBytes);

      // Save to device gallery
      final result = await ImageGallerySaverPlus.saveImage(
        imageBytes,
        name: 'ar_distance_$timestamp',
      );

      if (result != null && result['isSuccess'] as bool) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Screenshot saved to gallery!"))
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Saved to app gallery but failed to save to device: ${result?['errorMessage'] ?? 'Unknown error'}"))
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save: $e"))
      );
    }
  }

  void _navigateToGallery() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GalleryScreen()),
    );
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Screenshot(
        controller: _screenshotController,
        child: Stack(
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
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    "Distance: ${_measureService.getFormattedDistance()}",
                    style: const TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 50,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black38,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.photo_library, color: Colors.white),
                  onPressed: _navigateToGallery,
                  tooltip: "View Gallery",
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ControlPanel(
                service: _measureService,
                onScreenshot: _saveScreenshot,
                onTtsToggle: (value) => setState(() => _ttsEnabled = value),
                ttsEnabled: _ttsEnabled,
              ),
            ),
          ],
        ),
      ),
    );
  }
}