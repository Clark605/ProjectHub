import 'package:flutter/material.dart';

/// Semantic corner radius scale across ProjectHub.
///
/// Scale steps:
/// - `xs`: 4px
/// - `sm`: 8px
/// - `md`: 12px
/// - `lg`: 16px
/// - `xl`: 24px
/// - `full`: 999px
class AppRadius {
  AppRadius._();

  static const double xsValue = 4.0;
  static const double smValue = 8.0;
  static const double mdValue = 12.0;
  static const double lgValue = 16.0;
  static const double xlValue = 24.0;
  static const double fullValue = 999.0;

  static const Radius xsRadius = Radius.circular(xsValue);
  static const Radius smRadius = Radius.circular(smValue);
  static const Radius mdRadius = Radius.circular(mdValue);
  static const Radius lgRadius = Radius.circular(lgValue);
  static const Radius xlRadius = Radius.circular(xlValue);
  static const Radius fullRadius = Radius.circular(fullValue);

  static const BorderRadius xs = BorderRadius.all(xsRadius);
  static const BorderRadius sm = BorderRadius.all(smRadius);
  static const BorderRadius md = BorderRadius.all(mdRadius);
  static const BorderRadius lg = BorderRadius.all(lgRadius);
  static const BorderRadius xl = BorderRadius.all(xlRadius);
  static const BorderRadius full = BorderRadius.all(fullRadius);

  // Directional sheet / card radiuses
  static const BorderRadius topMd = BorderRadius.vertical(top: mdRadius);
  static const BorderRadius topLg = BorderRadius.vertical(top: lgRadius);
  static const BorderRadius topXl = BorderRadius.vertical(top: xlRadius);
  static const BorderRadius bottomMd = BorderRadius.vertical(bottom: mdRadius);
  static const BorderRadius bottomLg = BorderRadius.vertical(bottom: lgRadius);
}
