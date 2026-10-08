import 'package:flutter/material.dart';

/// Standard spacing and layout dimensional scale across ProjectHub.
class AppSpacing {
  AppSpacing._();

  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  // Common horizontal and vertical gaps
  static const SizedBox gapW2 = SizedBox(width: xxs);
  static const SizedBox gapW4 = SizedBox(width: xs);
  static const SizedBox gapW6 = SizedBox(width: 6.0);
  static const SizedBox gapW8 = SizedBox(width: sm);
  static const SizedBox gapW12 = SizedBox(width: md);
  static const SizedBox gapW16 = SizedBox(width: lg);
  static const SizedBox gapW20 = SizedBox(width: xl);
  static const SizedBox gapW24 = SizedBox(width: xxl);

  static const SizedBox gapH2 = SizedBox(height: xxs);
  static const SizedBox gapH4 = SizedBox(height: xs);
  static const SizedBox gapH6 = SizedBox(height: 6.0);
  static const SizedBox gapH8 = SizedBox(height: sm);
  static const SizedBox gapH10 = SizedBox(height: 10.0);
  static const SizedBox gapH12 = SizedBox(height: md);
  static const SizedBox gapH16 = SizedBox(height: lg);
  static const SizedBox gapH18 = SizedBox(height: 18.0);
  static const SizedBox gapH20 = SizedBox(height: xl);
  static const SizedBox gapH24 = SizedBox(height: xxl);
  static const SizedBox gapH32 = SizedBox(height: xxxl);

  // Common EdgeInsets
  static const EdgeInsets edgeInsetsAll8 = EdgeInsets.all(sm);
  static const EdgeInsets edgeInsetsAll12 = EdgeInsets.all(md);
  static const EdgeInsets edgeInsetsAll16 = EdgeInsets.all(lg);
  static const EdgeInsets edgeInsetsAll20 = EdgeInsets.all(xl);
  static const EdgeInsets edgeInsetsAll24 = EdgeInsets.all(xxl);
}

