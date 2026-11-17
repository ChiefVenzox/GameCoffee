import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class Face3D {
  final List<int> vertexIndices;
  final Color baseColor;
  final vm.Vector3? customNormal;
  final bool isDoubleSided;

  Face3D({
    required this.vertexIndices,
    required this.baseColor,
    this.customNormal,
    this.isDoubleSided = false,
  });
}

class Mesh3D {
  final List<vm.Vector3> vertices;
  final List<Face3D> faces;

  vm.Vector3 position;
  vm.Vector3 rotation; // in radians: x, y, z
  vm.Vector3 scale;

  Mesh3D({
    List<vm.Vector3>? vertices,
    List<Face3D>? faces,
    vm.Vector3? position,
    vm.Vector3? rotation,
    vm.Vector3? scale,
  })  : vertices = vertices ?? [],
        faces = faces ?? [],
        position = position ?? vm.Vector3.zero(),
        rotation = rotation ?? vm.Vector3.zero(),
        scale = scale ?? vm.Vector3(1, 1, 1);

  vm.Matrix4 get modelMatrix {
    final m = vm.Matrix4.identity();
    m.translate(position);
    if (rotation.y != 0) m.rotateY(rotation.y);
    if (rotation.x != 0) m.rotateX(rotation.x);
    if (rotation.z != 0) m.rotateZ(rotation.z);
    m.scale(scale);
    return m;
  }

  Mesh3D clone() {
    return Mesh3D(
      vertices: vertices.map((v) => v.clone()).toList(),
      faces: faces
          .map((f) => Face3D(
                vertexIndices: List.from(f.vertexIndices),
                baseColor: f.baseColor,
                customNormal: f.customNormal?.clone(),
                isDoubleSided: f.isDoubleSided,
              ))
          .toList(),
      position: position.clone(),
      rotation: rotation.clone(),
      scale: scale.clone(),
    );
  }

  /// Combine multiple meshes into one single mesh (applying their local transforms)
  static Mesh3D combine(List<Mesh3D> parts, {vm.Vector3? position, vm.Vector3? rotation}) {
    final List<vm.Vector3> combinedVerts = [];
    final List<Face3D> combinedFaces = [];

    for (var part in parts) {
      final transform = part.modelMatrix;
      final int offset = combinedVerts.length;

      for (var v in part.vertices) {
        final transformed = transform.transformed3(v);
        combinedVerts.add(transformed);
      }

      for (var f in part.faces) {
        final remappedIndices = f.vertexIndices.map((i) => i + offset).toList();
        combinedFaces.add(Face3D(
          vertexIndices: remappedIndices,
          baseColor: f.baseColor,
          customNormal: f.customNormal != null ? transform.transformed3(f.customNormal!) : null,
          isDoubleSided: f.isDoubleSided,
        ));
      }
    }

    return Mesh3D(
      vertices: combinedVerts,
      faces: combinedFaces,
      position: position ?? vm.Vector3.zero(),
      rotation: rotation ?? vm.Vector3.zero(),
    );
  }

  /// Creates a 3D Box / Cube
  static Mesh3D createBox({
    required vm.Vector3 size,
    required Color color,
    vm.Vector3? center,
    Map<String, Color>? faceColors,
  }) {
    final c = center ?? vm.Vector3.zero();
    final hx = size.x / 2.0;
    final hy = size.y / 2.0;
    final hz = size.z / 2.0;

    // 8 vertices of the box
    final vertices = [
      vm.Vector3(c.x - hx, c.y - hy, c.z - hz), // 0: left-bottom-back
      vm.Vector3(c.x + hx, c.y - hy, c.z - hz), // 1: right-bottom-back
      vm.Vector3(c.x + hx, c.y + hy, c.z - hz), // 2: right-top-back
      vm.Vector3(c.x - hx, c.y + hy, c.z - hz), // 3: left-top-back
      vm.Vector3(c.x - hx, c.y - hy, c.z + hz), // 4: left-bottom-front
      vm.Vector3(c.x + hx, c.y - hy, c.z + hz), // 5: right-bottom-front
      vm.Vector3(c.x + hx, c.y + hy, c.z + hz), // 6: right-top-front
      vm.Vector3(c.x - hx, c.y + hy, c.z + hz), // 7: left-top-front
    ];

    Color getC(String face) => faceColors?[face] ?? color;

    // 6 faces (quads: front, back, top, bottom, left, right)
    final faces = [
      // Front (facing +Z)
      Face3D(vertexIndices: [4, 5, 6, 7], baseColor: getC('front')),
      // Back (facing -Z)
      Face3D(vertexIndices: [1, 0, 3, 2], baseColor: getC('back')),
      // Top (facing +Y)
      Face3D(vertexIndices: [7, 6, 2, 3], baseColor: getC('top')),
      // Bottom (facing -Y)
      Face3D(vertexIndices: [0, 1, 5, 4], baseColor: getC('bottom')),
      // Left (facing -X)
      Face3D(vertexIndices: [0, 4, 7, 3], baseColor: getC('left')),
      // Right (facing +X)
      Face3D(vertexIndices: [5, 1, 2, 6], baseColor: getC('right')),
    ];

    return Mesh3D(vertices: vertices, faces: faces);
  }

  /// Creates a 3D Cylinder / Column
  static Mesh3D createCylinder({
    required double radius,
    required double height,
    required int segments,
    required Color color,
    vm.Vector3? center,
  }) {
    final c = center ?? vm.Vector3.zero();
    final halfH = height / 2.0;
    final List<vm.Vector3> vertices = [];
    final List<Face3D> faces = [];

    // Top center vertex
    final topCenterIdx = 0;
    vertices.add(vm.Vector3(c.x, c.y + halfH, c.z));

    // Bottom center vertex
    final botCenterIdx = 1;
    vertices.add(vm.Vector3(c.x, c.y - halfH, c.z));

    // Ring vertices
    for (int i = 0; i < segments; i++) {
      final angle = (i / segments) * 2 * pi;
      final x = c.x + radius * cos(angle);
      final z = c.z + radius * sin(angle);

      // Top ring vertex (2 + i * 2)
      vertices.add(vm.Vector3(x, c.y + halfH, z));
      // Bottom ring vertex (2 + i * 2 + 1)
      vertices.add(vm.Vector3(x, c.y - halfH, z));
    }

    for (int i = 0; i < segments; i++) {
      final next = (i + 1) % segments;
      final topA = 2 + (i * 2);
      final botA = topA + 1;
      final topB = 2 + (next * 2);
      final botB = topB + 1;

      // Side quad
      faces.add(Face3D(vertexIndices: [botA, botB, topB, topA], baseColor: color));

      // Top triangle fan
      faces.add(Face3D(vertexIndices: [topCenterIdx, topA, topB], baseColor: color));

      // Bottom triangle fan
      faces.add(Face3D(vertexIndices: [botCenterIdx, botB, botA], baseColor: color));
    }

    return Mesh3D(vertices: vertices, faces: faces);
  }

  /// Creates a flat 3D Plane / Tile
  static Mesh3D createPlane({
    required double width,
    required double depth,
    required Color color,
    vm.Vector3? center,
  }) {
    final c = center ?? vm.Vector3.zero();
    final hx = width / 2;
    final hz = depth / 2;

    final vertices = [
      vm.Vector3(c.x - hx, c.y, c.z - hz),
      vm.Vector3(c.x + hx, c.y, c.z - hz),
      vm.Vector3(c.x + hx, c.y, c.z + hz),
      vm.Vector3(c.x - hx, c.y, c.z + hz),
    ];

    final faces = [
      Face3D(vertexIndices: [0, 1, 2, 3], baseColor: color, isDoubleSided: true),
    ];

    return Mesh3D(vertices: vertices, faces: faces);
  }
}
