import 'package:flutter/material.dart';

class AppRadius {
  AppRadius._();

  // ===== Raw Values (Private) =====
  static const double _hero = 20;
  static const double _card = 16;
  static const double _button = 14;
  static const double _chip = 12;

  // ===== BorderRadius Tokens =====

  /// Hero (Bottom Only)
  static final BorderRadius hero = const BorderRadius.vertical(
    top: Radius.circular(_hero),
  );

  /// Standard Card
  static final BorderRadius card = BorderRadius.circular(_card);

  /// Button
  static final BorderRadius button = BorderRadius.circular(_button);

  /// Chip
  static final BorderRadius chip = BorderRadius.circular(_chip);
}
