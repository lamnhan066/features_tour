import 'package:flutter/material.dart';

class NextConfig {
  /// Global configuration
  static NextConfig global = const NextConfig._();

  /// Next button text
  final String text;

  /// Position of the next button
  final Alignment alignment;

  /// Color of ther next text
  final Color color;

  /// Enable or disable the skip button
  final bool enabled;

  const NextConfig._({
    this.text = 'NEXT >>',
    this.alignment = Alignment.bottomRight,
    this.color = Colors.white,
    this.enabled = true,
  });

  /// Create a new NextConfig base on the [global] values
  factory NextConfig.copyWith({
    String? text,
    Alignment? alignment,
    Color? color,
    bool? enabled,
  }) {
    return NextConfig._(
      text: text ?? global.text,
      alignment: alignment ?? global.alignment,
      color: color ?? global.color,
      enabled: enabled ?? global.enabled,
    );
  }

  /// Create a new NextConfig base on this values
  NextConfig copyWith({
    String? text,
    Alignment? alignment,
    Color? color,
    bool? enabled,
  }) {
    return NextConfig._(
      text: text ?? this.text,
      alignment: alignment ?? this.alignment,
      color: color ?? this.color,
      enabled: enabled ?? this.enabled,
    );
  }
}
