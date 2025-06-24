import 'package:features_tour/src/models/base_button_config.dart';
import 'package:flutter/material.dart';

class DoneConfig extends BaseButtonConfig {
  /// Global configuration.
  static DoneConfig global = DoneConfig._();

  DoneConfig._({
    super.child,
    super.text = 'DONE',
    super.alignment = Alignment.bottomRight,
    super.color,
    super.enabled = true,
    super.textStyle,
    super.buttonStyle,
  });

  /// Creates a new [DoneConfig] based on the [global] values.
  ///
  /// [child] is a custom widget for the done button. When this is set,
  /// you must pass the `onPressed` method.
  /// Example:
  /// ```dart
  /// child: (onPressed) => FilledButton(
  ///   onPressed: onPressed,
  ///   child: const Text('DONE'),
  /// ),
  /// ```
  ///
  /// [text] is the text displayed on the button. Defaults to 'SKIP'.
  ///
  /// [alignment] determines the position of the skip text. Defaults to
  /// `Alignment.bottomLeft`.
  ///
  /// [color] sets the color of the skip text. Defaults to `null`.
  ///
  /// [enabled] determines whether the skip button is enabled. Defaults to `true`.
  ///
  /// [textStyle] defines the text style for the button.
  ///
  /// [buttonStyle] defines the button's style, such as its shape and borders.
  /// Example:
  /// ``` dart
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
  factory DoneConfig({
    Widget Function(VoidCallback onPressed)? child,
    String? text,
    Alignment? alignment,
    Color? color,
    bool? enabled,
    TextStyle? textStyle,
    ButtonStyle? buttonStyle,
  }) =>
      global.copyWith(
        child: child,
        text: text,
        alignment: alignment,
        color: color,
        enabled: enabled,
        textStyle: textStyle,
        buttonStyle: buttonStyle,
      );

  /// Create a new DoneConfig base on the [global] values.
  ///
  /// [text] of skip button, default is 'SKIP'.
  ///
  /// [alignment] is the position of the skip text, default is `Alignment.bottomLeft`.
  ///
  /// [color] is the color of skip text, default is `null`.
  ///
  /// [enabled] whether the skip button is enabled or not, default is `true`.
  ///
  /// [textStyle] is the [TextStyle] of the button.
  ///
  /// [buttonStyle] is the [ButtonStyle] of the button.
  /// Example:
  /// ``` dart
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
  @Deprecated('Use `DoneConfig` instead.')
  factory DoneConfig.copyWith({
    Widget Function(VoidCallback onPressed)? child,
    String? text,
    Alignment? alignment,
    Color? color,
    bool? enabled,
    TextStyle? textStyle,
    ButtonStyle? buttonStyle,
  }) = DoneConfig;

  /// Create a new DoneConfig base on this values.
  @override
  DoneConfig copyWith({
    Widget Function(VoidCallback onPressed)? child,
    String? text,
    Alignment? alignment,
    Color? color,
    bool? enabled,
    TextStyle? textStyle,
    ButtonStyle? buttonStyle,
  }) {
    return DoneConfig._(
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
