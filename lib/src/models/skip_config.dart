import 'package:flutter/material.dart';

class SkipConfig {
  /// Global configuration
  static SkipConfig global = const SkipConfig._();

  /// Skip button text
  final String text;

  /// Position of the skip button
  final Alignment alignment;

  /// Color of ther skip text
  final Color color;

  /// Enable or disable the skip button
  final bool enabled;

  const SkipConfig._({
    this.text = 'SKIP >>>',
    this.alignment = Alignment.bottomLeft,
    this.color = Colors.white,
    this.enabled = true,
  });

  /// Create a new SkipConfig base on the [global] values
  factory SkipConfig.copyWith({
    String? text,
    Alignment? alignment,
    Color? color,
    bool? enabled,
  }) {
    return SkipConfig._(
      text: text ?? global.text,
      alignment: alignment ?? global.alignment,
      color: color ?? global.color,
      enabled: enabled ?? global.enabled,
    );
  }

  /// Create a new SkipConfig base on this values
  SkipConfig copyWith({
    String? text,
    Alignment? alignment,
    Color? color,
    bool? enabled,
  }) {
    return SkipConfig._(
      text: text ?? this.text,
      alignment: alignment ?? this.alignment,
      color: color ?? this.color,
      enabled: enabled ?? this.enabled,
    );
  }
}
