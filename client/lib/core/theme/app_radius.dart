import 'package:flutter/material.dart';

/// Standard geometric corner radiuses across ProjectHub.
class AppRadius {
  AppRadius._();

  static const double xxsValue = 2.0;
  static const double xsValue = 4.0;
  static const double smValue = 8.0;
  static const double mdValue = 12.0;
  static const double lgValue = 16.0;
  static const double xlValue = 20.0;
  static const double xxlValue = 24.0;
  static const double fullValue = 999.0;

  static const Radius xxs = Radius.circular(xxsValue);
  static const Radius xs = Radius.circular(xsValue);
  static const Radius sm = Radius.circular(smValue);
  static const Radius md = Radius.circular(mdValue);
  static const Radius lg = Radius.circular(lgValue);
  static const Radius xl = Radius.circular(xlValue);
  static const Radius xxl = Radius.circular(xxlValue);
  static const Radius full = Radius.circular(fullValue);

  // Standard all-corner radiuses
  static const BorderRadius kRadiusXxs = BorderRadius.all(xxs);
  static const BorderRadius kRadiusXs = BorderRadius.all(xs);
  static const BorderRadius kRadiusSm = BorderRadius.all(sm);
  static const BorderRadius kRadiusMd = BorderRadius.all(md);
  static const BorderRadius kRadiusLg = BorderRadius.all(lg);
  static const BorderRadius kRadiusXl = BorderRadius.all(xl);
  static const BorderRadius kRadiusXxl = BorderRadius.all(xxl);
  static const BorderRadius kRadiusFull = BorderRadius.all(full);

  // Aliases for convenience
  static const BorderRadius radiusXs = kRadiusXs;
  static const BorderRadius radiusSm = kRadiusSm;
  static const BorderRadius radiusMd = kRadiusMd;
  static const BorderRadius radiusLg = kRadiusLg;
  static const BorderRadius radiusXl = kRadiusXl;
  static const BorderRadius radiusXxl = kRadiusXxl;
  static const BorderRadius radiusFull = kRadiusFull;

  // Specific numeric corner radiuses
  static const BorderRadius r2 = kRadiusXxs;
  static const BorderRadius r3 = BorderRadius.all(Radius.circular(3.0));
  static const BorderRadius r4 = kRadiusXs;
  static const BorderRadius r6 = BorderRadius.all(Radius.circular(6.0));
  static const BorderRadius r8 = kRadiusSm;
  static const BorderRadius r10 = BorderRadius.all(Radius.circular(10.0));
  static const BorderRadius r12 = kRadiusMd;
  static const BorderRadius r14 = BorderRadius.all(Radius.circular(14.0));
  static const BorderRadius r16 = kRadiusLg;
  static const BorderRadius r18 = BorderRadius.all(Radius.circular(18.0));
  static const BorderRadius r20 = kRadiusXl;
  static const BorderRadius r22 = BorderRadius.all(Radius.circular(22.0));
  static const BorderRadius r24 = kRadiusXxl;
  static const BorderRadius r28 = BorderRadius.all(Radius.circular(28.0));
  static const BorderRadius rFull = kRadiusFull;

  // Top sheet / card radiuses
  static const BorderRadius topMd = BorderRadius.vertical(top: md);
  static const BorderRadius topLg = BorderRadius.vertical(top: lg);
  static const BorderRadius topXl = BorderRadius.vertical(top: xl);
  static const BorderRadius topXxl = BorderRadius.vertical(top: xxl);
  static const BorderRadius bottomMd = BorderRadius.vertical(bottom: md);
  static const BorderRadius bottomLg = BorderRadius.vertical(bottom: lg);
}
