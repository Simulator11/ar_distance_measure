// File: lib/screens/gallery_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class GalleryScreen extends StatefulWidget {
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<File> _screenshots = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScreenshots();
  }

  Future<void> _loadScreenshots() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory.listSync();

    setState(() {
      _screenshots = files
          .whereType<File>()
          .where((file) => file.path.endsWith('.png') && file.path.contains('ar_distance_'))
          .toList()
          .reversed
          .toList();

      _isLoading = false;
    });
  }

  Future<void> _deleteScreenshot(File file) async {
    try {
      await file.delete();
      setState(() {
        _screenshots.remove(file);
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Screenshot deleted"))
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete: $e"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Measurement Gallery'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadScreenshots();
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _screenshots.isEmpty
          ? Center(child: Text('No screenshots found'))
          : GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.7,
        ),
        padding: EdgeInsets.all(8),
        itemCount: _screenshots.length,
        itemBuilder: (context, index) {
          return _buildImageItem(_screenshots[index]);
        },
      ),
    );
  }

  Widget _buildImageItem(File file) {
    return GestureDetector(
      onTap: () => _showFullImage(file),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(file, fit: BoxFit.cover),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black54,
              padding: EdgeInsets.all(4),
              child: Text(
                _getFileName(file),
                style: TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteScreenshot(file),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullImage(File file) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.file(file),
        ),
      ),
    );
  }

  String _getFileName(File file) {
    final path = file.path;
    final name = path.split('/').last;
    final timestamp = name.replaceAll('ar_distance_', '').replaceAll('.png', '');
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')} ${date.day}/${date.month}/${date.year}';
  }
}