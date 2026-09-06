import 'package:flutter/material.dart';

/// Global controller to persist ambient glow position & pointer state across routes
class AmbientGlowState {
  AmbientGlowState._();
  static final AmbientGlowState instance = AmbientGlowState._();

  final int _startEpoch = DateTime.now().millisecondsSinceEpoch;
  Offset pointerOffset = Offset.zero;
  Offset smoothedPointerOffset = Offset.zero;

  double getCycleProgress(int durationMs) {
    final elapsed = DateTime.now().millisecondsSinceEpoch - _startEpoch;
    return (elapsed % durationMs) / durationMs;
  }
}
