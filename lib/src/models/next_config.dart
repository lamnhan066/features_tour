import 'package:features_tour/src/models/base_config.dart';
import 'package:flutter/material.dart';

class NextConfig extends BaseConfig {
  /// Global configuration.
  static NextConfig global = const NextConfig._();

  const NextConfig._({
    super.child,
    super.text = 'NEXT',
    super.alignment = Alignment.bottomRight,
    super.color,
    super.enabled = true,
    super.textStyle,
    super.buttonStyle,
  });

  /// Create a new NextConfig base on the [global] values.
  ///
  /// [child] Modified widget for the next button. When this Widget is set, you have to
  /// pass `onPressed` method
  ///
  /// [text] of the next button. Default is "NEXT".
  ///
  /// [alignment] is the alignment of the next button. Default is `Alignment.bottomRight`.
  ///
  /// [color] is the color of the next text. Default is `null`.
  ///
  /// [enabled] is true if the next button is enabled. Default is `true`.
  ///
  /// [textStyle] is the [TextStyle] of the button.
  ///
  /// [buttonStyle] is the [ButtonStyle] of the button.
  /// Default:
  /// ``` dart
  ///    style: ElevatedButton.styleFrom(
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
    Widget Function(VoidCallback onPressed)? child,
    String? text,
    Alignment? alignment,
    Color? color,
    bool? enabled,
    TextStyle? textStyle,
    ButtonStyle? buttonStyle,
  }) {
    return global.copyWith(
      child: child,
      text: text,
      alignment: alignment,
      color: color,
      enabled: enabled,
      textStyle: textStyle,
      buttonStyle: buttonStyle,
    );
  }

  /// Create a new NextConfig base on this values.
  @override
  NextConfig copyWith({
    Widget Function(VoidCallback onPressed)? child,
    String? text,
    Alignment? alignment,
    Color? color,
    bool? enabled,
    TextStyle? textStyle,
    ButtonStyle? buttonStyle,
  }) {
    return NextConfig._(
      child: child ?? this.child,
      text: text ?? this.text,
      alignment: alignment ?? this.alignment,
      color: color ?? this.color,
      enabled: enabled ?? this.enabled,
      textStyle: textStyle ?? this.textStyle,
      buttonStyle: buttonStyle ?? this.buttonStyle,
    );
  }
}
