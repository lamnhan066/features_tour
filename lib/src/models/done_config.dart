import 'package:features_tour/src/models/base_config.dart';
import 'package:flutter/material.dart';

class DoneConfig extends BaseConfig {
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
  factory DoneConfig.copyWith({
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
