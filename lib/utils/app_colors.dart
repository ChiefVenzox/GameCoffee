import 'package:flutter/material.dart';

class AppColors {
  // Coffee Tones
  static const Color darkEspresso = Color(0xFF1E120A);
  static const Color deepCoffee = Color(0xFF2E1A0F);
  static const Color warmCoffee = Color(0xFF4A2810);
  static const Color roastedBean = Color(0xFF5D3A1A);
  static const Color milkCoffee = Color(0xFF8D5B4C);
  static const Color caramel = Color(0xFFD97706);
  static const Color goldenCrema = Color(0xFFF59E0B);
  static const Color lightCrema = Color(0xFFFCD34D);

  // Milk & Foam
  static const Color warmMilk = Color(0xFFFFFBEB);
  static const Color milkFoam = Color(0xFFFFF8E7);
  static const Color softCream = Color(0xFFF5EBE0);
  
  // Accents & Materials
  static const Color copperCezve = Color(0xFFC86432);
  static const Color bronzeAccent = Color(0xFFB45309);
  static const Color matchaGreen = Color(0xFF4E7A58);
  static const Color strawberryPink = Color(0xFFE11D48);
  static const Color chocolateBrown = Color(0xFF3E2723);

  // Interface & Cards
  static const Color bgDark = Color(0xFF160E08);
  static const Color bgCard = Color(0xFF26170E);
  static const Color bgCardLight = Color(0xFF382315);
  static const Color borderSubtle = Color(0x33F59E0B);
  static const Color textPrimary = Color(0xFFFFFBEB);
  static const Color textSecondary = Color(0xFFD1BBA7);
  static const Color textMuted = Color(0xFF9E8472);

  // Gradients
  static const LinearGradient coffeeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF2E1A0F), Color(0xFF160E08)],
  );

  static const LinearGradient goldenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
  );

  static const LinearGradient cezveGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE27B38), Color(0xFF9B3D12)],
  );

  static const LinearGradient espressoCremaGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF59E0B), Color(0xFF5D3A1A), Color(0xFF2E1A0F)],
  );
}
