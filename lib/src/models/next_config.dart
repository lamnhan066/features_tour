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

  /// The [ButtonStyle] of the button
  /// Default:
  /// ``` dart
  ///   TextButton.styleFrom(
  ///     RoundedRectangleBorder(
  ///       side: BorderSide(
  ///         color: nextConfig.color,
  ///       ),
  ///       borderRadius: BorderRadius.circular(10),
  ///     ),
  ///   )
  /// ```
  final ButtonStyle? style;

  const NextConfig._({
    this.text = 'NEXT >>',
    this.alignment = Alignment.bottomRight,
    this.color = Colors.white,
    this.enabled = true,
    this.style,
  });

  /// Create a new NextConfig base on the [global] values
  ///
  /// [text] of the next button. Default is "NEXT >>".
  ///
  /// [alignment] is the alignment of the next button. Default is `Alignment.bottomRight`.
  ///
  /// [color] is the color of the next text. Default is `Colors.white`.
  ///
  /// [enabled] is true if the next button is enabled. Default is `true`.
  ///
  /// [style] is the [ButtonStyle] of the button
  /// Default:
  /// ``` dart
  ///   TextButton.styleFrom(
  ///     RoundedRectangleBorder(
  ///       side: BorderSide(
  ///         color: nextConfig.color,
  ///       ),
  ///       borderRadius: BorderRadius.circular(10),
  ///     ),
  ///   )
  /// ```
  factory NextConfig.copyWith({
    String? text,
    Alignment? alignment,
    Color? color,
    bool? enabled,
    ButtonStyle? style,
  }) {
    return NextConfig._(
      text: text ?? global.text,
      alignment: alignment ?? global.alignment,
      color: color ?? global.color,
      enabled: enabled ?? global.enabled,
      style: style ?? global.style,
    );
  }

  /// Create a new NextConfig base on this values
  NextConfig copyWith({
    String? text,
    Alignment? alignment,
    Color? color,
    bool? enabled,
    ButtonStyle? style,
  }) {
    return NextConfig._(
      text: text ?? this.text,
      alignment: alignment ?? this.alignment,
      color: color ?? this.color,
      enabled: enabled ?? this.enabled,
      style: style ?? this.style,
    );
  }
}
