import 'dart:math';
import 'package:vector_math/vector_math_64.dart' as vm;

class Camera3D {
  vm.Vector3 position;
  vm.Vector3 target;
  vm.Vector3 up;
  double fov;
  double near;
  double far;
  bool isIsometric;
  double orthoSize;

  Camera3D({
    vm.Vector3? position,
    vm.Vector3? target,
    vm.Vector3? up,
    this.fov = 50 * pi / 180,
    this.near = 0.1,
    this.far = 500.0,
    this.isIsometric = true,
    this.orthoSize = 7.5,
  })  : position = position ?? vm.Vector3(12, 14, 12),
        target = target ?? vm.Vector3(0, 1, 0),
        up = up ?? vm.Vector3(0, 1, 0);

  vm.Matrix4 getViewMatrix() {
    return vm.makeViewMatrix(position, target, up);
  }

  vm.Matrix4 getProjectionMatrix(double aspectRatio) {
    if (isIsometric) {
      final double width = orthoSize * aspectRatio;
      final double height = orthoSize;
      return vm.makeOrthographicMatrix(
        -width / 2,
        width / 2,
        -height / 2,
        height / 2,
        near,
        far,
      );
    } else {
      return vm.makePerspectiveMatrix(fov, aspectRatio, near, far);
    }
  }

  /// Orbit camera around the current target
  void orbit(double deltaAzimuth, double deltaElevation) {
    final offset = position - target;
    double radius = offset.length;
    double theta = atan2(offset.x, offset.z); // Azimuth
    double phi = asin((offset.y / radius).clamp(-1.0, 1.0)); // Elevation

    theta += deltaAzimuth;
    phi = (phi + deltaElevation).clamp(0.1, pi / 2 - 0.05); // Keep above ground

    final newX = target.x + radius * cos(phi) * sin(theta);
    final newY = target.y + radius * sin(phi);
    final newZ = target.z + radius * cos(phi) * cos(theta);

    position = vm.Vector3(newX, newY, newZ);
  }

  void zoomBy(double factor) {
    if (isIsometric) {
      orthoSize = (orthoSize * factor).clamp(3.0, 20.0);
    } else {
      final dir = (position - target).normalized();
      final currentDist = (position - target).length;
      final newDist = (currentDist * factor).clamp(4.0, 40.0);
      position = target + dir * newDist;
    }
  }
}
