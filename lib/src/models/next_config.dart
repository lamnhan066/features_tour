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

  /// Creates a new [NextConfig] based on the [global] values.
  ///
  /// [child] is a custom widget for the next button. When this is set,
  /// you must pass the `onPressed` method.
  ///
  /// [text] defines the text on the next button. Defaults to "NEXT".
  ///
  /// [alignment] specifies the alignment of the next button. Defaults to
  /// `Alignment.bottomRight`.
  ///
  /// [color] sets the color of the next button text. Defaults to `null`.
  ///
  /// [enabled] indicates whether the next button is enabled. Defaults to `true`.
  ///
  /// [textStyle] defines the [TextStyle] for the button text.
  ///
  /// [buttonStyle] specifies the [ButtonStyle] of the button. Default:
  /// ```dart
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
  factory NextConfig({
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
  @Deprecated('Use `NextConfig` instead.')
  factory NextConfig.copyWith({
    Widget Function(VoidCallback onPressed)? child,
    String? text,
    Alignment? alignment,
    Color? color,
    bool? enabled,
    TextStyle? textStyle,
    ButtonStyle? buttonStyle,
  }) = NextConfig;

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
