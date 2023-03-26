import 'package:flutter/material.dart';

class SkipConfig {
  /// Global configuration
  static SkipConfig global = const SkipConfig();

  /// Skip button text
  final String text;

  /// Position of the skip button
  final Alignment alignment;

  /// Color of ther skip text
  final Color color;

  const SkipConfig({
    this.text = 'Skip >>',
    this.alignment = Alignment.bottomLeft,
    this.color = Colors.white,
  });

  SkipConfig copyWith({
    String? text,
    Alignment? alignment,
    Color? color,
  }) {
    return SkipConfig(
      text: text ?? this.text,
      alignment: alignment ?? this.alignment,
      color: color ?? this.color,
    );
  }
}
