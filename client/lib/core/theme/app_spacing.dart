import 'package:flutter/material.dart';

/// Standard spacing and layout dimensional scale across ProjectHub.
class AppSpacing {
  AppSpacing._();

  static const double zero = 0.0;
  static const double xxs = 2.0;
  static const double s3 = 3.0;
  static const double xs = 4.0;
  static const double s5 = 5.0;
  static const double s6 = 6.0;
  static const double s7 = 7.0;
  static const double sm = 8.0;
  static const double s10 = 10.0;
  static const double md = 12.0;
  static const double s14 = 14.0;
  static const double lg = 16.0;
  static const double s18 = 18.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double s28 = 28.0;
  static const double xxxl = 32.0;
  static const double s40 = 40.0;
  static const double s48 = 48.0;
  static const double s80 = 80.0;

  // Common horizontal and vertical gaps
  static const SizedBox gapW2 = SizedBox(width: xxs);
  static const SizedBox gapW4 = SizedBox(width: xs);
  static const SizedBox gapW6 = SizedBox(width: s6);
  static const SizedBox gapW8 = SizedBox(width: sm);
  static const SizedBox gapW10 = SizedBox(width: s10);
  static const SizedBox gapW12 = SizedBox(width: md);
  static const SizedBox gapW14 = SizedBox(width: s14);
  static const SizedBox gapW16 = SizedBox(width: lg);
  static const SizedBox gapW18 = SizedBox(width: s18);
  static const SizedBox gapW20 = SizedBox(width: xl);
  static const SizedBox gapW24 = SizedBox(width: xxl);
  static const SizedBox gapW32 = SizedBox(width: xxxl);

  static const SizedBox gapH2 = SizedBox(height: xxs);
  static const SizedBox gapH4 = SizedBox(height: xs);
  static const SizedBox gapH6 = SizedBox(height: s6);
  static const SizedBox gapH8 = SizedBox(height: sm);
  static const SizedBox gapH10 = SizedBox(height: s10);
  static const SizedBox gapH12 = SizedBox(height: md);
  static const SizedBox gapH14 = SizedBox(height: s14);
  static const SizedBox gapH16 = SizedBox(height: lg);
  static const SizedBox gapH18 = SizedBox(height: s18);
  static const SizedBox gapH20 = SizedBox(height: xl);
  static const SizedBox gapH24 = SizedBox(height: xxl);
  static const SizedBox gapH28 = SizedBox(height: s28);
  static const SizedBox gapH32 = SizedBox(height: xxxl);
  static const SizedBox gapH40 = SizedBox(height: s40);
  static const SizedBox gapH48 = SizedBox(height: s48);

  // Common EdgeInsets
  static const EdgeInsets edgeInsetsAll4 = EdgeInsets.all(xs);
  static const EdgeInsets edgeInsetsAll6 = EdgeInsets.all(s6);
  static const EdgeInsets edgeInsetsAll8 = EdgeInsets.all(sm);
  static const EdgeInsets edgeInsetsAll10 = EdgeInsets.all(s10);
  static const EdgeInsets edgeInsetsAll12 = EdgeInsets.all(md);
  static const EdgeInsets edgeInsetsAll14 = EdgeInsets.all(s14);
  static const EdgeInsets edgeInsetsAll16 = EdgeInsets.all(lg);
  static const EdgeInsets edgeInsetsAll20 = EdgeInsets.all(xl);
  static const EdgeInsets edgeInsetsAll24 = EdgeInsets.all(xxl);
  static const EdgeInsets edgeInsetsAll32 = EdgeInsets.all(xxxl);

  // Symmetric EdgeInsets
  static const EdgeInsets edgeInsetsH16 = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets edgeInsetsH20 = EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets edgeInsetsH24 = EdgeInsets.symmetric(horizontal: xxl);
  static const EdgeInsets edgeInsetsV6 = EdgeInsets.symmetric(vertical: s6);
  static const EdgeInsets edgeInsetsV8 = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets edgeInsetsV12 = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets edgeInsetsV16 = EdgeInsets.symmetric(vertical: lg);
}
