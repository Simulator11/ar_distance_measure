import 'package:flutter/material.dart';
import 'screens/ar_distance_screen.dart';

void main() => runApp(ARDistanceApp());

class ARDistanceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "AR Distance App",
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: ARDistanceScreen(),
    );
  }
}
