import 'package:flutter/material.dart';

class NextConfig {
  /// Global configuration
  static NextConfig global = const NextConfig();

  /// Next button text
  final String text;

  /// Position of the next button
  final Alignment alignment;

  /// Color of ther next text
  final Color color;

  const NextConfig({
    this.text = 'NEXT >>',
    this.alignment = Alignment.bottomRight,
    this.color = Colors.white,
  });

  NextConfig copyWith({
    String? text,
    Alignment? alignment,
    Color? color,
  }) {
    return NextConfig(
      text: text ?? this.text,
      alignment: alignment ?? this.alignment,
      color: color ?? this.color,
    );
  }
}
