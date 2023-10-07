import 'package:flutter/material.dart';

class SkipConfig {
  /// Global configuration.
  static SkipConfig global = const SkipConfig._();

  /// Skip button text.
  final String text;

  /// Position of the skip button.
  final Alignment alignment;

  /// Color of the Skip text. You can use [textStyle] for more control.
  final Color color;

  /// Enable or disable the Skip button.
  final bool enabled;

  /// Call the `onPressed` action when the skip button is pressed. Default is `false`.
  final bool isCallOnPressed;

  /// Set the style for the text.
  final TextStyle? textStyle;

  /// The [ButtonStyle] of the button
  /// Default:
  /// ``` dart
  ///    style: TextButton.styleFrom(
  ///      shape: RoundedRectangleBorder(
  ///        side: const BorderSide(
  ///          color: Colors.red,
  ///        ),
  ///        borderRadius: BorderRadius.circular(10),
  ///      ),
  ///    ),
  ///  ),
  /// ```
  final ButtonStyle? buttonStyle;

  const SkipConfig._({
    this.text = 'SKIP >>>',
    this.alignment = Alignment.bottomLeft,
    this.color = Colors.white,
    this.enabled = true,
    this.isCallOnPressed = false,
    this.textStyle,
    this.buttonStyle,
  });

  /// Create a new SkipConfig base on the [global] values.
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
  /// [textStyle] is the [TextStyle] of the button.
  ///
  /// [buttonStyle] is the [ButtonStyle] of the button.
  /// Default:
  /// ``` dart
  ///    style: TextButton.styleFrom(
  ///      shape: RoundedRectangleBorder(
  ///        side: const BorderSide(
  ///          color: Colors.red,
  ///        ),
  ///        borderRadius: BorderRadius.circular(10),
  ///      ),
  ///    ),
  ///  ),
  /// ```
  factory SkipConfig.copyWith({
    String? text,
    Alignment? alignment,
    Color? color,
    bool? enabled,
    bool? isCallOnPressed,
    TextStyle? textStyle,
    ButtonStyle? buttonStyle,
  }) {
    return global.copyWith(
      text: text,
      alignment: alignment,
      color: color,
      enabled: enabled,
      isCallOnPressed: isCallOnPressed,
      textStyle: textStyle,
      buttonStyle: buttonStyle,
    );
  }

  /// Create a new SkipConfig base on this values.
  SkipConfig copyWith({
    String? text,
    Alignment? alignment,
    Color? color,
    bool? enabled,
    bool? isCallOnPressed,
    TextStyle? textStyle,
    ButtonStyle? buttonStyle,
  }) {
    return SkipConfig._(
      text: text ?? this.text,
      alignment: alignment ?? this.alignment,
      color: color ?? this.color,
      enabled: enabled ?? this.enabled,
      isCallOnPressed: isCallOnPressed ?? this.isCallOnPressed,
      textStyle: textStyle ?? this.textStyle,
      buttonStyle: buttonStyle ?? this.buttonStyle,
    );
  }
}
