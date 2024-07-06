import 'package:features_tour/src/models/base_config.dart';
import 'package:flutter/material.dart';

class SkipConfig extends BaseConfig {
  /// Global configuration.
  static SkipConfig global = const SkipConfig._();

  /// Call the `onPressed` action when the skip button is pressed. Default is `false`.
  final bool isCallOnPressed;

  const SkipConfig._({
    super.child,
    super.text = 'SKIP',
    super.alignment = Alignment.bottomLeft,
    super.color,
    super.enabled = true,
    this.isCallOnPressed = false,
    super.textStyle,
    super.buttonStyle,
  });

  /// Create a new SkipConfig base on the [global] values.
  ///
  /// [text] of skip button, default is 'SKIP'.
  ///
  /// [alignment] is the position of the skip text, default is `Alignment.bottomLeft`.
  ///
  /// [color] is the color of skip text, default is `null`.
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
  factory SkipConfig({
    Widget Function(VoidCallback onPressed)? child,
    String? text,
    Alignment? alignment,
    Color? color,
    bool? enabled,
    bool? isCallOnPressed,
    TextStyle? textStyle,
    ButtonStyle? buttonStyle,
  }) {
    return global.copyWith(
      child: child,
      text: text,
      alignment: alignment,
      color: color,
      enabled: enabled,
      isCallOnPressed: isCallOnPressed,
      textStyle: textStyle,
      buttonStyle: buttonStyle,
    );
  }

  /// Create a new SkipConfig base on the [global] values.
  ///
  /// [text] of skip button, default is 'SKIP'.
  ///
  /// [alignment] is the position of the skip text, default is `Alignment.bottomLeft`.
  ///
  /// [color] is the color of skip text, default is `null`.
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
  @Deprecated('Use `SkipConfig` instead.')
  factory SkipConfig.copyWith({
    Widget Function(VoidCallback onPressed)? child,
    String? text,
    Alignment? alignment,
    Color? color,
    bool? enabled,
    bool? isCallOnPressed,
    TextStyle? textStyle,
    ButtonStyle? buttonStyle,
  }) = SkipConfig;

  /// Create a new SkipConfig base on this values.
  @override
  SkipConfig copyWith({
    Widget Function(VoidCallback onPressed)? child,
    String? text,
    Alignment? alignment,
    Color? color,
    bool? enabled,
    bool? isCallOnPressed,
    TextStyle? textStyle,
    ButtonStyle? buttonStyle,
  }) {
    return SkipConfig._(
      child: child,
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
