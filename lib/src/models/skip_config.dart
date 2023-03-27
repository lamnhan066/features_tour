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

  /// Enable or disable the skip button
  final bool enabled;

  const SkipConfig({
    this.text = 'SKIP >>>',
    this.alignment = Alignment.bottomLeft,
    this.color = Colors.white,
    this.enabled = true,
  });

  factory SkipConfig.copyWith({
    String? text,
    Alignment? alignment,
    Color? color,
    bool? enabled,
  }) {
    return SkipConfig(
      text: text ?? global.text,
      alignment: alignment ?? global.alignment,
      color: color ?? global.color,
      enabled: enabled ?? global.enabled,
    );
  }

  SkipConfig copyWith({
    String? text,
    Alignment? alignment,
    Color? color,
    bool? enabled,
  }) {
    return SkipConfig(
      text: text ?? this.text,
      alignment: alignment ?? this.alignment,
      color: color ?? this.color,
      enabled: enabled ?? this.enabled,
    );
  }
}
