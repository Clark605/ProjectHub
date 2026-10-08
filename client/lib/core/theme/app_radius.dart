import 'package:flutter/material.dart';

/// Standard geometric corner radiuses across ProjectHub.
class AppRadius {
  AppRadius._();

  static const double xsValue = 4.0;
  static const double smValue = 8.0;
  static const double mdValue = 12.0;
  static const double lgValue = 16.0;
  static const double xlValue = 20.0;
  static const double xxlValue = 24.0;
  static const double fullValue = 999.0;

  static const Radius xs = Radius.circular(xsValue);
  static const Radius sm = Radius.circular(smValue);
  static const Radius md = Radius.circular(mdValue);
  static const Radius lg = Radius.circular(lgValue);
  static const Radius xl = Radius.circular(xlValue);
  static const Radius xxl = Radius.circular(xxlValue);
  static const Radius full = Radius.circular(fullValue);

  static const BorderRadius kRadiusXs = BorderRadius.all(xs);
  static const BorderRadius kRadiusSm = BorderRadius.all(sm);
  static const BorderRadius kRadiusMd = BorderRadius.all(md);
  static const BorderRadius kRadiusLg = BorderRadius.all(lg);
  static const BorderRadius kRadiusXl = BorderRadius.all(xl);
  static const BorderRadius kRadiusXxl = BorderRadius.all(xxl);
  static const BorderRadius kRadiusFull = BorderRadius.all(full);
}

