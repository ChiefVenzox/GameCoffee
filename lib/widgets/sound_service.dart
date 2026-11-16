import 'package:flutter/services.dart';

/// Sound and Haptic feedback controller for mobile (Android & iOS) and web
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  bool soundEnabled = true;
  bool hapticsEnabled = true;

  void toggleSound() {
    soundEnabled = !soundEnabled;
  }

  void toggleHaptics() {
    hapticsEnabled = !hapticsEnabled;
  }

  /// Button click haptic feedback
  void playClick() {
    if (!hapticsEnabled) return;
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Grinder motor vibration & sound
  void playGrinderTick() {
    if (!hapticsEnabled) return;
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}
  }

  /// Heavy tamping / lock portafilter
  void playTamp() {
    if (!hapticsEnabled) return;
    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  /// Liquid pouring sensation
  void playPourTick() {
    if (!hapticsEnabled) return;
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Turkish coffee boiling / milk foaming
  void playFoamTick() {
    if (!hapticsEnabled) return;
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// Celebration / Success
  void playSuccess() {
    if (!hapticsEnabled) return;
    try {
      HapticFeedback.mediumImpact();
      Future.delayed(const Duration(milliseconds: 120), () {
        HapticFeedback.heavyImpact();
      });
    } catch (_) {}
  }

  /// Error / Overboiled / Spilled
  void playError() {
    if (!hapticsEnabled) return;
    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}
  }
}
