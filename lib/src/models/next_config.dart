import 'package:features_tour/src/models/base_button_config.dart';
import 'package:flutter/material.dart';

class NextConfig extends BaseButtonConfig {

  /// Creates a new [NextConfig] based on the [global] values.
  ///
  /// [child] is a custom widget for the next button. When this is set,
  /// you must pass the `onPressed` method.
  /// Example:
  /// ```dart
  /// child: (onPressed) => FilledButton(
  ///   onPressed: onPressed,
  ///   child: const Text('NEXT'),
  /// ),
  /// ```
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
  /// [buttonStyle] specifies the [ButtonStyle] of the button.
  /// Example:
  /// ```dart
  ///    buttonStyle: ElevatedButton.styleFrom(
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

  const NextConfig._({
    super.child,
    super.text = 'NEXT',
    super.alignment = Alignment.bottomRight,
    super.color,
    super.enabled = true,
    super.textStyle,
    super.buttonStyle,
  });
  /// Global configuration.
  static NextConfig global = const NextConfig._();

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
