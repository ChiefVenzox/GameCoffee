import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import 'camera3d.dart';
import 'mesh3d.dart';

class RenderableFace {
  final List<Offset> screenPoints;
  final double depth;
  final Color shadedColor;

  RenderableFace({
    required this.screenPoints,
    required this.depth,
    required this.shadedColor,
  });
}

class Renderer3D {
  final vm.Vector3 lightDir = vm.Vector3(0.6, 1.2, 0.7).normalized();
  final double ambientIntensity = 0.42;
  final double diffuseIntensity = 0.58;

  void renderScene({
    required Canvas canvas,
    required Size size,
    required Camera3D camera,
    required List<Mesh3D> meshes,
  }) {
    if (size.width <= 0 || size.height <= 0) return;

    final aspectRatio = size.width / size.height;
    final viewMatrix = camera.getViewMatrix();
    final projMatrix = camera.getProjectionMatrix(aspectRatio);
    final viewProj = projMatrix * viewMatrix;

    final List<RenderableFace> renderQueue = [];

    for (var mesh in meshes) {
      final modelMatrix = mesh.modelMatrix;
      final worldVerts = <vm.Vector3>[];
      final screenPoints = <Offset?>[];
      final depths = <double>[];

      // Transform vertices
      for (var v in mesh.vertices) {
        final worldV = modelMatrix.transformed3(v);
        worldVerts.add(worldV);

        final clipV = viewProj.transform(vm.Vector4(worldV.x, worldV.y, worldV.z, 1.0));

        // Behind camera check
        if (clipV.w <= 0.001 && !camera.isIsometric) {
          screenPoints.add(null);
          depths.add(clipV.z);
          continue;
        }

        final ndcX = clipV.x / clipV.w;
        final ndcY = clipV.y / clipV.w;
        final screenX = (ndcX + 1.0) * 0.5 * size.width;
        final screenY = (1.0 - ndcY) * 0.5 * size.height;

        screenPoints.add(Offset(screenX, screenY));
        // View space depth for sorting
        depths.add(clipV.z / clipV.w);
      }

      // Process faces
      for (var face in mesh.faces) {
        final indices = face.vertexIndices;
        if (indices.length < 3) continue;

        // Ensure all vertices are in front of camera
        bool isInvalid = false;
        for (var idx in indices) {
          if (screenPoints[idx] == null) {
            isInvalid = true;
            break;
          }
        }
        if (isInvalid) continue;

        final v0 = worldVerts[indices[0]];
        final v1 = worldVerts[indices[1]];
        final v2 = worldVerts[indices[2]];

        // Calculate face normal in world space
        vm.Vector3 normal;
        if (face.customNormal != null) {
          normal = face.customNormal!;
        } else {
          final edge1 = v1 - v0;
          final edge2 = v2 - v0;
          normal = edge1.cross(edge2);
          if (normal.length2 < 0.000001) continue;
          normal.normalize();
        }

        // Backface culling
        if (!face.isDoubleSided) {
          final toCamera = camera.position - v0;
          if (normal.dot(toCamera) < 0) {
            continue; // Facing away from camera
          }
        }

        // Lighting calculation (Lambertian Diffuse + Ambient)
        final dotL = normal.dot(lightDir).clamp(0.0, 1.0);
        final lightFactor = (ambientIntensity + (diffuseIntensity * dotL)).clamp(0.0, 1.0);

        final shaded = Color.fromARGB(
          face.baseColor.alpha,
          (face.baseColor.red * lightFactor).round().clamp(0, 255),
          (face.baseColor.green * lightFactor).round().clamp(0, 255),
          (face.baseColor.blue * lightFactor).round().clamp(0, 255),
        );

        // Average face depth for sorting
        double avgDepth = 0.0;
        for (var idx in indices) {
          avgDepth += depths[idx];
        }
        avgDepth /= indices.length;

        final polyPoints = indices.map((idx) => screenPoints[idx]!).toList();

        renderQueue.add(RenderableFace(
          screenPoints: polyPoints,
          depth: avgDepth,
          shadedColor: shaded,
        ));
      }
    }

    // Depth sorting (Painter's Algorithm: Furthest first)
    renderQueue.sort((a, b) => b.depth.compareTo(a.depth));

    // Paint faces
    final fillPaint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    for (var face in renderQueue) {
      final path = ui.Path();
      path.moveTo(face.screenPoints[0].dx, face.screenPoints[0].dy);
      for (int i = 1; i < face.screenPoints.length; i++) {
        path.lineTo(face.screenPoints[i].dx, face.screenPoints[i].dy);
      }
      path.close();

      fillPaint.color = face.shadedColor;
      canvas.drawPath(path, fillPaint);

      // Subtle edge darkening for stylized low-poly cartoon look
      strokePaint.color = face.shadedColor.withValues(alpha: 0.15);
      canvas.drawPath(path, strokePaint);
    }
  }

  /// Helper to convert 3D world position to 2D screen coordinates
  static Offset? worldToScreen({
    required vm.Vector3 worldPos,
    required Camera3D camera,
    required Size size,
  }) {
    if (size.width <= 0 || size.height <= 0) return null;
    final aspectRatio = size.width / size.height;
    final vp = camera.getProjectionMatrix(aspectRatio) * camera.getViewMatrix();
    final clip = vp.transform(vm.Vector4(worldPos.x, worldPos.y, worldPos.z, 1.0));

    if (clip.w <= 0.001 && !camera.isIsometric) return null;
    final ndcX = clip.x / clip.w;
    final ndcY = clip.y / clip.w;
    return Offset(
      (ndcX + 1.0) * 0.5 * size.width,
      (1.0 - ndcY) * 0.5 * size.height,
    );
  }
}
