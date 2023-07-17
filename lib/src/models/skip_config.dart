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

  /// Call the `onPressed` action when the skip button is pressed. Default is `false`.
  final bool isCallOnPressed;

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

  const SkipConfig._({
    this.text = 'SKIP >>>',
    this.alignment = Alignment.bottomLeft,
    this.color = Colors.white,
    this.enabled = true,
    this.isCallOnPressed = false,
    this.style,
  });

  /// Create a new SkipConfig base on the [global] values
  ///
  /// [text] of skip button, default is 'SKIP >>>'.
  ///
  /// [alignment] is the position of the skip text, default is `Alignment.bottomLeft`.
  ///
  /// [color] is the color of skip text, default is `Colors.white`.
  ///
  /// [enabled] whether the skip button is enabled or not, default is `true`.
  ///
  /// [isCallOnPressed] allows the tour to call `onPressed` when the skip button is pressed.
  /// Default is `false`. Means that doesn't call `onPressed` when the skip button is pressed.
  ///
  /// [style] is the [ButtonStyle] of the button.
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
  factory SkipConfig.copyWith({
    String? text,
    Alignment? alignment,
    Color? color,
    bool? enabled,
    bool? isCallOnPressed,
    ButtonStyle? style,
  }) {
    return SkipConfig._(
      text: text ?? global.text,
      alignment: alignment ?? global.alignment,
      color: color ?? global.color,
      enabled: enabled ?? global.enabled,
      isCallOnPressed: isCallOnPressed ?? global.isCallOnPressed,
      style: style ?? global.style,
    );
  }

  /// Create a new SkipConfig base on this values
  SkipConfig copyWith({
    String? text,
    Alignment? alignment,
    Color? color,
    bool? enabled,
    bool? isCallOnPressed,
    ButtonStyle? style,
  }) {
    return SkipConfig._(
      text: text ?? this.text,
      alignment: alignment ?? this.alignment,
      color: color ?? this.color,
      enabled: enabled ?? this.enabled,
      isCallOnPressed: isCallOnPressed ?? this.isCallOnPressed,
      style: style ?? this.style,
    );
  }
}
