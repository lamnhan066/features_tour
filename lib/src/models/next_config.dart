import 'package:flutter/material.dart';

class NextConfig {
  /// Global configuration
  static NextConfig global = const NextConfig._();

  /// Next button text
  final String text;

  /// Position of the next button
  final Alignment alignment;

  /// Color of the Next text. You can use [textStyle] for more control.
  final Color color;

  /// Enable or disable the Skip button
  final bool enabled;

  /// Set the style for the text
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

  const NextConfig._({
    this.text = 'NEXT >>',
    this.alignment = Alignment.bottomRight,
    this.color = Colors.white,
    this.enabled = true,
    this.textStyle,
    this.buttonStyle,
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
  /// [textStyle] is the [TextStyle] of the button
  ///
  /// [buttonStyle] is the [ButtonStyle] of the button
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
  factory NextConfig.copyWith({
    String? text,
    Alignment? alignment,
    Color? color,
    bool? enabled,
    TextStyle? textStyle,
    ButtonStyle? buttonStyle,
  }) {
    return NextConfig._(
      text: text ?? global.text,
      alignment: alignment ?? global.alignment,
      color: color ?? global.color,
      enabled: enabled ?? global.enabled,
      textStyle: textStyle ?? global.textStyle,
      buttonStyle: buttonStyle ?? global.buttonStyle,
    );
  }

  /// Create a new NextConfig base on this values
  NextConfig copyWith({
    String? text,
    Alignment? alignment,
    Color? color,
    bool? enabled,
    TextStyle? textStyle,
    ButtonStyle? buttonStyle,
  }) {
    return NextConfig._(
      text: text ?? this.text,
      alignment: alignment ?? this.alignment,
      color: color ?? this.color,
      enabled: enabled ?? this.enabled,
      textStyle: textStyle ?? this.textStyle,
      buttonStyle: buttonStyle ?? this.buttonStyle,
    );
  }
}
