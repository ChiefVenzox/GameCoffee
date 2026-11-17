import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import 'mesh3d.dart';

class Models3D {
  // -------------------------------------------------------------
  // 1. CARAVAN 3D MODEL
  // -------------------------------------------------------------
  static Mesh3D createCaravan({
    Color bodyColor = const Color(0xFF5A8F6A), // Pastel Mint Green
    Color roofColor = const Color(0xFFF7F2E7), // Warm Cream
    Color woodColor = const Color(0xFFB57C48), // Honey Oak
    Color trimColor = const Color(0xFFD97706), // Gold Trim
  }) {
    final parts = <Mesh3D>[];

    // Main Trailer Body
    parts.add(Mesh3D.createBox(
      size: vm.Vector3(4.2, 2.2, 2.4),
      color: bodyColor,
      center: vm.Vector3(0, 1.4, 0),
    ));

    // Curved Upper Roof
    parts.add(Mesh3D.createBox(
      size: vm.Vector3(4.0, 0.45, 2.3),
      color: roofColor,
      center: vm.Vector3(0, 2.6, 0),
    ));

    // Serving Hatch / Cutout Frame (Front-facing side)
    parts.add(Mesh3D.createBox(
      size: vm.Vector3(2.4, 1.1, 0.15),
      color: const Color(0xFF231710), // Interior dark shadow
      center: vm.Vector3(0.2, 1.6, 1.22),
    ));

    // Wooden Service Counter (Shelf sticking out from hatch)
    parts.add(Mesh3D.createBox(
      size: vm.Vector3(2.6, 0.12, 0.6),
      color: woodColor,
      center: vm.Vector3(0.2, 1.1, 1.45),
    ));

    // Awning / Tente (Striped Canopy over window)
    parts.add(Mesh3D.createBox(
      size: vm.Vector3(2.8, 0.1, 0.8),
      color: trimColor,
      center: vm.Vector3(0.2, 2.35, 1.55),
    )..rotation = vm.Vector3(0.25, 0, 0));

    // Wheels (4 wheels)
    final wheelColor = const Color(0xFF222222);
    final rimColor = const Color(0xFFE5E5E5);

    final wheelPositions = [
      vm.Vector3(-1.2, 0.45, 1.25),
      vm.Vector3(1.2, 0.45, 1.25),
      vm.Vector3(-1.2, 0.45, -1.25),
      vm.Vector3(1.2, 0.45, -1.25),
    ];

    for (var pos in wheelPositions) {
      final w = Mesh3D.createCylinder(
        radius: 0.45,
        height: 0.22,
        segments: 10,
        color: wheelColor,
        center: pos,
      )..rotation = vm.Vector3(pi / 2, 0, 0);
      parts.add(w);

      final rim = Mesh3D.createCylinder(
        radius: 0.25,
        height: 0.24,
        segments: 8,
        color: rimColor,
        center: pos,
      )..rotation = vm.Vector3(pi / 2, 0, 0);
      parts.add(rim);
    }

    // Chimney & Smoke Pipe
    parts.add(Mesh3D.createCylinder(
      radius: 0.14,
      height: 0.6,
      segments: 8,
      color: const Color(0xFF4A4A4A),
      center: vm.Vector3(-1.2, 3.0, -0.4),
    ));

    // Caravan Tow Bar / Hitch
    parts.add(Mesh3D.createBox(
      size: vm.Vector3(0.8, 0.12, 0.3),
      color: const Color(0xFF333333),
      center: vm.Vector3(2.4, 0.45, 0),
    ));

    return Mesh3D.combine(parts);
  }

  // -------------------------------------------------------------
  // 2. BARISTA 3D CHARACTER
  // -------------------------------------------------------------
  static Mesh3D createBarista({
    double walkCycle = 0.0, // 0 to 2*pi
    bool isHoldingCup = false,
  }) {
    final parts = <Mesh3D>[];

    final legAngle = sin(walkCycle) * 0.4;
    final pantsColor = const Color(0xFF334155);
    final apronColor = const Color(0xFF854D0E);
    final shirtColor = const Color(0xFFF1F5F9);
    final skinColor = const Color(0xFFFBCFE8);
    final hatColor = const Color(0xFFFFFFFF);

    // Left Leg
    parts.add(Mesh3D.createBox(
      size: vm.Vector3(0.22, 0.55, 0.22),
      color: pantsColor,
      center: vm.Vector3(-0.16, 0.28, 0),
    )..rotation = vm.Vector3(legAngle, 0, 0));

    // Right Leg
    parts.add(Mesh3D.createBox(
      size: vm.Vector3(0.22, 0.55, 0.22),
      color: pantsColor,
      center: vm.Vector3(0.16, 0.28, 0),
    )..rotation = vm.Vector3(-legAngle, 0, 0));

    // Torso / Shirt & Apron
    parts.add(Mesh3D.createBox(
      size: vm.Vector3(0.55, 0.65, 0.35),
      color: shirtColor,
      center: vm.Vector3(0, 0.85, 0),
    ));
    parts.add(Mesh3D.createBox(
      size: vm.Vector3(0.42, 0.55, 0.38),
      color: apronColor,
      center: vm.Vector3(0, 0.82, 0.02),
    ));

    // Head
    parts.add(Mesh3D.createBox(
      size: vm.Vector3(0.4, 0.38, 0.38),
      color: skinColor,
      center: vm.Vector3(0, 1.35, 0),
    ));

    // Barista Toque / Chef Hat
    parts.add(Mesh3D.createCylinder(
      radius: 0.26,
      height: 0.35,
      segments: 10,
      color: hatColor,
      center: vm.Vector3(0, 1.68, 0),
    ));

    // Arms
    final armZ = isHoldingCup ? 0.2 : 0.0;
    final armAngle = isHoldingCup ? -0.8 : -sin(walkCycle) * 0.3;

    // Left Arm
    parts.add(Mesh3D.createBox(
      size: vm.Vector3(0.16, 0.45, 0.16),
      color: shirtColor,
      center: vm.Vector3(-0.35, 0.85, armZ),
    )..rotation = vm.Vector3(armAngle, 0, 0));

    // Right Arm
    parts.add(Mesh3D.createBox(
      size: vm.Vector3(0.16, 0.45, 0.16),
      color: shirtColor,
      center: vm.Vector3(0.35, 0.85, armZ),
    )..rotation = vm.Vector3(-armAngle, 0, 0));

    // Cup in hands if carrying
    if (isHoldingCup) {
      parts.add(Mesh3D.createCylinder(
        radius: 0.14,
        height: 0.22,
        segments: 8,
        color: const Color(0xFFFFFBEB),
        center: vm.Vector3(0, 0.85, 0.42),
      ));
    }

    return Mesh3D.combine(parts);
  }

  // -------------------------------------------------------------
  // 3. CUSTOMER 3D CHARACTER
  // -------------------------------------------------------------
  static Mesh3D createCustomer({
    required Color outfitColor,
    required Color hairColor,
    bool isSitting = false,
  }) {
    final parts = <Mesh3D>[];
    final skinColor = const Color(0xFFFFD1BA);

    if (isSitting) {
      // Seated legs
      parts.add(Mesh3D.createBox(
        size: vm.Vector3(0.45, 0.2, 0.45),
        color: const Color(0xFF1E293B),
        center: vm.Vector3(0, 0.4, 0.15),
      ));
    } else {
      // Standing legs
      parts.add(Mesh3D.createBox(
        size: vm.Vector3(0.45, 0.55, 0.22),
        color: const Color(0xFF1E293B),
        center: vm.Vector3(0, 0.28, 0),
      ));
    }

    final bodyY = isSitting ? 0.75 : 0.85;

    // Torso
    parts.add(Mesh3D.createBox(
      size: vm.Vector3(0.5, 0.6, 0.32),
      color: outfitColor,
      center: vm.Vector3(0, bodyY, 0),
    ));

    // Head
    parts.add(Mesh3D.createBox(
      size: vm.Vector3(0.38, 0.36, 0.36),
      color: skinColor,
      center: vm.Vector3(0, bodyY + 0.48, 0),
    ));

    // Hair
    parts.add(Mesh3D.createBox(
      size: vm.Vector3(0.42, 0.18, 0.4),
      color: hairColor,
      center: vm.Vector3(0, bodyY + 0.68, -0.02),
    ));

    return Mesh3D.combine(parts);
  }

  // -------------------------------------------------------------
  // 4. APPLIANCES & FURNITURE 3D
  // -------------------------------------------------------------

  /// 3D Espresso Machine
  static Mesh3D createEspressoMachine() {
    final parts = <Mesh3D>[];
    // Machine body (stainless chrome)
    parts.add(Mesh3D.createBox(
      size: vm.Vector3(0.85, 0.75, 0.65),
      color: const Color(0xFFCBD5E1),
      center: vm.Vector3(0, 0.38, 0),
    ));
    // Red Accent side panels
    parts.add(Mesh3D.createBox(
      size: vm.Vector3(0.89, 0.65, 0.55),
      color: const Color(0xFFBE123C),
      center: vm.Vector3(0, 0.38, 0),
    ));
    // Drip tray
    parts.add(Mesh3D.createBox(
      size: vm.Vector3(0.8, 0.08, 0.3),
      color: const Color(0xFF475569),
      center: vm.Vector3(0, 0.05, 0.35),
    ));
    // Group heads & portafilter handle
    parts.add(Mesh3D.createBox(
      size: vm.Vector3(0.12, 0.12, 0.35),
      color: const Color(0xFF0F172A),
      center: vm.Vector3(0.15, 0.4, 0.35),
    ));
    return Mesh3D.combine(parts);
  }

  /// 3D Coffee Grinder
  static Mesh3D createGrinder() {
    final parts = <Mesh3D>[];
    // Base & body
    parts.add(Mesh3D.createBox(
      size: vm.Vector3(0.45, 0.55, 0.45),
      color: const Color(0xFF1E293B),
      center: vm.Vector3(0, 0.28, 0),
    ));
    // Clear Hopper with roasted beans
    parts.add(Mesh3D.createCylinder(
      radius: 0.22,
      height: 0.45,
      segments: 8,
      color: const Color(0xFF5D3A1A), // Roasted coffee beans color
      center: vm.Vector3(0, 0.75, 0),
    ));
    // Hopper lid
    parts.add(Mesh3D.createCylinder(
      radius: 0.25,
      height: 0.06,
      segments: 8,
      color: const Color(0xFF0F172A),
      center: vm.Vector3(0, 0.98, 0),
    ));
    return Mesh3D.combine(parts);
  }

  /// 3D Sink / Bulaşık Lavabosu
  static Mesh3D createSink({bool isRunningWater = false}) {
    final parts = <Mesh3D>[];
    // Sink counter base
    parts.add(Mesh3D.createBox(
      size: vm.Vector3(0.9, 0.85, 0.8),
      color: const Color(0xFF94A3B8),
      center: vm.Vector3(0, 0.42, 0),
    ));
    // Basin inner cavity
    parts.add(Mesh3D.createBox(
      size: vm.Vector3(0.7, 0.3, 0.6),
      color: const Color(0xFF334155),
      center: vm.Vector3(0, 0.7, 0),
    ));
    // Faucet tap
    parts.add(Mesh3D.createCylinder(
      radius: 0.04,
      height: 0.35,
      segments: 6,
      color: const Color(0xFFE2E8F0),
      center: vm.Vector3(0, 1.0, -0.2),
    ));
    // Water stream if actively washing
    if (isRunningWater) {
      parts.add(Mesh3D.createCylinder(
        radius: 0.05,
        height: 0.28,
        segments: 6,
        color: const Color(0x9938BDF8),
        center: vm.Vector3(0, 0.8, -0.05),
      ));
    }
    return Mesh3D.combine(parts);
  }

  /// 3D Kitchen Prep Counter
  static Mesh3D createCounter({required double width, required double depth}) {
    final parts = <Mesh3D>[];
    // Wooden cabinet
    parts.add(Mesh3D.createBox(
      size: vm.Vector3(width, 0.85, depth),
      color: const Color(0xFF78350F), // Rich wood
      center: vm.Vector3(0, 0.42, 0),
    ));
    // Marble / Stainless top
    parts.add(Mesh3D.createBox(
      size: vm.Vector3(width + 0.08, 0.08, depth + 0.08),
      color: const Color(0xFFF8FAFC),
      center: vm.Vector3(0, 0.88, 0),
    ));
    return Mesh3D.combine(parts);
  }

  /// 3D Outdoor Bistro Table
  static Mesh3D createBistroTable() {
    final parts = <Mesh3D>[];
    // Table Top (Round)
    parts.add(Mesh3D.createCylinder(
      radius: 0.7,
      height: 0.08,
      segments: 12,
      color: const Color(0xFFB45309), // Warm wood
      center: vm.Vector3(0, 0.8, 0),
    ));
    // Leg column
    parts.add(Mesh3D.createCylinder(
      radius: 0.08,
      height: 0.75,
      segments: 6,
      color: const Color(0xFF1E293B),
      center: vm.Vector3(0, 0.38, 0),
    ));
    // Base feet
    parts.add(Mesh3D.createBox(
      size: vm.Vector3(0.7, 0.06, 0.7),
      color: const Color(0xFF1E293B),
      center: vm.Vector3(0, 0.03, 0),
    ));
    return Mesh3D.combine(parts);
  }

  /// 3D Bistro Chair
  static Mesh3D createChair() {
    final parts = <Mesh3D>[];
    final color = const Color(0xFF9A3412);
    // Seat
    parts.add(Mesh3D.createBox(
      size: vm.Vector3(0.45, 0.06, 0.45),
      color: color,
      center: vm.Vector3(0, 0.45, 0),
    ));
    // Backrest
    parts.add(Mesh3D.createBox(
      size: vm.Vector3(0.45, 0.4, 0.06),
      color: color,
      center: vm.Vector3(0, 0.7, -0.2),
    ));
    // Legs
    parts.add(Mesh3D.createBox(
      size: vm.Vector3(0.42, 0.45, 0.42),
      color: const Color(0xFF1E293B),
      center: vm.Vector3(0, 0.22, 0),
    ));
    return Mesh3D.combine(parts);
  }

  /// 3D Low-poly Pine Tree
  static Mesh3D createPineTree() {
    final parts = <Mesh3D>[];
    // Trunk
    parts.add(Mesh3D.createCylinder(
      radius: 0.2,
      height: 1.0,
      segments: 6,
      color: const Color(0xFF451A03),
      center: vm.Vector3(0, 0.5, 0),
    ));
    // 3 Foliage pyramids
    parts.add(Mesh3D.createBox(
      size: vm.Vector3(1.6, 0.9, 1.6),
      color: const Color(0xFF166534),
      center: vm.Vector3(0, 1.4, 0),
    ));
    parts.add(Mesh3D.createBox(
      size: vm.Vector3(1.2, 0.8, 1.2),
      color: const Color(0xFF15803D),
      center: vm.Vector3(0, 2.0, 0),
    ));
    parts.add(Mesh3D.createBox(
      size: vm.Vector3(0.7, 0.7, 0.7),
      color: const Color(0xFF22C55E),
      center: vm.Vector3(0, 2.5, 0),
    ));
    return Mesh3D.combine(parts);
  }
}
