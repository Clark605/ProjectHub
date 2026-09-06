import 'package:flutter/widgets.dart';

class OnboardingStep {
  final String title;
  final String description;
  final String badgeText;
  final Widget visual;

  const OnboardingStep({
    required this.title,
    required this.description,
    required this.badgeText,
    required this.visual,
  });
}
