import 'package:vector_math/vector_math_64.dart';

class GeometryUtils {
  static double calculateDistance(Vector3 a, Vector3 b) {
    return (a - b).length;
  }
}
