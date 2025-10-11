import 'package:features_tour/src/models/base_button_config.dart';
import 'package:flutter/material.dart';

/// Configuration for the "Done" button in the Features Tour.
class DoneConfig extends BaseButtonConfig {
  /// Creates a new [DoneConfig] based on the [global] values.
  ///
  /// [builder] is a builder function that provides a context and an `onPressed` callback
  /// to create a custom done button widget.
  ///
  /// [text] is the text displayed on the button. The default is 'DONE'.
  ///
  /// [alignment] determines the position of the done text. The default is
  /// `Alignment.bottomRight`.
  ///
  /// [color] sets the color of the done text. The default is `null`.
  ///
  /// [enabled] determines whether the done button is enabled. The default is `true`.
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
    Widget Function(BuildContext context, VoidCallback onPressed)? builder,
    String? text,
    Alignment? alignment,
    Color? color,
    bool? enabled,
    TextStyle? textStyle,
    ButtonStyle? buttonStyle,
  }) =>
      global.copyWith(
        builder: builder,
        text: text,
        alignment: alignment,
        color: color,
        enabled: enabled,
        textStyle: textStyle,
        buttonStyle: buttonStyle,
      );

  DoneConfig._({
    super.builder,
    super.text = 'DONE',
    super.alignment = Alignment.bottomRight,
    super.color,
    super.enabled = true,
    super.textStyle,
    super.buttonStyle,
  });

  /// Global configuration.
  static DoneConfig global = DoneConfig._();

  /// Creates a new DoneConfig based on these values.
  @override
  DoneConfig copyWith({
    Widget Function(BuildContext context, VoidCallback onPressed)? builder,
    String? text,
    Alignment? alignment,
    Color? color,
    bool? enabled,
    TextStyle? textStyle,
    ButtonStyle? buttonStyle,
  }) {
    return DoneConfig._(
      builder: builder ?? this.builder,
      text: text ?? this.text,
      alignment: alignment ?? this.alignment,
      color: color ?? this.color,
      enabled: enabled ?? this.enabled,
      textStyle: textStyle ?? this.textStyle,
      buttonStyle: buttonStyle ?? this.buttonStyle,
    );
  }
}
